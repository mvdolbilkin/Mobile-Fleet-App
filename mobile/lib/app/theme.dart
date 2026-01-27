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
    height: 0.83,
    letterSpacing: -0.5,
  );

  static const TextStyle appBarTitle = TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.w500,
    color: textPrimary,
    fontFamily: 'Yandex Sans Text',
  );

  static const TextStyle bodyText = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w400,
    color: textPrimary,
    fontFamily: 'Yandex Sans Text',
  );

  static const TextStyle searchHint = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w400,
    color: textSecondary,
    fontFamily: 'Yandex Sans Text',
  );

  static const TextStyle filterChip = TextStyle(
    fontSize: 15,
    fontWeight: FontWeight.w400,
    color: textPrimary,
    fontFamily: 'Yandex Sans Text',
  );

  static const TextStyle listTitle = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w500,
    color: textPrimary,
    fontFamily: 'Yandex Sans Text',
  );

  static const TextStyle listSubtitle = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w500,
    color: textSecondary,
    fontFamily: 'Yandex Sans Text',
  );

  static const TextStyle avatarText = TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.w600,
    color: textSecondary,
    fontFamily: 'Yandex Sans Text',
  );

  static const TextStyle badgeText = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w500,
    color: Colors.white,
    fontFamily: 'Yandex Sans Text',
  );

  static const TextStyle caption = TextStyle(
    fontSize: 14,
    color: textPrimary,
    fontFamily: 'Yandex Sans Text',
  );
  
  static const TextStyle captionSecondary = TextStyle(
    fontSize: 14,
    color: textSecondary,
    fontFamily: 'Yandex Sans Text',
  );

  // Deprecated or Aliases for backward compatibility if needed, 
  // but better to stick to the new naming convention.
  // Keeping YandexSansMedium as bodyText alias for now or removing if not used elsewhere.
  static const TextStyle YandexSansMedium = bodyText;

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
        bodyMedium: bodyText,
        labelMedium: labelMedium,
        titleMedium: listTitle,
        titleSmall: listSubtitle,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: backgroundColor,
        elevation: 0,
        scrolledUnderElevation: 0, // Отключает изменение цвета при скролле
        centerTitle: true,
        titleTextStyle: appBarTitle,
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
