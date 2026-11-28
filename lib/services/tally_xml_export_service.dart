import 'dart:isolate';
import 'package:intl/intl.dart';
import 'package:invobharat/models/invoice.dart';

class TallyXmlExportService {
  Future<String> generateTallySalesXmlAsync(
    final List<Invoice> invoices, {
    final String companyName = '',
  }) {
    return Isolate.run(
      () => generateTallySalesXml(invoices, companyName: companyName),
    );
  }

  static String _escapeXml(final String input) {
    return input
        .replaceAll('&', '&amp;')
        .replaceAll('<', '&lt;')
        .replaceAll('>', '&gt;')
        .replaceAll('"', '&quot;')
        .replaceAll("'", '&apos;');
  }

  static String _fmtAmount(final double value) => value.toStringAsFixed(2);

  String generateTallySalesXml(
    final List<Invoice> invoices, {
    final String companyName = '',
  }) {
    final dateFmt = DateFormat('yyyyMMdd');
    final buf = StringBuffer();
    buf.writeln('<ENVELOPE>');
    buf.writeln('  <HEADER>');
    buf.writeln('    <TALLYREQUEST>Import Data</TALLYREQUEST>');
    buf.writeln('  </HEADER>');
    buf.writeln('  <BODY>');
    buf.writeln('    <IMPORTDATA>');
    buf.writeln('      <REQUESTDESC>');
    buf.writeln('        <REPORTNAME>Vouchers</REPORTNAME>');
    if (companyName.trim().isNotEmpty) {
      buf.writeln('        <STATICVARIABLES>');
      buf.writeln(
        '          <SVCURRENTCOMPANY>${_escapeXml(companyName.trim())}</SVCURRENTCOMPANY>',
      );
      buf.writeln('        </STATICVARIABLES>');
    }
    buf.writeln('      </REQUESTDESC>');
    buf.writeln('      <REQUESTDATA>');

    for (final inv in invoices) {
      if (inv.isDeleted || inv.type == InvoiceType.deliveryChallan) continue;

      final vchType = switch (inv.type) {
        InvoiceType.creditNote => 'Credit Note',
        InvoiceType.debitNote => 'Debit Note',
        InvoiceType.invoice || InvoiceType.billOfSupply => 'Sales',
        InvoiceType.deliveryChallan => 'Delivery Note',
      };

      final dateStr = dateFmt.format(inv.invoiceDate);
      final partyName = inv.receiver.name.trim().isEmpty
          ? 'Cash'
          : inv.receiver.name.trim();
      final pos = inv.placeOfSupply.isNotEmpty
          ? inv.placeOfSupply
          : inv.receiver.state;

      buf.writeln('        <TALLYMESSAGE xmlns:UDF="TallyUDF">');
      buf.writeln(
        '          <VOUCHER VCHTYPE="${_escapeXml(vchType)}" ACTION="Create">',
      );
      buf.writeln('            <DATE>$dateStr</DATE>');
      buf.writeln(
        '            <VOUCHERTYPENAME>${_escapeXml(vchType)}</VOUCHERTYPENAME>',
      );
      buf.writeln(
        '            <VOUCHERNUMBER>${_escapeXml(inv.invoiceNo)}</VOUCHERNUMBER>',
      );
      buf.writeln(
        '            <PARTYLEDGERNAME>${_escapeXml(partyName)}</PARTYLEDGERNAME>',
      );
      if (inv.receiver.gstin.trim().isNotEmpty) {
        buf.writeln(
          '            <PARTYGSTIN>${_escapeXml(inv.receiver.gstin.trim())}</PARTYGSTIN>',
        );
      }
      if (pos.trim().isNotEmpty) {
        buf.writeln(
          '            <PLACEOFSUPPLY>${_escapeXml(pos.trim())}</PLACEOFSUPPLY>',
        );
      }
      buf.writeln(
        '            <NARRATION>${_escapeXml(inv.isCancelled ? (inv.cancellationReason ?? "Cancelled") : "Invoice ${inv.invoiceNo}")}</NARRATION>',
      );

      if (inv.isCancelled) {
        buf.writeln('            <ISCANCELLED>Yes</ISCANCELLED>');
      } else {
        // Tally convention: Debit is negative, Credit is positive; sum of all entries == 0.00.
        // For Credit Note, signs are reversed (Party credited, Sales/Tax debited).
        final isCreditNote = inv.type == InvoiceType.creditNote;
        final sign = isCreditNote ? -1.0 : 1.0;

        final entries = <({String ledger, bool isDeemedPositive, double amount})>[];

        final partyAmt = -inv.grandTotal * sign;
        entries.add((
          ledger: partyName,
          isDeemedPositive: partyAmt < 0,
          amount: partyAmt,
        ));

        final taxableAmt = inv.totalTaxableValue * sign;
        if (taxableAmt.abs() >= 0.005) {
          entries.add((
            ledger: 'Sales Account',
            isDeemedPositive: taxableAmt < 0,
            amount: taxableAmt,
          ));
        }

        final cgstAmt = inv.totalCGST * sign;
        if (cgstAmt.abs() >= 0.005) {
          entries.add((
            ledger: 'Output CGST',
            isDeemedPositive: cgstAmt < 0,
            amount: cgstAmt,
          ));
        }

        final sgstAmt = inv.totalSGST * sign;
        if (sgstAmt.abs() >= 0.005) {
          entries.add((
            ledger: inv.isUtgstSupply ? 'Output UTGST' : 'Output SGST',
            isDeemedPositive: sgstAmt < 0,
            amount: sgstAmt,
          ));
        }

        final igstAmt = inv.totalIGST * sign;
        if (igstAmt.abs() >= 0.005) {
          entries.add((
            ledger: 'Output IGST',
            isDeemedPositive: igstAmt < 0,
            amount: igstAmt,
          ));
        }

        final cessAmt = inv.totalCess * sign;
        if (cessAmt.abs() >= 0.005) {
          entries.add((
            ledger: 'Output GST Cess',
            isDeemedPositive: cessAmt < 0,
            amount: cessAmt,
          ));
        }

        final sum = entries.fold<double>(
          0.0,
          (final acc, final e) => acc + double.parse(_fmtAmount(e.amount)),
        );
        final roundOff = double.parse((-sum).toStringAsFixed(2));
        if (roundOff.abs() >= 0.01) {
          entries.add((
            ledger: 'Round Off',
            isDeemedPositive: roundOff < 0,
            amount: roundOff,
          ));
        }

        for (final entry in entries) {
          buf.writeln('            <ALLLEDGERENTRIES.LIST>');
          buf.writeln(
            '              <LEDGERNAME>${_escapeXml(entry.ledger)}</LEDGERNAME>',
          );
          buf.writeln(
            '              <ISDEEMEDPOSITIVE>${entry.isDeemedPositive ? "Yes" : "No"}</ISDEEMEDPOSITIVE>',
          );
          buf.writeln(
            '              <AMOUNT>${_fmtAmount(entry.amount)}</AMOUNT>',
          );
          buf.writeln('            </ALLLEDGERENTRIES.LIST>');
        }
      }

      buf.writeln('          </VOUCHER>');
      buf.writeln('        </TALLYMESSAGE>');
    }

    buf.writeln('      </REQUESTDATA>');
    buf.writeln('    </IMPORTDATA>');
    buf.writeln('  </BODY>');
    buf.writeln('</ENVELOPE>');
    return buf.toString();
  }
}
