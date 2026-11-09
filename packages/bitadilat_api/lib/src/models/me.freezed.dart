// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'me.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$Me {

@JsonKey(fromJson: idFromJson) String get id; String get fullName; String get email; String get phone; String get locale; UserMode get lastMode; bool get isAdmin; String get status; ProSummary? get pro;
/// Create a copy of Me
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$MeCopyWith<Me> get copyWith => _$MeCopyWithImpl<Me>(this as Me, _$identity);

  /// Serializes this Me to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Me&&(identical(other.id, id) || other.id == id)&&(identical(other.fullName, fullName) || other.fullName == fullName)&&(identical(other.email, email) || other.email == email)&&(identical(other.phone, phone) || other.phone == phone)&&(identical(other.locale, locale) || other.locale == locale)&&(identical(other.lastMode, lastMode) || other.lastMode == lastMode)&&(identical(other.isAdmin, isAdmin) || other.isAdmin == isAdmin)&&(identical(other.status, status) || other.status == status)&&(identical(other.pro, pro) || other.pro == pro));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,fullName,email,phone,locale,lastMode,isAdmin,status,pro);

@override
String toString() {
  return 'Me(id: $id, fullName: $fullName, email: $email, phone: $phone, locale: $locale, lastMode: $lastMode, isAdmin: $isAdmin, status: $status, pro: $pro)';
}


}

/// @nodoc
abstract mixin class $MeCopyWith<$Res>  {
  factory $MeCopyWith(Me value, $Res Function(Me) _then) = _$MeCopyWithImpl;
@useResult
$Res call({
@JsonKey(fromJson: idFromJson) String id, String fullName, String email, String phone, String locale, UserMode lastMode, bool isAdmin, String status, ProSummary? pro
});


$ProSummaryCopyWith<$Res>? get pro;

}
/// @nodoc
class _$MeCopyWithImpl<$Res>
    implements $MeCopyWith<$Res> {
  _$MeCopyWithImpl(this._self, this._then);

  final Me _self;
  final $Res Function(Me) _then;

/// Create a copy of Me
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? fullName = null,Object? email = null,Object? phone = null,Object? locale = null,Object? lastMode = null,Object? isAdmin = null,Object? status = null,Object? pro = freezed,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,fullName: null == fullName ? _self.fullName : fullName // ignore: cast_nullable_to_non_nullable
as String,email: null == email ? _self.email : email // ignore: cast_nullable_to_non_nullable
as String,phone: null == phone ? _self.phone : phone // ignore: cast_nullable_to_non_nullable
as String,locale: null == locale ? _self.locale : locale // ignore: cast_nullable_to_non_nullable
as String,lastMode: null == lastMode ? _self.lastMode : lastMode // ignore: cast_nullable_to_non_nullable
as UserMode,isAdmin: null == isAdmin ? _self.isAdmin : isAdmin // ignore: cast_nullable_to_non_nullable
as bool,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as String,pro: freezed == pro ? _self.pro : pro // ignore: cast_nullable_to_non_nullable
as ProSummary?,
  ));
}
/// Create a copy of Me
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$ProSummaryCopyWith<$Res>? get pro {
    if (_self.pro == null) {
    return null;
  }

  return $ProSummaryCopyWith<$Res>(_self.pro!, (value) {
    return _then(_self.copyWith(pro: value));
  });
}
}


