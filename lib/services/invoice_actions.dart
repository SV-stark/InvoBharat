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
    final isNew = invoice.id == null || invoice.id!.isEmpty;
    await ref.read(invoiceRepositoryProvider).saveInvoice(invoice);

    if (isNew) {
      final profile = ref.read(businessProfileProvider);
      final seriesList = ref.read(invoiceSeriesProvider);

      String? matchedPrefix;
      for (final series in seriesList) {
        if (invoice.invoiceNo.startsWith(series.prefix)) {
          matchedPrefix = series.prefix;
          break;
        }
      }

      if (matchedPrefix != null) {
        await ref
            .read(invoiceSeriesProvider.notifier)
            .incrementSequence(matchedPrefix);
      } else if (seriesList.isNotEmpty) {
        await ref
            .read(invoiceSeriesProvider.notifier)
            .incrementSequence(seriesList.first.prefix);
      }

      if (profile.id.isNotEmpty) {
        await ref
            .read(businessProfileListProvider.notifier)
            .incrementInvoiceSequence(profile.id);
      }
    }

    ref.invalidate(invoiceListProvider);
  }

  static Future<void> duplicateInvoice(
    final WidgetRef ref,
    final Invoice invoice,
  ) async {
    final profile = ref.read(businessProfileProvider);
    final seriesList = ref.read(invoiceSeriesProvider);
    final defaultSeries = seriesList.isNotEmpty
        ? seriesList.first
        : InvoiceSeries(
            prefix: profile.invoiceSeries,
            sequence: profile.invoiceSequence,
          );
    final invoiceNo =
        "${defaultSeries.prefix}${defaultSeries.sequence.toString().padLeft(3, '0')}";

    final newInvoice = invoice.copyWith(
      id: const Uuid().v4(),
      invoiceNo: invoiceNo,
      invoiceDate: DateTime.now(),
      payments: [],
      items: invoice.items
          .map((final e) => e.copyWith(id: const Uuid().v4()))
          .toList(),
    );

    await ref.read(invoiceRepositoryProvider).saveInvoice(newInvoice);
    await ref
        .read(invoiceSeriesProvider.notifier)
        .incrementSequence(defaultSeries.prefix);
    ref.invalidate(invoiceListProvider);
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
