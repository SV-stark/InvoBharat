class Invoice {
  final String? id; // Unique ID
  final String style; // 'Modern', 'Professional', 'Minimal'
  final Supplier supplier;
  final Receiver receiver;
  final String invoiceNo;
  final DateTime invoiceDate;
  final String placeOfSupply;
  final String reverseCharge; // Y/N
  final String paymentTerms;
  final List<InvoiceItem> items;
  final String comments;
  final String bankName;
  final String accountNo;
  final String ifscCode;
  final String branch;

  const Invoice({
    this.id,
    this.style = 'Modern',
    required this.supplier,
    required this.receiver,
    this.invoiceNo = '',
    required this.invoiceDate,
    this.placeOfSupply = '',
    this.reverseCharge = 'N',
    this.paymentTerms = '',
    this.items = const [],
    this.comments = '',
    this.bankName = '',
    this.accountNo = '',
    this.ifscCode = '',
    this.branch = '',
  });

  Invoice copyWith({
    String? id,
    String? style,
    Supplier? supplier,
    Receiver? receiver,
    String? invoiceNo,
    DateTime? invoiceDate,
    String? placeOfSupply,
    String? reverseCharge,
    String? paymentTerms,
    List<InvoiceItem>? items,
    String? comments,
    String? bankName,
    String? accountNo,
    String? ifscCode,
    String? branch,
  }) {
    return Invoice(
      id: id ?? this.id,
      style: style ?? this.style,
      supplier: supplier ?? this.supplier,
      receiver: receiver ?? this.receiver,
      invoiceNo: invoiceNo ?? this.invoiceNo,
      invoiceDate: invoiceDate ?? this.invoiceDate,
      placeOfSupply: placeOfSupply ?? this.placeOfSupply,
      reverseCharge: reverseCharge ?? this.reverseCharge,
      paymentTerms: paymentTerms ?? this.paymentTerms,
      items: items ?? this.items,
      comments: comments ?? this.comments,
      bankName: bankName ?? this.bankName,
      accountNo: accountNo ?? this.accountNo,
      ifscCode: ifscCode ?? this.ifscCode,
      branch: branch ?? this.branch,
    );
  }

  double get totalTaxableValue =>
      items.fold(0, (sum, item) => sum + item.amount);
  double get totalCGST => items.fold(0, (sum, item) => sum + (item.cgstAmount));
  double get totalSGST => items.fold(0, (sum, item) => sum + (item.sgstAmount));
  double get totalIGST => items.fold(0, (sum, item) => sum + (item.igstAmount));
  double get grandTotal =>
      totalTaxableValue + totalCGST + totalSGST + totalIGST;

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'style': style,
      'supplier': supplier.toJson(),
      'receiver': receiver.toJson(),
      'invoiceNo': invoiceNo,
      'invoiceDate': invoiceDate.toIso8601String(),
      'placeOfSupply': placeOfSupply,
      'reverseCharge': reverseCharge,
      'paymentTerms': paymentTerms,
      'items': items.map((i) => i.toJson()).toList(),
      'comments': comments,
      'bankName': bankName,
      'accountNo': accountNo,
      'ifscCode': ifscCode,
      'branch': branch,
    };
  }

  factory Invoice.fromJson(Map<String, dynamic> json) {
    return Invoice(
      id: json['id'],
      style: json['style'] ?? 'Modern',
      supplier: Supplier.fromJson(json['supplier']),
      receiver: Receiver.fromJson(json['receiver']),
      invoiceNo: json['invoiceNo'],
      invoiceDate: DateTime.parse(json['invoiceDate']),
      placeOfSupply: json['placeOfSupply'],
      reverseCharge: json['reverseCharge'],
      paymentTerms: json['paymentTerms'],
      items:
          (json['items'] as List).map((i) => InvoiceItem.fromJson(i)).toList(),
      comments: json['comments'],
      bankName: json['bankName'],
      accountNo: json['accountNo'],
      ifscCode: json['ifscCode'],
      branch: json['branch'],
    );
  }
}

