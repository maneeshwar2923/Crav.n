import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../core/services/supabase_partner_service.dart';
import '../../core/utils/error_utils.dart';

class ManageOrdersScreen extends StatefulWidget {
  const ManageOrdersScreen({super.key});

  @override
  State<ManageOrdersScreen> createState() => _ManageOrdersScreenState();
}

class _ManageOrdersScreenState extends State<ManageOrdersScreen> {
  static const List<String> _baseStatuses = [
    'pending',
    'accepted',
    'ready',
    'collected',
    'cancelled',
  ];

  final _service = SupabasePartnerService.instance;
  final DateFormat _placedAtFormat = DateFormat('MMM d • h:mm a');

  List<Map<String, dynamic>> _orders = const <Map<String, dynamic>>[];
  List<String> _statusTabs = _baseStatuses;
  bool _loading = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadOrders();
  }

  Future<void> _loadOrders() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final rows = await _service.getHostOrders(limit: 200);
      final statuses = <String>{..._baseStatuses};
      for (final row in rows) {
        final status = (row['status'] ?? '').toString();
        if (status.isNotEmpty) {
          statuses.add(status);
        }
      }
      final additionalStatuses = statuses
          .where((status) => !_baseStatuses.contains(status))
          .toList()
        ..sort();
      final orderedStatuses = [
        ..._baseStatuses,
        ...additionalStatuses,
      ];
      setState(() {
        _orders = rows;
        _statusTabs = orderedStatuses;
      });
    } catch (e) {
      final message = resolveDisplayError(e);
      if (mounted) {
        setState(() => _error = message);
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(message)));
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  List<Map<String, dynamic>> _ordersForStatus(String status) {
    return _orders
        .where((order) => (order['status'] ?? '').toString() == status)
        .toList();
  }

  String _statusLabel(String status) {
    switch (status) {
      case 'pending':
        return 'Pending';
      case 'accepted':
        return 'Accepted';
      case 'ready':
        return 'Ready for pickup';
      case 'collected':
        return 'Collected';
      case 'cancelled':
        return 'Cancelled';
      case 'completed':
        return 'Completed';
      case 'rejected':
        return 'Declined';
      default:
        return status.isEmpty
            ? 'Unknown'
            : '${status[0].toUpperCase()}${status.substring(1)}';
    }
  }

  Future<void> _updateOrderStatus(
    Map<String, dynamic> order,
    String nextStatus,
  ) async {
    final id = order['id']?.toString();
    if (id == null || id.isEmpty) return;
    final ok = await _service.updateOrderStatus(
      orderId: id,
      status: nextStatus,
    );
    if (!mounted) return;
    if (ok) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Order marked ${_statusLabel(nextStatus)}.')),
      );
      await _loadOrders();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Could not update order ${order['id']}.')),
      );
    }
  }

  Future<void> _confirmStatusChange({
    required Map<String, dynamic> order,
    required String nextStatus,
    String? prompt,
  }) async {
    final shouldProceed = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Confirm action'),
          content: Text(
            prompt ??
                'Update this order to ${_statusLabel(nextStatus).toLowerCase()}?',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text('Confirm'),
            ),
          ],
        );
      },
    );
    if (shouldProceed == true) {
      await _updateOrderStatus(order, nextStatus);
    }
  }

  Future<void> _contactPhone(String? phone) async {
    final sanitized = phone?.trim();
    if (sanitized == null || sanitized.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('No phone number on file for this diner.')),
      );
      return;
    }
    final uri = Uri(scheme: 'tel', path: sanitized);
    if (!await launchUrl(uri)) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Could not dial $sanitized.')),
      );
    }
  }

  Future<void> _contactEmail(String? email) async {
    final sanitized = email?.trim();
    if (sanitized == null || sanitized.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No email on file for this diner.')),
      );
      return;
    }
    final uri = Uri(
      scheme: 'mailto',
      path: sanitized,
    );
    if (!await launchUrl(uri)) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Could not open email for $sanitized.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final tabs = _statusTabs.isEmpty ? _baseStatuses : _statusTabs;
    return DefaultTabController(
      length: tabs.length,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Manage orders'),
          bottom: TabBar(
            isScrollable: true,
            tabs: [
              for (final status in tabs) Tab(text: _statusLabel(status)),
            ],
          ),
          actions: [
            IconButton(
              onPressed: _loadOrders,
              icon: const Icon(Icons.refresh_outlined),
              tooltip: 'Reload orders',
            ),
          ],
        ),
        body: _loading
            ? const Center(child: CircularProgressIndicator(color: cravnPrimary))
            : TabBarView(
                children: [
                  for (final status in tabs)
                    RefreshIndicator(
                      onRefresh: _loadOrders,
                      child: _buildOrderList(status),
                    ),
                ],
              ),
      ),
    );
  }

  Widget _buildOrderList(String status) {
    final items = _ordersForStatus(status);
    if (items.isEmpty) {
      return ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(24),
        children: [
          if (_error != null)
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Text(_error!),
              ),
            ),
          if (_error != null) const SizedBox(height: 12),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Text(
                'No ${_statusLabel(status).toLowerCase()} orders yet.',
              ),
            ),
          ),
        ],
      );
    }
    return ListView.separated(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
      itemCount: items.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final order = items[index];
        return _OrderCard(
          order: order,
          statusLabel: _statusLabel(status),
          placedAtFormat: _placedAtFormat,
          onAccept: () =>
              _confirmStatusChange(order: order, nextStatus: 'accepted'),
          onDecline: () => _confirmStatusChange(
            order: order,
            nextStatus: 'cancelled',
            prompt: 'Decline this order request?',
          ),
          onMarkReady: () =>
              _confirmStatusChange(order: order, nextStatus: 'ready'),
          onMarkCollected: () =>
              _confirmStatusChange(order: order, nextStatus: 'collected'),
          onCancel: () => _confirmStatusChange(
            order: order,
            nextStatus: 'cancelled',
            prompt: 'Cancel this order?',
          ),
          onCallDiner: () => _contactPhone(order['contact_phone'] as String?),
          onEmailDiner: () => _contactEmail(order['contact_email'] as String?),
        );
      },
    );
  }
}

