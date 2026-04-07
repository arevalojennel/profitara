import 'package:flutter/material.dart';
import 'package:profitara/repositories/settings_repository.dart';

class ThemeProvider extends ChangeNotifier {
  final SettingsRepository _repository = SettingsRepository();
  AppThemeMode _themeMode = AppThemeMode.system;

  ThemeProvider() {
    _loadThemeMode();
  }

  AppThemeMode get themeMode => _themeMode;

  Future<void> _loadThemeMode() async {
    _themeMode = await _repository.getThemeMode();
    notifyListeners();
  }

  Future<void> setThemeMode(AppThemeMode mode) async {
    if (_themeMode == mode) return;
    _themeMode = mode;
    await _repository.saveThemeMode(mode);
    notifyListeners();
  }

  ThemeMode get themeModeValue {
    switch (_themeMode) {
      case AppThemeMode.light:
        return ThemeMode.light;
      case AppThemeMode.dark:
        return ThemeMode.dark;
      case AppThemeMode.system:
        return ThemeMode.system;
    }
  }
}
