// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'estimate.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$Estimate {
  String get id;
  String get estimateNo;
  DateTime get date;
  DateTime? get expiryDate;
  Supplier get supplier;
  Receiver get receiver;
  List<InvoiceItem> get items;
  String get notes;
  String get terms;
  String? get status;

  /// Create a copy of Estimate
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $EstimateCopyWith<Estimate> get copyWith =>
      _$EstimateCopyWithImpl<Estimate>(this as Estimate, _$identity);

  /// Serializes this Estimate to a JSON map.
  Map<String, dynamic> toJson();

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is Estimate &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.estimateNo, estimateNo) ||
                other.estimateNo == estimateNo) &&
            (identical(other.date, date) || other.date == date) &&
            (identical(other.expiryDate, expiryDate) ||
                other.expiryDate == expiryDate) &&
            (identical(other.supplier, supplier) ||
                other.supplier == supplier) &&
            (identical(other.receiver, receiver) ||
                other.receiver == receiver) &&
            const DeepCollectionEquality().equals(other.items, items) &&
            (identical(other.notes, notes) || other.notes == notes) &&
            (identical(other.terms, terms) || other.terms == terms) &&
            (identical(other.status, status) || other.status == status));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      id,
      estimateNo,
      date,
      expiryDate,
      supplier,
      receiver,
      const DeepCollectionEquality().hash(items),
      notes,
      terms,
      status);

  @override
  String toString() {
    return 'Estimate(id: $id, estimateNo: $estimateNo, date: $date, expiryDate: $expiryDate, supplier: $supplier, receiver: $receiver, items: $items, notes: $notes, terms: $terms, status: $status)';
  }
}

/// @nodoc
abstract mixin class $EstimateCopyWith<$Res> {
  factory $EstimateCopyWith(Estimate value, $Res Function(Estimate) _then) =
      _$EstimateCopyWithImpl;
  @useResult
  $Res call(
      {String id,
      String estimateNo,
      DateTime date,
      DateTime? expiryDate,
      Supplier supplier,
      Receiver receiver,
      List<InvoiceItem> items,
      String notes,
      String terms,
      String? status});

  $SupplierCopyWith<$Res> get supplier;
  $ReceiverCopyWith<$Res> get receiver;
}

/// @nodoc
class _$EstimateCopyWithImpl<$Res> implements $EstimateCopyWith<$Res> {
  _$EstimateCopyWithImpl(this._self, this._then);

  final Estimate _self;
  final $Res Function(Estimate) _then;

  /// Create a copy of Estimate
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? estimateNo = null,
    Object? date = null,
    Object? expiryDate = freezed,
    Object? supplier = null,
    Object? receiver = null,
    Object? items = null,
    Object? notes = null,
    Object? terms = null,
    Object? status = freezed,
  }) {
    return _then(_self.copyWith(
      id: null == id
          ? _self.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      estimateNo: null == estimateNo
          ? _self.estimateNo
          : estimateNo // ignore: cast_nullable_to_non_nullable
              as String,
      date: null == date
          ? _self.date
          : date // ignore: cast_nullable_to_non_nullable
              as DateTime,
      expiryDate: freezed == expiryDate
          ? _self.expiryDate
          : expiryDate // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      supplier: null == supplier
          ? _self.supplier
          : supplier // ignore: cast_nullable_to_non_nullable
              as Supplier,
      receiver: null == receiver
          ? _self.receiver
          : receiver // ignore: cast_nullable_to_non_nullable
              as Receiver,
      items: null == items
          ? _self.items
          : items // ignore: cast_nullable_to_non_nullable
              as List<InvoiceItem>,
      notes: null == notes
          ? _self.notes
          : notes // ignore: cast_nullable_to_non_nullable
              as String,
      terms: null == terms
          ? _self.terms
          : terms // ignore: cast_nullable_to_non_nullable
              as String,
      status: freezed == status
          ? _self.status
          : status // ignore: cast_nullable_to_non_nullable
              as String?,
    ));
  }

  /// Create a copy of Estimate
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $SupplierCopyWith<$Res> get supplier {
    return $SupplierCopyWith<$Res>(_self.supplier, (value) {
      return _then(_self.copyWith(supplier: value));
    });
  }

  /// Create a copy of Estimate
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $ReceiverCopyWith<$Res> get receiver {
    return $ReceiverCopyWith<$Res>(_self.receiver, (value) {
      return _then(_self.copyWith(receiver: value));
    });
  }
}

