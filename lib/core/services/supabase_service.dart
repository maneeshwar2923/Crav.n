import 'dart:io';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:uuid/uuid.dart';
import 'package:flutter/foundation.dart';
import 'supabase_config.dart';

/// Supabase service singleton to manage database connections and queries
class SupabaseService {
  static SupabaseService? _instance;
  static SupabaseClient? _client;

  SupabaseService._();

  static SupabaseService get instance {
    _instance ??= SupabaseService._();
    return _instance!;
  }

  /// Initialize Supabase with your project credentials
  static Future<void> initialize() async {
    final url = SupabaseConfig.url;
    final key = SupabaseConfig.anonKey.substring(0, 12); // partial for log
    debugPrint(
        '[SupabaseService] Initializing (url=$url, anonKeyPrefix=$key...)');
    try {
      await Supabase.initialize(
        url: url,
        anonKey: SupabaseConfig.anonKey,
      );
      _client = Supabase.instance.client;
      debugPrint(
          '[SupabaseService] Initialization complete. Current user: ${_client!.auth.currentUser?.id ?? 'none'}');
    } catch (e) {
      debugPrint('[SupabaseService] Initialization FAILED: $e');
      rethrow;
    }
  }

  /// Get the Supabase client instance
  SupabaseClient get client {
    if (_client == null) {
      throw Exception(
          'Supabase not initialized. Call SupabaseService.initialize() first.');
    }
    return _client!;
  }

  /// Example: Fetch food listings from your Supabase table
  /// Replace 'food_listings' with your actual table name
  Future<List<Map<String, dynamic>>> getFoodListings() async {
    try {
      final response = await client
          .from('food_listings')
          .select('*, profiles(full_name)')
          .order('created_at', ascending: false);
      debugPrint('[SupabaseService] Fetched ${response.length} listings');
      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      debugPrint('[SupabaseService] Error fetching food listings: $e');
      return [];
    }
  }

  /// Example: Insert a new food listing
  Future<Map<String, dynamic>?> createFoodListing(
      Map<String, dynamic> listing) async {
    final user = currentUser;
    if (user == null) {
      throw AuthException('You need to be signed in to create a listing.');
    }
    try {
      listing['owner_id'] ??= user.id;
      final response = await client
          .from('food_listings')
          .insert(listing)
          .select()
          .maybeSingle();
      return response == null ? null : Map<String, dynamic>.from(response);
    } on PostgrestException catch (e) {
      debugPrint('Error creating food listing: ${e.message}');
      rethrow;
    } catch (e) {
      debugPrint('Error creating food listing: $e');
      rethrow;
    }
  }

  /// Update listing status/verification fields (admin-only route)
  Future<bool> updateListingStatus(
      {required String listingId,
      required String status,
      DateTime? verifiedAt}) async {
    try {
      await client.from('food_listings').update({
        'status': status,
        'verified_at': verifiedAt?.toIso8601String(),
        'verifier_id': currentUser?.id,
      }).eq('id', listingId);
      return true;
    } catch (e) {
      debugPrint('Error updating listing status: $e');
      return false;
    }
  }

  /// Saved addresses helpers -------------------------------------------------

  Future<List<Map<String, dynamic>>> getUserAddresses() async {
    if (currentUser == null) return [];
    try {
      final rows = await client
          .from('user_addresses')
          .select()
          .eq('user_id', currentUser!.id)
          .order('is_default', ascending: false)
          .order('created_at');
      return List<Map<String, dynamic>>.from(rows);
    } catch (e) {
      debugPrint('Error fetching user addresses: $e');
      return [];
    }
  }

  Future<Map<String, dynamic>?> upsertAddress(
      Map<String, dynamic> payload) async {
    if (currentUser == null) {
      throw const AuthException('User not logged in');
    }
    try {
      payload['user_id'] = currentUser!.id;
      final response = await client
          .from('user_addresses')
          .upsert(payload, onConflict: 'id')
          .select()
          .maybeSingle();
      return response == null ? null : Map<String, dynamic>.from(response);
    } catch (e) {
      debugPrint('Error upserting address: $e');
      rethrow;
    }
  }

