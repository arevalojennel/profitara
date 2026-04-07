import 'package:flutter/material.dart';

class AppColors {
  // ======================================================
  // LIGHT THEME
  // ======================================================

  /// Primary Navy
  static const Color primaryLight = Color(0xFF0F172A);
  static const Color onPrimaryLight = Colors.white;

  static const Color primaryContainerLight = Color(0xFFE0E7FF);
  static const Color onPrimaryContainerLight = Color(0xFF020617);

  /// Secondary Light Gray
  static const Color secondaryLight = Color(0xFFF8FAFC);
  static const Color onSecondaryLight = Color(0xFF0F172A);

  static const Color secondaryContainerLight = Color(0xFFF1F5F9);
  static const Color onSecondaryContainerLight = Color(0xFF334155);

  /// Accent Orange
  static const Color accentLight = Color(0xFFff6c3d);
  static const Color onAccentLight = Colors.white;

  /// Success / Profit Green
  static const Color tertiaryLight = Color(0xFF22C55E);
  static const Color onTertiaryLight = Colors.white;

  /// Error
  static const Color errorLight = Color(0xFFEF4444);
  static const Color onErrorLight = Colors.white;

  /// Background
  static const Color surfaceLight = Color(0xFFFFFFFF);
  static const Color onSurfaceLight = Color(0xFF0F172A);

  static const Color surfaceVariantLight = Color(0xFFF8F8F8);
  static const Color onSurfaceVariantLight = Color(0xFF475569);

  static const Color outlineLight = Color(0xFFCBD5E1);

  /// Profit / Loss
  static const Color profitLight = Color(0xFF22C55E);
  static const Color lossLight = Color(0xFFEF4444);

  /// Charts
  static const Color revenueChartLight = Color(0xFF0F172A);
  static const Color profitChartLight = Color(0xFF22C55E);
  static const Color expenseChartLight = Color(0xFFEF4444);

  // Custom Container Colors
  static const Color statContainerColorLight = Color(0x60d7dfef);

  // ======================================================
  // DARK THEME
  // ======================================================

  static const Color primaryDark = Color(0xFF1E293B);
  static const Color onPrimaryDark = Colors.white;

  static const Color primaryContainerDark = Color(0xFF0F172A);
  static const Color onPrimaryContainerDark = Color(0xFFE0E7FF);

  /// Secondary Dark Gray
  static const Color secondaryDark = Color(0xFF334155);
  static const Color onSecondaryDark = Colors.white;

  static const Color secondaryContainerDark = Color(0xFF1E293B);
  static const Color onSecondaryContainerDark = Color(0xFFE2E8F0);

  /// Accent
  static const Color accentDark = Color(0xFFFB923C);
  static const Color onAccentDark = Colors.black;

  static const Color tertiaryDark = Color(0xFF4ADE80);
  static const Color onTertiaryDark = Colors.black;

  static const Color errorDark = Color(0xFFF87171);
  static const Color onErrorDark = Colors.black;

  static const Color surfaceDark = Color(0xFF0F172A);
  static const Color onSurfaceDark = Color(0xFFE2E8F0);

  static const Color surfaceVariantDark = Color(0xFF1E293B);
  static const Color onSurfaceVariantDark = Color(0xFFCBD5E1);

  static const Color outlineDark = Color(0xFF475569);

  /// Profit / Loss
  static const Color profitDark = Color(0xFF4ADE80);
  static const Color lossDark = Color(0xFFF87171);

  /// Charts
  static const Color revenueChartDark = Color(0xFF60A5FA);
  static const Color profitChartDark = Color(0xFF4ADE80);
  static const Color expenseChartDark = Color(0xFFF87171);
}

extension AppColorScheme on BuildContext {
  ColorScheme get scheme => Theme.of(this).colorScheme;

  Color get primaryColor => scheme.primary;
  Color get secondaryColor => scheme.secondary;
  Color get tertiaryColor => scheme.tertiary;

  Color get surfaceColor => scheme.surface;
  Color get onSurface => scheme.onSurface;
  Color get outline => scheme.outline;

  /// Accent CTA
  Color get accent => Theme.of(this).brightness == Brightness.light
      ? AppColors.accentLight
      : AppColors.accentDark;

  /// Profit / Loss
  Color get profit => Theme.of(this).brightness == Brightness.light
      ? AppColors.profitLight
      : AppColors.profitDark;

  Color get loss => Theme.of(this).brightness == Brightness.light
      ? AppColors.lossLight
      : AppColors.lossDark;

  /// Charts
  Color get revenueChart => Theme.of(this).brightness == Brightness.light
      ? AppColors.revenueChartLight
      : AppColors.revenueChartDark;

  Color get profitChart => Theme.of(this).brightness == Brightness.light
      ? AppColors.profitChartLight
      : AppColors.profitChartDark;

  Color get expenseChart => Theme.of(this).brightness == Brightness.light
      ? AppColors.expenseChartLight
      : AppColors.expenseChartDark;
}
