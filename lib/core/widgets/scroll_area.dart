import 'package:flutter/material.dart';

class ScrollArea extends StatelessWidget {
  final Widget child;
  const ScrollArea({super.key, required this.child});

  @override
  Widget build(BuildContext context) => SingleChildScrollView(child: child);
}
