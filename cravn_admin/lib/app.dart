import 'package:flutter/material.dart';
import 'core/theme/colors.dart';
import 'core/theme/theme.dart';
import 'core/services/supabase_admin_service.dart';
import 'features/auth/presentation/screens/admin_login_screen.dart';
import 'features/dashboard/presentation/screens/admin_dashboard_screen.dart';

class CravnAdminApp extends StatelessWidget {
  const CravnAdminApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Crav\'n Admin',
      debugShowCheckedModeBanner: false,
      theme: buildCravnAdminTheme(),
      home: const _AuthWrapper(),
    );
  }
}

class _AuthWrapper extends StatefulWidget {
  const _AuthWrapper();

  @override
  State<_AuthWrapper> createState() => _AuthWrapperState();
}

class _AuthWrapperState extends State<_AuthWrapper> {
  bool _isLoading = true;
  bool _isAuthenticated = false;

  @override
  void initState() {
    super.initState();
    _checkAuth();
    SupabaseAdminService.instance.authStateChanges.listen((state) {
      if (mounted) _checkAuth();
    });
  }

  Future<void> _checkAuth() async {
    final session = SupabaseAdminService.instance.currentSession;
    setState(() {
      _isAuthenticated = session != null;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(body: Center(child: CircularProgressIndicator(color: cravnPrimary)));
    }
    return _isAuthenticated ? const AdminDashboardScreen() : const AdminLoginScreen();
  }
}
