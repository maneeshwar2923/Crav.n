import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:uuid/uuid.dart';

import 'supabase_config.dart';

class SupabasePartnerService {
  SupabasePartnerService._();

  static SupabasePartnerService? _instance;
  static SupabaseClient? _client;

  static SupabasePartnerService get instance {
    _instance ??= SupabasePartnerService._();
    return _instance!;
  }

  static Future<void> initialize() async {
    if (_client != null) {
      return;
    }
    debugPrint('[SupabasePartnerService] Initializing…');
    final usingFallback = SupabaseConfig.usingFallbackCredentials;
    debugPrint(
      '[SupabasePartnerService] Credentials source: ${usingFallback ? 'fallback defaults' : 'provided env/defines'}',
    );
    try {
      await Supabase.initialize(
        url: SupabaseConfig.url,
        anonKey: SupabaseConfig.anonKey,
      );
      _client = Supabase.instance.client;
      final userId = _client!.auth.currentUser?.id ?? 'anonymous';
      debugPrint('[SupabasePartnerService] Ready (user: $userId)');
    } catch (e, stack) {
      debugPrint('[SupabasePartnerService] Initialization failed: $e');
      debugPrint('$stack');
      rethrow;
    }
  }

  SupabaseClient get client {
    final existing = _client;
    if (existing == null) {
      throw StateError(
        'Supabase not initialized. Call SupabasePartnerService.initialize() first.',
      );
    }
    return existing;
  }

  Session? get currentSession => client.auth.currentSession;
  User? get currentUser => client.auth.currentUser;
  Stream<AuthState> get authStateChanges => client.auth.onAuthStateChange;

  Future<AuthResponse> signIn(String email, String password) {
    return client.auth.signInWithPassword(email: email, password: password);
  }

  Future<void> signOut() => client.auth.signOut();

  Future<bool> createProfile({
    required String fullName,
    required String description,
  }) async {
    final user = client.auth.currentUser;
    if (user == null) return false;

    try {
      await client.from('profiles').upsert({
        'id': user.id,
        'full_name': fullName,
        'description': description,
        'role': 'host',
        'host_status': 'pending', // Default to pending verification
        'host_verified': false,
        'created_at': DateTime.now().toIso8601String(),
        'updated_at': DateTime.now().toIso8601String(),
      });
      return true;
    } catch (e) {
      debugPrint('Error creating profile: $e');
      return false;
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
      debugPrint('[SupabasePartnerService] Error loading profile: $e');
      return null;
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
      debugPrint(
          '[SupabasePartnerService] Error loading host verification: $e');
      return null;
    }
  }

