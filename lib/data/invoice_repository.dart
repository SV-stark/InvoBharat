import '../models/invoice.dart';

abstract class InvoiceRepository {
  Future<void> saveInvoice(Invoice invoice);
  Future<Invoice?> getInvoice(String id);
  Future<List<Invoice>> getAllInvoices();
  Future<void> deleteInvoice(String id);
  Future<void> deleteAll();

  Future<bool> checkInvoiceExists(String invoiceNumber, {String? excludeId});
}
