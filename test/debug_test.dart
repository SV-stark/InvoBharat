import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:invobharat/main.dart';

import 'package:invobharat/models/invoice.dart';
import 'package:invobharat/providers/invoice_repository_provider.dart';
import 'package:flutter/material.dart';

void main() {
  testWidgets('Debug Dashboard', (WidgetTester tester) async {
    SharedPreferences.setMockInitialValues({});

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          invoiceListProvider.overrideWith((ref) => Future.value(<Invoice>[])),
        ],
        child: const InvoBharatApp(),
      ),
    );

    await tester.pump();
    await tester.pump(const Duration(seconds: 1));
    await tester.pump();

    debugPrint("Checking for Error text...");
    if (find.textContaining('Error:').evaluate().isNotEmpty) {
      debugPrint(
          "Found Error: ${find.textContaining('Error:').evaluate().first}");
      // Print the actual error text widget
      final errorWidget = tester.widget<Text>(find.textContaining('Error:'));
      debugPrint("Error Message: ${errorWidget.data}");
    } else {
      debugPrint("No Error text found.");
    }

    debugPrint("Checking for New Invoice text...");
    if (find.text('New Invoice').evaluate().isEmpty) {
      debugPrint("New Invoice NOT found.");
      // Dump all text widgets
      final textWidgets = find.byType(Text).evaluate();
      debugPrint("Found ${textWidgets.length} Text widgets:");
      for (final widget in textWidgets) {
        final text = (widget.widget as Text).data;
        debugPrint(" - '$text'");
      }
    } else {
      debugPrint("New Invoice found!");
    }
  });
}
