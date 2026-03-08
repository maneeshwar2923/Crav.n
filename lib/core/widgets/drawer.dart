import 'package:flutter/material.dart';

class CravnDrawer extends StatelessWidget {
  const CravnDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: const [
          DrawerHeader(child: Text('Menu')),
          ListTile(title: Text('Home')),
          ListTile(title: Text('Profile')),
        ],
      ),
    );
  }
}
