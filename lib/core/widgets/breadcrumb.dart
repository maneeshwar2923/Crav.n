import 'package:flutter/material.dart';

class Breadcrumb extends StatelessWidget {
  final List<String> items;
  const Breadcrumb({super.key, required this.items});

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      children: items
          .map((e) => Text(e, style: Theme.of(context).textTheme.bodyMedium))
          .toList(),
    );
  }
}
