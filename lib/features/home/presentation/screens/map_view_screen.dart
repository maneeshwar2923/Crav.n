import 'dart:async';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../core/services/supabase_service.dart';
import '../../../../core/services/marker_generator.dart';
import '../../../../core/theme/colors.dart';

class MapViewScreen extends StatefulWidget {
  const MapViewScreen({super.key});

  @override
  MapViewScreenState createState() => MapViewScreenState();
}

class MapViewScreenState extends State<MapViewScreen> {
  GoogleMapController? _mapController;
  final PageController _pageController = PageController(viewportFraction: 0.85);

  LatLng _initialPosition = const LatLng(19.075983, 72.877655); // Default Mumbai
  bool _isLoading = true;
  bool _mapReady = false;
  String? _mapStyle;
  
  // Markers & Data
  final Map<String, Marker> _markerIndex = {};
  List<Map<String, dynamic>> _listings = [];
  List<Map<String, dynamic>> _allListings = []; // Unfiltered listings
  int _selectedIndex = -1;
  bool _isProgrammaticScroll = false;
  double _currentZoom = 13.0; // Track current zoom level
  static const double _markerVisibilityThreshold = 12.0;
  
  // Filter state
  bool _vegOnly = false;
  bool _freeMeals = false;
  bool _within5km = false;
  
  RealtimeChannel? _realtimeChannel;

  @override
  void initState() {
    super.initState();
    _loadMapStyle();
    _getCurrentLocation();
    _loadListings();
    _subscribeToRealtime();
  }

  @override
  void dispose() {
    _mapController?.dispose();
    _pageController.dispose();
    if (_realtimeChannel != null) {
      SupabaseService.instance.client.removeChannel(_realtimeChannel!);
    }
    super.dispose();
  }

  Future<void> _loadMapStyle() async {
    try {
      _mapStyle = await rootBundle.loadString('assets/map_style.json');
      _applyMapStyle();
    } catch (e) {
      debugPrint('Error loading map style: $e');
    }
  }

  void _applyMapStyle() {
    if (_mapReady && _mapStyle != null && _mapController != null) {
      _mapController!.setMapStyle(_mapStyle);
    }
  }

