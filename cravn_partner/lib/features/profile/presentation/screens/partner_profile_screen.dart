import 'package:flutter/material.dart';
import '../../../../core/theme/colors.dart';
import '../../../../core/theme/dimensions.dart';
import '../../../../core/services/supabase_partner_service.dart';
import '../../../payouts/presentation/screens/payouts_screen.dart';
import 'kitchen_settings_screen.dart';
import 'reviews_screen.dart';
import 'add_edit_address_screen.dart';

class PartnerProfileScreen extends StatelessWidget {
  const PartnerProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: cravnBackground,
      body: ListView(
        padding: const EdgeInsets.all(Dimensions.s16),
        children: [
          const SizedBox(height: Dimensions.s16),
          _buildProfileHeader(),
          const SizedBox(height: Dimensions.s24),
          
          _SectionHeader(title: 'Business Management'),
          _ProfileOption(
            icon: Icons.attach_money,
            title: 'Payouts',
            subtitle: 'Withdraw earnings & view history',
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const PayoutsScreen()),
            ),
          ),
          _ProfileOption(
            icon: Icons.storefront_outlined,
            title: 'Kitchen Settings',
            subtitle: 'Opening hours & prep time',
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const KitchenSettingsScreen()),
            ),
          ),
          _ProfileOption(
            icon: Icons.star_outline,
            title: 'Reviews',
            subtitle: 'View & reply to customer feedback',
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const ReviewsScreen()),
            ),
          ),
          
          const SizedBox(height: Dimensions.s24),
          _SectionHeader(title: 'Account'),
          _ProfileOption(
            icon: Icons.location_on_outlined,
            title: 'Address Management',
            subtitle: 'Manage your pickup locations',
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const AddEditAddressScreen()),
            ),
          ),
          _ProfileOption(
            icon: Icons.logout,
            title: 'Sign Out',
            subtitle: 'Log out of your account',
            textColor: Colors.red,
            iconColor: Colors.red,
            onTap: () async {
              await SupabasePartnerService.instance.signOut();
            },
          ),
        ],
      ),
    );
  }

  Widget _buildProfileHeader() {
    return FutureBuilder<Map<String, dynamic>?>(
      future: SupabasePartnerService.instance.getProfile(),
      builder: (context, snapshot) {
        final profile = snapshot.data;
        final name = profile?['full_name'] ?? 'Partner';
        final email = SupabasePartnerService.instance.currentUser?.email ?? '';

        return Card(
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(Dimensions.radiusMd),
            side: BorderSide(color: Colors.grey[200]!),
          ),
          child: Padding(
            padding: const EdgeInsets.all(Dimensions.s16),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 30,
                  backgroundColor: cravnPrimary.withOpacity(0.1),
                  child: Text(
                    name.isNotEmpty ? name[0].toUpperCase() : 'P',
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: cravnPrimary,
                    ),
                  ),
                ),
                const SizedBox(width: Dimensions.s16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        name,
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        email,
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.title});
  final String title;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: Dimensions.s8, left: 4),
      child: Text(
        title,
        style: const TextStyle(
          fontWeight: FontWeight.bold,
          color: Colors.white,
          fontSize: 14,
        ),
      ),
    );
  }
}

class _ProfileOption extends StatelessWidget {
  const _ProfileOption({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
    this.textColor,
    this.iconColor,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;
  final Color? textColor;
  final Color? iconColor;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: Dimensions.s12),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(Dimensions.radiusMd),
        side: BorderSide(color: Colors.grey[200]!),
      ),
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: (iconColor ?? cravnPrimary).withOpacity(0.1),
            borderRadius: BorderRadius.circular(Dimensions.radiusSm),
          ),
          child: Icon(icon, color: iconColor ?? cravnPrimary),
        ),
        title: Text(
          title,
          style: TextStyle(
            fontWeight: FontWeight.w600,
            color: textColor,
          ),
        ),
        subtitle: Text(
          subtitle,
          style: TextStyle(fontSize: 12, color: Colors.grey[600]),
        ),
        trailing: const Icon(Icons.chevron_right, color: Colors.grey),
        onTap: onTap,
      ),
    );
  }
}
