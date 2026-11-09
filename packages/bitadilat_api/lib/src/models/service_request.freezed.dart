// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'service_request.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$RequestAnswer {

 String get questionKey; String get answer;
/// Create a copy of RequestAnswer
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$RequestAnswerCopyWith<RequestAnswer> get copyWith => _$RequestAnswerCopyWithImpl<RequestAnswer>(this as RequestAnswer, _$identity);

  /// Serializes this RequestAnswer to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is RequestAnswer&&(identical(other.questionKey, questionKey) || other.questionKey == questionKey)&&(identical(other.answer, answer) || other.answer == answer));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,questionKey,answer);

@override
String toString() {
  return 'RequestAnswer(questionKey: $questionKey, answer: $answer)';
}


}

/// @nodoc
abstract mixin class $RequestAnswerCopyWith<$Res>  {
  factory $RequestAnswerCopyWith(RequestAnswer value, $Res Function(RequestAnswer) _then) = _$RequestAnswerCopyWithImpl;
@useResult
$Res call({
 String questionKey, String answer
});




}
/// @nodoc
class _$RequestAnswerCopyWithImpl<$Res>
    implements $RequestAnswerCopyWith<$Res> {
  _$RequestAnswerCopyWithImpl(this._self, this._then);

  final RequestAnswer _self;
  final $Res Function(RequestAnswer) _then;

/// Create a copy of RequestAnswer
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? questionKey = null,Object? answer = null,}) {
  return _then(_self.copyWith(
questionKey: null == questionKey ? _self.questionKey : questionKey // ignore: cast_nullable_to_non_nullable
as String,answer: null == answer ? _self.answer : answer // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [RequestAnswer].
extension RequestAnswerPatterns on RequestAnswer {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _RequestAnswer value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _RequestAnswer() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _RequestAnswer value)  $default,){
final _that = this;
switch (_that) {
case _RequestAnswer():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _RequestAnswer value)?  $default,){
final _that = this;
switch (_that) {
case _RequestAnswer() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String questionKey,  String answer)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _RequestAnswer() when $default != null:
return $default(_that.questionKey,_that.answer);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String questionKey,  String answer)  $default,) {final _that = this;
switch (_that) {
case _RequestAnswer():
return $default(_that.questionKey,_that.answer);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String questionKey,  String answer)?  $default,) {final _that = this;
switch (_that) {
case _RequestAnswer() when $default != null:
return $default(_that.questionKey,_that.answer);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _RequestAnswer implements RequestAnswer {
  const _RequestAnswer({required this.questionKey, required this.answer});
  factory _RequestAnswer.fromJson(Map<String, dynamic> json) => _$RequestAnswerFromJson(json);

@override final  String questionKey;
@override final  String answer;

/// Create a copy of RequestAnswer
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$RequestAnswerCopyWith<_RequestAnswer> get copyWith => __$RequestAnswerCopyWithImpl<_RequestAnswer>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$RequestAnswerToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _RequestAnswer&&(identical(other.questionKey, questionKey) || other.questionKey == questionKey)&&(identical(other.answer, answer) || other.answer == answer));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,questionKey,answer);

@override
String toString() {
  return 'RequestAnswer(questionKey: $questionKey, answer: $answer)';
}


}

/// @nodoc
abstract mixin class _$RequestAnswerCopyWith<$Res> implements $RequestAnswerCopyWith<$Res> {
  factory _$RequestAnswerCopyWith(_RequestAnswer value, $Res Function(_RequestAnswer) _then) = __$RequestAnswerCopyWithImpl;
@override @useResult
$Res call({
 String questionKey, String answer
});




}
/// @nodoc
class __$RequestAnswerCopyWithImpl<$Res>
    implements _$RequestAnswerCopyWith<$Res> {
  __$RequestAnswerCopyWithImpl(this._self, this._then);

  final _RequestAnswer _self;
  final $Res Function(_RequestAnswer) _then;

/// Create a copy of RequestAnswer
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? questionKey = null,Object? answer = null,}) {
  return _then(_RequestAnswer(
questionKey: null == questionKey ? _self.questionKey : questionKey // ignore: cast_nullable_to_non_nullable
as String,answer: null == answer ? _self.answer : answer // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}


/// @nodoc
mixin _$RequestAddress {

 String get districtName; String get neighborhood; String? get lineFull; String? get doorNote;
/// Create a copy of RequestAddress
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$RequestAddressCopyWith<RequestAddress> get copyWith => _$RequestAddressCopyWithImpl<RequestAddress>(this as RequestAddress, _$identity);

  /// Serializes this RequestAddress to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is RequestAddress&&(identical(other.districtName, districtName) || other.districtName == districtName)&&(identical(other.neighborhood, neighborhood) || other.neighborhood == neighborhood)&&(identical(other.lineFull, lineFull) || other.lineFull == lineFull)&&(identical(other.doorNote, doorNote) || other.doorNote == doorNote));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,districtName,neighborhood,lineFull,doorNote);

@override
String toString() {
  return 'RequestAddress(districtName: $districtName, neighborhood: $neighborhood, lineFull: $lineFull, doorNote: $doorNote)';
}


}

/// @nodoc
abstract mixin class $RequestAddressCopyWith<$Res>  {
  factory $RequestAddressCopyWith(RequestAddress value, $Res Function(RequestAddress) _then) = _$RequestAddressCopyWithImpl;
@useResult
$Res call({
 String districtName, String neighborhood, String? lineFull, String? doorNote
});




}
/// @nodoc
class _$RequestAddressCopyWithImpl<$Res>
    implements $RequestAddressCopyWith<$Res> {
  _$RequestAddressCopyWithImpl(this._self, this._then);

  final RequestAddress _self;
  final $Res Function(RequestAddress) _then;

/// Create a copy of RequestAddress
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? districtName = null,Object? neighborhood = null,Object? lineFull = freezed,Object? doorNote = freezed,}) {
  return _then(_self.copyWith(
districtName: null == districtName ? _self.districtName : districtName // ignore: cast_nullable_to_non_nullable
as String,neighborhood: null == neighborhood ? _self.neighborhood : neighborhood // ignore: cast_nullable_to_non_nullable
as String,lineFull: freezed == lineFull ? _self.lineFull : lineFull // ignore: cast_nullable_to_non_nullable
as String?,doorNote: freezed == doorNote ? _self.doorNote : doorNote // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [RequestAddress].
extension RequestAddressPatterns on RequestAddress {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _RequestAddress value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _RequestAddress() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _RequestAddress value)  $default,){
final _that = this;
switch (_that) {
case _RequestAddress():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _RequestAddress value)?  $default,){
final _that = this;
switch (_that) {
case _RequestAddress() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String districtName,  String neighborhood,  String? lineFull,  String? doorNote)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _RequestAddress() when $default != null:
return $default(_that.districtName,_that.neighborhood,_that.lineFull,_that.doorNote);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String districtName,  String neighborhood,  String? lineFull,  String? doorNote)  $default,) {final _that = this;
switch (_that) {
case _RequestAddress():
return $default(_that.districtName,_that.neighborhood,_that.lineFull,_that.doorNote);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String districtName,  String neighborhood,  String? lineFull,  String? doorNote)?  $default,) {final _that = this;
switch (_that) {
case _RequestAddress() when $default != null:
return $default(_that.districtName,_that.neighborhood,_that.lineFull,_that.doorNote);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _RequestAddress implements RequestAddress {
  const _RequestAddress({required this.districtName, required this.neighborhood, this.lineFull, this.doorNote});
  factory _RequestAddress.fromJson(Map<String, dynamic> json) => _$RequestAddressFromJson(json);

@override final  String districtName;
@override final  String neighborhood;
@override final  String? lineFull;
@override final  String? doorNote;

/// Create a copy of RequestAddress
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$RequestAddressCopyWith<_RequestAddress> get copyWith => __$RequestAddressCopyWithImpl<_RequestAddress>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$RequestAddressToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _RequestAddress&&(identical(other.districtName, districtName) || other.districtName == districtName)&&(identical(other.neighborhood, neighborhood) || other.neighborhood == neighborhood)&&(identical(other.lineFull, lineFull) || other.lineFull == lineFull)&&(identical(other.doorNote, doorNote) || other.doorNote == doorNote));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,districtName,neighborhood,lineFull,doorNote);

@override
String toString() {
  return 'RequestAddress(districtName: $districtName, neighborhood: $neighborhood, lineFull: $lineFull, doorNote: $doorNote)';
}


}

/// @nodoc
abstract mixin class _$RequestAddressCopyWith<$Res> implements $RequestAddressCopyWith<$Res> {
  factory _$RequestAddressCopyWith(_RequestAddress value, $Res Function(_RequestAddress) _then) = __$RequestAddressCopyWithImpl;
@override @useResult
$Res call({
 String districtName, String neighborhood, String? lineFull, String? doorNote
});




}
/// @nodoc
class __$RequestAddressCopyWithImpl<$Res>
    implements _$RequestAddressCopyWith<$Res> {
  __$RequestAddressCopyWithImpl(this._self, this._then);

  final _RequestAddress _self;
  final $Res Function(_RequestAddress) _then;

/// Create a copy of RequestAddress
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? districtName = null,Object? neighborhood = null,Object? lineFull = freezed,Object? doorNote = freezed,}) {
  return _then(_RequestAddress(
districtName: null == districtName ? _self.districtName : districtName // ignore: cast_nullable_to_non_nullable
as String,neighborhood: null == neighborhood ? _self.neighborhood : neighborhood // ignore: cast_nullable_to_non_nullable
as String,lineFull: freezed == lineFull ? _self.lineFull : lineFull // ignore: cast_nullable_to_non_nullable
as String?,doorNote: freezed == doorNote ? _self.doorNote : doorNote // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}


/// @nodoc
mixin _$RequestSummary {

@JsonKey(fromJson: idFromJson) String get id; String get publicCode; String get title;@JsonKey(fromJson: idFromJson) String get categoryId; RequestUrgency get urgency; RequestStatus get status; String get districtName; String get neighborhood; DateTime get createdAt; DateTime get expiresAt; int get offerCount;@NullableMoneyConverter() Money? get minOfferTotal;@NullableMoneyConverter() Money? get maxOfferTotal;
/// Create a copy of RequestSummary
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$RequestSummaryCopyWith<RequestSummary> get copyWith => _$RequestSummaryCopyWithImpl<RequestSummary>(this as RequestSummary, _$identity);

  /// Serializes this RequestSummary to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is RequestSummary&&(identical(other.id, id) || other.id == id)&&(identical(other.publicCode, publicCode) || other.publicCode == publicCode)&&(identical(other.title, title) || other.title == title)&&(identical(other.categoryId, categoryId) || other.categoryId == categoryId)&&(identical(other.urgency, urgency) || other.urgency == urgency)&&(identical(other.status, status) || other.status == status)&&(identical(other.districtName, districtName) || other.districtName == districtName)&&(identical(other.neighborhood, neighborhood) || other.neighborhood == neighborhood)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.expiresAt, expiresAt) || other.expiresAt == expiresAt)&&(identical(other.offerCount, offerCount) || other.offerCount == offerCount)&&(identical(other.minOfferTotal, minOfferTotal) || other.minOfferTotal == minOfferTotal)&&(identical(other.maxOfferTotal, maxOfferTotal) || other.maxOfferTotal == maxOfferTotal));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,publicCode,title,categoryId,urgency,status,districtName,neighborhood,createdAt,expiresAt,offerCount,minOfferTotal,maxOfferTotal);

@override
String toString() {
  return 'RequestSummary(id: $id, publicCode: $publicCode, title: $title, categoryId: $categoryId, urgency: $urgency, status: $status, districtName: $districtName, neighborhood: $neighborhood, createdAt: $createdAt, expiresAt: $expiresAt, offerCount: $offerCount, minOfferTotal: $minOfferTotal, maxOfferTotal: $maxOfferTotal)';
}


}

/// @nodoc
abstract mixin class $RequestSummaryCopyWith<$Res>  {
  factory $RequestSummaryCopyWith(RequestSummary value, $Res Function(RequestSummary) _then) = _$RequestSummaryCopyWithImpl;
@useResult
$Res call({
@JsonKey(fromJson: idFromJson) String id, String publicCode, String title,@JsonKey(fromJson: idFromJson) String categoryId, RequestUrgency urgency, RequestStatus status, String districtName, String neighborhood, DateTime createdAt, DateTime expiresAt, int offerCount,@NullableMoneyConverter() Money? minOfferTotal,@NullableMoneyConverter() Money? maxOfferTotal
});




}
/// @nodoc
class _$RequestSummaryCopyWithImpl<$Res>
    implements $RequestSummaryCopyWith<$Res> {
  _$RequestSummaryCopyWithImpl(this._self, this._then);

  final RequestSummary _self;
  final $Res Function(RequestSummary) _then;

/// Create a copy of RequestSummary
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? publicCode = null,Object? title = null,Object? categoryId = null,Object? urgency = null,Object? status = null,Object? districtName = null,Object? neighborhood = null,Object? createdAt = null,Object? expiresAt = null,Object? offerCount = null,Object? minOfferTotal = freezed,Object? maxOfferTotal = freezed,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,publicCode: null == publicCode ? _self.publicCode : publicCode // ignore: cast_nullable_to_non_nullable
as String,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,categoryId: null == categoryId ? _self.categoryId : categoryId // ignore: cast_nullable_to_non_nullable
as String,urgency: null == urgency ? _self.urgency : urgency // ignore: cast_nullable_to_non_nullable
as RequestUrgency,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as RequestStatus,districtName: null == districtName ? _self.districtName : districtName // ignore: cast_nullable_to_non_nullable
as String,neighborhood: null == neighborhood ? _self.neighborhood : neighborhood // ignore: cast_nullable_to_non_nullable
as String,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,expiresAt: null == expiresAt ? _self.expiresAt : expiresAt // ignore: cast_nullable_to_non_nullable
as DateTime,offerCount: null == offerCount ? _self.offerCount : offerCount // ignore: cast_nullable_to_non_nullable
as int,minOfferTotal: freezed == minOfferTotal ? _self.minOfferTotal : minOfferTotal // ignore: cast_nullable_to_non_nullable
as Money?,maxOfferTotal: freezed == maxOfferTotal ? _self.maxOfferTotal : maxOfferTotal // ignore: cast_nullable_to_non_nullable
as Money?,
  ));
}

}


/// Adds pattern-matching-related methods to [RequestSummary].
extension RequestSummaryPatterns on RequestSummary {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _RequestSummary value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _RequestSummary() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _RequestSummary value)  $default,){
final _that = this;
switch (_that) {
case _RequestSummary():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _RequestSummary value)?  $default,){
final _that = this;
switch (_that) {
case _RequestSummary() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function(@JsonKey(fromJson: idFromJson)  String id,  String publicCode,  String title, @JsonKey(fromJson: idFromJson)  String categoryId,  RequestUrgency urgency,  RequestStatus status,  String districtName,  String neighborhood,  DateTime createdAt,  DateTime expiresAt,  int offerCount, @NullableMoneyConverter()  Money? minOfferTotal, @NullableMoneyConverter()  Money? maxOfferTotal)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _RequestSummary() when $default != null:
return $default(_that.id,_that.publicCode,_that.title,_that.categoryId,_that.urgency,_that.status,_that.districtName,_that.neighborhood,_that.createdAt,_that.expiresAt,_that.offerCount,_that.minOfferTotal,_that.maxOfferTotal);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function(@JsonKey(fromJson: idFromJson)  String id,  String publicCode,  String title, @JsonKey(fromJson: idFromJson)  String categoryId,  RequestUrgency urgency,  RequestStatus status,  String districtName,  String neighborhood,  DateTime createdAt,  DateTime expiresAt,  int offerCount, @NullableMoneyConverter()  Money? minOfferTotal, @NullableMoneyConverter()  Money? maxOfferTotal)  $default,) {final _that = this;
switch (_that) {
case _RequestSummary():
return $default(_that.id,_that.publicCode,_that.title,_that.categoryId,_that.urgency,_that.status,_that.districtName,_that.neighborhood,_that.createdAt,_that.expiresAt,_that.offerCount,_that.minOfferTotal,_that.maxOfferTotal);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function(@JsonKey(fromJson: idFromJson)  String id,  String publicCode,  String title, @JsonKey(fromJson: idFromJson)  String categoryId,  RequestUrgency urgency,  RequestStatus status,  String districtName,  String neighborhood,  DateTime createdAt,  DateTime expiresAt,  int offerCount, @NullableMoneyConverter()  Money? minOfferTotal, @NullableMoneyConverter()  Money? maxOfferTotal)?  $default,) {final _that = this;
switch (_that) {
case _RequestSummary() when $default != null:
return $default(_that.id,_that.publicCode,_that.title,_that.categoryId,_that.urgency,_that.status,_that.districtName,_that.neighborhood,_that.createdAt,_that.expiresAt,_that.offerCount,_that.minOfferTotal,_that.maxOfferTotal);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _RequestSummary implements RequestSummary {
  const _RequestSummary({@JsonKey(fromJson: idFromJson) required this.id, required this.publicCode, required this.title, @JsonKey(fromJson: idFromJson) required this.categoryId, required this.urgency, required this.status, required this.districtName, required this.neighborhood, required this.createdAt, required this.expiresAt, this.offerCount = 0, @NullableMoneyConverter() this.minOfferTotal, @NullableMoneyConverter() this.maxOfferTotal});
  factory _RequestSummary.fromJson(Map<String, dynamic> json) => _$RequestSummaryFromJson(json);

@override@JsonKey(fromJson: idFromJson) final  String id;
@override final  String publicCode;
@override final  String title;
@override@JsonKey(fromJson: idFromJson) final  String categoryId;
@override final  RequestUrgency urgency;
@override final  RequestStatus status;
@override final  String districtName;
@override final  String neighborhood;
@override final  DateTime createdAt;
@override final  DateTime expiresAt;
@override@JsonKey() final  int offerCount;
@override@NullableMoneyConverter() final  Money? minOfferTotal;
@override@NullableMoneyConverter() final  Money? maxOfferTotal;

/// Create a copy of RequestSummary
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$RequestSummaryCopyWith<_RequestSummary> get copyWith => __$RequestSummaryCopyWithImpl<_RequestSummary>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$RequestSummaryToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _RequestSummary&&(identical(other.id, id) || other.id == id)&&(identical(other.publicCode, publicCode) || other.publicCode == publicCode)&&(identical(other.title, title) || other.title == title)&&(identical(other.categoryId, categoryId) || other.categoryId == categoryId)&&(identical(other.urgency, urgency) || other.urgency == urgency)&&(identical(other.status, status) || other.status == status)&&(identical(other.districtName, districtName) || other.districtName == districtName)&&(identical(other.neighborhood, neighborhood) || other.neighborhood == neighborhood)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.expiresAt, expiresAt) || other.expiresAt == expiresAt)&&(identical(other.offerCount, offerCount) || other.offerCount == offerCount)&&(identical(other.minOfferTotal, minOfferTotal) || other.minOfferTotal == minOfferTotal)&&(identical(other.maxOfferTotal, maxOfferTotal) || other.maxOfferTotal == maxOfferTotal));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,publicCode,title,categoryId,urgency,status,districtName,neighborhood,createdAt,expiresAt,offerCount,minOfferTotal,maxOfferTotal);

@override
String toString() {
  return 'RequestSummary(id: $id, publicCode: $publicCode, title: $title, categoryId: $categoryId, urgency: $urgency, status: $status, districtName: $districtName, neighborhood: $neighborhood, createdAt: $createdAt, expiresAt: $expiresAt, offerCount: $offerCount, minOfferTotal: $minOfferTotal, maxOfferTotal: $maxOfferTotal)';
}


}

/// @nodoc
abstract mixin class _$RequestSummaryCopyWith<$Res> implements $RequestSummaryCopyWith<$Res> {
  factory _$RequestSummaryCopyWith(_RequestSummary value, $Res Function(_RequestSummary) _then) = __$RequestSummaryCopyWithImpl;
@override @useResult
$Res call({
@JsonKey(fromJson: idFromJson) String id, String publicCode, String title,@JsonKey(fromJson: idFromJson) String categoryId, RequestUrgency urgency, RequestStatus status, String districtName, String neighborhood, DateTime createdAt, DateTime expiresAt, int offerCount,@NullableMoneyConverter() Money? minOfferTotal,@NullableMoneyConverter() Money? maxOfferTotal
});




}
/// @nodoc
class __$RequestSummaryCopyWithImpl<$Res>
    implements _$RequestSummaryCopyWith<$Res> {
  __$RequestSummaryCopyWithImpl(this._self, this._then);

  final _RequestSummary _self;
  final $Res Function(_RequestSummary) _then;

/// Create a copy of RequestSummary
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? publicCode = null,Object? title = null,Object? categoryId = null,Object? urgency = null,Object? status = null,Object? districtName = null,Object? neighborhood = null,Object? createdAt = null,Object? expiresAt = null,Object? offerCount = null,Object? minOfferTotal = freezed,Object? maxOfferTotal = freezed,}) {
  return _then(_RequestSummary(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,publicCode: null == publicCode ? _self.publicCode : publicCode // ignore: cast_nullable_to_non_nullable
as String,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,categoryId: null == categoryId ? _self.categoryId : categoryId // ignore: cast_nullable_to_non_nullable
as String,urgency: null == urgency ? _self.urgency : urgency // ignore: cast_nullable_to_non_nullable
as RequestUrgency,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as RequestStatus,districtName: null == districtName ? _self.districtName : districtName // ignore: cast_nullable_to_non_nullable
as String,neighborhood: null == neighborhood ? _self.neighborhood : neighborhood // ignore: cast_nullable_to_non_nullable
as String,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,expiresAt: null == expiresAt ? _self.expiresAt : expiresAt // ignore: cast_nullable_to_non_nullable
as DateTime,offerCount: null == offerCount ? _self.offerCount : offerCount // ignore: cast_nullable_to_non_nullable
as int,minOfferTotal: freezed == minOfferTotal ? _self.minOfferTotal : minOfferTotal // ignore: cast_nullable_to_non_nullable
as Money?,maxOfferTotal: freezed == maxOfferTotal ? _self.maxOfferTotal : maxOfferTotal // ignore: cast_nullable_to_non_nullable
as Money?,
  ));
}


}


