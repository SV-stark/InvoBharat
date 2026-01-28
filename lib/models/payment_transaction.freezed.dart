// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'payment_transaction.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$PaymentTransaction {
  String get id;
  String get invoiceId;
  DateTime get date;
  double get amount;
  String get paymentMode; // 'Cash', 'UPI', 'Bank Transfer', 'Cheque', 'Other'
  String? get notes;

  /// Create a copy of PaymentTransaction
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $PaymentTransactionCopyWith<PaymentTransaction> get copyWith =>
      _$PaymentTransactionCopyWithImpl<PaymentTransaction>(
          this as PaymentTransaction, _$identity);

  /// Serializes this PaymentTransaction to a JSON map.
  Map<String, dynamic> toJson();

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is PaymentTransaction &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.invoiceId, invoiceId) ||
                other.invoiceId == invoiceId) &&
            (identical(other.date, date) || other.date == date) &&
            (identical(other.amount, amount) || other.amount == amount) &&
            (identical(other.paymentMode, paymentMode) ||
                other.paymentMode == paymentMode) &&
            (identical(other.notes, notes) || other.notes == notes));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode =>
      Object.hash(runtimeType, id, invoiceId, date, amount, paymentMode, notes);

  @override
  String toString() {
    return 'PaymentTransaction(id: $id, invoiceId: $invoiceId, date: $date, amount: $amount, paymentMode: $paymentMode, notes: $notes)';
  }
}

/// @nodoc
abstract mixin class $PaymentTransactionCopyWith<$Res> {
  factory $PaymentTransactionCopyWith(
          PaymentTransaction value, $Res Function(PaymentTransaction) _then) =
      _$PaymentTransactionCopyWithImpl;
  @useResult
  $Res call(
      {String id,
      String invoiceId,
      DateTime date,
      double amount,
      String paymentMode,
      String? notes});
}

/// @nodoc
class _$PaymentTransactionCopyWithImpl<$Res>
    implements $PaymentTransactionCopyWith<$Res> {
  _$PaymentTransactionCopyWithImpl(this._self, this._then);

  final PaymentTransaction _self;
  final $Res Function(PaymentTransaction) _then;

  /// Create a copy of PaymentTransaction
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? invoiceId = null,
    Object? date = null,
    Object? amount = null,
    Object? paymentMode = null,
    Object? notes = freezed,
  }) {
    return _then(_self.copyWith(
      id: null == id
          ? _self.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      invoiceId: null == invoiceId
          ? _self.invoiceId
          : invoiceId // ignore: cast_nullable_to_non_nullable
              as String,
      date: null == date
          ? _self.date
          : date // ignore: cast_nullable_to_non_nullable
              as DateTime,
      amount: null == amount
          ? _self.amount
          : amount // ignore: cast_nullable_to_non_nullable
              as double,
      paymentMode: null == paymentMode
          ? _self.paymentMode
          : paymentMode // ignore: cast_nullable_to_non_nullable
              as String,
      notes: freezed == notes
          ? _self.notes
          : notes // ignore: cast_nullable_to_non_nullable
              as String?,
    ));
  }
}

