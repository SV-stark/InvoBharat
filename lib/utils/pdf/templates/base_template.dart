import 'dart:typed_data';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import '../../../models/invoice.dart';
import '../../../models/business_profile.dart';
import '../../invoice_template.dart';

abstract class BasePdfTemplate implements InvoiceTemplate {
  @override
  String get name;

  @override
  Future<Uint8List> generate(
      Invoice invoice, BusinessProfile profile, pw.Font font, pw.Font fontBold,
      {String? title});

  pw.Widget buildItemsTable(Invoice invoice,
      {bool includeIndex = true,
      pw.TextStyle? headerStyle,
      pw.TextStyle? cellStyle,
      pw.BoxDecoration? headerDecoration,
      pw.BoxDecoration? oddRowDecoration,
      pw.TableBorder? border,
      Map<int, pw.TableColumnWidth>? columnWidths,
      Map<int, pw.Alignment>? cellAlignments,
      pw.EdgeInsets? cellPadding}) {
    final isInterState = invoice.isInterState;

    List<String> headers = [];
    if (includeIndex) headers.add('#');
    headers.addAll(['Item', 'HSN/SAC', 'Qty', 'Rate', 'Taxable Val']);

    if (isInterState) {
      headers.addAll(['IGST %', 'IGST Amt']);
    } else {
      headers.addAll(['CGST %', 'CGST Amt', 'SGST %', 'SGST Amt']);
    }
    headers.add('Total');

    final data = invoice.items.asMap().entries.map((e) {
      final item = e.value;
      final taxableValue = item.netAmount;

      final row = <String>[];
      if (includeIndex) row.add((e.key + 1).toString());

      row.add(item.description);
      row.add(item.sacCode);
      row.add("${item.quantity} ${item.unit}");
      row.add(item.amount.toStringAsFixed(2));
      row.add(taxableValue.toStringAsFixed(2));

      if (isInterState) {
        row.add("${item.gstRate}%");
        row.add(item.calculateIgst(true).toStringAsFixed(2));
      } else {
        final halfRate = item.gstRate / 2;
        row.add("$halfRate%");
        row.add(item.calculateCgst(false).toStringAsFixed(2));
        row.add("$halfRate%");
        row.add(item.calculateSgst(false).toStringAsFixed(2));
      }

      row.add(item.totalAmount.toStringAsFixed(2));
      return row;
    }).toList();

    return pw.TableHelper.fromTextArray(
        headers: headers,
        data: data,
        border: border ??
            const pw.TableBorder(
              top: pw.BorderSide(color: PdfColors.grey300),
              bottom: pw.BorderSide(color: PdfColors.grey300),
              horizontalInside: pw.BorderSide(color: PdfColors.grey200),
            ),
        headerStyle: headerStyle ??
            pw.TextStyle(fontSize: 8, fontWeight: pw.FontWeight.bold),
        cellStyle: cellStyle ?? const pw.TextStyle(fontSize: 8),
        headerDecoration: headerDecoration,
        oddRowDecoration: oddRowDecoration,
        columnWidths: columnWidths ??
            {
              if (includeIndex)
                1: const pw.FlexColumnWidth(3)
              else
                0: const pw.FlexColumnWidth(3),
            },
        cellAlignments: cellAlignments ??
            {
              0: pw.Alignment.centerLeft,
              1: pw.Alignment.centerLeft,
              2: pw.Alignment.centerLeft,
              3: pw.Alignment.centerRight,
              4: pw.Alignment.centerRight,
              5: pw.Alignment.centerRight,
              headers.length - 1: pw.Alignment.centerRight,
            },
        cellPadding: cellPadding ??
            const pw.EdgeInsets.symmetric(vertical: 8, horizontal: 4));
  }

  pw.Widget buildSummaryRow(String label, double value, String symbol,
      {bool isBold = false}) {
    return pw.Padding(
        padding: const pw.EdgeInsets.symmetric(vertical: 2),
        child: pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
            children: [
              pw.Text(label,
                  style: pw.TextStyle(
                      fontSize: 9,
                      fontWeight: isBold ? pw.FontWeight.bold : null)),
              pw.Text("$symbol ${value.toStringAsFixed(2)}",
                  style: pw.TextStyle(
                      fontSize: 9,
                      fontWeight: isBold ? pw.FontWeight.bold : null)),
            ]));
  }

  pw.Widget buildField(String label, String value, pw.TextStyle labelStyle,
      pw.TextStyle valueStyle) {
    return pw.Row(mainAxisSize: pw.MainAxisSize.min, children: [
      pw.Text("$label: ", style: labelStyle),
      pw.Text(value, style: valueStyle),
    ]);
  }
}
