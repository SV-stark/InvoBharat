import 'package:fl_chart/fl_chart.dart';
import 'package:fluent_ui/fluent_ui.dart';
import 'package:intl/intl.dart';

class RevenueChart extends StatelessWidget {
  final Map<String, double> monthlyData;
  // monthlyData keys expected to be "yyyy-MM"

  const RevenueChart({super.key, required this.monthlyData});

  @override
  Widget build(BuildContext context) {
    if (monthlyData.isEmpty) {
      return const Center(child: Text("No data for chart"));
    }

    // Sort keys
    final sortedKeys = monthlyData.keys.toList()..sort();
    // Take last 6 months
    final displayKeys = sortedKeys.length > 6
        ? sortedKeys.sublist(sortedKeys.length - 6)
        : sortedKeys;

    final spots = displayKeys.asMap().entries.map((e) {
      return FlSpot(e.key.toDouble(), monthlyData[e.value]!);
    }).toList();

    final maxY = spots.isEmpty
        ? 1000.0
        : spots.map((e) => e.y).reduce((a, b) => a > b ? a : b) * 1.2;

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("Revenue Trend (Last 6 Months)",
              style: FluentTheme.of(context).typography.subtitle),
          const SizedBox(height: 20),
          Expanded(
            child: LineChart(
              LineChartData(
                gridData: const FlGridData(show: true, drawVerticalLine: false),
                titlesData: FlTitlesData(
                  show: true,
                  rightTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false)),
                  topTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false)),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 30,
                      getTitlesWidget: (value, meta) {
                        final index = value.toInt();
                        if (index >= 0 && index < displayKeys.length) {
                          final date =
                              DateFormat("yyyy-MM").parse(displayKeys[index]);
                          return SideTitleWidget(
                            meta: meta,
                            child: Text(DateFormat("MMM").format(date),
                                style: const TextStyle(fontSize: 10)),
                          );
                        }
                        return const Text('');
                      },
                    ),
                  ),
                  leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                          showTitles: true,
                          reservedSize: 45,
                          getTitlesWidget: (value, meta) {
                            return Text(NumberFormat.compact().format(value),
                                style: const TextStyle(fontSize: 10));
                          })),
                ),
                borderData: FlBorderData(show: false),
                minX: 0,
                maxX: (displayKeys.length - 1).toDouble(),
                minY: 0,
                maxY: maxY,
                lineBarsData: [
                  LineChartBarData(
                    spots: spots,
                    isCurved: true,
                    color: FluentTheme.of(context).accentColor,
                    barWidth: 3,
                    isStrokeCapRound: true,
                    dotData: const FlDotData(show: true),
                    belowBarData: BarAreaData(
                      show: true,
                      color: FluentTheme.of(context)
                          .accentColor
                          .withValues(alpha: 0.1),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
