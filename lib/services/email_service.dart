import 'dart:io';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:mailer/mailer.dart';
import 'package:mailer/smtp_server.dart';
import 'package:invobharat/database/database.dart' hide Invoice;

import 'package:invobharat/models/invoice.dart';

class EmailSettings {
  final String smtpHost;
  final int smtpPort;
  final String email;
  final String username;
  final String? password;
  final bool isSecure;

  EmailSettings({
    required this.smtpHost,
    required this.smtpPort,
    required this.email,
    required this.username,
    this.password,
    this.isSecure = true,
  });
}

class EmailService {
  static const _storage = FlutterSecureStorage();
  static const _keyPassword = 'smtp_password';
  static const _keyHost = 'smtp_host';
  static const _keyPort = 'smtp_port';
  static const _keyEmail = 'smtp_email';
  static const _keyUsername = 'smtp_username';
  static const _keySecure = 'smtp_is_secure';

  final AppSettingsService _settingsService;

  EmailService({required this._settingsService});

  Future<void> saveSettings(final EmailSettings settings) async {
    await _storage.write(key: _keyHost, value: settings.smtpHost);
    await _storage.write(key: _keyPort, value: settings.smtpPort.toString());
    await _storage.write(key: _keyEmail, value: settings.email);
    await _storage.write(key: _keyUsername, value: settings.username);
    await _storage.write(key: _keySecure, value: settings.isSecure.toString());

    if (settings.password != null && settings.password!.isNotEmpty) {
      await _storage.write(key: _keyPassword, value: settings.password);
    } else {
      await _storage.delete(key: _keyPassword);
    }

    // Clean up any plaintext records from AppSettings to prevent credentials leakage
    await _settingsService.setSetting(_keyHost, '');
    await _settingsService.setSetting(_keyPort, '');
    await _settingsService.setSetting(_keyEmail, '');
    await _settingsService.setSetting(_keyUsername, '');
    await _settingsService.setSetting(_keySecure, '');
  }

  Future<EmailSettings?> getSettings() async {
    String? host = await _storage.read(key: _keyHost);
    if (host == null || host.isEmpty) {
      // Backward compatibility: check AppSettings
      host = await _settingsService.getSetting(_keyHost);
      if (host == null || host.isEmpty) return null;
    }

    final password = await _storage.read(key: _keyPassword);
    final portStr =
        await _storage.read(key: _keyPort) ??
        await _settingsService.getSetting(_keyPort);
    final email =
        await _storage.read(key: _keyEmail) ??
        await _settingsService.getSetting(_keyEmail) ??
        '';
    final username =
        await _storage.read(key: _keyUsername) ??
        await _settingsService.getSetting(_keyUsername) ??
        '';
    final secureStr =
        await _storage.read(key: _keySecure) ??
        await _settingsService.getSetting(_keySecure);

    return EmailSettings(
      smtpHost: host,
      smtpPort: portStr != null ? int.tryParse(portStr) ?? 587 : 587,
      email: email,
      username: username,
      password: password,
      isSecure: secureStr != null ? secureStr.toLowerCase() == 'true' : true,
    );
  }

  Future<void> clearSettings() async {
    await _storage.delete(key: _keyHost);
    await _storage.delete(key: _keyPort);
    await _storage.delete(key: _keyEmail);
    await _storage.delete(key: _keyUsername);
    await _storage.delete(key: _keySecure);
    await _storage.delete(key: _keyPassword);

    await _settingsService.setSetting(_keyHost, '');
    await _settingsService.setSetting(_keyPort, '');
    await _settingsService.setSetting(_keyEmail, '');
    await _settingsService.setSetting(_keyUsername, '');
    await _settingsService.setSetting(_keySecure, '');
  }

  static Future<EmailSettings?> getSettingsStatic() async {
    final db = AppDatabase.instance;
    final service = EmailService(settingsService: AppSettingsService(db));
    return service.getSettings();
  }

  static Future<void> saveSettingsStatic(final EmailSettings settings) async {
    final db = AppDatabase.instance;
    final service = EmailService(settingsService: AppSettingsService(db));
    await service.saveSettings(settings);
  }

  static Future<void> clearSettingsStatic() async {
    final db = AppDatabase.instance;
    final service = EmailService(settingsService: AppSettingsService(db));
    await service.clearSettings();
  }

  static Future<void> sendInvoiceEmail({
    required final EmailSettings settings,
    required final Invoice invoice,
    required final File pdfFile,
    required final String subject,
    required final String body,
    required final String recipientEmail,
    final Future<PersistentConnection> Function(Message, SmtpServer)?
    sendFunction,
  }) async {
    final smtpServer = SmtpServer(
      settings.smtpHost,
      port: settings.smtpPort,
      username: settings.username,
      password: settings.password,
      ssl: settings.isSecure && settings.smtpPort == 465,
    );

    final message = Message()
      ..from = Address(settings.email, settings.username)
      ..recipients.add(recipientEmail)
      ..subject = subject
      ..text = body
      ..attachments.add(FileAttachment(pdfFile));

    try {
      if (sendFunction != null) {
        await sendFunction(message, smtpServer);
      } else {
        await send(message, smtpServer);
      }
    } on MailerException catch (e) {
      throw Exception(
        "Email failed: ${e.message}\nCheck settings or internet.",
      );
    } catch (e) {
      throw Exception("Email failed: $e\nCheck settings or internet.");
    }
  }
}
