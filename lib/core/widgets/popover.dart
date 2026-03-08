import 'package:flutter/material.dart';

class Popover extends StatelessWidget {
  final Widget child;
  const Popover({super.key, required this.child});

  @override
  Widget build(BuildContext context) => Tooltip(message: '', child: child);
}
