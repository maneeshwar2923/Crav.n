import 'package:flutter/material.dart';

class CravnSwitch extends StatelessWidget {
  final bool value;
  final ValueChanged<bool>? onChanged;

  const CravnSwitch({super.key, required this.value, this.onChanged});

  @override
  Widget build(BuildContext context) =>
      Switch(value: value, onChanged: onChanged ?? (_) {});
}
