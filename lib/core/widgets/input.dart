import 'package:flutter/material.dart';

class CravnInput extends StatelessWidget {
  final TextEditingController? controller;
  final String? hint;

  const CravnInput({super.key, this.controller, this.hint});

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      decoration: InputDecoration(hintText: hint),
    );
  }
}
