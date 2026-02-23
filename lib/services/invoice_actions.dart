import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:invobharat/models/invoice.dart';
import 'package:invobharat/providers/business_profile_provider.dart';
import 'package:invobharat/providers/invoice_repository_provider.dart';

class InvoiceActions {
  // Generates a unique ID
  static String generateId() =>
      DateTime.now().millisecondsSinceEpoch.toString();

  /// Saves an invoice, handling profile sync and sequence updates.
  /// Returns the saved Invoice object.
  static Future<Invoice> saveInvoice(final WidgetRef ref, final Invoice invoice) async {
    Invoice toSave = invoice;
    final profile = ref.read(businessProfileProvider);

    // Auto-fill supplier info from profile if missing or always?
    // Original logic: Material did a full copy. Fluent did a check.
    // Let's standardize on updating supplier details from current profile for consistency.
    toSave = toSave.copyWith(
      supplier: toSave.supplier.copyWith(
        name: profile.companyName,
        address: profile.address,
        gstin: profile.gstin,
        phone: profile.phone,
        email: profile.email,
        state: profile.state,
      ),
    );

    // Generate ID if new
    if (toSave.id == null) {
      toSave = toSave.copyWith(id: generateId());
    }

    try {
      await ref.read(invoiceRepositoryProvider).saveInvoice(toSave);

      // Only increment sequence if it was a NEW invoice
      if (invoice.id == null) {
        await ref
            .read(businessProfileNotifierProvider)
            .incrementInvoiceSequence();
      }

      return toSave;
    } catch (e) {
      rethrow;
    }
  }
}
