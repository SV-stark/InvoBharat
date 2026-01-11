// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'invoice.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$Invoice {
  String? get id;
  String get style;
  Supplier get supplier;
  Receiver get receiver;
  String get invoiceNo;
  DateTime get invoiceDate;
  DateTime? get dueDate;
  String get placeOfSupply;
  String get reverseCharge;
  String get paymentTerms;
  List<InvoiceItem> get items;
  List<PaymentTransaction> get payments;
  String get comments;
  String get bankName;
  String get accountNo;
  String get ifscCode;
  String get branch;
  String? get deliveryAddress;
  bool get isArchived; // Phase 4
  String get currency;

  /// Create a copy of Invoice
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $InvoiceCopyWith<Invoice> get copyWith =>
      _$InvoiceCopyWithImpl<Invoice>(this as Invoice, _$identity);

  /// Serializes this Invoice to a JSON map.
  Map<String, dynamic> toJson();

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is Invoice &&
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
            const DeepCollectionEquality().equals(other.items, items) &&
            const DeepCollectionEquality().equals(other.payments, payments) &&
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
                other.currency == currency));
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
        const DeepCollectionEquality().hash(items),
        const DeepCollectionEquality().hash(payments),
        comments,
        bankName,
        accountNo,
        ifscCode,
        branch,
        deliveryAddress,
        isArchived,
        currency
      ]);

  @override
  String toString() {
    return 'Invoice(id: $id, style: $style, supplier: $supplier, receiver: $receiver, invoiceNo: $invoiceNo, invoiceDate: $invoiceDate, dueDate: $dueDate, placeOfSupply: $placeOfSupply, reverseCharge: $reverseCharge, paymentTerms: $paymentTerms, items: $items, payments: $payments, comments: $comments, bankName: $bankName, accountNo: $accountNo, ifscCode: $ifscCode, branch: $branch, deliveryAddress: $deliveryAddress, isArchived: $isArchived, currency: $currency)';
  }
}

/// @nodoc
abstract mixin class $InvoiceCopyWith<$Res> {
  factory $InvoiceCopyWith(Invoice value, $Res Function(Invoice) _then) =
      _$InvoiceCopyWithImpl;
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
      String currency});

  $SupplierCopyWith<$Res> get supplier;
  $ReceiverCopyWith<$Res> get receiver;
}

/// @nodoc
class _$InvoiceCopyWithImpl<$Res> implements $InvoiceCopyWith<$Res> {
  _$InvoiceCopyWithImpl(this._self, this._then);

  final Invoice _self;
  final $Res Function(Invoice) _then;

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
  }) {
    return _then(_self.copyWith(
      id: freezed == id
          ? _self.id
          : id // ignore: cast_nullable_to_non_nullable
              as String?,
      style: null == style
          ? _self.style
          : style // ignore: cast_nullable_to_non_nullable
              as String,
      supplier: null == supplier
          ? _self.supplier
          : supplier // ignore: cast_nullable_to_non_nullable
              as Supplier,
      receiver: null == receiver
          ? _self.receiver
          : receiver // ignore: cast_nullable_to_non_nullable
              as Receiver,
      invoiceNo: null == invoiceNo
          ? _self.invoiceNo
          : invoiceNo // ignore: cast_nullable_to_non_nullable
              as String,
      invoiceDate: null == invoiceDate
          ? _self.invoiceDate
          : invoiceDate // ignore: cast_nullable_to_non_nullable
              as DateTime,
      dueDate: freezed == dueDate
          ? _self.dueDate
          : dueDate // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      placeOfSupply: null == placeOfSupply
          ? _self.placeOfSupply
          : placeOfSupply // ignore: cast_nullable_to_non_nullable
              as String,
      reverseCharge: null == reverseCharge
          ? _self.reverseCharge
          : reverseCharge // ignore: cast_nullable_to_non_nullable
              as String,
      paymentTerms: null == paymentTerms
          ? _self.paymentTerms
          : paymentTerms // ignore: cast_nullable_to_non_nullable
              as String,
      items: null == items
          ? _self.items
          : items // ignore: cast_nullable_to_non_nullable
              as List<InvoiceItem>,
      payments: null == payments
          ? _self.payments
          : payments // ignore: cast_nullable_to_non_nullable
              as List<PaymentTransaction>,
      comments: null == comments
          ? _self.comments
          : comments // ignore: cast_nullable_to_non_nullable
              as String,
      bankName: null == bankName
          ? _self.bankName
          : bankName // ignore: cast_nullable_to_non_nullable
              as String,
      accountNo: null == accountNo
          ? _self.accountNo
          : accountNo // ignore: cast_nullable_to_non_nullable
              as String,
      ifscCode: null == ifscCode
          ? _self.ifscCode
          : ifscCode // ignore: cast_nullable_to_non_nullable
              as String,
      branch: null == branch
          ? _self.branch
          : branch // ignore: cast_nullable_to_non_nullable
              as String,
      deliveryAddress: freezed == deliveryAddress
          ? _self.deliveryAddress
          : deliveryAddress // ignore: cast_nullable_to_non_nullable
              as String?,
      isArchived: null == isArchived
          ? _self.isArchived
          : isArchived // ignore: cast_nullable_to_non_nullable
              as bool,
      currency: null == currency
          ? _self.currency
          : currency // ignore: cast_nullable_to_non_nullable
              as String,
    ));
  }

  /// Create a copy of Invoice
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $SupplierCopyWith<$Res> get supplier {
    return $SupplierCopyWith<$Res>(_self.supplier, (value) {
      return _then(_self.copyWith(supplier: value));
    });
  }

  /// Create a copy of Invoice
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $ReceiverCopyWith<$Res> get receiver {
    return $ReceiverCopyWith<$Res>(_self.receiver, (value) {
      return _then(_self.copyWith(receiver: value));
    });
  }
}

