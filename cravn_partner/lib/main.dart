import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:firebase_core/firebase_core.dart';

import 'app.dart';
import 'core/services/supabase_config.dart';
import 'core/services/supabase_partner_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final envSource = await _loadEnvironment();
  if (envSource != null) {
    debugPrint('[main] Loaded environment from $envSource');
  }

  if (SupabaseConfig.usingFallbackCredentials) {
    debugPrint(
      '[main] Supabase credentials not provided. Configure SUPABASE_URL and SUPABASE_ANON_KEY via .env or --dart-define. Using fallback dev keys.',
    );
  }

  try {
    await SupabasePartnerService.initialize();
  } catch (e) {
    debugPrint('[main] Supabase initialization failed: $e');
  }

  // Initialize Firebase
  try {
    await Firebase.initializeApp();
    debugPrint('[main] Firebase initialized');
  } catch (e) {
    debugPrint('[main] Firebase initialize failed: $e');
  }

  runApp(const CravnPartnerApp());
}

Future<String?> _loadEnvironment() async {
  const candidates = [
    'assets/env/.env',
    '.env',
  ];
  for (final candidate in candidates) {
    try {
      final mergeWith = dotenv.isInitialized
          ? Map<String, String>.from(dotenv.env)
          : <String, String>{};
      await dotenv.load(fileName: candidate, mergeWith: mergeWith);
      return candidate;
    } catch (e) {
      debugPrint('[main] Env load skipped for $candidate: $e');
    }
  }
  return null;
}
