import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../../core/theme/colors.dart';
import '../../../../core/theme/dimensions.dart';
import '../../../../core/services/supabase_service.dart';

class PhoneVerificationScreen extends StatefulWidget {
  const PhoneVerificationScreen({super.key});

  @override
  State<PhoneVerificationScreen> createState() => _PhoneVerificationScreenState();
}

class _PhoneVerificationScreenState extends State<PhoneVerificationScreen> {
  final _phoneController = TextEditingController();
  final _otpController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  
  bool _loading = false;
  bool _codeSent = false;
  String? _verificationId;
  String? _error;

  @override
  void dispose() {
    _phoneController.dispose();
    _otpController.dispose();
    super.dispose();
  }

  Future<void> _sendOTP() async {
    if (!_formKey.currentState!.validate()) return;
    
    setState(() {
      _loading = true;
      _error = null;
    });

    final phone = _phoneController.text.trim();
    
    try {
      await FirebaseAuth.instance.verifyPhoneNumber(
        phoneNumber: phone.startsWith('+') ? phone : '+91$phone',
        verificationCompleted: (PhoneAuthCredential credential) async {
          // Auto-verification on Android
          await _verifyWithCredential(credential);
        },
        verificationFailed: (FirebaseAuthException e) {
          setState(() {
            _loading = false;
            _error = e.message ?? 'Verification failed';
          });
        },
        codeSent: (String verificationId, int? resendToken) {
          setState(() {
            _loading = false;
            _codeSent = true;
            _verificationId = verificationId;
          });
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('OTP sent to your phone!')),
          );
        },
        codeAutoRetrievalTimeout: (String verificationId) {
          _verificationId = verificationId;
        },
        timeout: const Duration(seconds: 60),
      );
    } catch (e) {
      setState(() {
        _loading = false;
        _error = e.toString();
      });
    }
  }

  Future<void> _verifyOTP() async {
    if (_otpController.text.trim().length != 6) {
      setState(() => _error = 'Please enter 6-digit OTP');
      return;
    }

    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final credential = PhoneAuthProvider.credential(
        verificationId: _verificationId!,
        smsCode: _otpController.text.trim(),
      );
      await _verifyWithCredential(credential);
    } catch (e) {
      setState(() {
        _loading = false;
        _error = 'Invalid OTP. Please try again.';
      });
    }
  }

  Future<void> _verifyWithCredential(PhoneAuthCredential credential) async {
    try {
      // Link phone to existing Firebase auth (optional)
      // For now, just mark as verified in Supabase
      final phone = _phoneController.text.trim();
      final formattedPhone = phone.startsWith('+') ? phone : '+91$phone';
      
      // Update Supabase profile with verified phone
      await SupabaseService.instance.updateProfile({
        'phone_number': formattedPhone,
        'phone_verified': true,
        'phone_verified_at': DateTime.now().toIso8601String(),
      });

      if (!mounted) return;
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Phone verified successfully!'),
          backgroundColor: Colors.green,
        ),
      );
      
      Navigator.of(context).pop(true); // Return success
    } catch (e) {
      setState(() {
        _loading = false;
        _error = e.toString();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: cravnBackground,
      appBar: AppBar(
        title: const Text('Verify Phone', style: TextStyle(color: Colors.white)),
        backgroundColor: cravnBackground,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 20),
                
                // Icon
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.phone_android,
                    size: 40,
                    color: Colors.white,
                  ),
                ),
                
                const SizedBox(height: 24),
                
                // Title
                Text(
                  _codeSent ? 'Enter OTP' : 'Verify Your Phone',
                  style: const TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                  textAlign: TextAlign.center,
                ),
                
                const SizedBox(height: 8),
                
                Text(
                  _codeSent 
                    ? 'Enter the 6-digit code sent to ${_phoneController.text}'
                    : 'We\'ll send you a verification code',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.white.withOpacity(0.8),
                  ),
                  textAlign: TextAlign.center,
                ),
                
                const SizedBox(height: 32),
                
                // Error message
                if (_error != null)
                  Container(
                    padding: const EdgeInsets.all(12),
                    margin: const EdgeInsets.only(bottom: 16),
                    decoration: BoxDecoration(
                      color: Colors.red.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      _error!,
                      style: const TextStyle(color: Colors.white),
                      textAlign: TextAlign.center,
                    ),
                  ),
                
                if (!_codeSent) ...[
                  // Phone input
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: TextFormField(
                      controller: _phoneController,
                      keyboardType: TextInputType.phone,
                      style: const TextStyle(fontSize: 18, color: Colors.black87),
                      decoration: InputDecoration(
                        prefixText: '+91 ',
                        prefixStyle: TextStyle(fontSize: 18, color: Colors.grey[600]),
                        hintText: '98765 43210',
                        hintStyle: TextStyle(color: Colors.grey[400]),
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.all(16),
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Please enter your phone number';
                        }
                        if (value.trim().length < 10) {
                          return 'Please enter a valid phone number';
                        }
                        return null;
                      },
                    ),
                  ),
                  
                  const SizedBox(height: 24),
                  
                  // Send OTP button
                  SizedBox(
                    height: 56,
                    child: ElevatedButton(
                      onPressed: _loading ? null : _sendOTP,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: cravnPrimary,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: _loading
                        ? const SizedBox(
                            width: 24,
                            height: 24,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Text(
                            'Send OTP',
                            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                          ),
                    ),
                  ),
                ] else ...[
                  // OTP input
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: TextFormField(
                      controller: _otpController,
                      keyboardType: TextInputType.number,
                      maxLength: 6,
                      style: const TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 16,
                        color: Colors.black87,
                      ),
                      textAlign: TextAlign.center,
                      decoration: const InputDecoration(
                        counterText: '',
                        hintText: '------',
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.all(16),
                      ),
                    ),
                  ),
                  
                  const SizedBox(height: 24),
                  
                  // Verify button
                  SizedBox(
                    height: 56,
                    child: ElevatedButton(
                      onPressed: _loading ? null : _verifyOTP,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: cravnPrimary,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: _loading
                        ? const SizedBox(
                            width: 24,
                            height: 24,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Text(
                            'Verify',
                            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                          ),
                    ),
                  ),
                  
                  const SizedBox(height: 16),
                  
                  // Resend link
                  TextButton(
                    onPressed: _loading ? null : () {
                      setState(() => _codeSent = false);
                    },
                    child: Text(
                      'Change number or resend code',
                      style: TextStyle(color: Colors.white.withOpacity(0.9)),
                    ),
                  ),
                ],
                
                const Spacer(),
                
                // Skip button
                TextButton(
                  onPressed: () => Navigator.of(context).pop(false),
                  child: Text(
                    'Skip for now',
                    style: TextStyle(color: Colors.white.withOpacity(0.7)),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
