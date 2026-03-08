import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../core/services/supabase_service.dart';
import '../../../../core/theme/colors.dart';
import '../../../../shared/widgets/full_screen_image_viewer.dart';
import '../widgets/request_status_dialog.dart';

class FoodDetailScreen extends StatefulWidget {
  const FoodDetailScreen({super.key});

  @override
  State<FoodDetailScreen> createState() => _FoodDetailScreenState();
}

class _FoodDetailScreenState extends State<FoodDetailScreen> {
  bool _requesting = false;
  int _selectedQuantity = 1;
  bool _isFavorited = false;
  bool _favoriteLoading = false;

  Map<String, dynamic>? get _item =>
      ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;

  int get _availablePortions => (_item?['portions_available'] as num?)?.toInt() ?? 0;
  int get _maxOrderQuantity => _availablePortions.clamp(0, 2); // Max 2 per order
  bool get _isSoldOut => _availablePortions <= 0;
  bool get _isLowStock => _availablePortions > 0 && _availablePortions <= 3;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _checkFavoriteStatus();
  }

  Future<void> _checkFavoriteStatus() async {
    final item = _item;
    if (item == null) return;
    final listingId = item['id']?.toString();
    if (listingId == null) return;

    final isFav = await SupabaseService.instance.isFavorite(listingId);
    if (mounted) {
      setState(() => _isFavorited = isFav);
    }
  }

  Future<void> _toggleFavorite() async {
    final item = _item;
    if (item == null) return;
    final listingId = item['id']?.toString();
    if (listingId == null) return;

    setState(() => _favoriteLoading = true);
    final result = await SupabaseService.instance.toggleFavorite(listingId);
    if (mounted) {
      setState(() {
        _isFavorited = result;
        _favoriteLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(result ? 'Added to favorites!' : 'Removed from favorites'),
          duration: const Duration(seconds: 1),
        ),
      );
    }
  }

  Future<void> _openDirections() async {
    final item = _item;
    if (item == null) return;
    
    final lat = item['lat'] as double?;
    final lng = item['lng'] as double?;
    
    if (lat == null || lng == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Location not available')),
      );
      return;
    }
    
    final title = item['title'] ?? 'Food Pickup';
    final uri = Uri.parse('https://www.google.com/maps/dir/?api=1&destination=$lat,$lng&destination_place_id=$title');
    
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Could not open maps')),
        );
      }
    }
  }

  Future<void> _requestListing() async {
    final item = _item;
    if (item == null) return;
    
    // Prevent double taps
    if (_requesting) return;

    // Check availability
    if (_isSoldOut) {
      _showErrorDialog('This item is sold out.');
      return;
    }

    if (_selectedQuantity > _maxOrderQuantity) {
      _showErrorDialog('Only $_maxOrderQuantity portions available.');
      return;
    }

    final listingId = item['id']?.toString();
    if (listingId == null || listingId.isEmpty) {
      _showErrorDialog('Invalid listing information.');
      return;
    }

    final currentUser = SupabaseService.instance.currentUser;
    if (currentUser != null && item['owner_id'] == currentUser.id) {
       _showErrorDialog('You cannot request your own listing!');
      return;
    }

    // 1. Show Loading State (Premium Dialog)
    setState(() => _requesting = true);
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => const RequestStatusDialog(state: RequestState.loading),
    );

    // 2. Perform Request (Service Layer)
    final weightPerPortion = (item['weight_grams'] as num?)?.toInt() ?? 0;
    final quantity = _selectedQuantity;
    final totalSaved = weightPerPortion * quantity;
    final pricePerUnit = (item['price'] as num?)?.toInt() ?? 0;
    final totalPrice = pricePerUnit * quantity;

    final result = await SupabaseService.instance.createOrderSafe(
      listingId: listingId,
      quantity: quantity,
      savedFoodGrams: totalSaved,
      totalPrice: totalPrice,
    );

    // 3. Handle Result
    if (!mounted) return;
    Navigator.pop(context); // Pop Loading Dialog

    if (result.success) {
      // Success State
      await showDialog(
        context: context,
        barrierDismissible: false,
        builder: (ctx) => RequestStatusDialog(
          state: RequestState.success,
          onViewOrder: () {
             Navigator.pop(ctx); // Pop Success Dialog
             Navigator.pop(context); // Pop Details Screen
             // Navigate to Orders Tab (We need to trigger a tab switch in Home)
             // For now, we pop to home which usually defaults to first tab or stays.
             // Ideally we pass a result back to Home to switch tabs.
             ScaffoldMessenger.of(context).showSnackBar(
               const SnackBar(content: Text('Order placed! Check "Orders" tab.')),
             );
          },
        ),
      );
    } else {
      // Failure State
      await showDialog(
        context: context,
        builder: (ctx) => RequestStatusDialog(
          state: RequestState.error,
          errorMessage: result.errorMessage,
          onRetry: () {
            Navigator.pop(ctx);
            _requestListing(); // Recursive retry call
          },
        ),
      );
    }

    if (mounted) setState(() => _requesting = false);
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (ctx) => RequestStatusDialog(
        state: RequestState.error,
        errorMessage: message,
        onRetry: () => Navigator.pop(ctx),
      ),
    );
  }


  @override
  Widget build(BuildContext context) {
    final item = _item;
    return Scaffold(
      appBar: AppBar(
        title: Text(item?['title'] ?? 'Food detail'),
        actions: [
          IconButton(
            onPressed: _favoriteLoading ? null : _toggleFavorite,
            icon: _favoriteLoading
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                  )
                : Icon(
                    _isFavorited ? Icons.favorite : Icons.favorite_border,
                    color: _isFavorited ? Colors.red : null,
                  ),
            tooltip: _isFavorited ? 'Remove from favorites' : 'Add to favorites',
          ),
        ],
      ),
      body: SafeArea(
        child: item == null
            ? const Center(child: Text('Missing item data'))
            : ListView(
                children: [
                  SizedBox(
                    height: 250,
                    child: (item['images'] != null && (item['images'] as List).isNotEmpty)
                        ? PageView.builder(
                            itemCount: (item['images'] as List).length,
                            itemBuilder: (context, index) {
                              final urls = (item['images'] as List).map((e) => e.toString()).toList();
                              return GestureDetector(
                                onTap: () => Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => FullScreenImageViewer(
                                      imageUrls: urls,
                                      initialIndex: index,
                                    ),
                                  ),
                                ),
                                child: Image.network(
                                  urls[index],
                                  fit: BoxFit.cover,
                                  errorBuilder: (c, e, s) => Container(
                                    color: Colors.grey[300],
                                    child: const Center(
                                        child: Icon(Icons.image_not_supported)),
                                  ),
                                ),
                              );
                            },
                          )
                        : GestureDetector(
                            onTap: () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => FullScreenImageViewer(
                                  imageUrls: [item['image'] ?? ''],
                                ),
                              ),
                            ),
                            child: Image.network(
                              item['image'] ?? '',
                              fit: BoxFit.cover,
                              errorBuilder: (c, e, s) => Container(
                                color: Colors.grey[300],
                                child: const Center(
                                    child: Icon(Icons.image_not_supported)),
                              ),
                            ),
                          ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: Text(
                                item['title'] ?? '',
                                style: Theme.of(context).textTheme.headlineSmall,
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 12, vertical: 6),
                              decoration: BoxDecoration(
                                color: (item['price'] == 'free' ||
                                        item['price'] == 0)
                                    ? const Color(0xFF4CAF50)
                                    : const Color(0xFF006D3B),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                (item['price'] == 'free' || item['price'] == 0)
                                    ? 'FREE'
                                    : '₹${item['price']}',
                                style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold),
                              ),
                            )
                          ],
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            const Icon(Icons.location_on,
                                size: 16, color: Colors.grey),
                            const SizedBox(width: 4),
                            Text('${item['cuisine']} • ${item['distance']}'),
                            const Spacer(),
                            const Icon(Icons.star,
                                size: 16, color: Color(0xFFFFC107)),
                            const SizedBox(width: 4),
                            Text('${item['rating']}'),
                          ],
                        ),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            CircleAvatar(
                              backgroundImage:
                                  (item['hostAvatar'] ?? '').isNotEmpty
                                      ? NetworkImage(item['hostAvatar'])
                                      : null,
                              child: (item['hostAvatar'] ?? '').isEmpty
                                  ? Text((item['hostName'] ?? 'U')[0])
                                  : null,
                            ),
                            const SizedBox(width: 8),
                            Text('Hosted by ${item['hostName'] ?? 'Unknown'}'),
                          ],
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Description',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          item['description'] ?? 'Delicious home-cooked meal made with love. Pickup only. Please bring your own container if possible.',
                        ),
                        const SizedBox(height: 24),
                        
                        // Availability Section
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: _isSoldOut 
                                ? Colors.red.withOpacity(0.1)
                                : _isLowStock 
                                    ? Colors.orange.withOpacity(0.1)
                                    : cravnPrimary.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: _isSoldOut 
                                  ? Colors.red.withOpacity(0.3)
                                  : _isLowStock 
                                      ? Colors.orange.withOpacity(0.3)
                                      : cravnPrimary.withOpacity(0.3),
                            ),
                          ),
                          child: Column(
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Row(
                                    children: [
                                      Icon(
                                        _isSoldOut 
                                            ? Icons.remove_shopping_cart
                                            : Icons.inventory_2_outlined,
                                        color: _isSoldOut 
                                            ? Colors.red 
                                            : _isLowStock 
                                                ? Colors.orange 
                                                : cravnPrimary,
                                        size: 20,
                                      ),
                                      const SizedBox(width: 8),
                                      Text(
                                        _isSoldOut 
                                            ? 'Sold Out'
                                            : _isLowStock 
                                                ? 'Only $_availablePortions left!'
                                                : '$_availablePortions portions available',
                                        style: TextStyle(
                                          fontWeight: FontWeight.w600,
                                          color: _isSoldOut 
                                              ? Colors.red 
                                              : _isLowStock 
                                                  ? Colors.orange[800] 
                                                  : cravnPrimary,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                              if (!_isSoldOut) ...[
                                const SizedBox(height: 16),
                                // Quantity Stepper
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    const Text('Quantity:', style: TextStyle(fontWeight: FontWeight.w500)),
                                    Row(
                                      children: [
                                        IconButton(
                                          onPressed: _selectedQuantity > 1 
                                              ? () => setState(() => _selectedQuantity--)
                                              : null,
                                          icon: const Icon(Icons.remove_circle_outline),
                                          color: cravnPrimary,
                                        ),
                                        Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                          decoration: BoxDecoration(
                                            color: Colors.white,
                                            borderRadius: BorderRadius.circular(8),
                                            border: Border.all(color: Colors.grey[300]!),
                                          ),
                                          child: Text(
                                            '$_selectedQuantity',
                                            style: const TextStyle(
                                              fontSize: 18,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ),
                                        IconButton(
                                          onPressed: _selectedQuantity < _maxOrderQuantity 
                                              ? () => setState(() => _selectedQuantity++)
                                              : null,
                                          icon: const Icon(Icons.add_circle_outline),
                                          color: cravnPrimary,
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  'Max 2 portions per order',
                                  style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                                ),
                              ],
                            ],
                          ),
                        ),
                        const SizedBox(height: 24),
                        
                        // Request Button with Total Price
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: _isSoldOut || _requesting ? null : _requestListing,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: _isSoldOut ? Colors.grey : cravnPrimary,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: _requesting
                                ? const SizedBox(
                                    height: 20,
                                    width: 20,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      valueColor: AlwaysStoppedAnimation(Colors.white),
                                    ),
                                  )
                                : _isSoldOut 
                                    ? const Text('Sold Out', style: TextStyle(fontSize: 16))
                                    : Text(
                                        'Request ${_selectedQuantity}x - ${(item['price'] == 0) ? "FREE" : "₹${((item['price'] as num?) ?? 0) * _selectedQuantity}"}',
                                        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                                      ),
                          ),
                        ),
                        const SizedBox(height: 12),
                        // Get Directions Button
                        SizedBox(
                          width: double.infinity,
                          child: OutlinedButton.icon(
                            onPressed: _openDirections,
                            icon: const Icon(Icons.directions, color: cravnPrimary),
                            label: const Text('Get Directions'),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: cravnPrimary,
                              side: const BorderSide(color: cravnPrimary, width: 2),
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}
