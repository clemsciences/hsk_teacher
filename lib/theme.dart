import 'package:flutter/material.dart';

class AppTheme {
  // Colors
  static const Color primaryColor = Colors.blueAccent;
  static final Color primaryColorLight = Colors.blueAccent.withValues(alpha: 0.1);
  static const Color secondaryColor = Colors.blue;
  static final Color secondaryColorLight = Colors.blue.withValues(alpha: 0.1);
  static final Color? textSecondaryColor = Colors.grey[700];
  static const Color errorColor = Colors.redAccent;
  static const Color white = Colors.white;

  // Shapes & Sizes
  static const double borderRadiusValue = 20.0;
  static final BorderRadius borderRadius = BorderRadius.circular(borderRadiusValue);
  static const double cardElevation = 4.0;
  static const double defaultPadding = 16.0;
  static const double largePadding = 24.0;
  static const double extraLargePadding = 32.0;

  // Text Styles (optional but helpful)
  static const double hanziFontSizeLarge = 100.0;
  static const double hanziFontSizeCompact = 60.0;

  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: primaryColor,
        primary: primaryColor,
        secondary: secondaryColor,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: primaryColor,
        foregroundColor: white,
        elevation: 0,
        centerTitle: true,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
      cardTheme: CardThemeData(
        elevation: cardElevation,
        shape: RoundedRectangleBorder(
          borderRadius: borderRadius,
        ),
      ),
      dataTableTheme: DataTableThemeData(
        headingTextStyle: const TextStyle(
          fontWeight: FontWeight.bold,
          color: primaryColor,
        ),
        dataRowMinHeight: 48,
        dataRowMaxHeight: double.infinity,
      ),
    );
  }
}
