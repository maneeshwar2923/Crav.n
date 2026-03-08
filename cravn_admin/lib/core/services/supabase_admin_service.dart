import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'supabase_config.dart';

class SupabaseAdminService {
  SupabaseAdminService._();

  static SupabaseAdminService? _instance;
  static SupabaseClient? _client;

  static SupabaseAdminService get instance {
    _instance ??= SupabaseAdminService._();
    return _instance!;
  }

  static Future<void> initialize() async {
    if (_client != null) return;
    try {
      await Supabase.initialize(
        url: SupabaseConfig.url,
        anonKey: SupabaseConfig.anonKey,
      );
      _client = Supabase.instance.client;
      debugPrint('[SupabaseAdminService] Initialized');
    } catch (e) {
      debugPrint('[SupabaseAdminService] Initialization failed: $e');
      rethrow;
    }
  }

  SupabaseClient get client {
    if (_client == null) {
      throw StateError('SupabaseAdminService not initialized');
    }
    return _client!;
  }

  Session? get currentSession => client.auth.currentSession;
  User? get currentUser => client.auth.currentUser;
  Stream<AuthState> get authStateChanges => client.auth.onAuthStateChange;

  Future<AuthResponse> signIn(String email, String password) {
    return client.auth.signInWithPassword(email: email, password: password);
  }

  Future<void> signOut() => client.auth.signOut();

  // --- Host Management ---

  Future<List<Map<String, dynamic>>> getPendingHosts() async {
    try {
      final response = await client
          .from('profiles')
          .select()
          .eq('host_status', 'pending')
          .order('created_at', ascending: false);
      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      debugPrint('[SupabaseAdminService] Error loading pending hosts: $e');
      return [];
    }
  }

  Future<bool> approveHost(String userId) async {
    try {
      await client.from('profiles').update({
        'host_status': 'approved',
        'host_verified': true,
        'updated_at': DateTime.now().toIso8601String(),
      }).eq('id', userId);
      return true;
    } catch (e) {
      debugPrint('[SupabaseAdminService] Error approving host: $e');
      return false;
    }
  }

  Future<bool> rejectHost(String userId) async {
    try {
      await client.from('profiles').update({
        'host_status': 'rejected',
        'host_verified': false,
        'updated_at': DateTime.now().toIso8601String(),
      }).eq('id', userId);
      return true;
    } catch (e) {
      debugPrint('[SupabaseAdminService] Error rejecting host: $e');
      return false;
    }
  }

  // --- Content Moderation ---

  Future<List<Map<String, dynamic>>> getAllListings() async {
    try {
      final response = await client
          .from('food_listings')
          .select('*, profiles(full_name)')
          .order('created_at', ascending: false);
      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      debugPrint('[SupabaseAdminService] Error loading listings: $e');
      return [];
    }
  }

  Future<bool> deleteListing(String listingId) async {
    try {
      await client.from('food_listings').delete().eq('id', listingId);
      return true;
    } catch (e) {
      debugPrint('[SupabaseAdminService] Error deleting listing: $e');
      return false;
    }
  }

  Future<bool> updateListingStatus(String listingId, String status) async {
    try {
      await client.from('food_listings').update({
        'status': status,
        'verified_at': status == 'verified' ? DateTime.now().toIso8601String() : null,
      }).eq('id', listingId);
      return true;
    } catch (e) {
      debugPrint('[SupabaseAdminService] Error updating listing status: $e');
      return false;
    }
  }
}
