import 'dart:io';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:mailer/mailer.dart';
import 'package:mailer/smtp_server.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/invoice.dart';

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
  static Future<void> saveSettings(EmailSettings settings) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyHost, settings.smtpHost);
    await prefs.setInt(_keyPort, settings.smtpPort);
    await prefs.setString(_keyEmail, settings.email);
    await prefs.setString(_keyUsername, settings.username);
    await prefs.setBool(_keySecure, settings.isSecure);

    if (settings.password != null && settings.password!.isNotEmpty) {
      await _storage.write(key: _keyPassword, value: settings.password);
    }
  }

  /// Retrieves SMTP settings. Password is fetched from secure storage.
  static Future<EmailSettings?> getSettings() async {
    final prefs = await SharedPreferences.getInstance();
    final host = prefs.getString(_keyHost);
    if (host == null || host.isEmpty) return null;

    final password = await _storage.read(key: _keyPassword);

    return EmailSettings(
      smtpHost: host,
      smtpPort: prefs.getInt(_keyPort) ?? 587,
      email: prefs.getString(_keyEmail) ?? '',
      username: prefs.getString(_keyUsername) ?? '',
      password: password,
      isSecure: prefs.getBool(_keySecure) ?? true,
    );
  }

  /// Clears all settings.
  static Future<void> clearSettings() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_keyHost);
    await prefs.remove(_keyPort);
    await prefs.remove(_keyEmail);
    await prefs.remove(_keyUsername);
    await prefs.remove(_keySecure);
    await _storage.delete(key: _keyPassword);
  }

  static Future<void> sendInvoiceEmail({
    required EmailSettings settings,
    required Invoice invoice,
    required File pdfFile,
    required String subject,
    required String body,
    required String recipientEmail,
  }) async {
    final smtpServer = SmtpServer(
      settings.smtpHost,
      port: settings.smtpPort,
      username: settings.username,
      password: settings.password,
      ssl: settings.isSecure && settings.smtpPort == 465, // Implicit SSL
      allowInsecure: !settings.isSecure, // Explicit TLS usually startls
      ignoreBadCertificate: false,
    );

    final message = Message()
      ..from = Address(settings.email, settings.username)
      ..recipients.add(recipientEmail)
      ..subject = subject
      ..text = body
      ..attachments.add(FileAttachment(pdfFile));

    try {
      await send(message, smtpServer);
    } on MailerException catch (e) {
      // Re-throw with user friendly message if possible
      throw Exception(
          "Email failed: ${e.message}\nCheck settings or internet.");
    }
  }
}
