import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter/material.dart' as material;
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:invobharat/screens/windows/fluent_invoice_wizard.dart';
import 'package:invobharat/providers/business_profile_provider.dart';
import 'package:invobharat/models/business_profile.dart';

void main() {
  testWidgets('FluentInvoiceWizard should render on Windows', (final tester) async {
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
        child: const FluentApp(
          home: material.Material(
            child: FluentInvoiceWizard(),
          ),
        ),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.text('New Invoice'), findsOneWidget);
    expect(find.text('Bill To'), findsOneWidget);
    expect(find.text('Invoice Details'), findsOneWidget);
  });
}
