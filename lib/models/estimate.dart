import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:uuid/uuid.dart';
import 'package:invobharat/models/invoice.dart';
import 'package:invobharat/utils/gst_utils.dart';

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
    final posInput = receiver.state;
    final posCode = GstUtils.getStateCodeFromInput(posInput) ??
        (receiver.gstin.length >= 2 ? GstUtils.getStateCodeFromInput(receiver.gstin.substring(0, 2)) : null) ??
        GstUtils.getStateCodeFromInput(receiver.stateCode);

    final suppInput = supplier.state;
    final suppCode = GstUtils.getStateCodeFromInput(suppInput) ??
        (supplier.gstin.length >= 2 ? GstUtils.getStateCodeFromInput(supplier.gstin.substring(0, 2)) : null);

    if (suppCode != null && posCode != null) {
      return suppCode != posCode;
    }

    if (suppInput.isEmpty || posInput.isEmpty) return false;
    return suppInput.trim().toLowerCase() != posInput.trim().toLowerCase();
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