/// @nodoc
mixin _$RequestDetail {

@JsonKey(fromJson: idFromJson) String get id; String get publicCode; String get title;@JsonKey(fromJson: idFromJson) String get categoryId; RequestUrgency get urgency; RequestStatus get status; String get districtName; String get neighborhood; DateTime get createdAt; DateTime get expiresAt; int get offerCount;@NullableMoneyConverter() Money? get minOfferTotal;@NullableMoneyConverter() Money? get maxOfferTotal; String get description; DateTime? get preferredFrom; DateTime? get preferredTo; List<MediaRef> get photos; List<RequestAnswer> get answers; int get matchedProCount; List<MatchFactor> get matchFactors; RequestAddress? get address;
/// Create a copy of RequestDetail
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$RequestDetailCopyWith<RequestDetail> get copyWith => _$RequestDetailCopyWithImpl<RequestDetail>(this as RequestDetail, _$identity);

  /// Serializes this RequestDetail to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is RequestDetail&&(identical(other.id, id) || other.id == id)&&(identical(other.publicCode, publicCode) || other.publicCode == publicCode)&&(identical(other.title, title) || other.title == title)&&(identical(other.categoryId, categoryId) || other.categoryId == categoryId)&&(identical(other.urgency, urgency) || other.urgency == urgency)&&(identical(other.status, status) || other.status == status)&&(identical(other.districtName, districtName) || other.districtName == districtName)&&(identical(other.neighborhood, neighborhood) || other.neighborhood == neighborhood)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.expiresAt, expiresAt) || other.expiresAt == expiresAt)&&(identical(other.offerCount, offerCount) || other.offerCount == offerCount)&&(identical(other.minOfferTotal, minOfferTotal) || other.minOfferTotal == minOfferTotal)&&(identical(other.maxOfferTotal, maxOfferTotal) || other.maxOfferTotal == maxOfferTotal)&&(identical(other.description, description) || other.description == description)&&(identical(other.preferredFrom, preferredFrom) || other.preferredFrom == preferredFrom)&&(identical(other.preferredTo, preferredTo) || other.preferredTo == preferredTo)&&const DeepCollectionEquality().equals(other.photos, photos)&&const DeepCollectionEquality().equals(other.answers, answers)&&(identical(other.matchedProCount, matchedProCount) || other.matchedProCount == matchedProCount)&&const DeepCollectionEquality().equals(other.matchFactors, matchFactors)&&(identical(other.address, address) || other.address == address));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hashAll([runtimeType,id,publicCode,title,categoryId,urgency,status,districtName,neighborhood,createdAt,expiresAt,offerCount,minOfferTotal,maxOfferTotal,description,preferredFrom,preferredTo,const DeepCollectionEquality().hash(photos),const DeepCollectionEquality().hash(answers),matchedProCount,const DeepCollectionEquality().hash(matchFactors),address]);

@override
String toString() {
  return 'RequestDetail(id: $id, publicCode: $publicCode, title: $title, categoryId: $categoryId, urgency: $urgency, status: $status, districtName: $districtName, neighborhood: $neighborhood, createdAt: $createdAt, expiresAt: $expiresAt, offerCount: $offerCount, minOfferTotal: $minOfferTotal, maxOfferTotal: $maxOfferTotal, description: $description, preferredFrom: $preferredFrom, preferredTo: $preferredTo, photos: $photos, answers: $answers, matchedProCount: $matchedProCount, matchFactors: $matchFactors, address: $address)';
}


}

