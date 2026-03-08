import 'package:flutter/material.dart';

class ImageWithFallback extends StatelessWidget {
  final String imageUrl;
  final double width;
  final double height;
  final BoxFit fit;

  const ImageWithFallback({
    super.key,
    required this.imageUrl,
    this.width = 48,
    this.height = 48,
    this.fit = BoxFit.cover,
  });

  @override
  Widget build(BuildContext context) {
    if (imageUrl.isEmpty) {
      return Container(
        width: width,
        height: height,
        color: Colors.grey.shade200,
      );
    }

    return Image.network(imageUrl, width: width, height: height, fit: fit);
  }
}
