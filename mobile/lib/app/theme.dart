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

  // Текстовые стили
  static const TextStyle headlineLarge = TextStyle(
    fontSize: 24,
    fontWeight: FontWeight.w500,
    color: textPrimary,
    fontFamily: 'Yandex Sans Text',
    height: 0.83, // 20px line height / 24px font size
    letterSpacing: -0.5,
  );

  static const TextStyle YandexSansMedium = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w400,
    color: textPrimary,
    fontFamily: 'Yandex Sans Text',
  );

  static const TextStyle labelMedium = TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.w500,
    color: textSecondary,
    fontFamily: 'Yandex Sans Text',
  );

  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      scaffoldBackgroundColor: backgroundColor,
      colorScheme: ColorScheme.fromSeed(
        seedColor: primaryColor,
        surface: backgroundColor,
      ),
      textTheme: const TextTheme(
        headlineLarge: headlineLarge,
        bodyMedium: YandexSansMedium,
        labelMedium: labelMedium,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: backgroundColor,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: TextStyle(
          color: textPrimary,
          fontSize: 18,
          fontWeight: FontWeight.w500,
          fontFamily: 'Yandex Sans Text',
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
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: AppTheme.backgroundColor,
        indicatorColor: Colors.transparent, // Убираем овал выделения
        overlayColor: WidgetStateProperty.all(Colors.transparent), // Убираем Ripple Effect
        iconTheme: WidgetStateProperty.all(const IconThemeData(size: 28)), // Увеличиваем иконки
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return const TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w500,
              fontFamily: 'Yandex Sans Text',
              color: textPrimary,
            );
          }
          return const TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.w500,
            fontFamily: 'Yandex Sans Text',
            color: textSecondary,
          );
        }),
      ),
    );
  }
}
