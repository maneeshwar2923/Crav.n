import 'package:flutter/material.dart';
import '../../../../core/theme/dimensions.dart';
import '../../../../core/theme/colors.dart';
import '../../../../core/services/supabase_partner_service.dart';
import '../../../listings/partner_create_listing_screen.dart';

class InventoryScreen extends StatefulWidget {
  const InventoryScreen({super.key});

  @override
  State<InventoryScreen> createState() => _InventoryScreenState();
}

class _InventoryScreenState extends State<InventoryScreen> {
  bool _loading = true;
  List<Map<String, dynamic>> _listings = [];

  @override
  void initState() {
    super.initState();
    _loadListings();
  }

  Future<void> _loadListings() async {
    setState(() => _loading = true);
    try {
      final listings = await SupabasePartnerService.instance.getHostListings();
      if (mounted) {
        setState(() {
          _listings = listings;
          _loading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _loading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading listings: $e')),
        );
      }
    }
  }

  Future<void> _createListing() async {
    final result = await Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const PartnerCreateListingScreen()),
    );
    if (result == true) {
      _loadListings();
    }
  }

  Future<void> _editListing(Map<String, dynamic> listing) async {
    final result = await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => PartnerCreateListingScreen(listing: listing),
      ),
    );
    if (result == true) {
      _loadListings();
    }
  }

  Future<void> _deleteListing(String id) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Listing'),
        content: const Text('Are you sure you want to delete this listing?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      setState(() => _loading = true);
      final success = await SupabasePartnerService.instance.deleteFoodListing(id);
      if (mounted) {
        setState(() => _loading = false);
        if (success) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Listing deleted')),
          );
          _loadListings();
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Failed to delete listing')),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: cravnBackground,
      body: _loading
          ? const Center(child: CircularProgressIndicator(color: cravnPrimary))
          : _listings.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.storefront_outlined, size: 64, color: Colors.grey),
                      const SizedBox(height: 16),
                      Text(
                        'No listings yet',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(color: Colors.grey),
                      ),
                      const SizedBox(height: 24),
                      ElevatedButton.icon(
                        onPressed: _createListing,
                        icon: const Icon(Icons.add),
                        label: const Text('Create First Listing'),
                      ),
                    ],
                  ),
                )
              : RefreshIndicator(
                  onRefresh: _loadListings,
                  child: ListView.builder(
                    padding: const EdgeInsets.all(Dimensions.s16),
                    itemCount: _listings.length,
                    itemBuilder: (context, index) {
                      final listing = _listings[index];
                      return _InventoryItemCard(
                        listing: listing,
                        onEdit: () => _editListing(listing),
                        onDelete: () => _deleteListing(listing['id']),
                      );
                    },
                  ),
                ),
      floatingActionButton: FloatingActionButton(
        onPressed: _createListing,
        backgroundColor: cravnPrimary,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}

class _InventoryItemCard extends StatelessWidget {
  const _InventoryItemCard({
    required this.listing,
    required this.onEdit,
    required this.onDelete,
  });

  final Map<String, dynamic> listing;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final title = listing['title'] ?? 'Untitled Listing';
    final price = (listing['price'] as num?)?.toDouble() ?? 0.0;
    final portions = (listing['portions_available'] as num?)?.toInt() ?? 0;
    final status = listing['status']?.toString().toUpperCase() ?? 'UNKNOWN';
    final isVeg = listing['isVeg'] == true;
    final imageUrl = listing['image'] as String?;

    Color statusColor = Colors.grey;
    if (status == 'ACTIVE') statusColor = Colors.green;
    if (status == 'SOLD_OUT') statusColor = Colors.red;

    return Card(
      margin: const EdgeInsets.only(bottom: Dimensions.s12),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(Dimensions.radiusMd),
        side: const BorderSide(color: Color(0xFFE0E0E0)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(Dimensions.s16),
        child: Row(
          children: [
            // Image Placeholder
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                color: cravnPrimary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(Dimensions.radiusSm),
                image: imageUrl != null
                    ? DecorationImage(
                        image: NetworkImage(imageUrl),
                        fit: BoxFit.cover,
                      )
                    : null,
              ),
              child: imageUrl == null
                  ? const Icon(Icons.fastfood, color: cravnPrimary)
                  : null,
            ),
            const SizedBox(width: Dimensions.s16),
            
            // Details
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          title,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (isVeg)
                        const Padding(
                          padding: EdgeInsets.only(left: 4),
                          child: Icon(Icons.eco, size: 16, color: Colors.green),
                        ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${portions > 0 ? '$portions portions' : 'Sold Out'} • ₹${price.toStringAsFixed(0)}',
                    style: TextStyle(color: Colors.grey[600]),
                  ),
                  const SizedBox(height: 8),
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
            ),
            
            // Actions
            PopupMenuButton<String>(
              icon: const Icon(Icons.more_vert, color: Colors.grey),
              onSelected: (value) {
                if (value == 'edit') onEdit();
                if (value == 'delete') onDelete();
              },
              itemBuilder: (context) => [
                const PopupMenuItem(
                  value: 'edit',
                  child: Row(
                    children: [
                      Icon(Icons.edit_outlined, size: 20),
                      SizedBox(width: 8),
                      Text('Edit'),
                    ],
                  ),
                ),
                const PopupMenuItem(
                  value: 'delete',
                  child: Row(
                    children: [
                      Icon(Icons.delete_outline, size: 20, color: Colors.red),
                      SizedBox(width: 8),
                      Text('Delete', style: TextStyle(color: Colors.red)),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