/// @nodoc
abstract mixin class $RequestDetailCopyWith<$Res>  {
  factory $RequestDetailCopyWith(RequestDetail value, $Res Function(RequestDetail) _then) = _$RequestDetailCopyWithImpl;
@useResult
$Res call({
@JsonKey(fromJson: idFromJson) String id, String publicCode, String title,@JsonKey(fromJson: idFromJson) String categoryId, RequestUrgency urgency, RequestStatus status, String districtName, String neighborhood, DateTime createdAt, DateTime expiresAt, int offerCount,@NullableMoneyConverter() Money? minOfferTotal,@NullableMoneyConverter() Money? maxOfferTotal, String description, DateTime? preferredFrom, DateTime? preferredTo, List<MediaRef> photos, List<RequestAnswer> answers, int matchedProCount, List<MatchFactor> matchFactors, RequestAddress? address
});


$RequestAddressCopyWith<$Res>? get address;

}
/// @nodoc
class _$RequestDetailCopyWithImpl<$Res>
    implements $RequestDetailCopyWith<$Res> {
  _$RequestDetailCopyWithImpl(this._self, this._then);

  final RequestDetail _self;
  final $Res Function(RequestDetail) _then;

/// Create a copy of RequestDetail
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? publicCode = null,Object? title = null,Object? categoryId = null,Object? urgency = null,Object? status = null,Object? districtName = null,Object? neighborhood = null,Object? createdAt = null,Object? expiresAt = null,Object? offerCount = null,Object? minOfferTotal = freezed,Object? maxOfferTotal = freezed,Object? description = null,Object? preferredFrom = freezed,Object? preferredTo = freezed,Object? photos = null,Object? answers = null,Object? matchedProCount = null,Object? matchFactors = null,Object? address = freezed,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,publicCode: null == publicCode ? _self.publicCode : publicCode // ignore: cast_nullable_to_non_nullable
as String,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,categoryId: null == categoryId ? _self.categoryId : categoryId // ignore: cast_nullable_to_non_nullable
as String,urgency: null == urgency ? _self.urgency : urgency // ignore: cast_nullable_to_non_nullable
as RequestUrgency,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as RequestStatus,districtName: null == districtName ? _self.districtName : districtName // ignore: cast_nullable_to_non_nullable
as String,neighborhood: null == neighborhood ? _self.neighborhood : neighborhood // ignore: cast_nullable_to_non_nullable
as String,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,expiresAt: null == expiresAt ? _self.expiresAt : expiresAt // ignore: cast_nullable_to_non_nullable
as DateTime,offerCount: null == offerCount ? _self.offerCount : offerCount // ignore: cast_nullable_to_non_nullable
as int,minOfferTotal: freezed == minOfferTotal ? _self.minOfferTotal : minOfferTotal // ignore: cast_nullable_to_non_nullable
as Money?,maxOfferTotal: freezed == maxOfferTotal ? _self.maxOfferTotal : maxOfferTotal // ignore: cast_nullable_to_non_nullable
as Money?,description: null == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String,preferredFrom: freezed == preferredFrom ? _self.preferredFrom : preferredFrom // ignore: cast_nullable_to_non_nullable
as DateTime?,preferredTo: freezed == preferredTo ? _self.preferredTo : preferredTo // ignore: cast_nullable_to_non_nullable
as DateTime?,photos: null == photos ? _self.photos : photos // ignore: cast_nullable_to_non_nullable
as List<MediaRef>,answers: null == answers ? _self.answers : answers // ignore: cast_nullable_to_non_nullable
as List<RequestAnswer>,matchedProCount: null == matchedProCount ? _self.matchedProCount : matchedProCount // ignore: cast_nullable_to_non_nullable
as int,matchFactors: null == matchFactors ? _self.matchFactors : matchFactors // ignore: cast_nullable_to_non_nullable
as List<MatchFactor>,address: freezed == address ? _self.address : address // ignore: cast_nullable_to_non_nullable
as RequestAddress?,
  ));
}
/// Create a copy of RequestDetail
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$RequestAddressCopyWith<$Res>? get address {
    if (_self.address == null) {
    return null;
  }

  return $RequestAddressCopyWith<$Res>(_self.address!, (value) {
    return _then(_self.copyWith(address: value));
  });
}
}


