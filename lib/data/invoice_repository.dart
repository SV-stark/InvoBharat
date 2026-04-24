import 'package:invobharat/models/invoice.dart';
import 'package:invobharat/models/estimate.dart';
import 'package:invobharat/models/recurring_profile.dart';

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

  // Estimates
  Future<void> saveEstimate(final Estimate estimate);
  Future<List<Estimate>> getAllEstimates();
  Future<void> deleteEstimate(final String id);

  // Recurring
  Future<void> saveRecurringProfile(final RecurringProfile profile);
  Future<List<RecurringProfile>> getAllRecurringProfiles();
  Future<void> deleteRecurringProfile(final String id);
}
