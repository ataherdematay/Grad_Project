// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'address.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$Address {

@JsonKey(fromJson: idFromJson) String get id; String get label;@JsonKey(fromJson: idFromJson) String get districtId; String get districtName; String get neighborhood; String get lineFull; String? get doorNote; bool get isDefault;
/// Create a copy of Address
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$AddressCopyWith<Address> get copyWith => _$AddressCopyWithImpl<Address>(this as Address, _$identity);

  /// Serializes this Address to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Address&&(identical(other.id, id) || other.id == id)&&(identical(other.label, label) || other.label == label)&&(identical(other.districtId, districtId) || other.districtId == districtId)&&(identical(other.districtName, districtName) || other.districtName == districtName)&&(identical(other.neighborhood, neighborhood) || other.neighborhood == neighborhood)&&(identical(other.lineFull, lineFull) || other.lineFull == lineFull)&&(identical(other.doorNote, doorNote) || other.doorNote == doorNote)&&(identical(other.isDefault, isDefault) || other.isDefault == isDefault));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,label,districtId,districtName,neighborhood,lineFull,doorNote,isDefault);

@override
String toString() {
  return 'Address(id: $id, label: $label, districtId: $districtId, districtName: $districtName, neighborhood: $neighborhood, lineFull: $lineFull, doorNote: $doorNote, isDefault: $isDefault)';
}


}

/// @nodoc
abstract mixin class $AddressCopyWith<$Res>  {
  factory $AddressCopyWith(Address value, $Res Function(Address) _then) = _$AddressCopyWithImpl;
@useResult
$Res call({
@JsonKey(fromJson: idFromJson) String id, String label,@JsonKey(fromJson: idFromJson) String districtId, String districtName, String neighborhood, String lineFull, String? doorNote, bool isDefault
});




}
/// @nodoc
class _$AddressCopyWithImpl<$Res>
    implements $AddressCopyWith<$Res> {
  _$AddressCopyWithImpl(this._self, this._then);

  final Address _self;
  final $Res Function(Address) _then;

/// Create a copy of Address
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? label = null,Object? districtId = null,Object? districtName = null,Object? neighborhood = null,Object? lineFull = null,Object? doorNote = freezed,Object? isDefault = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,label: null == label ? _self.label : label // ignore: cast_nullable_to_non_nullable
as String,districtId: null == districtId ? _self.districtId : districtId // ignore: cast_nullable_to_non_nullable
as String,districtName: null == districtName ? _self.districtName : districtName // ignore: cast_nullable_to_non_nullable
as String,neighborhood: null == neighborhood ? _self.neighborhood : neighborhood // ignore: cast_nullable_to_non_nullable
as String,lineFull: null == lineFull ? _self.lineFull : lineFull // ignore: cast_nullable_to_non_nullable
as String,doorNote: freezed == doorNote ? _self.doorNote : doorNote // ignore: cast_nullable_to_non_nullable
as String?,isDefault: null == isDefault ? _self.isDefault : isDefault // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}

}


