import 'dart:math' as math;
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:invobharat/models/payment_transaction.dart';
import 'package:invobharat/utils/gst_utils.dart';
import 'package:money2/money2.dart';

part 'invoice.freezed.dart';
part 'invoice.g.dart';

enum InvoiceType { invoice, deliveryChallan, creditNote, debitNote }

@freezed
abstract class Invoice with _$Invoice {
  const Invoice._();

  const factory Invoice({
    String? id,
    String? profileId,
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
    @Default(false) bool isArchived,
    @Default('INR') String currency,
    @Default(0.0) double discountAmount,
    @Default(InvoiceType.invoice) InvoiceType type,
    String? originalInvoiceNumber,
    DateTime? originalInvoiceDate,
    String? poNumber,
    @Default('Draft') String status,
    DateTime? sentAt,
    String? ewayBillNo,
    String? vehicleNo,
    String? irnNo,
  }) = _Invoice;

  factory Invoice.fromJson(final Map<String, dynamic> json) =>
      _$InvoiceFromJson(json);

  Currency get _currencyObj =>
      Currencies().find(currency) ?? CommonCurrencies().inr;

  bool get isInterState {
    // 1. Effective Place of Supply (POS)
    final posInput = placeOfSupply.isNotEmpty ? placeOfSupply : receiver.state;
    final posCode =
        GstUtils.getStateCodeFromInput(posInput) ??
        (receiver.gstin.length >= 2
            ? GstUtils.getStateCodeFromInput(receiver.gstin.substring(0, 2))
            : null) ??
        GstUtils.getStateCodeFromInput(receiver.stateCode);

    // 2. Effective Supplier State
    final suppInput = supplier.state;
    final suppCode =
        GstUtils.getStateCodeFromInput(suppInput) ??
        (supplier.gstin.length >= 2
            ? GstUtils.getStateCodeFromInput(supplier.gstin.substring(0, 2))
            : null);

    if (suppCode != null && posCode != null) {
      return suppCode != posCode;
    }

    // Fallback: compare raw trimmed strings
    if (suppInput.isEmpty || posInput.isEmpty) return false;
    return suppInput.trim().toLowerCase() != posInput.trim().toLowerCase();
  }

  double get grossTaxableValue =>
      items.fold(0.0, (final sum, final item) => sum + item.netAmount);

  double get totalTaxableValue =>
      math.max(0.0, grossTaxableValue - discountAmount);

  double itemTaxableValue(final InvoiceItem item) {
    if (grossTaxableValue <= 0 || discountAmount <= 0) {
      return item.netAmount;
    }
    final discountRatio =
        math.min(discountAmount, grossTaxableValue) / grossTaxableValue;
    return math.max(0.0, item.netAmount * (1 - discountRatio));
  }

  double itemCgstAmount(final InvoiceItem item) {
    if (isInterState) return 0;
    final taxableMoney =
        Money.fromNumWithCurrency(itemTaxableValue(item), _currencyObj);
    return (taxableMoney * (item.cgstRate / 100)).toDouble();
  }

  double itemSgstAmount(final InvoiceItem item) {
    if (isInterState) return 0;
    final taxableMoney =
        Money.fromNumWithCurrency(itemTaxableValue(item), _currencyObj);
    return (taxableMoney * (item.sgstRate / 100)).toDouble();
  }

  double itemIgstAmount(final InvoiceItem item) {
    if (!isInterState) return 0;
    final taxableMoney =
        Money.fromNumWithCurrency(itemTaxableValue(item), _currencyObj);
    return (taxableMoney * (item.gstRate / 100)).toDouble();
  }

  double itemTotalAmount(final InvoiceItem item) {
    final taxableMoney =
        Money.fromNumWithCurrency(itemTaxableValue(item), _currencyObj);
    if (isInterState) {
      final igstMoney = taxableMoney * (item.gstRate / 100);
      return (taxableMoney + igstMoney).toDouble();
    } else {
      final cgstMoney = taxableMoney * (item.cgstRate / 100);
      final sgstMoney = taxableMoney * (item.sgstRate / 100);
      return (taxableMoney + cgstMoney + sgstMoney).toDouble();
    }
  }

