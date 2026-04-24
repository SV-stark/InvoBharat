import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:invobharat/models/invoice.dart';
import 'package:invobharat/providers/invoice_repository_provider.dart';
import 'package:invobharat/providers/business_profile_provider.dart';
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

    final newInvoice = invoice.copyWith(
      id: const Uuid().v4(),
      invoiceNo: '${profile.invoiceSeries}${profile.invoiceSequence}',
      invoiceDate: DateTime.now(),
      payments: [],
      items: invoice.items.map((final e) => e.copyWith(id: const Uuid().v4())).toList(),
    );

    await ref.read(invoiceRepositoryProvider).saveInvoice(newInvoice);
    await ref.read(businessProfileListProvider.notifier).incrementInvoiceSequence();
    ref.invalidate(invoiceListProvider);
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
