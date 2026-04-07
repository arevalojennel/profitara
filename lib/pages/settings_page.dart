import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:profitara/providers/theme_provider.dart';
import 'package:profitara/repositories/settings_repository.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    // Determine if the stored theme mode is dark
    final isDarkMode = themeProvider.themeMode == AppThemeMode.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: ListView(
        children: [
          const SizedBox(height: 16),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              'Appearance',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ),
          SwitchListTile(
            title: const Text('Dark Mode'),
            subtitle: const Text('Toggle between light and dark theme'),
            value: isDarkMode,
            onChanged: (value) {
              // Save the explicit theme choice
              themeProvider.setThemeMode(
                value ? AppThemeMode.dark : AppThemeMode.light,
              );
            },
          ),
          const Divider(),
          const ListTile(
            title: Text('About'),
            subtitle: Text('Profitara v1.0.0'),
          ),
        ],
      ),
    );
  }
}
