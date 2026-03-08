import 'package:flutter/material.dart';
import '../../../../core/theme/colors.dart';
import '../../../../core/theme/dimensions.dart';
import '../../../../core/services/supabase_partner_service.dart';

class PayoutsScreen extends StatefulWidget {
  const PayoutsScreen({super.key});

  @override
  State<PayoutsScreen> createState() => _PayoutsScreenState();
}

class _PayoutsScreenState extends State<PayoutsScreen> {
  bool _loading = true;
  List<Map<String, dynamic>> _payouts = [];
  double _availableBalance = 0.0; // This would ideally come from a 'balances' table

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _loading = true);
    final payouts = await SupabasePartnerService.instance.getPayouts();
    
    // Calculate mock balance based on orders if real balance isn't available
    // For now, we'll just set a static mock balance or fetch from profile if added later
    // In a real app, this should be a secure backend calculation
    final metrics = await SupabasePartnerService.instance.getHostListingMetrics();
    double totalRevenue = metrics.fold(0, (sum, item) => sum + (item['gross_revenue'] as num).toDouble());
    double totalWithdrawn = payouts.fold(0, (sum, item) => sum + (item['amount'] as num).toDouble());
    
    if (mounted) {
      setState(() {
        _payouts = payouts;
        _availableBalance = (totalRevenue - totalWithdrawn).clamp(0, double.infinity);
        _loading = false;
      });
    }
  }

  Future<void> _requestPayout() async {
    if (_availableBalance <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No funds available to withdraw')),
      );
      return;
    }

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirm Withdrawal'),
        content: Text('Withdraw ₹${_availableBalance.toStringAsFixed(2)} to your linked account?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: cravnPrimary),
            child: const Text('Withdraw', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      setState(() => _loading = true);
      final success = await SupabasePartnerService.instance.requestPayout(_availableBalance);
      if (mounted) {
        if (success) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Withdrawal request submitted')),
          );
          _loadData();
        } else {
          setState(() => _loading = false);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Failed to request withdrawal')),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6F7F7),
      appBar: AppBar(
        title: const Text('Payouts'),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator(color: cravnPrimary))
          : RefreshIndicator(
              onRefresh: _loadData,
              child: ListView(
                padding: const EdgeInsets.all(Dimensions.s16),
                children: [
                  // Balance Card
                  Container(
                    padding: const EdgeInsets.all(Dimensions.s24),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [cravnPrimary, Color(0xFF2D6A4F)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(Dimensions.radiusLg),
                      boxShadow: [
                        BoxShadow(
                          color: cravnPrimary.withOpacity(0.3),
                          blurRadius: 12,
                          offset: const Offset(0, 6),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Available Balance',
                          style: TextStyle(color: Colors.white70, fontSize: 14),
                        ),
                        const SizedBox(height: Dimensions.s8),
                        Text(
                          '₹${_availableBalance.toStringAsFixed(2)}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: Dimensions.s24),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: _requestPayout,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.white,
                              foregroundColor: cravnPrimary,
                              padding: const EdgeInsets.symmetric(vertical: 12),
                            ),
                            child: const Text('Withdraw Earnings'),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: Dimensions.s24),

                  // Transaction History
                  const Text(
                    'Transaction History',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: Dimensions.s12),
                  if (_payouts.isEmpty)
                    const Center(
                      child: Padding(
                        padding: EdgeInsets.all(32.0),
                        child: Text('No transactions yet'),
                      ),
                    )
                  else
                    ..._payouts.map((payout) => _PayoutTile(payout: payout)),
                ],
              ),
            ),
    );
  }
}

class _PayoutTile extends StatelessWidget {
  const _PayoutTile({required this.payout});

  final Map<String, dynamic> payout;

  @override
  Widget build(BuildContext context) {
    final amount = (payout['amount'] as num).toDouble();
    final status = (payout['status'] ?? 'pending').toString().toUpperCase();
    final date = DateTime.tryParse(payout['requested_at'] ?? '') ?? DateTime.now();

    Color statusColor = Colors.orange;
    if (status == 'COMPLETED') statusColor = Colors.green;
    if (status == 'FAILED') statusColor = Colors.red;

    return Card(
      margin: const EdgeInsets.only(bottom: Dimensions.s12),
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: statusColor.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(
            status == 'COMPLETED' ? Icons.check : Icons.access_time,
            color: statusColor,
          ),
        ),
        title: Text('Withdrawal'),
        subtitle: Text(_formatDate(date)),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              '- ₹${amount.toStringAsFixed(2)}',
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            Text(
              status,
              style: TextStyle(color: statusColor, fontSize: 10, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}
