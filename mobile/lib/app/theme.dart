import 'package:flutter/material.dart';

class AppTheme {
  // Цвета
  static const Color backgroundColor = Color(0xFFF5F4F2);
  static const Color cardColor = Colors.white;
  static const Color controlsColor = Color(0xFFE6E5E2);
  static const Color primaryColor = Color(0xFF007AFF);
  static const Color textPrimary = Colors.black;
  static const Color textSecondary = Color(0xFF8E8E93);
  static const Color borderColor = Color(0xFFE5E5EA);
  
  // Статусные цвета для бейджей
  static const Color statusGreen = Color(0xFF34C759);
  static const Color statusRed = Color(0xFFFF3B30);
  static const Color statusOrange = Color(0xFFFF9500);
  static const Color statusBlue = Color(0xFF007AFF);

  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      scaffoldBackgroundColor: backgroundColor,
      colorScheme: ColorScheme.fromSeed(
        seedColor: primaryColor,
        surface: backgroundColor,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: backgroundColor,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: TextStyle(
          color: textPrimary,
          fontSize: 17,
          fontWeight: FontWeight.w600,
        ),
        iconTheme: IconThemeData(color: textPrimary),
      ),
      cardTheme: CardThemeData(
        color: cardColor,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }
}
