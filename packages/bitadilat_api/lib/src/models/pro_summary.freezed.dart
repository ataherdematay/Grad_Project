// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'pro_summary.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$ProSummary {

 ReviewStatus get reviewStatus; ProAvailability get availability; String? get businessName;
/// Create a copy of ProSummary
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ProSummaryCopyWith<ProSummary> get copyWith => _$ProSummaryCopyWithImpl<ProSummary>(this as ProSummary, _$identity);

  /// Serializes this ProSummary to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ProSummary&&(identical(other.reviewStatus, reviewStatus) || other.reviewStatus == reviewStatus)&&(identical(other.availability, availability) || other.availability == availability)&&(identical(other.businessName, businessName) || other.businessName == businessName));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,reviewStatus,availability,businessName);

@override
String toString() {
  return 'ProSummary(reviewStatus: $reviewStatus, availability: $availability, businessName: $businessName)';
}


}

/// @nodoc
abstract mixin class $ProSummaryCopyWith<$Res>  {
  factory $ProSummaryCopyWith(ProSummary value, $Res Function(ProSummary) _then) = _$ProSummaryCopyWithImpl;
@useResult
$Res call({
 ReviewStatus reviewStatus, ProAvailability availability, String? businessName
});




}
/// @nodoc
class _$ProSummaryCopyWithImpl<$Res>
    implements $ProSummaryCopyWith<$Res> {
  _$ProSummaryCopyWithImpl(this._self, this._then);

  final ProSummary _self;
  final $Res Function(ProSummary) _then;

/// Create a copy of ProSummary
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? reviewStatus = null,Object? availability = null,Object? businessName = freezed,}) {
  return _then(_self.copyWith(
reviewStatus: null == reviewStatus ? _self.reviewStatus : reviewStatus // ignore: cast_nullable_to_non_nullable
as ReviewStatus,availability: null == availability ? _self.availability : availability // ignore: cast_nullable_to_non_nullable
as ProAvailability,businessName: freezed == businessName ? _self.businessName : businessName // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [ProSummary].
extension ProSummaryPatterns on ProSummary {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ProSummary value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ProSummary() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ProSummary value)  $default,){
final _that = this;
switch (_that) {
case _ProSummary():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ProSummary value)?  $default,){
final _that = this;
switch (_that) {
case _ProSummary() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( ReviewStatus reviewStatus,  ProAvailability availability,  String? businessName)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ProSummary() when $default != null:
return $default(_that.reviewStatus,_that.availability,_that.businessName);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( ReviewStatus reviewStatus,  ProAvailability availability,  String? businessName)  $default,) {final _that = this;
switch (_that) {
case _ProSummary():
return $default(_that.reviewStatus,_that.availability,_that.businessName);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( ReviewStatus reviewStatus,  ProAvailability availability,  String? businessName)?  $default,) {final _that = this;
switch (_that) {
case _ProSummary() when $default != null:
return $default(_that.reviewStatus,_that.availability,_that.businessName);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _ProSummary implements ProSummary {
  const _ProSummary({required this.reviewStatus, required this.availability, this.businessName});
  factory _ProSummary.fromJson(Map<String, dynamic> json) => _$ProSummaryFromJson(json);

@override final  ReviewStatus reviewStatus;
@override final  ProAvailability availability;
@override final  String? businessName;

/// Create a copy of ProSummary
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ProSummaryCopyWith<_ProSummary> get copyWith => __$ProSummaryCopyWithImpl<_ProSummary>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ProSummaryToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ProSummary&&(identical(other.reviewStatus, reviewStatus) || other.reviewStatus == reviewStatus)&&(identical(other.availability, availability) || other.availability == availability)&&(identical(other.businessName, businessName) || other.businessName == businessName));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,reviewStatus,availability,businessName);

@override
String toString() {
  return 'ProSummary(reviewStatus: $reviewStatus, availability: $availability, businessName: $businessName)';
}


}

/// @nodoc
abstract mixin class _$ProSummaryCopyWith<$Res> implements $ProSummaryCopyWith<$Res> {
  factory _$ProSummaryCopyWith(_ProSummary value, $Res Function(_ProSummary) _then) = __$ProSummaryCopyWithImpl;
@override @useResult
$Res call({
 ReviewStatus reviewStatus, ProAvailability availability, String? businessName
});




}
/// @nodoc
class __$ProSummaryCopyWithImpl<$Res>
    implements _$ProSummaryCopyWith<$Res> {
  __$ProSummaryCopyWithImpl(this._self, this._then);

  final _ProSummary _self;
  final $Res Function(_ProSummary) _then;

/// Create a copy of ProSummary
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? reviewStatus = null,Object? availability = null,Object? businessName = freezed,}) {
  return _then(_ProSummary(
reviewStatus: null == reviewStatus ? _self.reviewStatus : reviewStatus // ignore: cast_nullable_to_non_nullable
as ReviewStatus,availability: null == availability ? _self.availability : availability // ignore: cast_nullable_to_non_nullable
as ProAvailability,businessName: freezed == businessName ? _self.businessName : businessName // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

// dart format on
