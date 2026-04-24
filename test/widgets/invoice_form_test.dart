import 'package:fluent_ui/fluent_ui.dart' as fluent;
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:mocktail/mocktail.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:drift/native.dart';

import 'package:invobharat/screens/invoice_form.dart';
import 'package:invobharat/models/invoice.dart';
import 'package:invobharat/models/business_profile.dart';
import 'package:invobharat/models/client.dart';
import 'package:invobharat/providers/business_profile_provider.dart';
import 'package:invobharat/providers/client_provider.dart';
import 'package:invobharat/providers/invoice_repository_provider.dart';
import 'package:invobharat/providers/database_provider.dart';
import 'package:invobharat/data/invoice_repository.dart';
import 'package:invobharat/data/client_repository.dart';
import 'package:invobharat/data/business_profile_repository.dart';
import 'package:invobharat/database/database.dart' hide Client, Invoice, BusinessProfile, InvoiceItem, AppSetting;

class MockInvoiceRepository extends Mock implements InvoiceRepository {}

class MockClientRepository extends Mock implements ClientRepository {}

class MockBusinessProfileRepository extends Mock
    implements BusinessProfileRepository {}

void main() {
  late MockInvoiceRepository mockInvoiceRepo;
  late MockClientRepository mockClientRepo;
  late MockBusinessProfileRepository mockProfileRepo;

  setUpAll(() {
    registerFallbackValue(
      Invoice(
        supplier: const Supplier(),
        receiver: const Receiver(),
        items: [],
        invoiceDate: DateTime.now(),
      ),
    );
    registerFallbackValue(const Client(id: '', name: ''));
    registerFallbackValue(BusinessProfile.defaults());
  });

  setUp(() {
    SharedPreferences.setMockInitialValues({});
    mockInvoiceRepo = MockInvoiceRepository();
    mockClientRepo = MockClientRepository();
    mockProfileRepo = MockBusinessProfileRepository();

    // Default stubbing
    when(() => mockInvoiceRepo.getAllInvoices()).thenAnswer((_) async => []);
    when(() => mockClientRepo.getAllClients()).thenAnswer((_) async => []);
    when(
      () => mockProfileRepo.getAllProfiles(),
    ).thenAnswer((_) async => [BusinessProfile.defaults()]);
  });

  Widget createTestWidget() {
    final overrides = [
      invoiceRepositoryProvider.overrideWithValue(mockInvoiceRepo),
      clientRepositoryProvider.overrideWithValue(mockClientRepo),
      businessProfileRepositoryProvider.overrideWithValue(mockProfileRepo),
      databaseProvider.overrideWithValue(AppDatabase(NativeDatabase.memory())),
    ];

    return ProviderScope(
      overrides: overrides,
      child: fluent.FluentApp(
        theme: fluent.FluentThemeData(),
        home: const Material(
          child: InvoiceFormScreen(),
        ),
      ),
    );
  }

  testWidgets('InvoiceFormScreen renders core components', (
    final WidgetTester tester,
  ) async {
    await tester.pumpWidget(createTestWidget());
    await tester.pumpAndSettle();

    expect(find.text('New Invoice'), findsOneWidget);
    expect(find.text('Client Details'), findsOneWidget);
    expect(find.text('Invoice Details'), findsOneWidget);
  });

  testWidgets('Selecting a client updates the form', (
    final WidgetTester tester,
  ) async {
    final testClient = const Client(
      id: '1',
      name: 'Test Client',
      gstin: '27AAPFU0939F1ZV',
      address: 'Mumbai, Maharashtra',
      state: 'Maharashtra',
    );

    when(
      () => mockClientRepo.getAllClients(),
    ).thenAnswer((_) async => [testClient]);

    await tester.pumpWidget(createTestWidget());
    await tester.pumpAndSettle();

    final selectButton = find.widgetWithText(TextButton, 'Select Client');
    await tester.tap(selectButton);
    await tester.pumpAndSettle();

    expect(find.text('Select Client'), findsAtLeastNWidgets(1));
    expect(find.text('Test Client'), findsOneWidget);

    await tester.tap(find.text('Test Client'));
    await tester.pumpAndSettle();

    expect(find.text('Test Client'), findsOneWidget);
    expect(find.text('27AAPFU0939F1ZV'), findsOneWidget);
    expect(find.text('Maharashtra'), findsOneWidget);
  });

  testWidgets('Adding and removing items', (final WidgetTester tester) async {
    await tester.pumpWidget(createTestWidget());
    await tester.pumpAndSettle();

    expect(find.text('GST%'), findsOneWidget);

    final addItemButton = find.text('Add New Item');
    await tester.ensureVisible(addItemButton);
    await tester.tap(addItemButton);
    await tester.pumpAndSettle();

    expect(find.text('GST%'), findsNWidgets(2));

    final deleteButton = find.byIcon(Icons.delete).first;
    await tester.ensureVisible(deleteButton);
    await tester.tap(deleteButton);
    await tester.pumpAndSettle();

    expect(find.text('GST%'), findsOneWidget);
  });
}
