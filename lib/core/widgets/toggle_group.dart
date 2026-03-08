import 'package:flutter/material.dart';

class ToggleGroup extends StatelessWidget {
  final List<Widget> children;
  const ToggleGroup({super.key, required this.children});

  @override
  Widget build(BuildContext context) => Row(children: children);
}
