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
import '../providers/invoice_repository_provider.dart';

/// Mixin to handle form logic for creating/editing Invoices.
/// Standardizes controller management and common actions.
mixin InvoiceFormMixin<T extends ConsumerStatefulWidget> on ConsumerState<T> {
  // Controllers
  late TextEditingController invoiceNoCtrl;
  late TextEditingController posCtrl;
  late TextEditingController receiverNameCtrl;
  late TextEditingController receiverGstinCtrl;
  late TextEditingController receiverEmailCtrl; // NEW
  late TextEditingController receiverStateCtrl;
  late TextEditingController
      receiverAddressCtrl; // Note: In some forms this might be delivery address too?
  // Checking Material form: has _receiverAddressCtrl (billing)
  // Checking Fluent form: has deliveryAddress too.
  // Let's add delivery address controller too.
  late TextEditingController deliveryAddressCtrl;
  late TextEditingController paymentTermsCtrl;
  late TextEditingController originalInvoiceNoCtrl;

  void initInvoiceControllers([Invoice? invoice]) {
    invoiceNoCtrl = TextEditingController(text: invoice?.invoiceNo);
    posCtrl = TextEditingController(text: invoice?.placeOfSupply);
    receiverNameCtrl = TextEditingController(text: invoice?.receiver.name);
    receiverGstinCtrl = TextEditingController(text: invoice?.receiver.gstin);
    receiverEmailCtrl =
        TextEditingController(text: invoice?.receiver.email); // NEW
    receiverStateCtrl = TextEditingController(text: invoice?.receiver.state);
    receiverAddressCtrl =
        TextEditingController(text: invoice?.receiver.address);
    deliveryAddressCtrl = TextEditingController(text: invoice?.deliveryAddress);
    paymentTermsCtrl = TextEditingController(text: invoice?.paymentTerms);
    originalInvoiceNoCtrl =
        TextEditingController(text: invoice?.originalInvoiceNumber);
  }

  void disposeInvoiceControllers() {
    invoiceNoCtrl.dispose();
    posCtrl.dispose();
    receiverNameCtrl.dispose();
    receiverGstinCtrl.dispose();
    receiverEmailCtrl.dispose(); // NEW
    receiverStateCtrl.dispose();
    receiverAddressCtrl.dispose();
    deliveryAddressCtrl.dispose();
    paymentTermsCtrl.dispose();
    originalInvoiceNoCtrl.dispose();
  }

  /// Syncs controllers with provider state.
  /// call this inside a ref.listen callback or when setting initial data.
  void syncInvoiceControllers(Invoice invoice) {
    if (invoiceNoCtrl.text != invoice.invoiceNo) {
      invoiceNoCtrl.text = invoice.invoiceNo;
    }
    if (posCtrl.text != invoice.placeOfSupply) {
      posCtrl.text = invoice.placeOfSupply;
    }
    if (receiverNameCtrl.text != invoice.receiver.name) {
      receiverNameCtrl.text = invoice.receiver.name;
    }
    if (receiverGstinCtrl.text != invoice.receiver.gstin) {
      receiverGstinCtrl.text = invoice.receiver.gstin;
    }
    if (receiverEmailCtrl.text != invoice.receiver.email) {
      receiverEmailCtrl.text = invoice.receiver.email;
    }
    if (receiverStateCtrl.text != invoice.receiver.state) {
      receiverStateCtrl.text = invoice.receiver.state;
    }
    if (receiverAddressCtrl.text != invoice.receiver.address) {
      receiverAddressCtrl.text = invoice.receiver.address;
    }
    if (deliveryAddressCtrl.text != (invoice.deliveryAddress ?? '')) {
      deliveryAddressCtrl.text = invoice.deliveryAddress ?? '';
    }
    if (paymentTermsCtrl.text != invoice.paymentTerms) {
      paymentTermsCtrl.text = invoice.paymentTerms;
    }
    if (originalInvoiceNoCtrl.text != (invoice.originalInvoiceNumber ?? '')) {
      originalInvoiceNoCtrl.text = invoice.originalInvoiceNumber ?? '';
    }
  }

  /// Updates provider and controllers when a client is selected
  void onClientSelected(Client client) {
    final notifier = ref.read(invoiceProvider.notifier);
    notifier.updateReceiverName(client.name);
    notifier.updateReceiverGstin(client.gstin);
    notifier.updateReceiverEmail(client.email); // NEW
    notifier.updateReceiverState(client.state);
    notifier.updateReceiverAddress(client.address);

    // Explicitly update controllers to match
    receiverNameCtrl.text = client.name;
    receiverGstinCtrl.text = client.gstin;
    receiverEmailCtrl.text = client.email; // NEW
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

  /// Generates the next invoice number based on existing invoices
  Future<String> generateNextInvoiceNumber() async {
    final invoices = await ref.read(invoiceRepositoryProvider).getAllInvoices();
    
    if (invoices.isEmpty) {
      return 'INV-001';
    }
    
    // Find the highest invoice number
    int maxNumber = 0;
    final regex = RegExp(r'INV-?(\d+)', caseSensitive: false);
    
    for (final invoice in invoices) {
      final match = regex.firstMatch(invoice.invoiceNo);
      if (match != null) {
        final number = int.tryParse(match.group(1) ?? '0') ?? 0;
        if (number > maxNumber) {
          maxNumber = number;
        }
      }
    }
    
    return 'INV-${(maxNumber + 1).toString().padLeft(3, '0')}';
  }

  /// Calculates due date based on payment terms
  DateTime? calculateDueDate(DateTime invoiceDate, String paymentTerms) {
    if (paymentTerms.isEmpty) {
      return invoiceDate.add(const Duration(days: 30));
    }
    
    // Parse common payment terms
    final lowerTerms = paymentTerms.toLowerCase();
    
    if (lowerTerms.contains('net') || lowerTerms.contains('days')) {
      // Extract number from terms like "Net 30", "30 days", etc.
      final regex = RegExp(r'(\d+)');
      final match = regex.firstMatch(paymentTerms);
      if (match != null) {
        final days = int.tryParse(match.group(0) ?? '30') ?? 30;
        return invoiceDate.add(Duration(days: days));
      }
    }
    
    if (lowerTerms.contains('immediate') || lowerTerms.contains('due on receipt')) {
      return invoiceDate;
    }
    
    // Default to 30 days
    return invoiceDate.add(const Duration(days: 30));
  }
}
