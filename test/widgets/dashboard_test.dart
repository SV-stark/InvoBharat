import 'package:fluent_ui/fluent_ui.dart' as fluent;
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
      child: fluent.FluentApp(
        theme: fluent.FluentThemeData(),
        home: const Material(
          child: DashboardScreen(),
        ),
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
    });
  });
}
