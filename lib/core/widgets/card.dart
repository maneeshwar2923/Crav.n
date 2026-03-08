import 'package:flutter/material.dart';

class CravnCard extends StatelessWidget {
  final Widget child;
  const CravnCard({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: child,
    );
  }
}
