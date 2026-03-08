import 'package:flutter/material.dart';
import 'colors.dart';
import 'dimensions.dart';

ThemeData buildCravnPartnerTheme() {
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
    scaffoldBackgroundColor: cravnBackground, // Green Background
    appBarTheme: const AppBarTheme(
      backgroundColor: cravnBackground,
      foregroundColor: cravnTextPrimary, // White text
      elevation: 0,
      centerTitle: false,
      iconTheme: IconThemeData(color: cravnTextPrimary),
    ),
    cardTheme: CardThemeData(
      color: cravnSurface, // White Cards
      elevation: 0,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(Dimensions.radiusMd),
      ),
    ),
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
    textTheme: const TextTheme(
      titleLarge: TextStyle(
          fontSize: Dimensions.fontSizeLg, fontWeight: FontWeight.w700, color: cravnTextOnSurface),
      titleMedium: TextStyle(
          fontSize: 16, fontWeight: FontWeight.w600, color: cravnTextOnSurface),
      bodyMedium: TextStyle(fontSize: Dimensions.fontSizeBase, color: cravnTextOnSurface),
      bodyLarge: TextStyle(fontSize: Dimensions.fontSizeLg, color: cravnTextOnSurface),
      bodySmall: TextStyle(fontSize: Dimensions.fontSizeSm, color: Colors.black54),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: cravnSurface, // White inputs
      labelStyle: const TextStyle(color: Colors.black54), // Dark label on white input
      hintStyle: const TextStyle(color: Colors.black38),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(Dimensions.radiusMd),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(Dimensions.radiusMd),
        borderSide: BorderSide(color: Colors.grey.shade300),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(Dimensions.radiusMd),
        borderSide: const BorderSide(color: cravnSecondary, width: 2),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
    ),
    iconTheme: const IconThemeData(color: cravnTextOnSurface),
  );
}