class _OrderCard extends StatelessWidget {
  const _OrderCard({
    required this.order,
    required this.statusLabel,
    required this.placedAtFormat,
    required this.onAccept,
    required this.onDecline,
    required this.onMarkReady,
    required this.onMarkCollected,
    required this.onCancel,
    required this.onCallDiner,
    required this.onEmailDiner,
  });

  final Map<String, dynamic> order;
  final String statusLabel;
  final DateFormat placedAtFormat;
  final VoidCallback onAccept;
  final VoidCallback onDecline;
  final VoidCallback onMarkReady;
  final VoidCallback onMarkCollected;
  final VoidCallback onCancel;
  final VoidCallback onCallDiner;
  final VoidCallback onEmailDiner;

  @override
  Widget build(BuildContext context) {
    final listing = order['food_listings'] as Map<String, dynamic>?;
    final title = (listing?['title'] ?? order['listing_title'] ?? 'Rescue meal')
        .toString();
    final status = (order['status'] ?? '').toString();
    final quantity = (order['quantity'] as num?)?.toInt() ?? 1;
    final price = (listing?['price'] as num?)?.toDouble() ?? 0;
    final placedAtRaw = order['placed_at']?.toString();
    DateTime? placedAt;
    if (placedAtRaw != null) {
      placedAt = DateTime.tryParse(placedAtRaw);
    }
    final profile = order['profiles'] as Map<String, dynamic>?;
    final diner =
        profile?['full_name']?.toString() ?? order['customer_name']?.toString();

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text('x$quantity • ₹${price.toStringAsFixed(0)}'),
                      if (diner != null && diner.isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.only(top: 4),
                          child: Text('Diner: $diner'),
                        ),
                      if (placedAt != null)
                        Padding(
                          padding: const EdgeInsets.only(top: 4),
                          child: Text(
                            'Placed ${placedAtFormat.format(placedAt.toLocal())}',
                            style: const TextStyle(color: Color(0xFF5C7470)),
                          ),
                        ),
                    ],
                  ),
                ),
                Chip(
                  label: Text(statusLabel),
                  backgroundColor: _statusColor(status),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _buildActions(status),
            ),
            const Divider(height: 24),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: onCallDiner,
                    icon: const Icon(Icons.phone_outlined),
                    label: const Text('Call diner'),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: onEmailDiner,
                    icon: const Icon(Icons.email_outlined),
                    label: const Text('Email diner'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  List<Widget> _buildActions(String status) {
    switch (status) {
      case 'pending':
        return [
          ElevatedButton.icon(
            onPressed: onAccept,
            icon: const Icon(Icons.check_circle_outline),
            label: const Text('Accept'),
          ),
          OutlinedButton.icon(
            onPressed: onDecline,
            icon: const Icon(Icons.cancel_outlined),
            label: const Text('Decline'),
          ),
        ];
      case 'accepted':
        return [
          ElevatedButton.icon(
            onPressed: onMarkReady,
            icon: const Icon(Icons.restaurant_outlined),
            label: const Text('Mark ready'),
          ),
          OutlinedButton.icon(
            onPressed: onCancel,
            icon: const Icon(Icons.cancel_outlined),
            label: const Text('Cancel order'),
          ),
        ];
      case 'ready':
        return [
          ElevatedButton.icon(
            onPressed: onMarkCollected,
            icon: const Icon(Icons.task_alt_outlined),
            label: const Text('Mark collected'),
          ),
          OutlinedButton.icon(
            onPressed: onCallDiner,
            icon: const Icon(Icons.phone_outlined),
            label: const Text('Call diner'),
          ),
        ];
      default:
        return [
          OutlinedButton.icon(
            onPressed: null,
            icon: const Icon(Icons.receipt_long_outlined),
            label: const Text('View details'),
          ),
        ];
    }
  }

  static Color _statusColor(String status) {
    switch (status) {
      case 'pending':
        return const Color(0xFFFFF3E0);
      case 'accepted':
        return const Color(0xFFE0F7FA);
      case 'ready':
        return const Color(0xFFE8F5E9);
      case 'collected':
        return const Color(0xFFE8EAF6);
      case 'cancelled':
        return const Color(0xFFFFEBEE);
      default:
        return const Color(0xFFE0E0E0);
    }
  }
}
