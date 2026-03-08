import 'package:flutter/material.dart';
import '../../../../core/services/supabase_admin_service.dart';
import '../../../../core/theme/colors.dart';
import '../../../../core/theme/dimensions.dart';
import '../../../../shared/widgets/full_screen_image_viewer.dart';

class ListingDetailScreen extends StatefulWidget {
  final Map<String, dynamic> listing;
  final VoidCallback onUpdate;

  const ListingDetailScreen({
    super.key,
    required this.listing,
    required this.onUpdate,
  });

  @override
  State<ListingDetailScreen> createState() => _ListingDetailScreenState();
}

class _ListingDetailScreenState extends State<ListingDetailScreen> {
  late String _status;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _status = widget.listing['status'] ?? 'pending';
  }

  Future<void> _updateStatus(String status) async {
    setState(() => _isLoading = true);
    final success = await SupabaseAdminService.instance
        .updateListingStatus(widget.listing['id'], status);
    
    if (mounted) {
      setState(() => _isLoading = false);
      if (success) {
        setState(() => _status = status);
        widget.onUpdate();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Listing marked as $status')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to update status')),
        );
      }
    }
  }

  /// Show confirmation dialog and delete listing if confirmed
  Future<void> _confirmDelete(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(Dimensions.radiusMd)),
        title: const Row(
          children: [
            Icon(Icons.warning_amber_rounded, color: cravnError),
            SizedBox(width: 8),
            Text('Delete Listing'),
          ],
        ),
        content: Text(
          'Are you sure you want to permanently delete "${widget.listing['title']}"?\n\nThis action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: cravnError,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(Dimensions.radiusMd)),
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      setState(() => _isLoading = true);
      final success = await SupabaseAdminService.instance.deleteListing(widget.listing['id']);
      
      if (mounted) {
        setState(() => _isLoading = false);
        if (success) {
          widget.onUpdate();
          Navigator.pop(context); // Return to listings
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Listing deleted successfully')),
          );
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
    final l = widget.listing;
    final hostName = l['profiles']?['full_name'] ?? 'Unknown Host';
    final images = (l['images'] as List?)?.map((e) => e.toString()).toList() ??
        (l['image'] != null ? [l['image'].toString()] : []);
    final isVerified = _status == 'verified';

    return Scaffold(
      appBar: AppBar(
        title: const Text('Listing Details'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: cravnPrimary))
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Image Gallery
                  if (images.isNotEmpty)
                    SizedBox(
                      height: 300,
                      child: PageView.builder(
                        itemCount: images.length,
                        itemBuilder: (context, index) {
                          return GestureDetector(
                            onTap: () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => FullScreenImageViewer(
                                  imageUrls: images,
                                  initialIndex: index,
                                ),
                              ),
                            ),
                            child: Container(
                              margin: const EdgeInsets.symmetric(horizontal: 4),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(Dimensions.radiusMd),
                                color: Colors.grey[200],
                              ),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(Dimensions.radiusMd),
                                child: Image.network(
                                  images[index],
                                  fit: BoxFit.contain,
                                  errorBuilder: (_, __, ___) => const Center(
                                    child: Icon(Icons.broken_image, size: 50, color: Colors.grey),
                                  ),
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    )
                  else
                    Container(
                      height: 200,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: Colors.grey[200],
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Center(
                        child: Icon(Icons.fastfood, size: 64, color: Colors.grey),
                      ),
                    ),
                  
                  if (images.length > 1)
                    Padding(
                      padding: const EdgeInsets.only(top: 8),
                      child: Center(
                        child: Text(
                          '${images.length} Photos (Swipe to view)',
                          style: const TextStyle(color: Colors.grey),
                        ),
                      ),
                    ),

                  const SizedBox(height: 24),

                  // Header Info
                  Text(
                    l['title'] ?? 'Untitled',
                    style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: isVerified ? Colors.green.withOpacity(0.1) : Colors.orange.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: isVerified ? Colors.green : Colors.orange,
                          ),
                        ),
                        child: Text(
                          _status.toUpperCase(),
                          style: TextStyle(
                            color: isVerified ? Colors.green : Colors.orange,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Text(
                        l['price'] != null ? '₹${l['price']}' : 'Free',
                        style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w600, color: Colors.green),
                      ),
                    ],
                  ),

                  const Divider(height: 32),

                  // Host Info
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: const CircleAvatar(child: Icon(Icons.person)),
                    title: Text(hostName, style: const TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: const Text('Host / Kitchen'),
                  ),

                  const Divider(height: 32),

                  // Details
                  _buildDetailRow('Description', l['description'] ?? 'No description'),
                  _buildDetailRow('Portions', '${l['portions_available'] ?? 0} available'),
                  _buildDetailRow('Type', (l['isveg'] == true) ? 'Vegetarian' : 'Non-Vegetarian'),
                  _buildDetailRow('Pickup Time', '${l['pickup_start'] ?? ''} - ${l['pickup_end'] ?? ''}'),
                  _buildDetailRow('Address ID', l['address_id'] ?? 'Not specified'),

                  const SizedBox(height: 32),

                  // Actions
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: isVerified
                        ? ElevatedButton.icon(
                            onPressed: () => _updateStatus('pending'),
                            icon: const Icon(Icons.undo),
                            label: const Text('Revoke Verification'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.grey,
                            ),
                          )
                        : ElevatedButton.icon(
                            onPressed: () => _updateStatus('verified'),
                            icon: const Icon(Icons.check_circle),
                            label: const Text('Verify Listing', style: TextStyle(fontSize: 18)),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.green,
                              foregroundColor: Colors.white,
                            ),
                          ),
                  ),
                  const SizedBox(height: 16),
                  if (!isVerified)
                    SizedBox(
                      width: double.infinity,
                      child: TextButton.icon(
                        onPressed: () => _confirmDelete(context),
                        icon: const Icon(Icons.delete, color: cravnError),
                        label: const Text('Reject / Delete Listing', style: TextStyle(color: cravnError)),
                      ),
                    ),
                ],
              ),
            ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(color: Colors.grey[600], fontSize: 14),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(fontSize: 16),
          ),
        ],
      ),
    );
  }
}
