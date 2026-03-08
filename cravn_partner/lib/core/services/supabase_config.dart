import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

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
    final envUrl = _envValue('SUPABASE_URL');
    if (envUrl != null && envUrl.isNotEmpty) {
      return envUrl;
    }
    if (!_warnedUrlFallback) {
      debugPrint(
        '[SupabaseConfig] Using fallback Supabase URL. Provide SUPABASE_URL via .env or --dart-define.',
      );
      _warnedUrlFallback = true;
    }
    return _fallbackUrl;
  }

  static String get anonKey {
    if (_defineAnonKey.isNotEmpty) {
      return _defineAnonKey;
    }
    final envKey = _envValue('SUPABASE_ANON_KEY');
    if (envKey != null && envKey.isNotEmpty) {
      return envKey;
    }
    if (!_warnedKeyFallback) {
      debugPrint(
        '[SupabaseConfig] Using fallback Supabase anon key. Provide SUPABASE_ANON_KEY via .env or --dart-define.',
      );
      _warnedKeyFallback = true;
    }
    return _fallbackAnonKey;
  }

  static bool get hasExplicitCredentials {
    if (_defineUrl.isNotEmpty && _defineAnonKey.isNotEmpty) {
      return true;
    }
    final envUrl = _envValue('SUPABASE_URL');
    final envKey = _envValue('SUPABASE_ANON_KEY');
    return (envUrl?.isNotEmpty ?? false) && (envKey?.isNotEmpty ?? false);
  }

  static bool get usingFallbackCredentials => !hasExplicitCredentials;

  static String? _envValue(String key) {
    try {
      return dotenv.maybeGet(key);
    } catch (_) {
      return null;
    }
  }
}