/// Adds pattern-matching-related methods to [Me].
extension MePatterns on Me {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _Me value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _Me() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _Me value)  $default,){
final _that = this;
switch (_that) {
case _Me():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _Me value)?  $default,){
final _that = this;
switch (_that) {
case _Me() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function(@JsonKey(fromJson: idFromJson)  String id,  String fullName,  String email,  String phone,  String locale,  UserMode lastMode,  bool isAdmin,  String status,  ProSummary? pro)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Me() when $default != null:
return $default(_that.id,_that.fullName,_that.email,_that.phone,_that.locale,_that.lastMode,_that.isAdmin,_that.status,_that.pro);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function(@JsonKey(fromJson: idFromJson)  String id,  String fullName,  String email,  String phone,  String locale,  UserMode lastMode,  bool isAdmin,  String status,  ProSummary? pro)  $default,) {final _that = this;
switch (_that) {
case _Me():
return $default(_that.id,_that.fullName,_that.email,_that.phone,_that.locale,_that.lastMode,_that.isAdmin,_that.status,_that.pro);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function(@JsonKey(fromJson: idFromJson)  String id,  String fullName,  String email,  String phone,  String locale,  UserMode lastMode,  bool isAdmin,  String status,  ProSummary? pro)?  $default,) {final _that = this;
switch (_that) {
case _Me() when $default != null:
return $default(_that.id,_that.fullName,_that.email,_that.phone,_that.locale,_that.lastMode,_that.isAdmin,_that.status,_that.pro);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _Me implements Me {
  const _Me({@JsonKey(fromJson: idFromJson) required this.id, required this.fullName, required this.email, required this.phone, required this.locale, required this.lastMode, required this.isAdmin, required this.status, this.pro});
  factory _Me.fromJson(Map<String, dynamic> json) => _$MeFromJson(json);

@override@JsonKey(fromJson: idFromJson) final  String id;
@override final  String fullName;
@override final  String email;
@override final  String phone;
@override final  String locale;
@override final  UserMode lastMode;
@override final  bool isAdmin;
@override final  String status;
@override final  ProSummary? pro;

/// Create a copy of Me
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$MeCopyWith<_Me> get copyWith => __$MeCopyWithImpl<_Me>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$MeToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _Me&&(identical(other.id, id) || other.id == id)&&(identical(other.fullName, fullName) || other.fullName == fullName)&&(identical(other.email, email) || other.email == email)&&(identical(other.phone, phone) || other.phone == phone)&&(identical(other.locale, locale) || other.locale == locale)&&(identical(other.lastMode, lastMode) || other.lastMode == lastMode)&&(identical(other.isAdmin, isAdmin) || other.isAdmin == isAdmin)&&(identical(other.status, status) || other.status == status)&&(identical(other.pro, pro) || other.pro == pro));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,fullName,email,phone,locale,lastMode,isAdmin,status,pro);

@override
String toString() {
  return 'Me(id: $id, fullName: $fullName, email: $email, phone: $phone, locale: $locale, lastMode: $lastMode, isAdmin: $isAdmin, status: $status, pro: $pro)';
}


}

/// @nodoc
abstract mixin class _$MeCopyWith<$Res> implements $MeCopyWith<$Res> {
  factory _$MeCopyWith(_Me value, $Res Function(_Me) _then) = __$MeCopyWithImpl;
@override @useResult
$Res call({
@JsonKey(fromJson: idFromJson) String id, String fullName, String email, String phone, String locale, UserMode lastMode, bool isAdmin, String status, ProSummary? pro
});


@override $ProSummaryCopyWith<$Res>? get pro;

}
/// @nodoc
class __$MeCopyWithImpl<$Res>
    implements _$MeCopyWith<$Res> {
  __$MeCopyWithImpl(this._self, this._then);

  final _Me _self;
  final $Res Function(_Me) _then;

/// Create a copy of Me
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? fullName = null,Object? email = null,Object? phone = null,Object? locale = null,Object? lastMode = null,Object? isAdmin = null,Object? status = null,Object? pro = freezed,}) {
  return _then(_Me(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,fullName: null == fullName ? _self.fullName : fullName // ignore: cast_nullable_to_non_nullable
as String,email: null == email ? _self.email : email // ignore: cast_nullable_to_non_nullable
as String,phone: null == phone ? _self.phone : phone // ignore: cast_nullable_to_non_nullable
as String,locale: null == locale ? _self.locale : locale // ignore: cast_nullable_to_non_nullable
as String,lastMode: null == lastMode ? _self.lastMode : lastMode // ignore: cast_nullable_to_non_nullable
as UserMode,isAdmin: null == isAdmin ? _self.isAdmin : isAdmin // ignore: cast_nullable_to_non_nullable
as bool,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as String,pro: freezed == pro ? _self.pro : pro // ignore: cast_nullable_to_non_nullable
as ProSummary?,
  ));
}

/// Create a copy of Me
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$ProSummaryCopyWith<$Res>? get pro {
    if (_self.pro == null) {
    return null;
  }

  return $ProSummaryCopyWith<$Res>(_self.pro!, (value) {
    return _then(_self.copyWith(pro: value));
  });
}
}

// dart format on
