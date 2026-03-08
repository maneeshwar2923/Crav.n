import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../core/theme/colors.dart';
import '../../../../core/theme/dimensions.dart';
import '../../../../core/services/supabase_service.dart';

class OrdersScreen extends StatefulWidget {
  const OrdersScreen({super.key});

  @override
  State<OrdersScreen> createState() => _OrdersScreenState();
}

class _OrdersScreenState extends State<OrdersScreen> {
  bool _loading = true;
  final Set<String> _submitting = {};
  List<Map<String, dynamic>> _orders = [];

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    final orders = await SupabaseService.instance.getPastOrders();
    if (!mounted) return;
    setState(() {
      _orders = orders;
      _loading = false;
    });
  }

  Future<void> _confirmPickup(String orderId) async {
    setState(() => _submitting.add(orderId));
    final success = await SupabaseService.instance.confirmOrderPickup(
      orderId: orderId,
      method: 'user_confirmation',
    );
    if (!mounted) return;
    setState(() => _submitting.remove(orderId));
    if (success) {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('Pickup confirmed')));
      await _load();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Unable to confirm pickup.')),
      );
    }
  }

  Future<void> _submitReview(Map<String, dynamic> order) async {
    final listing = order['food_listings'] as Map<String, dynamic>?;
    final orderId = order['id']?.toString();
    if (listing == null || orderId == null) return;

    double rating = 4;
    final commentController = TextEditingController();
    final formKey = GlobalKey<FormState>();

    final shouldSubmit = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      builder: (sheetContext) {
        return Padding(
          padding: EdgeInsets.only(
            left: 20,
            right: 20,
            top: 20,
            bottom: MediaQuery.of(sheetContext).viewInsets.bottom + 20,
          ),
          child: StatefulBuilder(
            builder: (context, setModalState) {
              return Form(
                key: formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Rate ${listing['title'] ?? 'this meal'}',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Slider(
                      value: rating,
                      min: 1,
                      max: 5,
                      divisions: 8,
                      label: rating.toStringAsFixed(1),
                      onChanged: (value) => setModalState(() => rating = value),
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: commentController,
                      decoration: const InputDecoration(
                        labelText: 'Share your experience (optional)',
                        border: OutlineInputBorder(),
                      ),
                      minLines: 2,
                      maxLines: 4,
                      validator: (value) {
                        if ((value ?? '').trim().length > 240) {
                          return 'Please keep reviews under 240 characters';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 20),
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            onPressed: () =>
                                Navigator.of(sheetContext).pop(false),
                            child: const Text('Cancel'),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () {
                              if (formKey.currentState!.validate()) {
                                Navigator.of(sheetContext).pop(true);
                              }
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF006D3B),
                              foregroundColor: Colors.white,
                            ),
                            child: const Text('Submit review'),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              );
            },
          ),
        );
      },
    );

    if (shouldSubmit != true) {
      commentController.dispose();
      return;
    }

    setState(() => _submitting.add(orderId));
    try {
      await SupabaseService.instance.createReview(
        orderId: orderId,
        listingId: listing['id'].toString(),
        hostId: listing['owner_id']?.toString() ?? '',
        rating: rating.round(),
        comment: commentController.text.trim().isEmpty
            ? null
            : commentController.text.trim(),
      );
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Thanks for leaving a review!')),
      );
      await _load();
    } on AuthException catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(e.message)));
      }
    } on PostgrestException catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(e.message)));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Review failed: $e')),
        );
      }
    } finally {
      commentController.dispose();
      if (mounted) {
        setState(() => _submitting.remove(orderId));
      }
    }
  }

  Future<void> _openDirections(Map<String, dynamic> order) async {
    final listing = order['food_listings'] as Map<String, dynamic>?;
    final double? lat = (listing?['lat'] as num?)?.toDouble();
    final double? lng = (listing?['lng'] as num?)?.toDouble();
    if (lat == null || lng == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Host has not provided a pickup location yet.'),
        ),
      );
      return;
    }
    final uri = Uri.parse(
      'https://www.google.com/maps/dir/?api=1&destination=$lat,$lng&travelmode=walking',
    );
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Could not open maps on this device.')),
      );
    }
  }

  /// Launch phone dialer with the given number
  Future<void> _launchPhone(String phone) async {
    final uri = Uri.parse('tel:$phone');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Could not open phone app')),
        );
      }
    }
  }

  /// Launch SMS app with the given number
  Future<void> _launchSms(String phone) async {
    final uri = Uri.parse('sms:$phone');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Could not open SMS app')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: cravnBackground,
      appBar: AppBar(title: const Text('Orders')),
      body: _loading
          ? const Center(child: CircularProgressIndicator(color: cravnPrimary))
          : RefreshIndicator(
              onRefresh: _load,
              child: ListView(
                padding: const EdgeInsets.all(20),
                children: [
                  if (_orders.isEmpty)
                    _sectionCard(
                      title: 'Your meal requests',
                      child: const Padding(
                        padding: EdgeInsets.symmetric(vertical: 20),
                        child: Text(
                          'You have not requested any meals yet. Rescue your first meal to see it here.',
                        ),
                      ),
                    )
                  else
                    _sectionCard(
                      title: 'Your meal requests',
                      child: Column(
                        children: _orders.map(_buildOrderTile).toList(),
                      ),
                    ),
                ],
              ),
            ),
    );
  }

  Widget _buildOrderTile(Map<String, dynamic> order) {
    final listing = order['food_listings'] as Map<String, dynamic>?;
    final status = (order['status'] ?? 'pending').toString();
    final orderId = order['id']?.toString() ?? '';
    final canNavigate = status == 'accepted' || status == 'ready_for_pickup';
    final canConfirm = status == 'accepted' || status == 'ready_for_pickup';
    final hasReview =
        order['reviews'] is List && (order['reviews'] as List).isNotEmpty;
    final canReview =
        (status == 'collected' || status == 'completed') && !hasReview;
    final submitting = _submitting.contains(orderId);
    final Map<String, dynamic>? review = hasReview
        ? Map<String, dynamic>.from(
            (order['reviews'] as List).first as Map<String, dynamic>)
        : null;
    final reviewComment = review?['comment']?.toString() ?? '';

    return Column(
      children: [
        ListTile(
          contentPadding: EdgeInsets.zero,
          leading: CircleAvatar(
            backgroundColor: const Color(0xFFE7F6EE),
            backgroundImage: listing?['image'] != null
                ? NetworkImage(listing!['image'] as String)
                : null,
            child: listing?['image'] == null
                ? const Icon(Icons.fastfood_outlined, color: Color(0xFF006D3B))
                : null,
          ),
          title: Text(listing?['title'] ?? 'Listing'),
          subtitle: Text('Status: ${status.toUpperCase()}'),
          trailing: canNavigate
              ? TextButton.icon(
                  onPressed: () => _openDirections(order),
                  icon: const Icon(Icons.map_outlined, color: cravnPrimary),
                  label: const Text('Directions', style: TextStyle(color: cravnPrimary)),
                )
              : null,
        ),
        if (listing?['price'] != null)
          Align(
            alignment: Alignment.centerLeft,
            child: Text(
              'Contribution: ₹${listing!['price']}',
              style: const TextStyle(color: Color(0xFF5C7470)),
            ),
          ),
        if (order['contact_phone'] != null)
          Align(
            alignment: Alignment.centerLeft,
            child: Text(
              'Host contact: ${order['contact_phone']}',
              style: const TextStyle(color: Color(0xFF5C7470)),
            ),
          ),
        // Contact Host buttons (Call/Text)
        if (order['contact_phone'] != null && canNavigate)
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => _launchPhone(order['contact_phone']),
                    icon: const Icon(Icons.phone, size: 18, color: cravnPrimary),
                    label: const Text('Call', style: TextStyle(color: cravnPrimary)),
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: cravnPrimary),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(Dimensions.radiusMd)),
                      padding: const EdgeInsets.symmetric(vertical: 10),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => _launchSms(order['contact_phone']),
                    icon: const Icon(Icons.message, size: 18, color: cravnPrimary),
                    label: const Text('Text', style: TextStyle(color: cravnPrimary)),
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: cravnPrimary),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(Dimensions.radiusMd)),
                      padding: const EdgeInsets.symmetric(vertical: 10),
                    ),
                  ),
                ),
              ],
            ),
          ),
        if (canConfirm || canReview)
          Padding(
            padding: const EdgeInsets.only(top: 12, bottom: 4),
            child: Row(
              children: [
                if (canConfirm)
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed:
                          submitting ? null : () => _confirmPickup(orderId),
                      icon: submitting
                          ? const SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor:
                                    AlwaysStoppedAnimation<Color>(Colors.white),
                              ),
                            )
                          : const Icon(Icons.check_circle_outline),
                      label: const Text('Confirm pickup'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: cravnPrimary,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(Dimensions.radiusMd)),
                      ),
                    ),
                  ),
                if (canConfirm && canReview) const SizedBox(width: 12),
                if (canReview)
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: submitting ? null : () => _submitReview(order),
                      icon: const Icon(Icons.rate_review_outlined, color: cravnPrimary),
                      label: const Text('Leave review', style: TextStyle(color: cravnPrimary)),
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: cravnPrimary),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(Dimensions.radiusMd)),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        if (hasReview && review != null)
          Container(
            width: double.infinity,
            margin: const EdgeInsets.only(top: 12, bottom: 8),
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: const Color(0xFFE7F6EE),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.star, color: Color(0xFFFFC107)),
                    const SizedBox(width: 8),
                    Text(
                      'You rated ${review['rating']}/5',
                      style: const TextStyle(fontWeight: FontWeight.w600),
                    ),
                  ],
                ),
                if (reviewComment.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: 6),
                    child: Text(
                      reviewComment,
                      style: const TextStyle(color: Color(0xFF5C7470)),
                    ),
                  ),
              ],
            ),
          ),
        const Divider(height: 28),
      ],
    );
  }

  Widget _sectionCard({required String title, required Widget child}) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(Dimensions.radiusMd),
        boxShadow: Dimensions.boxShadowSmall(Colors.black),
      ),
      padding: const EdgeInsets.all(Dimensions.s16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 12),
          child,
        ],
      ),
    );
  }
}
