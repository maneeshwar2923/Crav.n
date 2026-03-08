import 'package:flutter/material.dart';

class CravnProgress extends StatelessWidget {
  final double value;
  const CravnProgress({super.key, this.value = 0});

  @override
  Widget build(BuildContext context) => LinearProgressIndicator(value: value);
}