  Future<bool> deleteAddress(String id) async {
    if (currentUser == null) return false;
    try {
      await client
          .from('user_addresses')
          .delete()
          .eq('id', id)
          .eq('user_id', currentUser!.id);
      return true;
    } catch (e) {
      debugPrint('Error deleting address: $e');
      return false;
    }
  }

  Future<bool> markDefaultAddress(String id) async {
    if (currentUser == null) return false;
    try {
      await client
          .from('user_addresses')
          .update({'is_default': false}).eq('user_id', currentUser!.id);
      await client
          .from('user_addresses')
          .update({'is_default': true}).eq('id', id);
      return true;
    } catch (e) {
      debugPrint('Error setting default address: $e');
      return false;
    }
  }

  /// Orders/profile insights --------------------------------------------------

  Future<List<Map<String, dynamic>>> getPastOrders() async {
    if (currentUser == null) return [];
    try {
      final rows = await client
          .from('orders')
          .select(
              '*, food_listings(id, title, image, lat, lng, owner_id, address_id, price), reviews(order_id, rating, comment, created_at)')
          .eq('user_id', currentUser!.id)
          .order('placed_at', ascending: false)
          .limit(20);
      return List<Map<String, dynamic>>.from(rows);
    } catch (e) {
      debugPrint('Error fetching orders: $e');
      return [];
    }
  }

  Future<int> getSavedFoodTotalGrams() async {
    if (currentUser == null) return 0;
    try {
      final rows = await client
          .from('orders')
          .select('saved_food_grams')
          .eq('user_id', currentUser!.id);
      return rows.fold<int>(0, (total, row) {
        final grams = (row['saved_food_grams'] as num?)?.toInt() ?? 0;
        return total + grams;
      });
    } catch (e) {
      debugPrint('Error calculating saved food total: $e');
      return 0;
    }
  }

  Future<List<Map<String, dynamic>>> getHostOrders({int limit = 50}) async {
    final user = currentUser;
    if (user == null) return [];
    try {
      final rows = await client
          .from('orders')
          .select(
              '*, food_listings!inner(id, title, image, lat, lng, owner_id, address_id, price)')
          .eq('food_listings.owner_id', user.id)
          .order('placed_at', ascending: false)
          .limit(limit);
      return List<Map<String, dynamic>>.from(rows);
    } on PostgrestException catch (e) {
      debugPrint('Error fetching host orders: ${e.message}');
      return [];
    } catch (e) {
      debugPrint('Error fetching host orders: $e');
      return [];
    }
  }

  Future<Map<String, dynamic>?> createOrder({
    required String listingId,
    int quantity = 1,
    int savedFoodGrams = 0,
    int totalPrice = 0,
  }) async {
    final user = currentUser;
    if (user == null) {
      throw AuthException('Please sign in before requesting a meal.');
    }
    final payload = {
      'listing_id': listingId,
      'user_id': user.id,
      'quantity': quantity,
      'saved_food_grams': savedFoodGrams,
      'status': 'pending',
      'contact_email': user.email,
      'total_price': totalPrice,
    };
    try {
      final response = await client
          .from('orders')
          .insert(payload)
          .select('*, food_listings(id, title, owner_id)')
          .maybeSingle();
      return response == null ? null : Map<String, dynamic>.from(response);
    } on PostgrestException catch (e) {
      debugPrint('Error creating order: ${e.message}');
      rethrow;
    }
  }

  Future<bool> confirmOrderPickup({
    required String orderId,
    String? method,
    String? code,
  }) async {
    if (currentUser == null) return false;
    try {
      await client.from('orders').update({
        'status': 'collected',
        'pickup_confirmed_at': DateTime.now().toIso8601String(),
        'pickup_confirmed_by': currentUser!.id,
        'pickup_confirmation_method': method,
        'pickup_code': code,
      }).eq('id', orderId);
      return true;
    } catch (e) {
      debugPrint('Error confirming order pickup: $e');
      return false;
    }
  }

