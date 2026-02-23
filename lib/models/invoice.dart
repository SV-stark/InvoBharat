import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:invobharat/models/payment_transaction.dart';

part 'invoice.freezed.dart';
part 'invoice.g.dart';

enum InvoiceType { invoice, deliveryChallan, creditNote, debitNote }

@freezed
abstract class Invoice with _$Invoice {
  const Invoice._(); // Needed for custom methods/getters

  const factory Invoice({
    final String? id,
    @Default('Modern') final String style,
    required final Supplier supplier,
    required final Receiver receiver,
    @Default('') final String invoiceNo,
    required final DateTime invoiceDate,
    final DateTime? dueDate,
    @Default('') final String placeOfSupply,
    @Default('N') final String reverseCharge,
    @Default('') final String paymentTerms,
    @Default([]) final List<InvoiceItem> items,
    @Default([]) final List<PaymentTransaction> payments,
    @Default('') final String comments,
    @Default('') final String bankName,
    @Default('') final String accountNo,
    @Default('') final String ifscCode,
    @Default('') final String branch,
    final String? deliveryAddress,
    @Default(false) final bool isArchived, // Phase 4
    @Default('INR') final String currency, // Phase 4
    @Default(0.0) final double discountAmount, // NEW: Invoice level discount
    @Default(InvoiceType.invoice)
    final InvoiceType type, // NEW: Delivery Challan Support
    // Credit/Debit Note Fields
    final String? originalInvoiceNumber,
    final DateTime? originalInvoiceDate,
  }) = _Invoice;

  factory Invoice.fromJson(final Map<String, dynamic> json) =>
      _$InvoiceFromJson(json);

  bool get isInterState {
    if (supplier.state.isEmpty || placeOfSupply.isEmpty) return false;
    return supplier.state.trim().toLowerCase() !=
        placeOfSupply.trim().toLowerCase();
  }

  double get totalTaxableValue =>
      items.fold(0, (final sum, final item) => sum + item.netAmount);

  double get totalCGST => items.fold(
      0, (final sum, final item) => sum + (isInterState ? 0 : item.calculateCgst(false)));
  double get totalSGST => items.fold(
      0, (final sum, final item) => sum + (isInterState ? 0 : item.calculateSgst(false)));
  double get totalIGST => items.fold(
      0, (final sum, final item) => sum + (isInterState ? item.calculateIgst(true) : 0));

  double get grandTotal {
    final total = totalTaxableValue + totalCGST + totalSGST + totalIGST;
    return total - discountAmount;
  }

  double get totalPaid => payments.fold(0, (final sum, final p) => sum + p.amount);

  double get balanceDue => grandTotal - totalPaid;

  String get paymentStatus {
    if (totalPaid >= grandTotal - 0.01) return 'Paid';
    if (totalPaid > 0) return 'Partial';
    if (dueDate != null && DateTime.now().isAfter(dueDate!)) {
      return 'Overdue';
    }
    return 'Unpaid';
  }
}

@freezed
abstract class Supplier with _$Supplier {
  const factory Supplier({
    @Default('') final String name,
    @Default('') final String address,
    @Default('') final String gstin,
    @Default('') final String pan,
    @Default('') final String email,
    @Default('') final String phone,
    @Default('') final String state,
  }) = _Supplier;

  factory Supplier.fromJson(final Map<String, dynamic> json) =>
      _$SupplierFromJson(json);
}

@freezed
abstract class Receiver with _$Receiver {
  const factory Receiver({
    @Default('') final String name,
    @Default('') final String address,
    @Default('') final String gstin,
    @Default('') final String pan,
    @Default('') final String state,
    @Default('') final String stateCode,
    @Default('') final String email, // NEW
  }) = _Receiver;

  factory Receiver.fromJson(final Map<String, dynamic> json) =>
      _$ReceiverFromJson(json);
}

@freezed
abstract class InvoiceItem with _$InvoiceItem {
  const InvoiceItem._();

  const factory InvoiceItem({
    final String?
        id, // Will be generated in factory constructor if null? No, freezed doesn't support logic in constructor easily.
    // We'll handle ID generation in the code that creates the item, or use @Default(Uuid().v4())?
    // Default values must be const. Uuid().v4() is not const.
    // We'll make it nullable and handle it.
    // OR we'll use a custom factory?
    // Let's make it nullable here, but commonly generated.
    // In original code: id = id ?? const Uuid().v4();
    // In freezed, if we pass null, it stays null.
    // We can't have logic.
    // Best Practice: Accept null in constructor, but ensure it's set before saving?
    // Or better: Let's assume it's optional string. If null, we treat as new.
    @Default('') final String description,
    @Default('') final String sacCode,
    @Default('SAC') final String codeType,
    @Default('') final String year, // e.g. "F.Y. 2025-26"
    @Default(0) final double amount,
    @Default(0) final double discount,
    @Default(1.0) final double quantity,
    @Default('Nos') final String unit,
    @Default(18.0) final double gstRate,
  }) = _InvoiceItem;

  factory InvoiceItem.fromJson(final Map<String, dynamic> json) =>
      _$InvoiceItemFromJson(json);

  double get netAmount => (amount * quantity) - discount;
  double get cgstRate => gstRate / 2;
  double get sgstRate => gstRate / 2;
  double get cgstAmount => netAmount * (cgstRate / 100);
  double get sgstAmount => netAmount * (sgstRate / 100);
  double get igstAmount => netAmount * (gstRate / 100);

  double calculateCgst(final bool isInterState) =>
      isInterState ? 0 : netAmount * (cgstRate / 100);
  double calculateSgst(final bool isInterState) =>
      isInterState ? 0 : netAmount * (sgstRate / 100);
  double calculateIgst(final bool isInterState) =>
      isInterState ? netAmount * (gstRate / 100) : 0;

  double get totalAmount => netAmount * (1 + gstRate / 100);
}

// NOTE: InvoiceItem default UUID generation is removed from constructor.
// Callers must generate UUID if they want one, or we handle it in services.
