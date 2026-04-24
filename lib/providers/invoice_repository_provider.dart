import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:invobharat/data/sql_invoice_repository.dart';
import 'package:invobharat/data/invoice_repository.dart';
import 'package:invobharat/models/invoice.dart';
import 'package:invobharat/providers/database_provider.dart';

const _pageSize = 50;

final invoiceRepositoryProvider = Provider<InvoiceRepository>((final ref) {
  final db = ref.watch(databaseProvider);
  return SqlInvoiceRepository(db);
});

final invoiceListProvider = FutureProvider<List<Invoice>>((final ref) async {
  return ref.watch(invoiceRepositoryProvider).getAllInvoices();
});

final paginatedInvoicesProvider = FutureProvider.family<List<Invoice>, int>((
  final ref,
  final page,
) async {
  return ref
      .watch(invoiceRepositoryProvider)
      .getInvoicesPaginated(limit: _pageSize, offset: page * _pageSize);
});

final invoiceCountProvider = FutureProvider<int>((final ref) async {
  return ref.watch(invoiceRepositoryProvider).getInvoiceCount();
});
