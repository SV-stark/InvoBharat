import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:invobharat/models/payment_transaction.dart';
import 'package:money2/money2.dart';

part 'invoice.freezed.dart';
part 'invoice.g.dart';

enum InvoiceType { invoice, deliveryChallan, creditNote, debitNote }

@freezed
abstract class Invoice with _$Invoice {
  const Invoice._();

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
    @Default(false) final bool isArchived,
    @Default('INR') final String currency,
    @Default(0.0) final double discountAmount,
    @Default(InvoiceType.invoice) final InvoiceType type,
    final String? originalInvoiceNumber,
    final DateTime? originalInvoiceDate,
  }) = _Invoice;

  factory Invoice.fromJson(final Map<String, dynamic> json) =>
      _$InvoiceFromJson(json);

  Currency get _currencyObj =>
      Currencies().find(currency) ?? CommonCurrencies().inr;

  bool get isInterState {
    if (supplier.state.isEmpty || placeOfSupply.isEmpty) return false;
    return supplier.state.trim().toLowerCase() !=
        placeOfSupply.trim().toLowerCase();
  }

  double get totalTaxableValue =>
      items.fold(0, (final sum, final item) => sum + item.netAmount);

  double get totalCGST {
    if (isInterState) return 0;
    final total = items.fold(
      Money.fromNumWithCurrency(0, _currencyObj),
      (final sum, final item) => sum + item.cgstMoney,
    );
    return total.toDouble();
  }

  double get totalSGST {
    if (isInterState) return 0;
    final total = items.fold(
      Money.fromNumWithCurrency(0, _currencyObj),
      (final sum, final item) => sum + item.sgstMoney,
    );
    return total.toDouble();
  }

  double get totalIGST {
    if (!isInterState) return 0;
    final total = items.fold(
      Money.fromNumWithCurrency(0, _currencyObj),
      (final sum, final item) => sum + item.igstMoney,
    );
    return total.toDouble();
  }

  double get grandTotal {
    final taxable = Money.fromNumWithCurrency(totalTaxableValue, _currencyObj);
    final discount = Money.fromNumWithCurrency(discountAmount, _currencyObj);

    return (taxable +
            Money.fromNumWithCurrency(totalCGST, _currencyObj) +
            Money.fromNumWithCurrency(totalSGST, _currencyObj) +
            Money.fromNumWithCurrency(totalIGST, _currencyObj) -
            discount)
        .toDouble();
  }

  double get totalPaid =>
      payments.fold(0, (final sum, final p) => sum + p.amount);

  double get balanceDue => grandTotal - totalPaid;

  String get paymentStatus {
    if (totalPaid >= grandTotal - 0.001) return 'Paid';
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
    @Default('') final String email,
  }) = _Receiver;

  factory Receiver.fromJson(final Map<String, dynamic> json) =>
      _$ReceiverFromJson(json);
}

@freezed
abstract class InvoiceItem with _$InvoiceItem {
  const InvoiceItem._();

  const factory InvoiceItem({
    final String? id,
    @Default('') final String description,
    @Default('') final String sacCode,
    @Default('SAC') final String codeType,
    @Default('') final String year,
    @Default(0) final double amount,
    @Default(0) final double discount,
    @Default(1.0) final double quantity,
    @Default('Nos') final String unit,
    @Default(18.0) final double gstRate,
  }) = _InvoiceItem;

  factory InvoiceItem.fromJson(final Map<String, dynamic> json) =>
      _$InvoiceItemFromJson(json);

  // We assume default currency is INR for these internal calculations if not specified, 
  // but models don't have currency. Invoice has it. 
  // For precise rounding, we should use the currency from the invoice.
  // Since InvoiceItem doesn't know its parent, we use INR as a safe default for precision (2 decimal).
  Currency get _currency => CommonCurrencies().inr;

  double get netAmount => (amount * quantity) - discount;

  Money get netAmountMoney => Money.fromNumWithCurrency(netAmount, _currency);

  double get cgstRate => gstRate / 2;
  double get sgstRate => gstRate / 2;

  Money get cgstMoney => netAmountMoney * (cgstRate / 100);
  Money get sgstMoney => netAmountMoney * (sgstRate / 100);
  Money get igstMoney => netAmountMoney * (gstRate / 100);

  double get cgstAmount => cgstMoney.toDouble();
  double get sgstAmount => sgstMoney.toDouble();
  double get igstAmount => igstMoney.toDouble();

  double calculateCgst(final bool isInterState) =>
      isInterState ? 0 : cgstAmount;
  double calculateSgst(final bool isInterState) =>
      isInterState ? 0 : sgstAmount;
  double calculateIgst(final bool isInterState) =>
      isInterState ? igstAmount : 0;

  double get totalAmount {
    // We don't know if it's interstate here, but for Indian GST:
    // Total = Net + CGST + SGST OR Net + IGST.
    // Both sums should be identical if using Money.
    return (netAmountMoney + igstMoney).toDouble();
  }
}