  Future<Map<String, dynamic>?> createReview({
    required String orderId,
    required String listingId,
    required String hostId,
    required int rating,
    String? comment,
  }) async {
    final user = currentUser;
    if (user == null) {
      throw AuthException('Please sign in to leave a review.');
    }
    final payload = {
      'order_id': orderId,
      'listing_id': listingId,
      'host_id': hostId,
      'reviewer_id': user.id,
      'rating': rating,
      'comment': comment,
    }..removeWhere((key, value) => value == null);
    try {
      final response = await client
          .from('reviews')
          .upsert(payload, onConflict: 'order_id')
          .select()
          .maybeSingle();
      return response == null ? null : Map<String, dynamic>.from(response);
    } on PostgrestException catch (e) {
      debugPrint('Error creating review: ${e.message}');
      rethrow;
    }
  }

  Future<List<Map<String, dynamic>>> getListingReviews(String listingId) async {
    try {
      final rows = await client
          .from('reviews')
          .select()
          .eq('listing_id', listingId)
          .order('created_at', ascending: false);
      return List<Map<String, dynamic>>.from(rows);
    } catch (e) {
      debugPrint('Error fetching listing reviews: $e');
      return [];
    }
  }

  Future<List<Map<String, dynamic>>> getListingReviewStats(
      {List<String>? listingIds}) async {
    try {
      var query = client.from('listing_review_stats').select();
      if (listingIds != null && listingIds.isNotEmpty) {
        query = query.inFilter('listing_id', listingIds);
      }
      final rows = await query.order('last_review_at', ascending: false);
      return List<Map<String, dynamic>>.from(rows);
    } catch (e) {
      debugPrint('Error fetching listing review stats: $e');
      return [];
    }
  }

  Future<List<Map<String, dynamic>>> getHostListingMetrics() async {
    final user = currentUser;
    if (user == null) return [];
    try {
      final rows = await client
          .from('host_listing_metrics')
          .select()
          .eq('owner_id', user.id)
          .order('gross_revenue', ascending: false);
      return List<Map<String, dynamic>>.from(rows);
    } catch (e) {
      debugPrint('Error fetching host listing metrics: $e');
      return [];
    }
  }

  Future<Map<String, dynamic>?> getHostVerification() async {
    final user = currentUser;
    if (user == null) return null;
    try {
      final response = await client
          .from('host_verifications')
          .select()
          .eq('user_id', user.id)
          .order('submitted_at', ascending: false)
          .limit(1)
          .maybeSingle();
      return response == null ? null : Map<String, dynamic>.from(response);
    } catch (e) {
      debugPrint('Error fetching host verification: $e');
      return null;
    }
  }

  Future<List<Map<String, dynamic>>> getHostVerifications() async {
    final user = currentUser;
    if (user == null) return [];
    try {
      final rows = await client
          .from('host_verifications')
          .select()
          .eq('user_id', user.id)
          .order('submitted_at', ascending: false);
      return List<Map<String, dynamic>>.from(rows);
    } catch (e) {
      debugPrint('Error fetching host verifications: $e');
      return [];
    }
  }

  Future<List<Map<String, dynamic>>> getFoodSafetyChecks(
      {String? listingId}) async {
    if (currentUser == null) return [];
    try {
      var query = client
          .from('food_safety_checks')
          .select('*, food_listings(id, title, status)');
      if (listingId != null) {
        query = query.eq('listing_id', listingId);
      }
      final rows = await query.order('submitted_at', ascending: false);
      return List<Map<String, dynamic>>.from(rows);
    } catch (e) {
      debugPrint('Error fetching food safety checks: $e');
      return [];
    }
  }

  Future<void> registerDeviceToken({
    required String token,
    String? platform,
    Map<String, dynamic>? metadata,
  }) async {
    final user = currentUser;
    if (user == null) return;
    try {
      await client.from('user_devices').upsert({
        'user_id': user.id,
        'device_token': token,
        'platform': platform,
        'metadata': metadata,
        'last_seen_at': DateTime.now().toIso8601String(),
      }, onConflict: 'device_token');
    } catch (e) {
      debugPrint('Error registering device token: $e');
    }
  }

