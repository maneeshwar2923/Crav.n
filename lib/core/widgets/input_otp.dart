import 'package:flutter/material.dart';

class OtpInput extends StatelessWidget {
  final int length;

  const OtpInput({super.key, this.length = 4});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(
        length,
        (_) => Container(
          width: 40,
          height: 48,
          margin: const EdgeInsets.all(4),
          color: Colors.grey.shade200,
        ),
      ),
    );
  }
}