  Future<List<Map<String, dynamic>>> getHostVerificationHistory() async {
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
      debugPrint(
          '[SupabasePartnerService] Error loading verification history: $e');
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
      debugPrint('[SupabasePartnerService] Error loading listing metrics: $e');
      return [];
    }
  }

  Future<List<Map<String, dynamic>>> getHostListings() async {
    final user = currentUser;
    if (user == null) return [];
    try {
      final rows = await client
          .from('food_listings')
          .select(
              'id, title, lat, lng, price, status, portions_available, image, isveg')
          .eq('owner_id', user.id)
          .order('updated_at', ascending: false);
      return List<Map<String, dynamic>>.from(rows);
    } catch (e) {
      debugPrint('[SupabasePartnerService] Error loading host listings: $e');
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
      debugPrint('[SupabasePartnerService] Error loading safety checks: $e');
      return [];
    }
  }

  Future<List<Map<String, dynamic>>> getRecentHostOrders(
      {int limit = 5}) async {
    final user = currentUser;
    if (user == null) return [];
    try {
      final rows = await client
          .from('orders')
          .select(
              '*, food_listings!inner(id, title, image, address_id, owner_id, price), profiles!orders_user_id_fkey(full_name, phone_number)')
          .eq('food_listings.owner_id', user.id)
          .order('placed_at', ascending: false)
          .limit(limit);
      return List<Map<String, dynamic>>.from(rows);
    } catch (e) {
      debugPrint('[SupabasePartnerService] Error loading host orders: $e');
      return [];
    }
  }

  Future<List<Map<String, dynamic>>> getHostOrders({int limit = 50}) async {
    final user = currentUser;
    if (user == null) return [];
    try {
      final rows = await client
          .from('orders')
          .select(
              '*, food_listings!inner(id, title, image, owner_id, price, portions_available, lat, lng), profiles!orders_user_id_fkey(full_name, phone_number)')
          .eq('food_listings.owner_id', user.id)
          .order('placed_at', ascending: false)
          .limit(limit);
      return List<Map<String, dynamic>>.from(rows);
    } on PostgrestException catch (e) {
      debugPrint(
          '[SupabasePartnerService] Error loading host orders: ${e.message}');
      return [];
    } catch (e) {
      debugPrint('[SupabasePartnerService] Error loading host orders: $e');
      return [];
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
      debugPrint(
          '[SupabasePartnerService] Error updating order status: ${e.message}');
      return false;
    } catch (e) {
      debugPrint('[SupabasePartnerService] Error updating order status: $e');
      return false;
    }
  }

  Future<Map<String, dynamic>?> createFoodListing(
      Map<String, dynamic> listing) async {
    final user = currentUser;
    if (user == null) {
      throw AuthException('You need to be signed in to create a listing.');
    }
    try {
      listing['owner_id'] ??= user.id;
      debugPrint('[SupabasePartnerService] Creating listing with payload: $listing');
      final response = await client
          .from('food_listings')
          .insert(listing)
          .select()
          .maybeSingle();
      return response == null ? null : Map<String, dynamic>.from(response);
    } on PostgrestException catch (e) {
      debugPrint(
          '[SupabasePartnerService] Error creating listing: ${e.message}');
      rethrow;
    }
  }

  Future<Map<String, dynamic>?> updateFoodListing(
      Map<String, dynamic> listing) async {
    final user = currentUser;
    if (user == null) {
      throw AuthException('You need to be signed in to update a listing.');
    }
    try {
      final response = await client
          .from('food_listings')
          .update(listing)
          .eq('id', listing['id'])
          .eq('owner_id', user.id)
          .select()
          .maybeSingle();
      return response == null ? null : Map<String, dynamic>.from(response);
    } on PostgrestException catch (e) {
      debugPrint(
          '[SupabasePartnerService] Error updating listing: ${e.message}');
      rethrow;
    }
  }

  Future<bool> deleteFoodListing(String listingId) async {
    final user = currentUser;
    if (user == null) return false;
    try {
      await client
          .from('food_listings')
          .delete()
          .eq('id', listingId)
          .eq('owner_id', user.id);
      return true;
    } catch (e) {
      debugPrint('[SupabasePartnerService] Error deleting listing: $e');
      return false;
    }
  }

  Future<List<String>> uploadListingImages({required List<File> files}) async {
    final userId = currentUser?.id ?? 'anonymous';
    List<String> urls = [];
    
    for (var file in files) {
      final ext = file.path.split('.').last.toLowerCase();
      final fileName = '${const Uuid().v4()}.$ext';
      final path = '$userId/$fileName';
      try {
        await client.storage.from('listing_images').upload(
              path,
              file,
              fileOptions: const FileOptions(cacheControl: '3600', upsert: false),
            );
        final publicUrl = client.storage.from('listing_images').getPublicUrl(path);
        urls.add(publicUrl);
      } catch (e) {
        debugPrint('[SupabasePartnerService] Error uploading one listing image: $e');
        // Continue uploading others even if one fails
      }
    }
    return urls;
  }

  Future<String?> uploadListingImage({required File file}) async {
    // Legacy single image upload, can keep for backward compatibility or refactor
    final urls = await uploadListingImages(files: [file]);
    return urls.isNotEmpty ? urls.first : null;
  }

  Future<List<Map<String, dynamic>>> getUserAddresses() async {
    final user = currentUser;
    if (user == null) return [];
    try {
      final rows = await client
          .from('user_addresses')
          .select()
          .eq('user_id', user.id)
          .order('is_default', ascending: false)
          .order('created_at');
      return List<Map<String, dynamic>>.from(rows);
    } catch (e) {
      debugPrint('[SupabasePartnerService] Error loading user addresses: $e');
      return [];
    }
  }

  Future<Map<String, dynamic>?> upsertAddress(
      Map<String, dynamic> payload) async {
    final user = currentUser;
    if (user == null) {
      throw const AuthException('User not logged in');
    }
    try {
      payload['user_id'] = user.id;
      final response = await client
          .from('user_addresses')
          .upsert(payload, onConflict: 'id')
          .select()
          .maybeSingle();
      return response == null ? null : Map<String, dynamic>.from(response);
    } on PostgrestException catch (e) {
      debugPrint('[SupabasePartnerService] Error saving address: ${e.message}');
      debugPrint('Code: ${e.code}, Details: ${e.details}, Hint: ${e.hint}');
      rethrow;
    } catch (e) {
      debugPrint('[SupabasePartnerService] Error saving address: $e');
      rethrow;
    }
  }

  Future<bool> deleteAddress(String id) async {
    final user = currentUser;
    if (user == null) return false;
    try {
      await client
          .from('user_addresses')
          .delete()
          .eq('id', id)
          .eq('user_id', user.id);
      return true;
    } catch (e) {
      debugPrint('[SupabasePartnerService] Error deleting address: $e');
      return false;
    }
  }

  Future<bool> markDefaultAddress(String id) async {
    final user = currentUser;
    if (user == null || id.isEmpty) return false;
    try {
      await client
          .from('user_addresses')
          .update({'is_default': false}).eq('user_id', user.id);
      await client
          .from('user_addresses')
          .update({'is_default': true}).eq('id', id);
      return true;
    } catch (e) {
      debugPrint('[SupabasePartnerService] Error setting default address: $e');
      return false;
    }
  }
  Future<bool> updateProfile(Map<String, dynamic> updates) async {
    final user = currentUser;
    if (user == null) return false;
    try {
      await client.from('profiles').update(updates).eq('id', user.id);
      return true;
    } catch (e) {
      debugPrint('[SupabasePartnerService] Error updating profile: $e');
      return false;
    }
  }

  // Payouts
  Future<List<Map<String, dynamic>>> getPayouts() async {
    final user = currentUser;
    if (user == null) return [];
    try {
      final rows = await client
          .from('payouts')
          .select()
          .eq('user_id', user.id)
          .order('requested_at', ascending: false);
      return List<Map<String, dynamic>>.from(rows);
    } catch (e) {
      debugPrint('[SupabasePartnerService] Error loading payouts: $e');
      return [];
    }
  }

  Future<bool> requestPayout(double amount) async {
    final user = currentUser;
    if (user == null) return false;
    try {
      await client.from('payouts').insert({
        'user_id': user.id,
        'amount': amount,
        'status': 'pending',
        'requested_at': DateTime.now().toIso8601String(),
      });
      return true;
    } catch (e) {
      debugPrint('[SupabasePartnerService] Error requesting payout: $e');
      return false;
    }
  }

  // Reviews
  Future<List<Map<String, dynamic>>> getReviews() async {
    final user = currentUser;
    if (user == null) return [];
    try {
      // Assuming reviews are linked to listings which are linked to the owner
      // This query might need adjustment based on exact schema
      final rows = await client
          .from('reviews')
          .select('*, food_listings!inner(owner_id, title), profiles(full_name)')
          .eq('food_listings.owner_id', user.id)
          .order('created_at', ascending: false);
      return List<Map<String, dynamic>>.from(rows);
    } catch (e) {
      debugPrint('[SupabasePartnerService] Error loading reviews: $e');
      return [];
    }
  }

  Future<bool> replyToReview(String reviewId, String reply) async {
    try {
      await client.from('reviews').update({
        'host_reply': reply,
        'replied_at': DateTime.now().toIso8601String(),
      }).eq('id', reviewId);
      return true;
    } catch (e) {
      debugPrint('[SupabasePartnerService] Error replying to review: $e');
      return false;
    }
  }
}
