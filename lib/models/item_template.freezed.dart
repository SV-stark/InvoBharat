// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'item_template.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

ItemTemplate _$ItemTemplateFromJson(Map<String, dynamic> json) {
  return _ItemTemplate.fromJson(json);
}

/// @nodoc
mixin _$ItemTemplate {
  String get id => throw _privateConstructorUsedError;
  String get description => throw _privateConstructorUsedError;
  String get unit => throw _privateConstructorUsedError;
  double get amount => throw _privateConstructorUsedError;
  double get gstRate => throw _privateConstructorUsedError;
  String get codeType => throw _privateConstructorUsedError;
  String get sacCode => throw _privateConstructorUsedError;
  double get quantity => throw _privateConstructorUsedError;

  /// Serializes this ItemTemplate to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of ItemTemplate
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $ItemTemplateCopyWith<ItemTemplate> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ItemTemplateCopyWith<$Res> {
  factory $ItemTemplateCopyWith(
          ItemTemplate value, $Res Function(ItemTemplate) then) =
      _$ItemTemplateCopyWithImpl<$Res, ItemTemplate>;
  @useResult
  $Res call(
      {String id,
      String description,
      String unit,
      double amount,
      double gstRate,
      String codeType,
      String sacCode,
      double quantity});
}

/// @nodoc
class _$ItemTemplateCopyWithImpl<$Res, $Val extends ItemTemplate>
    implements $ItemTemplateCopyWith<$Res> {
  _$ItemTemplateCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of ItemTemplate
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? description = null,
    Object? unit = null,
    Object? amount = null,
    Object? gstRate = null,
    Object? codeType = null,
    Object? sacCode = null,
    Object? quantity = null,
  }) {
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      description: null == description
          ? _value.description
          : description // ignore: cast_nullable_to_non_nullable
              as String,
      unit: null == unit
          ? _value.unit
          : unit // ignore: cast_nullable_to_non_nullable
              as String,
      amount: null == amount
          ? _value.amount
          : amount // ignore: cast_nullable_to_non_nullable
              as double,
      gstRate: null == gstRate
          ? _value.gstRate
          : gstRate // ignore: cast_nullable_to_non_nullable
              as double,
      codeType: null == codeType
          ? _value.codeType
          : codeType // ignore: cast_nullable_to_non_nullable
              as String,
      sacCode: null == sacCode
          ? _value.sacCode
          : sacCode // ignore: cast_nullable_to_non_nullable
              as String,
      quantity: null == quantity
          ? _value.quantity
          : quantity // ignore: cast_nullable_to_non_nullable
              as double,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$ItemTemplateImplCopyWith<$Res>
    implements $ItemTemplateCopyWith<$Res> {
  factory _$$ItemTemplateImplCopyWith(
          _$ItemTemplateImpl value, $Res Function(_$ItemTemplateImpl) then) =
      __$$ItemTemplateImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String id,
      String description,
      String unit,
      double amount,
      double gstRate,
      String codeType,
      String sacCode,
      double quantity});
}

/// @nodoc
class __$$ItemTemplateImplCopyWithImpl<$Res>
    extends _$ItemTemplateCopyWithImpl<$Res, _$ItemTemplateImpl>
    implements _$$ItemTemplateImplCopyWith<$Res> {
  __$$ItemTemplateImplCopyWithImpl(
      _$ItemTemplateImpl _value, $Res Function(_$ItemTemplateImpl) _then)
      : super(_value, _then);

  /// Create a copy of ItemTemplate
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? description = null,
    Object? unit = null,
    Object? amount = null,
    Object? gstRate = null,
    Object? codeType = null,
    Object? sacCode = null,
    Object? quantity = null,
  }) {
    return _then(_$ItemTemplateImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      description: null == description
          ? _value.description
          : description // ignore: cast_nullable_to_non_nullable
              as String,
      unit: null == unit
          ? _value.unit
          : unit // ignore: cast_nullable_to_non_nullable
              as String,
      amount: null == amount
          ? _value.amount
          : amount // ignore: cast_nullable_to_non_nullable
              as double,
      gstRate: null == gstRate
          ? _value.gstRate
          : gstRate // ignore: cast_nullable_to_non_nullable
              as double,
      codeType: null == codeType
          ? _value.codeType
          : codeType // ignore: cast_nullable_to_non_nullable
              as String,
      sacCode: null == sacCode
          ? _value.sacCode
          : sacCode // ignore: cast_nullable_to_non_nullable
              as String,
      quantity: null == quantity
          ? _value.quantity
          : quantity // ignore: cast_nullable_to_non_nullable
              as double,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$ItemTemplateImpl implements _ItemTemplate {
  const _$ItemTemplateImpl(
      {required this.id,
      required this.description,
      required this.unit,
      this.amount = 0.0,
      this.gstRate = 18.0,
      this.codeType = 'SAC',
      this.sacCode = '',
      this.quantity = 1.0});

  factory _$ItemTemplateImpl.fromJson(Map<String, dynamic> json) =>
      _$$ItemTemplateImplFromJson(json);

  @override
  final String id;
  @override
  final String description;
  @override
  final String unit;
  @override
  @JsonKey()
  final double amount;
  @override
  @JsonKey()
  final double gstRate;
  @override
  @JsonKey()
  final String codeType;
  @override
  @JsonKey()
  final String sacCode;
  @override
  @JsonKey()
  final double quantity;

  @override
  String toString() {
    return 'ItemTemplate(id: $id, description: $description, unit: $unit, amount: $amount, gstRate: $gstRate, codeType: $codeType, sacCode: $sacCode, quantity: $quantity)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ItemTemplateImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.description, description) ||
                other.description == description) &&
            (identical(other.unit, unit) || other.unit == unit) &&
            (identical(other.amount, amount) || other.amount == amount) &&
            (identical(other.gstRate, gstRate) || other.gstRate == gstRate) &&
            (identical(other.codeType, codeType) ||
                other.codeType == codeType) &&
            (identical(other.sacCode, sacCode) || other.sacCode == sacCode) &&
            (identical(other.quantity, quantity) ||
                other.quantity == quantity));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, id, description, unit, amount,
      gstRate, codeType, sacCode, quantity);

  /// Create a copy of ItemTemplate
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$ItemTemplateImplCopyWith<_$ItemTemplateImpl> get copyWith =>
      __$$ItemTemplateImplCopyWithImpl<_$ItemTemplateImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$ItemTemplateImplToJson(
      this,
    );
  }
}

abstract class _ItemTemplate implements ItemTemplate {
  const factory _ItemTemplate(
      {required final String id,
      required final String description,
      required final String unit,
      final double amount,
      final double gstRate,
      final String codeType,
      final String sacCode,
      final double quantity}) = _$ItemTemplateImpl;

  factory _ItemTemplate.fromJson(Map<String, dynamic> json) =
      _$ItemTemplateImpl.fromJson;

  @override
  String get id;
  @override
  String get description;
  @override
  String get unit;
  @override
  double get amount;
  @override
  double get gstRate;
  @override
  String get codeType;
  @override
  String get sacCode;
  @override
  double get quantity;

  /// Create a copy of ItemTemplate
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$ItemTemplateImplCopyWith<_$ItemTemplateImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