/// Adds pattern-matching-related methods to [Invoice].
extension InvoicePatterns on Invoice {
  /// A variant of `map` that fallback to returning `orElse`.
  ///
  /// It is equivalent to doing:
  /// ```dart
  /// switch (sealedClass) {
  ///   case final Subclass value:
  ///     return ...;
  ///   case _:
  ///     return orElse();
  /// }
  /// ```

  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>(
    TResult Function(_Invoice value)? $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _Invoice() when $default != null:
        return $default(_that);
      case _:
        return orElse();
    }
  }

  /// A `switch`-like method, using callbacks.
  ///
  /// Callbacks receives the raw object, upcasted.
  /// It is equivalent to doing:
  /// ```dart
  /// switch (sealedClass) {
  ///   case final Subclass value:
  ///     return ...;
  ///   case final Subclass2 value:
  ///     return ...;
  /// }
  /// ```

  @optionalTypeArgs
  TResult map<TResult extends Object?>(
    TResult Function(_Invoice value) $default,
  ) {
    final _that = this;
    switch (_that) {
      case _Invoice():
        return $default(_that);
      case _:
        throw StateError('Unexpected subclass');
    }
  }

  /// A variant of `map` that fallback to returning `null`.
  ///
  /// It is equivalent to doing:
  /// ```dart
  /// switch (sealedClass) {
  ///   case final Subclass value:
  ///     return ...;
  ///   case _:
  ///     return null;
  /// }
  /// ```

  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>(
    TResult? Function(_Invoice value)? $default,
  ) {
    final _that = this;
    switch (_that) {
      case _Invoice() when $default != null:
        return $default(_that);
      case _:
        return null;
    }
  }

  /// A variant of `when` that fallback to an `orElse` callback.
  ///
  /// It is equivalent to doing:
  /// ```dart
  /// switch (sealedClass) {
  ///   case Subclass(:final field):
  ///     return ...;
  ///   case _:
  ///     return orElse();
  /// }
  /// ```

  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>(
    TResult Function(
            String? id,
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
            String currency)?
        $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _Invoice() when $default != null:
        return $default(
            _that.id,
            _that.style,
            _that.supplier,
            _that.receiver,
            _that.invoiceNo,
            _that.invoiceDate,
            _that.dueDate,
            _that.placeOfSupply,
            _that.reverseCharge,
            _that.paymentTerms,
            _that.items,
            _that.payments,
            _that.comments,
            _that.bankName,
            _that.accountNo,
            _that.ifscCode,
            _that.branch,
            _that.deliveryAddress,
            _that.isArchived,
            _that.currency);
      case _:
        return orElse();
    }
  }

  /// A `switch`-like method, using callbacks.
  ///
  /// As opposed to `map`, this offers destructuring.
  /// It is equivalent to doing:
  /// ```dart
  /// switch (sealedClass) {
  ///   case Subclass(:final field):
  ///     return ...;
  ///   case Subclass2(:final field2):
  ///     return ...;
  /// }
  /// ```

  @optionalTypeArgs
  TResult when<TResult extends Object?>(
    TResult Function(
            String? id,
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
            String currency)
        $default,
  ) {
    final _that = this;
    switch (_that) {
      case _Invoice():
        return $default(
            _that.id,
            _that.style,
            _that.supplier,
            _that.receiver,
            _that.invoiceNo,
            _that.invoiceDate,
            _that.dueDate,
            _that.placeOfSupply,
            _that.reverseCharge,
            _that.paymentTerms,
            _that.items,
            _that.payments,
            _that.comments,
            _that.bankName,
            _that.accountNo,
            _that.ifscCode,
            _that.branch,
            _that.deliveryAddress,
            _that.isArchived,
            _that.currency);
      case _:
        throw StateError('Unexpected subclass');
    }
  }

  /// A variant of `when` that fallback to returning `null`
  ///
  /// It is equivalent to doing:
  /// ```dart
  /// switch (sealedClass) {
  ///   case Subclass(:final field):
  ///     return ...;
  ///   case _:
  ///     return null;
  /// }
  /// ```

  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>(
    TResult? Function(
            String? id,
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
            String currency)?
        $default,
  ) {
    final _that = this;
    switch (_that) {
      case _Invoice() when $default != null:
        return $default(
            _that.id,
            _that.style,
            _that.supplier,
            _that.receiver,
            _that.invoiceNo,
            _that.invoiceDate,
            _that.dueDate,
            _that.placeOfSupply,
            _that.reverseCharge,
            _that.paymentTerms,
            _that.items,
            _that.payments,
            _that.comments,
            _that.bankName,
            _that.accountNo,
            _that.ifscCode,
            _that.branch,
            _that.deliveryAddress,
            _that.isArchived,
            _that.currency);
      case _:
        return null;
    }
  }
}

