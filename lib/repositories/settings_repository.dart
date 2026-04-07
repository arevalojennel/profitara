import 'package:shared_preferences/shared_preferences.dart';

enum AppThemeMode { light, dark, system }

class SettingsRepository {
  static const String _themeModeKey = 'theme_mode';

  Future<void> saveThemeMode(AppThemeMode mode) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_themeModeKey, mode.index);
  }

  Future<AppThemeMode> getThemeMode() async {
    final prefs = await SharedPreferences.getInstance();
    final index = prefs.getInt(_themeModeKey);
    if (index == null) return AppThemeMode.system;
    return AppThemeMode.values[index];
  }
}
