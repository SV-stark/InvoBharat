import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:invobharat/screens/invoice_form.dart';
import 'package:invobharat/providers/business_profile_provider.dart';
import 'package:invobharat/models/business_profile.dart';

void main() {
  testWidgets('InvoiceFormScreen should render', (final tester) async {
    // Provide a default business profile so it doesn't fail
    final profile = BusinessProfile(
      id: 'p1',
      companyName: 'Test Biz',
      address: 'Addr',
      gstin: 'GST',
      email: 'e@b.com',
      phone: '123',
      state: 'Maharashtra',
      pan: 'ABCDE1234F',
      colorValue: 0xFF000000,
    );

    await tester.pumpWidget(
      ProviderScope(
        overrides: [businessProfileProvider.overrideWithValue(profile)],
        child: const MaterialApp(home: InvoiceFormScreen()),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.text('New Invoice'), findsOneWidget);
    expect(find.text('Save'), findsOneWidget);
    expect(find.byType(TextFormField), findsAtLeastNWidgets(3));
  });
}
