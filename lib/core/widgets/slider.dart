import 'package:flutter/material.dart';

class CravnSlider extends StatelessWidget {
  final double value;
  final ValueChanged<double>? onChanged;

  const CravnSlider({super.key, this.value = 0, this.onChanged});

  @override
  Widget build(BuildContext context) =>
      Slider(value: value, onChanged: onChanged ?? (_) {});
}
