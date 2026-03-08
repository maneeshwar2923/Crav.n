import 'package:flutter/material.dart';
import '../../../../core/theme/colors.dart';
import '../../../../core/theme/dimensions.dart';
import '../../../../core/services/supabase_partner_service.dart';
import '../../../dashboard/dashboard_screen.dart';

class PartnerOnboardingScreen extends StatefulWidget {
  const PartnerOnboardingScreen({super.key});

  @override
  State<PartnerOnboardingScreen> createState() => _PartnerOnboardingScreenState();
}

class _PartnerOnboardingScreenState extends State<PartnerOnboardingScreen> {
  final _formKey = GlobalKey<FormState>();
  final _kitchenNameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final PageController _pageController = PageController();
  
  int _currentStep = 0;
  bool _isLoading = false;
  String? _migratedPhone;
  
  final _steps = [
    'Welcome',
    'Kitchen Info',
    'Confirmation',
  ];

  @override
  void initState() {
    super.initState();
    _loadMigratedPhone();
  }

  Future<void> _loadMigratedPhone() async {
    // Load phone from user's Crav'n profile
    final profile = await SupabasePartnerService.instance.getProfile();
    if (profile != null && mounted) {
      setState(() {
        _migratedPhone = profile['phone_number'] as String?;
      });
    }
  }

  void _nextStep() {
    if (_currentStep < _steps.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  void _prevStep() {
    if (_currentStep > 0) {
      _pageController.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  Future<void> _completeOnboarding() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      // Update profile with kitchen name and mark as partner onboarded
      await SupabasePartnerService.instance.client
        .from('profiles')
        .update({
          'kitchen_name': _kitchenNameController.text.trim(),
          'is_partner_onboarded': true,
          'partner_onboarded_at': DateTime.now().toIso8601String(),
        })
        .eq('id', SupabasePartnerService.instance.currentUser!.id);

      if (mounted) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => const PartnerDashboardShell()),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: cravnBackground,
      body: SafeArea(
        child: Column(
          children: [
            // Progress indicator
            Padding(
              padding: const EdgeInsets.all(24),
              child: Row(
                children: List.generate(_steps.length, (index) {
                  return Expanded(
                    child: Container(
                      margin: EdgeInsets.only(right: index < _steps.length - 1 ? 8 : 0),
                      height: 4,
                      decoration: BoxDecoration(
                        color: index <= _currentStep 
                          ? Colors.white 
                          : Colors.white.withOpacity(0.3),
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  );
                }),
              ),
            ),
            
            // Pages
            Expanded(
              child: Form(
                key: _formKey,
                child: PageView(
                  controller: _pageController,
                  physics: const NeverScrollableScrollPhysics(),
                  onPageChanged: (index) => setState(() => _currentStep = index),
                  children: [
                    _buildWelcomeStep(),
                    _buildKitchenInfoStep(),
                    _buildConfirmationStep(),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWelcomeStep() {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.storefront, size: 50, color: Colors.white),
          ),
          const SizedBox(height: 32),
          const Text(
            'Welcome to Crav\'n Partner!',
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          Text(
            'Set up your kitchen profile and start sharing your culinary creations with the community.',
            style: TextStyle(
              fontSize: 16,
              color: Colors.white.withOpacity(0.8),
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          if (_migratedPhone != null) ...[
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.white.withOpacity(0.2)),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.check_circle, color: Colors.white, size: 20),
                  const SizedBox(width: 8),
                  Text(
                    'Phone: $_migratedPhone',
                    style: const TextStyle(color: Colors.white),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Your verified phone will be used for partner orders',
              style: TextStyle(fontSize: 12, color: Colors.white.withOpacity(0.6)),
            ),
          ],
          const Spacer(),
          SizedBox(
            width: double.infinity,
            height: 56,
            child: ElevatedButton(
              onPressed: _nextStep,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: cravnPrimary,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text('Get Started', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildKitchenInfoStep() {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Your Kitchen',
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Tell customers about your kitchen',
            style: TextStyle(
              fontSize: 16,
              color: Colors.white.withOpacity(0.8),
            ),
          ),
          const SizedBox(height: 32),
          
          // Kitchen Name
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
            ),
            child: TextFormField(
              controller: _kitchenNameController,
              style: const TextStyle(fontSize: 16, color: Colors.black87),
              decoration: InputDecoration(
                labelText: 'Kitchen Name',
                hintText: 'e.g., Green Bowl Kitchen',
                prefixIcon: Icon(Icons.storefront_outlined, color: Colors.grey[600]),
                border: InputBorder.none,
                contentPadding: const EdgeInsets.all(16),
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Please enter your kitchen name';
                }
                return null;
              },
            ),
          ),
          
          const SizedBox(height: 16),
          
          // Description
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
            ),
            child: TextFormField(
              controller: _descriptionController,
              style: const TextStyle(fontSize: 16, color: Colors.black87),
              maxLines: 4,
              decoration: InputDecoration(
                labelText: 'Description (optional)',
                hintText: 'Tell customers what makes your food special...',
                prefixIcon: Padding(
                  padding: const EdgeInsets.only(bottom: 60),
                  child: Icon(Icons.description_outlined, color: Colors.grey[600]),
                ),
                border: InputBorder.none,
                contentPadding: const EdgeInsets.all(16),
              ),
            ),
          ),
          
          const Spacer(),
          
          Row(
            children: [
              TextButton(
                onPressed: _prevStep,
                child: Text('Back', style: TextStyle(color: Colors.white.withOpacity(0.8))),
              ),
              const Spacer(),
              ElevatedButton(
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    _nextStep();
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: cravnPrimary,
                  padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text('Continue', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildConfirmationStep() {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.check, size: 50, color: Colors.white),
          ),
          const SizedBox(height: 32),
          const Text(
            'Ready to Go!',
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          
          // Summary card
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              children: [
                _buildSummaryRow(Icons.storefront, 'Kitchen', _kitchenNameController.text),
                if (_migratedPhone != null) ...[
                  const Divider(height: 24),
                  _buildSummaryRow(Icons.phone, 'Phone', _migratedPhone!),
                ],
              ],
            ),
          ),
          
          const Spacer(),
          
          SizedBox(
            width: double.infinity,
            height: 56,
            child: ElevatedButton(
              onPressed: _isLoading ? null : _completeOnboarding,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: cravnPrimary,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: _isLoading
                ? const SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Text('Start Hosting', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
            ),
          ),
          const SizedBox(height: 12),
          TextButton(
            onPressed: _prevStep,
            child: Text('Go Back', style: TextStyle(color: Colors.white.withOpacity(0.8))),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, color: cravnPrimary, size: 24),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: TextStyle(fontSize: 12, color: Colors.grey[600])),
              Text(value, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
            ],
          ),
        ),
      ],
    );
  }
  
  @override
  void dispose() {
    _kitchenNameController.dispose();
    _descriptionController.dispose();
    _pageController.dispose();
    super.dispose();
  }
}
