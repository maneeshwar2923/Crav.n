import 'package:flutter/foundation.dart';

/// Mirrors the consumer app configuration so both apps share credentials.
class SupabaseConfig {
  static const String _fallbackUrl = 'https://jxwefjzvwguizhueqwce.supabase.co';
  static const String _fallbackAnonKey =
      'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Imp4d2Vmanp2d2d1aXpodWVxd2NlIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NjI0OTU3NjEsImV4cCI6MjA3ODA3MTc2MX0.TweLbiqsQjwbrkrtBKksimyl25VJ07YAT33gOgh5rZg';

  static const String _defineUrl =
      String.fromEnvironment('SUPABASE_URL', defaultValue: '');
  static const String _defineAnonKey =
      String.fromEnvironment('SUPABASE_ANON_KEY', defaultValue: '');
  static bool _warnedUrlFallback = false;
  static bool _warnedKeyFallback = false;

  static String get url {
    if (_defineUrl.isNotEmpty) {
      return _defineUrl;
    }
    if (!_warnedUrlFallback) {
      debugPrint(
        '[SupabaseConfig] Using fallback Supabase URL. Provide SUPABASE_URL via --dart-define.',
      );
      _warnedUrlFallback = true;
    }
    return _fallbackUrl;
  }

  static String get anonKey {
    if (_defineAnonKey.isNotEmpty) {
      return _defineAnonKey;
    }
    if (!_warnedKeyFallback) {
      debugPrint(
        '[SupabaseConfig] Using fallback Supabase anon key. Provide SUPABASE_ANON_KEY via --dart-define.',
      );
      _warnedKeyFallback = true;
    }
    return _fallbackAnonKey;
  }
}
