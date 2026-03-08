import 'package:flutter/material.dart';
import 'colors.dart';
import 'dimensions.dart';

ThemeData buildCravnAdminTheme() {
  final ColorScheme colorScheme = ColorScheme.fromSeed(
    seedColor: cravnPrimary,
    primary: cravnPrimary,
    secondary: cravnSecondary,
    surface: cravnBackground,
    error: cravnError,
    brightness: Brightness.light,
  );

  return ThemeData(
    // Use the bundled SF Pro Display font (registered in pubspec.yaml)
    fontFamily: 'SF Pro Display',
    colorScheme: colorScheme,
    useMaterial3: true,
    scaffoldBackgroundColor: cravnSurface, // Unified with User App
    appBarTheme: AppBarTheme(
      backgroundColor: cravnBackground,
      foregroundColor: cravnSecondary, // Partner app prefers dark green text
      elevation: 0,
      centerTitle: false, // Partner app usually left aligns
    ),
    // cardTheme: CardTheme(
    //   color: cravnBackground,
    //   elevation: 0, // Flat style with border or shadow
    //   shape: RoundedRectangleBorder(
    //     borderRadius: BorderRadius.circular(Dimensions.radiusMd),
    //     side: const BorderSide(color: Color(0xFFE0E0E0), width: 1),
    //   ),
    //   margin: EdgeInsets.zero,
    // ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: cravnPrimary,
        foregroundColor: cravnOnPrimary,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(Dimensions.radiusMd)),
        padding: const EdgeInsets.symmetric(
            horizontal: Dimensions.buttonPaddingHorizontal,
            vertical: Dimensions.buttonPaddingVertical),
        elevation: 0,
      ),
    ),
    textTheme: TextTheme(
      titleLarge: TextStyle(
          fontSize: Dimensions.fontSizeLg, fontWeight: FontWeight.w700, color: cravnSecondary),
      titleMedium: TextStyle(
          fontSize: 16, fontWeight: FontWeight.w600, color: cravnSecondary),
      bodyMedium: TextStyle(fontSize: Dimensions.fontSizeBase, color: Colors.black87),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: cravnBackground,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(Dimensions.radiusMd),
        borderSide: const BorderSide(color: Color(0xFFE0E0E0)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(Dimensions.radiusMd),
        borderSide: const BorderSide(color: Color(0xFFE0E0E0)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(Dimensions.radiusMd),
        borderSide: const BorderSide(color: cravnPrimary, width: 2),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
    ),
  );
}