/// Adds pattern-matching-related methods to [Estimate].
extension EstimatePatterns on Estimate {
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
    TResult Function(_Estimate value)? $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _Estimate() when $default != null:
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
    TResult Function(_Estimate value) $default,
  ) {
    final _that = this;
    switch (_that) {
      case _Estimate():
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
    TResult? Function(_Estimate value)? $default,
  ) {
    final _that = this;
    switch (_that) {
      case _Estimate() when $default != null:
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
            String id,
            String estimateNo,
            DateTime date,
            DateTime? expiryDate,
            Supplier supplier,
            Receiver receiver,
            List<InvoiceItem> items,
            String notes,
            String terms,
            String? status)?
        $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _Estimate() when $default != null:
        return $default(
            _that.id,
            _that.estimateNo,
            _that.date,
            _that.expiryDate,
            _that.supplier,
            _that.receiver,
            _that.items,
            _that.notes,
            _that.terms,
            _that.status);
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
            String id,
            String estimateNo,
            DateTime date,
            DateTime? expiryDate,
            Supplier supplier,
            Receiver receiver,
            List<InvoiceItem> items,
            String notes,
            String terms,
            String? status)
        $default,
  ) {
    final _that = this;
    switch (_that) {
      case _Estimate():
        return $default(
            _that.id,
            _that.estimateNo,
            _that.date,
            _that.expiryDate,
            _that.supplier,
            _that.receiver,
            _that.items,
            _that.notes,
            _that.terms,
            _that.status);
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
            String id,
            String estimateNo,
            DateTime date,
            DateTime? expiryDate,
            Supplier supplier,
            Receiver receiver,
            List<InvoiceItem> items,
            String notes,
            String terms,
            String? status)?
        $default,
  ) {
    final _that = this;
    switch (_that) {
      case _Estimate() when $default != null:
        return $default(
            _that.id,
            _that.estimateNo,
            _that.date,
            _that.expiryDate,
            _that.supplier,
            _that.receiver,
            _that.items,
            _that.notes,
            _that.terms,
            _that.status);
      case _:
        return null;
    }
  }
}

/// @nodoc
@JsonSerializable()
class _Estimate extends Estimate {
  const _Estimate(
      {required this.id,
      this.estimateNo = '',
      required this.date,
      this.expiryDate,
      required this.supplier,
      required this.receiver,
      final List<InvoiceItem> items = const [],
      this.notes = '',
      this.terms = '',
      this.status = 'Draft'})
      : _items = items,
        super._();
  factory _Estimate.fromJson(Map<String, dynamic> json) =>
      _$EstimateFromJson(json);

