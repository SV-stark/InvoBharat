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
    final bool showHsnSummary = true,
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

  pw.Widget buildEwayBillAndEinvoiceInfo(
    final Invoice invoice,
    final pw.Font font,
    final pw.Font fontBold,
  ) {
    final hasEway = invoice.ewayBillNo != null && invoice.ewayBillNo!.isNotEmpty;
    final hasVehicle = invoice.vehicleNo != null && invoice.vehicleNo!.isNotEmpty;
    final hasIrn = invoice.irnNo != null && invoice.irnNo!.isNotEmpty;

    if (!hasEway && !hasVehicle && !hasIrn) {
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
            "Transportation & E-Invoice Details",
            style: pw.TextStyle(font: fontBold, fontSize: 9, fontWeight: pw.FontWeight.bold),
          ),
          pw.SizedBox(height: 4),
          pw.Row(
            children: [
              if (hasEway) ...[
                pw.Text("E-Way Bill No: ", style: pw.TextStyle(font: fontBold, fontSize: 9)),
                pw.Text(invoice.ewayBillNo!, style: pw.TextStyle(font: font, fontSize: 9)),
                pw.SizedBox(width: 16),
              ],
              if (hasVehicle) ...[
                pw.Text("Vehicle No: ", style: pw.TextStyle(font: fontBold, fontSize: 9)),
                pw.Text(invoice.vehicleNo!, style: pw.TextStyle(font: font, fontSize: 9)),
              ],
            ],
          ),
          if (hasIrn) ...[
            pw.SizedBox(height: 4),
            pw.Row(
              children: [
                pw.Text("E-Invoice IRN: ", style: pw.TextStyle(font: fontBold, fontSize: 9)),
                pw.Expanded(
                  child: pw.Text(
                    invoice.irnNo!,
                    style: pw.TextStyle(font: font, fontSize: 8),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  pw.Widget buildHsnSummaryTable(final Invoice invoice, final pw.Font font, final pw.Font fontBold) {
    // 1. Group items by HSN Code
    final Map<String, List<InvoiceItem>> grouped = {};
    for (final item in invoice.items) {
      final code = item.cleanSacCode.isEmpty ? 'N/A' : item.cleanSacCode;
      grouped.putIfAbsent(code, () => []).add(item);
    }

    final headers = ['HSN/SAC', 'Taxable Value', 'CGST %', 'CGST Amt', 'SGST %', 'SGST Amt', 'IGST %', 'IGST Amt', 'Total Tax'];
    final isInterState = invoice.isInterState;

    final data = grouped.entries.map((final entry) {
      final code = entry.key;
      final items = entry.value;
      
      double taxableVal = 0;
      double cgstAmt = 0;
      double sgstAmt = 0;
      double igstAmt = 0;
      double gstRate = 0;

      for (final item in items) {
        taxableVal += item.netAmount;
        gstRate = item.gstRate; // Assumes same HSN has same rate, standard
        cgstAmt += item.calculateCgst(isInterState);
        sgstAmt += item.calculateSgst(isInterState);
        igstAmt += item.calculateIgst(isInterState);
      }

      final totalTax = cgstAmt + sgstAmt + igstAmt;

      return [
        code,
        taxableVal.toIndianFormat(),
        isInterState ? '0%' : '${(gstRate / 2).toStringAsFixed(1)}%',
        cgstAmt.toIndianFormat(),
        isInterState ? '0%' : '${(gstRate / 2).toStringAsFixed(1)}%',
        sgstAmt.toIndianFormat(),
        !isInterState ? '0%' : '${gstRate.toStringAsFixed(1)}%',
        igstAmt.toIndianFormat(),
        totalTax.toIndianFormat(),
      ];
    }).toList();

    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.SizedBox(height: 10),
        pw.Text("HSN/SAC Tax Summary", style: pw.TextStyle(font: fontBold, fontSize: 9, fontWeight: pw.FontWeight.bold)),
        pw.SizedBox(height: 4),
        pw.TableHelper.fromTextArray(
          headers: headers,
          data: data,
          border: const pw.TableBorder(
            top: pw.BorderSide(color: PdfColors.grey300),
            bottom: pw.BorderSide(color: PdfColors.grey300),
            horizontalInside: pw.BorderSide(color: PdfColors.grey200),
            verticalInside: pw.BorderSide(color: PdfColors.grey200),
          ),
          headerStyle: pw.TextStyle(fontSize: 7, fontWeight: pw.FontWeight.bold, font: fontBold),
          cellStyle: pw.TextStyle(fontSize: 7, font: font),
          cellAlignments: {
            0: pw.Alignment.centerLeft,
            1: pw.Alignment.centerRight,
            2: pw.Alignment.centerRight,
            3: pw.Alignment.centerRight,
            4: pw.Alignment.centerRight,
            5: pw.Alignment.centerRight,
            6: pw.Alignment.centerRight,
            7: pw.Alignment.centerRight,
            8: pw.Alignment.centerRight,
          },
          cellPadding: const pw.EdgeInsets.symmetric(vertical: 2, horizontal: 3),
        ),
      ]
    );
  }
}
