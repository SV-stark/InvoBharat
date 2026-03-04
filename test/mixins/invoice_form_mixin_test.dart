import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:invobharat/mixins/invoice_form_mixin.dart';
import 'package:invobharat/models/client.dart';

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
  Widget build(BuildContext context) => Container();
}

void main() {
  testWidgets('InvoiceFormMixin should initialize and sync controllers', (
    tester,
  ) async {
    await tester.pumpWidget(
      const ProviderScope(child: MaterialApp(home: TestInvoiceWidget())),
    );

    final state = tester.state<TestInvoiceState>(
      find.byType(TestInvoiceWidget),
    );

    expect(state.invoiceNoCtrl, isNotNull);

    // Test onClientSelected
    final client = Client(
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

  testWidgets('calculateDueDate should work correctly', (tester) async {
    await tester.pumpWidget(
      const ProviderScope(child: MaterialApp(home: TestInvoiceWidget())),
    );
    final state = tester.state<TestInvoiceState>(
      find.byType(TestInvoiceWidget),
    );

    final date = DateTime(2024, 1, 1);

    // Net 30
    expect(state.calculateDueDate(date, 'Net 30'), DateTime(2024, 1, 31));

    // 15 days
    expect(state.calculateDueDate(date, '15 days'), DateTime(2024, 1, 16));

    // Immediate
    expect(state.calculateDueDate(date, 'Immediate'), date);
  });
}
