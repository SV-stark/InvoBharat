import 'package:uuid/uuid.dart';
import 'invoice.dart';

class Estimate {
  final String id;
  final String estimateNo;
  final DateTime date;
  final DateTime? expiryDate;
  final Supplier supplier;
  final Receiver receiver;
  final List<InvoiceItem> items;
  final String notes;
  final String terms;
  final String? status; // Draft, Sent, Accepted, Rejected, Converted

  const Estimate({
    required this.id,
    this.estimateNo = '',
    required this.date,
    this.expiryDate,
    required this.supplier,
    required this.receiver,
    this.items = const [],
    this.notes = '',
    this.terms = '',
    this.status = 'Draft',
  });

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

  Estimate copyWith({
    String? id,
    String? estimateNo,
    DateTime? date,
    DateTime? expiryDate,
    Supplier? supplier,
    Receiver? receiver,
    List<InvoiceItem>? items,
    String? notes,
    String? terms,
    String? status,
  }) {
    return Estimate(
      id: id ?? this.id,
      estimateNo: estimateNo ?? this.estimateNo,
      date: date ?? this.date,
      expiryDate: expiryDate ?? this.expiryDate,
      supplier: supplier ?? this.supplier,
      receiver: receiver ?? this.receiver,
      items: items ?? this.items,
      notes: notes ?? this.notes,
      terms: terms ?? this.terms,
      status: status ?? this.status,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'estimateNo': estimateNo,
      'date': date.toIso8601String(),
      'expiryDate': expiryDate?.toIso8601String(),
      'supplier': supplier.toJson(),
      'receiver': receiver.toJson(),
      'items': items.map((e) => e.toJson()).toList(),
      'notes': notes,
      'terms': terms,
      'status': status,
    };
  }

  factory Estimate.fromJson(Map<String, dynamic> json) {
    return Estimate(
      id: json['id'],
      estimateNo: json['estimateNo'] ?? '',
      date: DateTime.parse(json['date']),
      expiryDate: json['expiryDate'] != null
          ? DateTime.parse(json['expiryDate'])
          : null,
      supplier: Supplier.fromJson(json['supplier']),
      receiver: Receiver.fromJson(json['receiver']),
      items:
          (json['items'] as List).map((e) => InvoiceItem.fromJson(e)).toList(),
      notes: json['notes'] ?? '',
      terms: json['terms'] ?? '',
      status: json['status'] ?? 'Draft',
    );
  }
}