/// @nodoc
@JsonSerializable()
class _Invoice extends Invoice {
  const _Invoice(
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
      this.currency = 'INR'})
      : _items = items,
        _payments = payments,
        super._();
  factory _Invoice.fromJson(Map<String, dynamic> json) =>
      _$InvoiceFromJson(json);

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

  /// Create a copy of Invoice
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  _$InvoiceCopyWith<_Invoice> get copyWith =>
      __$InvoiceCopyWithImpl<_Invoice>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$InvoiceToJson(
      this,
    );
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _Invoice &&
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
                other.currency == currency));
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
        currency
      ]);

  @override
  String toString() {
    return 'Invoice(id: $id, style: $style, supplier: $supplier, receiver: $receiver, invoiceNo: $invoiceNo, invoiceDate: $invoiceDate, dueDate: $dueDate, placeOfSupply: $placeOfSupply, reverseCharge: $reverseCharge, paymentTerms: $paymentTerms, items: $items, payments: $payments, comments: $comments, bankName: $bankName, accountNo: $accountNo, ifscCode: $ifscCode, branch: $branch, deliveryAddress: $deliveryAddress, isArchived: $isArchived, currency: $currency)';
  }
}

/// @nodoc
abstract mixin class _$InvoiceCopyWith<$Res> implements $InvoiceCopyWith<$Res> {
  factory _$InvoiceCopyWith(_Invoice value, $Res Function(_Invoice) _then) =
      __$InvoiceCopyWithImpl;
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
      String currency});

  @override
  $SupplierCopyWith<$Res> get supplier;
  @override
  $ReceiverCopyWith<$Res> get receiver;
}

/// @nodoc
class __$InvoiceCopyWithImpl<$Res> implements _$InvoiceCopyWith<$Res> {
  __$InvoiceCopyWithImpl(this._self, this._then);

  final _Invoice _self;
  final $Res Function(_Invoice) _then;

  /// Create a copy of Invoice
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
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
  }) {
    return _then(_Invoice(
      id: freezed == id
          ? _self.id
          : id // ignore: cast_nullable_to_non_nullable
              as String?,
      style: null == style
          ? _self.style
          : style // ignore: cast_nullable_to_non_nullable
              as String,
      supplier: null == supplier
          ? _self.supplier
          : supplier // ignore: cast_nullable_to_non_nullable
              as Supplier,
      receiver: null == receiver
          ? _self.receiver
          : receiver // ignore: cast_nullable_to_non_nullable
              as Receiver,
      invoiceNo: null == invoiceNo
          ? _self.invoiceNo
          : invoiceNo // ignore: cast_nullable_to_non_nullable
              as String,
      invoiceDate: null == invoiceDate
          ? _self.invoiceDate
          : invoiceDate // ignore: cast_nullable_to_non_nullable
              as DateTime,
      dueDate: freezed == dueDate
          ? _self.dueDate
          : dueDate // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      placeOfSupply: null == placeOfSupply
          ? _self.placeOfSupply
          : placeOfSupply // ignore: cast_nullable_to_non_nullable
              as String,
      reverseCharge: null == reverseCharge
          ? _self.reverseCharge
          : reverseCharge // ignore: cast_nullable_to_non_nullable
              as String,
      paymentTerms: null == paymentTerms
          ? _self.paymentTerms
          : paymentTerms // ignore: cast_nullable_to_non_nullable
              as String,
      items: null == items
          ? _self._items
          : items // ignore: cast_nullable_to_non_nullable
              as List<InvoiceItem>,
      payments: null == payments
          ? _self._payments
          : payments // ignore: cast_nullable_to_non_nullable
              as List<PaymentTransaction>,
      comments: null == comments
          ? _self.comments
          : comments // ignore: cast_nullable_to_non_nullable
              as String,
      bankName: null == bankName
          ? _self.bankName
          : bankName // ignore: cast_nullable_to_non_nullable
              as String,
      accountNo: null == accountNo
          ? _self.accountNo
          : accountNo // ignore: cast_nullable_to_non_nullable
              as String,
      ifscCode: null == ifscCode
          ? _self.ifscCode
          : ifscCode // ignore: cast_nullable_to_non_nullable
              as String,
      branch: null == branch
          ? _self.branch
          : branch // ignore: cast_nullable_to_non_nullable
              as String,
      deliveryAddress: freezed == deliveryAddress
          ? _self.deliveryAddress
          : deliveryAddress // ignore: cast_nullable_to_non_nullable
              as String?,
      isArchived: null == isArchived
          ? _self.isArchived
          : isArchived // ignore: cast_nullable_to_non_nullable
              as bool,
      currency: null == currency
          ? _self.currency
          : currency // ignore: cast_nullable_to_non_nullable
              as String,
    ));
  }

  /// Create a copy of Invoice
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $SupplierCopyWith<$Res> get supplier {
    return $SupplierCopyWith<$Res>(_self.supplier, (value) {
      return _then(_self.copyWith(supplier: value));
    });
  }

  /// Create a copy of Invoice
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $ReceiverCopyWith<$Res> get receiver {
    return $ReceiverCopyWith<$Res>(_self.receiver, (value) {
      return _then(_self.copyWith(receiver: value));
    });
  }
}

