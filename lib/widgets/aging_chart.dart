import 'package:fl_chart/fl_chart.dart';
import 'package:fluent_ui/fluent_ui.dart';
import 'package:intl/intl.dart';

class AgingChart extends StatelessWidget {
  final Map<String, double> agingData;
  const AgingChart({super.key, required this.agingData});

  @override
  Widget build(final BuildContext context) {
    // Filter out zero values
    final data = Map.fromEntries(agingData.entries.where((final e) => e.value > 0));

    if (data.isEmpty) {
      return const Center(child: Text("No aging data available"));
    }

    final total = data.values.fold(0.0, (final sum, final val) => sum + val);

    return Row(
      children: [
        Expanded(
          flex: 2,
          child: PieChart(
            PieChartData(
              sections: data.entries.map((final e) {
                final color = _getColorForKey(e.key);
                final percentage = (e.value / total) * 100;
                return PieChartSectionData(
                  color: color,
                  value: e.value,
                  title: "${percentage.toStringAsFixed(0)}%",
                  radius: 50,
                  titleStyle: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: Colors.white),
                );
              }).toList(),
              sectionsSpace: 2,
              centerSpaceRadius: 40,
            ),
          ),
        ),
        const SizedBox(width: 20),
        Expanded(
          flex: 3,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: data.entries.map((final e) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 8.0),
                child: Row(
                  children: [
                    Container(
                      width: 12,
                      height: 12,
                      color: _getColorForKey(e.key),
                    ),
                    const SizedBox(width: 8),
                    Text("${e.key}: ",
                        style: const TextStyle(fontWeight: FontWeight.bold)),
                    Text(NumberFormat.currency(symbol: '₹').format(e.value)),
                  ],
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }

  Color _getColorForKey(final String key) {
    switch (key) {
      case "Current":
        return Colors.green;
      case "1-30 Days":
        return Colors.yellow;
      case "31-60 Days":
        return Colors.orange;
      case "61-90 Days":
        return Colors.red;
      case "90+ Days":
        return Colors.purple; // Dark red/Purple
      default:
        return Colors.grey;
    }
  }
}
