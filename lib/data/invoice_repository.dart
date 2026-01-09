import '../models/invoice.dart';

abstract class InvoiceRepository {
  Future<void> saveInvoice(Invoice invoice);
  Future<Invoice?> getInvoice(String id);
  Future<List<Invoice>> getAllInvoices();
  Future<void> deleteAll();
  // static methods in interface? No, dart interfaces are just classes.
  // We can't enforce static methods.
  // We'll stick to instance methods for the provider integration.
}