/// @nodoc
mixin _$Supplier {
  String get name;
  String get address;
  String get gstin;
  String get pan;
  String get email;
  String get phone;
  String get state;

  /// Create a copy of Supplier
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $SupplierCopyWith<Supplier> get copyWith =>
      _$SupplierCopyWithImpl<Supplier>(this as Supplier, _$identity);

  /// Serializes this Supplier to a JSON map.
  Map<String, dynamic> toJson();

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is Supplier &&
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

  @override
  String toString() {
    return 'Supplier(name: $name, address: $address, gstin: $gstin, pan: $pan, email: $email, phone: $phone, state: $state)';
  }
}

/// @nodoc
abstract mixin class $SupplierCopyWith<$Res> {
  factory $SupplierCopyWith(Supplier value, $Res Function(Supplier) _then) =
      _$SupplierCopyWithImpl;
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
class _$SupplierCopyWithImpl<$Res> implements $SupplierCopyWith<$Res> {
  _$SupplierCopyWithImpl(this._self, this._then);

  final Supplier _self;
  final $Res Function(Supplier) _then;

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
    return _then(_self.copyWith(
      name: null == name
          ? _self.name
          : name // ignore: cast_nullable_to_non_nullable
              as String,
      address: null == address
          ? _self.address
          : address // ignore: cast_nullable_to_non_nullable
              as String,
      gstin: null == gstin
          ? _self.gstin
          : gstin // ignore: cast_nullable_to_non_nullable
              as String,
      pan: null == pan
          ? _self.pan
          : pan // ignore: cast_nullable_to_non_nullable
              as String,
      email: null == email
          ? _self.email
          : email // ignore: cast_nullable_to_non_nullable
              as String,
      phone: null == phone
          ? _self.phone
          : phone // ignore: cast_nullable_to_non_nullable
              as String,
      state: null == state
          ? _self.state
          : state // ignore: cast_nullable_to_non_nullable
              as String,
    ));
  }
}

/// Adds pattern-matching-related methods to [Supplier].
extension SupplierPatterns on Supplier {
  /// A variant of `map` that fallback to returning `orElse`.
  ///
  /// It is equivalent to doing:
  /// ```dart
  /// switch (sealedClass) {
  ///   case final Subclass value:
  ///     return ...;
  ///   case _:
  ///     return orElse();
  /// }
  /// ```

  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>(
    TResult Function(_Supplier value)? $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _Supplier() when $default != null:
        return $default(_that);
      case _:
        return orElse();
    }
  }

  /// A `switch`-like method, using callbacks.
  ///
  /// Callbacks receives the raw object, upcasted.
  /// It is equivalent to doing:
  /// ```dart
  /// switch (sealedClass) {
  ///   case final Subclass value:
  ///     return ...;
  ///   case final Subclass2 value:
  ///     return ...;
  /// }
  /// ```

  @optionalTypeArgs
  TResult map<TResult extends Object?>(
    TResult Function(_Supplier value) $default,
  ) {
    final _that = this;
    switch (_that) {
      case _Supplier():
        return $default(_that);
      case _:
        throw StateError('Unexpected subclass');
    }
  }

  /// A variant of `map` that fallback to returning `null`.
  ///
  /// It is equivalent to doing:
  /// ```dart
  /// switch (sealedClass) {
  ///   case final Subclass value:
  ///     return ...;
  ///   case _:
  ///     return null;
  /// }
  /// ```

  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>(
    TResult? Function(_Supplier value)? $default,
  ) {
    final _that = this;
    switch (_that) {
      case _Supplier() when $default != null:
        return $default(_that);
      case _:
        return null;
    }
  }

  /// A variant of `when` that fallback to an `orElse` callback.
  ///
  /// It is equivalent to doing:
  /// ```dart
  /// switch (sealedClass) {
  ///   case Subclass(:final field):
  ///     return ...;
  ///   case _:
  ///     return orElse();
  /// }
  /// ```

  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>(
    TResult Function(String name, String address, String gstin, String pan,
            String email, String phone, String state)?
        $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _Supplier() when $default != null:
        return $default(_that.name, _that.address, _that.gstin, _that.pan,
            _that.email, _that.phone, _that.state);
      case _:
        return orElse();
    }
  }

  /// A `switch`-like method, using callbacks.
  ///
  /// As opposed to `map`, this offers destructuring.
  /// It is equivalent to doing:
  /// ```dart
  /// switch (sealedClass) {
  ///   case Subclass(:final field):
  ///     return ...;
  ///   case Subclass2(:final field2):
  ///     return ...;
  /// }
  /// ```

  @optionalTypeArgs
  TResult when<TResult extends Object?>(
    TResult Function(String name, String address, String gstin, String pan,
            String email, String phone, String state)
        $default,
  ) {
    final _that = this;
    switch (_that) {
      case _Supplier():
        return $default(_that.name, _that.address, _that.gstin, _that.pan,
            _that.email, _that.phone, _that.state);
      case _:
        throw StateError('Unexpected subclass');
    }
  }

  /// A variant of `when` that fallback to returning `null`
  ///
  /// It is equivalent to doing:
  /// ```dart
  /// switch (sealedClass) {
  ///   case Subclass(:final field):
  ///     return ...;
  ///   case _:
  ///     return null;
  /// }
  /// ```

  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>(
    TResult? Function(String name, String address, String gstin, String pan,
            String email, String phone, String state)?
        $default,
  ) {
    final _that = this;
    switch (_that) {
      case _Supplier() when $default != null:
        return $default(_that.name, _that.address, _that.gstin, _that.pan,
            _that.email, _that.phone, _that.state);
      case _:
        return null;
    }
  }
}

