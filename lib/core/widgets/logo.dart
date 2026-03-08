import 'package:flutter/widgets.dart';

/// Cravn logo widget that uses the bundled asset at `assets/images/Logo.png`.
///
/// Supports both `height` (named) and `size` (alias) to match existing usages
/// across the codebase (some files call `CravnLogo(size: 80)`). `size` will
/// take precedence when provided.
class CravnLogo extends StatelessWidget {
  /// Preferred explicit size (pixels). If provided, this is used as the image
  /// height. This parameter mirrors an older API used elsewhere.
  final double? size;

  /// Fallback height if [size] is not provided.
  final double? height;

  /// How to inscribe the image into the space allocated during layout.
  final BoxFit fit;

  const CravnLogo(
      {Key? key, this.size, this.height = 32.0, this.fit = BoxFit.contain})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    final double? usedHeight = size ?? height;
    return Image.asset(
      'assets/Images/Logo.png',
      height: usedHeight,
      fit: fit,
    );
  }
}