  @override
  final String id;
  @override
  @JsonKey()
  final String estimateNo;
  @override
  final DateTime date;
  @override
  final DateTime? expiryDate;
  @override
  final Supplier supplier;
  @override
  final Receiver receiver;
  final List<InvoiceItem> _items;
  @override
  @JsonKey()
  List<InvoiceItem> get items {
    if (_items is EqualUnmodifiableListView) return _items;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_items);
  }

  @override
  @JsonKey()
  final String notes;
  @override
  @JsonKey()
  final String terms;
  @override
  @JsonKey()
  final String? status;

  /// Create a copy of Estimate
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  _$EstimateCopyWith<_Estimate> get copyWith =>
      __$EstimateCopyWithImpl<_Estimate>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$EstimateToJson(
      this,
    );
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _Estimate &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.estimateNo, estimateNo) ||
                other.estimateNo == estimateNo) &&
            (identical(other.date, date) || other.date == date) &&
            (identical(other.expiryDate, expiryDate) ||
                other.expiryDate == expiryDate) &&
            (identical(other.supplier, supplier) ||
                other.supplier == supplier) &&
            (identical(other.receiver, receiver) ||
                other.receiver == receiver) &&
            const DeepCollectionEquality().equals(other._items, _items) &&
            (identical(other.notes, notes) || other.notes == notes) &&
            (identical(other.terms, terms) || other.terms == terms) &&
            (identical(other.status, status) || other.status == status));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      id,
      estimateNo,
      date,
      expiryDate,
      supplier,
      receiver,
      const DeepCollectionEquality().hash(_items),
      notes,
      terms,
      status);

  @override
  String toString() {
    return 'Estimate(id: $id, estimateNo: $estimateNo, date: $date, expiryDate: $expiryDate, supplier: $supplier, receiver: $receiver, items: $items, notes: $notes, terms: $terms, status: $status)';
  }
}

/// @nodoc
abstract mixin class _$EstimateCopyWith<$Res>
    implements $EstimateCopyWith<$Res> {
  factory _$EstimateCopyWith(_Estimate value, $Res Function(_Estimate) _then) =
      __$EstimateCopyWithImpl;
  @override
  @useResult
  $Res call(
      {String id,
      String estimateNo,
      DateTime date,
      DateTime? expiryDate,
      Supplier supplier,
      Receiver receiver,
      List<InvoiceItem> items,
      String notes,
      String terms,
      String? status});

  @override
  $SupplierCopyWith<$Res> get supplier;
  @override
  $ReceiverCopyWith<$Res> get receiver;
}

/// @nodoc
class __$EstimateCopyWithImpl<$Res> implements _$EstimateCopyWith<$Res> {
  __$EstimateCopyWithImpl(this._self, this._then);

  final _Estimate _self;
  final $Res Function(_Estimate) _then;

  /// Create a copy of Estimate
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $Res call({
    Object? id = null,
    Object? estimateNo = null,
    Object? date = null,
    Object? expiryDate = freezed,
    Object? supplier = null,
    Object? receiver = null,
    Object? items = null,
    Object? notes = null,
    Object? terms = null,
    Object? status = freezed,
  }) {
    return _then(_Estimate(
      id: null == id
          ? _self.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      estimateNo: null == estimateNo
          ? _self.estimateNo
          : estimateNo // ignore: cast_nullable_to_non_nullable
              as String,
      date: null == date
          ? _self.date
          : date // ignore: cast_nullable_to_non_nullable
              as DateTime,
      expiryDate: freezed == expiryDate
          ? _self.expiryDate
          : expiryDate // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      supplier: null == supplier
          ? _self.supplier
          : supplier // ignore: cast_nullable_to_non_nullable
              as Supplier,
      receiver: null == receiver
          ? _self.receiver
          : receiver // ignore: cast_nullable_to_non_nullable
              as Receiver,
      items: null == items
          ? _self._items
          : items // ignore: cast_nullable_to_non_nullable
              as List<InvoiceItem>,
      notes: null == notes
          ? _self.notes
          : notes // ignore: cast_nullable_to_non_nullable
              as String,
      terms: null == terms
          ? _self.terms
          : terms // ignore: cast_nullable_to_non_nullable
              as String,
      status: freezed == status
          ? _self.status
          : status // ignore: cast_nullable_to_non_nullable
              as String?,
    ));
  }

  /// Create a copy of Estimate
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $SupplierCopyWith<$Res> get supplier {
    return $SupplierCopyWith<$Res>(_self.supplier, (value) {
      return _then(_self.copyWith(supplier: value));
    });
  }

  /// Create a copy of Estimate
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $ReceiverCopyWith<$Res> get receiver {
    return $ReceiverCopyWith<$Res>(_self.receiver, (value) {
      return _then(_self.copyWith(receiver: value));
    });
  }
}

// dart format on