  Future<void> updateNotificationPreference({
    required String category,
    required bool enabled,
  }) async {
    final user = currentUser;
    if (user == null) return;
    try {
      await client.from('notification_preferences').upsert({
        'user_id': user.id,
        'category': category,
        'enabled': enabled,
        'updated_at': DateTime.now().toIso8601String(),
      }, onConflict: 'user_id,category');
    } catch (e) {
      debugPrint('Error updating notification preferences: $e');
    }
  }

  Future<Map<String, dynamic>?> getProfile() async {
    final user = currentUser;
    if (user == null) return null;
    try {
      final response = await client
          .from('profiles')
          .select()
          .eq('id', user.id)
          .maybeSingle();
      return response == null ? null : Map<String, dynamic>.from(response);
    } catch (e) {
      debugPrint('Error loading profile: $e');
      return null;
    }
  }

  Future<Map<String, dynamic>?> updateProfile(
      Map<String, dynamic> payload) async {
    final user = currentUser;
    if (user == null) return null;
    payload['id'] = user.id;
    payload['updated_at'] = DateTime.now().toIso8601String();
    try {
      final response = await client
          .from('profiles')
          .upsert(payload, onConflict: 'id')
          .select()
          .maybeSingle();
      return response == null ? null : Map<String, dynamic>.from(response);
    } catch (e) {
      debugPrint('Error updating profile: $e');
      return null;
    }
  }

  Future<bool> updateOrderStatus({
    required String orderId,
    required String status,
  }) async {
    try {
      await client.from('orders').update({
        'status': status,
        'updated_at': DateTime.now().toIso8601String(),
      }).eq('id', orderId);
      return true;
    } on PostgrestException catch (e) {
      debugPrint('Error updating order status: ${e.message}');
      return false;
    }
  }

  /// Get current authenticated user
  User? get currentUser => client.auth.currentUser;

  /// Sign in with email and password
  Future<AuthResponse> signIn(String email, String password) async {
    return await client.auth.signInWithPassword(
      email: email,
      password: password,
    );
  }

  /// Sign up with email and password
  Future<AuthResponse> signUp(String email, String password) async {
    return await client.auth.signUp(
      email: email,
      password: password,
    );
  }

  /// Sign out
  Future<void> signOut() async {
    await client.auth.signOut();
  }

  /// Sign in with Google using Supabase OAuth
  Future<void> signInWithGoogle() async {
    debugPrint('[Auth] Google OAuth starting');
    try {
      await client.auth.signInWithOAuth(
        OAuthProvider.google,
        redirectTo: 'io.supabase.flutter://login-callback',
      );
    } on AuthException catch (e) {
      debugPrint('[Auth] Google OAuth AuthException: ${e.message}');
      rethrow;
    } catch (e) {
      debugPrint('[Auth] Google OAuth generic error: $e');
      rethrow;
    }
  }

  /// Upload an image file to Supabase Storage and return a public URL
  /// Assumes a public bucket named 'listing_images' exists
  Future<String?> uploadListingImage({
    required File file,
  }) async {
    final userId = currentUser?.id ?? 'anonymous';
    final ext = file.path.split('.').last.toLowerCase();
    final String fileName = '${const Uuid().v4()}.$ext';
    final String path = '$userId/$fileName';
    try {
      await client.storage.from('listing_images').upload(path, file,
          fileOptions: const FileOptions(cacheControl: '3600', upsert: false));

      // If bucket is public, getPublicUrl will work; else use createSignedUrl
      final publicUrl =
          client.storage.from('listing_images').getPublicUrl(path);
      return publicUrl;
    } catch (e) {
      debugPrint('Error uploading image: $e');
      return null;
    }
  }