class Supplier {
  final String name;
  final String address;
  final String gstin;
  final String pan;
  final String email;
  final String phone;

  const Supplier({
    this.name = '',
    this.address = '',
    this.gstin = '',
    this.pan = '',
    this.email = '',
    this.phone = '',
  });

  Supplier copyWith({
    String? name,
    String? address,
    String? gstin,
    String? pan,
    String? email,
    String? phone,
  }) {
    return Supplier(
      name: name ?? this.name,
      address: address ?? this.address,
      gstin: gstin ?? this.gstin,
      pan: pan ?? this.pan,
      email: email ?? this.email,
      phone: phone ?? this.phone,
    );
  }

  Map<String, dynamic> toJson() => {
        'name': name,
        'address': address,
        'gstin': gstin,
        'pan': pan,
        'email': email,
        'phone': phone,
      };

  factory Supplier.fromJson(Map<String, dynamic> json) => Supplier(
        name: json['name'] ?? '',
        address: json['address'] ?? '',
        gstin: json['gstin'] ?? '',
        pan: json['pan'] ?? '',
        email: json['email'] ?? '',
        phone: json['phone'] ?? '',
      );
}

class Receiver {
  final String name;
  final String address;
  final String gstin;
  final String pan;

  const Receiver({
    this.name = '',
    this.address = '',
    this.gstin = '',
    this.pan = '',
  });

  Receiver copyWith({
    String? name,
    String? address,
    String? gstin,
    String? pan,
  }) {
    return Receiver(
      name: name ?? this.name,
      address: address ?? this.address,
      gstin: gstin ?? this.gstin,
      pan: pan ?? this.pan,
    );
  }

  Map<String, dynamic> toJson() => {
        'name': name,
        'address': address,
        'gstin': gstin,
        'pan': pan,
      };

  factory Receiver.fromJson(Map<String, dynamic> json) => Receiver(
        name: json['name'] ?? '',
        address: json['address'] ?? '',
        gstin: json['gstin'] ?? '',
        pan: json['pan'] ?? '',
      );
}

class InvoiceItem {
  final String description;
  final String sacCode;
  final String year; // e.g. "F.Y. 2025-26"
  final double amount; // Taxable Value
  final double discount; // Optional

  final double gstRate; // e.g. 18.0 for 18%

  // Computed helpers
  double get netAmount => amount - discount;
  double get cgstRate => gstRate / 2;
  double get sgstRate => gstRate / 2;

  double get cgstAmount => netAmount * (cgstRate / 100);
  double get sgstAmount => netAmount * (sgstRate / 100);
  double get igstAmount => 0;

  double get totalAmount => netAmount + cgstAmount + sgstAmount;

  const InvoiceItem({
    this.description = '',
    this.sacCode = '',
    this.year = '',
    this.amount = 0,
    this.discount = 0,
    this.gstRate = 18.0,
  });

  InvoiceItem copyWith({
    String? description,
    String? sacCode,
    String? year,
    double? amount,
    double? discount,
    double? gstRate,
  }) {
    return InvoiceItem(
      description: description ?? this.description,
      sacCode: sacCode ?? this.sacCode,
      year: year ?? this.year,
      amount: amount ?? this.amount,
      discount: discount ?? this.discount,
      gstRate: gstRate ?? this.gstRate,
    );
  }

  Map<String, dynamic> toJson() => {
        'description': description,
        'sacCode': sacCode,
        'year': year,
        'amount': amount,
        'discount': discount,
        'gstRate': gstRate,
      };

  factory InvoiceItem.fromJson(Map<String, dynamic> json) => InvoiceItem(
        description: json['description'] ?? '',
        sacCode: json['sacCode'] ?? '',
        year: json['year'] ?? '',
        amount: (json['amount'] as num).toDouble(),
        discount: (json['discount'] as num).toDouble(),
        gstRate: (json['gstRate'] as num).toDouble(),
      );
}