/// @nodoc
@JsonSerializable()
class _Supplier implements Supplier {
  const _Supplier(
      {this.name = '',
      this.address = '',
      this.gstin = '',
      this.pan = '',
      this.email = '',
      this.phone = '',
      this.state = ''});
  factory _Supplier.fromJson(Map<String, dynamic> json) =>
      _$SupplierFromJson(json);

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

  /// Create a copy of Supplier
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  _$SupplierCopyWith<_Supplier> get copyWith =>
      __$SupplierCopyWithImpl<_Supplier>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$SupplierToJson(
      this,
    );
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _Supplier &&
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

  @override
  String toString() {
    return 'Supplier(name: $name, address: $address, gstin: $gstin, pan: $pan, email: $email, phone: $phone, state: $state)';
  }
}

/// @nodoc
abstract mixin class _$SupplierCopyWith<$Res>
    implements $SupplierCopyWith<$Res> {
  factory _$SupplierCopyWith(_Supplier value, $Res Function(_Supplier) _then) =
      __$SupplierCopyWithImpl;
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
class __$SupplierCopyWithImpl<$Res> implements _$SupplierCopyWith<$Res> {
  __$SupplierCopyWithImpl(this._self, this._then);

  final _Supplier _self;
  final $Res Function(_Supplier) _then;

  /// Create a copy of Supplier
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $Res call({
    Object? name = null,
    Object? address = null,
    Object? gstin = null,
    Object? pan = null,
    Object? email = null,
    Object? phone = null,
    Object? state = null,
  }) {
    return _then(_Supplier(
      name: null == name
          ? _self.name
          : name // ignore: cast_nullable_to_non_nullable
              as String,
      address: null == address
          ? _self.address
          : address // ignore: cast_nullable_to_non_nullable
              as String,
      gstin: null == gstin
          ? _self.gstin
          : gstin // ignore: cast_nullable_to_non_nullable
              as String,
      pan: null == pan
          ? _self.pan
          : pan // ignore: cast_nullable_to_non_nullable
              as String,
      email: null == email
          ? _self.email
          : email // ignore: cast_nullable_to_non_nullable
              as String,
      phone: null == phone
          ? _self.phone
          : phone // ignore: cast_nullable_to_non_nullable
              as String,
      state: null == state
          ? _self.state
          : state // ignore: cast_nullable_to_non_nullable
              as String,
    ));
  }
}

/// @nodoc
mixin _$Receiver {
  String get name;
  String get address;
  String get gstin;
  String get pan;
  String get state;
  String get stateCode;

  /// Create a copy of Receiver
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $ReceiverCopyWith<Receiver> get copyWith =>
      _$ReceiverCopyWithImpl<Receiver>(this as Receiver, _$identity);

  /// Serializes this Receiver to a JSON map.
  Map<String, dynamic> toJson();

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is Receiver &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.address, address) || other.address == address) &&
            (identical(other.gstin, gstin) || other.gstin == gstin) &&
            (identical(other.pan, pan) || other.pan == pan) &&
            (identical(other.state, state) || other.state == state) &&
            (identical(other.stateCode, stateCode) ||
                other.stateCode == stateCode));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode =>
      Object.hash(runtimeType, name, address, gstin, pan, state, stateCode);

  @override
  String toString() {
    return 'Receiver(name: $name, address: $address, gstin: $gstin, pan: $pan, state: $state, stateCode: $stateCode)';
  }
}

/// @nodoc
abstract mixin class $ReceiverCopyWith<$Res> {
  factory $ReceiverCopyWith(Receiver value, $Res Function(Receiver) _then) =
      _$ReceiverCopyWithImpl;
  @useResult
  $Res call(
      {String name,
      String address,
      String gstin,
      String pan,
      String state,
      String stateCode});
}

/// @nodoc
class _$ReceiverCopyWithImpl<$Res> implements $ReceiverCopyWith<$Res> {
  _$ReceiverCopyWithImpl(this._self, this._then);

  final Receiver _self;
  final $Res Function(Receiver) _then;

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
  }) {
    return _then(_self.copyWith(
      name: null == name
          ? _self.name
          : name // ignore: cast_nullable_to_non_nullable
              as String,
      address: null == address
          ? _self.address
          : address // ignore: cast_nullable_to_non_nullable
              as String,
      gstin: null == gstin
          ? _self.gstin
          : gstin // ignore: cast_nullable_to_non_nullable
              as String,
      pan: null == pan
          ? _self.pan
          : pan // ignore: cast_nullable_to_non_nullable
              as String,
      state: null == state
          ? _self.state
          : state // ignore: cast_nullable_to_non_nullable
              as String,
      stateCode: null == stateCode
          ? _self.stateCode
          : stateCode // ignore: cast_nullable_to_non_nullable
              as String,
    ));
  }
}

