// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'client.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$Client {
  String get id;
  String get name;
  String get profileId;
  String get gstin;
  String get address;
  String get email;
  String get phone;
  String get primaryContact;
  String get notes;
  String get state;
  String get pan;
  String get stateCode;

  /// Create a copy of Client
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $ClientCopyWith<Client> get copyWith =>
      _$ClientCopyWithImpl<Client>(this as Client, _$identity);

  /// Serializes this Client to a JSON map.
  Map<String, dynamic> toJson();

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is Client &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.profileId, profileId) ||
                other.profileId == profileId) &&
            (identical(other.gstin, gstin) || other.gstin == gstin) &&
            (identical(other.address, address) || other.address == address) &&
            (identical(other.email, email) || other.email == email) &&
            (identical(other.phone, phone) || other.phone == phone) &&
            (identical(other.primaryContact, primaryContact) ||
                other.primaryContact == primaryContact) &&
            (identical(other.notes, notes) || other.notes == notes) &&
            (identical(other.state, state) || other.state == state) &&
            (identical(other.pan, pan) || other.pan == pan) &&
            (identical(other.stateCode, stateCode) ||
                other.stateCode == stateCode));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, id, name, profileId, gstin,
      address, email, phone, primaryContact, notes, state, pan, stateCode);

  @override
  String toString() {
    return 'Client(id: $id, name: $name, profileId: $profileId, gstin: $gstin, address: $address, email: $email, phone: $phone, primaryContact: $primaryContact, notes: $notes, state: $state, pan: $pan, stateCode: $stateCode)';
  }
}

/// @nodoc
abstract mixin class $ClientCopyWith<$Res> {
  factory $ClientCopyWith(Client value, $Res Function(Client) _then) =
      _$ClientCopyWithImpl;
  @useResult
  $Res call(
      {String id,
      String name,
      String profileId,
      String gstin,
      String address,
      String email,
      String phone,
      String primaryContact,
      String notes,
      String state,
      String pan,
      String stateCode});
}

/// @nodoc
class _$ClientCopyWithImpl<$Res> implements $ClientCopyWith<$Res> {
  _$ClientCopyWithImpl(this._self, this._then);

  final Client _self;
  final $Res Function(Client) _then;

  /// Create a copy of Client
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? name = null,
    Object? profileId = null,
    Object? gstin = null,
    Object? address = null,
    Object? email = null,
    Object? phone = null,
    Object? primaryContact = null,
    Object? notes = null,
    Object? state = null,
    Object? pan = null,
    Object? stateCode = null,
  }) {
    return _then(_self.copyWith(
      id: null == id
          ? _self.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      name: null == name
          ? _self.name
          : name // ignore: cast_nullable_to_non_nullable
              as String,
      profileId: null == profileId
          ? _self.profileId
          : profileId // ignore: cast_nullable_to_non_nullable
              as String,
      gstin: null == gstin
          ? _self.gstin
          : gstin // ignore: cast_nullable_to_non_nullable
              as String,
      address: null == address
          ? _self.address
          : address // ignore: cast_nullable_to_non_nullable
              as String,
      email: null == email
          ? _self.email
          : email // ignore: cast_nullable_to_non_nullable
              as String,
      phone: null == phone
          ? _self.phone
          : phone // ignore: cast_nullable_to_non_nullable
              as String,
      primaryContact: null == primaryContact
          ? _self.primaryContact
          : primaryContact // ignore: cast_nullable_to_non_nullable
              as String,
      notes: null == notes
          ? _self.notes
          : notes // ignore: cast_nullable_to_non_nullable
              as String,
      state: null == state
          ? _self.state
          : state // ignore: cast_nullable_to_non_nullable
              as String,
      pan: null == pan
          ? _self.pan
          : pan // ignore: cast_nullable_to_non_nullable
              as String,
      stateCode: null == stateCode
          ? _self.stateCode
          : stateCode // ignore: cast_nullable_to_non_nullable
              as String,
    ));
  }
}

/// Adds pattern-matching-related methods to [Client].
extension ClientPatterns on Client {
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
    TResult Function(_Client value)? $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _Client() when $default != null:
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
    TResult Function(_Client value) $default,
  ) {
    final _that = this;
    switch (_that) {
      case _Client():
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
    TResult? Function(_Client value)? $default,
  ) {
    final _that = this;
    switch (_that) {
      case _Client() when $default != null:
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
            String name,
            String profileId,
            String gstin,
            String address,
            String email,
            String phone,
            String primaryContact,
            String notes,
            String state,
            String pan,
            String stateCode)?
        $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _Client() when $default != null:
        return $default(
            _that.id,
            _that.name,
            _that.profileId,
            _that.gstin,
            _that.address,
            _that.email,
            _that.phone,
            _that.primaryContact,
            _that.notes,
            _that.state,
            _that.pan,
            _that.stateCode);
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
            String name,
            String profileId,
            String gstin,
            String address,
            String email,
            String phone,
            String primaryContact,
            String notes,
            String state,
            String pan,
            String stateCode)
        $default,
  ) {
    final _that = this;
    switch (_that) {
      case _Client():
        return $default(
            _that.id,
            _that.name,
            _that.profileId,
            _that.gstin,
            _that.address,
            _that.email,
            _that.phone,
            _that.primaryContact,
            _that.notes,
            _that.state,
            _that.pan,
            _that.stateCode);
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
            String name,
            String profileId,
            String gstin,
            String address,
            String email,
            String phone,
            String primaryContact,
            String notes,
            String state,
            String pan,
            String stateCode)?
        $default,
  ) {
    final _that = this;
    switch (_that) {
      case _Client() when $default != null:
        return $default(
            _that.id,
            _that.name,
            _that.profileId,
            _that.gstin,
            _that.address,
            _that.email,
            _that.phone,
            _that.primaryContact,
            _that.notes,
            _that.state,
            _that.pan,
            _that.stateCode);
      case _:
        return null;
    }
  }
}

