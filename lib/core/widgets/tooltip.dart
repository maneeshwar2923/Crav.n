import 'package:flutter/material.dart';

class TooltipWidget extends StatelessWidget {
  final String message;
  final Widget child;
  const TooltipWidget({super.key, required this.message, required this.child});

  @override
  Widget build(BuildContext context) => Tooltip(message: message, child: child);
}