  /// Robust Meal Request Pipeline with Retry & Validation
  Future<OrderResult> createOrderSafe({
    required String listingId,
    int quantity = 1,
    int savedFoodGrams = 0,
    int totalPrice = 0,
  }) async {
    final user = currentUser;
    if (user == null) {
      return OrderResult(success: false, errorMessage: 'Please sign in to request a meal.');
    }

    if (quantity < 1) {
       return OrderResult(success: false, errorMessage: 'Quantity must be at least 1.');
    }

    int attempts = 0;
    while (attempts < 3) {
      try {
        final payload = {
          'listing_id': listingId,
          'user_id': user.id,
          'quantity': quantity,
          'saved_food_grams': savedFoodGrams,
          'status': 'pending',
          'contact_email': user.email,
          'total_price': totalPrice,
        };

        // Explicit timeout to prevent hanging UI
        final response = await client
            .from('orders')
            .insert(payload)
            .select('*, food_listings(id, title, owner_id)')
            .maybeSingle()
            .timeout(const Duration(seconds: 15));

        if (response != null) {
          return OrderResult(success: true, data: Map<String, dynamic>.from(response));
        } else {
          return OrderResult(success: false, errorMessage: 'Server returned no data.');
        }
      } on PostgrestException catch (e) {
        // Database errors (e.g. constraints) should NOT be retried
        debugPrint('[createOrderSafe] PostgrestException: ${e.message} (Code: ${e.code})');
        return OrderResult(success: false, errorMessage: e.message);
      } catch (e) {
        // Network/Timeout errors SHOULD be retried
        attempts++;
        debugPrint('[createOrderSafe] Attempt $attempts failed: $e');
        if (attempts >= 3) {
           return OrderResult(success: false, errorMessage: 'Network error. Please check your connection.');
        }
        await Future.delayed(Duration(milliseconds: 500 * attempts)); // Exponential backoff
      }
    }
    return OrderResult(success: false, errorMessage: 'Request failed. Please try again.');
  }

  // ==================== FAVORITES ====================

  /// Toggle favorite status for a listing
  Future<bool> toggleFavorite(String listingId) async {
    final user = currentUser;
    if (user == null) return false;

    try {
      // Check if already favorited
      final existing = await client
          .from('user_favorites')
          .select('id')
          .eq('user_id', user.id)
          .eq('listing_id', listingId)
          .maybeSingle();

      if (existing != null) {
        // Remove favorite
        await client
            .from('user_favorites')
            .delete()
            .eq('user_id', user.id)
            .eq('listing_id', listingId);
        debugPrint('[SupabaseService] Removed favorite: $listingId');
        return false; // Not favorited anymore
      } else {
        // Add favorite
        await client.from('user_favorites').insert({
          'user_id': user.id,
          'listing_id': listingId,
        });
        debugPrint('[SupabaseService] Added favorite: $listingId');
        return true; // Now favorited
      }
    } catch (e) {
      debugPrint('[SupabaseService] Error toggling favorite: $e');
      return false;
    }
  }

  /// Check if a listing is favorited
  Future<bool> isFavorite(String listingId) async {
    final user = currentUser;
    if (user == null) return false;

    try {
      final result = await client
          .from('user_favorites')
          .select('id')
          .eq('user_id', user.id)
          .eq('listing_id', listingId)
          .maybeSingle();
      return result != null;
    } catch (e) {
      debugPrint('[SupabaseService] Error checking favorite: $e');
      return false;
    }
  }

  /// Get all favorite listing IDs for current user
  Future<Set<String>> getFavoriteListingIds() async {
    final user = currentUser;
    if (user == null) return {};

    try {
      final rows = await client
          .from('user_favorites')
          .select('listing_id')
          .eq('user_id', user.id);
      return rows.map<String>((r) => r['listing_id'].toString()).toSet();
    } catch (e) {
      debugPrint('[SupabaseService] Error fetching favorite IDs: $e');
      return {};
    }
  }

