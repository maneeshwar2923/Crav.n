import 'package:flutter/material.dart';

class BadgeWidget extends StatelessWidget {
  final Widget child;
  final String? label;

  const BadgeWidget({super.key, required this.child, this.label});

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        child,
        if (label != null)
          Positioned(
            right: -6,
            top: -6,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primary,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                label!,
                style: const TextStyle(color: Colors.white, fontSize: 12),
              ),
            ),
          ),
      ],
    );
  }
}
