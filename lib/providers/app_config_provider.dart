import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

final appConfigProvider = NotifierProvider<AppConfigNotifier, AppConfig>(
  AppConfigNotifier.new,
);

enum UpdateChannel { stable, nightly }

class AppConfig {
  final PaneDisplayMode paneDisplayMode;
  final UpdateChannel updateChannel;

  AppConfig({
    this.paneDisplayMode = PaneDisplayMode.auto,
    this.updateChannel = UpdateChannel.stable,
  });

  AppConfig copyWith({
    final PaneDisplayMode? paneDisplayMode,
    final UpdateChannel? updateChannel,
  }) {
    return AppConfig(
      paneDisplayMode: paneDisplayMode ?? this.paneDisplayMode,
      updateChannel: updateChannel ?? this.updateChannel,
    );
  }
}

class AppConfigNotifier extends Notifier<AppConfig> {
  static const _paneKey = 'pane_display_mode';
  static const _updateChannelKey = 'update_channel';

  @override
  AppConfig build() {
    _loadConfig();
    return AppConfig();
  }

  Future<void> _loadConfig() async {
    final prefs = await SharedPreferences.getInstance();
    final paneIndex = prefs.getInt(_paneKey);
    final channelIndex = prefs.getInt(_updateChannelKey);

    var newState = state;

    if (paneIndex != null &&
        paneIndex >= 0 &&
        paneIndex < PaneDisplayMode.values.length) {
      newState = newState.copyWith(
        paneDisplayMode: PaneDisplayMode.values[paneIndex],
      );
    }

    if (channelIndex != null &&
        channelIndex >= 0 &&
        channelIndex < UpdateChannel.values.length) {
      newState = newState.copyWith(
        updateChannel: UpdateChannel.values[channelIndex],
      );
    }

    state = newState;
  }

  Future<void> setPaneDisplayMode(final PaneDisplayMode mode) async {
    state = state.copyWith(paneDisplayMode: mode);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_paneKey, mode.index);
  }

  Future<void> setUpdateChannel(final UpdateChannel channel) async {
    state = state.copyWith(updateChannel: channel);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_updateChannelKey, channel.index);
  }
}
