import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';
import '../providers/theme_provider.dart';
import '../theme/app_colors.dart';

class SnackbarUtil {
  static void showSuccessMessage({
    required BuildContext context,
    required String message,
    String? title,
    SnackPosition? snackPosition,
    int duration = 1500,
  }) {
    final themeProvider = Provider.of<ThemeProvider>(context, listen: false);
    final backgroundColor = themeProvider.themeModeValue == ThemeMode.dark
        ? AppColors.tertiaryDark
        : AppColors.tertiaryLight;

    Get.snackbar(
      title ?? "Success!",
      message,
      backgroundColor: backgroundColor,
      snackPosition: snackPosition ?? SnackPosition.BOTTOM,
      margin: const EdgeInsets.all(0),
      borderRadius: 0,
      duration: Duration(milliseconds: duration),
      colorText: AppColors.onPrimaryLight,
    );
  }

  static void showErrorMessage({
    required BuildContext context,
    required String message,
    String? title,
    SnackPosition? snackPosition,
    int duration = 1500,
  }) {
    final themeProvider = Provider.of<ThemeProvider>(context, listen: false);
    final backgroundColor = themeProvider.themeModeValue == ThemeMode.dark
        ? AppColors.errorDark
        : AppColors.errorLight;

    Get.snackbar(
      title ?? "Error!",
      message,
      backgroundColor: backgroundColor,
      snackPosition: snackPosition ?? SnackPosition.BOTTOM,
      margin: const EdgeInsets.all(0),
      borderRadius: 0,
      duration: Duration(milliseconds: duration),
      colorText: AppColors.onPrimaryLight,
    );
  }

  static void showExitMessage({
    required BuildContext context,
    required String message,
    String? title,
    SnackPosition? snackPosition,
    int duration = 1500,
  }) {
    final themeProvider = Provider.of<ThemeProvider>(context, listen: false);
    final backgroundColor = themeProvider.themeModeValue == ThemeMode.dark
        ? AppColors.onPrimaryContainerDark
        : AppColors.onPrimaryContainerLight;
    final textColor = themeProvider.themeModeValue == ThemeMode.dark
        ? AppColors.primaryContainerDark
        : AppColors.primaryContainerLight;

    Get.snackbar(
      title ?? "Alert!",
      message,
      backgroundColor: backgroundColor,
      snackPosition: snackPosition ?? SnackPosition.BOTTOM,
      margin: const EdgeInsets.all(0),
      borderRadius: 0,
      duration: Duration(milliseconds: duration),
      colorText: textColor,
    );
  }
}
