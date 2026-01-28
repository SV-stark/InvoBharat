import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/sql_invoice_repository.dart';
import '../data/invoice_repository.dart';
import '../models/invoice.dart'; // New import
import 'database_provider.dart';

final invoiceRepositoryProvider = Provider<InvoiceRepository>((ref) {
  final db = ref.watch(databaseProvider);
  return SqlInvoiceRepository(db);
});

final invoiceListProvider = FutureProvider<List<Invoice>>((ref) async {
  return ref.watch(invoiceRepositoryProvider).getAllInvoices();
});