/// Adds pattern-matching-related methods to [Address].
extension AddressPatterns on Address {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _Address value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _Address() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _Address value)  $default,){
final _that = this;
switch (_that) {
case _Address():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _Address value)?  $default,){
final _that = this;
switch (_that) {
case _Address() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function(@JsonKey(fromJson: idFromJson)  String id,  String label, @JsonKey(fromJson: idFromJson)  String districtId,  String districtName,  String neighborhood,  String lineFull,  String? doorNote,  bool isDefault)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Address() when $default != null:
return $default(_that.id,_that.label,_that.districtId,_that.districtName,_that.neighborhood,_that.lineFull,_that.doorNote,_that.isDefault);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function(@JsonKey(fromJson: idFromJson)  String id,  String label, @JsonKey(fromJson: idFromJson)  String districtId,  String districtName,  String neighborhood,  String lineFull,  String? doorNote,  bool isDefault)  $default,) {final _that = this;
switch (_that) {
case _Address():
return $default(_that.id,_that.label,_that.districtId,_that.districtName,_that.neighborhood,_that.lineFull,_that.doorNote,_that.isDefault);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function(@JsonKey(fromJson: idFromJson)  String id,  String label, @JsonKey(fromJson: idFromJson)  String districtId,  String districtName,  String neighborhood,  String lineFull,  String? doorNote,  bool isDefault)?  $default,) {final _that = this;
switch (_that) {
case _Address() when $default != null:
return $default(_that.id,_that.label,_that.districtId,_that.districtName,_that.neighborhood,_that.lineFull,_that.doorNote,_that.isDefault);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _Address implements Address {
  const _Address({@JsonKey(fromJson: idFromJson) required this.id, required this.label, @JsonKey(fromJson: idFromJson) required this.districtId, required this.districtName, required this.neighborhood, required this.lineFull, this.doorNote, required this.isDefault});
  factory _Address.fromJson(Map<String, dynamic> json) => _$AddressFromJson(json);

@override@JsonKey(fromJson: idFromJson) final  String id;
@override final  String label;
@override@JsonKey(fromJson: idFromJson) final  String districtId;
@override final  String districtName;
@override final  String neighborhood;
@override final  String lineFull;
@override final  String? doorNote;
@override final  bool isDefault;

/// Create a copy of Address
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$AddressCopyWith<_Address> get copyWith => __$AddressCopyWithImpl<_Address>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$AddressToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _Address&&(identical(other.id, id) || other.id == id)&&(identical(other.label, label) || other.label == label)&&(identical(other.districtId, districtId) || other.districtId == districtId)&&(identical(other.districtName, districtName) || other.districtName == districtName)&&(identical(other.neighborhood, neighborhood) || other.neighborhood == neighborhood)&&(identical(other.lineFull, lineFull) || other.lineFull == lineFull)&&(identical(other.doorNote, doorNote) || other.doorNote == doorNote)&&(identical(other.isDefault, isDefault) || other.isDefault == isDefault));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,label,districtId,districtName,neighborhood,lineFull,doorNote,isDefault);

@override
String toString() {
  return 'Address(id: $id, label: $label, districtId: $districtId, districtName: $districtName, neighborhood: $neighborhood, lineFull: $lineFull, doorNote: $doorNote, isDefault: $isDefault)';
}


}

/// @nodoc
abstract mixin class _$AddressCopyWith<$Res> implements $AddressCopyWith<$Res> {
  factory _$AddressCopyWith(_Address value, $Res Function(_Address) _then) = __$AddressCopyWithImpl;
@override @useResult
$Res call({
@JsonKey(fromJson: idFromJson) String id, String label,@JsonKey(fromJson: idFromJson) String districtId, String districtName, String neighborhood, String lineFull, String? doorNote, bool isDefault
});




}
/// @nodoc
class __$AddressCopyWithImpl<$Res>
    implements _$AddressCopyWith<$Res> {
  __$AddressCopyWithImpl(this._self, this._then);

  final _Address _self;
  final $Res Function(_Address) _then;

/// Create a copy of Address
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? label = null,Object? districtId = null,Object? districtName = null,Object? neighborhood = null,Object? lineFull = null,Object? doorNote = freezed,Object? isDefault = null,}) {
  return _then(_Address(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,label: null == label ? _self.label : label // ignore: cast_nullable_to_non_nullable
as String,districtId: null == districtId ? _self.districtId : districtId // ignore: cast_nullable_to_non_nullable
as String,districtName: null == districtName ? _self.districtName : districtName // ignore: cast_nullable_to_non_nullable
as String,neighborhood: null == neighborhood ? _self.neighborhood : neighborhood // ignore: cast_nullable_to_non_nullable
as String,lineFull: null == lineFull ? _self.lineFull : lineFull // ignore: cast_nullable_to_non_nullable
as String,doorNote: freezed == doorNote ? _self.doorNote : doorNote // ignore: cast_nullable_to_non_nullable
as String?,isDefault: null == isDefault ? _self.isDefault : isDefault // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}


}


/// @nodoc
mixin _$AddressInput {

 String get label;@JsonKey(fromJson: idFromJson, toJson: wireId) String get districtId; String get neighborhood; String get lineFull;@JsonKey(includeIfNull: false) String? get doorNote;@JsonKey(includeIfNull: false) bool? get isDefault;
/// Create a copy of AddressInput
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$AddressInputCopyWith<AddressInput> get copyWith => _$AddressInputCopyWithImpl<AddressInput>(this as AddressInput, _$identity);

  /// Serializes this AddressInput to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is AddressInput&&(identical(other.label, label) || other.label == label)&&(identical(other.districtId, districtId) || other.districtId == districtId)&&(identical(other.neighborhood, neighborhood) || other.neighborhood == neighborhood)&&(identical(other.lineFull, lineFull) || other.lineFull == lineFull)&&(identical(other.doorNote, doorNote) || other.doorNote == doorNote)&&(identical(other.isDefault, isDefault) || other.isDefault == isDefault));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,label,districtId,neighborhood,lineFull,doorNote,isDefault);

@override
String toString() {
  return 'AddressInput(label: $label, districtId: $districtId, neighborhood: $neighborhood, lineFull: $lineFull, doorNote: $doorNote, isDefault: $isDefault)';
}


}

/// @nodoc
abstract mixin class $AddressInputCopyWith<$Res>  {
  factory $AddressInputCopyWith(AddressInput value, $Res Function(AddressInput) _then) = _$AddressInputCopyWithImpl;
@useResult
$Res call({
 String label,@JsonKey(fromJson: idFromJson, toJson: wireId) String districtId, String neighborhood, String lineFull,@JsonKey(includeIfNull: false) String? doorNote,@JsonKey(includeIfNull: false) bool? isDefault
});




}
/// @nodoc
class _$AddressInputCopyWithImpl<$Res>
    implements $AddressInputCopyWith<$Res> {
  _$AddressInputCopyWithImpl(this._self, this._then);

  final AddressInput _self;
  final $Res Function(AddressInput) _then;

/// Create a copy of AddressInput
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? label = null,Object? districtId = null,Object? neighborhood = null,Object? lineFull = null,Object? doorNote = freezed,Object? isDefault = freezed,}) {
  return _then(_self.copyWith(
label: null == label ? _self.label : label // ignore: cast_nullable_to_non_nullable
as String,districtId: null == districtId ? _self.districtId : districtId // ignore: cast_nullable_to_non_nullable
as String,neighborhood: null == neighborhood ? _self.neighborhood : neighborhood // ignore: cast_nullable_to_non_nullable
as String,lineFull: null == lineFull ? _self.lineFull : lineFull // ignore: cast_nullable_to_non_nullable
as String,doorNote: freezed == doorNote ? _self.doorNote : doorNote // ignore: cast_nullable_to_non_nullable
as String?,isDefault: freezed == isDefault ? _self.isDefault : isDefault // ignore: cast_nullable_to_non_nullable
as bool?,
  ));
}

}


/// Adds pattern-matching-related methods to [AddressInput].
extension AddressInputPatterns on AddressInput {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _AddressInput value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _AddressInput() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _AddressInput value)  $default,){
final _that = this;
switch (_that) {
case _AddressInput():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _AddressInput value)?  $default,){
final _that = this;
switch (_that) {
case _AddressInput() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String label, @JsonKey(fromJson: idFromJson, toJson: wireId)  String districtId,  String neighborhood,  String lineFull, @JsonKey(includeIfNull: false)  String? doorNote, @JsonKey(includeIfNull: false)  bool? isDefault)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _AddressInput() when $default != null:
return $default(_that.label,_that.districtId,_that.neighborhood,_that.lineFull,_that.doorNote,_that.isDefault);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String label, @JsonKey(fromJson: idFromJson, toJson: wireId)  String districtId,  String neighborhood,  String lineFull, @JsonKey(includeIfNull: false)  String? doorNote, @JsonKey(includeIfNull: false)  bool? isDefault)  $default,) {final _that = this;
switch (_that) {
case _AddressInput():
return $default(_that.label,_that.districtId,_that.neighborhood,_that.lineFull,_that.doorNote,_that.isDefault);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String label, @JsonKey(fromJson: idFromJson, toJson: wireId)  String districtId,  String neighborhood,  String lineFull, @JsonKey(includeIfNull: false)  String? doorNote, @JsonKey(includeIfNull: false)  bool? isDefault)?  $default,) {final _that = this;
switch (_that) {
case _AddressInput() when $default != null:
return $default(_that.label,_that.districtId,_that.neighborhood,_that.lineFull,_that.doorNote,_that.isDefault);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _AddressInput implements AddressInput {
  const _AddressInput({required this.label, @JsonKey(fromJson: idFromJson, toJson: wireId) required this.districtId, required this.neighborhood, required this.lineFull, @JsonKey(includeIfNull: false) this.doorNote, @JsonKey(includeIfNull: false) this.isDefault});
  factory _AddressInput.fromJson(Map<String, dynamic> json) => _$AddressInputFromJson(json);

@override final  String label;
@override@JsonKey(fromJson: idFromJson, toJson: wireId) final  String districtId;
@override final  String neighborhood;
@override final  String lineFull;
@override@JsonKey(includeIfNull: false) final  String? doorNote;
@override@JsonKey(includeIfNull: false) final  bool? isDefault;

/// Create a copy of AddressInput
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$AddressInputCopyWith<_AddressInput> get copyWith => __$AddressInputCopyWithImpl<_AddressInput>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$AddressInputToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _AddressInput&&(identical(other.label, label) || other.label == label)&&(identical(other.districtId, districtId) || other.districtId == districtId)&&(identical(other.neighborhood, neighborhood) || other.neighborhood == neighborhood)&&(identical(other.lineFull, lineFull) || other.lineFull == lineFull)&&(identical(other.doorNote, doorNote) || other.doorNote == doorNote)&&(identical(other.isDefault, isDefault) || other.isDefault == isDefault));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,label,districtId,neighborhood,lineFull,doorNote,isDefault);

@override
String toString() {
  return 'AddressInput(label: $label, districtId: $districtId, neighborhood: $neighborhood, lineFull: $lineFull, doorNote: $doorNote, isDefault: $isDefault)';
}


}

