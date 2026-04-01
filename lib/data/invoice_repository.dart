import 'package:invobharat/models/invoice.dart';

abstract class InvoiceRepository {
  Future<void> saveInvoice(final Invoice invoice);
  Future<Invoice?> getInvoice(final String id);
  Future<List<Invoice>> getAllInvoices();
  Future<List<Invoice>> getInvoicesPaginated({
    required final int limit,
    required final int offset,
  });
  Future<int> getInvoiceCount();
  Future<void> deleteInvoice(final String id);
  Future<void> deleteAll();

  Future<bool> checkInvoiceExists(
    final String invoiceNumber, {
    final String? excludeId,
  });
}
