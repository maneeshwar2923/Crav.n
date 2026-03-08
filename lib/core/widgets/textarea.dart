import 'package:flutter/material.dart';

class CravnTextarea extends StatelessWidget {
  final TextEditingController? controller;
  final int maxLines;

  const CravnTextarea({super.key, this.controller, this.maxLines = 4});

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      maxLines: maxLines,
      decoration: const InputDecoration(),
    );
  }
}