/// @nodoc
abstract mixin class _$AddressInputCopyWith<$Res> implements $AddressInputCopyWith<$Res> {
  factory _$AddressInputCopyWith(_AddressInput value, $Res Function(_AddressInput) _then) = __$AddressInputCopyWithImpl;
@override @useResult
$Res call({
 String label,@JsonKey(fromJson: idFromJson, toJson: wireId) String districtId, String neighborhood, String lineFull,@JsonKey(includeIfNull: false) String? doorNote,@JsonKey(includeIfNull: false) bool? isDefault
});




}
/// @nodoc
class __$AddressInputCopyWithImpl<$Res>
    implements _$AddressInputCopyWith<$Res> {
  __$AddressInputCopyWithImpl(this._self, this._then);

  final _AddressInput _self;
  final $Res Function(_AddressInput) _then;

/// Create a copy of AddressInput
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? label = null,Object? districtId = null,Object? neighborhood = null,Object? lineFull = null,Object? doorNote = freezed,Object? isDefault = freezed,}) {
  return _then(_AddressInput(
label: null == label ? _self.label : label // ignore: cast_nullable_to_non_nullable
as String,districtId: null == districtId ? _self.districtId : districtId // ignore: cast_nullable_to_non_nullable
as String,neighborhood: null == neighborhood ? _self.neighborhood : neighborhood // ignore: cast_nullable_to_non_nullable
as String,lineFull: null == lineFull ? _self.lineFull : lineFull // ignore: cast_nullable_to_non_nullable
as String,doorNote: freezed == doorNote ? _self.doorNote : doorNote // ignore: cast_nullable_to_non_nullable
as String?,isDefault: freezed == isDefault ? _self.isDefault : isDefault // ignore: cast_nullable_to_non_nullable
as bool?,
  ));
}


}

// dart format on
