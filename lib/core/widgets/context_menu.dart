import 'package:flutter/material.dart';

class ContextMenuWidget extends StatelessWidget {
  final List<PopupMenuEntry> items;
  const ContextMenuWidget({super.key, required this.items});

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton(itemBuilder: (context) => items);
  }
}
