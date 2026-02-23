import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:invobharat/providers/database_provider.dart';

final themeProvider =
    NotifierProvider<ThemeNotifier, ThemeMode>(ThemeNotifier.new);

class ThemeNotifier extends Notifier<ThemeMode> {
  @override
  ThemeMode build() {
    _loadTheme();
    return ThemeMode.system;
  }

  Future<void> _loadTheme() async {
    try {
      final settingsService = ref.read(appSettingsServiceProvider);
      final savedMode = await settingsService.getSetting('theme_mode');
      if (savedMode != null) {
        state = ThemeMode.values.firstWhere(
          (final e) => e.toString() == savedMode,
          orElse: () => ThemeMode.system,
        );
      }
    } catch (e) {
      // Fallback to default
    }
  }

  Future<void> setTheme(final ThemeMode mode) async {
    state = mode;
    try {
      final settingsService = ref.read(appSettingsServiceProvider);
      await settingsService.setSetting('theme_mode', mode.toString());
    } catch (e) {
      // Handle error
    }
  }
}
