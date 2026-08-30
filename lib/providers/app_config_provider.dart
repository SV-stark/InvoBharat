import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:invobharat/providers/database_provider.dart';

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
  final bool showHsnSummaryInPdf;

  AppConfig({
    this.paneDisplayMode = PaneDisplayMode.expanded,
    this.updateChannel = UpdateChannel.stable,
    this.autoBackupEnabled = false,
    this.backupFrequency = BackupFrequency.none,
    this.backupTime = "00:00",
    this.lastAutoBackup,
    this.backupPath,
    this.showHsnSummaryInPdf = true,
  });

  AppConfig copyWith({
    final PaneDisplayMode? paneDisplayMode,
    final UpdateChannel? updateChannel,
    final bool? autoBackupEnabled,
    final BackupFrequency? backupFrequency,
    final String? backupTime,
    final DateTime? lastAutoBackup,
    final String? backupPath,
    final bool? showHsnSummaryInPdf,
  }) {
    return AppConfig(
      paneDisplayMode: paneDisplayMode ?? this.paneDisplayMode,
      updateChannel: updateChannel ?? this.updateChannel,
      autoBackupEnabled: autoBackupEnabled ?? this.autoBackupEnabled,
      backupFrequency: backupFrequency ?? this.backupFrequency,
      backupTime: backupTime ?? this.backupTime,
      lastAutoBackup: lastAutoBackup ?? this.lastAutoBackup,
      backupPath: backupPath ?? this.backupPath,
      showHsnSummaryInPdf: showHsnSummaryInPdf ?? this.showHsnSummaryInPdf,
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
  static const _showHsnSummaryInPdfKey = 'show_hsn_summary_in_pdf';

  @override
  AppConfig build() {
    _loadConfig();
    return AppConfig();
  }

  Future<void> loadConfig() => _loadConfig();

  Future<void> _loadConfig() async {
    try {
      final settingsService = ref.read(appSettingsServiceProvider);
      final prefs = await SharedPreferences.getInstance();

      final paneVal =
          await settingsService.getSetting(_paneKey) ??
          prefs.getInt(_paneKey)?.toString();
      final channelVal =
          await settingsService.getSetting(_updateChannelKey) ??
          prefs.getInt(_updateChannelKey)?.toString();
      final autoBackupVal =
          await settingsService.getSetting(_autoBackupEnabledKey) ??
          prefs.getBool(_autoBackupEnabledKey)?.toString();
      final freqVal =
          await settingsService.getSetting(_backupFrequencyKey) ??
          prefs.getInt(_backupFrequencyKey)?.toString();
      final backupTime =
          await settingsService.getSetting(_backupTimeKey) ??
          prefs.getString(_backupTimeKey) ??
          "00:00";
      final lastBackupStr =
          await settingsService.getSetting(_lastAutoBackupKey) ??
          prefs.getString(_lastAutoBackupKey);
      final backupPath =
          await settingsService.getSetting(_backupPathKey) ??
          prefs.getString(_backupPathKey);
      final showHsnVal =
          await settingsService.getSetting(_showHsnSummaryInPdfKey) ??
          prefs.getBool(_showHsnSummaryInPdfKey)?.toString();

      final paneIndex = int.tryParse(paneVal ?? '');
      final channelIndex = int.tryParse(channelVal ?? '');
      final autoBackupEnabled = autoBackupVal?.toLowerCase() == 'true';
      final frequencyIndex = int.tryParse(freqVal ?? '') ?? 0;
      final showHsnSummaryInPdf =
          showHsnVal == null || showHsnVal.toLowerCase() == 'true';

      var newState = state.copyWith(
        autoBackupEnabled: autoBackupEnabled,
        backupFrequency:
            frequencyIndex >= 0 &&
                frequencyIndex < BackupFrequency.values.length
            ? BackupFrequency.values[frequencyIndex]
            : BackupFrequency.none,
        backupTime: backupTime,
        lastAutoBackup: lastBackupStr != null
            ? DateTime.tryParse(lastBackupStr)
            : null,
        backupPath: backupPath,
        showHsnSummaryInPdf: showHsnSummaryInPdf,
      );

      if (paneIndex != null &&
          paneIndex >= 0 &&
          paneIndex < PaneDisplayMode.values.length) {
        var loadedMode = PaneDisplayMode.values[paneIndex];
        if (loadedMode == PaneDisplayMode.auto ||
            loadedMode == PaneDisplayMode.minimal) {
          loadedMode = PaneDisplayMode.expanded;
        }
        newState = newState.copyWith(paneDisplayMode: loadedMode);
      }

      if (channelIndex != null &&
          channelIndex >= 0 &&
          channelIndex < UpdateChannel.values.length) {
        newState = newState.copyWith(
          updateChannel: UpdateChannel.values[channelIndex],
        );
      }

      state = newState;
    } catch (_) {}
  }

  Future<void> setPaneDisplayMode(final PaneDisplayMode mode) async {
    state = state.copyWith(paneDisplayMode: mode);
    final settingsService = ref.read(appSettingsServiceProvider);
    await settingsService.setSetting(_paneKey, mode.index.toString());
  }

  Future<void> setUpdateChannel(final UpdateChannel channel) async {
    state = state.copyWith(updateChannel: channel);
    final settingsService = ref.read(appSettingsServiceProvider);
    await settingsService.setSetting(
      _updateChannelKey,
      channel.index.toString(),
    );
  }

  Future<void> setAutoBackupEnabled(final bool enabled) async {
    state = state.copyWith(autoBackupEnabled: enabled);
    final settingsService = ref.read(appSettingsServiceProvider);
    await settingsService.setSetting(_autoBackupEnabledKey, enabled.toString());
  }

  Future<void> setBackupFrequency(final BackupFrequency freq) async {
    state = state.copyWith(backupFrequency: freq);
    final settingsService = ref.read(appSettingsServiceProvider);
    await settingsService.setSetting(
      _backupFrequencyKey,
      freq.index.toString(),
    );
  }

  Future<void> setBackupTime(final String time) async {
    state = state.copyWith(backupTime: time);
    final settingsService = ref.read(appSettingsServiceProvider);
    await settingsService.setSetting(_backupTimeKey, time);
  }

  Future<void> setBackupPath(final String? path) async {
    state = state.copyWith(backupPath: path);
    final settingsService = ref.read(appSettingsServiceProvider);
    await settingsService.setSetting(_backupPathKey, path ?? '');
  }

  Future<void> updateLastBackupDate(final DateTime date) async {
    state = state.copyWith(lastAutoBackup: date);
    final settingsService = ref.read(appSettingsServiceProvider);
    await settingsService.setSetting(
      _lastAutoBackupKey,
      date.toIso8601String(),
    );
  }

  Future<void> setShowHsnSummaryInPdf(final bool value) async {
    state = state.copyWith(showHsnSummaryInPdf: value);
    final settingsService = ref.read(appSettingsServiceProvider);
    await settingsService.setSetting(_showHsnSummaryInPdfKey, value.toString());
  }
}
