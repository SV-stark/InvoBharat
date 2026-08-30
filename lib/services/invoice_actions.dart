import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:invobharat/models/invoice.dart';
import 'package:invobharat/providers/invoice_repository_provider.dart';
import 'package:invobharat/providers/business_profile_provider.dart';
import 'package:invobharat/providers/invoice_series_provider.dart';
import 'package:uuid/uuid.dart';

class InvoiceActions {
  static Future<void> saveInvoice(
    final WidgetRef ref,
    final Invoice invoice,
  ) async {
    await ref.read(invoiceRepositoryProvider).saveInvoice(invoice);
    ref.invalidate(invoiceListProvider);
  }

  static Future<void> duplicateInvoice(
    final WidgetRef ref,
    final Invoice invoice,
  ) async {
    final profile = ref.read(businessProfileProvider);
    final seriesList = ref.read(invoiceSeriesProvider);
    final repository = ref.read(invoiceRepositoryProvider);
    final targetPrefix =
        (invoice.invoiceNo.isNotEmpty &&
            seriesList.any((final s) => invoice.invoiceNo.startsWith(s.prefix)))
        ? seriesList
              .firstWhere((final s) => invoice.invoiceNo.startsWith(s.prefix))
              .prefix
        : (profile.invoiceSeries.isNotEmpty ? profile.invoiceSeries : 'INV-');

    final targetDate = DateTime.now();
    final maxInFy = await repository.getMaxSequenceForPrefix(
      targetPrefix,
      invoiceDate: targetDate,
    );
    int seq = maxInFy + 1;
    String candidate = '$targetPrefix${seq.toString().padLeft(3, '0')}';
    while (await repository.checkInvoiceExists(
      candidate,
      invoiceDate: targetDate,
    )) {
      seq++;
      candidate = '$targetPrefix${seq.toString().padLeft(3, '0')}';
    }

    final newInvoice = invoice.copyWith(
      id: const Uuid().v4(),
      invoiceNo: candidate,
      invoiceDate: targetDate,
      payments: [],
      status: 'Draft',
      items: invoice.items
          .map((final e) => e.copyWith(id: const Uuid().v4()))
          .toList(),
    );

    await ref.read(invoiceRepositoryProvider).saveInvoice(newInvoice);
    await ref
        .read(invoiceSeriesProvider.notifier)
        .updateSequence(targetPrefix, seq);
    ref.invalidate(invoiceListProvider);
  }

  static Future<Invoice> buildCreditNote(
    final WidgetRef ref,
    final Invoice originalInvoice,
  ) async {
    final repository = ref.read(invoiceRepositoryProvider);
    const prefix = 'CN-';
    final targetDate = DateTime.now();
    final maxInFy = await repository.getMaxSequenceForPrefix(
      prefix,
      invoiceDate: targetDate,
    );
    int seq = maxInFy + 1;
    String candidate = '$prefix${seq.toString().padLeft(3, '0')}';
    while (await repository.checkInvoiceExists(
      candidate,
      invoiceDate: targetDate,
    )) {
      seq++;
      candidate = '$prefix${seq.toString().padLeft(3, '0')}';
    }

    return originalInvoice.copyWith(
      id: const Uuid().v4(),
      type: InvoiceType.creditNote,
      invoiceNo: candidate,
      invoiceDate: targetDate,
      originalInvoiceNumber: originalInvoice.invoiceNo,
      originalInvoiceDate: originalInvoice.invoiceDate,
      payments: [],
      status: 'Draft',
      items: originalInvoice.items
          .map((final e) => e.copyWith(id: const Uuid().v4()))
          .toList(),
    );
  }

  static Future<Invoice> buildDebitNote(
    final WidgetRef ref,
    final Invoice originalInvoice,
  ) async {
    final repository = ref.read(invoiceRepositoryProvider);
    const prefix = 'DN-';
    final targetDate = DateTime.now();
    final maxInFy = await repository.getMaxSequenceForPrefix(
      prefix,
      invoiceDate: targetDate,
    );
    int seq = maxInFy + 1;
    String candidate = '$prefix${seq.toString().padLeft(3, '0')}';
    while (await repository.checkInvoiceExists(
      candidate,
      invoiceDate: targetDate,
    )) {
      seq++;
      candidate = '$prefix${seq.toString().padLeft(3, '0')}';
    }

    return originalInvoice.copyWith(
      id: const Uuid().v4(),
      type: InvoiceType.debitNote,
      invoiceNo: candidate,
      invoiceDate: targetDate,
      originalInvoiceNumber: originalInvoice.invoiceNo,
      originalInvoiceDate: originalInvoice.invoiceDate,
      payments: [],
      status: 'Draft',
      items: originalInvoice.items
          .map((final e) => e.copyWith(id: const Uuid().v4()))
          .toList(),
    );
  }

  static Future<void> markAsSent(
    final WidgetRef ref,
    final Invoice invoice,
  ) async {
    final updated = invoice.copyWith(status: 'Sent', sentAt: DateTime.now());
    await saveInvoice(ref, updated);
  }

  static Color getStatusColor(final String status) {
    switch (status) {
      case 'Paid':
        return Colors.green;
      case 'Partial':
        return Colors.blue;
      case 'Overdue':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }
}
