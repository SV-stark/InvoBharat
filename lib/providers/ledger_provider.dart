import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/invoice.dart';

import 'invoice_repository_provider.dart';

// Model for a single row in the ledger
class LedgerEntry {
  final DateTime date;
  final String particulars; // Description (Invoice # or Payment Ref)
  final String type; // 'INVOICE', 'PAYMENT', 'CREDIT_NOTE'
  final double debit; // Amount billed to client (increases balance)
  final double credit; // Amount paid by client (decreases balance)
  final double balance; // Running balance after this transaction

  LedgerEntry({
    required this.date,
    required this.particulars,
    required this.type,
    required this.debit,
    required this.credit,
    required this.balance,
  });
}

// Provider that returns a list of LedgerEntry for a given Client Name (since we link by name mostly)
// We use Family to pass arguments.
final clientLedgerProvider =
    FutureProvider.family<List<LedgerEntry>, String>((ref, clientName) async {
  final repository = ref.watch(invoiceRepositoryProvider);

  // 1. Fetch all invoices
  // Optimization: If repository supports filtering, use it. But File repo loads all.
  final allInvoices = await repository.getAllInvoices();

  // 2. Filter for this client
  // We match by Receiver Name as Invoice/Receiver models do not store a Client ID.
  final clientInvoices = allInvoices
      .where((inv) =>
          inv.receiver.name.trim().toLowerCase() ==
          clientName.trim().toLowerCase())
      .toList();

  List<LedgerEntry> entries = [];

  for (final inv in clientInvoices) {
    // 3. Invoice Entry (Debit)
    // If it's a Credit Note Invoice, is it a Debit or Credit?
    // A "Credit Note" document usually *reduces* the balance.
    // However, in our system, we treat Credit Notes as a Payment on the original invoice?
    // OR is the Credit Note itself a document?
    // If `InvoiceType.creditNote`, it should appear as a CREDIT (Reducing balance).

    // Scenario A: Standard Invoice
    if (inv.type == InvoiceType.invoice) {
      entries.add(LedgerEntry(
        date: inv.invoiceDate,
        particulars: "Invoice #${inv.invoiceNo}",
        type: 'INVOICE',
        debit: inv.grandTotal,
        credit: 0,
        balance: 0, // Calc later
      ));
    } else if (inv.type == InvoiceType.creditNote) {
      // It's a Credit Note Document.
      // It reduces balance. So Credit column.
      entries.add(LedgerEntry(
        date: inv.invoiceDate,
        particulars: "Credit Note #${inv.invoiceNo}",
        type: 'CREDIT_NOTE',
        debit: 0,
        credit: inv.grandTotal,
        balance: 0,
      ));
    }

    // 4. Payments (Credit) associated with this invoice
    for (final pay in inv.payments) {
      // If payment is "Credit Note", it means it came from a CN linking.
      // Do we show it?
      // If we show the CN document AND the payment, we double count?
      // Logic:
      // If we show the CN Document as a line item, we establish the Credit.
      // The "Payment" of type "Credit Note" effectively "Apply" that credit to the invoice.
      // In a Ledger View, we usually show:
      // 1. Invoice A (Debit 1000)
      // 2. Credit Note B (Credit 200)
      // We do NOT show "Payment (CN applied)" as another 200.
      // SO: We should filter out payments of mode 'Credit Note' IF we are showing the CN documents themselves.
      // Since `clientInvoices` includes ALL documents (inc CNs), we will see the CN document.
      // Therefore, we should skip 'Credit Note' payments to avoid double counting.

      if (pay.paymentMode == 'Credit Note') continue;

      entries.add(LedgerEntry(
        date: pay.date,
        particulars: "Payment (${pay.paymentMode})",
        type: 'PAYMENT',
        debit: 0,
        credit: pay.amount,
        balance: 0,
      ));
    }
  }

  // 5. Sort by Date
  entries.sort((a, b) => a.date.compareTo(b.date));

  // 6. Calculate Running Balance
  double runningBalance = 0;
  List<LedgerEntry> calculatedEntries = [];

  for (final entry in entries) {
    runningBalance += entry.debit - entry.credit;
    calculatedEntries.add(LedgerEntry(
      date: entry.date,
      particulars: entry.particulars,
      type: entry.type,
      debit: entry.debit,
      credit: entry.credit,
      balance: runningBalance,
    ));
  }

  // Reverse to show latest first?
  // Usually Ledgers are chronological (Oldest first) to show balance history.
  // But users might want latest.
  // Let's keep chronological.

  return calculatedEntries;
});
