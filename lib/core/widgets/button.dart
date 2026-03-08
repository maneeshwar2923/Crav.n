import 'package:flutter/material.dart';

// Lightweight wrapper for different button types
class CravnTextButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;

  const CravnTextButton({super.key, required this.label, this.onPressed});

  @override
  Widget build(BuildContext context) {
    return TextButton(onPressed: onPressed, child: Text(label));
  }
}
