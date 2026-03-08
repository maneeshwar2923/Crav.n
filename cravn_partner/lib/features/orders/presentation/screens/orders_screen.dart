import 'package:flutter/material.dart';
import '../../../../core/theme/colors.dart';
import '../../../../core/theme/dimensions.dart';
import '../../../../core/services/supabase_partner_service.dart';
import 'order_detail_screen.dart';

class OrdersScreen extends StatefulWidget {
  const OrdersScreen({super.key});

  @override
  State<OrdersScreen> createState() => _OrdersScreenState();
}

class _OrdersScreenState extends State<OrdersScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  bool _loading = true;
  List<Map<String, dynamic>> _allOrders = [];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadOrders();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadOrders() async {
    setState(() => _loading = true);
    final orders = await SupabasePartnerService.instance.getHostOrders(limit: 50);
    if (mounted) {
      setState(() {
        _allOrders = orders;
        _loading = false;
      });
    }
  }

  List<Map<String, dynamic>> _filterOrders(String statusGroup) {
    return _allOrders.where((order) {
      final status = (order['status'] ?? '').toString().toLowerCase();
      if (statusGroup == 'active') {
        return ['pending', 'confirmed', 'ready'].contains(status);
      } else if (statusGroup == 'completed') {
        return ['collected', 'completed'].contains(status);
      } else if (statusGroup == 'cancelled') {
        return ['cancelled', 'rejected'].contains(status);
      }
      return false;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: cravnBackground,
      appBar: AppBar(
        title: const Text('Orders'),
        backgroundColor: cravnBackground,
        foregroundColor: Colors.white,
        bottom: TabBar(
          controller: _tabController,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          indicatorColor: Colors.white,
          indicatorWeight: 3,
          tabs: const [
            Tab(text: 'Active'),
            Tab(text: 'Completed'),
            Tab(text: 'Cancelled'),
          ],
        ),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator(color: cravnPrimary))
          : TabBarView(
              controller: _tabController,
              children: [
                _OrderList(
                  orders: _filterOrders('active'),
                  onRefresh: _loadOrders,
                ),
                _OrderList(
                  orders: _filterOrders('completed'),
                  onRefresh: _loadOrders,
                ),
                _OrderList(
                  orders: _filterOrders('cancelled'),
                  onRefresh: _loadOrders,
                ),
              ],
            ),
    );
  }
}

class _OrderList extends StatelessWidget {
  const _OrderList({required this.orders, required this.onRefresh});

  final List<Map<String, dynamic>> orders;
  final Future<void> Function() onRefresh;

  @override
  Widget build(BuildContext context) {
    if (orders.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.receipt_long_outlined, size: 64, color: Colors.grey),
            const SizedBox(height: 16),
            Text(
              'No orders found',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(color: Colors.grey),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: onRefresh,
      child: ListView.builder(
        padding: const EdgeInsets.all(Dimensions.s16),
        itemCount: orders.length,
        itemBuilder: (context, index) {
          final order = orders[index];
          return _OrderCard(order: order, onUpdate: onRefresh);
        },
      ),
    );
  }
}

class _OrderCard extends StatelessWidget {
  const _OrderCard({required this.order, required this.onUpdate});

  final Map<String, dynamic> order;
  final VoidCallback onUpdate;

  @override
  Widget build(BuildContext context) {
    final id = order['id'].toString().substring(0, 8).toUpperCase();
    final status = (order['status'] ?? 'PENDING').toString().toUpperCase();
    final total = (order['total_price'] ?? 0.0).toStringAsFixed(2);
    final placedAt = DateTime.tryParse(order['placed_at'] ?? '') ?? DateTime.now();
    final listing = order['food_listings'] ?? {};
    final title = listing['title'] ?? 'Unknown Item';
    final quantity = order['quantity'] ?? 1;
    final customer = order['profiles'] ?? {};
    final customerName = (customer['full_name'] ?? '').toString().isNotEmpty 
        ? customer['full_name'] 
        : (order['contact_email'] ?? 'Guest');
    final customerPhone = customer['phone_number'] as String?;

    Color statusColor = Colors.grey;
    if (status == 'PENDING') statusColor = Colors.orange;
    if (status == 'CONFIRMED') statusColor = Colors.blue;
    if (status == 'READY') statusColor = Colors.green;
    if (status == 'COLLECTED') statusColor = Colors.grey;
    if (status == 'CANCELLED') statusColor = Colors.red;

    return Card(
      margin: const EdgeInsets.only(bottom: Dimensions.s12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(Dimensions.radiusMd),
        side: const BorderSide(color: Color(0xFFE0E0E0)),
      ),
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => OrderDetailScreen(order: order),
            ),
          ).then((_) => onUpdate());
        },
        borderRadius: BorderRadius.circular(Dimensions.radiusMd),
        child: Padding(
          padding: const EdgeInsets.all(Dimensions.s16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '#$id',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.grey,
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: statusColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      status,
                      style: TextStyle(
                        color: statusColor,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: Dimensions.s12),
              Row(
                children: [
                  Container(
                    width: 48,
                    height: 48,
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
                        ? const Icon(Icons.fastfood, color: cravnPrimary, size: 24)
                        : null,
                  ),
                  const SizedBox(width: Dimensions.s12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        Text(
                          '$quantity x $title',
                          style: TextStyle(color: Colors.grey[600], fontSize: 13),
                        ),
                      ],
                    ),
                  ),
                  Text(
                    '₹$total',
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                ],
              ),
              const Divider(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Icon(Icons.person_outline, size: 16, color: Colors.grey),
                            const SizedBox(width: 4),
                            Flexible(
                              child: Text(
                                customerName,
                                style: const TextStyle(color: Colors.grey),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                        if (customerPhone != null && customerPhone.isNotEmpty) ...[
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              const Icon(Icons.phone_outlined, size: 14, color: cravnPrimary),
                              const SizedBox(width: 4),
                              Text(
                                customerPhone,
                                style: const TextStyle(color: cravnPrimary, fontSize: 13, fontWeight: FontWeight.w500),
                              ),
                            ],
                          ),
                        ],
                      ],
                    ),
                  ),
                  Text(
                    _formatDate(placedAt),
                    style: const TextStyle(color: Colors.grey, fontSize: 12),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month} ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
  }
}
