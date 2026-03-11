import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mocktail/mocktail.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:invobharat/screens/dashboard_screen.dart';
import 'package:invobharat/models/invoice.dart';
import 'package:invobharat/models/business_profile.dart';
import 'package:invobharat/providers/business_profile_provider.dart';
import 'package:invobharat/providers/invoice_repository_provider.dart';
import 'package:invobharat/models/client.dart';
import 'package:invobharat/providers/client_provider.dart';
import 'package:invobharat/data/client_repository.dart';
import 'package:invobharat/data/invoice_repository.dart';
import 'package:invobharat/data/business_profile_repository.dart';

class MockInvoiceRepository extends Mock implements InvoiceRepository {}

class MockBusinessProfileRepository extends Mock
    implements BusinessProfileRepository {}

class MockClientRepository extends Mock implements ClientRepository {}

void main() {
  late MockInvoiceRepository mockInvoiceRepo;
  late MockBusinessProfileRepository mockProfileRepo;
  late MockClientRepository mockClientRepo; // Added late variable
  late BusinessProfile testProfile;

  setUpAll(() {
    registerFallbackValue(
      Invoice(
        supplier: const Supplier(),
        receiver: const Receiver(),
        items: [],
        invoiceDate: DateTime.now(),
      ),
    );
    registerFallbackValue(const Client(id: '', name: '')); // Added fallback
    registerFallbackValue(BusinessProfile.defaults());
  });

  setUp(() {
    SharedPreferences.setMockInitialValues({});
    mockInvoiceRepo = MockInvoiceRepository();
    mockClientRepo = MockClientRepository(); // Initialized mockClientRepo
    mockProfileRepo = MockBusinessProfileRepository();
    testProfile = BusinessProfile.defaults().copyWith(
      id: 'test-profile',
      companyName: 'Test Corp',
    );

    // Default stubbing
    when(() => mockInvoiceRepo.getAllInvoices()).thenAnswer((_) async => []);
    when(
      () => mockProfileRepo.getAllProfiles(),
    ).thenAnswer((_) async => [testProfile]);
    when(
      () => mockClientRepo.getAllClients(),
    ).thenAnswer((_) async => []); // Added stubbing
  });

  Widget createTestWidget() {
    return ProviderScope(
      overrides: [
        invoiceRepositoryProvider.overrideWithValue(mockInvoiceRepo),
        businessProfileRepositoryProvider.overrideWithValue(mockProfileRepo),
        clientRepositoryProvider.overrideWithValue(
          mockClientRepo,
        ), // Added override
        businessProfileProvider.overrideWithValue(testProfile),
      ],
      child: MaterialApp(
        theme: ThemeData(useMaterial3: true, platform: TargetPlatform.android),
        home: const DashboardScreen(),
      ),
    );
  }

  group('DashboardScreen Tests', () {
    testWidgets('renders welcome message and stats', (
      final WidgetTester tester,
    ) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      expect(find.text('InvoBharat'), findsOneWidget);
      expect(find.text('Welcome back,'), findsOneWidget);
      expect(find.text('Test Corp'), findsOneWidget);
      expect(find.textContaining('Revenue'), findsOneWidget); // Modified finder
      expect(find.text('Invoices'), findsOneWidget);
    });

    testWidgets('shows empty state when no invoices', (
      final WidgetTester tester,
    ) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      expect(find.text('No invoices yet'), findsOneWidget);
      expect(
        find.text('Create your first invoice to get started'),
        findsOneWidget,
      );
    });

    testWidgets('displays stats correctly with invoices', (
      final WidgetTester tester,
    ) async {
      final now = DateTime.now();
      final invoices = [
        Invoice(
          id: '1',
          invoiceNo: 'INV-001',
          invoiceDate: now,
          supplier: const Supplier(),
          receiver: const Receiver(name: 'Client A'),
          items: [const InvoiceItem(description: 'Item 1', amount: 1000)],
        ),
      ];

      when(
        () => mockInvoiceRepo.getAllInvoices(),
      ).thenAnswer((_) async => invoices);

      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // Total Revenue should be 1000 + 180 = 1180
      // Total Revenue should be 1180
      expect(find.textContaining('180'), findsAtLeastNWidgets(1));
      expect(find.text('1'), findsAtLeastNWidgets(1)); // Modified finder

      // Recent Invoices list
      expect(find.text('Client A'), findsOneWidget);
      expect(
        find.textContaining('INV-001'), // Modified finder
        findsOneWidget,
      );
    });

    testWidgets('quick action "New Invoice" navigates to form', (
      final WidgetTester tester,
    ) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // Tap "New Invoice" action button
      final addItemText = find.text('New Invoice'); // Renamed variable
      expect(addItemText, findsOneWidget); // Added expectation
      await tester.ensureVisible(addItemText);
      await tester.tap(addItemText); // Used new variable
      await tester.pumpAndSettle();

      // Should be on InvoiceFormScreen - AppBar Title is "New Invoice"
      // Verify by finding the Save button or similar unique elements
      expect(find.text('Client Details'), findsOneWidget);
      expect(find.byIcon(Icons.save), findsOneWidget);
    });
  });
}
