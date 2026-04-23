import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:invobharat/mixins/invoice_form_mixin.dart';
import 'package:invobharat/models/client.dart';
import 'package:invobharat/providers/database_provider.dart';
import 'package:invobharat/database/database.dart' hide Client, Invoice, BusinessProfile, InvoiceItem, PaymentTransaction, AppSetting;
import 'package:drift/native.dart';

class TestInvoiceWidget extends ConsumerStatefulWidget {
  const TestInvoiceWidget({super.key});
  @override
  ConsumerState<TestInvoiceWidget> createState() => TestInvoiceState();
}

class TestInvoiceState extends ConsumerState<TestInvoiceWidget>
    with InvoiceFormMixin {
  @override
  void initState() {
    super.initState();
    initInvoiceControllers();
  }

  @override
  void dispose() {
    disposeInvoiceControllers();
    super.dispose();
  }

  @override
  Widget build(final BuildContext context) => Container();
}

void main() {
  testWidgets('InvoiceFormMixin should initialize and sync controllers', (
    final tester,
  ) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          databaseProvider.overrideWithValue(AppDatabase(NativeDatabase.memory())),
        ],
        child: const MaterialApp(home: TestInvoiceWidget()),
      ),
    );
    await tester.pumpAndSettle();

    final state = tester.state<TestInvoiceState>(
      find.byType(TestInvoiceWidget),
    );

    expect(state.invoiceNoCtrl, isNotNull);

    // Test onClientSelected
    final client = const Client(
      id: 'c1',
      name: 'Test Client',
      address: 'Addr',
      gstin: 'GST',
      state: 'S',
      profileId: 'p1',
    );

    state.onClientSelected(client);

    expect(state.receiverNameCtrl.text, 'Test Client');
    expect(state.receiverGstinCtrl.text, 'GST');
  });

  testWidgets('calculateDueDate should work correctly', (final tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          databaseProvider.overrideWithValue(AppDatabase(NativeDatabase.memory())),
        ],
        child: const MaterialApp(home: TestInvoiceWidget()),
      ),
    );
    await tester.pumpAndSettle();
    final state = tester.state<TestInvoiceState>(
      find.byType(TestInvoiceWidget),
    );

    final date = DateTime(2024);

    // Net 30
    expect(state.calculateDueDate(date, 'Net 30'), DateTime(2024, 1, 31));

    // 15 days
    expect(state.calculateDueDate(date, '15 days'), DateTime(2024, 1, 16));

    // Immediate
    expect(state.calculateDueDate(date, 'Immediate'), date);
  });
}
