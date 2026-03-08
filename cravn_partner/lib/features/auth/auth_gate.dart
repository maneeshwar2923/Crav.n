import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../core/theme/colors.dart';
import '../../core/services/supabase_partner_service.dart';
import '../dashboard/dashboard_screen.dart';
import 'login_screen.dart';

class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  SupabasePartnerService get _service => SupabasePartnerService.instance;

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<AuthState>(
      stream: _service.authStateChanges,
      builder: (context, snapshot) {
        final session = snapshot.data?.session ?? _service.currentSession;

        if (snapshot.connectionState == ConnectionState.waiting &&
            session == null) {
          return Scaffold(
            body: Center(child: CircularProgressIndicator(color: cravnPrimary)),
          );
        }

        if (session == null) {
          return PartnerLoginScreen(
            onSignedIn: () => _showWelcomeSnackbar(context),
          );
        }

        return PartnerDashboardShell(
          onSignedOut: () => _showGoodbyeSnackbar(context),
        );
      },
    );
  }

  void _showWelcomeSnackbar(BuildContext context) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Signed in to Crav\'n Partner.')),
      );
    });
  }

  void _showGoodbyeSnackbar(BuildContext context) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Signed out successfully.')),
      );
    });
  }
}
