import 'package:flutter/material.dart';

import '../../../../core/theme/colors.dart';
import '../../../../core/theme/dimensions.dart';
import '../../../../core/extensions/iterable_extensions.dart';
import '../../../../core/models/user_address.dart';
import '../../../../core/services/supabase_service.dart';
import '../../../../routes/app_routes.dart';
import '../widgets/address_manager_sheet.dart';
import '../../../../features/profile/presentation/screens/manage_addresses_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  bool _loading = true;
  List<UserAddress> _addresses = [];
  List<Map<String, dynamic>> _orders = [];
  int _savedFoodGrams = 0;
  Map<String, dynamic>? _profile;
  final TextEditingController _phoneController = TextEditingController();
  bool _savingPhone = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    final service = SupabaseService.instance;
    final addressRows = await service.getUserAddresses();
    final orders = await service.getPastOrders();
    final grams = await service.getSavedFoodTotalGrams();
    final profile = await service.getProfile();
    if (!mounted) return;
    final phone = profile?['phone']?.toString() ?? '';
    setState(() {
      _addresses = addressRows.map(UserAddress.fromMap).toList();
      _orders = orders;
      _savedFoodGrams = grams;
      _profile = profile;
      _loading = false;
    });
    _phoneController.text = phone;
  }

  Future<void> _handleSignOut() async {
    await SupabaseService.instance.signOut();
    if (!mounted) return;
    ScaffoldMessenger.of(context)
        .showSnackBar(const SnackBar(content: Text('Signed out')));
    Navigator.of(context).pushNamedAndRemoveUntil(
      AppRoutes.login,
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = SupabaseService.instance.currentUser;
    return Scaffold(
      backgroundColor: cravnBackground,
      appBar: AppBar(
        title: const Text('Profile'),
        backgroundColor: Colors.white,
        foregroundColor: cravnSecondary,
        elevation: 0,
        actions: [
          if (user != null)
            IconButton(
              tooltip: 'Sign out',
              icon: const Icon(Icons.logout),
              onPressed: _handleSignOut,
            ),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator(color: cravnPrimary))
          : RefreshIndicator(
              color: cravnPrimary,
              onRefresh: _load,
              child: ListView(
                padding: const EdgeInsets.all(20),
                children: [
                  _buildHeader(user?.email),
                  const SizedBox(height: 16),
                  _buildStats(),
                  const SizedBox(height: 20),
                  _buildContactCard(),
                  const SizedBox(height: 20),
                  _buildAddressSection(),
                  const SizedBox(height: 20),
                  _buildOrdersSection(),
                  const SizedBox(height: 20),
                  _buildSupportSection(),
                ],
              ),
            ),
    );
  }

  Widget _buildHeader(String? email) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(Dimensions.radiusMd),
        boxShadow: Dimensions.boxShadowSmall(Colors.black),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 28,
            backgroundColor: const Color(0xFF006D3B),
            child: Text(
              (email ?? 'Guest').substring(0, 1).toUpperCase(),
              style: const TextStyle(color: Colors.white, fontSize: 24),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  email ?? 'Guest user',
                  style: const TextStyle(
                      fontSize: 18, fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 4),
                Text(
                  'Member since ${_formatJoinDate()}',
                  style: const TextStyle(color: Color(0xFF5C7470)),
                ),
                if (email == null) ...[
                  const SizedBox(height: 12),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: cravnPrimary,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(Dimensions.radiusMd),
                      ),
                    ),
                    onPressed: () => Navigator.of(context)
                        .pushNamedAndRemoveUntil(
                            AppRoutes.login, (route) => false),
                    child: const Text('Sign in to sync'),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _formatJoinDate() {
    final user = SupabaseService.instance.currentUser;
    final createdAtIso = user?.createdAt;
    if (createdAtIso == null) return 'today';
    final timestamp = DateTime.tryParse(createdAtIso);
    if (timestamp == null) return 'today';
    return '${timestamp.year}-${timestamp.month.toString().padLeft(2, '0')}-${timestamp.day.toString().padLeft(2, '0')}';
  }

  Widget _buildStats() {
    final savedKg = (_savedFoodGrams / 1000).toStringAsFixed(1);
    return Row(
      children: [
        _StatCard(
          icon: Icons.eco_outlined,
          title: 'Food saved',
          value: '$savedKg kg',
          accent: const Color(0xFF0F9D58),
        ),
        const SizedBox(width: 12),
        _StatCard(
          icon: Icons.favorite_outline,
          title: 'Saved meals',
          value: _orders.length.toString(),
          accent: const Color(0xFFFB8C00),
        ),
      ],
    );
  }

  Widget _buildContactCard() {
    final phoneMissing = _phoneController.text.trim().isEmpty;
    final hostStatus = _profile?['host_status']?.toString();
    final hostVerified = _profile?['host_verified'] == true;
    return Container(
      decoration: BoxDecoration(
         color: Colors.white,
         borderRadius: BorderRadius.circular(Dimensions.radiusMd),
         boxShadow: Dimensions.boxShadowSmall(Colors.black),
      ),
      padding: const EdgeInsets.all(Dimensions.s16),
      child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.phone_iphone, color: cravnPrimary),
                const SizedBox(width: 8),
                const Text(
                  'Contact details',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                ),
                const Spacer(),
                if (_savingPhone)
                  const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(strokeWidth: 2, color: cravnPrimary),
                  ),
              ],
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _phoneController,
              keyboardType: TextInputType.phone,
              decoration: InputDecoration(
                labelText: 'Phone number',
                hintText: '+91 98765 43210',
                labelStyle: const TextStyle(color: cravnPrimary),
                focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(Dimensions.radiusMd),
                    borderSide: const BorderSide(color: cravnPrimary, width: 2),
                ),
                helperText:
                    phoneMissing ? 'Required for pickup coordination' : null,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(Dimensions.radiusMd),
                ),
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _savingPhone ? null : _savePhoneNumber,
                icon: const Icon(Icons.save_outlined),
                label: const Text('Save contact number'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: cravnPrimary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(Dimensions.radiusMd)),
                ),
              ),
            ),
            if (hostStatus != null)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Row(
                  children: [
                    Icon(
                      hostVerified ? Icons.verified : Icons.pending_outlined,
                      size: 18,
                      color: hostVerified
                          ? const Color(0xFF0F9D58)
                          : const Color(0xFFF9A825),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      'Partner status: ${hostStatus.toUpperCase()}',
                      style: const TextStyle(color: Color(0xFF5C7470)),
                    ),
                  ],
                ),
              ),
          ],
        ),
    );
  }

  Future<void> _savePhoneNumber() async {
    final phone = _phoneController.text.trim();
    if (phone.isEmpty) {
      setState(() {});
      return;
    }
    setState(() => _savingPhone = true);
    final updated =
        await SupabaseService.instance.updateProfile({'phone': phone});
    if (!mounted) return;
    setState(() {
      _profile = updated ?? _profile;
      _savingPhone = false;
    });
    ScaffoldMessenger.of(context)
        .showSnackBar(const SnackBar(content: Text('Phone number saved.')));
  }

  Widget _buildAddressSection() {

    return Container(
      decoration: BoxDecoration(
         color: Colors.white,
         borderRadius: BorderRadius.circular(Dimensions.radiusMd),
         boxShadow: Dimensions.boxShadowSmall(Colors.black),
      ),
      padding: const EdgeInsets.all(Dimensions.s16),
      child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.location_on_outlined,
                    color: Color(0xFF006D3B)),
                const SizedBox(width: 8),
                const Text(
                  'Addresses',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                ),
                const Spacer(),
                TextButton(
                  onPressed: () async {
                    await Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (_) => const ManageAddressesScreen()),
                    );
                    await _load();
                  },
                  child: const Text('Manage'),
                ),
              ],
            ),
            const SizedBox(height: 12),
            if (_addresses.isEmpty)
              const Text('No saved addresses. Add one to speed up checkout.')
            else
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: _addresses.map((address) {
                  final isPrimary = address.isDefault;
                  return Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: isPrimary
                            ? const Color(0xFF006D3B)
                            : const Color(0xFFE0E0E0),
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(
                              address.label,
                              style:
                                  const TextStyle(fontWeight: FontWeight.w600),
                            ),
                            if (isPrimary) ...[
                              const SizedBox(width: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(
                                  color: const Color(0xFF006D3B),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: const Text(
                                  'Default',
                                  style: TextStyle(
                                      color: Colors.white, fontSize: 11),
                                ),
                              ),
                            ],
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text([
                          address.addressLine1,
                          address.addressLine2,
                          address.city
                        ]
                            .where((element) => (element ?? '').isNotEmpty)
                            .join(', ')),
                      ],
                    ),
                  );
                }).toList(),
              ),
          ],
        ),
      ),
    )
  }

  Widget _buildOrdersSection() {
    if (_orders.isEmpty) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(Dimensions.radiusMd),
           boxShadow: Dimensions.boxShadowSmall(Colors.black),
        ),
        child: const Text('You have no past orders yet. Rescue a meal to see it here.'),
      );
    }

    return Container(
       decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(Dimensions.radiusMd),
           boxShadow: Dimensions.boxShadowSmall(Colors.black),
       ),
       padding: const EdgeInsets.all(Dimensions.s16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
            const Text('Recent orders',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
            const SizedBox(height: 12),
            ..._orders.take(5).map((order) {
              final listing = order['food_listings'] as Map<String, dynamic>?;
              return ListTile(
                contentPadding: EdgeInsets.zero,
                leading: CircleAvatar(
                  backgroundColor: const Color(0xFFE7F6EE),
                  backgroundImage: listing?['image'] != null
                      ? NetworkImage(listing!['image'] as String)
                      : null,
                  child: listing?['image'] == null
                      ? const Icon(Icons.fastfood_outlined,
                          color: Color(0xFF006D3B))
                      : null,
                ),
                title: Text(listing?['title'] ?? 'Listing'),
                subtitle: Text(
                    'Status: ${order['status']} â€¢ Qty: ${order['quantity']}'),
                trailing: Text(_formatDate(order['placed_at'])),
              );
            }),
          ],
        ),
      ),
    )
  }

  Widget _buildSupportSection() {
    return Container(
      decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(Dimensions.radiusMd),
           boxShadow: Dimensions.boxShadowSmall(Colors.black),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: const [
          ListTile(
            leading: Icon(Icons.help_outline),
            title: Text('Support & FAQs'),
            subtitle: Text('Browse answers to common questions'),
          ),
          Divider(height: 1),
          ListTile(
            leading: Icon(Icons.mail_outline),
            title: Text('Email support'),
            subtitle: Text('support@cravn.app'),
          ),
          Divider(height: 1),
          ListTile(
            leading: Icon(Icons.policy_outlined),
            title: Text('Privacy & terms'),
            subtitle: Text('Understand how we protect your data'),
          ),
        ],
      ),
    );
  }

  String _formatDate(dynamic value) {
    if (value is String) {
      final date = DateTime.tryParse(value);
      if (date != null) {
        return '${date.day}/${date.month}/${date.year}';
      }
    }
    return '';
  }
}

class _StatCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String value;
  final Color accent;

  const _StatCard({
    required this.icon,
    required this.title,
    required this.value,
    required this.accent,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(Dimensions.radiusMd),
          border: Border.all(color: const Color(0xFFE0E0E0)),
          boxShadow: Dimensions.boxShadowSmall(Colors.black),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: accent),
            const SizedBox(height: 12),
            Text(
              value,
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 4),
            Text(
              title,
              style: const TextStyle(color: Color(0xFF5C7470)),
            ),
          ],
        ),
      ),
    );
  }
}
