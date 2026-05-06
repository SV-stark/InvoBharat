import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

final appConfigProvider = NotifierProvider<AppConfigNotifier, AppConfig>(
  AppConfigNotifier.new,
);

enum UpdateChannel { stable, nightly }

enum BackupFrequency { none, daily, weekly, monthly }

class AppConfig {
  final PaneDisplayMode paneDisplayMode;
  final UpdateChannel updateChannel;
  final bool autoBackupEnabled;
  final BackupFrequency backupFrequency;
  final String backupTime;
  final DateTime? lastAutoBackup;
  final String? backupPath;

  AppConfig({
    this.paneDisplayMode = PaneDisplayMode.auto,
    this.updateChannel = UpdateChannel.stable,
    this.autoBackupEnabled = false,
    this.backupFrequency = BackupFrequency.none,
    this.backupTime = "00:00",
    this.lastAutoBackup,
    this.backupPath,
  });

  AppConfig copyWith({
    final PaneDisplayMode? paneDisplayMode,
    final UpdateChannel? updateChannel,
    final bool? autoBackupEnabled,
    final BackupFrequency? backupFrequency,
    final String? backupTime,
    final DateTime? lastAutoBackup,
    final String? backupPath,
  }) {
    return AppConfig(
      paneDisplayMode: paneDisplayMode ?? this.paneDisplayMode,
      updateChannel: updateChannel ?? this.updateChannel,
      autoBackupEnabled: autoBackupEnabled ?? this.autoBackupEnabled,
      backupFrequency: backupFrequency ?? this.backupFrequency,
      backupTime: backupTime ?? this.backupTime,
      lastAutoBackup: lastAutoBackup ?? this.lastAutoBackup,
      backupPath: backupPath ?? this.backupPath,
    );
  }
}

class AppConfigNotifier extends Notifier<AppConfig> {
  static const _paneKey = 'pane_display_mode';
  static const _updateChannelKey = 'update_channel';
  static const _autoBackupEnabledKey = 'auto_backup_enabled';
  static const _backupFrequencyKey = 'backup_frequency';
  static const _backupTimeKey = 'backup_time';
  static const _lastAutoBackupKey = 'last_auto_backup';
  static const _backupPathKey = 'backup_path';

  @override
  AppConfig build() {
    _loadConfig();
    return AppConfig();
  }

  Future<void> _loadConfig() async {
    final prefs = await SharedPreferences.getInstance();
    final paneIndex = prefs.getInt(_paneKey);
    final channelIndex = prefs.getInt(_updateChannelKey);
    final autoBackupEnabled = prefs.getBool(_autoBackupEnabledKey) ?? false;
    final frequencyIndex = prefs.getInt(_backupFrequencyKey) ?? 0;
    final backupTime = prefs.getString(_backupTimeKey) ?? "00:00";
    final lastBackupStr = prefs.getString(_lastAutoBackupKey);
    final backupPath = prefs.getString(_backupPathKey);

    var newState = state.copyWith(
      autoBackupEnabled: autoBackupEnabled,
      backupFrequency: BackupFrequency.values[frequencyIndex],
      backupTime: backupTime,
      lastAutoBackup: lastBackupStr != null
          ? DateTime.tryParse(lastBackupStr)
          : null,
      backupPath: backupPath,
    );

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

  Future<void> setAutoBackupEnabled(final bool enabled) async {
    state = state.copyWith(autoBackupEnabled: enabled);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_autoBackupEnabledKey, enabled);
  }

  Future<void> setBackupFrequency(final BackupFrequency freq) async {
    state = state.copyWith(backupFrequency: freq);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_backupFrequencyKey, freq.index);
  }

  Future<void> setBackupTime(final String time) async {
    state = state.copyWith(backupTime: time);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_backupTimeKey, time);
  }

  Future<void> setBackupPath(final String? path) async {
    state = state.copyWith(backupPath: path);
    final prefs = await SharedPreferences.getInstance();
    if (path == null) {
      await prefs.remove(_backupPathKey);
    } else {
      await prefs.setString(_backupPathKey, path);
    }
  }

  Future<void> updateLastBackupDate(final DateTime date) async {
    state = state.copyWith(lastAutoBackup: date);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_lastAutoBackupKey, date.toIso8601String());
  }
}
