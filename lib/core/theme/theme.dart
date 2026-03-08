import 'package:flutter/material.dart';
import 'colors.dart';
import 'dimensions.dart';

ThemeData buildCravnTheme() {
  final ColorScheme colorScheme = ColorScheme.fromSeed(
    seedColor: cravnPrimary,
    primary: cravnPrimary,
    // 'background' parameter is deprecated in newer Flutter; use 'surface' where appropriate
    surface: cravnBackground,
    brightness: Brightness.light,
  );

  return ThemeData(
    // Use the bundled SF Pro Display font (registered in pubspec.yaml)
    fontFamily: 'SF Pro Display',
    colorScheme: colorScheme,
    useMaterial3: true,
    scaffoldBackgroundColor: cravnBackground,
    appBarTheme: AppBarTheme(
      backgroundColor: cravnBackground,
      foregroundColor: Colors.white,
      elevation: 0,
      centerTitle: true,
      iconTheme: const IconThemeData(color: Colors.white),
      titleTextStyle: const TextStyle(
        color: Colors.white,
        fontSize: 20,
        fontWeight: FontWeight.w600,
        fontFamily: 'SF Pro Display',
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.white,
        foregroundColor: cravnPrimary,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(Dimensions.radiusMd)),
        padding: const EdgeInsets.symmetric(
            horizontal: Dimensions.buttonPaddingHorizontal,
            vertical: Dimensions.buttonPaddingVertical),
      ),
    ),
    cardTheme: const CardThemeData(
      color: Colors.white,
      elevation: 2,
    ),
    textTheme: TextTheme(
      titleLarge: const TextStyle(
          fontSize: 24, fontWeight: FontWeight.w700, color: cravnTextPrimary),
      titleMedium: const TextStyle(
          fontSize: 18, fontWeight: FontWeight.w600, color: cravnTextPrimary),
      bodyMedium: TextStyle(fontSize: 14, color: Colors.grey[800]),
      bodyLarge: TextStyle(fontSize: 16, color: Colors.grey[800]),
    ),
  );
}
