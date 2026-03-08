import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../../../core/theme/colors.dart';
import '../../../../core/theme/dimensions.dart';
import '../../../../core/services/supabase_partner_service.dart';

class AnalyticsScreen extends StatefulWidget {
  const AnalyticsScreen({super.key});

  @override
  State<AnalyticsScreen> createState() => _AnalyticsScreenState();
}

class _AnalyticsScreenState extends State<AnalyticsScreen> {
  bool _loading = true;
  double _totalRevenue = 0.0;
  int _totalOrders = 0;
  List<Map<String, dynamic>> _orders = [];

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _loading = true);
    // Fetch last 50 orders for analytics
    final orders = await SupabasePartnerService.instance.getHostOrders(limit: 50);
    
    double revenue = 0;
    int count = 0;
    
    for (var order in orders) {
      final status = (order['status'] ?? '').toString().toUpperCase();
      if (status == 'COMPLETED' || status == 'COLLECTED') {
        revenue += (order['total_price'] as num?)?.toDouble() ?? 0.0;
        count++;
      }
    }

    if (mounted) {
      setState(() {
        _orders = orders;
        _totalRevenue = revenue;
        _totalOrders = count;
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: cravnBackground,
      appBar: AppBar(
        title: const Text('Analytics'),
        backgroundColor: cravnBackground,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadData,
          ),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator(color: cravnPrimary))
          : SingleChildScrollView(
              padding: const EdgeInsets.all(Dimensions.s16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Summary Cards
                  Row(
                    children: [
                      Expanded(
                        child: _MetricCard(
                          title: 'Total Revenue',
                          value: '₹${_totalRevenue.toStringAsFixed(0)}',
                          icon: Icons.currency_rupee,
                          color: Colors.green,
                        ),
                      ),
                      const SizedBox(width: Dimensions.s16),
                      Expanded(
                        child: _MetricCard(
                          title: 'Completed Orders',
                          value: _totalOrders.toString(),
                          icon: Icons.shopping_bag_outlined,
                          color: cravnPrimary,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: Dimensions.s24),

                  // Revenue Chart
                  const Text('Revenue Trend', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
                  const SizedBox(height: Dimensions.s16),
                  Container(
                    height: 300,
                    padding: const EdgeInsets.all(Dimensions.s16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(Dimensions.radiusMd),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: LineChart(
                      LineChartData(
                        gridData: const FlGridData(show: false),
                        titlesData: FlTitlesData(
                          leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                          topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                          rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                          bottomTitles: AxisTitles(
                            sideTitles: SideTitles(
                              showTitles: true,
                              getTitlesWidget: (value, meta) {
                                return const Text(''); // Simplified for now
                              },
                            ),
                          ),
                        ),
                        borderData: FlBorderData(show: false),
                        lineBarsData: [
                          LineChartBarData(
                            spots: _generateSpots(),
                            isCurved: true,
                            color: cravnPrimary,
                            barWidth: 3,
                            isStrokeCapRound: true,
                            dotData: const FlDotData(show: false),
                            belowBarData: BarAreaData(
                              show: true,
                              color: cravnPrimary.withOpacity(0.1),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  List<FlSpot> _generateSpots() {
    // Mock data generation based on orders if real data is sparse
    if (_orders.isEmpty) {
      return [
        const FlSpot(0, 0),
        const FlSpot(1, 200),
        const FlSpot(2, 150),
        const FlSpot(3, 300),
        const FlSpot(4, 250),
        const FlSpot(5, 400),
      ];
    }
    
    // Simple mapping for demo purposes
    // In a real app, we'd aggregate by date
    List<FlSpot> spots = [];
    double current = 0;
    for (int i = 0; i < _orders.length && i < 7; i++) {
      current += (_orders[i]['total_price'] as num?)?.toDouble() ?? 0.0;
      spots.add(FlSpot(i.toDouble(), current));
    }
    return spots;
  }
}

class _MetricCard extends StatelessWidget {
  const _MetricCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
  });

  final String title;
  final String value;
  final IconData icon;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(Dimensions.s16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(Dimensions.radiusMd),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 28),
          const SizedBox(height: Dimensions.s12),
          Text(
            value,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            title,
            style: TextStyle(
              color: Colors.grey[600],
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}
