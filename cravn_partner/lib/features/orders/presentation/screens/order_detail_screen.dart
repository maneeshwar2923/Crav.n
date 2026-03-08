import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../../core/theme/colors.dart';
import '../../../../core/theme/dimensions.dart';
import '../../../../core/services/supabase_partner_service.dart';

class OrderDetailScreen extends StatefulWidget {
  const OrderDetailScreen({super.key, required this.order});

  final Map<String, dynamic> order;

  @override
  State<OrderDetailScreen> createState() => _OrderDetailScreenState();
}

class _OrderDetailScreenState extends State<OrderDetailScreen> {
  late String _status;
  bool _updating = false;

  @override
  void initState() {
    super.initState();
    _status = (widget.order['status'] ?? 'PENDING').toString().toUpperCase();
  }

  Future<void> _updateStatus(String newStatus) async {
    setState(() => _updating = true);
    final success = await SupabasePartnerService.instance.updateOrderStatus(
      orderId: widget.order['id'],
      status: newStatus.toLowerCase(),
    );
    
    if (mounted) {
      setState(() => _updating = false);
      if (success) {
        setState(() => _status = newStatus);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Order marked as $newStatus')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to update status')),
        );
      }
    }
  }

  Future<void> _callCustomer(String? phone) async {
    if (phone == null || phone.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No phone number available')),
      );
      return;
    }
    final uri = Uri.parse('tel:$phone');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Could not launch dialer')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final order = widget.order;
    final id = order['id'].toString().substring(0, 8).toUpperCase();
    final listing = order['food_listings'] ?? {};
    final customer = order['profiles'] ?? {};
    final placedAt = DateTime.tryParse(order['placed_at'] ?? '') ?? DateTime.now();
    final quantity = order['quantity'] ?? 1;
    final price = (order['total_price'] ?? 0.0).toStringAsFixed(2);
    
    Color statusColor = Colors.grey;
    if (_status == 'PENDING') statusColor = Colors.orange;
    if (_status == 'CONFIRMED') statusColor = Colors.blue;
    if (_status == 'READY') statusColor = Colors.green;
    if (_status == 'COLLECTED') statusColor = Colors.grey;
    if (_status == 'CANCELLED') statusColor = Colors.red;

    return Scaffold(
      backgroundColor: const Color(0xFFF6F7F7),
      appBar: AppBar(
        title: Text('Order #$id'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(Dimensions.s16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Status Card
            Card(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(Dimensions.radiusMd)),
              child: Padding(
                padding: const EdgeInsets.all(Dimensions.s16),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: statusColor.withOpacity(0.1),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(Icons.info_outline, color: statusColor),
                    ),
                    const SizedBox(width: Dimensions.s16),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Current Status', style: TextStyle(color: Colors.grey)),
                        Text(
                          _status,
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: statusColor,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: Dimensions.s16),

            // Item Details
            const Text('Order Details', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: Dimensions.s8),
            Card(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(Dimensions.radiusMd)),
              child: Padding(
                padding: const EdgeInsets.all(Dimensions.s16),
                child: Row(
                  children: [
                    Container(
                      width: 60,
                      height: 60,
                      decoration: BoxDecoration(
                        color: cravnPrimary.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(Dimensions.radiusSm),
                        image: listing['image'] != null
                            ? DecorationImage(
                                image: NetworkImage(listing['image']),
                                fit: BoxFit.cover,
                              )
                            : null,
                      ),
                      child: listing['image'] == null
                          ? const Icon(Icons.fastfood, color: cravnPrimary)
                          : null,
                    ),
                    const SizedBox(width: Dimensions.s16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            listing['title'] ?? 'Unknown Item',
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                          ),
                          Text('Quantity: $quantity'),
                        ],
                      ),
                    ),
                    Text(
                      '₹$price',
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: Dimensions.s16),

            // Customer Details
            const Text('Customer', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: Dimensions.s8),
            Card(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(Dimensions.radiusMd)),
              child: Padding(
                padding: const EdgeInsets.all(Dimensions.s16),
                child: Row(
                  children: [
                    CircleAvatar(
                      backgroundColor: cravnPrimary.withOpacity(0.1),
                      child: Text(
                        (customer['full_name'] ?? 'G')[0].toUpperCase(),
                        style: const TextStyle(color: cravnPrimary),
                      ),
                    ),
                    const SizedBox(width: Dimensions.s16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            customer['full_name'] ?? 'Guest User',
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          Text(
                            'Placed at: ${_formatDate(placedAt)}',
                            style: const TextStyle(color: Colors.grey, fontSize: 12),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.phone, color: cravnPrimary),
                      onPressed: () => _callCustomer(customer['phone']),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: _buildActionButtons(),
    );
  }

  Widget? _buildActionButtons() {
    if (_status == 'CANCELLED' || _status == 'COLLECTED') return null;

    return Container(
      padding: const EdgeInsets.all(Dimensions.s16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (_status == 'PENDING') ...[
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _updating ? null : () => _updateStatus('CONFIRMED'),
                  style: ElevatedButton.styleFrom(backgroundColor: cravnPrimary),
                  child: _updating
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text('Accept Order', style: TextStyle(color: Colors.white)),
                ),
              ),
              const SizedBox(height: Dimensions.s12),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: OutlinedButton(
                  onPressed: _updating ? null : () => _updateStatus('CANCELLED'),
                  style: OutlinedButton.styleFrom(foregroundColor: Colors.red),
                  child: const Text('Reject Order'),
                ),
              ),
            ] else if (_status == 'CONFIRMED') ...[
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _updating ? null : () => _updateStatus('READY'),
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.blue),
                  child: const Text('Mark as Ready for Pickup', style: TextStyle(color: Colors.white)),
                ),
              ),
            ] else if (_status == 'READY') ...[
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _updating ? null : () => _updateStatus('COLLECTED'),
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                  child: const Text('Confirm Collection', style: TextStyle(color: Colors.white)),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year} ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
  }
}