  double get totalCGST {
    if (isInterState) return 0;
    final total = items.fold(
      Money.fromNumWithCurrency(0, _currencyObj),
      (final sum, final item) {
        final taxableMoney =
            Money.fromNumWithCurrency(itemTaxableValue(item), _currencyObj);
        return sum + (taxableMoney * (item.cgstRate / 100));
      },
    );
    return total.toDouble();
  }

  double get totalSGST {
    if (isInterState) return 0;
    final total = items.fold(
      Money.fromNumWithCurrency(0, _currencyObj),
      (final sum, final item) {
        final taxableMoney =
            Money.fromNumWithCurrency(itemTaxableValue(item), _currencyObj);
        return sum + (taxableMoney * (item.sgstRate / 100));
      },
    );
    return total.toDouble();
  }

  double get totalIGST {
    if (!isInterState) return 0;
    final total = items.fold(
      Money.fromNumWithCurrency(0, _currencyObj),
      (final sum, final item) {
        final taxableMoney =
            Money.fromNumWithCurrency(itemTaxableValue(item), _currencyObj);
        return sum + (taxableMoney * (item.gstRate / 100));
      },
    );
    return total.toDouble();
  }

  double get grandTotal {
    final taxable = Money.fromNumWithCurrency(totalTaxableValue, _currencyObj);
    final cgst = Money.fromNumWithCurrency(totalCGST, _currencyObj);
    final sgst = Money.fromNumWithCurrency(totalSGST, _currencyObj);
    final igst = Money.fromNumWithCurrency(totalIGST, _currencyObj);

    return (taxable + cgst + sgst + igst).toDouble();
  }

  double get totalPaid {
    final paid = payments.fold(
      Money.fromNumWithCurrency(0, _currencyObj),
      (final sum, final p) =>
          sum + Money.fromNumWithCurrency(p.amount, _currencyObj),
    );
    return paid.toDouble();
  }

  double get balanceDue {
    final grand = Money.fromNumWithCurrency(grandTotal, _currencyObj);
    final paid = Money.fromNumWithCurrency(totalPaid, _currencyObj);
    final diff = grand - paid;
    return diff.toDouble();
  }

  String get paymentStatus {
    if (totalPaid >= grandTotal - 0.001) return 'Paid';
    if (dueDate != null && DateTime.now().isAfter(dueDate!)) {
      return 'Overdue';
    }
    if (totalPaid > 0) return 'Partial';
    return 'Unpaid';
  }
}

@freezed
abstract class Supplier with _$Supplier {
  const factory Supplier({
    @Default('') String name,
    @Default('') String address,
    @Default('') String gstin,
    @Default('') String pan,
    @Default('') String email,
    @Default('') String phone,
    @Default('') String state,
  }) = _Supplier;

  factory Supplier.fromJson(final Map<String, dynamic> json) =>
      _$SupplierFromJson(json);
}

@freezed
abstract class Receiver with _$Receiver {
  const factory Receiver({
    @Default('') String name,
    @Default('') String address,
    @Default('') String gstin,
    @Default('') String pan,
    @Default('') String state,
    @Default('') String stateCode,
    @Default('') String email,
    @Default('') String phone,
  }) = _Receiver;

  factory Receiver.fromJson(final Map<String, dynamic> json) =>
      _$ReceiverFromJson(json);
}

@freezed
abstract class InvoiceItem with _$InvoiceItem {
  const InvoiceItem._();

  const factory InvoiceItem({
    String? id,
    @Default('') String description,
    @Default('') String sacCode,
    @Default('SAC') String codeType,
    @Default('') String year,
    @Default(0) double amount,
    @Default(0) double discount,
    @Default(1.0) double quantity,
    @Default('Nos') String unit,
    @Default(18.0) double gstRate,
    @Default('INR') String currency,
  }) = _InvoiceItem;

  factory InvoiceItem.fromJson(final Map<String, dynamic> json) =>
      _$InvoiceItemFromJson(json);

  Currency get _currency =>
      Currencies().find(currency) ?? CommonCurrencies().inr;

  double get netAmount => math.max(0.0, (amount * quantity) - discount);

  String get cleanSacCode => sacCode.split(' - ').first.trim();

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
    // igstMoney represents the full GST (gstRate), which is the same as cgst + sgst.
    // Pick one to avoid double-counting.
    return (netAmountMoney + igstMoney).toDouble();
  }
}