/// Adds pattern-matching-related methods to [RequestDetail].
extension RequestDetailPatterns on RequestDetail {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _RequestDetail value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _RequestDetail() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _RequestDetail value)  $default,){
final _that = this;
switch (_that) {
case _RequestDetail():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _RequestDetail value)?  $default,){
final _that = this;
switch (_that) {
case _RequestDetail() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function(@JsonKey(fromJson: idFromJson)  String id,  String publicCode,  String title, @JsonKey(fromJson: idFromJson)  String categoryId,  RequestUrgency urgency,  RequestStatus status,  String districtName,  String neighborhood,  DateTime createdAt,  DateTime expiresAt,  int offerCount, @NullableMoneyConverter()  Money? minOfferTotal, @NullableMoneyConverter()  Money? maxOfferTotal,  String description,  DateTime? preferredFrom,  DateTime? preferredTo,  List<MediaRef> photos,  List<RequestAnswer> answers,  int matchedProCount,  List<MatchFactor> matchFactors,  RequestAddress? address)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _RequestDetail() when $default != null:
return $default(_that.id,_that.publicCode,_that.title,_that.categoryId,_that.urgency,_that.status,_that.districtName,_that.neighborhood,_that.createdAt,_that.expiresAt,_that.offerCount,_that.minOfferTotal,_that.maxOfferTotal,_that.description,_that.preferredFrom,_that.preferredTo,_that.photos,_that.answers,_that.matchedProCount,_that.matchFactors,_that.address);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function(@JsonKey(fromJson: idFromJson)  String id,  String publicCode,  String title, @JsonKey(fromJson: idFromJson)  String categoryId,  RequestUrgency urgency,  RequestStatus status,  String districtName,  String neighborhood,  DateTime createdAt,  DateTime expiresAt,  int offerCount, @NullableMoneyConverter()  Money? minOfferTotal, @NullableMoneyConverter()  Money? maxOfferTotal,  String description,  DateTime? preferredFrom,  DateTime? preferredTo,  List<MediaRef> photos,  List<RequestAnswer> answers,  int matchedProCount,  List<MatchFactor> matchFactors,  RequestAddress? address)  $default,) {final _that = this;
switch (_that) {
case _RequestDetail():
return $default(_that.id,_that.publicCode,_that.title,_that.categoryId,_that.urgency,_that.status,_that.districtName,_that.neighborhood,_that.createdAt,_that.expiresAt,_that.offerCount,_that.minOfferTotal,_that.maxOfferTotal,_that.description,_that.preferredFrom,_that.preferredTo,_that.photos,_that.answers,_that.matchedProCount,_that.matchFactors,_that.address);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function(@JsonKey(fromJson: idFromJson)  String id,  String publicCode,  String title, @JsonKey(fromJson: idFromJson)  String categoryId,  RequestUrgency urgency,  RequestStatus status,  String districtName,  String neighborhood,  DateTime createdAt,  DateTime expiresAt,  int offerCount, @NullableMoneyConverter()  Money? minOfferTotal, @NullableMoneyConverter()  Money? maxOfferTotal,  String description,  DateTime? preferredFrom,  DateTime? preferredTo,  List<MediaRef> photos,  List<RequestAnswer> answers,  int matchedProCount,  List<MatchFactor> matchFactors,  RequestAddress? address)?  $default,) {final _that = this;
switch (_that) {
case _RequestDetail() when $default != null:
return $default(_that.id,_that.publicCode,_that.title,_that.categoryId,_that.urgency,_that.status,_that.districtName,_that.neighborhood,_that.createdAt,_that.expiresAt,_that.offerCount,_that.minOfferTotal,_that.maxOfferTotal,_that.description,_that.preferredFrom,_that.preferredTo,_that.photos,_that.answers,_that.matchedProCount,_that.matchFactors,_that.address);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _RequestDetail extends RequestDetail {
  const _RequestDetail({@JsonKey(fromJson: idFromJson) required this.id, required this.publicCode, required this.title, @JsonKey(fromJson: idFromJson) required this.categoryId, required this.urgency, required this.status, required this.districtName, required this.neighborhood, required this.createdAt, required this.expiresAt, this.offerCount = 0, @NullableMoneyConverter() this.minOfferTotal, @NullableMoneyConverter() this.maxOfferTotal, required this.description, this.preferredFrom, this.preferredTo, this.photos = const <MediaRef>[], this.answers = const <RequestAnswer>[], this.matchedProCount = 0, this.matchFactors = const <MatchFactor>[], this.address}): super._();
  factory _RequestDetail.fromJson(Map<String, dynamic> json) => _$RequestDetailFromJson(json);

@override@JsonKey(fromJson: idFromJson) final  String id;
@override final  String publicCode;
@override final  String title;
@override@JsonKey(fromJson: idFromJson) final  String categoryId;
@override final  RequestUrgency urgency;
@override final  RequestStatus status;
@override final  String districtName;
@override final  String neighborhood;
@override final  DateTime createdAt;
@override final  DateTime expiresAt;
@override@JsonKey() final  int offerCount;
@override@NullableMoneyConverter() final  Money? minOfferTotal;
@override@NullableMoneyConverter() final  Money? maxOfferTotal;
@override final  String description;
@override final  DateTime? preferredFrom;
@override final  DateTime? preferredTo;
@override@JsonKey() final  List<MediaRef> photos;
@override@JsonKey() final  List<RequestAnswer> answers;
@override@JsonKey() final  int matchedProCount;
@override@JsonKey() final  List<MatchFactor> matchFactors;
@override final  RequestAddress? address;

/// Create a copy of RequestDetail
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$RequestDetailCopyWith<_RequestDetail> get copyWith => __$RequestDetailCopyWithImpl<_RequestDetail>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$RequestDetailToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _RequestDetail&&(identical(other.id, id) || other.id == id)&&(identical(other.publicCode, publicCode) || other.publicCode == publicCode)&&(identical(other.title, title) || other.title == title)&&(identical(other.categoryId, categoryId) || other.categoryId == categoryId)&&(identical(other.urgency, urgency) || other.urgency == urgency)&&(identical(other.status, status) || other.status == status)&&(identical(other.districtName, districtName) || other.districtName == districtName)&&(identical(other.neighborhood, neighborhood) || other.neighborhood == neighborhood)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.expiresAt, expiresAt) || other.expiresAt == expiresAt)&&(identical(other.offerCount, offerCount) || other.offerCount == offerCount)&&(identical(other.minOfferTotal, minOfferTotal) || other.minOfferTotal == minOfferTotal)&&(identical(other.maxOfferTotal, maxOfferTotal) || other.maxOfferTotal == maxOfferTotal)&&(identical(other.description, description) || other.description == description)&&(identical(other.preferredFrom, preferredFrom) || other.preferredFrom == preferredFrom)&&(identical(other.preferredTo, preferredTo) || other.preferredTo == preferredTo)&&const DeepCollectionEquality().equals(other.photos, photos)&&const DeepCollectionEquality().equals(other.answers, answers)&&(identical(other.matchedProCount, matchedProCount) || other.matchedProCount == matchedProCount)&&const DeepCollectionEquality().equals(other.matchFactors, matchFactors)&&(identical(other.address, address) || other.address == address));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hashAll([runtimeType,id,publicCode,title,categoryId,urgency,status,districtName,neighborhood,createdAt,expiresAt,offerCount,minOfferTotal,maxOfferTotal,description,preferredFrom,preferredTo,const DeepCollectionEquality().hash(photos),const DeepCollectionEquality().hash(answers),matchedProCount,const DeepCollectionEquality().hash(matchFactors),address]);

@override
String toString() {
  return 'RequestDetail(id: $id, publicCode: $publicCode, title: $title, categoryId: $categoryId, urgency: $urgency, status: $status, districtName: $districtName, neighborhood: $neighborhood, createdAt: $createdAt, expiresAt: $expiresAt, offerCount: $offerCount, minOfferTotal: $minOfferTotal, maxOfferTotal: $maxOfferTotal, description: $description, preferredFrom: $preferredFrom, preferredTo: $preferredTo, photos: $photos, answers: $answers, matchedProCount: $matchedProCount, matchFactors: $matchFactors, address: $address)';
}


}

/// @nodoc
abstract mixin class _$RequestDetailCopyWith<$Res> implements $RequestDetailCopyWith<$Res> {
  factory _$RequestDetailCopyWith(_RequestDetail value, $Res Function(_RequestDetail) _then) = __$RequestDetailCopyWithImpl;
@override @useResult
$Res call({
@JsonKey(fromJson: idFromJson) String id, String publicCode, String title,@JsonKey(fromJson: idFromJson) String categoryId, RequestUrgency urgency, RequestStatus status, String districtName, String neighborhood, DateTime createdAt, DateTime expiresAt, int offerCount,@NullableMoneyConverter() Money? minOfferTotal,@NullableMoneyConverter() Money? maxOfferTotal, String description, DateTime? preferredFrom, DateTime? preferredTo, List<MediaRef> photos, List<RequestAnswer> answers, int matchedProCount, List<MatchFactor> matchFactors, RequestAddress? address
});


@override $RequestAddressCopyWith<$Res>? get address;

}
/// @nodoc
class __$RequestDetailCopyWithImpl<$Res>
    implements _$RequestDetailCopyWith<$Res> {
  __$RequestDetailCopyWithImpl(this._self, this._then);

  final _RequestDetail _self;
  final $Res Function(_RequestDetail) _then;

/// Create a copy of RequestDetail
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? publicCode = null,Object? title = null,Object? categoryId = null,Object? urgency = null,Object? status = null,Object? districtName = null,Object? neighborhood = null,Object? createdAt = null,Object? expiresAt = null,Object? offerCount = null,Object? minOfferTotal = freezed,Object? maxOfferTotal = freezed,Object? description = null,Object? preferredFrom = freezed,Object? preferredTo = freezed,Object? photos = null,Object? answers = null,Object? matchedProCount = null,Object? matchFactors = null,Object? address = freezed,}) {
  return _then(_RequestDetail(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,publicCode: null == publicCode ? _self.publicCode : publicCode // ignore: cast_nullable_to_non_nullable
as String,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,categoryId: null == categoryId ? _self.categoryId : categoryId // ignore: cast_nullable_to_non_nullable
as String,urgency: null == urgency ? _self.urgency : urgency // ignore: cast_nullable_to_non_nullable
as RequestUrgency,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as RequestStatus,districtName: null == districtName ? _self.districtName : districtName // ignore: cast_nullable_to_non_nullable
as String,neighborhood: null == neighborhood ? _self.neighborhood : neighborhood // ignore: cast_nullable_to_non_nullable
as String,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,expiresAt: null == expiresAt ? _self.expiresAt : expiresAt // ignore: cast_nullable_to_non_nullable
as DateTime,offerCount: null == offerCount ? _self.offerCount : offerCount // ignore: cast_nullable_to_non_nullable
as int,minOfferTotal: freezed == minOfferTotal ? _self.minOfferTotal : minOfferTotal // ignore: cast_nullable_to_non_nullable
as Money?,maxOfferTotal: freezed == maxOfferTotal ? _self.maxOfferTotal : maxOfferTotal // ignore: cast_nullable_to_non_nullable
as Money?,description: null == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String,preferredFrom: freezed == preferredFrom ? _self.preferredFrom : preferredFrom // ignore: cast_nullable_to_non_nullable
as DateTime?,preferredTo: freezed == preferredTo ? _self.preferredTo : preferredTo // ignore: cast_nullable_to_non_nullable
as DateTime?,photos: null == photos ? _self.photos : photos // ignore: cast_nullable_to_non_nullable
as List<MediaRef>,answers: null == answers ? _self.answers : answers // ignore: cast_nullable_to_non_nullable
as List<RequestAnswer>,matchedProCount: null == matchedProCount ? _self.matchedProCount : matchedProCount // ignore: cast_nullable_to_non_nullable
as int,matchFactors: null == matchFactors ? _self.matchFactors : matchFactors // ignore: cast_nullable_to_non_nullable
as List<MatchFactor>,address: freezed == address ? _self.address : address // ignore: cast_nullable_to_non_nullable
as RequestAddress?,
  ));
}