  /// Get all favorited listings with full details
  Future<List<Map<String, dynamic>>> getFavoriteListings() async {
    final user = currentUser;
    if (user == null) return [];

    try {
      final rows = await client
          .from('user_favorites')
          .select('listing_id, food_listings(*)')
          .eq('user_id', user.id)
          .order('created_at', ascending: false);
      
      return rows
          .where((r) => r['food_listings'] != null)
          .map<Map<String, dynamic>>((r) => Map<String, dynamic>.from(r['food_listings']))
          .toList();
    } catch (e) {
      debugPrint('[SupabaseService] Error fetching favorite listings: $e');
      return [];
    }
  }

  // ==================== REVIEWS ====================

  /// Check if user has already reviewed an order
  Future<bool> hasReviewedOrder(String orderId) async {
    final user = currentUser;
    if (user == null) return false;

    try {
      final result = await client
          .from('reviews')
          .select('id')
          .eq('order_id', orderId)
          .eq('reviewer_id', user.id)
          .maybeSingle();
      return result != null;
    } catch (e) {
      debugPrint('[SupabaseService] Error checking review: $e');
      return false;
    }
  }

  /// Get reviews for a host
  Future<List<Map<String, dynamic>>> getReviewsForHost(String hostId) async {
    try {
      final rows = await client
          .from('reviews')
          .select('*, profiles:reviewer_id(full_name)')
          .eq('host_id', hostId)
          .order('created_at', ascending: false);
      return List<Map<String, dynamic>>.from(rows);
    } catch (e) {
      debugPrint('[SupabaseService] Error fetching host reviews: $e');
      return [];
    }
  }

  /// Get average rating for a host
  Future<double> getHostAverageRating(String hostId) async {
    try {
      final rows = await client
          .from('reviews')
          .select('rating')
          .eq('host_id', hostId);
      if (rows.isEmpty) return 0.0;
      final total = rows.fold<int>(0, (sum, r) => sum + (r['rating'] as int? ?? 0));
      return total / rows.length;
    } catch (e) {
      debugPrint('[SupabaseService] Error calculating host rating: $e');
      return 0.0;
    }
  }

  // ==================== CHAT ====================

  /// Send a chat message
  Future<Map<String, dynamic>?> sendMessage({
    required String orderId,
    required String receiverId,
    required String message,
  }) async {
    final user = currentUser;
    if (user == null) return null;

    try {
      final result = await client.from('chat_messages').insert({
        'order_id': orderId,
        'sender_id': user.id,
        'receiver_id': receiverId,
        'message': message,
      }).select().maybeSingle();
      debugPrint('[SupabaseService] Sent message to: $receiverId');
      return result != null ? Map<String, dynamic>.from(result) : null;
    } catch (e) {
      debugPrint('[SupabaseService] Error sending message: $e');
      return null;
    }
  }

  /// Get messages for an order
  Future<List<Map<String, dynamic>>> getMessages(String orderId) async {
    try {
      final rows = await client
          .from('chat_messages')
          .select('*, sender:sender_id(full_name)')
          .eq('order_id', orderId)
          .order('created_at', ascending: true);
      return List<Map<String, dynamic>>.from(rows);
    } catch (e) {
      debugPrint('[SupabaseService] Error fetching messages: $e');
      return [];
    }
  }

  /// Mark messages as read
  Future<void> markMessagesAsRead(String orderId) async {
    final user = currentUser;
    if (user == null) return;

    try {
      await client
          .from('chat_messages')
          .update({'is_read': true})
          .eq('order_id', orderId)
          .eq('receiver_id', user.id);
    } catch (e) {
      debugPrint('[SupabaseService] Error marking messages read: $e');
    }
  }

  /// Get unread message count for current user
  Future<int> getUnreadMessageCount() async {
    final user = currentUser;
    if (user == null) return 0;

    try {
      final result = await client
          .from('chat_messages')
          .select('id')
          .eq('receiver_id', user.id)
          .eq('is_read', false);
      return result.length;
    } catch (e) {
      debugPrint('[SupabaseService] Error counting unread messages: $e');
      return 0;
    }
  }
}

/// Helper result class for robust error handling
class OrderResult {
  final bool success;
  final String? errorMessage;
  final Map<String, dynamic>? data;

  OrderResult({
    required this.success,
    this.errorMessage,
    this.data,
  });
}
