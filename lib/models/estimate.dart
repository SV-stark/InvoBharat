import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:uuid/uuid.dart';
import 'invoice.dart';

part 'estimate.freezed.dart';
part 'estimate.g.dart';

@freezed
abstract class Estimate with _$Estimate {
  const Estimate._();

  const factory Estimate({
    required String id,
    @Default('') String estimateNo,
    required DateTime date,
    DateTime? expiryDate,
    required Supplier supplier,
    required Receiver receiver,
    @Default([]) List<InvoiceItem> items,
    @Default('') String notes,
    @Default('') String terms,
    @Default('Draft')
    String? status, // Draft, Sent, Accepted, Rejected, Converted
  }) = _Estimate;

  factory Estimate.create({
    required Supplier supplier,
    required Receiver receiver,
    DateTime? date,
  }) {
    return Estimate(
      id: const Uuid().v4(),
      date: date ?? DateTime.now(),
      supplier: supplier,
      receiver: receiver,
    );
  }

  double get totalTaxableValue =>
      items.fold(0, (sum, item) => sum + item.netAmount);
  double get totalAmount =>
      items.fold(0, (sum, item) => sum + item.totalAmount);

  factory Estimate.fromJson(Map<String, dynamic> json) =>
      _$EstimateFromJson(json);
}
