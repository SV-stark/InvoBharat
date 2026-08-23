import 'dart:isolate';
import 'package:invobharat/models/invoice.dart';
import 'package:intl/intl.dart';
import 'package:csv/csv.dart';
import 'package:indian_formatters/indian_formatters.dart';

class Gstr3bService {
  Future<String> generateGstr3bCsvAsync(final List<Invoice> invoices) async {
    return Isolate.run(() => generateGstr3bCsv(invoices));
  }

  static dynamic _sanitize(final dynamic value) {
    if (value == null) return '';
    final str = value.toString();
    if (str.isEmpty) return str;
    final firstChar = str[0];
    if (firstChar == '=' || firstChar == '+' || firstChar == '-' || firstChar == '@' || firstChar == '\t' || firstChar == '\r') {
      return "'$str";
    }
    return str;
  }

  String generateGstr3bCsv(final List<Invoice> invoices) {
    final validInvoices = invoices.where((inv) =>
      inv.status.toLowerCase() != 'draft' &&
      inv.type != InvoiceType.deliveryChallan
    ).toList();

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

    for (final inv in validInvoices) {
      if (inv.items.isEmpty) continue;

      final isInter = inv.isInterState;
      final multiplier = inv.type == InvoiceType.creditNote ? -1.0 : 1.0;
      // IndianDateFormatter.fiscalYear(date) returns "FY 2025-26"
      // We want something like "2025-26" or similar.
      final fy = IndianDateFormatter.fiscalYear(
        inv.invoiceDate,
      ).replaceAll('FY ', '');
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
        final taxable = item.netAmount * multiplier;
        entry['taxableValue'] = (entry['taxableValue'] as double) + taxable;

        if (isInter) {
          entry['igst'] = (entry['igst'] as double) + (item.igstAmount * multiplier);
        } else {
          entry['cgst'] = (entry['cgst'] as double) + (item.cgstAmount * multiplier);
          entry['sgst'] = (entry['sgst'] as double) + (item.sgstAmount * multiplier);
        }
      }
    }

    for (final entry in grouped.values) {
      rows.add([
        '',
        _sanitize(entry['fy']),
        _sanitize(entry['period']),
        _sanitize(entry['section']),
        _sanitize(entry['nature']),
        (entry['gstRate'] as double).toStringAsFixed(2),
        (entry['taxableValue'] as double).toStringAsFixed(2),
        (entry['igst'] as double).toStringAsFixed(2),
        (entry['cgst'] as double).toStringAsFixed(2),
        (entry['sgst'] as double).toStringAsFixed(2),
        (entry['cess'] as double).toStringAsFixed(2),
      ]);
    }

    return Csv().encode(rows);
  }
}