  Future<void> _getCurrentLocation() async {
    try {
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }
      if (permission == LocationPermission.whileInUse ||
          permission == LocationPermission.always) {
        final position = await Geolocator.getCurrentPosition();
        if (mounted) {
          setState(() {
            _initialPosition = LatLng(position.latitude, position.longitude);
            _isLoading = false;
          });
          _animateCamera(_initialPosition);
        }
      } else {
        if (mounted) setState(() => _isLoading = false);
      }
    } catch (e) {
      debugPrint('Location Error: $e');
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _animateCamera(LatLng target) {
    _mapController?.animateCamera(
      CameraUpdate.newCameraPosition(
        CameraPosition(target: target, zoom: 15, tilt: 0),
      ),
    );
  }

  Future<void> _loadListings() async {
    try {
      final data = await SupabaseService.instance.client
          .from('food_listings')
          .select('*, profiles(full_name)');
      final listings = List<Map<String, dynamic>>.from(data);
      if (mounted) {
        setState(() {
          _allListings = listings;
        });
        _applyFilters();
      }
    } catch (e) {
      debugPrint('Error loading listings: $e');
    }
  }

  void _applyFilters() {
    List<Map<String, dynamic>> filtered = List.from(_allListings);
    
    if (_vegOnly) {
      filtered = filtered.where((l) => l['is_veg'] == true).toList();
    }
    
    if (_freeMeals) {
      filtered = filtered.where((l) {
        final price = l['price'];
        return price == null || price == 0 || price == 'free';
      }).toList();
    }
    
    if (_within5km) {
      // Filter by distance from current position (5km = 5000m)
      filtered = filtered.where((l) {
        final lat = l['lat'] as double?;
        final lng = l['lng'] as double?;
        if (lat == null || lng == null) return false;
        final distance = Geolocator.distanceBetween(
          _initialPosition.latitude,
          _initialPosition.longitude,
          lat,
          lng,
        );
        return distance <= 5000;
      }).toList();
    }
    
    _generateMarkers(filtered);
    if (mounted) {
      setState(() {
        _listings = filtered;
        _selectedIndex = -1;
      });
    }
  }


  Future<void> _generateMarkers(List<Map<String, dynamic>> listings) async {
    final Map<String, Marker> newMarkers = {};
    for (var listing in listings) {
      final marker = await _buildMarker(listing);
      if (marker != null) {
        newMarkers[marker.markerId.value] = marker;
      }
    }
    if (mounted) {
      setState(() {
        _markerIndex.clear();
        _markerIndex.addAll(newMarkers);
      });
    }
  }

  Future<Marker?> _buildMarker(Map<String, dynamic> listing) async {
    final lat = (listing['lat'] as num?)?.toDouble();
    final lng = (listing['lng'] as num?)?.toDouble();
    final price = listing['price'];
    final priceLabel = (price == 0 || price == null) ? 'Free' : '₹$price';
    
    if (lat == null || lng == null) return null;

    final icon = await MarkerGenerator.createCustomMarkerBitmap(
      listing['image'],
      priceLabel, // Pass price for badge
    );

    return Marker(
      markerId: MarkerId('listing_${listing['id']}'),
      position: LatLng(lat, lng),
      icon: icon,
      onTap: () => _onMarkerTapped(listing),
    );
  }

  void _onMarkerTapped(Map<String, dynamic> listing) {
    final index = _listings.indexWhere((l) => l['id'] == listing['id']);
    if (index != -1) {
      setState(() => _selectedIndex = index);
      _isProgrammaticScroll = true;
      _pageController.animateToPage(
        index, 
        duration: const Duration(milliseconds: 400), 
        curve: Curves.easeOutCubic
      ).then((_) => _isProgrammaticScroll = false);
      
      _focusOnListing(listing);
    }
  }

  void _onPageChanged(int index) {
    if (_isProgrammaticScroll) return;
    setState(() => _selectedIndex = index);
    _focusOnListing(_listings[index]);
  }

  void _focusOnListing(Map<String, dynamic> listing) {
    final lat = (listing['lat'] as num).toDouble();
    final lng = (listing['lng'] as num).toDouble();
    // Offset slightly for card visibility
    _mapController?.animateCamera(
      CameraUpdate.newCameraPosition(
        CameraPosition(
            target: LatLng(lat - 0.005, lng),
            zoom: 16,
            tilt: 30),
      ),
    );
  }

  void _subscribeToRealtime() {
    _realtimeChannel = SupabaseService.instance.client.channel('public:food_listings')
      ..onPostgresChanges(
        event: PostgresChangeEvent.all,
        schema: 'public',
        table: 'food_listings',
        callback: (payload) => _loadListings(),
      )
      ..subscribe();
  }

  /// Called when camera moves - track zoom level for marker visibility
  void _onCameraMove(CameraPosition position) {
    final newZoom = position.zoom;
    // Only rebuild if crossing threshold
    if ((_currentZoom < _markerVisibilityThreshold && newZoom >= _markerVisibilityThreshold) ||
        (_currentZoom >= _markerVisibilityThreshold && newZoom < _markerVisibilityThreshold)) {
      setState(() => _currentZoom = newZoom);
    } else {
      _currentZoom = newZoom;
    }
  }

  /// Returns markers filtered by current zoom level (Airbnb-style)
  Set<Marker> _getVisibleMarkers() {
    if (_currentZoom < _markerVisibilityThreshold) {
      return {}; // Hide all markers when zoomed out
    }
    return _markerIndex.values.toSet();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // 1. Full Screen Map
          GoogleMap(
            initialCameraPosition: CameraPosition(
              target: _initialPosition,
              zoom: 13,
            ),
            onMapCreated: (controller) {
              _mapController = controller;
              _mapReady = true;
              _applyMapStyle();
            },
            markers: _getVisibleMarkers(),
            myLocationEnabled: true,
            myLocationButtonEnabled: false,
            zoomControlsEnabled: false,
            mapToolbarEnabled: false,
            onCameraMove: _onCameraMove,
            onTap: (_) => setState(() => _selectedIndex = -1),
          ),
          
          if (_isLoading)
            const Center(child: CircularProgressIndicator(color: cravnPrimary)),

          // 2. Head-Up Display (Search & Chips)
          Positioned(
            top: 50,
            left: 20,
            right: 20,
            child: Column(
              children: [
                _buildGlassSearchBar(),
                const SizedBox(height: 12),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      _buildFilterChip('Veg Only', Icons.eco, Colors.green, _vegOnly, () {
                        setState(() => _vegOnly = !_vegOnly);
                        _applyFilters();
                      }),
                      const SizedBox(width: 8),
                      _buildFilterChip('Free Meals', Icons.volunteer_activism, Colors.orange, _freeMeals, () {
                        setState(() => _freeMeals = !_freeMeals);
                        _applyFilters();
                      }),
                      const SizedBox(width: 8),
                      _buildFilterChip('Within 5km', Icons.near_me, Colors.blue, _within5km, () {
                        setState(() => _within5km = !_within5km);
                        _applyFilters();
                      }),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // 3. Right Side Controls
          Positioned(
            bottom: _selectedIndex != -1 ? 160 : 40,
            right: 20,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildMapButton(Icons.refresh, _loadListings),
                const SizedBox(height: 12),
                _buildMapButton(Icons.my_location, _getCurrentLocation),
              ],
            ),
          ),

          // 4. Listing Carousel
          AnimatedPositioned(
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
            bottom: _selectedIndex != -1 ? 30 : -200,
            left: 0,
            right: 0,
            height: 125,
            child: PageView.builder(
              controller: _pageController,
              itemCount: _listings.length,
              onPageChanged: _onPageChanged,
              itemBuilder: (context, index) {
                return _buildListingCard(_listings[index], index == _selectedIndex);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGlassSearchBar() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(30),
      child: BackdropFilter(
        filter: ui.ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          height: 50,
          padding: const EdgeInsets.symmetric(horizontal: 20),
          decoration: BoxDecoration(
            color: cravnPrimary.withOpacity(0.95),
            borderRadius: BorderRadius.circular(30),
            border: Border.all(color: Colors.white.withOpacity(0.3)),
            boxShadow: [
              BoxShadow(
                color: cravnPrimary.withOpacity(0.3),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            children: [
              const Icon(Icons.search, color: Colors.white),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Find cravings nearby...',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Colors.white.withOpacity(0.9),
                        fontFamily: 'SF Pro Display',
                      ),
                ),
              ),
              const Icon(Icons.tune, color: Colors.white),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFilterChip(String label, IconData icon, Color color, bool isActive, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: BackdropFilter(
          filter: ui.ImageFilter.blur(sigmaX: 8, sigmaY: 8),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: isActive ? Colors.white : cravnPrimary.withOpacity(0.9),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: isActive ? cravnPrimary : Colors.white.withOpacity(0.3)),
            ),
            child: Row(
              children: [
                Icon(icon, size: 16, color: isActive ? cravnPrimary : Colors.white),
                const SizedBox(width: 6),
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 13, 
                    fontWeight: FontWeight.w600,
                    fontFamily: 'SF Pro Display',
                    color: isActive ? cravnPrimary : Colors.white,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildGlassChip(String label, IconData icon, Color color) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: BackdropFilter(
        filter: ui.ImageFilter.blur(sigmaX: 8, sigmaY: 8),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.7),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.white.withValues(alpha: 0.4)),
          ),
          child: Row(
            children: [
              Icon(icon, size: 16, color: color),
              const SizedBox(width: 6),
              Text(
                label,
                style: const TextStyle(
                  fontSize: 13, 
                  fontWeight: FontWeight.w600,
                  fontFamily: 'SF Pro Display'
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMapButton(IconData icon, VoidCallback onTap) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.15),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: IconButton(
        icon: Icon(icon, color: cravnPrimary),
        onPressed: onTap,
      ),
    );
  }

  Widget _buildListingCard(Map<String, dynamic> listing, bool isSelected) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      margin: const EdgeInsets.symmetric(horizontal: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: isSelected ? Border.all(color: cravnPrimary, width: 2) : null,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.2),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: GestureDetector(
        onTap: () => _showRequestSheet(listing),
        child: Row(
          children: [
            Padding(
              padding: const EdgeInsets.all(10),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: Image.network(
                  listing['image'] ?? '',
                  width: 100,
                  height: 100,
                  fit: BoxFit.cover,
                  errorBuilder: (c, e, s) => Container(
                    width: 100,
                    height: 100,
                    color: Colors.grey[200],
                    child: const Icon(Icons.fastfood, color: Colors.grey),
                  ),
                ),
              ),
            ),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    listing['title'] ?? 'Listing',
                    style: const TextStyle(
                      fontFamily: 'SF Pro Display',
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    (listing['price'] == 0 || listing['price'] == null) ? 'Free' : '₹${listing['price']}',
                    style: const TextStyle(
                      fontFamily: 'SF Pro Display',
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      color: cravnPrimary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      _buildTag(listing['isVeg'] == true ? 'Veg' : 'Non-Veg', 
                        listing['isVeg'] == true ? Colors.green : Colors.red),
                      const SizedBox(width: 6),
                      if (listing['weight_grams'] != null && listing['weight_grams'] > 0)
                        _buildTag('${listing['weight_grams']}g', Colors.grey),
                    ],
                  )
                ],
              ),
            ),
             Padding(
               padding: const EdgeInsets.only(right: 16),
               child: CircleAvatar(
                 radius: 14,
                backgroundColor: cravnBackground,
                child: const Icon(Icons.arrow_forward_ios, size: 14, color: cravnPrimary),
               ),
             )
          ],
        ),
      ),
    );
  }
  
  Widget _buildTag(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(text, style: TextStyle(
          color: color, 
          fontSize: 10, 
          fontWeight: FontWeight.bold
      )),
    );
  }

  void _showRequestSheet(Map<String, dynamic> listing) {
      showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => Container(
        height: MediaQuery.of(context).size.height * 0.7,
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
        ),
        child: Column(
          children: [
             // Small handle
            Center(
              child: Container(
                margin: const EdgeInsets.symmetric(vertical: 12),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Large Image
                     ClipRRect(
                      borderRadius: BorderRadius.circular(24),
                      child: Image.network(
                        listing['image'] ?? '',
                        width: double.infinity,
                        height: 250,
                        fit: BoxFit.cover,
                      ),
                    ),
                    const SizedBox(height: 24),
                    Text(
                      listing['title'] ?? 'Listing',
                      style: const TextStyle(
                        fontFamily: 'SF Pro Display',
                        fontSize: 28,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 8),
                     Text(
                      listing['description'] ?? 'No description provided.',
                      style: const TextStyle(
                         fontSize: 16,
                         color: cravnTextSecondary,
                         height: 1.5,
                      ),
                    ),
                     const SizedBox(height: 32),
                     // Request Button
                     SizedBox(
                       width: double.infinity,
                       height: 56,
                       child: ElevatedButton(
                         style: ElevatedButton.styleFrom(
                           backgroundColor: cravnPrimary,
                           shape: RoundedRectangleBorder(
                             borderRadius: BorderRadius.circular(16)
                           )
                         ),
                         onPressed: () async {
                              final currentUser = SupabaseService.instance.currentUser;
                              if (currentUser == null) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text('Please sign in to request food')),
                                );
                                return;
                              }

                              if (listing['owner_id'] == currentUser.id) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text('You cannot request your own listing!')),
                                );
                                return;
                              }

                              Navigator.pop(context);
                              
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('Requesting meal...')),
                              );

                              try {
                                 final weightPerPortion = (listing['weight_grams'] as num?)?.toInt() ?? 0;
                                 final pricePerUnit = (listing['price'] as num?)?.toInt() ?? 0;
                                 await SupabaseService.instance.createOrder(
                                  listingId: listing['id'],
                                  quantity: 1,
                                  savedFoodGrams: weightPerPortion,
                                  totalPrice: pricePerUnit,
                                );
                                if (mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(content: Text('Request sent successfully!')),
                                  );
                                }
                              } catch(e) {
                                if (mounted) {
                                   ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(content: Text('Error: $e')),
                                  );
                                }
                              }
                         },
                         child: const Text('Request Meal', style: TextStyle(
                           fontSize: 18, 
                           fontWeight: FontWeight.bold,
                           color: Colors.white,
                         )),
                       ),
                     )
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