/// @nodoc
@JsonSerializable()
class _Client implements Client {
  const _Client(
      {required this.id,
      required this.name,
      this.profileId = 'default',
      this.gstin = '',
      this.address = '',
      this.email = '',
      this.phone = '',
      this.primaryContact = '',
      this.notes = '',
      this.state = '',
      this.pan = '',
      this.stateCode = ''});
  factory _Client.fromJson(Map<String, dynamic> json) => _$ClientFromJson(json);

  @override
  final String id;
  @override
  final String name;
  @override
  @JsonKey()
  final String profileId;
  @override
  @JsonKey()
  final String gstin;
  @override
  @JsonKey()
  final String address;
  @override
  @JsonKey()
  final String email;
  @override
  @JsonKey()
  final String phone;
  @override
  @JsonKey()
  final String primaryContact;
  @override
  @JsonKey()
  final String notes;
  @override
  @JsonKey()
  final String state;
  @override
  @JsonKey()
  final String pan;
  @override
  @JsonKey()
  final String stateCode;

  /// Create a copy of Client
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  _$ClientCopyWith<_Client> get copyWith =>
      __$ClientCopyWithImpl<_Client>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$ClientToJson(
      this,
    );
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _Client &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.profileId, profileId) ||
                other.profileId == profileId) &&
            (identical(other.gstin, gstin) || other.gstin == gstin) &&
            (identical(other.address, address) || other.address == address) &&
            (identical(other.email, email) || other.email == email) &&
            (identical(other.phone, phone) || other.phone == phone) &&
            (identical(other.primaryContact, primaryContact) ||
                other.primaryContact == primaryContact) &&
            (identical(other.notes, notes) || other.notes == notes) &&
            (identical(other.state, state) || other.state == state) &&
            (identical(other.pan, pan) || other.pan == pan) &&
            (identical(other.stateCode, stateCode) ||
                other.stateCode == stateCode));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, id, name, profileId, gstin,
      address, email, phone, primaryContact, notes, state, pan, stateCode);

  @override
  String toString() {
    return 'Client(id: $id, name: $name, profileId: $profileId, gstin: $gstin, address: $address, email: $email, phone: $phone, primaryContact: $primaryContact, notes: $notes, state: $state, pan: $pan, stateCode: $stateCode)';
  }
}

/// @nodoc
abstract mixin class _$ClientCopyWith<$Res> implements $ClientCopyWith<$Res> {
  factory _$ClientCopyWith(_Client value, $Res Function(_Client) _then) =
      __$ClientCopyWithImpl;
  @override
  @useResult
  $Res call(
      {String id,
      String name,
      String profileId,
      String gstin,
      String address,
      String email,
      String phone,
      String primaryContact,
      String notes,
      String state,
      String pan,
      String stateCode});
}

/// @nodoc
class __$ClientCopyWithImpl<$Res> implements _$ClientCopyWith<$Res> {
  __$ClientCopyWithImpl(this._self, this._then);

  final _Client _self;
  final $Res Function(_Client) _then;

  /// Create a copy of Client
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $Res call({
    Object? id = null,
    Object? name = null,
    Object? profileId = null,
    Object? gstin = null,
    Object? address = null,
    Object? email = null,
    Object? phone = null,
    Object? primaryContact = null,
    Object? notes = null,
    Object? state = null,
    Object? pan = null,
    Object? stateCode = null,
  }) {
    return _then(_Client(
      id: null == id
          ? _self.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      name: null == name
          ? _self.name
          : name // ignore: cast_nullable_to_non_nullable
              as String,
      profileId: null == profileId
          ? _self.profileId
          : profileId // ignore: cast_nullable_to_non_nullable
              as String,
      gstin: null == gstin
          ? _self.gstin
          : gstin // ignore: cast_nullable_to_non_nullable
              as String,
      address: null == address
          ? _self.address
          : address // ignore: cast_nullable_to_non_nullable
              as String,
      email: null == email
          ? _self.email
          : email // ignore: cast_nullable_to_non_nullable
              as String,
      phone: null == phone
          ? _self.phone
          : phone // ignore: cast_nullable_to_non_nullable
              as String,
      primaryContact: null == primaryContact
          ? _self.primaryContact
          : primaryContact // ignore: cast_nullable_to_non_nullable
              as String,
      notes: null == notes
          ? _self.notes
          : notes // ignore: cast_nullable_to_non_nullable
              as String,
      state: null == state
          ? _self.state
          : state // ignore: cast_nullable_to_non_nullable
              as String,
      pan: null == pan
          ? _self.pan
          : pan // ignore: cast_nullable_to_non_nullable
              as String,
      stateCode: null == stateCode
          ? _self.stateCode
          : stateCode // ignore: cast_nullable_to_non_nullable
              as String,
    ));
  }
}

// dart format on
