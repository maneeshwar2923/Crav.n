import 'package:flutter/material.dart';

/// Design tokens converted from the Figma export / CSS tokens.
/// Use these throughout widgets for consistent spacing, radii, shadows and type sizes.

class Dimensions {
  // spacing
  static const double s2 = 2.0;
  static const double s4 = 4.0;
  static const double s6 = 6.0;
  static const double s8 = 8.0;
  static const double s12 = 12.0;
  static const double s16 = 16.0;
  static const double s24 = 24.0;
  static const double s32 = 32.0;

  // radii
  static const double radiusSm = 8.0;
  static const double radiusMd = 12.0;
  static const double radiusLg = 16.0;

  // common sizes
  static const double avatar = 40.0;
  static const double imageSmall = 56.0;
  static const double imageMedium = 72.0;
  static const double imageLarge = 96.0;

  // button paddings
  static const double buttonPaddingHorizontal = 16.0;
  static const double buttonPaddingVertical = 12.0;

  // typography (approximate, adjust to match Figma when fonts available)
  static const double fontSizeSm = 12.0;
  static const double fontSizeBase = 14.0;
  static const double fontSizeLg = 20.0;

  // canvas / breakpoints
  static const double mobileMaxWidth = 428.0;

  // shadows
  // Helper to create a color with the desired opacity using the
  // modern Color.withValues API (avoids precision-loss deprecations).
  static Color _withOpacity(Color color, double opacity) {
    final double a = (color.a * opacity).clamp(0.0, 1.0);
    return color.withValues(alpha: a);
  }

  static List<BoxShadow> boxShadowSmall(Color color) => [
        BoxShadow(
          color: _withOpacity(color, 0.08),
          offset: const Offset(0, 2),
          blurRadius: 8,
        ),
      ];

  static List<BoxShadow> boxShadowMedium(Color color) => [
        BoxShadow(
          color: _withOpacity(color, 0.15),
          offset: const Offset(0, 4),
          blurRadius: 12,
        ),
      ];
}
