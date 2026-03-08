import 'package:flutter/material.dart';
import '../../../../core/theme/colors.dart';
import '../../../../core/theme/dimensions.dart';
import '../../../shared/widgets/food_listing_card.dart';
import '../../../../core/widgets/logo.dart';
import '../../../../routes/app_routes.dart';
import 'map_view_screen.dart';
import 'orders_screen.dart';
import 'profile_screen.dart';
import '../../../../core/services/supabase_service.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// HomeScreen with full UI matching the React/Vite web app
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _index = 0;
  String _selectedCategory = 'All';
  final TextEditingController _searchController = TextEditingController();
  final GlobalKey<MapViewScreenState> _mapViewKey =
      GlobalKey<MapViewScreenState>();
  final List<Map<String, dynamic>> _defaultItems = [
    {
      'id': '1',
      'image':
          'https://images.unsplash.com/photo-1605719161691-5d9771fc144f?w=1080',
      'title': 'Homemade Biryani',
      'hostName': 'Priya',
      'hostAvatar':
          'https://images.unsplash.com/photo-1494790108377-be9c29b29330?w=100',
      'price': 80,
      'distance': '0.5 km',
      'cuisine': 'Indian',
      'isVeg': true,
      'rating': 4.8,
      'status': 'verified',
    },
    {
      'id': '2',
      'image':
          'https://images.unsplash.com/photo-1614442316719-1e38c661c29c?w=1080',
      'title': 'Fresh Margherita Pizza',
      'hostName': 'Raj',
      'hostAvatar':
          'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=100',
      'price': 'free',
      'distance': '1.2 km',
      'cuisine': 'Italian',
      'isVeg': true,
      'rating': 4.9,
      'status': 'verified',
    },
    {
      'id': '3',
      'image':
          'https://images.unsplash.com/photo-1644704001249-0d9dbb842238?w=1080',
      'title': 'Creamy Pasta Bowl',
      'hostName': 'Sarah',
      'hostAvatar':
          'https://images.unsplash.com/photo-1438761681033-6461ffad8d80?w=100',
      'price': 60,
      'distance': '2.1 km',
      'cuisine': 'Italian',
      'isVeg': true,
      'rating': 4.7,
      'status': 'verified',
    },
    {
      'id': '4',
      'image':
          'https://images.unsplash.com/photo-1705933774160-24298027a349?w=1080',
      'title': 'Chocolate Cake',
      'hostName': 'Amit',
      'hostAvatar':
          'https://images.unsplash.com/photo-1500648767791-00dcc994a43e?w=100',
      'price': 'free',
      'distance': '0.8 km',
      'cuisine': 'Dessert',
      'isVeg': true,
      'rating': 5.0,
      'status': 'verified',
    },
    {
      'id': '5',
      'image':
          'https://images.unsplash.com/photo-1546069901-ba9599a7e63c?w=1080',
      'title': 'Fresh Garden Salad',
      'hostName': 'Maya',
      'hostAvatar':
          'https://images.unsplash.com/photo-1534528741775-53994a69daeb?w=100',
      'price': 40,
      'distance': '1.5 km',
      'cuisine': 'Healthy',
      'isVeg': true,
      'rating': 4.6,
      'status': 'verified',
    },
    {
      'id': '6',
      'image':
          'https://images.unsplash.com/photo-1694076544200-08114d9f2ef6?w=1080',
      'title': 'Organic Veggie Bowl',
      'hostName': 'Kiran',
      'hostAvatar':
          'https://images.unsplash.com/photo-1544005313-94ddf0286df2?w=100',
      'price': 70,
      'distance': '3.0 km',
      'cuisine': 'Healthy',
      'isVeg': true,
      'rating': 4.8,
      'status': 'verified',
    }
  ];
  late List<Map<String, dynamic>> _allItems = List.of(_defaultItems);
  late List<Map<String, dynamic>> _visibleItems = List.of(_allItems);

  RealtimeChannel? _subscription;

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_applyFilters);
    _loadFromSupabase();
    _subscribeToRealtime();
  }
  
  void _subscribeToRealtime() {
    final client = SupabaseService.instance.client;
    _subscription = client.channel('public:food_listings')
      .onPostgresChanges(
        event: PostgresChangeEvent.all,
        schema: 'public',
        table: 'food_listings',
        callback: (payload) {
          debugPrint('[HomeScreen] Realtime update: ${payload.eventType}');
          _loadFromSupabase();
        }
      )
      .subscribe();
  }

  @override
  void dispose() {
    if (_subscription != null) SupabaseService.instance.client.removeChannel(_subscription!);
    _searchController.dispose();
    super.dispose();
  }

  void _onNavTap(int index) {
    setState(() {
      _index = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final pages = [
      _buildListings(context),
      MapViewScreen(key: _mapViewKey),
      const OrdersScreen(),
      const ProfileScreen(),
    ];
    return Scaffold(
      appBar: AppBar(
        title: const CravnLogo(size: 48),
        elevation: 0,
        backgroundColor: cravnBackground,
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_outlined, color: Colors.white),
            onPressed: () => debugPrint('Notifications clicked'),
          ),
        ],
      ),
      body: IndexedStack(index: _index, children: pages),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _index,
        onTap: _onNavTap,
        type: BottomNavigationBarType.fixed,
        backgroundColor: cravnBackground,
        selectedItemColor: Colors.white,
        unselectedItemColor: Colors.white70,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.map), label: 'Map'),
          BottomNavigationBarItem(
              icon: Icon(Icons.shopping_bag), label: 'Orders'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
        ],
      ),
    );
  }

  Widget _buildListings(BuildContext context) {
    return Column(
      children: [
        // Search Bar
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          color: cravnBackground,
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _searchController,
                  style: const TextStyle(color: Colors.black87),
                  decoration: InputDecoration(
                    hintText: 'Search for food...',
                    hintStyle: TextStyle(color: Colors.grey[500]),
                    prefixIcon:
                        Icon(Icons.search, color: Colors.grey[600]),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(Dimensions.radiusMd),
                      borderSide: BorderSide.none,
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(Dimensions.radiusMd),
                      borderSide: BorderSide.none,
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(Dimensions.radiusMd),
                      borderSide:
                          const BorderSide(color: Colors.white, width: 2),
                    ),
                    filled: true,
                    fillColor: Colors.white,
                    contentPadding: const EdgeInsets.symmetric(vertical: 0, horizontal: 16),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(Dimensions.radiusMd),
                ),
                child: IconButton(
                  icon: const Icon(Icons.tune, color: cravnPrimary),
                  onPressed: () => debugPrint('Filters clicked'),
                ),
              ),
            ],
          ),
        ),
        // Category Chips
        Container(
          padding: const EdgeInsets.symmetric(vertical: 8),
          color: cravnBackground,
          child: SizedBox(
            height: 40,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              children: [
                'All',
                'Free',
                'Indian',
                'Italian',
                'Dessert',
                'Healthy'
              ]
                  .map((category) => Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: FilterChip(
                          label: Text(category),
                          selected: _selectedCategory == category,
                          onSelected: (selected) {
                            setState(() {
                              _selectedCategory = selected ? category : 'All';
                            });
                            _applyFilters();
                          },
                          backgroundColor: Colors.white,
                          selectedColor: Colors.white,
                          labelStyle: TextStyle(
                            color: _selectedCategory == category
                                ? cravnPrimary
                                : Colors.grey[700],
                            fontWeight: FontWeight.w600,
                          ),
                          side: BorderSide(
                            color: _selectedCategory == category
                                ? Colors.white
                                : Colors.white70,
                          ),
                        ),
                      ))
                  .toList(),
            ),
          ),
        ),
        // Food Grid
        Expanded(
          child: Container(
            color: cravnBackground,
            child: RefreshIndicator(
              color: cravnPrimary,
              onRefresh: _loadFromSupabase,
              child: ListView.builder(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(16),
                itemCount: _visibleItems.length,
                itemBuilder: (context, index) {
                  final item = _visibleItems[index];
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: FoodListingCard(
                      title: item['title'],
                      subtitle:
                          '${item['cuisine'] ?? 'Cuisine'} • ${item['distance'] ?? 'Nearby'}',
                      imageUrl: item['image'],
                      price: item['price'],
                      hostName: item['hostName'],
                      hostAvatar: item['hostAvatar'],
                      isVeg: item['isVeg'],
                      rating: (item['rating'] is num)
                          ? (item['rating'] as num).toDouble()
                          : 5.0,
                      reviewCount: (item['reviewCount'] is num)
                          ? (item['reviewCount'] as num).toInt()
                          : null,
                      onTap: () => Navigator.of(context).pushNamed(
                        AppRoutes.foodDetail,
                        arguments: item,
                      ),
                      status: item['status']?.toString(),
                    ),
                  );
                },
              ),
            ),
          ),
        ),
      ],
    );
  }

  void _applyFilters() {
    final q = _searchController.text.trim().toLowerCase();
    setState(() {
      _visibleItems = _allItems.where((item) {
        final matchesSearch = q.isEmpty ||
            (item['title']?.toString().toLowerCase().contains(q) ?? false) ||
            (item['cuisine']?.toString().toLowerCase().contains(q) ?? false) ||
            (item['hostName']?.toString().toLowerCase().contains(q) ?? false);
        final cat = _selectedCategory;
        final matchesCat = cat == 'All'
            ? true
            : cat == 'Free'
                ? (item['price'] == 'free' || item['price'] == 0)
                : (item['cuisine']?.toString().toLowerCase() ==
                    cat.toLowerCase());
        return matchesSearch && matchesCat;
      }).toList();
    });
  }

  Future<void> _loadFromSupabase() async {
    try {
      final rows = await SupabaseService.instance.getFoodListings();
      if (rows.isNotEmpty) {
        final ids =
            rows.map((r) => r['id']).whereType<String>().toSet().toList();
        final stats = await SupabaseService.instance
            .getListingReviewStats(listingIds: ids);
        final statsMap = <String, Map<String, dynamic>>{};
        for (final stat in stats) {
          final key = stat['listing_id']?.toString();
          if (key != null && key.isNotEmpty) {
            statsMap[key] = stat;
          }
        }
        setState(() {
          // Normalize expected keys if table schema differs
          _allItems = rows.map((r) {
            final normalized = _normalizeListing(r);
            final stat = statsMap[normalized['id']?.toString() ?? ''];
            if (stat != null) {
              normalized['rating'] =
                  (stat['average_rating'] as num?)?.toDouble() ?? 5.0;
              normalized['reviewCount'] =
                  (stat['review_count'] as num?)?.toInt() ?? 0;
            }
            return normalized;
          }).toList();
          _applyFilters();
        });
      } else {
        // Keep defaults
        _applyFilters();
      }
    } catch (e) {
      debugPrint('Supabase fetch error: $e');
      _applyFilters();
    }
  }

  Map<String, dynamic> _normalizeListing(Map<String, dynamic> raw) {
    return {
      'id': raw['id'],
      'title': raw['title'] ?? raw['name'] ?? 'Untitled',
      'cuisine': raw['cuisine'] ?? 'Unknown',
      'image': raw['image'] ?? '',
      'images': raw['images'],
      'price': raw['price'] ?? 'free',
      'hostName': raw['profiles']?['full_name'] ?? raw['host_name'] ?? 'Cravn Host',
      'hostAvatar': raw['profiles']?['avatar_url'] ?? raw['hostAvatar'] ?? '',
      'distance': raw['distance'] ?? 'Nearby',
      'isVeg': raw['isVeg'] ?? true,
      'rating':
          (raw['rating'] is num) ? (raw['rating'] as num).toDouble() : 5.0,
      'reviewCount': (raw['reviewCount'] is num)
          ? (raw['reviewCount'] as num).toInt()
          : (raw['review_count'] is num)
              ? (raw['review_count'] as num).toInt()
              : 0,
      'status': raw['status'] ?? 'pending',
      'lat': raw['lat'],
      'lng': raw['lng'],
      'owner_id': raw['owner_id'],
      'description': raw['description'],
      'pickup_start': raw['pickup_start'],
      'pickup_end': raw['pickup_end'],
      'pickup_end': raw['pickup_end'],
      'portions_available': raw['portions_available'],
      'weight_grams': raw['weight_grams'],
    };
  }
}