/// Adds pattern-matching-related methods to [Receiver].
extension ReceiverPatterns on Receiver {
  /// A variant of `map` that fallback to returning `orElse`.
  ///
  /// It is equivalent to doing:
  /// ```dart
  /// switch (sealedClass) {
  ///   case final Subclass value:
  ///     return ...;
  ///   case _:
  ///     return orElse();
  /// }
  /// ```

  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>(
    TResult Function(_Receiver value)? $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _Receiver() when $default != null:
        return $default(_that);
      case _:
        return orElse();
    }
  }

  /// A `switch`-like method, using callbacks.
  ///
  /// Callbacks receives the raw object, upcasted.
  /// It is equivalent to doing:
  /// ```dart
  /// switch (sealedClass) {
  ///   case final Subclass value:
  ///     return ...;
  ///   case final Subclass2 value:
  ///     return ...;
  /// }
  /// ```

  @optionalTypeArgs
  TResult map<TResult extends Object?>(
    TResult Function(_Receiver value) $default,
  ) {
    final _that = this;
    switch (_that) {
      case _Receiver():
        return $default(_that);
      case _:
        throw StateError('Unexpected subclass');
    }
  }

  /// A variant of `map` that fallback to returning `null`.
  ///
  /// It is equivalent to doing:
  /// ```dart
  /// switch (sealedClass) {
  ///   case final Subclass value:
  ///     return ...;
  ///   case _:
  ///     return null;
  /// }
  /// ```

  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>(
    TResult? Function(_Receiver value)? $default,
  ) {
    final _that = this;
    switch (_that) {
      case _Receiver() when $default != null:
        return $default(_that);
      case _:
        return null;
    }
  }

  /// A variant of `when` that fallback to an `orElse` callback.
  ///
  /// It is equivalent to doing:
  /// ```dart
  /// switch (sealedClass) {
  ///   case Subclass(:final field):
  ///     return ...;
  ///   case _:
  ///     return orElse();
  /// }
  /// ```

  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>(
    TResult Function(String name, String address, String gstin, String pan,
            String state, String stateCode)?
        $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _Receiver() when $default != null:
        return $default(_that.name, _that.address, _that.gstin, _that.pan,
            _that.state, _that.stateCode);
      case _:
        return orElse();
    }
  }

  /// A `switch`-like method, using callbacks.
  ///
  /// As opposed to `map`, this offers destructuring.
  /// It is equivalent to doing:
  /// ```dart
  /// switch (sealedClass) {
  ///   case Subclass(:final field):
  ///     return ...;
  ///   case Subclass2(:final field2):
  ///     return ...;
  /// }
  /// ```

  @optionalTypeArgs
  TResult when<TResult extends Object?>(
    TResult Function(String name, String address, String gstin, String pan,
            String state, String stateCode)
        $default,
  ) {
    final _that = this;
    switch (_that) {
      case _Receiver():
        return $default(_that.name, _that.address, _that.gstin, _that.pan,
            _that.state, _that.stateCode);
      case _:
        throw StateError('Unexpected subclass');
    }
  }

  /// A variant of `when` that fallback to returning `null`
  ///
  /// It is equivalent to doing:
  /// ```dart
  /// switch (sealedClass) {
  ///   case Subclass(:final field):
  ///     return ...;
  ///   case _:
  ///     return null;
  /// }
  /// ```

  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>(
    TResult? Function(String name, String address, String gstin, String pan,
            String state, String stateCode)?
        $default,
  ) {
    final _that = this;
    switch (_that) {
      case _Receiver() when $default != null:
        return $default(_that.name, _that.address, _that.gstin, _that.pan,
            _that.state, _that.stateCode);
      case _:
        return null;
    }
  }
}

/// @nodoc
@JsonSerializable()
class _Receiver implements Receiver {
  const _Receiver(
      {this.name = '',
      this.address = '',
      this.gstin = '',
      this.pan = '',
      this.state = '',
      this.stateCode = ''});
  factory _Receiver.fromJson(Map<String, dynamic> json) =>
      _$ReceiverFromJson(json);

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

  /// Create a copy of Receiver
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  _$ReceiverCopyWith<_Receiver> get copyWith =>
      __$ReceiverCopyWithImpl<_Receiver>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$ReceiverToJson(
      this,
    );
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _Receiver &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.address, address) || other.address == address) &&
            (identical(other.gstin, gstin) || other.gstin == gstin) &&
            (identical(other.pan, pan) || other.pan == pan) &&
            (identical(other.state, state) || other.state == state) &&
            (identical(other.stateCode, stateCode) ||
                other.stateCode == stateCode));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode =>
      Object.hash(runtimeType, name, address, gstin, pan, state, stateCode);

  @override
  String toString() {
    return 'Receiver(name: $name, address: $address, gstin: $gstin, pan: $pan, state: $state, stateCode: $stateCode)';
  }
}

/// @nodoc
abstract mixin class _$ReceiverCopyWith<$Res>
    implements $ReceiverCopyWith<$Res> {
  factory _$ReceiverCopyWith(_Receiver value, $Res Function(_Receiver) _then) =
      __$ReceiverCopyWithImpl;
  @override
  @useResult
  $Res call(
      {String name,
      String address,
      String gstin,
      String pan,
      String state,
      String stateCode});
}

/// @nodoc
class __$ReceiverCopyWithImpl<$Res> implements _$ReceiverCopyWith<$Res> {
  __$ReceiverCopyWithImpl(this._self, this._then);

  final _Receiver _self;
  final $Res Function(_Receiver) _then;

