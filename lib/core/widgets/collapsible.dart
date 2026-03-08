import 'package:flutter/material.dart';

class Collapsible extends StatefulWidget {
  final Widget header;
  final Widget child;

  const Collapsible({super.key, required this.header, required this.child});

  @override
  State<Collapsible> createState() => _CollapsibleState();
}

class _CollapsibleState extends State<Collapsible> {
  bool _open = false;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        GestureDetector(
          onTap: () => setState(() => _open = !_open),
          child: widget.header,
        ),
        if (_open) widget.child,
      ],
    );
  }
}
