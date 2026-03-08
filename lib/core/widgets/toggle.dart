import 'package:flutter/material.dart';

class ToggleWidget extends StatelessWidget {
  final bool value;
  final ValueChanged<bool>? onChanged;

  const ToggleWidget({super.key, required this.value, this.onChanged});

  @override
  Widget build(BuildContext context) =>
      Switch(value: value, onChanged: onChanged ?? (_) {});
}
