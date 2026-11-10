// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'payments.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$PaymentInit {

 String get ref; String get htmlContent;
/// Create a copy of PaymentInit
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$PaymentInitCopyWith<PaymentInit> get copyWith => _$PaymentInitCopyWithImpl<PaymentInit>(this as PaymentInit, _$identity);

  /// Serializes this PaymentInit to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is PaymentInit&&(identical(other.ref, ref) || other.ref == ref)&&(identical(other.htmlContent, htmlContent) || other.htmlContent == htmlContent));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,ref,htmlContent);

@override
String toString() {
  return 'PaymentInit(ref: $ref, htmlContent: $htmlContent)';
}


}

/// @nodoc
abstract mixin class $PaymentInitCopyWith<$Res>  {
  factory $PaymentInitCopyWith(PaymentInit value, $Res Function(PaymentInit) _then) = _$PaymentInitCopyWithImpl;
@useResult
$Res call({
 String ref, String htmlContent
});




}
/// @nodoc
class _$PaymentInitCopyWithImpl<$Res>
    implements $PaymentInitCopyWith<$Res> {
  _$PaymentInitCopyWithImpl(this._self, this._then);

  final PaymentInit _self;
  final $Res Function(PaymentInit) _then;

/// Create a copy of PaymentInit
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? ref = null,Object? htmlContent = null,}) {
  return _then(_self.copyWith(
ref: null == ref ? _self.ref : ref // ignore: cast_nullable_to_non_nullable
as String,htmlContent: null == htmlContent ? _self.htmlContent : htmlContent // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [PaymentInit].
extension PaymentInitPatterns on PaymentInit {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _PaymentInit value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _PaymentInit() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _PaymentInit value)  $default,){
final _that = this;
switch (_that) {
case _PaymentInit():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _PaymentInit value)?  $default,){
final _that = this;
switch (_that) {
case _PaymentInit() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String ref,  String htmlContent)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _PaymentInit() when $default != null:
return $default(_that.ref,_that.htmlContent);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String ref,  String htmlContent)  $default,) {final _that = this;
switch (_that) {
case _PaymentInit():
return $default(_that.ref,_that.htmlContent);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String ref,  String htmlContent)?  $default,) {final _that = this;
switch (_that) {
case _PaymentInit() when $default != null:
return $default(_that.ref,_that.htmlContent);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _PaymentInit implements PaymentInit {
  const _PaymentInit({required this.ref, required this.htmlContent});
  factory _PaymentInit.fromJson(Map<String, dynamic> json) => _$PaymentInitFromJson(json);

@override final  String ref;
@override final  String htmlContent;

/// Create a copy of PaymentInit
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$PaymentInitCopyWith<_PaymentInit> get copyWith => __$PaymentInitCopyWithImpl<_PaymentInit>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$PaymentInitToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _PaymentInit&&(identical(other.ref, ref) || other.ref == ref)&&(identical(other.htmlContent, htmlContent) || other.htmlContent == htmlContent));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,ref,htmlContent);

@override
String toString() {
  return 'PaymentInit(ref: $ref, htmlContent: $htmlContent)';
}


}

/// @nodoc
abstract mixin class _$PaymentInitCopyWith<$Res> implements $PaymentInitCopyWith<$Res> {
  factory _$PaymentInitCopyWith(_PaymentInit value, $Res Function(_PaymentInit) _then) = __$PaymentInitCopyWithImpl;
@override @useResult
$Res call({
 String ref, String htmlContent
});




}
/// @nodoc
class __$PaymentInitCopyWithImpl<$Res>
    implements _$PaymentInitCopyWith<$Res> {
  __$PaymentInitCopyWithImpl(this._self, this._then);

  final _PaymentInit _self;
  final $Res Function(_PaymentInit) _then;

/// Create a copy of PaymentInit
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? ref = null,Object? htmlContent = null,}) {
  return _then(_PaymentInit(
ref: null == ref ? _self.ref : ref // ignore: cast_nullable_to_non_nullable
as String,htmlContent: null == htmlContent ? _self.htmlContent : htmlContent // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}


/// @nodoc
mixin _$PaymentResult {

 String get ref; EscrowStatus get status;@JsonKey(fromJson: idFromJsonNullable) String? get offerId;@JsonKey(fromJson: idFromJsonNullable) String? get requestId;@JsonKey(fromJson: idFromJsonNullable) String? get jobId;@MoneyConverter() Money get totalAmount; String? get cardLast4;@JsonKey(unknownEnumValue: PaymentErrorCode.unknown) PaymentErrorCode? get errorCode; String? get errorMessage; bool get resultUncertain;
/// Create a copy of PaymentResult
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$PaymentResultCopyWith<PaymentResult> get copyWith => _$PaymentResultCopyWithImpl<PaymentResult>(this as PaymentResult, _$identity);

  /// Serializes this PaymentResult to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is PaymentResult&&(identical(other.ref, ref) || other.ref == ref)&&(identical(other.status, status) || other.status == status)&&(identical(other.offerId, offerId) || other.offerId == offerId)&&(identical(other.requestId, requestId) || other.requestId == requestId)&&(identical(other.jobId, jobId) || other.jobId == jobId)&&(identical(other.totalAmount, totalAmount) || other.totalAmount == totalAmount)&&(identical(other.cardLast4, cardLast4) || other.cardLast4 == cardLast4)&&(identical(other.errorCode, errorCode) || other.errorCode == errorCode)&&(identical(other.errorMessage, errorMessage) || other.errorMessage == errorMessage)&&(identical(other.resultUncertain, resultUncertain) || other.resultUncertain == resultUncertain));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,ref,status,offerId,requestId,jobId,totalAmount,cardLast4,errorCode,errorMessage,resultUncertain);

@override
String toString() {
  return 'PaymentResult(ref: $ref, status: $status, offerId: $offerId, requestId: $requestId, jobId: $jobId, totalAmount: $totalAmount, cardLast4: $cardLast4, errorCode: $errorCode, errorMessage: $errorMessage, resultUncertain: $resultUncertain)';
}


}

/// @nodoc
abstract mixin class $PaymentResultCopyWith<$Res>  {
  factory $PaymentResultCopyWith(PaymentResult value, $Res Function(PaymentResult) _then) = _$PaymentResultCopyWithImpl;
@useResult
$Res call({
 String ref, EscrowStatus status,@JsonKey(fromJson: idFromJsonNullable) String? offerId,@JsonKey(fromJson: idFromJsonNullable) String? requestId,@JsonKey(fromJson: idFromJsonNullable) String? jobId,@MoneyConverter() Money totalAmount, String? cardLast4,@JsonKey(unknownEnumValue: PaymentErrorCode.unknown) PaymentErrorCode? errorCode, String? errorMessage, bool resultUncertain
});




}
/// @nodoc
class _$PaymentResultCopyWithImpl<$Res>
    implements $PaymentResultCopyWith<$Res> {
  _$PaymentResultCopyWithImpl(this._self, this._then);

  final PaymentResult _self;
  final $Res Function(PaymentResult) _then;

/// Create a copy of PaymentResult
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? ref = null,Object? status = null,Object? offerId = freezed,Object? requestId = freezed,Object? jobId = freezed,Object? totalAmount = null,Object? cardLast4 = freezed,Object? errorCode = freezed,Object? errorMessage = freezed,Object? resultUncertain = null,}) {
  return _then(_self.copyWith(
ref: null == ref ? _self.ref : ref // ignore: cast_nullable_to_non_nullable
as String,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as EscrowStatus,offerId: freezed == offerId ? _self.offerId : offerId // ignore: cast_nullable_to_non_nullable
as String?,requestId: freezed == requestId ? _self.requestId : requestId // ignore: cast_nullable_to_non_nullable
as String?,jobId: freezed == jobId ? _self.jobId : jobId // ignore: cast_nullable_to_non_nullable
as String?,totalAmount: null == totalAmount ? _self.totalAmount : totalAmount // ignore: cast_nullable_to_non_nullable
as Money,cardLast4: freezed == cardLast4 ? _self.cardLast4 : cardLast4 // ignore: cast_nullable_to_non_nullable
as String?,errorCode: freezed == errorCode ? _self.errorCode : errorCode // ignore: cast_nullable_to_non_nullable
as PaymentErrorCode?,errorMessage: freezed == errorMessage ? _self.errorMessage : errorMessage // ignore: cast_nullable_to_non_nullable
as String?,resultUncertain: null == resultUncertain ? _self.resultUncertain : resultUncertain // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}

}


/// Adds pattern-matching-related methods to [PaymentResult].
extension PaymentResultPatterns on PaymentResult {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _PaymentResult value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _PaymentResult() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _PaymentResult value)  $default,){
final _that = this;
switch (_that) {
case _PaymentResult():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _PaymentResult value)?  $default,){
final _that = this;
switch (_that) {
case _PaymentResult() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String ref,  EscrowStatus status, @JsonKey(fromJson: idFromJsonNullable)  String? offerId, @JsonKey(fromJson: idFromJsonNullable)  String? requestId, @JsonKey(fromJson: idFromJsonNullable)  String? jobId, @MoneyConverter()  Money totalAmount,  String? cardLast4, @JsonKey(unknownEnumValue: PaymentErrorCode.unknown)  PaymentErrorCode? errorCode,  String? errorMessage,  bool resultUncertain)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _PaymentResult() when $default != null:
return $default(_that.ref,_that.status,_that.offerId,_that.requestId,_that.jobId,_that.totalAmount,_that.cardLast4,_that.errorCode,_that.errorMessage,_that.resultUncertain);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String ref,  EscrowStatus status, @JsonKey(fromJson: idFromJsonNullable)  String? offerId, @JsonKey(fromJson: idFromJsonNullable)  String? requestId, @JsonKey(fromJson: idFromJsonNullable)  String? jobId, @MoneyConverter()  Money totalAmount,  String? cardLast4, @JsonKey(unknownEnumValue: PaymentErrorCode.unknown)  PaymentErrorCode? errorCode,  String? errorMessage,  bool resultUncertain)  $default,) {final _that = this;
switch (_that) {
case _PaymentResult():
return $default(_that.ref,_that.status,_that.offerId,_that.requestId,_that.jobId,_that.totalAmount,_that.cardLast4,_that.errorCode,_that.errorMessage,_that.resultUncertain);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String ref,  EscrowStatus status, @JsonKey(fromJson: idFromJsonNullable)  String? offerId, @JsonKey(fromJson: idFromJsonNullable)  String? requestId, @JsonKey(fromJson: idFromJsonNullable)  String? jobId, @MoneyConverter()  Money totalAmount,  String? cardLast4, @JsonKey(unknownEnumValue: PaymentErrorCode.unknown)  PaymentErrorCode? errorCode,  String? errorMessage,  bool resultUncertain)?  $default,) {final _that = this;
switch (_that) {
case _PaymentResult() when $default != null:
return $default(_that.ref,_that.status,_that.offerId,_that.requestId,_that.jobId,_that.totalAmount,_that.cardLast4,_that.errorCode,_that.errorMessage,_that.resultUncertain);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _PaymentResult implements PaymentResult {
  const _PaymentResult({required this.ref, required this.status, @JsonKey(fromJson: idFromJsonNullable) this.offerId, @JsonKey(fromJson: idFromJsonNullable) this.requestId, @JsonKey(fromJson: idFromJsonNullable) this.jobId, @MoneyConverter() required this.totalAmount, this.cardLast4, @JsonKey(unknownEnumValue: PaymentErrorCode.unknown) this.errorCode, this.errorMessage, this.resultUncertain = false});
  factory _PaymentResult.fromJson(Map<String, dynamic> json) => _$PaymentResultFromJson(json);

@override final  String ref;
@override final  EscrowStatus status;
@override@JsonKey(fromJson: idFromJsonNullable) final  String? offerId;
@override@JsonKey(fromJson: idFromJsonNullable) final  String? requestId;
@override@JsonKey(fromJson: idFromJsonNullable) final  String? jobId;
@override@MoneyConverter() final  Money totalAmount;
@override final  String? cardLast4;
@override@JsonKey(unknownEnumValue: PaymentErrorCode.unknown) final  PaymentErrorCode? errorCode;
@override final  String? errorMessage;
@override@JsonKey() final  bool resultUncertain;

/// Create a copy of PaymentResult
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$PaymentResultCopyWith<_PaymentResult> get copyWith => __$PaymentResultCopyWithImpl<_PaymentResult>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$PaymentResultToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _PaymentResult&&(identical(other.ref, ref) || other.ref == ref)&&(identical(other.status, status) || other.status == status)&&(identical(other.offerId, offerId) || other.offerId == offerId)&&(identical(other.requestId, requestId) || other.requestId == requestId)&&(identical(other.jobId, jobId) || other.jobId == jobId)&&(identical(other.totalAmount, totalAmount) || other.totalAmount == totalAmount)&&(identical(other.cardLast4, cardLast4) || other.cardLast4 == cardLast4)&&(identical(other.errorCode, errorCode) || other.errorCode == errorCode)&&(identical(other.errorMessage, errorMessage) || other.errorMessage == errorMessage)&&(identical(other.resultUncertain, resultUncertain) || other.resultUncertain == resultUncertain));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,ref,status,offerId,requestId,jobId,totalAmount,cardLast4,errorCode,errorMessage,resultUncertain);

@override
String toString() {
  return 'PaymentResult(ref: $ref, status: $status, offerId: $offerId, requestId: $requestId, jobId: $jobId, totalAmount: $totalAmount, cardLast4: $cardLast4, errorCode: $errorCode, errorMessage: $errorMessage, resultUncertain: $resultUncertain)';
}


}

/// @nodoc
abstract mixin class _$PaymentResultCopyWith<$Res> implements $PaymentResultCopyWith<$Res> {
  factory _$PaymentResultCopyWith(_PaymentResult value, $Res Function(_PaymentResult) _then) = __$PaymentResultCopyWithImpl;
@override @useResult
$Res call({
 String ref, EscrowStatus status,@JsonKey(fromJson: idFromJsonNullable) String? offerId,@JsonKey(fromJson: idFromJsonNullable) String? requestId,@JsonKey(fromJson: idFromJsonNullable) String? jobId,@MoneyConverter() Money totalAmount, String? cardLast4,@JsonKey(unknownEnumValue: PaymentErrorCode.unknown) PaymentErrorCode? errorCode, String? errorMessage, bool resultUncertain
});




}
/// @nodoc
class __$PaymentResultCopyWithImpl<$Res>
    implements _$PaymentResultCopyWith<$Res> {
  __$PaymentResultCopyWithImpl(this._self, this._then);

  final _PaymentResult _self;
  final $Res Function(_PaymentResult) _then;

/// Create a copy of PaymentResult
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? ref = null,Object? status = null,Object? offerId = freezed,Object? requestId = freezed,Object? jobId = freezed,Object? totalAmount = null,Object? cardLast4 = freezed,Object? errorCode = freezed,Object? errorMessage = freezed,Object? resultUncertain = null,}) {
  return _then(_PaymentResult(
ref: null == ref ? _self.ref : ref // ignore: cast_nullable_to_non_nullable
as String,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as EscrowStatus,offerId: freezed == offerId ? _self.offerId : offerId // ignore: cast_nullable_to_non_nullable
as String?,requestId: freezed == requestId ? _self.requestId : requestId // ignore: cast_nullable_to_non_nullable
as String?,jobId: freezed == jobId ? _self.jobId : jobId // ignore: cast_nullable_to_non_nullable
as String?,totalAmount: null == totalAmount ? _self.totalAmount : totalAmount // ignore: cast_nullable_to_non_nullable
as Money,cardLast4: freezed == cardLast4 ? _self.cardLast4 : cardLast4 // ignore: cast_nullable_to_non_nullable
as String?,errorCode: freezed == errorCode ? _self.errorCode : errorCode // ignore: cast_nullable_to_non_nullable
as PaymentErrorCode?,errorMessage: freezed == errorMessage ? _self.errorMessage : errorMessage // ignore: cast_nullable_to_non_nullable
as String?,resultUncertain: null == resultUncertain ? _self.resultUncertain : resultUncertain // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}


}

// dart format on
