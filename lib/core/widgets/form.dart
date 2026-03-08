import 'package:flutter/material.dart';

class CravnForm extends StatelessWidget {
  final Widget child;
  const CravnForm({super.key, required this.child});

  @override
  Widget build(BuildContext context) => Form(child: child);
}
