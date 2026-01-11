import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:printing/printing.dart';
import 'package:uuid/uuid.dart';

import '../models/client.dart';
import '../models/estimate.dart';
import '../models/invoice.dart';
import '../providers/business_profile_provider.dart';
import '../providers/estimate_provider.dart';
import '../providers/invoice_repository_provider.dart';
import '../utils/pdf_generator.dart';

/// Mixin to handle shared logic for Estimate Forms (Material & Fluent UI)
mixin EstimateFormMixin<T extends ConsumerStatefulWidget> on ConsumerState<T> {
  final formKey = GlobalKey<FormState>();

  // Controllers
  late TextEditingController estimateNoCtrl;
  late TextEditingController notesCtrl;
  late TextEditingController termsCtrl;
  late TextEditingController receiverNameCtrl;
  late TextEditingController receiverAddressCtrl;
  late TextEditingController receiverGstinCtrl;
  late TextEditingController receiverStateCtrl;

  // State Variables
  List<InvoiceItem> items = [];
  DateTime date = DateTime.now();
  DateTime? expiryDate;
  Estimate? existingEstimate;
  bool isInit = true;

  void initEstimateControllers() {
    estimateNoCtrl = TextEditingController();
    notesCtrl = TextEditingController();
    termsCtrl = TextEditingController();
    receiverNameCtrl = TextEditingController();
    receiverAddressCtrl = TextEditingController();
    receiverGstinCtrl = TextEditingController();
    receiverStateCtrl = TextEditingController();
  }

  void disposeEstimateControllers() {
    estimateNoCtrl.dispose();
    notesCtrl.dispose();
    termsCtrl.dispose();
    receiverNameCtrl.dispose();
    receiverAddressCtrl.dispose();
    receiverGstinCtrl.dispose();
    receiverStateCtrl.dispose();
  }

  /// Initialize data from existing estimate or defaults
  Future<void> initializeEstimateData({String? estimateId}) async {
    final profile = ref.read(businessProfileProvider);
    date = DateTime.now();
    expiryDate = DateTime.now().add(const Duration(days: 30));

    // Defaults
    estimateNoCtrl.text =
        'EST-${DateTime.now().millisecondsSinceEpoch.toString().substring(8)}';
    notesCtrl.text = profile.defaultNotes;
    termsCtrl.text = profile.termsAndConditions;

    if (estimateId != null) {
      final estimates = await ref.read(estimateListProvider.future);
      try {
        existingEstimate = estimates.firstWhere((e) => e.id == estimateId);

        date = existingEstimate!.date;
        expiryDate = existingEstimate!.expiryDate;
        items = List.from(existingEstimate!.items);

        estimateNoCtrl.text = existingEstimate!.estimateNo;
        notesCtrl.text = existingEstimate!.notes;
        termsCtrl.text = existingEstimate!.terms;
        receiverNameCtrl.text = existingEstimate!.receiver.name;
        receiverAddressCtrl.text = existingEstimate!.receiver.address;
        receiverGstinCtrl.text = existingEstimate!.receiver.gstin;
        receiverStateCtrl.text = existingEstimate!.receiver.state;
      } catch (e) {
        // Handle not found
        debugPrint('Estimate not found: $e');
      }
    }

    if (mounted) setState(() {});
  }

  /// Update controllers when a client is selected
  void onClientSelected(Client client) {
    setState(() {
      receiverNameCtrl.text = client.name;
      receiverAddressCtrl.text = client.address;
      receiverGstinCtrl.text = client.gstin;
      receiverStateCtrl.text = client.state;
    });
  }

  /// Save the estimate
  Future<void> saveEstimate(BuildContext context) async {
    // Basic validation
    if (items.isEmpty) {
      throw Exception('Please add at least one item');
    }

    final profile = ref.read(businessProfileProvider);

    final supplier = Supplier(
      name: profile.companyName,
      address: profile.address,
      gstin: profile.gstin,
      email: profile.email,
      phone: profile.phone,
      state: profile.state,
    );

    final receiver = Receiver(
      name: receiverNameCtrl.text,
      address: receiverAddressCtrl.text,
      gstin: receiverGstinCtrl.text,
      state: receiverStateCtrl.text,
    );

    final newEstimate = Estimate(
      id: existingEstimate?.id ?? const Uuid().v4(),
      estimateNo: estimateNoCtrl.text,
      date: date,
      expiryDate: expiryDate,
      supplier: supplier,
      receiver: receiver,
      items: items,
      notes: notesCtrl.text,
      terms: termsCtrl.text,
      status: existingEstimate?.status ?? 'Draft',
    );

    await ref.read(estimateListProvider.notifier).saveEstimate(newEstimate);
  }

  /// Convert estimate to invoice
  Future<String> convertToInvoice() async {
    if (existingEstimate == null) throw Exception('No estimate to convert');

    final profile = ref.read(businessProfileProvider);
    final invoiceNo = '${profile.invoiceSeries}${profile.invoiceSequence}';

    final newInvoice = Invoice(
      id: const Uuid().v4(),
      style: 'Modern',
      supplier: existingEstimate!.supplier,
      receiver: existingEstimate!.receiver,
      invoiceNo: invoiceNo,
      invoiceDate: DateTime.now(),
      placeOfSupply: existingEstimate!.receiver.state,
      items: existingEstimate!.items,
      comments: existingEstimate!.notes,
      bankName: profile.bankName,
      accountNo: profile.accountNumber,
      ifscCode: profile.ifscCode,
      branch: profile.branchName,
    );

    await ref.read(invoiceRepositoryProvider).saveInvoice(newInvoice);

    // Update Estimate Status
    final updatedEstimate = existingEstimate!.copyWith(status: 'Converted');
    await ref.read(estimateListProvider.notifier).saveEstimate(updatedEstimate);

    // Increment sequence
    await ref.read(businessProfileNotifierProvider).incrementInvoiceSequence();

    return invoiceNo;
  }

  /// Print or Preview Estimate
  Future<void> printEstimate() async {
    if (existingEstimate == null) return;
    final profile = ref.read(businessProfileProvider);

    // Create transient Invoice object for printing
    final estimateInvoice = Invoice(
      id: existingEstimate!.id,
      style: 'Modern',
      supplier: existingEstimate!.supplier,
      receiver: existingEstimate!.receiver,
      invoiceNo: existingEstimate!.estimateNo,
      invoiceDate: existingEstimate!.date,
      placeOfSupply: existingEstimate!.receiver.state,
      items: existingEstimate!.items,
      comments: existingEstimate!.notes,
      bankName: profile.bankName,
      accountNo: profile.accountNumber,
      ifscCode: profile.ifscCode,
      branch: profile.branchName,
    );

    await Printing.layoutPdf(
        onLayout: (format) =>
            generateInvoicePdf(estimateInvoice, profile, title: "ESTIMATE"));
  }
}