  /// Create a copy of Receiver
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $Res call({
    Object? name = null,
    Object? address = null,
    Object? gstin = null,
    Object? pan = null,
    Object? state = null,
    Object? stateCode = null,
  }) {
    return _then(_Receiver(
      name: null == name
          ? _self.name
          : name // ignore: cast_nullable_to_non_nullable
              as String,
      address: null == address
          ? _self.address
          : address // ignore: cast_nullable_to_non_nullable
              as String,
      gstin: null == gstin
          ? _self.gstin
          : gstin // ignore: cast_nullable_to_non_nullable
              as String,
      pan: null == pan
          ? _self.pan
          : pan // ignore: cast_nullable_to_non_nullable
              as String,
      state: null == state
          ? _self.state
          : state // ignore: cast_nullable_to_non_nullable
              as String,
      stateCode: null == stateCode
          ? _self.stateCode
          : stateCode // ignore: cast_nullable_to_non_nullable
              as String,
    ));
  }
}

/// @nodoc
mixin _$InvoiceItem {
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
  String get description;
  String get sacCode;
  String get codeType;
  String get year; // e.g. "F.Y. 2025-26"
  double get amount;
  double get discount;
  double get quantity;
  String get unit;
  double get gstRate;

  /// Create a copy of InvoiceItem
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $InvoiceItemCopyWith<InvoiceItem> get copyWith =>
      _$InvoiceItemCopyWithImpl<InvoiceItem>(this as InvoiceItem, _$identity);

  /// Serializes this InvoiceItem to a JSON map.
  Map<String, dynamic> toJson();

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is InvoiceItem &&
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

  @override
  String toString() {
    return 'InvoiceItem(id: $id, description: $description, sacCode: $sacCode, codeType: $codeType, year: $year, amount: $amount, discount: $discount, quantity: $quantity, unit: $unit, gstRate: $gstRate)';
  }
}

/// @nodoc
abstract mixin class $InvoiceItemCopyWith<$Res> {
  factory $InvoiceItemCopyWith(
          InvoiceItem value, $Res Function(InvoiceItem) _then) =
      _$InvoiceItemCopyWithImpl;
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
class _$InvoiceItemCopyWithImpl<$Res> implements $InvoiceItemCopyWith<$Res> {
  _$InvoiceItemCopyWithImpl(this._self, this._then);

  final InvoiceItem _self;
  final $Res Function(InvoiceItem) _then;

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
    return _then(_self.copyWith(
      id: freezed == id
          ? _self.id
          : id // ignore: cast_nullable_to_non_nullable
              as String?,
      description: null == description
          ? _self.description
          : description // ignore: cast_nullable_to_non_nullable
              as String,
      sacCode: null == sacCode
          ? _self.sacCode
          : sacCode // ignore: cast_nullable_to_non_nullable
              as String,
      codeType: null == codeType
          ? _self.codeType
          : codeType // ignore: cast_nullable_to_non_nullable
              as String,
      year: null == year
          ? _self.year
          : year // ignore: cast_nullable_to_non_nullable
              as String,
      amount: null == amount
          ? _self.amount
          : amount // ignore: cast_nullable_to_non_nullable
              as double,
      discount: null == discount
          ? _self.discount
          : discount // ignore: cast_nullable_to_non_nullable
              as double,
      quantity: null == quantity
          ? _self.quantity
          : quantity // ignore: cast_nullable_to_non_nullable
              as double,
      unit: null == unit
          ? _self.unit
          : unit // ignore: cast_nullable_to_non_nullable
              as String,
      gstRate: null == gstRate
          ? _self.gstRate
          : gstRate // ignore: cast_nullable_to_non_nullable
              as double,
    ));
  }
}