/// Adds pattern-matching-related methods to [PaymentTransaction].
extension PaymentTransactionPatterns on PaymentTransaction {
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
    TResult Function(_PaymentTransaction value)? $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _PaymentTransaction() when $default != null:
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
    TResult Function(_PaymentTransaction value) $default,
  ) {
    final _that = this;
    switch (_that) {
      case _PaymentTransaction():
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
    TResult? Function(_PaymentTransaction value)? $default,
  ) {
    final _that = this;
    switch (_that) {
      case _PaymentTransaction() when $default != null:
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
    TResult Function(String id, String invoiceId, DateTime date, double amount,
            String paymentMode, String? notes)?
        $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _PaymentTransaction() when $default != null:
        return $default(_that.id, _that.invoiceId, _that.date, _that.amount,
            _that.paymentMode, _that.notes);
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
    TResult Function(String id, String invoiceId, DateTime date, double amount,
            String paymentMode, String? notes)
        $default,
  ) {
    final _that = this;
    switch (_that) {
      case _PaymentTransaction():
        return $default(_that.id, _that.invoiceId, _that.date, _that.amount,
            _that.paymentMode, _that.notes);
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
    TResult? Function(String id, String invoiceId, DateTime date, double amount,
            String paymentMode, String? notes)?
        $default,
  ) {
    final _that = this;
    switch (_that) {
      case _PaymentTransaction() when $default != null:
        return $default(_that.id, _that.invoiceId, _that.date, _that.amount,
            _that.paymentMode, _that.notes);
      case _:
        return null;
    }
  }
}

/// @nodoc
@JsonSerializable()
class _PaymentTransaction implements PaymentTransaction {
  const _PaymentTransaction(
      {required this.id,
      required this.invoiceId,
      required this.date,
      required this.amount,
      required this.paymentMode,
      this.notes});
  factory _PaymentTransaction.fromJson(Map<String, dynamic> json) =>
      _$PaymentTransactionFromJson(json);

  @override
  final String id;
  @override
  final String invoiceId;
  @override
  final DateTime date;
  @override
  final double amount;
  @override
  final String paymentMode;
// 'Cash', 'UPI', 'Bank Transfer', 'Cheque', 'Other'
  @override
  final String? notes;

  /// Create a copy of PaymentTransaction
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  _$PaymentTransactionCopyWith<_PaymentTransaction> get copyWith =>
      __$PaymentTransactionCopyWithImpl<_PaymentTransaction>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$PaymentTransactionToJson(
      this,
    );
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _PaymentTransaction &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.invoiceId, invoiceId) ||
                other.invoiceId == invoiceId) &&
            (identical(other.date, date) || other.date == date) &&
            (identical(other.amount, amount) || other.amount == amount) &&
            (identical(other.paymentMode, paymentMode) ||
                other.paymentMode == paymentMode) &&
            (identical(other.notes, notes) || other.notes == notes));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode =>
      Object.hash(runtimeType, id, invoiceId, date, amount, paymentMode, notes);

  @override
  String toString() {
    return 'PaymentTransaction(id: $id, invoiceId: $invoiceId, date: $date, amount: $amount, paymentMode: $paymentMode, notes: $notes)';
  }
}

/// @nodoc
abstract mixin class _$PaymentTransactionCopyWith<$Res>
    implements $PaymentTransactionCopyWith<$Res> {
  factory _$PaymentTransactionCopyWith(
          _PaymentTransaction value, $Res Function(_PaymentTransaction) _then) =
      __$PaymentTransactionCopyWithImpl;
  @override
  @useResult
  $Res call(
      {String id,
      String invoiceId,
      DateTime date,
      double amount,
      String paymentMode,
      String? notes});
}

/// @nodoc
class __$PaymentTransactionCopyWithImpl<$Res>
    implements _$PaymentTransactionCopyWith<$Res> {
  __$PaymentTransactionCopyWithImpl(this._self, this._then);

  final _PaymentTransaction _self;
  final $Res Function(_PaymentTransaction) _then;

  /// Create a copy of PaymentTransaction
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $Res call({
    Object? id = null,
    Object? invoiceId = null,
    Object? date = null,
    Object? amount = null,
    Object? paymentMode = null,
    Object? notes = freezed,
  }) {
    return _then(_PaymentTransaction(
      id: null == id
          ? _self.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      invoiceId: null == invoiceId
          ? _self.invoiceId
          : invoiceId // ignore: cast_nullable_to_non_nullable
              as String,
      date: null == date
          ? _self.date
          : date // ignore: cast_nullable_to_non_nullable
              as DateTime,
      amount: null == amount
          ? _self.amount
          : amount // ignore: cast_nullable_to_non_nullable
              as double,
      paymentMode: null == paymentMode
          ? _self.paymentMode
          : paymentMode // ignore: cast_nullable_to_non_nullable
              as String,
      notes: freezed == notes
          ? _self.notes
          : notes // ignore: cast_nullable_to_non_nullable
              as String?,
    ));
  }
}

// dart format on
