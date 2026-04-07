import 'package:flutter/material.dart';
import 'app_colors.dart';

class AppTheme {
  // ===========================
  // LIGHT THEME
  // ===========================
  static ThemeData lightTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    primaryColor: AppColors.primaryLight,
    scaffoldBackgroundColor: AppColors.surfaceLight,
    cardColor: AppColors.surfaceVariantLight,
    fontFamily: 'Inter',
    colorScheme: const ColorScheme.light(
      primary: AppColors.primaryLight,
      onPrimary: AppColors.onPrimaryLight,
      primaryContainer: AppColors.primaryContainerLight,
      onPrimaryContainer: AppColors.onPrimaryContainerLight,
      secondary: AppColors.secondaryLight,
      onSecondary: AppColors.onSecondaryLight,
      secondaryContainer: AppColors.secondaryContainerLight,
      onSecondaryContainer: AppColors.onSecondaryContainerLight,
      tertiary: AppColors.accentLight,
      onTertiary: AppColors.onAccentLight,
      error: AppColors.errorLight,
      onError: AppColors.onErrorLight,
      surface: AppColors.surfaceLight,
      onSurface: AppColors.onSurfaceLight,
      surfaceContainerHighest: AppColors.surfaceVariantLight,
      onSurfaceVariant: AppColors.onSurfaceVariantLight,
      outline: AppColors.outlineLight,
    ),
    textTheme: const TextTheme(
      displayLarge: TextStyle(
          fontFamily: 'InterDisplay',
          fontSize: 57,
          fontWeight: FontWeight.w700,
          letterSpacing: -0.25),
      displayMedium: TextStyle(
          fontFamily: 'InterDisplay',
          fontSize: 45,
          fontWeight: FontWeight.w600),
      displaySmall: TextStyle(
          fontFamily: 'InterDisplay',
          fontSize: 36,
          fontWeight: FontWeight.w600),
      headlineLarge: TextStyle(
          fontFamily: 'InterDisplay',
          fontSize: 32,
          fontWeight: FontWeight.w600),
      headlineMedium: TextStyle(
          fontFamily: 'InterDisplay',
          fontSize: 28,
          fontWeight: FontWeight.w600),
      headlineSmall: TextStyle(
          fontFamily: 'InterDisplay',
          fontSize: 24,
          fontWeight: FontWeight.w600),
      titleLarge: TextStyle(
          fontFamily: 'InterDisplay',
          fontSize: 22,
          fontWeight: FontWeight.w600),
      titleMedium: TextStyle(
          fontFamily: 'Inter', fontSize: 16, fontWeight: FontWeight.w600),
      titleSmall: TextStyle(
          fontFamily: 'Inter', fontSize: 14, fontWeight: FontWeight.w600),
      bodyLarge: TextStyle(fontFamily: 'Inter', fontSize: 16),
      bodyMedium: TextStyle(fontFamily: 'Inter', fontSize: 14),
      bodySmall: TextStyle(fontFamily: 'Inter', fontSize: 12),
      labelLarge: TextStyle(
          fontFamily: 'Inter', fontSize: 14, fontWeight: FontWeight.w500),
      labelMedium: TextStyle(
          fontFamily: 'Inter', fontSize: 12, fontWeight: FontWeight.w500),
      labelSmall: TextStyle(
          fontFamily: 'Inter', fontSize: 11, fontWeight: FontWeight.w500),
    ),
    appBarTheme: const AppBarTheme(
      centerTitle: false,
      elevation: 0,
      backgroundColor: AppColors.surfaceLight,
      foregroundColor: AppColors.primaryLight,
      titleTextStyle: TextStyle(
        fontFamily: 'InterDisplay',
        fontSize: 20,
        fontWeight: FontWeight.w600,
        color: AppColors.primaryLight,
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        foregroundColor: AppColors.onAccentLight,
        backgroundColor: AppColors.accentLight,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    ),
    cardTheme: CardThemeData(
      color: AppColors.surfaceVariantLight,
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    ),
    inputDecorationTheme: InputDecorationTheme(
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      filled: true,
      fillColor: AppColors.secondaryContainerLight,
      labelStyle: const TextStyle(fontFamily: 'Inter', fontSize: 14),
    ),
    floatingActionButtonTheme: FloatingActionButtonThemeData(
      foregroundColor: AppColors.onAccentLight,
      backgroundColor: AppColors.accentLight,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
    ),
  );