/// Create a copy of RequestDetail
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$RequestAddressCopyWith<$Res>? get address {
    if (_self.address == null) {
    return null;
  }

  return $RequestAddressCopyWith<$Res>(_self.address!, (value) {
    return _then(_self.copyWith(address: value));
  });
}
}


/// @nodoc
mixin _$RequestInput {

@JsonKey(fromJson: idFromJson, toJson: wireId) String get categoryId; RequestUrgency get urgency; DateTime? get preferredFrom; DateTime? get preferredTo; String get title; String get description;@JsonKey(fromJson: idFromJson, toJson: wireId) String get addressId;@JsonKey(toJson: idListToJson, fromJson: idListFromJson) List<String> get photoIds; List<RequestAnswer> get answers;
/// Create a copy of RequestInput
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$RequestInputCopyWith<RequestInput> get copyWith => _$RequestInputCopyWithImpl<RequestInput>(this as RequestInput, _$identity);

  /// Serializes this RequestInput to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is RequestInput&&(identical(other.categoryId, categoryId) || other.categoryId == categoryId)&&(identical(other.urgency, urgency) || other.urgency == urgency)&&(identical(other.preferredFrom, preferredFrom) || other.preferredFrom == preferredFrom)&&(identical(other.preferredTo, preferredTo) || other.preferredTo == preferredTo)&&(identical(other.title, title) || other.title == title)&&(identical(other.description, description) || other.description == description)&&(identical(other.addressId, addressId) || other.addressId == addressId)&&const DeepCollectionEquality().equals(other.photoIds, photoIds)&&const DeepCollectionEquality().equals(other.answers, answers));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,categoryId,urgency,preferredFrom,preferredTo,title,description,addressId,const DeepCollectionEquality().hash(photoIds),const DeepCollectionEquality().hash(answers));

@override
String toString() {
  return 'RequestInput(categoryId: $categoryId, urgency: $urgency, preferredFrom: $preferredFrom, preferredTo: $preferredTo, title: $title, description: $description, addressId: $addressId, photoIds: $photoIds, answers: $answers)';
}


}

