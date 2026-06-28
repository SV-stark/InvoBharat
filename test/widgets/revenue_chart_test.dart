import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:invobharat/widgets/revenue_chart.dart';
import 'package:fluent_ui/fluent_ui.dart' as fluent;

void main() {
  Widget createChartWidget(Map<String, double> monthlyData) {
    return fluent.FluentApp(
      home: fluent.ScaffoldPage(
        content: SizedBox(
          width: 400,
          height: 300,
          child: RevenueChart(monthlyData: monthlyData),
        ),
      ),
    );
  }

  group('RevenueChart Tests', () {
    testWidgets('renders empty state correctly', (final WidgetTester tester) async {
      await tester.pumpWidget(createChartWidget({}));
      await tester.pumpAndSettle();

      expect(find.text("No data for chart"), findsOneWidget);
    });

    testWidgets('renders zero data without crashing', (final WidgetTester tester) async {
      await tester.pumpWidget(createChartWidget({
        '2024-01': 0.0,
        '2024-02': 0.0,
      }));
      await tester.pumpAndSettle();

      expect(find.text("Revenue Trend (Last 6 Months)"), findsOneWidget);
    });

    testWidgets('handles malformed date key gracefully', (final WidgetTester tester) async {
      await tester.pumpWidget(createChartWidget({
        '2024-01': 100.0,
        'bad-date-format': 200.0,
      }));
      await tester.pumpAndSettle();

      expect(find.text("Revenue Trend (Last 6 Months)"), findsOneWidget);
    });
  });
}
