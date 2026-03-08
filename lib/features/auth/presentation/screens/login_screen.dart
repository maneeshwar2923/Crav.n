import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../core/services/supabase_service.dart';
import '../../../../core/utils/error_utils.dart';
import '../../../../core/widgets/logo.dart';
import '../../../../routes/app_routes.dart';
import 'signup_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _loading = false;
  String? _error;
  bool _showPassword = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    _emailController.addListener(() {
      if (_error != null) {
        setState(() => _error = null);
      }
    });
    _passwordController.addListener(() {
      if (_error != null) {
        setState(() => _error = null);
      }
    });
  }

  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      FocusScope.of(context).unfocus();
      await SupabaseService.instance
          .signIn(_emailController.text.trim(), _passwordController.text);
      if (!mounted) return;
      Navigator.of(context).pushReplacementNamed(AppRoutes.home);
    } on AuthException catch (e) {
      setState(() => _error = e.message);
    } catch (e) {
      setState(() => _error = resolveDisplayError(e));
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _googleLogin() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      await SupabaseService.instance.signInWithGoogle();
      // On mobile the OAuth flow opens a browser; after redirect the app resumes.
      // We poll briefly for the session.
      for (int i = 0; i < 20; i++) {
        await Future.delayed(const Duration(milliseconds: 300));
        if (SupabaseService.instance.currentUser != null) break;
      }
      if (!mounted) return;
      if (SupabaseService.instance.currentUser != null) {
        Navigator.of(context).pushReplacementNamed(AppRoutes.home);
      } else {
        setState(() => _error =
            'Google sign-in not completed. Ensure Google provider enabled & redirect matches io.supabase.flutter://login-callback');
      }
    } on AuthException catch (e) {
      setState(() => _error = e.message);
    } catch (e) {
      setState(() => _error = resolveDisplayError(e));
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF0D2B2A),
              Color(0xFF0F4C3A),
              Color(0xFFE7F6EE),
            ],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 420),
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(24),
                    border:
                        Border.all(color: const Color(0xFFB8E1D9), width: 1.5),
                    boxShadow: [
                      BoxShadow(
                        blurRadius: 24,
                        color: Colors.black.withValues(alpha: 0.08),
                        offset: const Offset(0, 12),
                      ),
                    ],
                  ),
                  padding: const EdgeInsets.fromLTRB(24, 32, 24, 32),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        const Align(
                          alignment: Alignment.center,
                          child: CravnLogo(size: 72),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          'Welcome back',
                          style: theme.textTheme.headlineSmall?.copyWith(
                              fontWeight: FontWeight.w700,
                              color: const Color(0xFF104B3A)),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 6),
                        Text(
                          'Sign in to discover fresh home-made meals near you.',
                          style: theme.textTheme.bodyMedium
                              ?.copyWith(color: const Color(0xFF5C7470)),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 32),
                        TextFormField(
                          controller: _emailController,
                          keyboardType: TextInputType.emailAddress,
                          textInputAction: TextInputAction.next,
                          decoration: InputDecoration(
                            labelText: 'Email',
                            prefixIcon: const Icon(Icons.mail_outline),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                          ),
                          validator: (v) => v != null && v.contains('@')
                              ? null
                              : 'Enter a valid email',
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: _passwordController,
                          obscureText: !_showPassword,
                          textInputAction: TextInputAction.done,
                          onFieldSubmitted: (_) => _loading ? null : _login(),
                          decoration: InputDecoration(
                            labelText: 'Password',
                            prefixIcon: const Icon(Icons.lock_outline),
                            suffixIcon: IconButton(
                              icon: Icon(
                                _showPassword
                                    ? Icons.visibility_off_outlined
                                    : Icons.visibility_outlined,
                              ),
                              onPressed: () {
                                setState(() => _showPassword = !_showPassword);
                              },
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                          ),
                          validator: (v) => v != null && v.length >= 6
                              ? null
                              : 'Password must be at least 6 characters',
                        ),
                        if (_error != null) ...[
                          const SizedBox(height: 16),
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: const Color(0xFFFFE9E9),
                              borderRadius: BorderRadius.circular(14),
                              border:
                                  Border.all(color: const Color(0xFFFFB1B1)),
                            ),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Icon(Icons.warning_rounded,
                                    size: 20, color: Color(0xFFB3261E)),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    _error!,
                                    style: const TextStyle(
                                        color: Color(0xFFB3261E)),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                        const SizedBox(height: 24),
                        SizedBox(
                          height: 52,
                          child: ElevatedButton(
                            onPressed: _loading ? null : _login,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF006D3B),
                              foregroundColor: Colors.white,
                              textStyle: const TextStyle(
                                  fontSize: 16, fontWeight: FontWeight.w600),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(18),
                              ),
                            ),
                            child: _loading
                                ? const SizedBox(
                                    height: 22,
                                    width: 22,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2.3,
                                      valueColor:
                                          AlwaysStoppedAnimation(Colors.white),
                                    ),
                                  )
                                : const Text('Sign in'),
                          ),
                        ),
                        const SizedBox(height: 16),
                        SizedBox(
                          height: 52,
                          child: OutlinedButton(
                            onPressed: _loading ? null : _googleLogin,
                            style: OutlinedButton.styleFrom(
                              side: const BorderSide(color: Color(0xFFB8E1D9)),
                              foregroundColor: const Color(0xFF104B3A),
                              textStyle: const TextStyle(
                                  fontSize: 16, fontWeight: FontWeight.w600),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(18),
                              ),
                            ),
                            child: const Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.language, size: 22),
                                SizedBox(width: 12),
                                Text('Continue with Google'),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 24),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Text('New to Crav\'n?'),
                            TextButton(
                              onPressed: () async {
                                setState(() => _error = null);
                                final result =
                                    await Navigator.of(context).push<bool?>(
                                  MaterialPageRoute(
                                    builder: (_) => const SignUpScreen(),
                                  ),
                                );
                                if (!mounted) return;
                                if (result == true) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text(
                                          'Account created! Check your email to verify before signing in.'),
                                    ),
                                  );
                                }
                              },
                              child: const Text('Create an account'),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'By signing in you agree to our Terms of Service and acknowledge our Privacy Policy.',
                          textAlign: TextAlign.center,
                          style: theme.textTheme.bodySmall?.copyWith(
                              color: const Color(0xFF6A7A76), height: 1.4),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
