import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mocktail/mocktail.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:invobharat/screens/invoice_form.dart';
import 'package:invobharat/models/invoice.dart';
import 'package:invobharat/models/business_profile.dart';
import 'package:invobharat/models/client.dart';
import 'package:invobharat/providers/business_profile_provider.dart';
import 'package:invobharat/providers/client_provider.dart';
import 'package:invobharat/providers/invoice_repository_provider.dart';
import 'package:invobharat/data/invoice_repository.dart';
import 'package:invobharat/data/client_repository.dart';
import 'package:invobharat/data/business_profile_repository.dart';

class MockInvoiceRepository extends Mock implements InvoiceRepository {}

class MockClientRepository extends Mock implements ClientRepository {}

class MockBusinessProfileRepository extends Mock
    implements BusinessProfileRepository {}

void main() {
  late MockInvoiceRepository mockInvoiceRepo;
  late MockClientRepository mockClientRepo;
  late MockBusinessProfileRepository mockProfileRepo;

  setUpAll(() {
    GoogleFonts.config.allowRuntimeFetching = false;
    registerFallbackValue(
      Invoice(
        supplier: const Supplier(),
        receiver: const Receiver(),
        items: [],
        invoiceDate: DateTime.now(),
      ),
    );
    registerFallbackValue(
      const Client(id: '', name: ''),
    );
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
    ];

    return ProviderScope(
      overrides: overrides,
      child: MaterialApp(
        theme: ThemeData(
          useMaterial3: true,
          platform:
              TargetPlatform.android, // Force Android for stable widget testing
        ),
        home: const InvoiceFormScreen(),
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
      gstin: '27AAAAA0000A1Z5',
      address: 'Mumbai, Maharashtra',
      state: 'Maharashtra',
    );

    when(
      () => mockClientRepo.getAllClients(),
    ).thenAnswer((_) async => [testClient]);

    await tester.pumpWidget(createTestWidget());
    await tester.pumpAndSettle();

    // Find the "Select Client" button specifically (it's a TextButton.icon)
    final selectButton = find.widgetWithText(TextButton, 'Select Client');
    await tester.tap(selectButton);
    await tester.pumpAndSettle();

    // Verify dialog title and client list
    expect(find.text('Select Client'), findsAtLeastNWidgets(1));
    expect(find.text('Test Client'), findsOneWidget);

    // Tap on the client in the list
    await tester.tap(find.text('Test Client'));
    await tester.pumpAndSettle();

    // Verify form is updated
    expect(find.text('Test Client'), findsOneWidget);
    expect(find.text('27AAAAA0000A1Z5'), findsOneWidget);
    expect(find.text('Maharashtra'), findsOneWidget);
  });

  testWidgets('Adding and removing items', (final WidgetTester tester) async {
    await tester.pumpWidget(createTestWidget());
    await tester.pumpAndSettle();

    // Initial state has 1 empty item
    expect(find.text('GST%'), findsOneWidget);

    // Tap "Add New Item"
    final addItemButton = find.text('Add New Item');
    await tester.ensureVisible(addItemButton);
    await tester.tap(addItemButton);
    await tester.pumpAndSettle();

    expect(find.text('GST%'), findsNWidgets(2));

    // Tap delete on the first item
    final deleteButton = find.byIcon(Icons.delete).first;
    await tester.ensureVisible(deleteButton);
    await tester.tap(deleteButton);
    await tester.pumpAndSettle();

    expect(find.text('GST%'), findsOneWidget);
  });
}
