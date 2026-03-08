import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../core/services/supabase_service.dart';
import '../../../../core/utils/error_utils.dart';
import '../../../../core/widgets/logo.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _loading = false;
  bool _showPassword = false;
  String? _error;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    _emailController.addListener(_clearInlineError);
    _passwordController.addListener(_clearInlineError);
  }

  void _clearInlineError() {
    if (_error != null) {
      setState(() => _error = null);
    }
  }

  Future<void> _signup() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      FocusScope.of(context).unfocus();
      await SupabaseService.instance
          .signUp(_emailController.text.trim(), _passwordController.text);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Account created! Now verify your phone.')),
      );
      // Navigate to phone verification
      final verified = await Navigator.of(context).pushNamed('/phone-verify');
      if (!mounted) return;
      if (verified == true) {
        // Phone verified - go to home
        Navigator.of(context).pushNamedAndRemoveUntil('/', (route) => false);
      } else {
        // Skipped phone verification - still go to home
        Navigator.of(context).pushNamedAndRemoveUntil('/', (route) => false);
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
                    border:
                        Border.all(color: const Color(0xFFB8E1D9), width: 1.5),
                    borderRadius: BorderRadius.circular(24),
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
                          'Create your account',
                          style: Theme.of(context)
                              .textTheme
                              .headlineSmall
                              ?.copyWith(
                                  fontWeight: FontWeight.w700,
                                  color: const Color(0xFF104B3A)),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Verify your email to start sharing or rescuing surplus meals.',
                          textAlign: TextAlign.center,
                          style: Theme.of(context)
                              .textTheme
                              .bodyMedium
                              ?.copyWith(color: const Color(0xFF5C7470)),
                        ),
                        const SizedBox(height: 28),
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
                          onFieldSubmitted: (_) => _loading ? null : _signup(),
                          decoration: InputDecoration(
                            labelText: 'Password',
                            prefixIcon: const Icon(Icons.lock_outline),
                            suffixIcon: IconButton(
                              icon: Icon(
                                _showPassword
                                    ? Icons.visibility_off_outlined
                                    : Icons.visibility_outlined,
                              ),
                              onPressed: () => setState(
                                  () => _showPassword = !_showPassword),
                            ),
                            helperText: 'Minimum 6 characters',
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
                            onPressed: _loading ? null : _signup,
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
                                : const Text('Send verification link'),
                          ),
                        ),
                        const SizedBox(height: 16),
                        TextButton.icon(
                          onPressed: () => Navigator.of(context).pop(false),
                          icon: const Icon(Icons.arrow_back),
                          label: const Text('Back to sign in'),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'We will email you a verification link. Complete verification to access the community.',
                          textAlign: TextAlign.center,
                          style: Theme.of(context)
                              .textTheme
                              .bodySmall
                              ?.copyWith(
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
