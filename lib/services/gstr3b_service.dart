import 'dart:isolate';
import 'package:invobharat/models/invoice.dart';
import 'package:intl/intl.dart';
import 'package:csv/csv.dart';
import 'package:indian_formatters/indian_formatters.dart';

class Gstr3bService {
  Future<String> generateGstr3bCsvAsync(final List<Invoice> invoices) async {
    return Isolate.run(() => generateGstr3bCsv(invoices));
  }

  String generateGstr3bCsv(final List<Invoice> invoices) {
    final List<List<dynamic>> rows = [];

    rows.add([
      'GSTIN',
      'Financial Year',
      'Return Period',
      'Section',
      'Nature of Supplies',
      'GST Rate',
      'Taxable Value',
      'IGST',
      'CGST',
      'SGST',
      'CESS',
    ]);

    final grouped = <String, Map<String, dynamic>>{};

    for (final inv in invoices) {
      if (inv.items.isEmpty) continue;

      final isInter = inv.isInterState;
      // IndianDateFormatter.fiscalYear(date) returns "FY 2025-26"
      // We want something like "2025-26" or similar.
      final fy = IndianDateFormatter.fiscalYear(inv.invoiceDate).replaceAll('FY ', '');
      final period = DateFormat('MM').format(inv.invoiceDate);

      for (final item in inv.items) {
        final rateKey = item.gstRate.toStringAsFixed(2);
        final section = isInter
            ? '3.1(a) - Inter-State'
            : '3.1(b) - Intra-State';
        final nature = isInter
            ? 'Inter-State supplies'
            : 'Intra-State supplies';
        final compositeKey = '$section|$rateKey|$fy|$period';

        if (!grouped.containsKey(compositeKey)) {
          grouped[compositeKey] = {
            'section': section,
            'nature': nature,
            'gstRate': item.gstRate,
            'fy': fy,
            'period': period,
            'taxableValue': 0.0,
            'igst': 0.0,
            'cgst': 0.0,
            'sgst': 0.0,
            'cess': 0.0,
          };
        }

        final entry = grouped[compositeKey]!;
        final taxable = item.netAmount;
        entry['taxableValue'] = (entry['taxableValue'] as double) + taxable;

        if (isInter) {
          entry['igst'] = (entry['igst'] as double) + item.igstAmount;
        } else {
          entry['cgst'] = (entry['cgst'] as double) + item.cgstAmount;
          entry['sgst'] = (entry['sgst'] as double) + item.sgstAmount;
        }
      }
    }

    for (final entry in grouped.values) {
      rows.add([
        '',
        entry['fy'],
        entry['period'],
        entry['section'],
        entry['nature'],
        (entry['gstRate'] as double).toStringAsFixed(2),
        (entry['taxableValue'] as double).toStringAsFixed(2),
        (entry['igst'] as double).toStringAsFixed(2),
        (entry['cgst'] as double).toStringAsFixed(2),
        (entry['sgst'] as double).toStringAsFixed(2),
        (entry['cess'] as double).toStringAsFixed(2),
      ]);
    }

    return const ListToCsvConverter().convert(rows);
  }
}
