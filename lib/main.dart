import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'core/theme/theme.dart';
import 'routes/app_routes.dart';
import 'core/services/supabase_config.dart';
import 'core/services/supabase_service.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final envSource = await _loadEnvironment();
  if (envSource != null) {
    debugPrint('[main] Loaded environment from $envSource');
  }

  if (SupabaseConfig.usingFallbackCredentials) {
    debugPrint(
        '[main] Supabase credentials not provided. Configure SUPABASE_URL and SUPABASE_ANON_KEY via .env or --dart-define. Using fallback dev keys.');
  }

  try {
    await SupabaseService.initialize();
  } catch (e) {
    debugPrint('[main] Supabase initialize failed: $e');
  }

  // Initialize Firebase
  try {
    await Firebase.initializeApp();
    debugPrint('[main] Firebase initialized');
  } catch (e) {
    debugPrint('[main] Firebase initialize failed: $e');
  }

  runApp(CravnApp(envLoaded: envSource != null));
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

class CravnApp extends StatelessWidget {
  final bool envLoaded;
  const CravnApp({super.key, required this.envLoaded});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "Crav'n",
      theme: buildCravnTheme(),
      // Start at the splash screen; routing is defined in AppRoutes
      initialRoute: AppRoutes.splash,
      routes: AppRoutes.routes,
      debugShowCheckedModeBanner: false,
      builder: (context, child) => child ?? const SizedBox.shrink(),
    );
  }
}
