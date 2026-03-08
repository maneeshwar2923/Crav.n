import 'package:flutter/material.dart';

class Menubar extends StatelessWidget {
  const Menubar({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: const [
        Text('Menu Item 1'),
        SizedBox(width: 12),
        Text('Menu Item 2'),
      ],
    );
  }
}