/// Adds pattern-matching-related methods to [InvoiceItem].
extension InvoiceItemPatterns on InvoiceItem {
  /// A variant of `map` that fallback to returning `orElse`.
  ///
  /// It is equivalent to doing:
  /// ```dart
  /// switch (sealedClass) {
  ///   case final Subclass value:
  ///     return ...;
  ///   case _:
  ///     return orElse();
  /// }
  /// ```

  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>(
    TResult Function(_InvoiceItem value)? $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _InvoiceItem() when $default != null:
        return $default(_that);
      case _:
        return orElse();
    }
  }

  /// A `switch`-like method, using callbacks.
  ///
  /// Callbacks receives the raw object, upcasted.
  /// It is equivalent to doing:
  /// ```dart
  /// switch (sealedClass) {
  ///   case final Subclass value:
  ///     return ...;
  ///   case final Subclass2 value:
  ///     return ...;
  /// }
  /// ```

  @optionalTypeArgs
  TResult map<TResult extends Object?>(
    TResult Function(_InvoiceItem value) $default,
  ) {
    final _that = this;
    switch (_that) {
      case _InvoiceItem():
        return $default(_that);
      case _:
        throw StateError('Unexpected subclass');
    }
  }

  /// A variant of `map` that fallback to returning `null`.
  ///
  /// It is equivalent to doing:
  /// ```dart
  /// switch (sealedClass) {
  ///   case final Subclass value:
  ///     return ...;
  ///   case _:
  ///     return null;
  /// }
  /// ```

  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>(
    TResult? Function(_InvoiceItem value)? $default,
  ) {
    final _that = this;
    switch (_that) {
      case _InvoiceItem() when $default != null:
        return $default(_that);
      case _:
        return null;
    }
  }

  /// A variant of `when` that fallback to an `orElse` callback.
  ///
  /// It is equivalent to doing:
  /// ```dart
  /// switch (sealedClass) {
  ///   case Subclass(:final field):
  ///     return ...;
  ///   case _:
  ///     return orElse();
  /// }
  /// ```

  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>(
    TResult Function(
            String? id,
            String description,
            String sacCode,
            String codeType,
            String year,
            double amount,
            double discount,
            double quantity,
            String unit,
            double gstRate)?
        $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _InvoiceItem() when $default != null:
        return $default(
            _that.id,
            _that.description,
            _that.sacCode,
            _that.codeType,
            _that.year,
            _that.amount,
            _that.discount,
            _that.quantity,
            _that.unit,
            _that.gstRate);
      case _:
        return orElse();
    }
  }

  /// A `switch`-like method, using callbacks.
  ///
  /// As opposed to `map`, this offers destructuring.
  /// It is equivalent to doing:
  /// ```dart
  /// switch (sealedClass) {
  ///   case Subclass(:final field):
  ///     return ...;
  ///   case Subclass2(:final field2):
  ///     return ...;
  /// }
  /// ```

  @optionalTypeArgs
  TResult when<TResult extends Object?>(
    TResult Function(
            String? id,
            String description,
            String sacCode,
            String codeType,
            String year,
            double amount,
            double discount,
            double quantity,
            String unit,
            double gstRate)
        $default,
  ) {
    final _that = this;
    switch (_that) {
      case _InvoiceItem():
        return $default(
            _that.id,
            _that.description,
            _that.sacCode,
            _that.codeType,
            _that.year,
            _that.amount,
            _that.discount,
            _that.quantity,
            _that.unit,
            _that.gstRate);
      case _:
        throw StateError('Unexpected subclass');
    }
  }

  /// A variant of `when` that fallback to returning `null`
  ///
  /// It is equivalent to doing:
  /// ```dart
  /// switch (sealedClass) {
  ///   case Subclass(:final field):
  ///     return ...;
  ///   case _:
  ///     return null;
  /// }
  /// ```

  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>(
    TResult? Function(
            String? id,
            String description,
            String sacCode,
            String codeType,
            String year,
            double amount,
            double discount,
            double quantity,
            String unit,
            double gstRate)?
        $default,
  ) {
    final _that = this;
    switch (_that) {
      case _InvoiceItem() when $default != null:
        return $default(
            _that.id,
            _that.description,
            _that.sacCode,
            _that.codeType,
            _that.year,
            _that.amount,
            _that.discount,
            _that.quantity,
            _that.unit,
            _that.gstRate);
      case _:
        return null;
    }
  }
}

/// @nodoc
@JsonSerializable()
class _InvoiceItem extends InvoiceItem {
  const _InvoiceItem(
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
  factory _InvoiceItem.fromJson(Map<String, dynamic> json) =>
      _$InvoiceItemFromJson(json);

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

  /// Create a copy of InvoiceItem
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  _$InvoiceItemCopyWith<_InvoiceItem> get copyWith =>
      __$InvoiceItemCopyWithImpl<_InvoiceItem>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$InvoiceItemToJson(
      this,
    );
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _InvoiceItem &&
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

  @override
  String toString() {
    return 'InvoiceItem(id: $id, description: $description, sacCode: $sacCode, codeType: $codeType, year: $year, amount: $amount, discount: $discount, quantity: $quantity, unit: $unit, gstRate: $gstRate)';
  }
}

/// @nodoc
abstract mixin class _$InvoiceItemCopyWith<$Res>
    implements $InvoiceItemCopyWith<$Res> {
  factory _$InvoiceItemCopyWith(
          _InvoiceItem value, $Res Function(_InvoiceItem) _then) =
      __$InvoiceItemCopyWithImpl;
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
class __$InvoiceItemCopyWithImpl<$Res> implements _$InvoiceItemCopyWith<$Res> {
  __$InvoiceItemCopyWithImpl(this._self, this._then);

  final _InvoiceItem _self;
  final $Res Function(_InvoiceItem) _then;

  /// Create a copy of InvoiceItem
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
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
    return _then(_InvoiceItem(
      id: freezed == id
          ? _self.id
          : id // ignore: cast_nullable_to_non_nullable
              as String?,
      description: null == description
          ? _self.description
          : description // ignore: cast_nullable_to_non_nullable
              as String,
      sacCode: null == sacCode
          ? _self.sacCode
          : sacCode // ignore: cast_nullable_to_non_nullable
              as String,
      codeType: null == codeType
          ? _self.codeType
          : codeType // ignore: cast_nullable_to_non_nullable
              as String,
      year: null == year
          ? _self.year
          : year // ignore: cast_nullable_to_non_nullable
              as String,
      amount: null == amount
          ? _self.amount
          : amount // ignore: cast_nullable_to_non_nullable
              as double,
      discount: null == discount
          ? _self.discount
          : discount // ignore: cast_nullable_to_non_nullable
              as double,
      quantity: null == quantity
          ? _self.quantity
          : quantity // ignore: cast_nullable_to_non_nullable
              as double,
      unit: null == unit
          ? _self.unit
          : unit // ignore: cast_nullable_to_non_nullable
              as String,
      gstRate: null == gstRate
          ? _self.gstRate
          : gstRate // ignore: cast_nullable_to_non_nullable
              as double,
    ));
  }
}

// dart format on
