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

  EmailService({required final AppSettingsService settingsService})
    : _settingsService = settingsService;

  Future<void> saveSettings(final EmailSettings settings) async {
    await _settingsService.setSetting(_keyHost, settings.smtpHost);
    await _settingsService.setSetting(_keyPort, settings.smtpPort.toString());
    await _settingsService.setSetting(_keyEmail, settings.email);
    await _settingsService.setSetting(_keyUsername, settings.username);
    await _settingsService.setSetting(_keySecure, settings.isSecure.toString());

    if (settings.password != null && settings.password!.isNotEmpty) {
      await _storage.write(key: _keyPassword, value: settings.password);
    }
  }

  Future<EmailSettings?> getSettings() async {
    final host = await _settingsService.getSetting(_keyHost);
    if (host == null || host.isEmpty) return null;

    final password = await _storage.read(key: _keyPassword);

    final portStr = await _settingsService.getSetting(_keyPort);
    final secureStr = await _settingsService.getSetting(_keySecure);

    return EmailSettings(
      smtpHost: host,
      smtpPort: portStr != null ? int.tryParse(portStr) ?? 587 : 587,
      email: await _settingsService.getSetting(_keyEmail) ?? '',
      username: await _settingsService.getSetting(_keyUsername) ?? '',
      password: password,
      isSecure: secureStr != null ? secureStr.toLowerCase() == 'true' : true,
    );
  }

  Future<void> clearSettings() async {
    await _settingsService.setSetting(_keyHost, '');
    await _settingsService.setSetting(_keyPort, '');
    await _settingsService.setSetting(_keyEmail, '');
    await _settingsService.setSetting(_keyUsername, '');
    await _settingsService.setSetting(_keySecure, '');
    await _storage.delete(key: _keyPassword);
  }

  static Future<EmailSettings?> getSettingsStatic() async {
    final db = AppDatabase();
    final service = EmailService(settingsService: AppSettingsService(db));
    return service.getSettings();
  }

  static Future<void> saveSettingsStatic(final EmailSettings settings) async {
    final db = AppDatabase();
    final service = EmailService(settingsService: AppSettingsService(db));
    await service.saveSettings(settings);
  }

  static Future<void> clearSettingsStatic() async {
    final db = AppDatabase();
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
      allowInsecure: !settings.isSecure,
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
    }
  }
}
