import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:uuid/uuid.dart';
import 'package:invobharat/models/invoice.dart';

part 'estimate.freezed.dart';
part 'estimate.g.dart';

@freezed
abstract class Estimate with _$Estimate {
  const Estimate._();

  const factory Estimate({
    required final String id,
    @Default('') final String estimateNo,
    required final DateTime date,
    final DateTime? expiryDate,
    required final Supplier supplier,
    required final Receiver receiver,
    @Default([]) final List<InvoiceItem> items,
    @Default('') final String notes,
    @Default('') final String terms,
    @Default('Draft')
    final String? status, // Draft, Sent, Accepted, Rejected, Converted
    final String? poNumber,
  }) = _Estimate;

  factory Estimate.create({
    required final Supplier supplier,
    required final Receiver receiver,
    final DateTime? date,
  }) {
    return Estimate(
      id: const Uuid().v4(),
      date: date ?? DateTime.now(),
      supplier: supplier,
      receiver: receiver,
    );
  }

  bool get isInterState {
    if (supplier.state.isEmpty || receiver.state.isEmpty) return false;
    return supplier.state.trim().toLowerCase() !=
        receiver.state.trim().toLowerCase();
  }

  double get totalTaxableValue =>
      items.fold(0, (final sum, final item) => sum + item.netAmount);

  double get totalCGST => isInterState
      ? 0
      : items.fold(0, (final sum, final item) => sum + item.cgstAmount);

  double get totalSGST => isInterState
      ? 0
      : items.fold(0, (final sum, final item) => sum + item.sgstAmount);

  double get totalIGST => isInterState
      ? items.fold(0, (final sum, final item) => sum + item.igstAmount)
      : 0;

  double get totalAmount =>
      totalTaxableValue + totalCGST + totalSGST + totalIGST;

  factory Estimate.fromJson(final Map<String, dynamic> json) =>
      _$EstimateFromJson(json);
}
