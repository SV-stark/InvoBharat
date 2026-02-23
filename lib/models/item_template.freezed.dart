// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'item_template.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$ItemTemplate {

 String get id; String get description; String get unit; double get amount; double get gstRate; String get codeType; String get sacCode; double get quantity;
/// Create a copy of ItemTemplate
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ItemTemplateCopyWith<ItemTemplate> get copyWith => _$ItemTemplateCopyWithImpl<ItemTemplate>(this as ItemTemplate, _$identity);

  /// Serializes this ItemTemplate to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ItemTemplate&&(identical(other.id, id) || other.id == id)&&(identical(other.description, description) || other.description == description)&&(identical(other.unit, unit) || other.unit == unit)&&(identical(other.amount, amount) || other.amount == amount)&&(identical(other.gstRate, gstRate) || other.gstRate == gstRate)&&(identical(other.codeType, codeType) || other.codeType == codeType)&&(identical(other.sacCode, sacCode) || other.sacCode == sacCode)&&(identical(other.quantity, quantity) || other.quantity == quantity));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,description,unit,amount,gstRate,codeType,sacCode,quantity);

@override
String toString() {
  return 'ItemTemplate(id: $id, description: $description, unit: $unit, amount: $amount, gstRate: $gstRate, codeType: $codeType, sacCode: $sacCode, quantity: $quantity)';
}


}

/// @nodoc
abstract mixin class $ItemTemplateCopyWith<$Res>  {
  factory $ItemTemplateCopyWith(ItemTemplate value, $Res Function(ItemTemplate) _then) = _$ItemTemplateCopyWithImpl;
@useResult
$Res call({
 String id, String description, String unit, double amount, double gstRate, String codeType, String sacCode, double quantity
});




}
/// @nodoc
class _$ItemTemplateCopyWithImpl<$Res>
    implements $ItemTemplateCopyWith<$Res> {
  _$ItemTemplateCopyWithImpl(this._self, this._then);

  final ItemTemplate _self;
  final $Res Function(ItemTemplate) _then;

/// Create a copy of ItemTemplate
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? description = null,Object? unit = null,Object? amount = null,Object? gstRate = null,Object? codeType = null,Object? sacCode = null,Object? quantity = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,description: null == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String,unit: null == unit ? _self.unit : unit // ignore: cast_nullable_to_non_nullable
as String,amount: null == amount ? _self.amount : amount // ignore: cast_nullable_to_non_nullable
as double,gstRate: null == gstRate ? _self.gstRate : gstRate // ignore: cast_nullable_to_non_nullable
as double,codeType: null == codeType ? _self.codeType : codeType // ignore: cast_nullable_to_non_nullable
as String,sacCode: null == sacCode ? _self.sacCode : sacCode // ignore: cast_nullable_to_non_nullable
as String,quantity: null == quantity ? _self.quantity : quantity // ignore: cast_nullable_to_non_nullable
as double,
  ));
}

}


