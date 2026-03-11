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
  final String? password; // Only for in-memory transfer, stored securely
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

  /// Saves SMTP settings. Password is stored securely.
  static Future<void> saveSettings(final EmailSettings settings) async {
    final db = AppDatabase();
    final prefs = AppSettingsService(db);
    await prefs.setSetting(_keyHost, settings.smtpHost);
    await prefs.setSetting(_keyPort, settings.smtpPort.toString());
    await prefs.setSetting(_keyEmail, settings.email);
    await prefs.setSetting(_keyUsername, settings.username);
    await prefs.setSetting(_keySecure, settings.isSecure.toString());

    if (settings.password != null && settings.password!.isNotEmpty) {
      await _storage.write(key: _keyPassword, value: settings.password);
    }
  }

  /// Retrieves SMTP settings. Password is fetched from secure storage.
  static Future<EmailSettings?> getSettings() async {
    final db = AppDatabase();
    final prefs = AppSettingsService(db);

    final host = await prefs.getSetting(_keyHost);
    if (host == null || host.isEmpty) return null;

    final password = await _storage.read(key: _keyPassword);

    final portStr = await prefs.getSetting(_keyPort);
    final secureStr = await prefs.getSetting(_keySecure);

    return EmailSettings(
      smtpHost: host,
      smtpPort: portStr != null ? int.tryParse(portStr) ?? 587 : 587,
      email: await prefs.getSetting(_keyEmail) ?? '',
      username: await prefs.getSetting(_keyUsername) ?? '',
      password: password,
      isSecure: secureStr != null ? secureStr.toLowerCase() == 'true' : true,
    );
  }

  /// Clears all settings.
  static Future<void> clearSettings() async {
    final db = AppDatabase();
    final prefs = AppSettingsService(db);
    await prefs.setSetting(_keyHost, '');
    await prefs.setSetting(_keyPort, '');
    await prefs.setSetting(_keyEmail, '');
    await prefs.setSetting(_keyUsername, '');
    await prefs.setSetting(_keySecure, '');
    await _storage.delete(key: _keyPassword);
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
      ssl: settings.isSecure && settings.smtpPort == 465, // Implicit SSL
      allowInsecure: !settings.isSecure, // Explicit TLS usually startls
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
      // Re-throw with user friendly message if possible
      throw Exception(
        "Email failed: ${e.message}\nCheck settings or internet.",
      );
    }
  }
}
