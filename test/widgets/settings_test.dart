import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mocktail/mocktail.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:invobharat/screens/settings_screen.dart';
import 'package:invobharat/models/business_profile.dart';
import 'package:invobharat/providers/business_profile_provider.dart';
import 'package:invobharat/providers/database_provider.dart';
import 'package:invobharat/data/business_profile_repository.dart';

import 'package:invobharat/database/database.dart' as db;

class MockBusinessProfileRepository extends Mock
    implements BusinessProfileRepository {}

class MockAppSettingsService extends Mock implements db.AppSettingsService {}

void main() {
  late MockBusinessProfileRepository mockProfileRepo;
  late MockAppSettingsService mockSettingsService;
  late BusinessProfile testProfile;

  setUpAll(() {
    registerFallbackValue(BusinessProfile.defaults());
  });

  setUp(() {
    SharedPreferences.setMockInitialValues({});
    mockProfileRepo = MockBusinessProfileRepository();
    mockSettingsService = MockAppSettingsService();
    testProfile = BusinessProfile.defaults().copyWith(
      id: 'test-profile',
      companyName: 'Test Corp',
      address: 'Test Address',
    );

    when(
      () => mockProfileRepo.getAllProfiles(),
    ).thenAnswer((_) async => [testProfile]);
    when(
      () => mockSettingsService.getSetting(any()),
    ).thenAnswer((_) async => null);
    when(
      () => mockSettingsService.setSetting(any(), any()),
    ).thenAnswer((_) async => Future.value());
    when(() => mockProfileRepo.saveProfile(any())).thenAnswer((_) async => 1);
  });

  Widget createTestWidget() {
    return ProviderScope(
      overrides: [
        businessProfileRepositoryProvider.overrideWithValue(mockProfileRepo),
        appSettingsServiceProvider.overrideWithValue(mockSettingsService),
        // We override the list provider which will use our mock repo to load testProfile
        businessProfileListProvider.overrideWith(
          () => BusinessProfileList(),
        ),
        activeProfileIdProvider.overrideWith(() => ActiveProfileId()),
      ],
      child: MaterialApp(
        theme: ThemeData(useMaterial3: true, platform: TargetPlatform.android),
        home: const SettingsScreen(),
      ),
    );
  }

  group('SettingsScreen Tests', () {
    testWidgets('renders all tabs', (final WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      expect(find.text('Settings'), findsAtLeastNWidgets(1));
      expect(find.widgetWithText(Tab, 'General'), findsOneWidget);
      expect(find.widgetWithText(Tab, 'Profiles'), findsOneWidget);
      expect(find.widgetWithText(Tab, 'Backup'), findsOneWidget);
      expect(find.widgetWithText(Tab, 'Email'), findsOneWidget);
      expect(find.widgetWithText(Tab, 'About'), findsOneWidget);
    });

    testWidgets('can switch between tabs', (final WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // Start on General
      expect(find.text('Appearance'), findsOneWidget);

      // Switch to Profiles
      await tester.tap(find.widgetWithText(Tab, 'Profiles'));
      await tester.pumpAndSettle();
      expect(find.text('Manage Profiles'), findsOneWidget);

      // Switch to Backup
      await tester.tap(find.widgetWithText(Tab, 'Backup'));
      await tester.pumpAndSettle();
      expect(find.text('Backup & Restore'), findsOneWidget);
    });

    testWidgets('updates general text fields', (
      final WidgetTester tester,
    ) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // Check loaded data by label instead of value for the widget finder
      final nameField = find.widgetWithText(TextFormField, 'Company Name');
      expect(nameField, findsOneWidget);

      // Update a field
      await tester.enterText(nameField, 'New Corp');
      await tester.pumpAndSettle();
      expect(find.text('New Corp'), findsOneWidget);
    });

    testWidgets('theme selection works', (final WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // Find theme dropdown
      final dropdown = find.byType(DropdownButton<ThemeMode>);
      expect(dropdown, findsOneWidget);

      await tester.tap(dropdown);
      await tester.pumpAndSettle();

      // Tap "Dark"
      await tester.tap(find.text('Dark').last);
      await tester.pumpAndSettle();

      // Verify it's set in state (difficult to verify visual theme in widget test easily without complicated checks,
      // but we can check if it's called)
      verify(
        () => mockSettingsService.setSetting(
          'theme_mode',
          ThemeMode.dark.toString(),
        ),
      ).called(1);
    });
  });
}
