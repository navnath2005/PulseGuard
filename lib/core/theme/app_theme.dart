import 'package:flutter/material.dart';

class AppColors {
  // Primary gradient palette
  static const Color primaryDark = Color(0xFF0A0E21);
  static const Color primaryMid = Color(0xFF1A1F3A);
  static const Color surfaceDark = Color(0xFF111328);
  static const Color surfaceCard = Color(0xFF1D1E33);

  // Accent colors
  static const Color accentCyan = Color(0xFF00E5FF);
  static const Color accentPink = Color(0xFFFF006E);
  static const Color accentGreen = Color(0xFF00E676);
  static const Color accentOrange = Color(0xFFFF9100);
  static const Color accentPurple = Color(0xFFBB86FC);

  // Heart rate gradient
  static const Color heartRateStart = Color(0xFFFF006E);
  static const Color heartRateEnd = Color(0xFFFF4081);

  // SpO2 gradient
  static const Color spo2Start = Color(0xFF00B4D8);
  static const Color spo2End = Color(0xFF00E5FF);

  // Temperature gradient
  static const Color tempStart = Color(0xFFFF9100);
  static const Color tempEnd = Color(0xFFFFAB40);

  // Text colors
  static const Color textPrimary = Color(0xFFFFFFFF);
  static const Color textSecondary = Color(0xB3FFFFFF); // 70% white
  static const Color textMuted = Color(0x80FFFFFF); // 50% white

  // Status colors
  static const Color statusNormal = Color(0xFF00E676);
  static const Color statusWarning = Color(0xFFFFD600);
  static const Color statusCritical = Color(0xFFFF1744);

  // Glass effect
  static const Color glassWhite = Color(0x1AFFFFFF); // 10% white
  static const Color glassBorder = Color(0x33FFFFFF); // 20% white
}

class AppTheme {
  static ThemeData get darkTheme {
    return ThemeData(
      brightness: Brightness.dark,
      scaffoldBackgroundColor: AppColors.primaryDark,
      primaryColor: AppColors.accentCyan,
      colorScheme: const ColorScheme.dark(
        primary: AppColors.accentCyan,
        secondary: AppColors.accentPink,
        surface: AppColors.surfaceCard,
        error: AppColors.statusCritical,
      ),
      fontFamily: 'Roboto',
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: TextStyle(
          fontFamily: 'Roboto',
          fontSize: 20,
          fontWeight: FontWeight.w600,
          letterSpacing: 1.2,
          color: AppColors.textPrimary,
        ),
      ),
      textTheme: const TextTheme(
        headlineLarge: TextStyle(
          fontSize: 32,
          fontWeight: FontWeight.w700,
          letterSpacing: -0.5,
          color: AppColors.textPrimary,
        ),
        headlineMedium: TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.w600,
          color: AppColors.textPrimary,
        ),
        titleLarge: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: AppColors.textPrimary,
        ),
        titleMedium: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w500,
          color: AppColors.textSecondary,
        ),
        bodyLarge: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w400,
          color: AppColors.textPrimary,
        ),
        bodyMedium: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w400,
          color: AppColors.textSecondary,
        ),
        labelLarge: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w500,
          letterSpacing: 1.5,
          color: AppColors.textMuted,
        ),
      ),
    );
  }
}
