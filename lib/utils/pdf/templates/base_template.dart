import 'dart:typed_data';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:invobharat/models/invoice.dart';
import 'package:invobharat/models/business_profile.dart';
import 'package:invobharat/utils/invoice_template.dart';
import 'package:invobharat/utils/formatters.dart';
import 'package:intl/intl.dart';

abstract class BasePdfTemplate implements InvoiceTemplate {
  @override
  String get name;

  @override
  Future<Uint8List> generate(
    final Invoice invoice,
    final BusinessProfile profile,
    final pw.Font font,
    final pw.Font fontBold, {
    final String? title,
  });

  pw.Widget buildItemsTable(
    final Invoice invoice, {
    final bool includeIndex = true,
    final pw.TextStyle? headerStyle,
    final pw.TextStyle? cellStyle,
    final pw.BoxDecoration? headerDecoration,
    final pw.BoxDecoration? oddRowDecoration,
    final pw.TableBorder? border,
    final Map<int, pw.TableColumnWidth>? columnWidths,
    final Map<int, pw.Alignment>? cellAlignments,
    final pw.EdgeInsets? cellPadding,
  }) {
    final isInterState = invoice.isInterState;

    final List<String> headers = [];
    if (includeIndex) headers.add('#');
    headers.addAll(['Item', 'HSN/SAC', 'Qty', 'Rate', 'Taxable Val']);

    if (isInterState) {
      headers.addAll(['IGST %', 'IGST Amt']);
    } else {
      headers.addAll(['CGST %', 'CGST Amt', 'SGST %', 'SGST Amt']);
    }
    headers.add('Total');

    final data = invoice.items.asMap().entries.map((final e) {
      final item = e.value;
      final taxableValue = item.netAmount;

      final row = <String>[];
      if (includeIndex) row.add((e.key + 1).toString());

      row.add(item.description);
      row.add(item.cleanSacCode);
      row.add("${item.quantity} ${item.unit}");
      row.add(item.amount.toIndianFormat());
      row.add(taxableValue.toIndianFormat());

      if (isInterState) {
        row.add("${item.gstRate}%");
        row.add(item.calculateIgst(true).toIndianFormat());
      } else {
        final halfRate = item.gstRate / 2;
        final halfRateStr = halfRate == halfRate.truncateToDouble()
            ? halfRate.toInt().toString()
            : halfRate.toStringAsFixed(1);
        row.add("$halfRateStr%");
        row.add(item.calculateCgst(false).toIndianFormat());
        row.add("$halfRateStr%");
        row.add(item.calculateSgst(false).toIndianFormat());
      }

      row.add(item.totalAmount.toIndianFormat());
      return row;
    }).toList();

    return pw.TableHelper.fromTextArray(
      headers: headers,
      data: data,
      border:
          border ??
          const pw.TableBorder(
            top: pw.BorderSide(color: PdfColors.grey300),
            bottom: pw.BorderSide(color: PdfColors.grey300),
            horizontalInside: pw.BorderSide(color: PdfColors.grey200),
          ),
      headerStyle:
          headerStyle ??
          pw.TextStyle(fontSize: 8, fontWeight: pw.FontWeight.bold),
      cellStyle: cellStyle ?? const pw.TextStyle(fontSize: 8),
      headerDecoration: headerDecoration,
      oddRowDecoration: oddRowDecoration,
      columnWidths:
          columnWidths ??
          {
            if (includeIndex)
              1: const pw.FlexColumnWidth(3)
            else
              0: const pw.FlexColumnWidth(3),
          },
      cellAlignments:
          cellAlignments ??
          {
            0: pw.Alignment.centerLeft,
            1: pw.Alignment.centerLeft,
            2: pw.Alignment.centerLeft,
            3: pw.Alignment.centerRight,
            4: pw.Alignment.centerRight,
            5: pw.Alignment.centerRight,
            6: pw.Alignment.centerRight,
            7: pw.Alignment.centerRight,
            8: pw.Alignment.centerRight,
            9: pw.Alignment.centerRight,
            10: pw.Alignment.centerRight,
          },
      cellPadding:
          cellPadding ??
          const pw.EdgeInsets.symmetric(vertical: 4, horizontal: 4),
    );
  }

