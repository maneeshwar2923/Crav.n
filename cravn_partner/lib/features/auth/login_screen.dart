import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../core/services/supabase_config.dart';
import '../../core/services/supabase_partner_service.dart';
import '../../core/utils/error_utils.dart';
import '../../shared/widgets/cravn_logo.dart';

class PartnerLoginScreen extends StatefulWidget {
  const PartnerLoginScreen({super.key, this.onSignedIn});

  final VoidCallback? onSignedIn;

  @override
  State<PartnerLoginScreen> createState() => _PartnerLoginScreenState();
}

class _PartnerLoginScreenState extends State<PartnerLoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscure = true;
  bool _loading = false;
  String? _error;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final form = _formKey.currentState;
    if (form == null) return;
    if (!form.validate()) return;

    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      await SupabasePartnerService.instance.signIn(
          _emailController.text.trim(), _passwordController.text.trim());
      widget.onSignedIn?.call();
    } on AuthException catch (e) {
      setState(() => _error = e.message);
    } catch (e) {
      final message = resolveDisplayError(
        e,
        fallback: 'Unable to sign in right now. ($e)',
      );
      setState(() => _error = message);
    } finally {
      if (mounted) {
        setState(() => _loading = false);
      }
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
            colors: [Color(0xFFF2FBF4), Color(0xFFE4F4E8)],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const CravnLogo(size: 80),
                  const SizedBox(height: 12),
                  Text(
                    "Crav'n Partner",
                    style: theme.textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFF1B4332),
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 6),
                  const Text(
                    'Verified hosts manage orders, reviews, and food safety here.',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Color(0xFF4C6A5A)),
                  ),
                  const SizedBox(height: 32),
                  if (SupabaseConfig.usingFallbackCredentials) ...[
                    ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 420),
                      child: Card(
                        color: const Color(0xFFFFF6E5),
                        elevation: 0,
                        margin: EdgeInsets.zero,
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: const [
                              Icon(
                                Icons.warning_amber_rounded,
                                color: Color(0xFF8A6D3B),
                              ),
                              SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  'Add SUPABASE_URL and SUPABASE_ANON_KEY to cravn_partner/assets/env/.env or pass them with --dart-define before signing in.',
                                  style: TextStyle(
                                    color: Color(0xFF5C4F32),
                                    height: 1.3,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                  ],
                  ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 420),
                    child: Card(
                      elevation: 3,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 24,
                          vertical: 28,
                        ),
                        child: Form(
                          key: _formKey,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                'Sign in',
                                style: theme.textTheme.titleLarge?.copyWith(
                                  fontWeight: FontWeight.w700,
                                  color: const Color(0xFF1B4332),
                                ),
                              ),
                              const SizedBox(height: 4),
                              const Text(
                                'Use the credentials from your Crav\'n onboarding email.',
                                style: TextStyle(color: Color(0xFF5C7470)),
                              ),
                              const SizedBox(height: 24),
                              TextFormField(
                                controller: _emailController,
                                enabled: !_loading,
                                decoration: const InputDecoration(
                                  labelText: 'Work email',
                                  hintText: 'chef@yourkitchen.com',
                                ),
                                keyboardType: TextInputType.emailAddress,
                                validator: (value) {
                                  final text = value?.trim() ?? '';
                                  if (text.isEmpty) {
                                    return 'Enter your email';
                                  }
                                  if (!text.contains('@')) {
                                    return 'Enter a valid email';
                                  }
                                  return null;
                                },
                              ),
                              const SizedBox(height: 16),
                              TextFormField(
                                controller: _passwordController,
                                enabled: !_loading,
                                obscureText: _obscure,
                                decoration: InputDecoration(
                                  labelText: 'Password',
                                  suffixIcon: IconButton(
                                    icon: Icon(
                                      _obscure
                                          ? Icons.visibility_outlined
                                          : Icons.visibility_off_outlined,
                                    ),
                                    onPressed: () =>
                                        setState(() => _obscure = !_obscure),
                                  ),
                                ),
                                validator: (value) {
                                  final text = value ?? '';
                                  if (text.length < 6) {
                                    return 'Password must be at least 6 characters';
                                  }
                                  return null;
                                },
                              ),
                              if (_error != null) ...[
                                const SizedBox(height: 12),
                                Text(
                                  _error!,
                                  style:
                                      const TextStyle(color: Color(0xFFD32F2F)),
                                ),
                              ],
                              const SizedBox(height: 24),
                              SizedBox(
                                width: double.infinity,
                                child: ElevatedButton(
                                  onPressed: _loading ? null : _submit,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: const Color(0xFF006D3B),
                                    foregroundColor: Colors.white,
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 14),
                                  ),
                                  child: _loading
                                      ? const SizedBox(
                                          width: 18,
                                          height: 18,
                                          child: CircularProgressIndicator(
                                            strokeWidth: 2,
                                            valueColor:
                                                AlwaysStoppedAnimation<Color>(
                                                    Colors.white),
                                          ),
                                        )
                                      : const Text('Sign in'),
                                ),
                              ),
                              const SizedBox(height: 16),
                              const Text(
                                'Need access? Email onboarding@cravn.app from your registered account.',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Color(0xFF5C7470),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