  // ===========================
  // DARK THEME
  // ===========================
  static ThemeData darkTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    primaryColor: AppColors.primaryDark,
    scaffoldBackgroundColor: AppColors.surfaceDark,
    cardColor: AppColors.surfaceVariantDark,
    fontFamily: 'Inter',
    colorScheme: const ColorScheme.dark(
      primary: AppColors.primaryDark,
      onPrimary: AppColors.onPrimaryDark,
      primaryContainer: AppColors.primaryContainerDark,
      onPrimaryContainer: AppColors.onPrimaryContainerDark,
      secondary: AppColors.secondaryDark,
      onSecondary: AppColors.onSecondaryDark,
      secondaryContainer: AppColors.secondaryContainerDark,
      onSecondaryContainer: AppColors.onSecondaryContainerDark,
      tertiary: AppColors.accentDark,
      onTertiary: AppColors.onAccentDark,
      error: AppColors.errorDark,
      onError: AppColors.onErrorDark,
      surface: AppColors.surfaceDark,
      onSurface: AppColors.onSurfaceDark,
      surfaceContainerHighest: AppColors.surfaceVariantDark,
      onSurfaceVariant: AppColors.onSurfaceVariantDark,
      outline: AppColors.outlineDark,
    ),
    textTheme: const TextTheme(
      displayLarge: TextStyle(
        fontFamily: 'InterDisplay',
        fontSize: 57,
        fontWeight: FontWeight.w700,
      ),
      displayMedium: TextStyle(
        fontFamily: 'InterDisplay',
        fontSize: 45,
        fontWeight: FontWeight.w600,
      ),
      displaySmall: TextStyle(
        fontFamily: 'InterDisplay',
        fontSize: 36,
        fontWeight: FontWeight.w600,
      ),
      headlineLarge: TextStyle(
        fontFamily: 'InterDisplay',
        fontSize: 32,
        fontWeight: FontWeight.w600,
      ),
      headlineMedium: TextStyle(
          fontFamily: 'InterDisplay',
          fontSize: 28,
          fontWeight: FontWeight.w600),
      headlineSmall: TextStyle(
          fontFamily: 'InterDisplay',
          fontSize: 24,
          fontWeight: FontWeight.w600),
      titleLarge: TextStyle(
          fontFamily: 'InterDisplay',
          fontSize: 22,
          fontWeight: FontWeight.w600),
      titleMedium: TextStyle(
          fontFamily: 'Inter', fontSize: 16, fontWeight: FontWeight.w600),
      titleSmall: TextStyle(
          fontFamily: 'Inter', fontSize: 14, fontWeight: FontWeight.w600),
      bodyLarge: TextStyle(fontFamily: 'Inter', fontSize: 16),
      bodyMedium: TextStyle(fontFamily: 'Inter', fontSize: 14),
      bodySmall: TextStyle(fontFamily: 'Inter', fontSize: 12),
      labelLarge: TextStyle(
          fontFamily: 'Inter', fontSize: 14, fontWeight: FontWeight.w500),
      labelMedium: TextStyle(
          fontFamily: 'Inter', fontSize: 12, fontWeight: FontWeight.w500),
      labelSmall: TextStyle(
          fontFamily: 'Inter', fontSize: 11, fontWeight: FontWeight.w500),
    ),
    appBarTheme: const AppBarTheme(
      centerTitle: false,
      elevation: 0,
      backgroundColor: AppColors.surfaceDark,
      foregroundColor: AppColors.onPrimaryDark,
      titleTextStyle: TextStyle(
          fontFamily: 'InterDisplay',
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: AppColors.onPrimaryDark),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        foregroundColor: AppColors.onAccentDark,
        backgroundColor: AppColors.accentDark,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    ),
    cardTheme: CardThemeData(
      color: AppColors.surfaceVariantDark,
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    ),
    inputDecorationTheme: InputDecorationTheme(
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      filled: true,
      fillColor: AppColors.secondaryContainerDark,
      labelStyle: const TextStyle(fontFamily: 'Inter', fontSize: 14),
    ),
    floatingActionButtonTheme: FloatingActionButtonThemeData(
      foregroundColor: AppColors.onAccentLight,
      backgroundColor: AppColors.accentDark,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
    ),
  );
}
