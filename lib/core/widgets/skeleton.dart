import 'package:flutter/material.dart';

class SkeletonBox extends StatelessWidget {
  final double width;
  final double height;

  const SkeletonBox({
    super.key,
    this.width = double.infinity,
    this.height = 12,
  });

  @override
  Widget build(BuildContext context) {
    return Container(width: width, height: height, color: Colors.grey.shade200);
  }
}
