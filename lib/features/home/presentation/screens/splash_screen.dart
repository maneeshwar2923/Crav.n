import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:cravn_flutter/routes/app_routes.dart';
import '../../../../core/widgets/logo.dart';
import '../../../../core/services/supabase_service.dart';

/// Splash screen now gates navigation based on authentication state.
/// If the user is logged in -> home, else -> login.
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  String _status = 'Initializing';

  @override
  void initState() {
    super.initState();
    _bootstrap();
  }

  Future<void> _bootstrap() async {
    debugPrint('[Splash] bootstrap start');
    await Future.delayed(const Duration(milliseconds: 800));
    User? user;
    try {
      user = SupabaseService.instance.currentUser;
      debugPrint('[Splash] currentUser check -> ${user?.id ?? 'null'}');
      if (mounted) setState(() => _status = 'User: ${user?.id ?? 'none'}');
    } catch (e) {
      debugPrint('[Splash] ERROR accessing currentUser: $e');
      if (mounted) setState(() => _status = 'Error reading user');
    }
    if (!mounted) return;
    if (user == null) {
      debugPrint('[Splash] Navigating to login');
      _statusNavigate(AppRoutes.login, label: 'login');
    } else {
      debugPrint('[Splash] Navigating to home');
      _statusNavigate(AppRoutes.home, label: 'home');
    }
    // Failsafe after 5s
    Future.delayed(const Duration(seconds: 5), () {
      if (!mounted) return;
      final stillSplash =
          ModalRoute.of(context)?.settings.name == AppRoutes.splash;
      if (stillSplash) {
        debugPrint(
            '[Splash] Failsafe triggered -> forcing navigation to login');
        _statusNavigate(AppRoutes.login, label: 'login(failsafe)');
      }
    });
  }

  void _statusNavigate(String route, {required String label}) {
    setState(() => _status = 'Navigating -> $label');
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      try {
        Navigator.of(context).pushNamedAndRemoveUntil(route, (r) => false);
        debugPrint('[Splash] pushNamedAndRemoveUntil to $route done');
      } catch (e) {
        debugPrint('[Splash] Navigation error to $route: $e');
        if (mounted) setState(() => _status = 'Navigation error');
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.primary,
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const CravnLogo(size: 80),
            const SizedBox(height: 24),
            const CircularProgressIndicator(color: Colors.white),
            const SizedBox(height: 12),
            Text(_status, style: const TextStyle(color: Colors.white)),
            const SizedBox(height: 16),
            OutlinedButton(
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.white,
                side: const BorderSide(color: Colors.white),
              ),
              onPressed: () {
                debugPrint('[Splash] Manual continue tapped');
                _statusNavigate(AppRoutes.login, label: 'login(manual)');
              },
              child: const Text('Continue'),
            ),
          ],
        ),
      ),
    );
  }
}
