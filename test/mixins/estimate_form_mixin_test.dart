import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:invobharat/mixins/estimate_form_mixin.dart';
import 'package:invobharat/models/client.dart';

class TestEstimateWidget extends ConsumerStatefulWidget {
  const TestEstimateWidget({super.key});
  @override
  ConsumerState<TestEstimateWidget> createState() => TestEstimateState();
}

class TestEstimateState extends ConsumerState<TestEstimateWidget>
    with EstimateFormMixin {
  @override
  void initState() {
    super.initState();
    initEstimateControllers();
  }

  @override
  void dispose() {
    disposeEstimateControllers();
    super.dispose();
  }

  @override
  Widget build(final BuildContext context) => Container();
}

void main() {
  testWidgets('EstimateFormMixin should initialize and sync controllers', (
    final tester,
  ) async {
    await tester.pumpWidget(
      const ProviderScope(child: MaterialApp(home: TestEstimateWidget())),
    );

    final state = tester.state<TestEstimateState>(
      find.byType(TestEstimateWidget),
    );

    expect(state.estimateNoCtrl, isNotNull);

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
    expect(state.receiverAddressCtrl.text, 'Addr');
  });
}
