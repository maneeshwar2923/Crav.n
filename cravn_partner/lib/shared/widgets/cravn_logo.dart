import 'package:flutter/widgets.dart';

/// Lightweight copy of the consumer logo widget so the partner app
/// can reuse the shared brand asset without duplicating styling.
class CravnLogo extends StatelessWidget {
  const CravnLogo(
      {super.key, this.size, this.height = 40, this.fit = BoxFit.contain, this.color});

  final double? size;
  final double? height;
  final BoxFit fit;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final resolvedHeight = size ?? height;
    return Image.asset(
      'assets/Images/Logo.png',
      height: resolvedHeight,
      fit: fit,
      color: color,
    );
  }
}
