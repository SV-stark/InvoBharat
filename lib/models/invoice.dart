class Invoice {
  Supplier supplier;
  Receiver receiver;
  String invoiceNo;
  DateTime invoiceDate;
  String placeOfSupply;
  String reverseCharge; // Y/N
  String paymentTerms;
  List<InvoiceItem> items;
  String comments;
  String bankName;
  String accountNo;
  String ifscCode;
  String branch;

  Invoice({
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

  double get totalTaxableValue => items.fold(0, (sum, item) => sum + item.amount);
  double get totalCGST => items.fold(0, (sum, item) => sum + (item.cgstAmount ?? 0));
  double get totalSGST => items.fold(0, (sum, item) => sum + (item.sgstAmount ?? 0));
  double get totalIGST => items.fold(0, (sum, item) => sum + (item.igstAmount ?? 0));
  double get grandTotal => totalTaxableValue + totalCGST + totalSGST + totalIGST;
  double get grandTotal => totalTaxableValue + totalCGST + totalSGST + totalIGST;

  Map<String, dynamic> toJson() {
    return {
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
      supplier: Supplier.fromJson(json['supplier']),
      receiver: Receiver.fromJson(json['receiver']),
      invoiceNo: json['invoiceNo'],
      invoiceDate: DateTime.parse(json['invoiceDate']),
      placeOfSupply: json['placeOfSupply'],
      reverseCharge: json['reverseCharge'],
      paymentTerms: json['paymentTerms'],
      items: (json['items'] as List).map((i) => InvoiceItem.fromJson(i)).toList(),
      comments: json['comments'],
      bankName: json['bankName'],
      accountNo: json['accountNo'],
      ifscCode: json['ifscCode'],
      branch: json['branch'],
    );
  }
}

class Supplier {
  String name;
  String address;
  String gstin;
  String pan;
  String email;
  String phone;

  Supplier({
    this.name = '',
    this.address = '',
    this.gstin = '',
    this.pan = '',
    this.email = '',
    this.phone = '',
  });
  });

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
  String name;
  String address;
  String gstin;
  String pan;

  Receiver({
    this.name = '',
    this.address = '',
    this.gstin = '',
    this.pan = '',
  });
  });

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
  String description;
  String sacCode;
  String year; // e.g. "F.Y. 2025-26"
  double amount; // Taxable Value
  double discount; // Optional
  double netAmount; // amount - discount
  
  double gstRate; // e.g. 18.0 for 18%
  
  // Computed helpers for CGST/SGST (assuming intra-state 50/50 split)
  double get cgstRate => gstRate / 2;
  double get sgstRate => gstRate / 2;

  double get cgstAmount => netAmount * (cgstRate / 100);
  double get sgstAmount => netAmount * (sgstRate / 100);
  double get igstAmount => 0; // Logic can be expanded for inter-state

  double get totalAmount => netAmount + cgstAmount + sgstAmount;

  InvoiceItem({
    this.description = '',
    this.sacCode = '',
    this.year = '',
    this.amount = 0,
    this.discount = 0,
    this.gstRate = 18.0,
  }) : netAmount = amount - discount;
  }) : netAmount = amount - discount;

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
