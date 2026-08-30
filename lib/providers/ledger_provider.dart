import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:money2/money2.dart';
import 'package:invobharat/models/invoice.dart';

import 'package:invobharat/providers/invoice_repository_provider.dart';

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

// Provider that returns a list of LedgerEntry for a given Client identifier (Name, GSTIN, or ID)
final clientLedgerProvider = FutureProvider.family<List<LedgerEntry>, String>((
  final ref,
  final clientIdentifier,
) async {
  final repository = ref.watch(invoiceRepositoryProvider);

  // 1. Fetch client-specific invoices via indexed query matching ID, GSTIN, or Name
  final clientInvoices = await repository.getInvoicesForClient(
    clientId: clientIdentifier,
    gstin: clientIdentifier,
    query: clientIdentifier,
  );

  final List<LedgerEntry> entries = [];

  for (final inv in clientInvoices) {
    // 3. Invoice Entry (Debit)
    if (inv.type == InvoiceType.invoice) {
      entries.add(
        LedgerEntry(
          date: inv.invoiceDate,
          particulars: "Invoice #${inv.invoiceNo}",
          type: 'INVOICE',
          debit: inv.grandTotal,
          credit: 0,
          balance: 0, // Calc later
        ),
      );
    } else if (inv.type == InvoiceType.creditNote) {
      // It's a Credit Note Document.
      // It reduces balance. So Credit column.
      entries.add(
        LedgerEntry(
          date: inv.invoiceDate,
          particulars: "Credit Note #${inv.invoiceNo}",
          type: 'CREDIT_NOTE',
          debit: 0,
          credit: inv.grandTotal,
          balance: 0,
        ),
      );
    }

    // 4. Payments (Credit) associated with this invoice
    for (final pay in inv.payments) {
      if (pay.paymentMode == 'Credit Note') continue;

      entries.add(
        LedgerEntry(
          date: pay.date,
          particulars: "Payment (${pay.paymentMode})",
          type: 'PAYMENT',
          debit: 0,
          credit: pay.amount,
          balance: 0,
        ),
      );
    }
  }

  // 5. Sort by Date
  entries.sort((final a, final b) => a.date.compareTo(b.date));

  // 6. Calculate Running Balance using Money precision math
  final inr = CommonCurrencies().inr;
  Money runningBalance = Money.fromNumWithCurrency(0, inr);
  final List<LedgerEntry> calculatedEntries = [];

  for (final entry in entries) {
    final debitMoney = Money.fromNumWithCurrency(entry.debit, inr);
    final creditMoney = Money.fromNumWithCurrency(entry.credit, inr);
    runningBalance = runningBalance + debitMoney - creditMoney;

    calculatedEntries.add(
      LedgerEntry(
        date: entry.date,
        particulars: entry.particulars,
        type: entry.type,
        debit: entry.debit,
        credit: entry.credit,
        balance: runningBalance.toDouble(),
      ),
    );
  }

  return calculatedEntries;
});
