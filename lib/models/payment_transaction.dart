class PaymentTransaction {
  final String id;
  final String invoiceId;
  final DateTime date;
  final double amount;
  final String paymentMode; // 'Cash', 'UPI', 'Bank Transfer', 'Cheque', 'Other'
  final String? notes;

  const PaymentTransaction({
    required this.id,
    required this.invoiceId,
    required this.date,
    required this.amount,
    required this.paymentMode,
    this.notes,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'invoiceId': invoiceId,
      'date': date.toIso8601String(),
      'amount': amount,
      'paymentMode': paymentMode,
      'notes': notes,
    };
  }

  factory PaymentTransaction.fromJson(Map<String, dynamic> json) {
    return PaymentTransaction(
      id: json['id'],
      invoiceId: json['invoiceId'],
      date: DateTime.parse(json['date']),
      amount: (json['amount'] as num).toDouble(),
      paymentMode: json['paymentMode'] ?? 'Cash',
      notes: json['notes'],
    );
  }
}
