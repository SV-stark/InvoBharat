import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:printing/printing.dart';

import '../models/invoice.dart';
import '../models/business_profile.dart';
import '../models/client.dart';
import '../services/invoice_actions.dart';
import '../utils/pdf_generator.dart';
import '../providers/invoice_provider.dart';
import '../providers/estimate_provider.dart';

/// Mixin to handle form logic for creating/editing Invoices.
/// Standardizes controller management and common actions.
mixin InvoiceFormMixin<T extends ConsumerStatefulWidget> on ConsumerState<T> {
  // Controllers
  late TextEditingController invoiceNoCtrl;
  late TextEditingController posCtrl;
  late TextEditingController receiverNameCtrl;
  late TextEditingController receiverGstinCtrl;
  late TextEditingController receiverStateCtrl;
  late TextEditingController
      receiverAddressCtrl; // Note: In some forms this might be delivery address too?
  // Checking Material form: has _receiverAddressCtrl (billing)
  // Checking Fluent form: has deliveryAddress too.
  // Let's add delivery address controller too.
  late TextEditingController deliveryAddressCtrl;
  late TextEditingController paymentTermsCtrl;

  void initInvoiceControllers([Invoice? invoice]) {
    invoiceNoCtrl = TextEditingController(text: invoice?.invoiceNo);
    posCtrl = TextEditingController(text: invoice?.placeOfSupply);
    receiverNameCtrl = TextEditingController(text: invoice?.receiver.name);
    receiverGstinCtrl = TextEditingController(text: invoice?.receiver.gstin);
    receiverStateCtrl = TextEditingController(text: invoice?.receiver.state);
    receiverAddressCtrl =
        TextEditingController(text: invoice?.receiver.address);
    deliveryAddressCtrl = TextEditingController(text: invoice?.deliveryAddress);
    paymentTermsCtrl = TextEditingController(text: invoice?.paymentTerms);
  }

  void disposeInvoiceControllers() {
    invoiceNoCtrl.dispose();
    posCtrl.dispose();
    receiverNameCtrl.dispose();
    receiverGstinCtrl.dispose();
    receiverStateCtrl.dispose();
    receiverAddressCtrl.dispose();
    deliveryAddressCtrl.dispose();
    paymentTermsCtrl.dispose();
  }

  /// Syncs controllers with provider state.
  /// call this inside a ref.listen callback or when setting initial data.
  void syncInvoiceControllers(Invoice invoice) {
    if (invoiceNoCtrl.text != invoice.invoiceNo)
      invoiceNoCtrl.text = invoice.invoiceNo;
    if (posCtrl.text != invoice.placeOfSupply)
      posCtrl.text = invoice.placeOfSupply;
    if (receiverNameCtrl.text != invoice.receiver.name)
      receiverNameCtrl.text = invoice.receiver.name;
    if (receiverGstinCtrl.text != invoice.receiver.gstin)
      receiverGstinCtrl.text = invoice.receiver.gstin;
    if (receiverStateCtrl.text != invoice.receiver.state)
      receiverStateCtrl.text = invoice.receiver.state;
    if (receiverAddressCtrl.text != invoice.receiver.address)
      receiverAddressCtrl.text = invoice.receiver.address;
    if (deliveryAddressCtrl.text != (invoice.deliveryAddress ?? '')) {
      deliveryAddressCtrl.text = invoice.deliveryAddress ?? '';
    }
    if (paymentTermsCtrl.text != invoice.paymentTerms)
      paymentTermsCtrl.text = invoice.paymentTerms;
  }

  /// Updates provider and controllers when a client is selected
  void onClientSelected(Client client) {
    final notifier = ref.read(invoiceProvider.notifier);
    notifier.updateReceiverName(client.name);
    notifier.updateReceiverGstin(client.gstin);
    notifier.updateReceiverState(client.state);
    notifier.updateReceiverAddress(client.address);

    // Explicitly update controllers to match
    receiverNameCtrl.text = client.name;
    receiverGstinCtrl.text = client.gstin;
    receiverStateCtrl.text = client.state;
    receiverAddressCtrl.text = client.address;
  }

  Future<bool> saveInvoice({
    required Invoice invoice,
    String? estimateIdToMarkConverted,
    required BuildContext
        context, // required for notifications if specific UI logic needed?
    // Actually mixin shouldn't depend on UI widgets like ShowDialog if possible,
    // but here we return status or throw error?
    // Let's return success bool and let UI handle success message.
    // Or simpler: Reuse the logic.
  }) async {
    try {
      await InvoiceActions.saveInvoice(ref, invoice);

      if (estimateIdToMarkConverted != null) {
        await ref
            .read(estimateListProvider.notifier)
            .markAsConverted(estimateIdToMarkConverted);
      }
      return true;
    } catch (e) {
      // Logic to show error is UI specific usually, but we can rethrow
      rethrow;
    }
  }

  Future<void> printInvoice(Invoice invoice, BusinessProfile profile) async {
    final pdfBytes = await generateInvoicePdf(invoice, profile);
    await Printing.layoutPdf(onLayout: (_) => pdfBytes);
  }
}
