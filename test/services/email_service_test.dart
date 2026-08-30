import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:drift/native.dart';
import 'package:invobharat/database/database.dart' hide Invoice;
import 'package:invobharat/services/email_service.dart';
import 'package:invobharat/models/invoice.dart';
import 'package:mailer/mailer.dart';
import 'package:mailer/smtp_server.dart';

class MockSecureStorage extends Mock implements FlutterSecureStorage {}

class MockMessage extends Mock implements Message {}

class MockPersistentConnection extends Mock implements PersistentConnection {}

void main() {
  setUpAll(() {
    registerFallbackValue(Message());
    registerFallbackValue(SmtpServer('host'));
  });

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  group('EmailService', () {
    test(
      'sendInvoiceEmail calls the sendFunction with correct message',
      () async {
        final settings = EmailSettings(
          smtpHost: 'smtp.test.com',
          smtpPort: 465,
          email: 'sender@test.com',
          username: 'senderName',
          password: 'pass',
        );

        final invoice = Invoice(
          invoiceNo: '123',
          invoiceDate: DateTime.now(),
          supplier: const Supplier(name: 'S'),
          receiver: const Receiver(name: 'R'),
        );

        final pdfFile = File('dummy.pdf');
        bool called = false;

        await EmailService.sendInvoiceEmail(
          settings: settings,
          invoice: invoice,
          pdfFile: pdfFile,
          subject: 'Test Subject',
          body: 'Test Body',
          recipientEmail: 'client@test.com',
          sendFunction: (final message, final server) async {
            called = true;
            expect(message.subject, 'Test Subject');
            expect(
              message.recipients.first.toString(),
              contains('client@test.com'),
            );
            expect(server.host, 'smtp.test.com');
            return MockPersistentConnection();
          },
        );

        expect(called, isTrue);
      },
    );

    test('saveSettings and getSettings securely stores credentials', () async {
      FlutterSecureStorage.setMockInitialValues({});
      final db = AppDatabase(NativeDatabase.memory());
      final service = EmailService(settingsService: AppSettingsService(db));

      final settings = EmailSettings(
        smtpHost: 'smtp.office365.com',
        smtpPort: 587,
        email: 'billing@company.com',
        username: 'Billing Dept',
        password: 'SuperSecretPassword123!',
      );

      await service.saveSettings(settings);

      final retrieved = await service.getSettings();
      expect(retrieved, isNotNull);
      expect(retrieved!.smtpHost, 'smtp.office365.com');
      expect(retrieved.smtpPort, 587);
      expect(retrieved.email, 'billing@company.com');
      expect(retrieved.username, 'Billing Dept');
      expect(retrieved.password, 'SuperSecretPassword123!');
      expect(retrieved.isSecure, isTrue);

      await service.clearSettings();
      final afterClear = await service.getSettings();
      expect(afterClear, isNull);

      await db.close();
    });
  });
}