/// @nodoc
abstract mixin class $RequestInputCopyWith<$Res>  {
  factory $RequestInputCopyWith(RequestInput value, $Res Function(RequestInput) _then) = _$RequestInputCopyWithImpl;
@useResult
$Res call({
@JsonKey(fromJson: idFromJson, toJson: wireId) String categoryId, RequestUrgency urgency, DateTime? preferredFrom, DateTime? preferredTo, String title, String description,@JsonKey(fromJson: idFromJson, toJson: wireId) String addressId,@JsonKey(toJson: idListToJson, fromJson: idListFromJson) List<String> photoIds, List<RequestAnswer> answers
});




}
/// @nodoc
class _$RequestInputCopyWithImpl<$Res>
    implements $RequestInputCopyWith<$Res> {
  _$RequestInputCopyWithImpl(this._self, this._then);

  final RequestInput _self;
  final $Res Function(RequestInput) _then;

/// Create a copy of RequestInput
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? categoryId = null,Object? urgency = null,Object? preferredFrom = freezed,Object? preferredTo = freezed,Object? title = null,Object? description = null,Object? addressId = null,Object? photoIds = null,Object? answers = null,}) {
  return _then(_self.copyWith(
categoryId: null == categoryId ? _self.categoryId : categoryId // ignore: cast_nullable_to_non_nullable
as String,urgency: null == urgency ? _self.urgency : urgency // ignore: cast_nullable_to_non_nullable
as RequestUrgency,preferredFrom: freezed == preferredFrom ? _self.preferredFrom : preferredFrom // ignore: cast_nullable_to_non_nullable
as DateTime?,preferredTo: freezed == preferredTo ? _self.preferredTo : preferredTo // ignore: cast_nullable_to_non_nullable
as DateTime?,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,description: null == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String,addressId: null == addressId ? _self.addressId : addressId // ignore: cast_nullable_to_non_nullable
as String,photoIds: null == photoIds ? _self.photoIds : photoIds // ignore: cast_nullable_to_non_nullable
as List<String>,answers: null == answers ? _self.answers : answers // ignore: cast_nullable_to_non_nullable
as List<RequestAnswer>,
  ));
}

}


/// Adds pattern-matching-related methods to [RequestInput].
extension RequestInputPatterns on RequestInput {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _RequestInput value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _RequestInput() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _RequestInput value)  $default,){
final _that = this;
switch (_that) {
case _RequestInput():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _RequestInput value)?  $default,){
final _that = this;
switch (_that) {
case _RequestInput() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function(@JsonKey(fromJson: idFromJson, toJson: wireId)  String categoryId,  RequestUrgency urgency,  DateTime? preferredFrom,  DateTime? preferredTo,  String title,  String description, @JsonKey(fromJson: idFromJson, toJson: wireId)  String addressId, @JsonKey(toJson: idListToJson, fromJson: idListFromJson)  List<String> photoIds,  List<RequestAnswer> answers)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _RequestInput() when $default != null:
return $default(_that.categoryId,_that.urgency,_that.preferredFrom,_that.preferredTo,_that.title,_that.description,_that.addressId,_that.photoIds,_that.answers);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function(@JsonKey(fromJson: idFromJson, toJson: wireId)  String categoryId,  RequestUrgency urgency,  DateTime? preferredFrom,  DateTime? preferredTo,  String title,  String description, @JsonKey(fromJson: idFromJson, toJson: wireId)  String addressId, @JsonKey(toJson: idListToJson, fromJson: idListFromJson)  List<String> photoIds,  List<RequestAnswer> answers)  $default,) {final _that = this;
switch (_that) {
case _RequestInput():
return $default(_that.categoryId,_that.urgency,_that.preferredFrom,_that.preferredTo,_that.title,_that.description,_that.addressId,_that.photoIds,_that.answers);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function(@JsonKey(fromJson: idFromJson, toJson: wireId)  String categoryId,  RequestUrgency urgency,  DateTime? preferredFrom,  DateTime? preferredTo,  String title,  String description, @JsonKey(fromJson: idFromJson, toJson: wireId)  String addressId, @JsonKey(toJson: idListToJson, fromJson: idListFromJson)  List<String> photoIds,  List<RequestAnswer> answers)?  $default,) {final _that = this;
switch (_that) {
case _RequestInput() when $default != null:
return $default(_that.categoryId,_that.urgency,_that.preferredFrom,_that.preferredTo,_that.title,_that.description,_that.addressId,_that.photoIds,_that.answers);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _RequestInput implements RequestInput {
  const _RequestInput({@JsonKey(fromJson: idFromJson, toJson: wireId) required this.categoryId, required this.urgency, this.preferredFrom, this.preferredTo, required this.title, required this.description, @JsonKey(fromJson: idFromJson, toJson: wireId) required this.addressId, @JsonKey(toJson: idListToJson, fromJson: idListFromJson) this.photoIds = const <String>[], this.answers = const <RequestAnswer>[]});
  factory _RequestInput.fromJson(Map<String, dynamic> json) => _$RequestInputFromJson(json);

@override@JsonKey(fromJson: idFromJson, toJson: wireId) final  String categoryId;
@override final  RequestUrgency urgency;
@override final  DateTime? preferredFrom;
@override final  DateTime? preferredTo;
@override final  String title;
@override final  String description;
@override@JsonKey(fromJson: idFromJson, toJson: wireId) final  String addressId;
@override@JsonKey(toJson: idListToJson, fromJson: idListFromJson) final  List<String> photoIds;
@override@JsonKey() final  List<RequestAnswer> answers;

/// Create a copy of RequestInput
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$RequestInputCopyWith<_RequestInput> get copyWith => __$RequestInputCopyWithImpl<_RequestInput>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$RequestInputToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _RequestInput&&(identical(other.categoryId, categoryId) || other.categoryId == categoryId)&&(identical(other.urgency, urgency) || other.urgency == urgency)&&(identical(other.preferredFrom, preferredFrom) || other.preferredFrom == preferredFrom)&&(identical(other.preferredTo, preferredTo) || other.preferredTo == preferredTo)&&(identical(other.title, title) || other.title == title)&&(identical(other.description, description) || other.description == description)&&(identical(other.addressId, addressId) || other.addressId == addressId)&&const DeepCollectionEquality().equals(other.photoIds, photoIds)&&const DeepCollectionEquality().equals(other.answers, answers));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,categoryId,urgency,preferredFrom,preferredTo,title,description,addressId,const DeepCollectionEquality().hash(photoIds),const DeepCollectionEquality().hash(answers));

@override
String toString() {
  return 'RequestInput(categoryId: $categoryId, urgency: $urgency, preferredFrom: $preferredFrom, preferredTo: $preferredTo, title: $title, description: $description, addressId: $addressId, photoIds: $photoIds, answers: $answers)';
}


}

/// @nodoc
abstract mixin class _$RequestInputCopyWith<$Res> implements $RequestInputCopyWith<$Res> {
  factory _$RequestInputCopyWith(_RequestInput value, $Res Function(_RequestInput) _then) = __$RequestInputCopyWithImpl;
@override @useResult
$Res call({
@JsonKey(fromJson: idFromJson, toJson: wireId) String categoryId, RequestUrgency urgency, DateTime? preferredFrom, DateTime? preferredTo, String title, String description,@JsonKey(fromJson: idFromJson, toJson: wireId) String addressId,@JsonKey(toJson: idListToJson, fromJson: idListFromJson) List<String> photoIds, List<RequestAnswer> answers
});




}
/// @nodoc
class __$RequestInputCopyWithImpl<$Res>
    implements _$RequestInputCopyWith<$Res> {
  __$RequestInputCopyWithImpl(this._self, this._then);

  final _RequestInput _self;
  final $Res Function(_RequestInput) _then;

/// Create a copy of RequestInput
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? categoryId = null,Object? urgency = null,Object? preferredFrom = freezed,Object? preferredTo = freezed,Object? title = null,Object? description = null,Object? addressId = null,Object? photoIds = null,Object? answers = null,}) {
  return _then(_RequestInput(
categoryId: null == categoryId ? _self.categoryId : categoryId // ignore: cast_nullable_to_non_nullable
as String,urgency: null == urgency ? _self.urgency : urgency // ignore: cast_nullable_to_non_nullable
as RequestUrgency,preferredFrom: freezed == preferredFrom ? _self.preferredFrom : preferredFrom // ignore: cast_nullable_to_non_nullable
as DateTime?,preferredTo: freezed == preferredTo ? _self.preferredTo : preferredTo // ignore: cast_nullable_to_non_nullable
as DateTime?,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,description: null == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String,addressId: null == addressId ? _self.addressId : addressId // ignore: cast_nullable_to_non_nullable
as String,photoIds: null == photoIds ? _self.photoIds : photoIds // ignore: cast_nullable_to_non_nullable
as List<String>,answers: null == answers ? _self.answers : answers // ignore: cast_nullable_to_non_nullable
as List<RequestAnswer>,
  ));
}


}


