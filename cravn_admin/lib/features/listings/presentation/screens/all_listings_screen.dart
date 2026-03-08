import 'package:flutter/material.dart';
import '../../../../core/services/supabase_admin_service.dart';
import '../../../../core/theme/colors.dart';
import '../../../../core/theme/dimensions.dart';
import 'listing_detail_screen.dart';

class AllListingsScreen extends StatefulWidget {
  const AllListingsScreen({super.key});

  @override
  State<AllListingsScreen> createState() => _AllListingsScreenState();
}

class _AllListingsScreenState extends State<AllListingsScreen> {
  bool _isLoading = true;
  List<Map<String, dynamic>> _listings = [];

  @override
  void initState() {
    super.initState();
    _loadListings();
  }

  Future<void> _loadListings() async {
    setState(() => _isLoading = true);
    final data = await SupabaseAdminService.instance.getAllListings();
    if (mounted) {
      setState(() {
        _listings = data;
        _isLoading = false;
      });
    }
  }

  Future<void> _updateStatus(String id, String status) async {
    final success =
        await SupabaseAdminService.instance.updateListingStatus(id, status);
    if (success) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Listing marked as $status')));
        _loadListings();
      }
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Failed to update status')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator(color: cravnPrimary));
    }

    if (_listings.isEmpty) {
      return const Center(child: Text('No listings found'));
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _listings.length,
      itemBuilder: (context, index) {
        final listing = _listings[index];
        final status = listing['status'] ?? 'pending';
        final isVerified = status == 'verified';
        final title = listing['title'] ?? 'Untitled';
        final hostName = listing['profiles']?['full_name'] ?? 'Unknown Host';
        final price = listing['price'];


        final images = (listing['images'] as List?)?.map((e) => e.toString()).toList() ??
            (listing['image'] != null ? [listing['image'].toString()] : []);

        return GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => ListingDetailScreen(
                  listing: listing,
                  onUpdate: _loadListings,
                ),
              ),
            );
          },
          child: Container(
            margin: const EdgeInsets.only(bottom: 12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(Dimensions.radiusMd),
              boxShadow: Dimensions.boxShadowSmall(Colors.black),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ListTile(
                  title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 4),
                      Text('Hosted by: $hostName'),
                      Text('Price: ${price != null ? '₹$price' : 'Free'}'),
                      Container(
                        margin: const EdgeInsets.only(top: 4),
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: isVerified ? Colors.green.withOpacity(0.1) : Colors.orange.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: isVerified ? Colors.green : Colors.orange),
                        ),
                        child: Text(
                          status.toUpperCase(),
                          style: TextStyle(
                              color: isVerified ? Colors.green : Colors.orange,
                              fontWeight: FontWeight.bold,
                              fontSize: 11,
                          ),
                        ),
                      ),
                    ],
                  ),
                  trailing: Icon(Icons.arrow_forward_ios, size: 16, color: cravnTextSecondary),
                ),
                if (images.isNotEmpty)
                  SizedBox(
                    height: 100,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      itemCount: images.length,
                      itemBuilder: (context, imgIndex) {
                        return Padding(
                          padding: const EdgeInsets.only(right: 8),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: Image.network(images[imgIndex], width: 100, height: 100, fit: BoxFit.cover),
                          ),
                        );
                      },
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }
}
