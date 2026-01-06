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
}
