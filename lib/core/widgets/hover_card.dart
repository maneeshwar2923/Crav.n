import 'package:flutter/material.dart';

class HoverCard extends StatelessWidget {
  final Widget child;
  const HoverCard({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: Card(child: child),
    );
  }
}
