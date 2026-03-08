import 'package:flutter/material.dart';
import '../../../../core/services/supabase_admin_service.dart';
import '../../../../core/theme/colors.dart';
import '../../../hosts/presentation/screens/pending_hosts_screen.dart';
import '../../../listings/presentation/screens/all_listings_screen.dart';

class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({super.key});

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> {
  int _selectedIndex = 0;

  final List<Widget> _screens = [
    const PendingHostsScreen(),
    const AllListingsScreen(),
  ];

  void _handleSignOut() async {
    await SupabaseAdminService.instance.signOut();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: cravnBackground,
      appBar: AppBar(
        title: const Text('Crav\'n Admin'),
        backgroundColor: cravnBackground,
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.white),
            onPressed: _handleSignOut,
            tooltip: 'Sign Out',
          ),
        ],
      ),
      body: Row(
        children: [
          NavigationRail(
            backgroundColor: Colors.white,
            indicatorColor: cravnPrimary.withOpacity(0.1),
            selectedIndex: _selectedIndex,
            onDestinationSelected: (int index) {
              setState(() {
                _selectedIndex = index;
              });
            },
            labelType: NavigationRailLabelType.all,
            destinations: const [
              NavigationRailDestination(
                icon: Icon(Icons.people_outline),
                selectedIcon: Icon(Icons.people, color: cravnPrimary),
                label: Text('Hosts'),
              ),
              NavigationRailDestination(
                icon: Icon(Icons.restaurant_menu_outlined),
                selectedIcon: Icon(Icons.restaurant_menu, color: cravnPrimary),
                label: Text('Listings'),
              ),
            ],
          ),
          const VerticalDivider(thickness: 1, width: 1, color: Color(0xFFE0E0E0)),
          Expanded(
            child: _screens[_selectedIndex],
          ),
        ],
      ),
    );
  }
}
