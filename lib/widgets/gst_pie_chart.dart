import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';

class GstPieChart extends StatelessWidget {
  final double cgst;
  final double sgst;
  final double igst;
  final String currencySymbol;

  const GstPieChart({
    super.key,
    required this.cgst,
    required this.sgst,
    required this.igst,
    required this.currencySymbol,
  });

  @override
  Widget build(BuildContext context) {
    final totalGst = cgst + sgst + igst;
    
    if (totalGst == 0) {
      return const Center(
        child: Text(
          "No GST data available",
          style: TextStyle(color: Colors.grey),
        ),
      );
    }

    final sections = <PieChartSectionData>[];
    
    if (cgst > 0) {
      sections.add(
        PieChartSectionData(
          color: Colors.blue,
          value: cgst,
          title: 'CGST\n${NumberFormat.compact().format(cgst)}',
          radius: 80,
          titleStyle: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      );
    }
    
    if (sgst > 0) {
      sections.add(
        PieChartSectionData(
          color: Colors.green,
          value: sgst,
          title: 'SGST\n${NumberFormat.compact().format(sgst)}',
          radius: 80,
          titleStyle: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      );
    }
    
    if (igst > 0) {
      sections.add(
        PieChartSectionData(
          color: Colors.orange,
          value: igst,
          title: 'IGST\n${NumberFormat.compact().format(igst)}',
          radius: 80,
          titleStyle: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      );
    }

    return Column(
      children: [
        SizedBox(
          height: 200,
          child: PieChart(
            PieChartData(
              sectionsSpace: 2,
              centerSpaceRadius: 40,
              sections: sections,
              pieTouchData: PieTouchData(
                touchCallback: (FlTouchEvent event, pieTouchResponse) {},
              ),
            ),
          ),
        ),
        const SizedBox(height: 16),
        // Legend
        Wrap(
          spacing: 16,
          runSpacing: 8,
          children: [
            if (cgst > 0)
              _buildLegendItem('CGST', Colors.blue, cgst),
            if (sgst > 0)
              _buildLegendItem('SGST', Colors.green, sgst),
            if (igst > 0)
              _buildLegendItem('IGST', Colors.orange, igst),
          ],
        ),
        const SizedBox(height: 8),
        Text(
          'Total GST: $currencySymbol${NumberFormat('#,##0.00').format(totalGst)}',
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
      ],
    );
  }

  Widget _buildLegendItem(String label, Color color, double value) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 4),
        Text(
          '$label: ${NumberFormat.compact().format(value)}',
          style: const TextStyle(fontSize: 12),
        ),
      ],
    );
  }
}
