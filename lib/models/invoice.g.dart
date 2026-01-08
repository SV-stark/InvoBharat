// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'invoice.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_Invoice _$InvoiceFromJson(Map<String, dynamic> json) => _Invoice(
      id: json['id'] as String?,
      style: json['style'] as String? ?? 'Modern',
      supplier: Supplier.fromJson(json['supplier'] as Map<String, dynamic>),
      receiver: Receiver.fromJson(json['receiver'] as Map<String, dynamic>),
      invoiceNo: json['invoiceNo'] as String? ?? '',
      invoiceDate: DateTime.parse(json['invoiceDate'] as String),
      dueDate: json['dueDate'] == null
          ? null
          : DateTime.parse(json['dueDate'] as String),
      placeOfSupply: json['placeOfSupply'] as String? ?? '',
      reverseCharge: json['reverseCharge'] as String? ?? 'N',
      paymentTerms: json['paymentTerms'] as String? ?? '',
      items: (json['items'] as List<dynamic>?)
              ?.map((e) => InvoiceItem.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
      payments: (json['payments'] as List<dynamic>?)
              ?.map(
                  (e) => PaymentTransaction.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
      comments: json['comments'] as String? ?? '',
      bankName: json['bankName'] as String? ?? '',
      accountNo: json['accountNo'] as String? ?? '',
      ifscCode: json['ifscCode'] as String? ?? '',
      branch: json['branch'] as String? ?? '',
      deliveryAddress: json['deliveryAddress'] as String?,
    );

Map<String, dynamic> _$InvoiceToJson(_Invoice instance) => <String, dynamic>{
      'id': instance.id,
      'style': instance.style,
      'supplier': instance.supplier,
      'receiver': instance.receiver,
      'invoiceNo': instance.invoiceNo,
      'invoiceDate': instance.invoiceDate.toIso8601String(),
      'dueDate': instance.dueDate?.toIso8601String(),
      'placeOfSupply': instance.placeOfSupply,
      'reverseCharge': instance.reverseCharge,
      'paymentTerms': instance.paymentTerms,
      'items': instance.items,
      'payments': instance.payments,
      'comments': instance.comments,
      'bankName': instance.bankName,
      'accountNo': instance.accountNo,
      'ifscCode': instance.ifscCode,
      'branch': instance.branch,
      'deliveryAddress': instance.deliveryAddress,
    };

_Supplier _$SupplierFromJson(Map<String, dynamic> json) => _Supplier(
      name: json['name'] as String? ?? '',
      address: json['address'] as String? ?? '',
      gstin: json['gstin'] as String? ?? '',
      pan: json['pan'] as String? ?? '',
      email: json['email'] as String? ?? '',
      phone: json['phone'] as String? ?? '',
      state: json['state'] as String? ?? '',
    );

Map<String, dynamic> _$SupplierToJson(_Supplier instance) => <String, dynamic>{
      'name': instance.name,
      'address': instance.address,
      'gstin': instance.gstin,
      'pan': instance.pan,
      'email': instance.email,
      'phone': instance.phone,
      'state': instance.state,
    };

_Receiver _$ReceiverFromJson(Map<String, dynamic> json) => _Receiver(
      name: json['name'] as String? ?? '',
      address: json['address'] as String? ?? '',
      gstin: json['gstin'] as String? ?? '',
      pan: json['pan'] as String? ?? '',
      state: json['state'] as String? ?? '',
      stateCode: json['stateCode'] as String? ?? '',
    );

Map<String, dynamic> _$ReceiverToJson(_Receiver instance) => <String, dynamic>{
      'name': instance.name,
      'address': instance.address,
      'gstin': instance.gstin,
      'pan': instance.pan,
      'state': instance.state,
      'stateCode': instance.stateCode,
    };

_InvoiceItem _$InvoiceItemFromJson(Map<String, dynamic> json) => _InvoiceItem(
      id: json['id'] as String?,
      description: json['description'] as String? ?? '',
      sacCode: json['sacCode'] as String? ?? '',
      codeType: json['codeType'] as String? ?? 'SAC',
      year: json['year'] as String? ?? '',
      amount: (json['amount'] as num?)?.toDouble() ?? 0,
      discount: (json['discount'] as num?)?.toDouble() ?? 0,
      quantity: (json['quantity'] as num?)?.toDouble() ?? 1.0,
      unit: json['unit'] as String? ?? 'Nos',
      gstRate: (json['gstRate'] as num?)?.toDouble() ?? 18.0,
    );

Map<String, dynamic> _$InvoiceItemToJson(_InvoiceItem instance) =>
    <String, dynamic>{
      'id': instance.id,
      'description': instance.description,
      'sacCode': instance.sacCode,
      'codeType': instance.codeType,
      'year': instance.year,
      'amount': instance.amount,
      'discount': instance.discount,
      'quantity': instance.quantity,
      'unit': instance.unit,
      'gstRate': instance.gstRate,
    };
