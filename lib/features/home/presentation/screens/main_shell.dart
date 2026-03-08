import 'package:flutter/material.dart';
import '../../../../core/widgets/bottom_nav.dart';
import 'home_screen.dart';
import 'map_view_screen.dart';
import 'orders_screen.dart';
import 'profile_screen.dart';

/// Main navigation shell with bottom navigation to mirror the web app tabs.
class MainShell extends StatefulWidget {
  const MainShell({super.key});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int _index = 0;

  final _pages = const [
    HomeScreen(),
    MapViewScreen(),
    OrdersScreen(), // mirrors "messages" tab routing to orders in web
    ProfileScreen(),
  ];

  void _onTap(int i) {
    setState(() => _index = i);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(index: _index, children: _pages),
      bottomNavigationBar: CravnBottomNav(currentIndex: _index, onTap: _onTap),
    );
  }
}
