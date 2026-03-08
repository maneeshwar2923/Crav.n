import 'package:flutter/material.dart';
import 'image_with_fallback.dart';

class Avatar extends StatelessWidget {
  final String imageUrl;
  final double size;

  const Avatar({super.key, required this.imageUrl, this.size = 40});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(size / 2),
      child: ImageWithFallback(imageUrl: imageUrl, width: size, height: size),
    );
  }
}
