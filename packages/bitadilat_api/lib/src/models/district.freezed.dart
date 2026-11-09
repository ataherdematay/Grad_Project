// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'district.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$District {

@JsonKey(fromJson: idFromJson) String get id; String get name;/// `ANADOLU` veya `AVRUPA`.
 String get side;
/// Create a copy of District
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$DistrictCopyWith<District> get copyWith => _$DistrictCopyWithImpl<District>(this as District, _$identity);

  /// Serializes this District to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is District&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.side, side) || other.side == side));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,name,side);

@override
String toString() {
  return 'District(id: $id, name: $name, side: $side)';
}


}

/// @nodoc
abstract mixin class $DistrictCopyWith<$Res>  {
  factory $DistrictCopyWith(District value, $Res Function(District) _then) = _$DistrictCopyWithImpl;
@useResult
$Res call({
@JsonKey(fromJson: idFromJson) String id, String name, String side
});




}
/// @nodoc
class _$DistrictCopyWithImpl<$Res>
    implements $DistrictCopyWith<$Res> {
  _$DistrictCopyWithImpl(this._self, this._then);

  final District _self;
  final $Res Function(District) _then;

/// Create a copy of District
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? name = null,Object? side = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,side: null == side ? _self.side : side // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [District].
extension DistrictPatterns on District {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _District value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _District() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _District value)  $default,){
final _that = this;
switch (_that) {
case _District():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _District value)?  $default,){
final _that = this;
switch (_that) {
case _District() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function(@JsonKey(fromJson: idFromJson)  String id,  String name,  String side)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _District() when $default != null:
return $default(_that.id,_that.name,_that.side);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function(@JsonKey(fromJson: idFromJson)  String id,  String name,  String side)  $default,) {final _that = this;
switch (_that) {
case _District():
return $default(_that.id,_that.name,_that.side);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function(@JsonKey(fromJson: idFromJson)  String id,  String name,  String side)?  $default,) {final _that = this;
switch (_that) {
case _District() when $default != null:
return $default(_that.id,_that.name,_that.side);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _District implements District {
  const _District({@JsonKey(fromJson: idFromJson) required this.id, required this.name, required this.side});
  factory _District.fromJson(Map<String, dynamic> json) => _$DistrictFromJson(json);

@override@JsonKey(fromJson: idFromJson) final  String id;
@override final  String name;
/// `ANADOLU` veya `AVRUPA`.
@override final  String side;

/// Create a copy of District
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$DistrictCopyWith<_District> get copyWith => __$DistrictCopyWithImpl<_District>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$DistrictToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _District&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.side, side) || other.side == side));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,name,side);

@override
String toString() {
  return 'District(id: $id, name: $name, side: $side)';
}


}

/// @nodoc
abstract mixin class _$DistrictCopyWith<$Res> implements $DistrictCopyWith<$Res> {
  factory _$DistrictCopyWith(_District value, $Res Function(_District) _then) = __$DistrictCopyWithImpl;
@override @useResult
$Res call({
@JsonKey(fromJson: idFromJson) String id, String name, String side
});




}
/// @nodoc
class __$DistrictCopyWithImpl<$Res>
    implements _$DistrictCopyWith<$Res> {
  __$DistrictCopyWithImpl(this._self, this._then);

  final _District _self;
  final $Res Function(_District) _then;

/// Create a copy of District
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? name = null,Object? side = null,}) {
  return _then(_District(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,side: null == side ? _self.side : side // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

// dart format on
