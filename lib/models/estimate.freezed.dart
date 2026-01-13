// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'estimate.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

Estimate _$EstimateFromJson(Map<String, dynamic> json) {
  return _Estimate.fromJson(json);
}

/// @nodoc
mixin _$Estimate {
  String get id => throw _privateConstructorUsedError;
  String get estimateNo => throw _privateConstructorUsedError;
  DateTime get date => throw _privateConstructorUsedError;
  DateTime? get expiryDate => throw _privateConstructorUsedError;
  Supplier get supplier => throw _privateConstructorUsedError;
  Receiver get receiver => throw _privateConstructorUsedError;
  List<InvoiceItem> get items => throw _privateConstructorUsedError;
  String get notes => throw _privateConstructorUsedError;
  String get terms => throw _privateConstructorUsedError;
  String? get status => throw _privateConstructorUsedError;

  /// Serializes this Estimate to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of Estimate
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $EstimateCopyWith<Estimate> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $EstimateCopyWith<$Res> {
  factory $EstimateCopyWith(Estimate value, $Res Function(Estimate) then) =
      _$EstimateCopyWithImpl<$Res, Estimate>;
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
class _$EstimateCopyWithImpl<$Res, $Val extends Estimate>
    implements $EstimateCopyWith<$Res> {
  _$EstimateCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

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
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      estimateNo: null == estimateNo
          ? _value.estimateNo
          : estimateNo // ignore: cast_nullable_to_non_nullable
              as String,
      date: null == date
          ? _value.date
          : date // ignore: cast_nullable_to_non_nullable
              as DateTime,
      expiryDate: freezed == expiryDate
          ? _value.expiryDate
          : expiryDate // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      supplier: null == supplier
          ? _value.supplier
          : supplier // ignore: cast_nullable_to_non_nullable
              as Supplier,
      receiver: null == receiver
          ? _value.receiver
          : receiver // ignore: cast_nullable_to_non_nullable
              as Receiver,
      items: null == items
          ? _value.items
          : items // ignore: cast_nullable_to_non_nullable
              as List<InvoiceItem>,
      notes: null == notes
          ? _value.notes
          : notes // ignore: cast_nullable_to_non_nullable
              as String,
      terms: null == terms
          ? _value.terms
          : terms // ignore: cast_nullable_to_non_nullable
              as String,
      status: freezed == status
          ? _value.status
          : status // ignore: cast_nullable_to_non_nullable
              as String?,
    ) as $Val);
  }

  /// Create a copy of Estimate
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $SupplierCopyWith<$Res> get supplier {
    return $SupplierCopyWith<$Res>(_value.supplier, (value) {
      return _then(_value.copyWith(supplier: value) as $Val);
    });
  }

  /// Create a copy of Estimate
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
abstract class _$$EstimateImplCopyWith<$Res>
    implements $EstimateCopyWith<$Res> {
  factory _$$EstimateImplCopyWith(
          _$EstimateImpl value, $Res Function(_$EstimateImpl) then) =
      __$$EstimateImplCopyWithImpl<$Res>;
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
class __$$EstimateImplCopyWithImpl<$Res>
    extends _$EstimateCopyWithImpl<$Res, _$EstimateImpl>
    implements _$$EstimateImplCopyWith<$Res> {
  __$$EstimateImplCopyWithImpl(
      _$EstimateImpl _value, $Res Function(_$EstimateImpl) _then)
      : super(_value, _then);

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
    return _then(_$EstimateImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      estimateNo: null == estimateNo
          ? _value.estimateNo
          : estimateNo // ignore: cast_nullable_to_non_nullable
              as String,
      date: null == date
          ? _value.date
          : date // ignore: cast_nullable_to_non_nullable
              as DateTime,
      expiryDate: freezed == expiryDate
          ? _value.expiryDate
          : expiryDate // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      supplier: null == supplier
          ? _value.supplier
          : supplier // ignore: cast_nullable_to_non_nullable
              as Supplier,
      receiver: null == receiver
          ? _value.receiver
          : receiver // ignore: cast_nullable_to_non_nullable
              as Receiver,
      items: null == items
          ? _value._items
          : items // ignore: cast_nullable_to_non_nullable
              as List<InvoiceItem>,
      notes: null == notes
          ? _value.notes
          : notes // ignore: cast_nullable_to_non_nullable
              as String,
      terms: null == terms
          ? _value.terms
          : terms // ignore: cast_nullable_to_non_nullable
              as String,
      status: freezed == status
          ? _value.status
          : status // ignore: cast_nullable_to_non_nullable
              as String?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$EstimateImpl extends _Estimate {
  const _$EstimateImpl(
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

  factory _$EstimateImpl.fromJson(Map<String, dynamic> json) =>
      _$$EstimateImplFromJson(json);

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

  @override
  String toString() {
    return 'Estimate(id: $id, estimateNo: $estimateNo, date: $date, expiryDate: $expiryDate, supplier: $supplier, receiver: $receiver, items: $items, notes: $notes, terms: $terms, status: $status)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$EstimateImpl &&
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

  /// Create a copy of Estimate
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$EstimateImplCopyWith<_$EstimateImpl> get copyWith =>
      __$$EstimateImplCopyWithImpl<_$EstimateImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$EstimateImplToJson(
      this,
    );
  }
}

abstract class _Estimate extends Estimate {
  const factory _Estimate(
      {required final String id,
      final String estimateNo,
      required final DateTime date,
      final DateTime? expiryDate,
      required final Supplier supplier,
      required final Receiver receiver,
      final List<InvoiceItem> items,
      final String notes,
      final String terms,
      final String? status}) = _$EstimateImpl;
  const _Estimate._() : super._();

  factory _Estimate.fromJson(Map<String, dynamic> json) =
      _$EstimateImpl.fromJson;

  @override
  String get id;
  @override
  String get estimateNo;
  @override
  DateTime get date;
  @override
  DateTime? get expiryDate;
  @override
  Supplier get supplier;
  @override
  Receiver get receiver;
  @override
  List<InvoiceItem> get items;
  @override
  String get notes;
  @override
  String get terms;
  @override
  String? get status;

  /// Create a copy of Estimate
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$EstimateImplCopyWith<_$EstimateImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