  pw.Widget buildSummaryRow(
    final String label,
    final double value,
    final String? symbol, {
    final bool isBold = false,
  }) {
    return pw.Padding(
      padding: const pw.EdgeInsets.symmetric(vertical: 2),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.Text(
            label,
            style: pw.TextStyle(
              fontSize: 9,
              fontWeight: isBold ? pw.FontWeight.bold : null,
            ),
          ),
          pw.Text(
            symbol != null
                ? "$symbol ${value.toIndianFormat()}"
                : value.toIndianFormat(),
            style: pw.TextStyle(
              fontSize: 9,
              fontWeight: isBold ? pw.FontWeight.bold : null,
            ),
          ),
        ],
      ),
    );
  }

  pw.Widget buildField(
    final String label,
    final String value,
    final pw.TextStyle labelStyle,
    final pw.TextStyle valueStyle,
  ) {
    return pw.Row(
      mainAxisSize: pw.MainAxisSize.min,
      children: [
        pw.Text("$label: ", style: labelStyle),
        pw.Text(value, style: valueStyle),
      ],
    );
  }

  pw.Widget buildAmountInWords(final double amount) {
    return pw.Padding(
      padding: const pw.EdgeInsets.symmetric(vertical: 4),
      child: pw.Row(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(
            "Amount in words: ",
            style: pw.TextStyle(fontSize: 9, fontWeight: pw.FontWeight.bold),
          ),
          pw.Expanded(
            child: pw.Text(
              amount.toChequeFormat(),
              style: pw.TextStyle(fontSize: 9, fontStyle: pw.FontStyle.italic),
            ),
          ),
        ],
      ),
    );
  }

  pw.Widget buildPaymentQRCode(
    final String upiId,
    final String name,
    final double amount, [
    final String? invoiceNo,
  ]) {
    if (upiId.isEmpty) return pw.SizedBox();

    // Standard UPI deep link format
    String upiUrl =
        "upi://pay?pa=$upiId&pn=${Uri.encodeComponent(name)}&am=${amount.toStringAsFixed(2)}&cu=INR";
    if (invoiceNo != null && invoiceNo.isNotEmpty) {
      upiUrl +=
          "&tr=${Uri.encodeComponent(invoiceNo)}&tn=${Uri.encodeComponent('Invoice $invoiceNo')}";
    }

    return pw.Column(
      children: [
        pw.Container(
          width: 80,
          height: 80,
          padding: const pw.EdgeInsets.all(4),
          decoration: pw.BoxDecoration(
            border: pw.Border.all(color: PdfColors.grey300),
            borderRadius: const pw.BorderRadius.all(pw.Radius.circular(4)),
          ),
          child: pw.BarcodeWidget(
            barcode: pw.Barcode.qrCode(),
            data: upiUrl,
            drawText: false,
          ),
        ),
        pw.SizedBox(height: 4),
        pw.Text("Scan to Pay", style: const pw.TextStyle(fontSize: 7)),
      ],
    );
  }

  pw.Widget buildOriginalInvoiceInfo(final Invoice invoice) {
    if (invoice.type != InvoiceType.creditNote &&
        invoice.type != InvoiceType.debitNote) {
      return pw.SizedBox();
    }

    if (invoice.originalInvoiceNumber == null ||
        invoice.originalInvoiceNumber!.isEmpty) {
      return pw.SizedBox();
    }

    return pw.Container(
      margin: const pw.EdgeInsets.only(top: 8),
      padding: const pw.EdgeInsets.all(8),
      decoration: const pw.BoxDecoration(
        color: PdfColors.grey100,
        borderRadius: pw.BorderRadius.all(pw.Radius.circular(4)),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(
            "Original Invoice Reference",
            style: pw.TextStyle(fontSize: 9, fontWeight: pw.FontWeight.bold),
          ),
          pw.Row(
            children: [
              pw.Text(
                "Inv No: ${invoice.originalInvoiceNumber}",
                style: const pw.TextStyle(fontSize: 9),
              ),
              pw.SizedBox(width: 16),
              if (invoice.originalInvoiceDate != null)
                pw.Text(
                  "Date: ${DateFormat('dd/MM/yyyy').format(invoice.originalInvoiceDate!)}",
                  style: const pw.TextStyle(fontSize: 9),
                ),
            ],
          ),
        ],
      ),
    );
  }
}
