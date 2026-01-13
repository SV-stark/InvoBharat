// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'invoice.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

Invoice _$InvoiceFromJson(Map<String, dynamic> json) {
  return _Invoice.fromJson(json);
}

/// @nodoc
mixin _$Invoice {
  String? get id => throw _privateConstructorUsedError;
  String get style => throw _privateConstructorUsedError;
  Supplier get supplier => throw _privateConstructorUsedError;
  Receiver get receiver => throw _privateConstructorUsedError;
  String get invoiceNo => throw _privateConstructorUsedError;
  DateTime get invoiceDate => throw _privateConstructorUsedError;
  DateTime? get dueDate => throw _privateConstructorUsedError;
  String get placeOfSupply => throw _privateConstructorUsedError;
  String get reverseCharge => throw _privateConstructorUsedError;
  String get paymentTerms => throw _privateConstructorUsedError;
  List<InvoiceItem> get items => throw _privateConstructorUsedError;
  List<PaymentTransaction> get payments => throw _privateConstructorUsedError;
  String get comments => throw _privateConstructorUsedError;
  String get bankName => throw _privateConstructorUsedError;
  String get accountNo => throw _privateConstructorUsedError;
  String get ifscCode => throw _privateConstructorUsedError;
  String get branch => throw _privateConstructorUsedError;
  String? get deliveryAddress => throw _privateConstructorUsedError;
  bool get isArchived => throw _privateConstructorUsedError; // Phase 4
  String get currency => throw _privateConstructorUsedError; // Phase 4
  double get discountAmount =>
      throw _privateConstructorUsedError; // NEW: Invoice level discount
  InvoiceType get type =>
      throw _privateConstructorUsedError; // NEW: Delivery Challan Support
// Credit/Debit Note Fields
  String? get originalInvoiceNumber => throw _privateConstructorUsedError;
  DateTime? get originalInvoiceDate => throw _privateConstructorUsedError;

  /// Serializes this Invoice to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of Invoice
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $InvoiceCopyWith<Invoice> get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $InvoiceCopyWith<$Res> {
  factory $InvoiceCopyWith(Invoice value, $Res Function(Invoice) then) =
      _$InvoiceCopyWithImpl<$Res, Invoice>;
  @useResult
  $Res call(
      {String? id,
      String style,
      Supplier supplier,
      Receiver receiver,
      String invoiceNo,
      DateTime invoiceDate,
      DateTime? dueDate,
      String placeOfSupply,
      String reverseCharge,
      String paymentTerms,
      List<InvoiceItem> items,
      List<PaymentTransaction> payments,
      String comments,
      String bankName,
      String accountNo,
      String ifscCode,
      String branch,
      String? deliveryAddress,
      bool isArchived,
      String currency,
      double discountAmount,
      InvoiceType type,
      String? originalInvoiceNumber,
      DateTime? originalInvoiceDate});

  $SupplierCopyWith<$Res> get supplier;
  $ReceiverCopyWith<$Res> get receiver;
}

/// @nodoc
class _$InvoiceCopyWithImpl<$Res, $Val extends Invoice>
    implements $InvoiceCopyWith<$Res> {
  _$InvoiceCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of Invoice
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = freezed,
    Object? style = null,
    Object? supplier = null,
    Object? receiver = null,
    Object? invoiceNo = null,
    Object? invoiceDate = null,
    Object? dueDate = freezed,
    Object? placeOfSupply = null,
    Object? reverseCharge = null,
    Object? paymentTerms = null,
    Object? items = null,
    Object? payments = null,
    Object? comments = null,
    Object? bankName = null,
    Object? accountNo = null,
    Object? ifscCode = null,
    Object? branch = null,
    Object? deliveryAddress = freezed,
    Object? isArchived = null,
    Object? currency = null,
    Object? discountAmount = null,
    Object? type = null,
    Object? originalInvoiceNumber = freezed,
    Object? originalInvoiceDate = freezed,
  }) {
    return _then(_value.copyWith(
      id: freezed == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String?,
      style: null == style
          ? _value.style
          : style // ignore: cast_nullable_to_non_nullable
              as String,
      supplier: null == supplier
          ? _value.supplier
          : supplier // ignore: cast_nullable_to_non_nullable
              as Supplier,
      receiver: null == receiver
          ? _value.receiver
          : receiver // ignore: cast_nullable_to_non_nullable
              as Receiver,
      invoiceNo: null == invoiceNo
          ? _value.invoiceNo
          : invoiceNo // ignore: cast_nullable_to_non_nullable
              as String,
      invoiceDate: null == invoiceDate
          ? _value.invoiceDate
          : invoiceDate // ignore: cast_nullable_to_non_nullable
              as DateTime,
      dueDate: freezed == dueDate
          ? _value.dueDate
          : dueDate // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      placeOfSupply: null == placeOfSupply
          ? _value.placeOfSupply
          : placeOfSupply // ignore: cast_nullable_to_non_nullable
              as String,
      reverseCharge: null == reverseCharge
          ? _value.reverseCharge
          : reverseCharge // ignore: cast_nullable_to_non_nullable
              as String,
      paymentTerms: null == paymentTerms
          ? _value.paymentTerms
          : paymentTerms // ignore: cast_nullable_to_non_nullable
              as String,
      items: null == items
          ? _value.items
          : items // ignore: cast_nullable_to_non_nullable
              as List<InvoiceItem>,
      payments: null == payments
          ? _value.payments
          : payments // ignore: cast_nullable_to_non_nullable
              as List<PaymentTransaction>,
      comments: null == comments
          ? _value.comments
          : comments // ignore: cast_nullable_to_non_nullable
              as String,
      bankName: null == bankName
          ? _value.bankName
          : bankName // ignore: cast_nullable_to_non_nullable
              as String,
      accountNo: null == accountNo
          ? _value.accountNo
          : accountNo // ignore: cast_nullable_to_non_nullable
              as String,
      ifscCode: null == ifscCode
          ? _value.ifscCode
          : ifscCode // ignore: cast_nullable_to_non_nullable
              as String,
      branch: null == branch
          ? _value.branch
          : branch // ignore: cast_nullable_to_non_nullable
              as String,
      deliveryAddress: freezed == deliveryAddress
          ? _value.deliveryAddress
          : deliveryAddress // ignore: cast_nullable_to_non_nullable
              as String?,
      isArchived: null == isArchived
          ? _value.isArchived
          : isArchived // ignore: cast_nullable_to_non_nullable
              as bool,
      currency: null == currency
          ? _value.currency
          : currency // ignore: cast_nullable_to_non_nullable
              as String,
      discountAmount: null == discountAmount
          ? _value.discountAmount
          : discountAmount // ignore: cast_nullable_to_non_nullable
              as double,
      type: null == type
          ? _value.type
          : type // ignore: cast_nullable_to_non_nullable
              as InvoiceType,
      originalInvoiceNumber: freezed == originalInvoiceNumber
          ? _value.originalInvoiceNumber
          : originalInvoiceNumber // ignore: cast_nullable_to_non_nullable
              as String?,
      originalInvoiceDate: freezed == originalInvoiceDate
          ? _value.originalInvoiceDate
          : originalInvoiceDate // ignore: cast_nullable_to_non_nullable
              as DateTime?,
    ) as $Val);
  }

  /// Create a copy of Invoice
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $SupplierCopyWith<$Res> get supplier {
    return $SupplierCopyWith<$Res>(_value.supplier, (value) {
      return _then(_value.copyWith(supplier: value) as $Val);
    });
  }

  /// Create a copy of Invoice
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $ReceiverCopyWith<$Res> get receiver {
    return $ReceiverCopyWith<$Res>(_value.receiver, (value) {
      return _then(_value.copyWith(receiver: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$InvoiceImplCopyWith<$Res> implements $InvoiceCopyWith<$Res> {
  factory _$$InvoiceImplCopyWith(
          _$InvoiceImpl value, $Res Function(_$InvoiceImpl) then) =
      __$$InvoiceImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String? id,
      String style,
      Supplier supplier,
      Receiver receiver,
      String invoiceNo,
      DateTime invoiceDate,
      DateTime? dueDate,
      String placeOfSupply,
      String reverseCharge,
      String paymentTerms,
      List<InvoiceItem> items,
      List<PaymentTransaction> payments,
      String comments,
      String bankName,
      String accountNo,
      String ifscCode,
      String branch,
      String? deliveryAddress,
      bool isArchived,
      String currency,
      double discountAmount,
      InvoiceType type,
      String? originalInvoiceNumber,
      DateTime? originalInvoiceDate});

  @override
  $SupplierCopyWith<$Res> get supplier;
  @override
  $ReceiverCopyWith<$Res> get receiver;
}

/// @nodoc
class __$$InvoiceImplCopyWithImpl<$Res>
    extends _$InvoiceCopyWithImpl<$Res, _$InvoiceImpl>
    implements _$$InvoiceImplCopyWith<$Res> {
  __$$InvoiceImplCopyWithImpl(
      _$InvoiceImpl _value, $Res Function(_$InvoiceImpl) _then)
      : super(_value, _then);

  /// Create a copy of Invoice
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = freezed,
    Object? style = null,
    Object? supplier = null,
    Object? receiver = null,
    Object? invoiceNo = null,
    Object? invoiceDate = null,
    Object? dueDate = freezed,
    Object? placeOfSupply = null,
    Object? reverseCharge = null,
    Object? paymentTerms = null,
    Object? items = null,
    Object? payments = null,
    Object? comments = null,
    Object? bankName = null,
    Object? accountNo = null,
    Object? ifscCode = null,
    Object? branch = null,
    Object? deliveryAddress = freezed,
    Object? isArchived = null,
    Object? currency = null,
    Object? discountAmount = null,
    Object? type = null,
    Object? originalInvoiceNumber = freezed,
    Object? originalInvoiceDate = freezed,
  }) {
    return _then(_$InvoiceImpl(
      id: freezed == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String?,
      style: null == style
          ? _value.style
          : style // ignore: cast_nullable_to_non_nullable
              as String,
      supplier: null == supplier
          ? _value.supplier
          : supplier // ignore: cast_nullable_to_non_nullable
              as Supplier,
      receiver: null == receiver
          ? _value.receiver
          : receiver // ignore: cast_nullable_to_non_nullable
              as Receiver,
      invoiceNo: null == invoiceNo
          ? _value.invoiceNo
          : invoiceNo // ignore: cast_nullable_to_non_nullable
              as String,
      invoiceDate: null == invoiceDate
          ? _value.invoiceDate
          : invoiceDate // ignore: cast_nullable_to_non_nullable
              as DateTime,
      dueDate: freezed == dueDate
          ? _value.dueDate
          : dueDate // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      placeOfSupply: null == placeOfSupply
          ? _value.placeOfSupply
          : placeOfSupply // ignore: cast_nullable_to_non_nullable
              as String,
      reverseCharge: null == reverseCharge
          ? _value.reverseCharge
          : reverseCharge // ignore: cast_nullable_to_non_nullable
              as String,
      paymentTerms: null == paymentTerms
          ? _value.paymentTerms
          : paymentTerms // ignore: cast_nullable_to_non_nullable
              as String,
      items: null == items
          ? _value._items
          : items // ignore: cast_nullable_to_non_nullable
              as List<InvoiceItem>,
      payments: null == payments
          ? _value._payments
          : payments // ignore: cast_nullable_to_non_nullable
              as List<PaymentTransaction>,
      comments: null == comments
          ? _value.comments
          : comments // ignore: cast_nullable_to_non_nullable
              as String,
      bankName: null == bankName
          ? _value.bankName
          : bankName // ignore: cast_nullable_to_non_nullable
              as String,
      accountNo: null == accountNo
          ? _value.accountNo
          : accountNo // ignore: cast_nullable_to_non_nullable
              as String,
      ifscCode: null == ifscCode
          ? _value.ifscCode
          : ifscCode // ignore: cast_nullable_to_non_nullable
              as String,
      branch: null == branch
          ? _value.branch
          : branch // ignore: cast_nullable_to_non_nullable
              as String,
      deliveryAddress: freezed == deliveryAddress
          ? _value.deliveryAddress
          : deliveryAddress // ignore: cast_nullable_to_non_nullable
              as String?,
      isArchived: null == isArchived
          ? _value.isArchived
          : isArchived // ignore: cast_nullable_to_non_nullable
              as bool,
      currency: null == currency
          ? _value.currency
          : currency // ignore: cast_nullable_to_non_nullable
              as String,
      discountAmount: null == discountAmount
          ? _value.discountAmount
          : discountAmount // ignore: cast_nullable_to_non_nullable
              as double,
      type: null == type
          ? _value.type
          : type // ignore: cast_nullable_to_non_nullable
              as InvoiceType,
      originalInvoiceNumber: freezed == originalInvoiceNumber
          ? _value.originalInvoiceNumber
          : originalInvoiceNumber // ignore: cast_nullable_to_non_nullable
              as String?,
      originalInvoiceDate: freezed == originalInvoiceDate
          ? _value.originalInvoiceDate
          : originalInvoiceDate // ignore: cast_nullable_to_non_nullable
              as DateTime?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$InvoiceImpl extends _Invoice {
  const _$InvoiceImpl(
      {this.id,
      this.style = 'Modern',
      required this.supplier,
      required this.receiver,
      this.invoiceNo = '',
      required this.invoiceDate,
      this.dueDate,
      this.placeOfSupply = '',
      this.reverseCharge = 'N',
      this.paymentTerms = '',
      final List<InvoiceItem> items = const [],
      final List<PaymentTransaction> payments = const [],
      this.comments = '',
      this.bankName = '',
      this.accountNo = '',
      this.ifscCode = '',
      this.branch = '',
      this.deliveryAddress,
      this.isArchived = false,
      this.currency = 'INR',
      this.discountAmount = 0.0,
      this.type = InvoiceType.invoice,
      this.originalInvoiceNumber,
      this.originalInvoiceDate})
      : _items = items,
        _payments = payments,
        super._();

  factory _$InvoiceImpl.fromJson(Map<String, dynamic> json) =>
      _$$InvoiceImplFromJson(json);

  @override
  final String? id;
  @override
  @JsonKey()
  final String style;
  @override
  final Supplier supplier;
  @override
  final Receiver receiver;
  @override
  @JsonKey()
  final String invoiceNo;
  @override
  final DateTime invoiceDate;
  @override
  final DateTime? dueDate;
  @override
  @JsonKey()
  final String placeOfSupply;
  @override
  @JsonKey()
  final String reverseCharge;
  @override
  @JsonKey()
  final String paymentTerms;
  final List<InvoiceItem> _items;
  @override
  @JsonKey()
  List<InvoiceItem> get items {
    if (_items is EqualUnmodifiableListView) return _items;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_items);
  }

  final List<PaymentTransaction> _payments;
  @override
  @JsonKey()
  List<PaymentTransaction> get payments {
    if (_payments is EqualUnmodifiableListView) return _payments;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_payments);
  }

  @override
  @JsonKey()
  final String comments;
  @override
  @JsonKey()
  final String bankName;
  @override
  @JsonKey()
  final String accountNo;
  @override
  @JsonKey()
  final String ifscCode;
  @override
  @JsonKey()
  final String branch;
  @override
  final String? deliveryAddress;
  @override
  @JsonKey()
  final bool isArchived;
// Phase 4
  @override
  @JsonKey()
  final String currency;
// Phase 4
  @override
  @JsonKey()
  final double discountAmount;
// NEW: Invoice level discount
  @override
  @JsonKey()
  final InvoiceType type;
// NEW: Delivery Challan Support
// Credit/Debit Note Fields
  @override
  final String? originalInvoiceNumber;
  @override
  final DateTime? originalInvoiceDate;

  @override
  String toString() {
    return 'Invoice(id: $id, style: $style, supplier: $supplier, receiver: $receiver, invoiceNo: $invoiceNo, invoiceDate: $invoiceDate, dueDate: $dueDate, placeOfSupply: $placeOfSupply, reverseCharge: $reverseCharge, paymentTerms: $paymentTerms, items: $items, payments: $payments, comments: $comments, bankName: $bankName, accountNo: $accountNo, ifscCode: $ifscCode, branch: $branch, deliveryAddress: $deliveryAddress, isArchived: $isArchived, currency: $currency, discountAmount: $discountAmount, type: $type, originalInvoiceNumber: $originalInvoiceNumber, originalInvoiceDate: $originalInvoiceDate)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$InvoiceImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.style, style) || other.style == style) &&
            (identical(other.supplier, supplier) ||
                other.supplier == supplier) &&
            (identical(other.receiver, receiver) ||
                other.receiver == receiver) &&
            (identical(other.invoiceNo, invoiceNo) ||
                other.invoiceNo == invoiceNo) &&
            (identical(other.invoiceDate, invoiceDate) ||
                other.invoiceDate == invoiceDate) &&
            (identical(other.dueDate, dueDate) || other.dueDate == dueDate) &&
            (identical(other.placeOfSupply, placeOfSupply) ||
                other.placeOfSupply == placeOfSupply) &&
            (identical(other.reverseCharge, reverseCharge) ||
                other.reverseCharge == reverseCharge) &&
            (identical(other.paymentTerms, paymentTerms) ||
                other.paymentTerms == paymentTerms) &&
            const DeepCollectionEquality().equals(other._items, _items) &&
            const DeepCollectionEquality().equals(other._payments, _payments) &&
            (identical(other.comments, comments) ||
                other.comments == comments) &&
            (identical(other.bankName, bankName) ||
                other.bankName == bankName) &&
            (identical(other.accountNo, accountNo) ||
                other.accountNo == accountNo) &&
            (identical(other.ifscCode, ifscCode) ||
                other.ifscCode == ifscCode) &&
            (identical(other.branch, branch) || other.branch == branch) &&
            (identical(other.deliveryAddress, deliveryAddress) ||
                other.deliveryAddress == deliveryAddress) &&
            (identical(other.isArchived, isArchived) ||
                other.isArchived == isArchived) &&
            (identical(other.currency, currency) ||
                other.currency == currency) &&
            (identical(other.discountAmount, discountAmount) ||
                other.discountAmount == discountAmount) &&
            (identical(other.type, type) || other.type == type) &&
            (identical(other.originalInvoiceNumber, originalInvoiceNumber) ||
                other.originalInvoiceNumber == originalInvoiceNumber) &&
            (identical(other.originalInvoiceDate, originalInvoiceDate) ||
                other.originalInvoiceDate == originalInvoiceDate));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hashAll([
        runtimeType,
        id,
        style,
        supplier,
        receiver,
        invoiceNo,
        invoiceDate,
        dueDate,
        placeOfSupply,
        reverseCharge,
        paymentTerms,
        const DeepCollectionEquality().hash(_items),
        const DeepCollectionEquality().hash(_payments),
        comments,
        bankName,
        accountNo,
        ifscCode,
        branch,
        deliveryAddress,
        isArchived,
        currency,
        discountAmount,
        type,
        originalInvoiceNumber,
        originalInvoiceDate
      ]);

  /// Create a copy of Invoice
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$InvoiceImplCopyWith<_$InvoiceImpl> get copyWith =>
      __$$InvoiceImplCopyWithImpl<_$InvoiceImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$InvoiceImplToJson(
      this,
    );
  }
}

abstract class _Invoice extends Invoice {
  const factory _Invoice(
      {final String? id,
      final String style,
      required final Supplier supplier,
      required final Receiver receiver,
      final String invoiceNo,
      required final DateTime invoiceDate,
      final DateTime? dueDate,
      final String placeOfSupply,
      final String reverseCharge,
      final String paymentTerms,
      final List<InvoiceItem> items,
      final List<PaymentTransaction> payments,
      final String comments,
      final String bankName,
      final String accountNo,
      final String ifscCode,
      final String branch,
      final String? deliveryAddress,
      final bool isArchived,
      final String currency,
      final double discountAmount,
      final InvoiceType type,
      final String? originalInvoiceNumber,
      final DateTime? originalInvoiceDate}) = _$InvoiceImpl;
  const _Invoice._() : super._();

  factory _Invoice.fromJson(Map<String, dynamic> json) = _$InvoiceImpl.fromJson;

  @override
  String? get id;
  @override
  String get style;
  @override
  Supplier get supplier;
  @override
  Receiver get receiver;
  @override
  String get invoiceNo;
  @override
  DateTime get invoiceDate;
  @override
  DateTime? get dueDate;
  @override
  String get placeOfSupply;
  @override
  String get reverseCharge;
  @override
  String get paymentTerms;
  @override
  List<InvoiceItem> get items;
  @override
  List<PaymentTransaction> get payments;
  @override
  String get comments;
  @override
  String get bankName;
  @override
  String get accountNo;
  @override
  String get ifscCode;
  @override
  String get branch;
  @override
  String? get deliveryAddress;
  @override
  bool get isArchived; // Phase 4
  @override
  String get currency; // Phase 4
  @override
  double get discountAmount; // NEW: Invoice level discount
  @override
  InvoiceType get type; // NEW: Delivery Challan Support
// Credit/Debit Note Fields
  @override
  String? get originalInvoiceNumber;
  @override
  DateTime? get originalInvoiceDate;

  /// Create a copy of Invoice
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$InvoiceImplCopyWith<_$InvoiceImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

Supplier _$SupplierFromJson(Map<String, dynamic> json) {
  return _Supplier.fromJson(json);
}

/// @nodoc
mixin _$Supplier {
  String get name => throw _privateConstructorUsedError;
  String get address => throw _privateConstructorUsedError;
  String get gstin => throw _privateConstructorUsedError;
  String get pan => throw _privateConstructorUsedError;
  String get email => throw _privateConstructorUsedError;
  String get phone => throw _privateConstructorUsedError;
  String get state => throw _privateConstructorUsedError;

  /// Serializes this Supplier to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of Supplier
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $SupplierCopyWith<Supplier> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $SupplierCopyWith<$Res> {
  factory $SupplierCopyWith(Supplier value, $Res Function(Supplier) then) =
      _$SupplierCopyWithImpl<$Res, Supplier>;
  @useResult
  $Res call(
      {String name,
      String address,
      String gstin,
      String pan,
      String email,
      String phone,
      String state});
}

/// @nodoc
class _$SupplierCopyWithImpl<$Res, $Val extends Supplier>
    implements $SupplierCopyWith<$Res> {
  _$SupplierCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of Supplier
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? name = null,
    Object? address = null,
    Object? gstin = null,
    Object? pan = null,
    Object? email = null,
    Object? phone = null,
    Object? state = null,
  }) {
    return _then(_value.copyWith(
      name: null == name
          ? _value.name
          : name // ignore: cast_nullable_to_non_nullable
              as String,
      address: null == address
          ? _value.address
          : address // ignore: cast_nullable_to_non_nullable
              as String,
      gstin: null == gstin
          ? _value.gstin
          : gstin // ignore: cast_nullable_to_non_nullable
              as String,
      pan: null == pan
          ? _value.pan
          : pan // ignore: cast_nullable_to_non_nullable
              as String,
      email: null == email
          ? _value.email
          : email // ignore: cast_nullable_to_non_nullable
              as String,
      phone: null == phone
          ? _value.phone
          : phone // ignore: cast_nullable_to_non_nullable
              as String,
      state: null == state
          ? _value.state
          : state // ignore: cast_nullable_to_non_nullable
              as String,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$SupplierImplCopyWith<$Res>
    implements $SupplierCopyWith<$Res> {
  factory _$$SupplierImplCopyWith(
          _$SupplierImpl value, $Res Function(_$SupplierImpl) then) =
      __$$SupplierImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String name,
      String address,
      String gstin,
      String pan,
      String email,
      String phone,
      String state});
}

/// @nodoc
class __$$SupplierImplCopyWithImpl<$Res>
    extends _$SupplierCopyWithImpl<$Res, _$SupplierImpl>
    implements _$$SupplierImplCopyWith<$Res> {
  __$$SupplierImplCopyWithImpl(
      _$SupplierImpl _value, $Res Function(_$SupplierImpl) _then)
      : super(_value, _then);

  /// Create a copy of Supplier
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? name = null,
    Object? address = null,
    Object? gstin = null,
    Object? pan = null,
    Object? email = null,
    Object? phone = null,
    Object? state = null,
  }) {
    return _then(_$SupplierImpl(
      name: null == name
          ? _value.name
          : name // ignore: cast_nullable_to_non_nullable
              as String,
      address: null == address
          ? _value.address
          : address // ignore: cast_nullable_to_non_nullable
              as String,
      gstin: null == gstin
          ? _value.gstin
          : gstin // ignore: cast_nullable_to_non_nullable
              as String,
      pan: null == pan
          ? _value.pan
          : pan // ignore: cast_nullable_to_non_nullable
              as String,
      email: null == email
          ? _value.email
          : email // ignore: cast_nullable_to_non_nullable
              as String,
      phone: null == phone
          ? _value.phone
          : phone // ignore: cast_nullable_to_non_nullable
              as String,
      state: null == state
          ? _value.state
          : state // ignore: cast_nullable_to_non_nullable
              as String,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$SupplierImpl implements _Supplier {
  const _$SupplierImpl(
      {this.name = '',
      this.address = '',
      this.gstin = '',
      this.pan = '',
      this.email = '',
      this.phone = '',
      this.state = ''});

  factory _$SupplierImpl.fromJson(Map<String, dynamic> json) =>
      _$$SupplierImplFromJson(json);

  @override
  @JsonKey()
  final String name;
  @override
  @JsonKey()
  final String address;
  @override
  @JsonKey()
  final String gstin;
  @override
  @JsonKey()
  final String pan;
  @override
  @JsonKey()
  final String email;
  @override
  @JsonKey()
  final String phone;
  @override
  @JsonKey()
  final String state;

  @override
  String toString() {
    return 'Supplier(name: $name, address: $address, gstin: $gstin, pan: $pan, email: $email, phone: $phone, state: $state)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$SupplierImpl &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.address, address) || other.address == address) &&
            (identical(other.gstin, gstin) || other.gstin == gstin) &&
            (identical(other.pan, pan) || other.pan == pan) &&
            (identical(other.email, email) || other.email == email) &&
            (identical(other.phone, phone) || other.phone == phone) &&
            (identical(other.state, state) || other.state == state));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode =>
      Object.hash(runtimeType, name, address, gstin, pan, email, phone, state);

  /// Create a copy of Supplier
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$SupplierImplCopyWith<_$SupplierImpl> get copyWith =>
      __$$SupplierImplCopyWithImpl<_$SupplierImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$SupplierImplToJson(
      this,
    );
  }
}

abstract class _Supplier implements Supplier {
  const factory _Supplier(
      {final String name,
      final String address,
      final String gstin,
      final String pan,
      final String email,
      final String phone,
      final String state}) = _$SupplierImpl;

  factory _Supplier.fromJson(Map<String, dynamic> json) =
      _$SupplierImpl.fromJson;

  @override
  String get name;
  @override
  String get address;
  @override
  String get gstin;
  @override
  String get pan;
  @override
  String get email;
  @override
  String get phone;
  @override
  String get state;

  /// Create a copy of Supplier
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$SupplierImplCopyWith<_$SupplierImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

Receiver _$ReceiverFromJson(Map<String, dynamic> json) {
  return _Receiver.fromJson(json);
}

/// @nodoc
mixin _$Receiver {
  String get name => throw _privateConstructorUsedError;
  String get address => throw _privateConstructorUsedError;
  String get gstin => throw _privateConstructorUsedError;
  String get pan => throw _privateConstructorUsedError;
  String get state => throw _privateConstructorUsedError;
  String get stateCode => throw _privateConstructorUsedError;
  String get email => throw _privateConstructorUsedError;

  /// Serializes this Receiver to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of Receiver
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $ReceiverCopyWith<Receiver> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ReceiverCopyWith<$Res> {
  factory $ReceiverCopyWith(Receiver value, $Res Function(Receiver) then) =
      _$ReceiverCopyWithImpl<$Res, Receiver>;
  @useResult
  $Res call(
      {String name,
      String address,
      String gstin,
      String pan,
      String state,
      String stateCode,
      String email});
}

/// @nodoc
class _$ReceiverCopyWithImpl<$Res, $Val extends Receiver>
    implements $ReceiverCopyWith<$Res> {
  _$ReceiverCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of Receiver
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? name = null,
    Object? address = null,
    Object? gstin = null,
    Object? pan = null,
    Object? state = null,
    Object? stateCode = null,
    Object? email = null,
  }) {
    return _then(_value.copyWith(
      name: null == name
          ? _value.name
          : name // ignore: cast_nullable_to_non_nullable
              as String,
      address: null == address
          ? _value.address
          : address // ignore: cast_nullable_to_non_nullable
              as String,
      gstin: null == gstin
          ? _value.gstin
          : gstin // ignore: cast_nullable_to_non_nullable
              as String,
      pan: null == pan
          ? _value.pan
          : pan // ignore: cast_nullable_to_non_nullable
              as String,
      state: null == state
          ? _value.state
          : state // ignore: cast_nullable_to_non_nullable
              as String,
      stateCode: null == stateCode
          ? _value.stateCode
          : stateCode // ignore: cast_nullable_to_non_nullable
              as String,
      email: null == email
          ? _value.email
          : email // ignore: cast_nullable_to_non_nullable
              as String,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$ReceiverImplCopyWith<$Res>
    implements $ReceiverCopyWith<$Res> {
  factory _$$ReceiverImplCopyWith(
          _$ReceiverImpl value, $Res Function(_$ReceiverImpl) then) =
      __$$ReceiverImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String name,
      String address,
      String gstin,
      String pan,
      String state,
      String stateCode,
      String email});
}

/// @nodoc
class __$$ReceiverImplCopyWithImpl<$Res>
    extends _$ReceiverCopyWithImpl<$Res, _$ReceiverImpl>
    implements _$$ReceiverImplCopyWith<$Res> {
  __$$ReceiverImplCopyWithImpl(
      _$ReceiverImpl _value, $Res Function(_$ReceiverImpl) _then)
      : super(_value, _then);

  /// Create a copy of Receiver
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? name = null,
    Object? address = null,
    Object? gstin = null,
    Object? pan = null,
    Object? state = null,
    Object? stateCode = null,
    Object? email = null,
  }) {
    return _then(_$ReceiverImpl(
      name: null == name
          ? _value.name
          : name // ignore: cast_nullable_to_non_nullable
              as String,
      address: null == address
          ? _value.address
          : address // ignore: cast_nullable_to_non_nullable
              as String,
      gstin: null == gstin
          ? _value.gstin
          : gstin // ignore: cast_nullable_to_non_nullable
              as String,
      pan: null == pan
          ? _value.pan
          : pan // ignore: cast_nullable_to_non_nullable
              as String,
      state: null == state
          ? _value.state
          : state // ignore: cast_nullable_to_non_nullable
              as String,
      stateCode: null == stateCode
          ? _value.stateCode
          : stateCode // ignore: cast_nullable_to_non_nullable
              as String,
      email: null == email
          ? _value.email
          : email // ignore: cast_nullable_to_non_nullable
              as String,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$ReceiverImpl implements _Receiver {
  const _$ReceiverImpl(
      {this.name = '',
      this.address = '',
      this.gstin = '',
      this.pan = '',
      this.state = '',
      this.stateCode = '',
      this.email = ''});

  factory _$ReceiverImpl.fromJson(Map<String, dynamic> json) =>
      _$$ReceiverImplFromJson(json);

  @override
  @JsonKey()
  final String name;
  @override
  @JsonKey()
  final String address;
  @override
  @JsonKey()
  final String gstin;
  @override
  @JsonKey()
  final String pan;
  @override
  @JsonKey()
  final String state;
  @override
  @JsonKey()
  final String stateCode;
  @override
  @JsonKey()
  final String email;

  @override
  String toString() {
    return 'Receiver(name: $name, address: $address, gstin: $gstin, pan: $pan, state: $state, stateCode: $stateCode, email: $email)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ReceiverImpl &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.address, address) || other.address == address) &&
            (identical(other.gstin, gstin) || other.gstin == gstin) &&
            (identical(other.pan, pan) || other.pan == pan) &&
            (identical(other.state, state) || other.state == state) &&
            (identical(other.stateCode, stateCode) ||
                other.stateCode == stateCode) &&
            (identical(other.email, email) || other.email == email));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType, name, address, gstin, pan, state, stateCode, email);

  /// Create a copy of Receiver
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$ReceiverImplCopyWith<_$ReceiverImpl> get copyWith =>
      __$$ReceiverImplCopyWithImpl<_$ReceiverImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$ReceiverImplToJson(
      this,
    );
  }
}

abstract class _Receiver implements Receiver {
  const factory _Receiver(
      {final String name,
      final String address,
      final String gstin,
      final String pan,
      final String state,
      final String stateCode,
      final String email}) = _$ReceiverImpl;

  factory _Receiver.fromJson(Map<String, dynamic> json) =
      _$ReceiverImpl.fromJson;

  @override
  String get name;
  @override
  String get address;
  @override
  String get gstin;
  @override
  String get pan;
  @override
  String get state;
  @override
  String get stateCode;
  @override
  String get email;

  /// Create a copy of Receiver
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$ReceiverImplCopyWith<_$ReceiverImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

InvoiceItem _$InvoiceItemFromJson(Map<String, dynamic> json) {
  return _InvoiceItem.fromJson(json);
}

/// @nodoc
mixin _$InvoiceItem {
  String? get id =>
      throw _privateConstructorUsedError; // Will be generated in factory constructor if null? No, freezed doesn't support logic in constructor easily.
// We'll handle ID generation in the code that creates the item, or use @Default(Uuid().v4())?
// Default values must be const. Uuid().v4() is not const.
// We'll make it nullable and handle it.
// OR we'll use a custom factory?
// Let's make it nullable here, but commonly generated.
// In original code: id = id ?? const Uuid().v4();
// In freezed, if we pass null, it stays null.
// We can't have logic.
// Best Practice: Accept null in constructor, but ensure it's set before saving?
// Or better: Let's assume it's optional string. If null, we treat as new.
  String get description => throw _privateConstructorUsedError;
  String get sacCode => throw _privateConstructorUsedError;
  String get codeType => throw _privateConstructorUsedError;
  String get year => throw _privateConstructorUsedError; // e.g. "F.Y. 2025-26"
  double get amount => throw _privateConstructorUsedError;
  double get discount => throw _privateConstructorUsedError;
  double get quantity => throw _privateConstructorUsedError;
  String get unit => throw _privateConstructorUsedError;
  double get gstRate => throw _privateConstructorUsedError;

  /// Serializes this InvoiceItem to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of InvoiceItem
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $InvoiceItemCopyWith<InvoiceItem> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $InvoiceItemCopyWith<$Res> {
  factory $InvoiceItemCopyWith(
          InvoiceItem value, $Res Function(InvoiceItem) then) =
      _$InvoiceItemCopyWithImpl<$Res, InvoiceItem>;
  @useResult
  $Res call(
      {String? id,
      String description,
      String sacCode,
      String codeType,
      String year,
      double amount,
      double discount,
      double quantity,
      String unit,
      double gstRate});
}

/// @nodoc
class _$InvoiceItemCopyWithImpl<$Res, $Val extends InvoiceItem>
    implements $InvoiceItemCopyWith<$Res> {
  _$InvoiceItemCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of InvoiceItem
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = freezed,
    Object? description = null,
    Object? sacCode = null,
    Object? codeType = null,
    Object? year = null,
    Object? amount = null,
    Object? discount = null,
    Object? quantity = null,
    Object? unit = null,
    Object? gstRate = null,
  }) {
    return _then(_value.copyWith(
      id: freezed == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String?,
      description: null == description
          ? _value.description
          : description // ignore: cast_nullable_to_non_nullable
              as String,
      sacCode: null == sacCode
          ? _value.sacCode
          : sacCode // ignore: cast_nullable_to_non_nullable
              as String,
      codeType: null == codeType
          ? _value.codeType
          : codeType // ignore: cast_nullable_to_non_nullable
              as String,
      year: null == year
          ? _value.year
          : year // ignore: cast_nullable_to_non_nullable
              as String,
      amount: null == amount
          ? _value.amount
          : amount // ignore: cast_nullable_to_non_nullable
              as double,
      discount: null == discount
          ? _value.discount
          : discount // ignore: cast_nullable_to_non_nullable
              as double,
      quantity: null == quantity
          ? _value.quantity
          : quantity // ignore: cast_nullable_to_non_nullable
              as double,
      unit: null == unit
          ? _value.unit
          : unit // ignore: cast_nullable_to_non_nullable
              as String,
      gstRate: null == gstRate
          ? _value.gstRate
          : gstRate // ignore: cast_nullable_to_non_nullable
              as double,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$InvoiceItemImplCopyWith<$Res>
    implements $InvoiceItemCopyWith<$Res> {
  factory _$$InvoiceItemImplCopyWith(
          _$InvoiceItemImpl value, $Res Function(_$InvoiceItemImpl) then) =
      __$$InvoiceItemImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String? id,
      String description,
      String sacCode,
      String codeType,
      String year,
      double amount,
      double discount,
      double quantity,
      String unit,
      double gstRate});
}

/// @nodoc
class __$$InvoiceItemImplCopyWithImpl<$Res>
    extends _$InvoiceItemCopyWithImpl<$Res, _$InvoiceItemImpl>
    implements _$$InvoiceItemImplCopyWith<$Res> {
  __$$InvoiceItemImplCopyWithImpl(
      _$InvoiceItemImpl _value, $Res Function(_$InvoiceItemImpl) _then)
      : super(_value, _then);

  /// Create a copy of InvoiceItem
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = freezed,
    Object? description = null,
    Object? sacCode = null,
    Object? codeType = null,
    Object? year = null,
    Object? amount = null,
    Object? discount = null,
    Object? quantity = null,
    Object? unit = null,
    Object? gstRate = null,
  }) {
    return _then(_$InvoiceItemImpl(
      id: freezed == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String?,
      description: null == description
          ? _value.description
          : description // ignore: cast_nullable_to_non_nullable
              as String,
      sacCode: null == sacCode
          ? _value.sacCode
          : sacCode // ignore: cast_nullable_to_non_nullable
              as String,
      codeType: null == codeType
          ? _value.codeType
          : codeType // ignore: cast_nullable_to_non_nullable
              as String,
      year: null == year
          ? _value.year
          : year // ignore: cast_nullable_to_non_nullable
              as String,
      amount: null == amount
          ? _value.amount
          : amount // ignore: cast_nullable_to_non_nullable
              as double,
      discount: null == discount
          ? _value.discount
          : discount // ignore: cast_nullable_to_non_nullable
              as double,
      quantity: null == quantity
          ? _value.quantity
          : quantity // ignore: cast_nullable_to_non_nullable
              as double,
      unit: null == unit
          ? _value.unit
          : unit // ignore: cast_nullable_to_non_nullable
              as String,
      gstRate: null == gstRate
          ? _value.gstRate
          : gstRate // ignore: cast_nullable_to_non_nullable
              as double,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$InvoiceItemImpl extends _InvoiceItem {
  const _$InvoiceItemImpl(
      {this.id,
      this.description = '',
      this.sacCode = '',
      this.codeType = 'SAC',
      this.year = '',
      this.amount = 0,
      this.discount = 0,
      this.quantity = 1.0,
      this.unit = 'Nos',
      this.gstRate = 18.0})
      : super._();

  factory _$InvoiceItemImpl.fromJson(Map<String, dynamic> json) =>
      _$$InvoiceItemImplFromJson(json);

  @override
  final String? id;
// Will be generated in factory constructor if null? No, freezed doesn't support logic in constructor easily.
// We'll handle ID generation in the code that creates the item, or use @Default(Uuid().v4())?
// Default values must be const. Uuid().v4() is not const.
// We'll make it nullable and handle it.
// OR we'll use a custom factory?
// Let's make it nullable here, but commonly generated.
// In original code: id = id ?? const Uuid().v4();
// In freezed, if we pass null, it stays null.
// We can't have logic.
// Best Practice: Accept null in constructor, but ensure it's set before saving?
// Or better: Let's assume it's optional string. If null, we treat as new.
  @override
  @JsonKey()
  final String description;
  @override
  @JsonKey()
  final String sacCode;
  @override
  @JsonKey()
  final String codeType;
  @override
  @JsonKey()
  final String year;
// e.g. "F.Y. 2025-26"
  @override
  @JsonKey()
  final double amount;
  @override
  @JsonKey()
  final double discount;
  @override
  @JsonKey()
  final double quantity;
  @override
  @JsonKey()
  final String unit;
  @override
  @JsonKey()
  final double gstRate;

  @override
  String toString() {
    return 'InvoiceItem(id: $id, description: $description, sacCode: $sacCode, codeType: $codeType, year: $year, amount: $amount, discount: $discount, quantity: $quantity, unit: $unit, gstRate: $gstRate)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$InvoiceItemImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.description, description) ||
                other.description == description) &&
            (identical(other.sacCode, sacCode) || other.sacCode == sacCode) &&
            (identical(other.codeType, codeType) ||
                other.codeType == codeType) &&
            (identical(other.year, year) || other.year == year) &&
            (identical(other.amount, amount) || other.amount == amount) &&
            (identical(other.discount, discount) ||
                other.discount == discount) &&
            (identical(other.quantity, quantity) ||
                other.quantity == quantity) &&
            (identical(other.unit, unit) || other.unit == unit) &&
            (identical(other.gstRate, gstRate) || other.gstRate == gstRate));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, id, description, sacCode,
      codeType, year, amount, discount, quantity, unit, gstRate);

  /// Create a copy of InvoiceItem
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$InvoiceItemImplCopyWith<_$InvoiceItemImpl> get copyWith =>
      __$$InvoiceItemImplCopyWithImpl<_$InvoiceItemImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$InvoiceItemImplToJson(
      this,
    );
  }
}

abstract class _InvoiceItem extends InvoiceItem {
  const factory _InvoiceItem(
      {final String? id,
      final String description,
      final String sacCode,
      final String codeType,
      final String year,
      final double amount,
      final double discount,
      final double quantity,
      final String unit,
      final double gstRate}) = _$InvoiceItemImpl;
  const _InvoiceItem._() : super._();

  factory _InvoiceItem.fromJson(Map<String, dynamic> json) =
      _$InvoiceItemImpl.fromJson;

  @override
  String?
      get id; // Will be generated in factory constructor if null? No, freezed doesn't support logic in constructor easily.
// We'll handle ID generation in the code that creates the item, or use @Default(Uuid().v4())?
// Default values must be const. Uuid().v4() is not const.
// We'll make it nullable and handle it.
// OR we'll use a custom factory?
// Let's make it nullable here, but commonly generated.
// In original code: id = id ?? const Uuid().v4();
// In freezed, if we pass null, it stays null.
// We can't have logic.
// Best Practice: Accept null in constructor, but ensure it's set before saving?
// Or better: Let's assume it's optional string. If null, we treat as new.
  @override
  String get description;
  @override
  String get sacCode;
  @override
  String get codeType;
  @override
  String get year; // e.g. "F.Y. 2025-26"
  @override
  double get amount;
  @override
  double get discount;
  @override
  double get quantity;
  @override
  String get unit;
  @override
  double get gstRate;

  /// Create a copy of InvoiceItem
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$InvoiceItemImplCopyWith<_$InvoiceItemImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
