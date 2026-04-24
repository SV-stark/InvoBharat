import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

final appConfigProvider =
    NotifierProvider<AppConfigNotifier, AppConfig>(AppConfigNotifier.new);

class AppConfig {
  final PaneDisplayMode paneDisplayMode;

  AppConfig({this.paneDisplayMode = PaneDisplayMode.auto});

  AppConfig copyWith({final PaneDisplayMode? paneDisplayMode}) {
    return AppConfig(
      paneDisplayMode: paneDisplayMode ?? this.paneDisplayMode,
    );
  }
}

class AppConfigNotifier extends Notifier<AppConfig> {
  static const _paneKey = 'pane_display_mode';

  @override
  AppConfig build() {
    _loadConfig();
    return AppConfig();
  }

  Future<void> _loadConfig() async {
    final prefs = await SharedPreferences.getInstance();
    final paneIndex = prefs.getInt(_paneKey);
    if (paneIndex != null &&
        paneIndex >= 0 &&
        paneIndex < PaneDisplayMode.values.length) {
      state =
          state.copyWith(paneDisplayMode: PaneDisplayMode.values[paneIndex]);
    }
  }

  Future<void> setPaneDisplayMode(final PaneDisplayMode mode) async {
    state = state.copyWith(paneDisplayMode: mode);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_paneKey, mode.index);
  }
}
