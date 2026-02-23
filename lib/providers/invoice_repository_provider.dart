import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:invobharat/data/sql_invoice_repository.dart';
import 'package:invobharat/data/invoice_repository.dart';
import 'package:invobharat/models/invoice.dart'; // New import
import 'package:invobharat/providers/database_provider.dart';

final invoiceRepositoryProvider = Provider<InvoiceRepository>((final ref) {
  final db = ref.watch(databaseProvider);
  return SqlInvoiceRepository(db);
});

final invoiceListProvider = FutureProvider<List<Invoice>>((final ref) async {
  return ref.watch(invoiceRepositoryProvider).getAllInvoices();
});
