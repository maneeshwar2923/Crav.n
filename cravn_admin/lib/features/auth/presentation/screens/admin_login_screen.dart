import 'package:flutter/material.dart';
import '../../../../core/services/supabase_admin_service.dart';
import '../../../../core/theme/dimensions.dart';
import '../../../../core/theme/colors.dart';

class AdminLoginScreen extends StatefulWidget {
  const AdminLoginScreen({super.key});

  @override
  State<AdminLoginScreen> createState() => _AdminLoginScreenState();
}

class _AdminLoginScreenState extends State<AdminLoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;
  String? _errorMessage;

  Future<void> _login() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      await SupabaseAdminService.instance.signIn(
        _emailController.text.trim(),
        _passwordController.text.trim(),
      );
      // Auth wrapper will handle navigation
    } catch (e) {
      setState(() {
        _errorMessage = 'Login failed: ${e.toString()}';
      });
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Container(
          constraints: const BoxConstraints(maxWidth: 400),
          padding: const EdgeInsets.all(Dimensions.s24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text(
                'Crav\'n Admin',
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: cravnPrimary,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 48.0),
              if (_errorMessage != null)
                Container(
                  padding: const EdgeInsets.all(Dimensions.s12),
                  margin: const EdgeInsets.only(bottom: Dimensions.s16),
                  decoration: BoxDecoration(
                    color: cravnError.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(Dimensions.radiusSm),
                  ),
                  child: Text(
                    _errorMessage!,
                    style: const TextStyle(color: cravnError),
                  ),
                ),
              TextField(
                controller: _emailController,
                decoration: const InputDecoration(
                  labelText: 'Email',
                  prefixIcon: Icon(Icons.email_outlined),
                ),
                keyboardType: TextInputType.emailAddress,
              ),
              const SizedBox(height: Dimensions.s16),
              TextField(
                controller: _passwordController,
                decoration: const InputDecoration(
                  labelText: 'Password',
                  prefixIcon: Icon(Icons.lock_outline),
                ),
                obscureText: true,
              ),
              const SizedBox(height: Dimensions.s32),
              ElevatedButton(
                onPressed: _isLoading ? null : _login,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: _isLoading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Text('Login'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
