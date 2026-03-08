import 'package:flutter/material.dart';

class CravnCheckbox extends StatelessWidget {
  final bool value;
  final ValueChanged<bool?>? onChanged;

  const CravnCheckbox({super.key, required this.value, this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Checkbox(value: value, onChanged: onChanged);
  }
}
