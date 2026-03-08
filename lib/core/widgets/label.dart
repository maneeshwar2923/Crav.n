import 'package:flutter/material.dart';

class LabelWidget extends StatelessWidget {
  final String text;
  const LabelWidget({super.key, required this.text});

  @override
  Widget build(BuildContext context) =>
      Text(text, style: Theme.of(context).textTheme.bodyMedium);
}