/// @nodoc
mixin _$CancelRequestInput {

 RequestCancelReason get reason;@JsonKey(includeIfNull: false) String? get note;
/// Create a copy of CancelRequestInput
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$CancelRequestInputCopyWith<CancelRequestInput> get copyWith => _$CancelRequestInputCopyWithImpl<CancelRequestInput>(this as CancelRequestInput, _$identity);

  /// Serializes this CancelRequestInput to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is CancelRequestInput&&(identical(other.reason, reason) || other.reason == reason)&&(identical(other.note, note) || other.note == note));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,reason,note);

@override
String toString() {
  return 'CancelRequestInput(reason: $reason, note: $note)';
}


}

/// @nodoc
abstract mixin class $CancelRequestInputCopyWith<$Res>  {
  factory $CancelRequestInputCopyWith(CancelRequestInput value, $Res Function(CancelRequestInput) _then) = _$CancelRequestInputCopyWithImpl;
@useResult
$Res call({
 RequestCancelReason reason,@JsonKey(includeIfNull: false) String? note
});




}
/// @nodoc
class _$CancelRequestInputCopyWithImpl<$Res>
    implements $CancelRequestInputCopyWith<$Res> {
  _$CancelRequestInputCopyWithImpl(this._self, this._then);

  final CancelRequestInput _self;
  final $Res Function(CancelRequestInput) _then;

/// Create a copy of CancelRequestInput
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? reason = null,Object? note = freezed,}) {
  return _then(_self.copyWith(
reason: null == reason ? _self.reason : reason // ignore: cast_nullable_to_non_nullable
as RequestCancelReason,note: freezed == note ? _self.note : note // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [CancelRequestInput].
extension CancelRequestInputPatterns on CancelRequestInput {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _CancelRequestInput value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _CancelRequestInput() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _CancelRequestInput value)  $default,){
final _that = this;
switch (_that) {
case _CancelRequestInput():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _CancelRequestInput value)?  $default,){
final _that = this;
switch (_that) {
case _CancelRequestInput() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( RequestCancelReason reason, @JsonKey(includeIfNull: false)  String? note)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _CancelRequestInput() when $default != null:
return $default(_that.reason,_that.note);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( RequestCancelReason reason, @JsonKey(includeIfNull: false)  String? note)  $default,) {final _that = this;
switch (_that) {
case _CancelRequestInput():
return $default(_that.reason,_that.note);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( RequestCancelReason reason, @JsonKey(includeIfNull: false)  String? note)?  $default,) {final _that = this;
switch (_that) {
case _CancelRequestInput() when $default != null:
return $default(_that.reason,_that.note);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _CancelRequestInput implements CancelRequestInput {
  const _CancelRequestInput({required this.reason, @JsonKey(includeIfNull: false) this.note});
  factory _CancelRequestInput.fromJson(Map<String, dynamic> json) => _$CancelRequestInputFromJson(json);

@override final  RequestCancelReason reason;
@override@JsonKey(includeIfNull: false) final  String? note;

/// Create a copy of CancelRequestInput
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$CancelRequestInputCopyWith<_CancelRequestInput> get copyWith => __$CancelRequestInputCopyWithImpl<_CancelRequestInput>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$CancelRequestInputToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _CancelRequestInput&&(identical(other.reason, reason) || other.reason == reason)&&(identical(other.note, note) || other.note == note));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,reason,note);

@override
String toString() {
  return 'CancelRequestInput(reason: $reason, note: $note)';
}


}

/// @nodoc
abstract mixin class _$CancelRequestInputCopyWith<$Res> implements $CancelRequestInputCopyWith<$Res> {
  factory _$CancelRequestInputCopyWith(_CancelRequestInput value, $Res Function(_CancelRequestInput) _then) = __$CancelRequestInputCopyWithImpl;
@override @useResult
$Res call({
 RequestCancelReason reason,@JsonKey(includeIfNull: false) String? note
});




}
/// @nodoc
class __$CancelRequestInputCopyWithImpl<$Res>
    implements _$CancelRequestInputCopyWith<$Res> {
  __$CancelRequestInputCopyWithImpl(this._self, this._then);

  final _CancelRequestInput _self;
  final $Res Function(_CancelRequestInput) _then;

/// Create a copy of CancelRequestInput
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? reason = null,Object? note = freezed,}) {
  return _then(_CancelRequestInput(
reason: null == reason ? _self.reason : reason // ignore: cast_nullable_to_non_nullable
as RequestCancelReason,note: freezed == note ? _self.note : note // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}


/// @nodoc
mixin _$QuestionOption {

 String get value; String get labelTr; String get labelEn;
/// Create a copy of QuestionOption
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$QuestionOptionCopyWith<QuestionOption> get copyWith => _$QuestionOptionCopyWithImpl<QuestionOption>(this as QuestionOption, _$identity);

  /// Serializes this QuestionOption to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is QuestionOption&&(identical(other.value, value) || other.value == value)&&(identical(other.labelTr, labelTr) || other.labelTr == labelTr)&&(identical(other.labelEn, labelEn) || other.labelEn == labelEn));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,value,labelTr,labelEn);

@override
String toString() {
  return 'QuestionOption(value: $value, labelTr: $labelTr, labelEn: $labelEn)';
}


}

/// @nodoc
abstract mixin class $QuestionOptionCopyWith<$Res>  {
  factory $QuestionOptionCopyWith(QuestionOption value, $Res Function(QuestionOption) _then) = _$QuestionOptionCopyWithImpl;
@useResult
$Res call({
 String value, String labelTr, String labelEn
});




}
/// @nodoc
class _$QuestionOptionCopyWithImpl<$Res>
    implements $QuestionOptionCopyWith<$Res> {
  _$QuestionOptionCopyWithImpl(this._self, this._then);

  final QuestionOption _self;
  final $Res Function(QuestionOption) _then;

/// Create a copy of QuestionOption
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? value = null,Object? labelTr = null,Object? labelEn = null,}) {
  return _then(_self.copyWith(
value: null == value ? _self.value : value // ignore: cast_nullable_to_non_nullable
as String,labelTr: null == labelTr ? _self.labelTr : labelTr // ignore: cast_nullable_to_non_nullable
as String,labelEn: null == labelEn ? _self.labelEn : labelEn // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [QuestionOption].
extension QuestionOptionPatterns on QuestionOption {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _QuestionOption value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _QuestionOption() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _QuestionOption value)  $default,){
final _that = this;
switch (_that) {
case _QuestionOption():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _QuestionOption value)?  $default,){
final _that = this;
switch (_that) {
case _QuestionOption() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String value,  String labelTr,  String labelEn)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _QuestionOption() when $default != null:
return $default(_that.value,_that.labelTr,_that.labelEn);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String value,  String labelTr,  String labelEn)  $default,) {final _that = this;
switch (_that) {
case _QuestionOption():
return $default(_that.value,_that.labelTr,_that.labelEn);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String value,  String labelTr,  String labelEn)?  $default,) {final _that = this;
switch (_that) {
case _QuestionOption() when $default != null:
return $default(_that.value,_that.labelTr,_that.labelEn);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _QuestionOption implements QuestionOption {
  const _QuestionOption({required this.value, required this.labelTr, required this.labelEn});
  factory _QuestionOption.fromJson(Map<String, dynamic> json) => _$QuestionOptionFromJson(json);

@override final  String value;
@override final  String labelTr;
@override final  String labelEn;

/// Create a copy of QuestionOption
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$QuestionOptionCopyWith<_QuestionOption> get copyWith => __$QuestionOptionCopyWithImpl<_QuestionOption>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$QuestionOptionToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _QuestionOption&&(identical(other.value, value) || other.value == value)&&(identical(other.labelTr, labelTr) || other.labelTr == labelTr)&&(identical(other.labelEn, labelEn) || other.labelEn == labelEn));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,value,labelTr,labelEn);

@override
String toString() {
  return 'QuestionOption(value: $value, labelTr: $labelTr, labelEn: $labelEn)';
}


}

/// @nodoc
abstract mixin class _$QuestionOptionCopyWith<$Res> implements $QuestionOptionCopyWith<$Res> {
  factory _$QuestionOptionCopyWith(_QuestionOption value, $Res Function(_QuestionOption) _then) = __$QuestionOptionCopyWithImpl;
@override @useResult
$Res call({
 String value, String labelTr, String labelEn
});




}
/// @nodoc
class __$QuestionOptionCopyWithImpl<$Res>
    implements _$QuestionOptionCopyWith<$Res> {
  __$QuestionOptionCopyWithImpl(this._self, this._then);

  final _QuestionOption _self;
  final $Res Function(_QuestionOption) _then;

/// Create a copy of QuestionOption
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? value = null,Object? labelTr = null,Object? labelEn = null,}) {
  return _then(_QuestionOption(
value: null == value ? _self.value : value // ignore: cast_nullable_to_non_nullable
as String,labelTr: null == labelTr ? _self.labelTr : labelTr // ignore: cast_nullable_to_non_nullable
as String,labelEn: null == labelEn ? _self.labelEn : labelEn // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}


/// @nodoc
mixin _$Question {

 String get key; String get labelTr; String get labelEn; List<QuestionOption> get options;
/// Create a copy of Question
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$QuestionCopyWith<Question> get copyWith => _$QuestionCopyWithImpl<Question>(this as Question, _$identity);

  /// Serializes this Question to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Question&&(identical(other.key, key) || other.key == key)&&(identical(other.labelTr, labelTr) || other.labelTr == labelTr)&&(identical(other.labelEn, labelEn) || other.labelEn == labelEn)&&const DeepCollectionEquality().equals(other.options, options));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,key,labelTr,labelEn,const DeepCollectionEquality().hash(options));

@override
String toString() {
  return 'Question(key: $key, labelTr: $labelTr, labelEn: $labelEn, options: $options)';
}


}

/// @nodoc
abstract mixin class $QuestionCopyWith<$Res>  {
  factory $QuestionCopyWith(Question value, $Res Function(Question) _then) = _$QuestionCopyWithImpl;
@useResult
$Res call({
 String key, String labelTr, String labelEn, List<QuestionOption> options
});




}
/// @nodoc
class _$QuestionCopyWithImpl<$Res>
    implements $QuestionCopyWith<$Res> {
  _$QuestionCopyWithImpl(this._self, this._then);

  final Question _self;
  final $Res Function(Question) _then;

/// Create a copy of Question
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? key = null,Object? labelTr = null,Object? labelEn = null,Object? options = null,}) {
  return _then(_self.copyWith(
key: null == key ? _self.key : key // ignore: cast_nullable_to_non_nullable
as String,labelTr: null == labelTr ? _self.labelTr : labelTr // ignore: cast_nullable_to_non_nullable
as String,labelEn: null == labelEn ? _self.labelEn : labelEn // ignore: cast_nullable_to_non_nullable
as String,options: null == options ? _self.options : options // ignore: cast_nullable_to_non_nullable
as List<QuestionOption>,
  ));
}

}


/// Adds pattern-matching-related methods to [Question].
extension QuestionPatterns on Question {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _Question value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _Question() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _Question value)  $default,){
final _that = this;
switch (_that) {
case _Question():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _Question value)?  $default,){
final _that = this;
switch (_that) {
case _Question() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String key,  String labelTr,  String labelEn,  List<QuestionOption> options)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Question() when $default != null:
return $default(_that.key,_that.labelTr,_that.labelEn,_that.options);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String key,  String labelTr,  String labelEn,  List<QuestionOption> options)  $default,) {final _that = this;
switch (_that) {
case _Question():
return $default(_that.key,_that.labelTr,_that.labelEn,_that.options);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String key,  String labelTr,  String labelEn,  List<QuestionOption> options)?  $default,) {final _that = this;
switch (_that) {
case _Question() when $default != null:
return $default(_that.key,_that.labelTr,_that.labelEn,_that.options);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _Question implements Question {
  const _Question({required this.key, required this.labelTr, required this.labelEn, this.options = const <QuestionOption>[]});
  factory _Question.fromJson(Map<String, dynamic> json) => _$QuestionFromJson(json);

@override final  String key;
@override final  String labelTr;
@override final  String labelEn;
@override@JsonKey() final  List<QuestionOption> options;

/// Create a copy of Question
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$QuestionCopyWith<_Question> get copyWith => __$QuestionCopyWithImpl<_Question>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$QuestionToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _Question&&(identical(other.key, key) || other.key == key)&&(identical(other.labelTr, labelTr) || other.labelTr == labelTr)&&(identical(other.labelEn, labelEn) || other.labelEn == labelEn)&&const DeepCollectionEquality().equals(other.options, options));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,key,labelTr,labelEn,const DeepCollectionEquality().hash(options));

@override
String toString() {
  return 'Question(key: $key, labelTr: $labelTr, labelEn: $labelEn, options: $options)';
}


}

/// @nodoc
abstract mixin class _$QuestionCopyWith<$Res> implements $QuestionCopyWith<$Res> {
  factory _$QuestionCopyWith(_Question value, $Res Function(_Question) _then) = __$QuestionCopyWithImpl;
@override @useResult
$Res call({
 String key, String labelTr, String labelEn, List<QuestionOption> options
});




}
/// @nodoc
class __$QuestionCopyWithImpl<$Res>
    implements _$QuestionCopyWith<$Res> {
  __$QuestionCopyWithImpl(this._self, this._then);

  final _Question _self;
  final $Res Function(_Question) _then;

/// Create a copy of Question
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? key = null,Object? labelTr = null,Object? labelEn = null,Object? options = null,}) {
  return _then(_Question(
key: null == key ? _self.key : key // ignore: cast_nullable_to_non_nullable
as String,labelTr: null == labelTr ? _self.labelTr : labelTr // ignore: cast_nullable_to_non_nullable
as String,labelEn: null == labelEn ? _self.labelEn : labelEn // ignore: cast_nullable_to_non_nullable
as String,options: null == options ? _self.options : options // ignore: cast_nullable_to_non_nullable
as List<QuestionOption>,
  ));
}


}

// dart format on