/// Adds pattern-matching-related methods to [ItemTemplate].
extension ItemTemplatePatterns on ItemTemplate {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ItemTemplate value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ItemTemplate() when $default != null:
return $default(_that);case _:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ItemTemplate value)  $default,){
final _that = this;
switch (_that) {
case _ItemTemplate():
return $default(_that);case _:
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ItemTemplate value)?  $default,){
final _that = this;
switch (_that) {
case _ItemTemplate() when $default != null:
return $default(_that);case _:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String description,  String unit,  double amount,  double gstRate,  String codeType,  String sacCode,  double quantity)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ItemTemplate() when $default != null:
return $default(_that.id,_that.description,_that.unit,_that.amount,_that.gstRate,_that.codeType,_that.sacCode,_that.quantity);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String description,  String unit,  double amount,  double gstRate,  String codeType,  String sacCode,  double quantity)  $default,) {final _that = this;
switch (_that) {
case _ItemTemplate():
return $default(_that.id,_that.description,_that.unit,_that.amount,_that.gstRate,_that.codeType,_that.sacCode,_that.quantity);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String description,  String unit,  double amount,  double gstRate,  String codeType,  String sacCode,  double quantity)?  $default,) {final _that = this;
switch (_that) {
case _ItemTemplate() when $default != null:
return $default(_that.id,_that.description,_that.unit,_that.amount,_that.gstRate,_that.codeType,_that.sacCode,_that.quantity);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _ItemTemplate implements ItemTemplate {
  const _ItemTemplate({required this.id, required this.description, required this.unit, this.amount = 0.0, this.gstRate = 18.0, this.codeType = 'SAC', this.sacCode = '', this.quantity = 1.0});
  factory _ItemTemplate.fromJson(Map<String, dynamic> json) => _$ItemTemplateFromJson(json);

@override final  String id;
@override final  String description;
@override final  String unit;
@override@JsonKey() final  double amount;
@override@JsonKey() final  double gstRate;
@override@JsonKey() final  String codeType;
@override@JsonKey() final  String sacCode;
@override@JsonKey() final  double quantity;

/// Create a copy of ItemTemplate
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ItemTemplateCopyWith<_ItemTemplate> get copyWith => __$ItemTemplateCopyWithImpl<_ItemTemplate>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ItemTemplateToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ItemTemplate&&(identical(other.id, id) || other.id == id)&&(identical(other.description, description) || other.description == description)&&(identical(other.unit, unit) || other.unit == unit)&&(identical(other.amount, amount) || other.amount == amount)&&(identical(other.gstRate, gstRate) || other.gstRate == gstRate)&&(identical(other.codeType, codeType) || other.codeType == codeType)&&(identical(other.sacCode, sacCode) || other.sacCode == sacCode)&&(identical(other.quantity, quantity) || other.quantity == quantity));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,description,unit,amount,gstRate,codeType,sacCode,quantity);

@override
String toString() {
  return 'ItemTemplate(id: $id, description: $description, unit: $unit, amount: $amount, gstRate: $gstRate, codeType: $codeType, sacCode: $sacCode, quantity: $quantity)';
}


}

/// @nodoc
abstract mixin class _$ItemTemplateCopyWith<$Res> implements $ItemTemplateCopyWith<$Res> {
  factory _$ItemTemplateCopyWith(_ItemTemplate value, $Res Function(_ItemTemplate) _then) = __$ItemTemplateCopyWithImpl;
@override @useResult
$Res call({
 String id, String description, String unit, double amount, double gstRate, String codeType, String sacCode, double quantity
});




}
/// @nodoc
class __$ItemTemplateCopyWithImpl<$Res>
    implements _$ItemTemplateCopyWith<$Res> {
  __$ItemTemplateCopyWithImpl(this._self, this._then);

  final _ItemTemplate _self;
  final $Res Function(_ItemTemplate) _then;

/// Create a copy of ItemTemplate
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? description = null,Object? unit = null,Object? amount = null,Object? gstRate = null,Object? codeType = null,Object? sacCode = null,Object? quantity = null,}) {
  return _then(_ItemTemplate(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,description: null == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String,unit: null == unit ? _self.unit : unit // ignore: cast_nullable_to_non_nullable
as String,amount: null == amount ? _self.amount : amount // ignore: cast_nullable_to_non_nullable
as double,gstRate: null == gstRate ? _self.gstRate : gstRate // ignore: cast_nullable_to_non_nullable
as double,codeType: null == codeType ? _self.codeType : codeType // ignore: cast_nullable_to_non_nullable
as String,sacCode: null == sacCode ? _self.sacCode : sacCode // ignore: cast_nullable_to_non_nullable
as String,quantity: null == quantity ? _self.quantity : quantity // ignore: cast_nullable_to_non_nullable
as double,
  ));
}


}

// dart format on
