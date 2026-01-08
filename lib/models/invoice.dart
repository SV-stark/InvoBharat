import 'package:freezed_annotation/freezed_annotation.dart';
import 'payment_transaction.dart';

part 'invoice.freezed.dart';
part 'invoice.g.dart';

@freezed
class Invoice with _$Invoice {
  const Invoice._(); // Needed for custom methods/getters

  const factory Invoice({
    String? id,
    @Default('Modern') String style,
    required Supplier supplier,
    required Receiver receiver,
    @Default('') String invoiceNo,
    required DateTime invoiceDate,
    DateTime? dueDate,
    @Default('') String placeOfSupply,
    @Default('N') String reverseCharge,
    @Default('') String paymentTerms,
    @Default([]) List<InvoiceItem> items,
    @Default([]) List<PaymentTransaction> payments,
    @Default('') String comments,
    @Default('') String bankName,
    @Default('') String accountNo,
    @Default('') String ifscCode,
    @Default('') String branch,
    String? deliveryAddress,
  }) = _Invoice;

  factory Invoice.fromJson(Map<String, dynamic> json) =>
      _$InvoiceFromJson(json);

  bool get isInterState {
    if (supplier.state.isEmpty || placeOfSupply.isEmpty) return false;
    return supplier.state.trim().toLowerCase() !=
        placeOfSupply.trim().toLowerCase();
  }

  double get totalTaxableValue =>
      items.fold(0, (sum, item) => sum + item.netAmount);

  double get totalCGST => items.fold(
      0, (sum, item) => sum + (isInterState ? 0 : item.calculateCgst(false)));
  double get totalSGST => items.fold(
      0, (sum, item) => sum + (isInterState ? 0 : item.calculateSgst(false)));
  double get totalIGST => items.fold(
      0, (sum, item) => sum + (isInterState ? item.calculateIgst(true) : 0));

  double get grandTotal =>
      totalTaxableValue + totalCGST + totalSGST + totalIGST;

  double get totalPaid => payments.fold(0, (sum, p) => sum + p.amount);

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
class Supplier with _$Supplier {
  const factory Supplier({
    @Default('') String name,
    @Default('') String address,
    @Default('') String gstin,
    @Default('') String pan,
    @Default('') String email,
    @Default('') String phone,
    @Default('') String state,
  }) = _Supplier;

  factory Supplier.fromJson(Map<String, dynamic> json) =>
      _$SupplierFromJson(json);
}

@freezed
class Receiver with _$Receiver {
  const factory Receiver({
    @Default('') String name,
    @Default('') String address,
    @Default('') String gstin,
    @Default('') String pan,
    @Default('') String state,
    @Default('') String stateCode,
  }) = _Receiver;

  factory Receiver.fromJson(Map<String, dynamic> json) =>
      _$ReceiverFromJson(json);
}

@freezed
class InvoiceItem with _$InvoiceItem {
  const InvoiceItem._();

  const factory InvoiceItem({
    String?
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
    @Default('') String description,
    @Default('') String sacCode,
    @Default('SAC') String codeType,
    @Default('') String year, // e.g. "F.Y. 2025-26"
    @Default(0) double amount,
    @Default(0) double discount,
    @Default(1.0) double quantity,
    @Default('Nos') String unit,
    @Default(18.0) double gstRate,
  }) = _InvoiceItem;

  factory InvoiceItem.fromJson(Map<String, dynamic> json) =>
      _$InvoiceItemFromJson(json);

  double get netAmount => (amount * quantity) - discount;
  double get cgstRate => gstRate / 2;
  double get sgstRate => gstRate / 2;
  double get cgstAmount => netAmount * (cgstRate / 100);
  double get sgstAmount => netAmount * (sgstRate / 100);
  double get igstAmount => netAmount * (gstRate / 100);

  double calculateCgst(bool isInterState) =>
      isInterState ? 0 : netAmount * (cgstRate / 100);
  double calculateSgst(bool isInterState) =>
      isInterState ? 0 : netAmount * (sgstRate / 100);
  double calculateIgst(bool isInterState) =>
      isInterState ? netAmount * (gstRate / 100) : 0;

  double get totalAmount => netAmount * (1 + gstRate / 100);
}

// NOTE: InvoiceItem default UUID generation is removed from constructor.
// Callers must generate UUID if they want one, or we handle it in services.
