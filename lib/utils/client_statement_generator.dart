import 'dart:isolate';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:intl/intl.dart';
import 'package:invobharat/models/invoice.dart';
import 'package:invobharat/models/business_profile.dart';
import 'package:invobharat/models/client.dart';

class ClientStatementParams {
  final Client client;
  final BusinessProfile profile;
  final List<Invoice> invoices;
  final DateTimeRange dateRange;

  ClientStatementParams({
    required this.client,
    required this.profile,
    required this.invoices,
    required this.dateRange,
  });
}

Future<Uint8List> _generateStatementInIsolate(
  final ClientStatementParams params,
) async {
  pw.Font font;
  pw.Font fontBold;
  try {
    final regularData = await rootBundle.load('fonts/NotoSans-Regular.ttf');
    font = pw.Font.ttf(regularData.buffer.asByteData());

    final boldData = await rootBundle.load('fonts/NotoSans-Bold.ttf');
    fontBold = pw.Font.ttf(boldData.buffer.asByteData());
  } catch (_) {
    font = pw.Font.helvetica();
    fontBold = pw.Font.helveticaBold();
  }

  final pdf = pw.Document();
  final currency = NumberFormat.currency(
    symbol: params.profile.currencySymbol,
    decimalDigits: 2,
  );
  final dateFormatter = DateFormat('dd MMM yyyy');

  pdf.addPage(
    pw.Page(
      build: (final pw.Context context) {
        final filteredInvoices = params.invoices.where((final inv) {
          return inv.receiver.name == params.client.name &&
              inv.invoiceDate.isAfter(
                params.dateRange.start.subtract(const Duration(days: 1)),
              ) &&
              inv.invoiceDate.isBefore(
                params.dateRange.end.add(const Duration(days: 1)),
              );
        }).toList();

        double totalInvoiced = 0;
        double totalPaid = 0;

        for (final inv in filteredInvoices) {
          totalInvoiced += inv.grandTotal;
          totalPaid += inv.totalPaid;
        }

        return pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              children: [
                pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text(
                      params.profile.companyName,
                      style: pw.TextStyle(font: fontBold, fontSize: 18),
                    ),
                    pw.Text(
                      params.profile.address,
                      style: pw.TextStyle(font: font, fontSize: 10),
                    ),
                    if (params.profile.gstin.isNotEmpty)
                      pw.Text(
                        'GSTIN: ${params.profile.gstin}',
                        style: pw.TextStyle(font: font, fontSize: 10),
                      ),
                  ],
                ),
                pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.end,
                  children: [
                    pw.Text(
                      'CLIENT STATEMENT',
                      style: pw.TextStyle(font: fontBold, fontSize: 16),
                    ),
                    pw.Text(
                      params.client.name,
                      style: pw.TextStyle(font: font, fontSize: 12),
                    ),
                    pw.Text(
                      params.client.address,
                      style: pw.TextStyle(font: font, fontSize: 10),
                    ),
                    if (params.client.gstin.isNotEmpty)
                      pw.Text(
                        'GSTIN: ${params.client.gstin}',
                        style: pw.TextStyle(font: font, fontSize: 10),
                      ),
                  ],
                ),
              ],
            ),
            pw.Divider(),
            pw.Text(
              'Statement Period: ${dateFormatter.format(params.dateRange.start)} - ${dateFormatter.format(params.dateRange.end)}',
              style: pw.TextStyle(font: fontBold, fontSize: 12),
            ),
            pw.SizedBox(height: 16),
            pw.Table(
              border: pw.TableBorder.all(width: 0.5),
              children: [
                pw.TableRow(
                  decoration: const pw.BoxDecoration(color: PdfColors.grey200),
                  children: [
                    pw.Padding(
                      padding: const pw.EdgeInsets.all(6),
                      child: pw.Text(
                        'Date',
                        style: pw.TextStyle(font: fontBold, fontSize: 9),
                      ),
                    ),
                    pw.Padding(
                      padding: const pw.EdgeInsets.all(6),
                      child: pw.Text(
                        'Invoice #',
                        style: pw.TextStyle(font: fontBold, fontSize: 9),
                      ),
                    ),
                    pw.Padding(
                      padding: const pw.EdgeInsets.all(6),
                      child: pw.Text(
                        'Amount',
                        style: pw.TextStyle(font: fontBold, fontSize: 9),
                        textAlign: pw.TextAlign.right,
                      ),
                    ),
                    pw.Padding(
                      padding: const pw.EdgeInsets.all(6),
                      child: pw.Text(
                        'Paid',
                        style: pw.TextStyle(font: fontBold, fontSize: 9),
                        textAlign: pw.TextAlign.right,
                      ),
                    ),
                    pw.Padding(
                      padding: const pw.EdgeInsets.all(6),
                      child: pw.Text(
                        'Balance',
                        style: pw.TextStyle(font: fontBold, fontSize: 9),
                        textAlign: pw.TextAlign.right,
                      ),
                    ),
                    pw.Padding(
                      padding: const pw.EdgeInsets.all(6),
                      child: pw.Text(
                        'Status',
                        style: pw.TextStyle(font: fontBold, fontSize: 9),
                      ),
                    ),
                  ],
                ),
                ...filteredInvoices.map((final inv) {
                  return pw.TableRow(
                    children: [
                      pw.Padding(
                        padding: const pw.EdgeInsets.all(6),
                        child: pw.Text(
                          dateFormatter.format(inv.invoiceDate),
                          style: pw.TextStyle(font: font, fontSize: 9),
                        ),
                      ),
                      pw.Padding(
                        padding: const pw.EdgeInsets.all(6),
                        child: pw.Text(
                          inv.invoiceNo,
                          style: pw.TextStyle(font: font, fontSize: 9),
                        ),
                      ),
                      pw.Padding(
                        padding: const pw.EdgeInsets.all(6),
                        child: pw.Text(
                          currency.format(inv.grandTotal),
                          style: pw.TextStyle(font: font, fontSize: 9),
                          textAlign: pw.TextAlign.right,
                        ),
                      ),
                      pw.Padding(
                        padding: const pw.EdgeInsets.all(6),
                        child: pw.Text(
                          currency.format(inv.totalPaid),
                          style: pw.TextStyle(font: font, fontSize: 9),
                          textAlign: pw.TextAlign.right,
                        ),
                      ),
                      pw.Padding(
                        padding: const pw.EdgeInsets.all(6),
                        child: pw.Text(
                          currency.format(inv.balanceDue),
                          style: pw.TextStyle(font: font, fontSize: 9),
                          textAlign: pw.TextAlign.right,
                        ),
                      ),
                      pw.Padding(
                        padding: const pw.EdgeInsets.all(6),
                        child: pw.Text(
                          inv.paymentStatus,
                          style: pw.TextStyle(font: font, fontSize: 9),
                        ),
                      ),
                    ],
                  );
                }),
                pw.TableRow(
                  decoration: const pw.BoxDecoration(color: PdfColors.grey100),
                  children: [
                    pw.Padding(
                      padding: const pw.EdgeInsets.all(6),
                      child: pw.Text(
                        'TOTAL',
                        style: pw.TextStyle(font: fontBold, fontSize: 9),
                      ),
                    ),
                    pw.Padding(
                      padding: const pw.EdgeInsets.all(6),
                      child: pw.Text(
                        '',
                        style: pw.TextStyle(font: fontBold, fontSize: 9),
                      ),
                    ),
                    pw.Padding(
                      padding: const pw.EdgeInsets.all(6),
                      child: pw.Text(
                        currency.format(totalInvoiced),
                        style: pw.TextStyle(font: fontBold, fontSize: 9),
                        textAlign: pw.TextAlign.right,
                      ),
                    ),
                    pw.Padding(
                      padding: const pw.EdgeInsets.all(6),
                      child: pw.Text(
                        currency.format(totalPaid),
                        style: pw.TextStyle(font: fontBold, fontSize: 9),
                        textAlign: pw.TextAlign.right,
                      ),
                    ),
                    pw.Padding(
                      padding: const pw.EdgeInsets.all(6),
                      child: pw.Text(
                        currency.format(totalInvoiced - totalPaid),
                        style: pw.TextStyle(font: fontBold, fontSize: 9),
                        textAlign: pw.TextAlign.right,
                      ),
                    ),
                    pw.Padding(
                      padding: const pw.EdgeInsets.all(6),
                      child: pw.Text(
                        '',
                        style: pw.TextStyle(font: fontBold, fontSize: 9),
                      ),
                    ),
                  ],
                ),
              ],
            ),
            pw.SizedBox(height: 32),
            pw.Text(
              'Generated by InvoBharat',
              style: pw.TextStyle(
                font: font,
                fontSize: 8,
                color: PdfColors.grey,
              ),
            ),
          ],
        );
      },
    ),
  );

  return pdf.save();
}

Future<Uint8List> generateClientStatement(
  final ClientStatementParams params,
) async {
  return Isolate.run(() => _generateStatementInIsolate(params));
}
