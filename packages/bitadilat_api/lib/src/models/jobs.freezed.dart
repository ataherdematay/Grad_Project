// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'jobs.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$JobCounterpart {

@JsonKey(fromJson: idFromJson) String get id; String get displayName;
/// Create a copy of JobCounterpart
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$JobCounterpartCopyWith<JobCounterpart> get copyWith => _$JobCounterpartCopyWithImpl<JobCounterpart>(this as JobCounterpart, _$identity);

  /// Serializes this JobCounterpart to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is JobCounterpart&&(identical(other.id, id) || other.id == id)&&(identical(other.displayName, displayName) || other.displayName == displayName));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,displayName);

@override
String toString() {
  return 'JobCounterpart(id: $id, displayName: $displayName)';
}


}

/// @nodoc
abstract mixin class $JobCounterpartCopyWith<$Res>  {
  factory $JobCounterpartCopyWith(JobCounterpart value, $Res Function(JobCounterpart) _then) = _$JobCounterpartCopyWithImpl;
@useResult
$Res call({
@JsonKey(fromJson: idFromJson) String id, String displayName
});




}
/// @nodoc
class _$JobCounterpartCopyWithImpl<$Res>
    implements $JobCounterpartCopyWith<$Res> {
  _$JobCounterpartCopyWithImpl(this._self, this._then);

  final JobCounterpart _self;
  final $Res Function(JobCounterpart) _then;

/// Create a copy of JobCounterpart
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? displayName = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,displayName: null == displayName ? _self.displayName : displayName // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [JobCounterpart].
extension JobCounterpartPatterns on JobCounterpart {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _JobCounterpart value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _JobCounterpart() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _JobCounterpart value)  $default,){
final _that = this;
switch (_that) {
case _JobCounterpart():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _JobCounterpart value)?  $default,){
final _that = this;
switch (_that) {
case _JobCounterpart() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function(@JsonKey(fromJson: idFromJson)  String id,  String displayName)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _JobCounterpart() when $default != null:
return $default(_that.id,_that.displayName);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function(@JsonKey(fromJson: idFromJson)  String id,  String displayName)  $default,) {final _that = this;
switch (_that) {
case _JobCounterpart():
return $default(_that.id,_that.displayName);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function(@JsonKey(fromJson: idFromJson)  String id,  String displayName)?  $default,) {final _that = this;
switch (_that) {
case _JobCounterpart() when $default != null:
return $default(_that.id,_that.displayName);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _JobCounterpart implements JobCounterpart {
  const _JobCounterpart({@JsonKey(fromJson: idFromJson) required this.id, required this.displayName});
  factory _JobCounterpart.fromJson(Map<String, dynamic> json) => _$JobCounterpartFromJson(json);

@override@JsonKey(fromJson: idFromJson) final  String id;
@override final  String displayName;

/// Create a copy of JobCounterpart
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$JobCounterpartCopyWith<_JobCounterpart> get copyWith => __$JobCounterpartCopyWithImpl<_JobCounterpart>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$JobCounterpartToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _JobCounterpart&&(identical(other.id, id) || other.id == id)&&(identical(other.displayName, displayName) || other.displayName == displayName));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,displayName);

@override
String toString() {
  return 'JobCounterpart(id: $id, displayName: $displayName)';
}


}

/// @nodoc
abstract mixin class _$JobCounterpartCopyWith<$Res> implements $JobCounterpartCopyWith<$Res> {
  factory _$JobCounterpartCopyWith(_JobCounterpart value, $Res Function(_JobCounterpart) _then) = __$JobCounterpartCopyWithImpl;
@override @useResult
$Res call({
@JsonKey(fromJson: idFromJson) String id, String displayName
});




}
/// @nodoc
class __$JobCounterpartCopyWithImpl<$Res>
    implements _$JobCounterpartCopyWith<$Res> {
  __$JobCounterpartCopyWithImpl(this._self, this._then);

  final _JobCounterpart _self;
  final $Res Function(_JobCounterpart) _then;

/// Create a copy of JobCounterpart
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? displayName = null,}) {
  return _then(_JobCounterpart(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,displayName: null == displayName ? _self.displayName : displayName // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}


/// @nodoc
mixin _$JobSummary {

@JsonKey(fromJson: idFromJson) String get id; String get publicCode;@JsonKey(fromJson: idFromJson) String get requestId; String get title;@JsonKey(fromJson: idFromJson) String get categoryId; JobStatus get status; PartyRole get viewerRole; JobCounterpart get counterpart;@MoneyConverter() Money get totalAmount; DateTime? get scheduledFrom; DateTime? get scheduledTo; DateTime get updatedAt; int get unreadMessages;
/// Create a copy of JobSummary
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$JobSummaryCopyWith<JobSummary> get copyWith => _$JobSummaryCopyWithImpl<JobSummary>(this as JobSummary, _$identity);

  /// Serializes this JobSummary to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is JobSummary&&(identical(other.id, id) || other.id == id)&&(identical(other.publicCode, publicCode) || other.publicCode == publicCode)&&(identical(other.requestId, requestId) || other.requestId == requestId)&&(identical(other.title, title) || other.title == title)&&(identical(other.categoryId, categoryId) || other.categoryId == categoryId)&&(identical(other.status, status) || other.status == status)&&(identical(other.viewerRole, viewerRole) || other.viewerRole == viewerRole)&&(identical(other.counterpart, counterpart) || other.counterpart == counterpart)&&(identical(other.totalAmount, totalAmount) || other.totalAmount == totalAmount)&&(identical(other.scheduledFrom, scheduledFrom) || other.scheduledFrom == scheduledFrom)&&(identical(other.scheduledTo, scheduledTo) || other.scheduledTo == scheduledTo)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt)&&(identical(other.unreadMessages, unreadMessages) || other.unreadMessages == unreadMessages));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,publicCode,requestId,title,categoryId,status,viewerRole,counterpart,totalAmount,scheduledFrom,scheduledTo,updatedAt,unreadMessages);

@override
String toString() {
  return 'JobSummary(id: $id, publicCode: $publicCode, requestId: $requestId, title: $title, categoryId: $categoryId, status: $status, viewerRole: $viewerRole, counterpart: $counterpart, totalAmount: $totalAmount, scheduledFrom: $scheduledFrom, scheduledTo: $scheduledTo, updatedAt: $updatedAt, unreadMessages: $unreadMessages)';
}


}

/// @nodoc
abstract mixin class $JobSummaryCopyWith<$Res>  {
  factory $JobSummaryCopyWith(JobSummary value, $Res Function(JobSummary) _then) = _$JobSummaryCopyWithImpl;
@useResult
$Res call({
@JsonKey(fromJson: idFromJson) String id, String publicCode,@JsonKey(fromJson: idFromJson) String requestId, String title,@JsonKey(fromJson: idFromJson) String categoryId, JobStatus status, PartyRole viewerRole, JobCounterpart counterpart,@MoneyConverter() Money totalAmount, DateTime? scheduledFrom, DateTime? scheduledTo, DateTime updatedAt, int unreadMessages
});


$JobCounterpartCopyWith<$Res> get counterpart;

}
/// @nodoc
class _$JobSummaryCopyWithImpl<$Res>
    implements $JobSummaryCopyWith<$Res> {
  _$JobSummaryCopyWithImpl(this._self, this._then);

  final JobSummary _self;
  final $Res Function(JobSummary) _then;

/// Create a copy of JobSummary
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? publicCode = null,Object? requestId = null,Object? title = null,Object? categoryId = null,Object? status = null,Object? viewerRole = null,Object? counterpart = null,Object? totalAmount = null,Object? scheduledFrom = freezed,Object? scheduledTo = freezed,Object? updatedAt = null,Object? unreadMessages = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,publicCode: null == publicCode ? _self.publicCode : publicCode // ignore: cast_nullable_to_non_nullable
as String,requestId: null == requestId ? _self.requestId : requestId // ignore: cast_nullable_to_non_nullable
as String,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,categoryId: null == categoryId ? _self.categoryId : categoryId // ignore: cast_nullable_to_non_nullable
as String,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as JobStatus,viewerRole: null == viewerRole ? _self.viewerRole : viewerRole // ignore: cast_nullable_to_non_nullable
as PartyRole,counterpart: null == counterpart ? _self.counterpart : counterpart // ignore: cast_nullable_to_non_nullable
as JobCounterpart,totalAmount: null == totalAmount ? _self.totalAmount : totalAmount // ignore: cast_nullable_to_non_nullable
as Money,scheduledFrom: freezed == scheduledFrom ? _self.scheduledFrom : scheduledFrom // ignore: cast_nullable_to_non_nullable
as DateTime?,scheduledTo: freezed == scheduledTo ? _self.scheduledTo : scheduledTo // ignore: cast_nullable_to_non_nullable
as DateTime?,updatedAt: null == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime,unreadMessages: null == unreadMessages ? _self.unreadMessages : unreadMessages // ignore: cast_nullable_to_non_nullable
as int,
  ));
}
/// Create a copy of JobSummary
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$JobCounterpartCopyWith<$Res> get counterpart {
  
  return $JobCounterpartCopyWith<$Res>(_self.counterpart, (value) {
    return _then(_self.copyWith(counterpart: value));
  });
}
}


/// Adds pattern-matching-related methods to [JobSummary].
extension JobSummaryPatterns on JobSummary {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _JobSummary value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _JobSummary() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _JobSummary value)  $default,){
final _that = this;
switch (_that) {
case _JobSummary():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _JobSummary value)?  $default,){
final _that = this;
switch (_that) {
case _JobSummary() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function(@JsonKey(fromJson: idFromJson)  String id,  String publicCode, @JsonKey(fromJson: idFromJson)  String requestId,  String title, @JsonKey(fromJson: idFromJson)  String categoryId,  JobStatus status,  PartyRole viewerRole,  JobCounterpart counterpart, @MoneyConverter()  Money totalAmount,  DateTime? scheduledFrom,  DateTime? scheduledTo,  DateTime updatedAt,  int unreadMessages)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _JobSummary() when $default != null:
return $default(_that.id,_that.publicCode,_that.requestId,_that.title,_that.categoryId,_that.status,_that.viewerRole,_that.counterpart,_that.totalAmount,_that.scheduledFrom,_that.scheduledTo,_that.updatedAt,_that.unreadMessages);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function(@JsonKey(fromJson: idFromJson)  String id,  String publicCode, @JsonKey(fromJson: idFromJson)  String requestId,  String title, @JsonKey(fromJson: idFromJson)  String categoryId,  JobStatus status,  PartyRole viewerRole,  JobCounterpart counterpart, @MoneyConverter()  Money totalAmount,  DateTime? scheduledFrom,  DateTime? scheduledTo,  DateTime updatedAt,  int unreadMessages)  $default,) {final _that = this;
switch (_that) {
case _JobSummary():
return $default(_that.id,_that.publicCode,_that.requestId,_that.title,_that.categoryId,_that.status,_that.viewerRole,_that.counterpart,_that.totalAmount,_that.scheduledFrom,_that.scheduledTo,_that.updatedAt,_that.unreadMessages);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function(@JsonKey(fromJson: idFromJson)  String id,  String publicCode, @JsonKey(fromJson: idFromJson)  String requestId,  String title, @JsonKey(fromJson: idFromJson)  String categoryId,  JobStatus status,  PartyRole viewerRole,  JobCounterpart counterpart, @MoneyConverter()  Money totalAmount,  DateTime? scheduledFrom,  DateTime? scheduledTo,  DateTime updatedAt,  int unreadMessages)?  $default,) {final _that = this;
switch (_that) {
case _JobSummary() when $default != null:
return $default(_that.id,_that.publicCode,_that.requestId,_that.title,_that.categoryId,_that.status,_that.viewerRole,_that.counterpart,_that.totalAmount,_that.scheduledFrom,_that.scheduledTo,_that.updatedAt,_that.unreadMessages);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _JobSummary implements JobSummary {
  const _JobSummary({@JsonKey(fromJson: idFromJson) required this.id, required this.publicCode, @JsonKey(fromJson: idFromJson) required this.requestId, required this.title, @JsonKey(fromJson: idFromJson) required this.categoryId, required this.status, required this.viewerRole, required this.counterpart, @MoneyConverter() required this.totalAmount, this.scheduledFrom, this.scheduledTo, required this.updatedAt, this.unreadMessages = 0});
  factory _JobSummary.fromJson(Map<String, dynamic> json) => _$JobSummaryFromJson(json);

@override@JsonKey(fromJson: idFromJson) final  String id;
@override final  String publicCode;
@override@JsonKey(fromJson: idFromJson) final  String requestId;
@override final  String title;
@override@JsonKey(fromJson: idFromJson) final  String categoryId;
@override final  JobStatus status;
@override final  PartyRole viewerRole;
@override final  JobCounterpart counterpart;
@override@MoneyConverter() final  Money totalAmount;
@override final  DateTime? scheduledFrom;
@override final  DateTime? scheduledTo;
@override final  DateTime updatedAt;
@override@JsonKey() final  int unreadMessages;

/// Create a copy of JobSummary
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$JobSummaryCopyWith<_JobSummary> get copyWith => __$JobSummaryCopyWithImpl<_JobSummary>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$JobSummaryToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _JobSummary&&(identical(other.id, id) || other.id == id)&&(identical(other.publicCode, publicCode) || other.publicCode == publicCode)&&(identical(other.requestId, requestId) || other.requestId == requestId)&&(identical(other.title, title) || other.title == title)&&(identical(other.categoryId, categoryId) || other.categoryId == categoryId)&&(identical(other.status, status) || other.status == status)&&(identical(other.viewerRole, viewerRole) || other.viewerRole == viewerRole)&&(identical(other.counterpart, counterpart) || other.counterpart == counterpart)&&(identical(other.totalAmount, totalAmount) || other.totalAmount == totalAmount)&&(identical(other.scheduledFrom, scheduledFrom) || other.scheduledFrom == scheduledFrom)&&(identical(other.scheduledTo, scheduledTo) || other.scheduledTo == scheduledTo)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt)&&(identical(other.unreadMessages, unreadMessages) || other.unreadMessages == unreadMessages));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,publicCode,requestId,title,categoryId,status,viewerRole,counterpart,totalAmount,scheduledFrom,scheduledTo,updatedAt,unreadMessages);

@override
String toString() {
  return 'JobSummary(id: $id, publicCode: $publicCode, requestId: $requestId, title: $title, categoryId: $categoryId, status: $status, viewerRole: $viewerRole, counterpart: $counterpart, totalAmount: $totalAmount, scheduledFrom: $scheduledFrom, scheduledTo: $scheduledTo, updatedAt: $updatedAt, unreadMessages: $unreadMessages)';
}


}

/// @nodoc
abstract mixin class _$JobSummaryCopyWith<$Res> implements $JobSummaryCopyWith<$Res> {
  factory _$JobSummaryCopyWith(_JobSummary value, $Res Function(_JobSummary) _then) = __$JobSummaryCopyWithImpl;
@override @useResult
$Res call({
@JsonKey(fromJson: idFromJson) String id, String publicCode,@JsonKey(fromJson: idFromJson) String requestId, String title,@JsonKey(fromJson: idFromJson) String categoryId, JobStatus status, PartyRole viewerRole, JobCounterpart counterpart,@MoneyConverter() Money totalAmount, DateTime? scheduledFrom, DateTime? scheduledTo, DateTime updatedAt, int unreadMessages
});


@override $JobCounterpartCopyWith<$Res> get counterpart;

}
/// @nodoc
class __$JobSummaryCopyWithImpl<$Res>
    implements _$JobSummaryCopyWith<$Res> {
  __$JobSummaryCopyWithImpl(this._self, this._then);

  final _JobSummary _self;
  final $Res Function(_JobSummary) _then;

/// Create a copy of JobSummary
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? publicCode = null,Object? requestId = null,Object? title = null,Object? categoryId = null,Object? status = null,Object? viewerRole = null,Object? counterpart = null,Object? totalAmount = null,Object? scheduledFrom = freezed,Object? scheduledTo = freezed,Object? updatedAt = null,Object? unreadMessages = null,}) {
  return _then(_JobSummary(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,publicCode: null == publicCode ? _self.publicCode : publicCode // ignore: cast_nullable_to_non_nullable
as String,requestId: null == requestId ? _self.requestId : requestId // ignore: cast_nullable_to_non_nullable
as String,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,categoryId: null == categoryId ? _self.categoryId : categoryId // ignore: cast_nullable_to_non_nullable
as String,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as JobStatus,viewerRole: null == viewerRole ? _self.viewerRole : viewerRole // ignore: cast_nullable_to_non_nullable
as PartyRole,counterpart: null == counterpart ? _self.counterpart : counterpart // ignore: cast_nullable_to_non_nullable
as JobCounterpart,totalAmount: null == totalAmount ? _self.totalAmount : totalAmount // ignore: cast_nullable_to_non_nullable
as Money,scheduledFrom: freezed == scheduledFrom ? _self.scheduledFrom : scheduledFrom // ignore: cast_nullable_to_non_nullable
as DateTime?,scheduledTo: freezed == scheduledTo ? _self.scheduledTo : scheduledTo // ignore: cast_nullable_to_non_nullable
as DateTime?,updatedAt: null == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime,unreadMessages: null == unreadMessages ? _self.unreadMessages : unreadMessages // ignore: cast_nullable_to_non_nullable
as int,
  ));
}

/// Create a copy of JobSummary
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$JobCounterpartCopyWith<$Res> get counterpart {
  
  return $JobCounterpartCopyWith<$Res>(_self.counterpart, (value) {
    return _then(_self.copyWith(counterpart: value));
  });
}
}


/// @nodoc
mixin _$JobAddress {

 String get districtName; String get neighborhood; String? get lineFull; String? get doorNote;
/// Create a copy of JobAddress
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$JobAddressCopyWith<JobAddress> get copyWith => _$JobAddressCopyWithImpl<JobAddress>(this as JobAddress, _$identity);

  /// Serializes this JobAddress to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is JobAddress&&(identical(other.districtName, districtName) || other.districtName == districtName)&&(identical(other.neighborhood, neighborhood) || other.neighborhood == neighborhood)&&(identical(other.lineFull, lineFull) || other.lineFull == lineFull)&&(identical(other.doorNote, doorNote) || other.doorNote == doorNote));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,districtName,neighborhood,lineFull,doorNote);

@override
String toString() {
  return 'JobAddress(districtName: $districtName, neighborhood: $neighborhood, lineFull: $lineFull, doorNote: $doorNote)';
}


}

/// @nodoc
abstract mixin class $JobAddressCopyWith<$Res>  {
  factory $JobAddressCopyWith(JobAddress value, $Res Function(JobAddress) _then) = _$JobAddressCopyWithImpl;
@useResult
$Res call({
 String districtName, String neighborhood, String? lineFull, String? doorNote
});




}
/// @nodoc
class _$JobAddressCopyWithImpl<$Res>
    implements $JobAddressCopyWith<$Res> {
  _$JobAddressCopyWithImpl(this._self, this._then);

  final JobAddress _self;
  final $Res Function(JobAddress) _then;

/// Create a copy of JobAddress
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


/// Adds pattern-matching-related methods to [JobAddress].
extension JobAddressPatterns on JobAddress {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _JobAddress value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _JobAddress() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _JobAddress value)  $default,){
final _that = this;
switch (_that) {
case _JobAddress():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _JobAddress value)?  $default,){
final _that = this;
switch (_that) {
case _JobAddress() when $default != null:
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
case _JobAddress() when $default != null:
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
case _JobAddress():
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
case _JobAddress() when $default != null:
return $default(_that.districtName,_that.neighborhood,_that.lineFull,_that.doorNote);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _JobAddress implements JobAddress {
  const _JobAddress({required this.districtName, required this.neighborhood, this.lineFull, this.doorNote});
  factory _JobAddress.fromJson(Map<String, dynamic> json) => _$JobAddressFromJson(json);

@override final  String districtName;
@override final  String neighborhood;
@override final  String? lineFull;
@override final  String? doorNote;

/// Create a copy of JobAddress
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$JobAddressCopyWith<_JobAddress> get copyWith => __$JobAddressCopyWithImpl<_JobAddress>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$JobAddressToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _JobAddress&&(identical(other.districtName, districtName) || other.districtName == districtName)&&(identical(other.neighborhood, neighborhood) || other.neighborhood == neighborhood)&&(identical(other.lineFull, lineFull) || other.lineFull == lineFull)&&(identical(other.doorNote, doorNote) || other.doorNote == doorNote));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,districtName,neighborhood,lineFull,doorNote);

@override
String toString() {
  return 'JobAddress(districtName: $districtName, neighborhood: $neighborhood, lineFull: $lineFull, doorNote: $doorNote)';
}


}

/// @nodoc
abstract mixin class _$JobAddressCopyWith<$Res> implements $JobAddressCopyWith<$Res> {
  factory _$JobAddressCopyWith(_JobAddress value, $Res Function(_JobAddress) _then) = __$JobAddressCopyWithImpl;
@override @useResult
$Res call({
 String districtName, String neighborhood, String? lineFull, String? doorNote
});




}
/// @nodoc
class __$JobAddressCopyWithImpl<$Res>
    implements _$JobAddressCopyWith<$Res> {
  __$JobAddressCopyWithImpl(this._self, this._then);

  final _JobAddress _self;
  final $Res Function(_JobAddress) _then;

/// Create a copy of JobAddress
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? districtName = null,Object? neighborhood = null,Object? lineFull = freezed,Object? doorNote = freezed,}) {
  return _then(_JobAddress(
districtName: null == districtName ? _self.districtName : districtName // ignore: cast_nullable_to_non_nullable
as String,neighborhood: null == neighborhood ? _self.neighborhood : neighborhood // ignore: cast_nullable_to_non_nullable
as String,lineFull: freezed == lineFull ? _self.lineFull : lineFull // ignore: cast_nullable_to_non_nullable
as String?,doorNote: freezed == doorNote ? _self.doorNote : doorNote // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}


/// @nodoc
mixin _$AppointmentProposal {

@JsonKey(fromJson: idFromJson) String get id; PartyRole get proposedBy; DateTime get slotFrom; DateTime get slotTo; DateTime get createdAt;
/// Create a copy of AppointmentProposal
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$AppointmentProposalCopyWith<AppointmentProposal> get copyWith => _$AppointmentProposalCopyWithImpl<AppointmentProposal>(this as AppointmentProposal, _$identity);

  /// Serializes this AppointmentProposal to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is AppointmentProposal&&(identical(other.id, id) || other.id == id)&&(identical(other.proposedBy, proposedBy) || other.proposedBy == proposedBy)&&(identical(other.slotFrom, slotFrom) || other.slotFrom == slotFrom)&&(identical(other.slotTo, slotTo) || other.slotTo == slotTo)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,proposedBy,slotFrom,slotTo,createdAt);

@override
String toString() {
  return 'AppointmentProposal(id: $id, proposedBy: $proposedBy, slotFrom: $slotFrom, slotTo: $slotTo, createdAt: $createdAt)';
}


}

/// @nodoc
abstract mixin class $AppointmentProposalCopyWith<$Res>  {
  factory $AppointmentProposalCopyWith(AppointmentProposal value, $Res Function(AppointmentProposal) _then) = _$AppointmentProposalCopyWithImpl;
@useResult
$Res call({
@JsonKey(fromJson: idFromJson) String id, PartyRole proposedBy, DateTime slotFrom, DateTime slotTo, DateTime createdAt
});




}
/// @nodoc
class _$AppointmentProposalCopyWithImpl<$Res>
    implements $AppointmentProposalCopyWith<$Res> {
  _$AppointmentProposalCopyWithImpl(this._self, this._then);

  final AppointmentProposal _self;
  final $Res Function(AppointmentProposal) _then;

/// Create a copy of AppointmentProposal
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? proposedBy = null,Object? slotFrom = null,Object? slotTo = null,Object? createdAt = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,proposedBy: null == proposedBy ? _self.proposedBy : proposedBy // ignore: cast_nullable_to_non_nullable
as PartyRole,slotFrom: null == slotFrom ? _self.slotFrom : slotFrom // ignore: cast_nullable_to_non_nullable
as DateTime,slotTo: null == slotTo ? _self.slotTo : slotTo // ignore: cast_nullable_to_non_nullable
as DateTime,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}

}


/// Adds pattern-matching-related methods to [AppointmentProposal].
extension AppointmentProposalPatterns on AppointmentProposal {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _AppointmentProposal value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _AppointmentProposal() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _AppointmentProposal value)  $default,){
final _that = this;
switch (_that) {
case _AppointmentProposal():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _AppointmentProposal value)?  $default,){
final _that = this;
switch (_that) {
case _AppointmentProposal() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function(@JsonKey(fromJson: idFromJson)  String id,  PartyRole proposedBy,  DateTime slotFrom,  DateTime slotTo,  DateTime createdAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _AppointmentProposal() when $default != null:
return $default(_that.id,_that.proposedBy,_that.slotFrom,_that.slotTo,_that.createdAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function(@JsonKey(fromJson: idFromJson)  String id,  PartyRole proposedBy,  DateTime slotFrom,  DateTime slotTo,  DateTime createdAt)  $default,) {final _that = this;
switch (_that) {
case _AppointmentProposal():
return $default(_that.id,_that.proposedBy,_that.slotFrom,_that.slotTo,_that.createdAt);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function(@JsonKey(fromJson: idFromJson)  String id,  PartyRole proposedBy,  DateTime slotFrom,  DateTime slotTo,  DateTime createdAt)?  $default,) {final _that = this;
switch (_that) {
case _AppointmentProposal() when $default != null:
return $default(_that.id,_that.proposedBy,_that.slotFrom,_that.slotTo,_that.createdAt);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _AppointmentProposal implements AppointmentProposal {
  const _AppointmentProposal({@JsonKey(fromJson: idFromJson) required this.id, required this.proposedBy, required this.slotFrom, required this.slotTo, required this.createdAt});
  factory _AppointmentProposal.fromJson(Map<String, dynamic> json) => _$AppointmentProposalFromJson(json);

@override@JsonKey(fromJson: idFromJson) final  String id;
@override final  PartyRole proposedBy;
@override final  DateTime slotFrom;
@override final  DateTime slotTo;
@override final  DateTime createdAt;

/// Create a copy of AppointmentProposal
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$AppointmentProposalCopyWith<_AppointmentProposal> get copyWith => __$AppointmentProposalCopyWithImpl<_AppointmentProposal>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$AppointmentProposalToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _AppointmentProposal&&(identical(other.id, id) || other.id == id)&&(identical(other.proposedBy, proposedBy) || other.proposedBy == proposedBy)&&(identical(other.slotFrom, slotFrom) || other.slotFrom == slotFrom)&&(identical(other.slotTo, slotTo) || other.slotTo == slotTo)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,proposedBy,slotFrom,slotTo,createdAt);

@override
String toString() {
  return 'AppointmentProposal(id: $id, proposedBy: $proposedBy, slotFrom: $slotFrom, slotTo: $slotTo, createdAt: $createdAt)';
}


}

/// @nodoc
abstract mixin class _$AppointmentProposalCopyWith<$Res> implements $AppointmentProposalCopyWith<$Res> {
  factory _$AppointmentProposalCopyWith(_AppointmentProposal value, $Res Function(_AppointmentProposal) _then) = __$AppointmentProposalCopyWithImpl;
@override @useResult
$Res call({
@JsonKey(fromJson: idFromJson) String id, PartyRole proposedBy, DateTime slotFrom, DateTime slotTo, DateTime createdAt
});




}
/// @nodoc
class __$AppointmentProposalCopyWithImpl<$Res>
    implements _$AppointmentProposalCopyWith<$Res> {
  __$AppointmentProposalCopyWithImpl(this._self, this._then);

  final _AppointmentProposal _self;
  final $Res Function(_AppointmentProposal) _then;

/// Create a copy of AppointmentProposal
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? proposedBy = null,Object? slotFrom = null,Object? slotTo = null,Object? createdAt = null,}) {
  return _then(_AppointmentProposal(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,proposedBy: null == proposedBy ? _self.proposedBy : proposedBy // ignore: cast_nullable_to_non_nullable
as PartyRole,slotFrom: null == slotFrom ? _self.slotFrom : slotFrom // ignore: cast_nullable_to_non_nullable
as DateTime,slotTo: null == slotTo ? _self.slotTo : slotTo // ignore: cast_nullable_to_non_nullable
as DateTime,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}


}


/// @nodoc
mixin _$JobAppointment {

 DateTime? get scheduledFrom; DateTime? get scheduledTo; AppointmentProposal? get pendingProposal;
/// Create a copy of JobAppointment
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$JobAppointmentCopyWith<JobAppointment> get copyWith => _$JobAppointmentCopyWithImpl<JobAppointment>(this as JobAppointment, _$identity);

  /// Serializes this JobAppointment to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is JobAppointment&&(identical(other.scheduledFrom, scheduledFrom) || other.scheduledFrom == scheduledFrom)&&(identical(other.scheduledTo, scheduledTo) || other.scheduledTo == scheduledTo)&&(identical(other.pendingProposal, pendingProposal) || other.pendingProposal == pendingProposal));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,scheduledFrom,scheduledTo,pendingProposal);

@override
String toString() {
  return 'JobAppointment(scheduledFrom: $scheduledFrom, scheduledTo: $scheduledTo, pendingProposal: $pendingProposal)';
}


}

/// @nodoc
abstract mixin class $JobAppointmentCopyWith<$Res>  {
  factory $JobAppointmentCopyWith(JobAppointment value, $Res Function(JobAppointment) _then) = _$JobAppointmentCopyWithImpl;
@useResult
$Res call({
 DateTime? scheduledFrom, DateTime? scheduledTo, AppointmentProposal? pendingProposal
});


$AppointmentProposalCopyWith<$Res>? get pendingProposal;

}
/// @nodoc
class _$JobAppointmentCopyWithImpl<$Res>
    implements $JobAppointmentCopyWith<$Res> {
  _$JobAppointmentCopyWithImpl(this._self, this._then);

  final JobAppointment _self;
  final $Res Function(JobAppointment) _then;

/// Create a copy of JobAppointment
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? scheduledFrom = freezed,Object? scheduledTo = freezed,Object? pendingProposal = freezed,}) {
  return _then(_self.copyWith(
scheduledFrom: freezed == scheduledFrom ? _self.scheduledFrom : scheduledFrom // ignore: cast_nullable_to_non_nullable
as DateTime?,scheduledTo: freezed == scheduledTo ? _self.scheduledTo : scheduledTo // ignore: cast_nullable_to_non_nullable
as DateTime?,pendingProposal: freezed == pendingProposal ? _self.pendingProposal : pendingProposal // ignore: cast_nullable_to_non_nullable
as AppointmentProposal?,
  ));
}
/// Create a copy of JobAppointment
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$AppointmentProposalCopyWith<$Res>? get pendingProposal {
    if (_self.pendingProposal == null) {
    return null;
  }

  return $AppointmentProposalCopyWith<$Res>(_self.pendingProposal!, (value) {
    return _then(_self.copyWith(pendingProposal: value));
  });
}
}


/// Adds pattern-matching-related methods to [JobAppointment].
extension JobAppointmentPatterns on JobAppointment {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _JobAppointment value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _JobAppointment() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _JobAppointment value)  $default,){
final _that = this;
switch (_that) {
case _JobAppointment():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _JobAppointment value)?  $default,){
final _that = this;
switch (_that) {
case _JobAppointment() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( DateTime? scheduledFrom,  DateTime? scheduledTo,  AppointmentProposal? pendingProposal)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _JobAppointment() when $default != null:
return $default(_that.scheduledFrom,_that.scheduledTo,_that.pendingProposal);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( DateTime? scheduledFrom,  DateTime? scheduledTo,  AppointmentProposal? pendingProposal)  $default,) {final _that = this;
switch (_that) {
case _JobAppointment():
return $default(_that.scheduledFrom,_that.scheduledTo,_that.pendingProposal);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( DateTime? scheduledFrom,  DateTime? scheduledTo,  AppointmentProposal? pendingProposal)?  $default,) {final _that = this;
switch (_that) {
case _JobAppointment() when $default != null:
return $default(_that.scheduledFrom,_that.scheduledTo,_that.pendingProposal);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _JobAppointment implements JobAppointment {
  const _JobAppointment({this.scheduledFrom, this.scheduledTo, this.pendingProposal});
  factory _JobAppointment.fromJson(Map<String, dynamic> json) => _$JobAppointmentFromJson(json);

@override final  DateTime? scheduledFrom;
@override final  DateTime? scheduledTo;
@override final  AppointmentProposal? pendingProposal;

/// Create a copy of JobAppointment
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$JobAppointmentCopyWith<_JobAppointment> get copyWith => __$JobAppointmentCopyWithImpl<_JobAppointment>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$JobAppointmentToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _JobAppointment&&(identical(other.scheduledFrom, scheduledFrom) || other.scheduledFrom == scheduledFrom)&&(identical(other.scheduledTo, scheduledTo) || other.scheduledTo == scheduledTo)&&(identical(other.pendingProposal, pendingProposal) || other.pendingProposal == pendingProposal));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,scheduledFrom,scheduledTo,pendingProposal);

@override
String toString() {
  return 'JobAppointment(scheduledFrom: $scheduledFrom, scheduledTo: $scheduledTo, pendingProposal: $pendingProposal)';
}


}

/// @nodoc
abstract mixin class _$JobAppointmentCopyWith<$Res> implements $JobAppointmentCopyWith<$Res> {
  factory _$JobAppointmentCopyWith(_JobAppointment value, $Res Function(_JobAppointment) _then) = __$JobAppointmentCopyWithImpl;
@override @useResult
$Res call({
 DateTime? scheduledFrom, DateTime? scheduledTo, AppointmentProposal? pendingProposal
});


@override $AppointmentProposalCopyWith<$Res>? get pendingProposal;

}
/// @nodoc
class __$JobAppointmentCopyWithImpl<$Res>
    implements _$JobAppointmentCopyWith<$Res> {
  __$JobAppointmentCopyWithImpl(this._self, this._then);

  final _JobAppointment _self;
  final $Res Function(_JobAppointment) _then;

/// Create a copy of JobAppointment
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? scheduledFrom = freezed,Object? scheduledTo = freezed,Object? pendingProposal = freezed,}) {
  return _then(_JobAppointment(
scheduledFrom: freezed == scheduledFrom ? _self.scheduledFrom : scheduledFrom // ignore: cast_nullable_to_non_nullable
as DateTime?,scheduledTo: freezed == scheduledTo ? _self.scheduledTo : scheduledTo // ignore: cast_nullable_to_non_nullable
as DateTime?,pendingProposal: freezed == pendingProposal ? _self.pendingProposal : pendingProposal // ignore: cast_nullable_to_non_nullable
as AppointmentProposal?,
  ));
}

/// Create a copy of JobAppointment
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$AppointmentProposalCopyWith<$Res>? get pendingProposal {
    if (_self.pendingProposal == null) {
    return null;
  }

  return $AppointmentProposalCopyWith<$Res>(_self.pendingProposal!, (value) {
    return _then(_self.copyWith(pendingProposal: value));
  });
}
}


/// @nodoc
mixin _$JobEvent {

@JsonKey(fromJson: idFromJson) String get id; JobEventType get type; JobStatus? get fromStatus; JobStatus? get toStatus; String? get note; MediaRef? get photo; ActorRole get actorRole; DateTime get createdAt;
/// Create a copy of JobEvent
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$JobEventCopyWith<JobEvent> get copyWith => _$JobEventCopyWithImpl<JobEvent>(this as JobEvent, _$identity);

  /// Serializes this JobEvent to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is JobEvent&&(identical(other.id, id) || other.id == id)&&(identical(other.type, type) || other.type == type)&&(identical(other.fromStatus, fromStatus) || other.fromStatus == fromStatus)&&(identical(other.toStatus, toStatus) || other.toStatus == toStatus)&&(identical(other.note, note) || other.note == note)&&(identical(other.photo, photo) || other.photo == photo)&&(identical(other.actorRole, actorRole) || other.actorRole == actorRole)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,type,fromStatus,toStatus,note,photo,actorRole,createdAt);

@override
String toString() {
  return 'JobEvent(id: $id, type: $type, fromStatus: $fromStatus, toStatus: $toStatus, note: $note, photo: $photo, actorRole: $actorRole, createdAt: $createdAt)';
}


}

/// @nodoc
abstract mixin class $JobEventCopyWith<$Res>  {
  factory $JobEventCopyWith(JobEvent value, $Res Function(JobEvent) _then) = _$JobEventCopyWithImpl;
@useResult
$Res call({
@JsonKey(fromJson: idFromJson) String id, JobEventType type, JobStatus? fromStatus, JobStatus? toStatus, String? note, MediaRef? photo, ActorRole actorRole, DateTime createdAt
});


$MediaRefCopyWith<$Res>? get photo;

}
/// @nodoc
class _$JobEventCopyWithImpl<$Res>
    implements $JobEventCopyWith<$Res> {
  _$JobEventCopyWithImpl(this._self, this._then);

  final JobEvent _self;
  final $Res Function(JobEvent) _then;

/// Create a copy of JobEvent
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? type = null,Object? fromStatus = freezed,Object? toStatus = freezed,Object? note = freezed,Object? photo = freezed,Object? actorRole = null,Object? createdAt = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,type: null == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as JobEventType,fromStatus: freezed == fromStatus ? _self.fromStatus : fromStatus // ignore: cast_nullable_to_non_nullable
as JobStatus?,toStatus: freezed == toStatus ? _self.toStatus : toStatus // ignore: cast_nullable_to_non_nullable
as JobStatus?,note: freezed == note ? _self.note : note // ignore: cast_nullable_to_non_nullable
as String?,photo: freezed == photo ? _self.photo : photo // ignore: cast_nullable_to_non_nullable
as MediaRef?,actorRole: null == actorRole ? _self.actorRole : actorRole // ignore: cast_nullable_to_non_nullable
as ActorRole,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}
/// Create a copy of JobEvent
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$MediaRefCopyWith<$Res>? get photo {
    if (_self.photo == null) {
    return null;
  }

  return $MediaRefCopyWith<$Res>(_self.photo!, (value) {
    return _then(_self.copyWith(photo: value));
  });
}
}


/// Adds pattern-matching-related methods to [JobEvent].
extension JobEventPatterns on JobEvent {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _JobEvent value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _JobEvent() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _JobEvent value)  $default,){
final _that = this;
switch (_that) {
case _JobEvent():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _JobEvent value)?  $default,){
final _that = this;
switch (_that) {
case _JobEvent() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function(@JsonKey(fromJson: idFromJson)  String id,  JobEventType type,  JobStatus? fromStatus,  JobStatus? toStatus,  String? note,  MediaRef? photo,  ActorRole actorRole,  DateTime createdAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _JobEvent() when $default != null:
return $default(_that.id,_that.type,_that.fromStatus,_that.toStatus,_that.note,_that.photo,_that.actorRole,_that.createdAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function(@JsonKey(fromJson: idFromJson)  String id,  JobEventType type,  JobStatus? fromStatus,  JobStatus? toStatus,  String? note,  MediaRef? photo,  ActorRole actorRole,  DateTime createdAt)  $default,) {final _that = this;
switch (_that) {
case _JobEvent():
return $default(_that.id,_that.type,_that.fromStatus,_that.toStatus,_that.note,_that.photo,_that.actorRole,_that.createdAt);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function(@JsonKey(fromJson: idFromJson)  String id,  JobEventType type,  JobStatus? fromStatus,  JobStatus? toStatus,  String? note,  MediaRef? photo,  ActorRole actorRole,  DateTime createdAt)?  $default,) {final _that = this;
switch (_that) {
case _JobEvent() when $default != null:
return $default(_that.id,_that.type,_that.fromStatus,_that.toStatus,_that.note,_that.photo,_that.actorRole,_that.createdAt);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _JobEvent implements JobEvent {
  const _JobEvent({@JsonKey(fromJson: idFromJson) required this.id, required this.type, this.fromStatus, this.toStatus, this.note, this.photo, required this.actorRole, required this.createdAt});
  factory _JobEvent.fromJson(Map<String, dynamic> json) => _$JobEventFromJson(json);

@override@JsonKey(fromJson: idFromJson) final  String id;
@override final  JobEventType type;
@override final  JobStatus? fromStatus;
@override final  JobStatus? toStatus;
@override final  String? note;
@override final  MediaRef? photo;
@override final  ActorRole actorRole;
@override final  DateTime createdAt;

/// Create a copy of JobEvent
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$JobEventCopyWith<_JobEvent> get copyWith => __$JobEventCopyWithImpl<_JobEvent>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$JobEventToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _JobEvent&&(identical(other.id, id) || other.id == id)&&(identical(other.type, type) || other.type == type)&&(identical(other.fromStatus, fromStatus) || other.fromStatus == fromStatus)&&(identical(other.toStatus, toStatus) || other.toStatus == toStatus)&&(identical(other.note, note) || other.note == note)&&(identical(other.photo, photo) || other.photo == photo)&&(identical(other.actorRole, actorRole) || other.actorRole == actorRole)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,type,fromStatus,toStatus,note,photo,actorRole,createdAt);

@override
String toString() {
  return 'JobEvent(id: $id, type: $type, fromStatus: $fromStatus, toStatus: $toStatus, note: $note, photo: $photo, actorRole: $actorRole, createdAt: $createdAt)';
}


}

/// @nodoc
abstract mixin class _$JobEventCopyWith<$Res> implements $JobEventCopyWith<$Res> {
  factory _$JobEventCopyWith(_JobEvent value, $Res Function(_JobEvent) _then) = __$JobEventCopyWithImpl;
@override @useResult
$Res call({
@JsonKey(fromJson: idFromJson) String id, JobEventType type, JobStatus? fromStatus, JobStatus? toStatus, String? note, MediaRef? photo, ActorRole actorRole, DateTime createdAt
});


@override $MediaRefCopyWith<$Res>? get photo;

}
/// @nodoc
class __$JobEventCopyWithImpl<$Res>
    implements _$JobEventCopyWith<$Res> {
  __$JobEventCopyWithImpl(this._self, this._then);

  final _JobEvent _self;
  final $Res Function(_JobEvent) _then;

/// Create a copy of JobEvent
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? type = null,Object? fromStatus = freezed,Object? toStatus = freezed,Object? note = freezed,Object? photo = freezed,Object? actorRole = null,Object? createdAt = null,}) {
  return _then(_JobEvent(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,type: null == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as JobEventType,fromStatus: freezed == fromStatus ? _self.fromStatus : fromStatus // ignore: cast_nullable_to_non_nullable
as JobStatus?,toStatus: freezed == toStatus ? _self.toStatus : toStatus // ignore: cast_nullable_to_non_nullable
as JobStatus?,note: freezed == note ? _self.note : note // ignore: cast_nullable_to_non_nullable
as String?,photo: freezed == photo ? _self.photo : photo // ignore: cast_nullable_to_non_nullable
as MediaRef?,actorRole: null == actorRole ? _self.actorRole : actorRole // ignore: cast_nullable_to_non_nullable
as ActorRole,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}

/// Create a copy of JobEvent
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$MediaRefCopyWith<$Res>? get photo {
    if (_self.photo == null) {
    return null;
  }

  return $MediaRefCopyWith<$Res>(_self.photo!, (value) {
    return _then(_self.copyWith(photo: value));
  });
}
}


/// @nodoc
mixin _$JobPayment {

 String get ref; EscrowStatus get status;@MoneyConverter() Money get totalAmount;@MoneyConverter() Money get refundedAmount;@NullableMoneyConverter() Money? get serviceFee;@NullableMoneyConverter() Money? get netEarning;
/// Create a copy of JobPayment
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$JobPaymentCopyWith<JobPayment> get copyWith => _$JobPaymentCopyWithImpl<JobPayment>(this as JobPayment, _$identity);

  /// Serializes this JobPayment to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is JobPayment&&(identical(other.ref, ref) || other.ref == ref)&&(identical(other.status, status) || other.status == status)&&(identical(other.totalAmount, totalAmount) || other.totalAmount == totalAmount)&&(identical(other.refundedAmount, refundedAmount) || other.refundedAmount == refundedAmount)&&(identical(other.serviceFee, serviceFee) || other.serviceFee == serviceFee)&&(identical(other.netEarning, netEarning) || other.netEarning == netEarning));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,ref,status,totalAmount,refundedAmount,serviceFee,netEarning);

@override
String toString() {
  return 'JobPayment(ref: $ref, status: $status, totalAmount: $totalAmount, refundedAmount: $refundedAmount, serviceFee: $serviceFee, netEarning: $netEarning)';
}


}

/// @nodoc
abstract mixin class $JobPaymentCopyWith<$Res>  {
  factory $JobPaymentCopyWith(JobPayment value, $Res Function(JobPayment) _then) = _$JobPaymentCopyWithImpl;
@useResult
$Res call({
 String ref, EscrowStatus status,@MoneyConverter() Money totalAmount,@MoneyConverter() Money refundedAmount,@NullableMoneyConverter() Money? serviceFee,@NullableMoneyConverter() Money? netEarning
});




}
/// @nodoc
class _$JobPaymentCopyWithImpl<$Res>
    implements $JobPaymentCopyWith<$Res> {
  _$JobPaymentCopyWithImpl(this._self, this._then);

  final JobPayment _self;
  final $Res Function(JobPayment) _then;

/// Create a copy of JobPayment
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? ref = null,Object? status = null,Object? totalAmount = null,Object? refundedAmount = null,Object? serviceFee = freezed,Object? netEarning = freezed,}) {
  return _then(_self.copyWith(
ref: null == ref ? _self.ref : ref // ignore: cast_nullable_to_non_nullable
as String,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as EscrowStatus,totalAmount: null == totalAmount ? _self.totalAmount : totalAmount // ignore: cast_nullable_to_non_nullable
as Money,refundedAmount: null == refundedAmount ? _self.refundedAmount : refundedAmount // ignore: cast_nullable_to_non_nullable
as Money,serviceFee: freezed == serviceFee ? _self.serviceFee : serviceFee // ignore: cast_nullable_to_non_nullable
as Money?,netEarning: freezed == netEarning ? _self.netEarning : netEarning // ignore: cast_nullable_to_non_nullable
as Money?,
  ));
}

}


/// Adds pattern-matching-related methods to [JobPayment].
extension JobPaymentPatterns on JobPayment {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _JobPayment value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _JobPayment() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _JobPayment value)  $default,){
final _that = this;
switch (_that) {
case _JobPayment():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _JobPayment value)?  $default,){
final _that = this;
switch (_that) {
case _JobPayment() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String ref,  EscrowStatus status, @MoneyConverter()  Money totalAmount, @MoneyConverter()  Money refundedAmount, @NullableMoneyConverter()  Money? serviceFee, @NullableMoneyConverter()  Money? netEarning)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _JobPayment() when $default != null:
return $default(_that.ref,_that.status,_that.totalAmount,_that.refundedAmount,_that.serviceFee,_that.netEarning);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String ref,  EscrowStatus status, @MoneyConverter()  Money totalAmount, @MoneyConverter()  Money refundedAmount, @NullableMoneyConverter()  Money? serviceFee, @NullableMoneyConverter()  Money? netEarning)  $default,) {final _that = this;
switch (_that) {
case _JobPayment():
return $default(_that.ref,_that.status,_that.totalAmount,_that.refundedAmount,_that.serviceFee,_that.netEarning);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String ref,  EscrowStatus status, @MoneyConverter()  Money totalAmount, @MoneyConverter()  Money refundedAmount, @NullableMoneyConverter()  Money? serviceFee, @NullableMoneyConverter()  Money? netEarning)?  $default,) {final _that = this;
switch (_that) {
case _JobPayment() when $default != null:
return $default(_that.ref,_that.status,_that.totalAmount,_that.refundedAmount,_that.serviceFee,_that.netEarning);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _JobPayment implements JobPayment {
  const _JobPayment({required this.ref, required this.status, @MoneyConverter() required this.totalAmount, @MoneyConverter() this.refundedAmount = Money.zero, @NullableMoneyConverter() this.serviceFee, @NullableMoneyConverter() this.netEarning});
  factory _JobPayment.fromJson(Map<String, dynamic> json) => _$JobPaymentFromJson(json);

@override final  String ref;
@override final  EscrowStatus status;
@override@MoneyConverter() final  Money totalAmount;
@override@JsonKey()@MoneyConverter() final  Money refundedAmount;
@override@NullableMoneyConverter() final  Money? serviceFee;
@override@NullableMoneyConverter() final  Money? netEarning;

/// Create a copy of JobPayment
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$JobPaymentCopyWith<_JobPayment> get copyWith => __$JobPaymentCopyWithImpl<_JobPayment>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$JobPaymentToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _JobPayment&&(identical(other.ref, ref) || other.ref == ref)&&(identical(other.status, status) || other.status == status)&&(identical(other.totalAmount, totalAmount) || other.totalAmount == totalAmount)&&(identical(other.refundedAmount, refundedAmount) || other.refundedAmount == refundedAmount)&&(identical(other.serviceFee, serviceFee) || other.serviceFee == serviceFee)&&(identical(other.netEarning, netEarning) || other.netEarning == netEarning));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,ref,status,totalAmount,refundedAmount,serviceFee,netEarning);

@override
String toString() {
  return 'JobPayment(ref: $ref, status: $status, totalAmount: $totalAmount, refundedAmount: $refundedAmount, serviceFee: $serviceFee, netEarning: $netEarning)';
}


}

/// @nodoc
abstract mixin class _$JobPaymentCopyWith<$Res> implements $JobPaymentCopyWith<$Res> {
  factory _$JobPaymentCopyWith(_JobPayment value, $Res Function(_JobPayment) _then) = __$JobPaymentCopyWithImpl;
@override @useResult
$Res call({
 String ref, EscrowStatus status,@MoneyConverter() Money totalAmount,@MoneyConverter() Money refundedAmount,@NullableMoneyConverter() Money? serviceFee,@NullableMoneyConverter() Money? netEarning
});




}
/// @nodoc
class __$JobPaymentCopyWithImpl<$Res>
    implements _$JobPaymentCopyWith<$Res> {
  __$JobPaymentCopyWithImpl(this._self, this._then);

  final _JobPayment _self;
  final $Res Function(_JobPayment) _then;

/// Create a copy of JobPayment
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? ref = null,Object? status = null,Object? totalAmount = null,Object? refundedAmount = null,Object? serviceFee = freezed,Object? netEarning = freezed,}) {
  return _then(_JobPayment(
ref: null == ref ? _self.ref : ref // ignore: cast_nullable_to_non_nullable
as String,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as EscrowStatus,totalAmount: null == totalAmount ? _self.totalAmount : totalAmount // ignore: cast_nullable_to_non_nullable
as Money,refundedAmount: null == refundedAmount ? _self.refundedAmount : refundedAmount // ignore: cast_nullable_to_non_nullable
as Money,serviceFee: freezed == serviceFee ? _self.serviceFee : serviceFee // ignore: cast_nullable_to_non_nullable
as Money?,netEarning: freezed == netEarning ? _self.netEarning : netEarning // ignore: cast_nullable_to_non_nullable
as Money?,
  ));
}


}


/// @nodoc
mixin _$ComplaintRef {

@JsonKey(fromJson: idFromJson) String get id; String get publicCode; ComplaintStatus get status;
/// Create a copy of ComplaintRef
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ComplaintRefCopyWith<ComplaintRef> get copyWith => _$ComplaintRefCopyWithImpl<ComplaintRef>(this as ComplaintRef, _$identity);

  /// Serializes this ComplaintRef to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ComplaintRef&&(identical(other.id, id) || other.id == id)&&(identical(other.publicCode, publicCode) || other.publicCode == publicCode)&&(identical(other.status, status) || other.status == status));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,publicCode,status);

@override
String toString() {
  return 'ComplaintRef(id: $id, publicCode: $publicCode, status: $status)';
}


}

/// @nodoc
abstract mixin class $ComplaintRefCopyWith<$Res>  {
  factory $ComplaintRefCopyWith(ComplaintRef value, $Res Function(ComplaintRef) _then) = _$ComplaintRefCopyWithImpl;
@useResult
$Res call({
@JsonKey(fromJson: idFromJson) String id, String publicCode, ComplaintStatus status
});




}
/// @nodoc
class _$ComplaintRefCopyWithImpl<$Res>
    implements $ComplaintRefCopyWith<$Res> {
  _$ComplaintRefCopyWithImpl(this._self, this._then);

  final ComplaintRef _self;
  final $Res Function(ComplaintRef) _then;

/// Create a copy of ComplaintRef
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? publicCode = null,Object? status = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,publicCode: null == publicCode ? _self.publicCode : publicCode // ignore: cast_nullable_to_non_nullable
as String,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as ComplaintStatus,
  ));
}

}


/// Adds pattern-matching-related methods to [ComplaintRef].
extension ComplaintRefPatterns on ComplaintRef {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ComplaintRef value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ComplaintRef() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ComplaintRef value)  $default,){
final _that = this;
switch (_that) {
case _ComplaintRef():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ComplaintRef value)?  $default,){
final _that = this;
switch (_that) {
case _ComplaintRef() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function(@JsonKey(fromJson: idFromJson)  String id,  String publicCode,  ComplaintStatus status)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ComplaintRef() when $default != null:
return $default(_that.id,_that.publicCode,_that.status);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function(@JsonKey(fromJson: idFromJson)  String id,  String publicCode,  ComplaintStatus status)  $default,) {final _that = this;
switch (_that) {
case _ComplaintRef():
return $default(_that.id,_that.publicCode,_that.status);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function(@JsonKey(fromJson: idFromJson)  String id,  String publicCode,  ComplaintStatus status)?  $default,) {final _that = this;
switch (_that) {
case _ComplaintRef() when $default != null:
return $default(_that.id,_that.publicCode,_that.status);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _ComplaintRef implements ComplaintRef {
  const _ComplaintRef({@JsonKey(fromJson: idFromJson) required this.id, required this.publicCode, required this.status});
  factory _ComplaintRef.fromJson(Map<String, dynamic> json) => _$ComplaintRefFromJson(json);

@override@JsonKey(fromJson: idFromJson) final  String id;
@override final  String publicCode;
@override final  ComplaintStatus status;

/// Create a copy of ComplaintRef
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ComplaintRefCopyWith<_ComplaintRef> get copyWith => __$ComplaintRefCopyWithImpl<_ComplaintRef>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ComplaintRefToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ComplaintRef&&(identical(other.id, id) || other.id == id)&&(identical(other.publicCode, publicCode) || other.publicCode == publicCode)&&(identical(other.status, status) || other.status == status));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,publicCode,status);

@override
String toString() {
  return 'ComplaintRef(id: $id, publicCode: $publicCode, status: $status)';
}


}

/// @nodoc
abstract mixin class _$ComplaintRefCopyWith<$Res> implements $ComplaintRefCopyWith<$Res> {
  factory _$ComplaintRefCopyWith(_ComplaintRef value, $Res Function(_ComplaintRef) _then) = __$ComplaintRefCopyWithImpl;
@override @useResult
$Res call({
@JsonKey(fromJson: idFromJson) String id, String publicCode, ComplaintStatus status
});




}
/// @nodoc
class __$ComplaintRefCopyWithImpl<$Res>
    implements _$ComplaintRefCopyWith<$Res> {
  __$ComplaintRefCopyWithImpl(this._self, this._then);

  final _ComplaintRef _self;
  final $Res Function(_ComplaintRef) _then;

/// Create a copy of ComplaintRef
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? publicCode = null,Object? status = null,}) {
  return _then(_ComplaintRef(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,publicCode: null == publicCode ? _self.publicCode : publicCode // ignore: cast_nullable_to_non_nullable
as String,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as ComplaintStatus,
  ));
}


}


/// @nodoc
mixin _$JobDetail {

@JsonKey(fromJson: idFromJson) String get id; String get publicCode;@JsonKey(fromJson: idFromJson) String get requestId; String get title;@JsonKey(fromJson: idFromJson) String get categoryId; JobStatus get status; PartyRole get viewerRole; JobCounterpart get counterpart;@MoneyConverter() Money get totalAmount; DateTime? get scheduledFrom; DateTime? get scheduledTo; DateTime get updatedAt; int get unreadMessages; OfferDetail get offer; JobAddress get address; JobAppointment get appointment; List<JobEvent> get timeline; JobPayment get payment; DateTime? get autoCompleteAt; ReviewItem? get review; ComplaintRef? get complaint; List<String> get allowedActions;
/// Create a copy of JobDetail
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$JobDetailCopyWith<JobDetail> get copyWith => _$JobDetailCopyWithImpl<JobDetail>(this as JobDetail, _$identity);

  /// Serializes this JobDetail to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is JobDetail&&(identical(other.id, id) || other.id == id)&&(identical(other.publicCode, publicCode) || other.publicCode == publicCode)&&(identical(other.requestId, requestId) || other.requestId == requestId)&&(identical(other.title, title) || other.title == title)&&(identical(other.categoryId, categoryId) || other.categoryId == categoryId)&&(identical(other.status, status) || other.status == status)&&(identical(other.viewerRole, viewerRole) || other.viewerRole == viewerRole)&&(identical(other.counterpart, counterpart) || other.counterpart == counterpart)&&(identical(other.totalAmount, totalAmount) || other.totalAmount == totalAmount)&&(identical(other.scheduledFrom, scheduledFrom) || other.scheduledFrom == scheduledFrom)&&(identical(other.scheduledTo, scheduledTo) || other.scheduledTo == scheduledTo)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt)&&(identical(other.unreadMessages, unreadMessages) || other.unreadMessages == unreadMessages)&&(identical(other.offer, offer) || other.offer == offer)&&(identical(other.address, address) || other.address == address)&&(identical(other.appointment, appointment) || other.appointment == appointment)&&const DeepCollectionEquality().equals(other.timeline, timeline)&&(identical(other.payment, payment) || other.payment == payment)&&(identical(other.autoCompleteAt, autoCompleteAt) || other.autoCompleteAt == autoCompleteAt)&&(identical(other.review, review) || other.review == review)&&(identical(other.complaint, complaint) || other.complaint == complaint)&&const DeepCollectionEquality().equals(other.allowedActions, allowedActions));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hashAll([runtimeType,id,publicCode,requestId,title,categoryId,status,viewerRole,counterpart,totalAmount,scheduledFrom,scheduledTo,updatedAt,unreadMessages,offer,address,appointment,const DeepCollectionEquality().hash(timeline),payment,autoCompleteAt,review,complaint,const DeepCollectionEquality().hash(allowedActions)]);

@override
String toString() {
  return 'JobDetail(id: $id, publicCode: $publicCode, requestId: $requestId, title: $title, categoryId: $categoryId, status: $status, viewerRole: $viewerRole, counterpart: $counterpart, totalAmount: $totalAmount, scheduledFrom: $scheduledFrom, scheduledTo: $scheduledTo, updatedAt: $updatedAt, unreadMessages: $unreadMessages, offer: $offer, address: $address, appointment: $appointment, timeline: $timeline, payment: $payment, autoCompleteAt: $autoCompleteAt, review: $review, complaint: $complaint, allowedActions: $allowedActions)';
}


}

/// @nodoc
abstract mixin class $JobDetailCopyWith<$Res>  {
  factory $JobDetailCopyWith(JobDetail value, $Res Function(JobDetail) _then) = _$JobDetailCopyWithImpl;
@useResult
$Res call({
@JsonKey(fromJson: idFromJson) String id, String publicCode,@JsonKey(fromJson: idFromJson) String requestId, String title,@JsonKey(fromJson: idFromJson) String categoryId, JobStatus status, PartyRole viewerRole, JobCounterpart counterpart,@MoneyConverter() Money totalAmount, DateTime? scheduledFrom, DateTime? scheduledTo, DateTime updatedAt, int unreadMessages, OfferDetail offer, JobAddress address, JobAppointment appointment, List<JobEvent> timeline, JobPayment payment, DateTime? autoCompleteAt, ReviewItem? review, ComplaintRef? complaint, List<String> allowedActions
});


$JobCounterpartCopyWith<$Res> get counterpart;$OfferDetailCopyWith<$Res> get offer;$JobAddressCopyWith<$Res> get address;$JobAppointmentCopyWith<$Res> get appointment;$JobPaymentCopyWith<$Res> get payment;$ReviewItemCopyWith<$Res>? get review;$ComplaintRefCopyWith<$Res>? get complaint;

}
/// @nodoc
class _$JobDetailCopyWithImpl<$Res>
    implements $JobDetailCopyWith<$Res> {
  _$JobDetailCopyWithImpl(this._self, this._then);

  final JobDetail _self;
  final $Res Function(JobDetail) _then;

/// Create a copy of JobDetail
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? publicCode = null,Object? requestId = null,Object? title = null,Object? categoryId = null,Object? status = null,Object? viewerRole = null,Object? counterpart = null,Object? totalAmount = null,Object? scheduledFrom = freezed,Object? scheduledTo = freezed,Object? updatedAt = null,Object? unreadMessages = null,Object? offer = null,Object? address = null,Object? appointment = null,Object? timeline = null,Object? payment = null,Object? autoCompleteAt = freezed,Object? review = freezed,Object? complaint = freezed,Object? allowedActions = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,publicCode: null == publicCode ? _self.publicCode : publicCode // ignore: cast_nullable_to_non_nullable
as String,requestId: null == requestId ? _self.requestId : requestId // ignore: cast_nullable_to_non_nullable
as String,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,categoryId: null == categoryId ? _self.categoryId : categoryId // ignore: cast_nullable_to_non_nullable
as String,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as JobStatus,viewerRole: null == viewerRole ? _self.viewerRole : viewerRole // ignore: cast_nullable_to_non_nullable
as PartyRole,counterpart: null == counterpart ? _self.counterpart : counterpart // ignore: cast_nullable_to_non_nullable
as JobCounterpart,totalAmount: null == totalAmount ? _self.totalAmount : totalAmount // ignore: cast_nullable_to_non_nullable
as Money,scheduledFrom: freezed == scheduledFrom ? _self.scheduledFrom : scheduledFrom // ignore: cast_nullable_to_non_nullable
as DateTime?,scheduledTo: freezed == scheduledTo ? _self.scheduledTo : scheduledTo // ignore: cast_nullable_to_non_nullable
as DateTime?,updatedAt: null == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime,unreadMessages: null == unreadMessages ? _self.unreadMessages : unreadMessages // ignore: cast_nullable_to_non_nullable
as int,offer: null == offer ? _self.offer : offer // ignore: cast_nullable_to_non_nullable
as OfferDetail,address: null == address ? _self.address : address // ignore: cast_nullable_to_non_nullable
as JobAddress,appointment: null == appointment ? _self.appointment : appointment // ignore: cast_nullable_to_non_nullable
as JobAppointment,timeline: null == timeline ? _self.timeline : timeline // ignore: cast_nullable_to_non_nullable
as List<JobEvent>,payment: null == payment ? _self.payment : payment // ignore: cast_nullable_to_non_nullable
as JobPayment,autoCompleteAt: freezed == autoCompleteAt ? _self.autoCompleteAt : autoCompleteAt // ignore: cast_nullable_to_non_nullable
as DateTime?,review: freezed == review ? _self.review : review // ignore: cast_nullable_to_non_nullable
as ReviewItem?,complaint: freezed == complaint ? _self.complaint : complaint // ignore: cast_nullable_to_non_nullable
as ComplaintRef?,allowedActions: null == allowedActions ? _self.allowedActions : allowedActions // ignore: cast_nullable_to_non_nullable
as List<String>,
  ));
}
/// Create a copy of JobDetail
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$JobCounterpartCopyWith<$Res> get counterpart {
  
  return $JobCounterpartCopyWith<$Res>(_self.counterpart, (value) {
    return _then(_self.copyWith(counterpart: value));
  });
}/// Create a copy of JobDetail
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$OfferDetailCopyWith<$Res> get offer {
  
  return $OfferDetailCopyWith<$Res>(_self.offer, (value) {
    return _then(_self.copyWith(offer: value));
  });
}/// Create a copy of JobDetail
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$JobAddressCopyWith<$Res> get address {
  
  return $JobAddressCopyWith<$Res>(_self.address, (value) {
    return _then(_self.copyWith(address: value));
  });
}/// Create a copy of JobDetail
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$JobAppointmentCopyWith<$Res> get appointment {
  
  return $JobAppointmentCopyWith<$Res>(_self.appointment, (value) {
    return _then(_self.copyWith(appointment: value));
  });
}/// Create a copy of JobDetail
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$JobPaymentCopyWith<$Res> get payment {
  
  return $JobPaymentCopyWith<$Res>(_self.payment, (value) {
    return _then(_self.copyWith(payment: value));
  });
}/// Create a copy of JobDetail
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$ReviewItemCopyWith<$Res>? get review {
    if (_self.review == null) {
    return null;
  }

  return $ReviewItemCopyWith<$Res>(_self.review!, (value) {
    return _then(_self.copyWith(review: value));
  });
}/// Create a copy of JobDetail
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$ComplaintRefCopyWith<$Res>? get complaint {
    if (_self.complaint == null) {
    return null;
  }

  return $ComplaintRefCopyWith<$Res>(_self.complaint!, (value) {
    return _then(_self.copyWith(complaint: value));
  });
}
}


/// Adds pattern-matching-related methods to [JobDetail].
extension JobDetailPatterns on JobDetail {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _JobDetail value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _JobDetail() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _JobDetail value)  $default,){
final _that = this;
switch (_that) {
case _JobDetail():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _JobDetail value)?  $default,){
final _that = this;
switch (_that) {
case _JobDetail() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function(@JsonKey(fromJson: idFromJson)  String id,  String publicCode, @JsonKey(fromJson: idFromJson)  String requestId,  String title, @JsonKey(fromJson: idFromJson)  String categoryId,  JobStatus status,  PartyRole viewerRole,  JobCounterpart counterpart, @MoneyConverter()  Money totalAmount,  DateTime? scheduledFrom,  DateTime? scheduledTo,  DateTime updatedAt,  int unreadMessages,  OfferDetail offer,  JobAddress address,  JobAppointment appointment,  List<JobEvent> timeline,  JobPayment payment,  DateTime? autoCompleteAt,  ReviewItem? review,  ComplaintRef? complaint,  List<String> allowedActions)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _JobDetail() when $default != null:
return $default(_that.id,_that.publicCode,_that.requestId,_that.title,_that.categoryId,_that.status,_that.viewerRole,_that.counterpart,_that.totalAmount,_that.scheduledFrom,_that.scheduledTo,_that.updatedAt,_that.unreadMessages,_that.offer,_that.address,_that.appointment,_that.timeline,_that.payment,_that.autoCompleteAt,_that.review,_that.complaint,_that.allowedActions);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function(@JsonKey(fromJson: idFromJson)  String id,  String publicCode, @JsonKey(fromJson: idFromJson)  String requestId,  String title, @JsonKey(fromJson: idFromJson)  String categoryId,  JobStatus status,  PartyRole viewerRole,  JobCounterpart counterpart, @MoneyConverter()  Money totalAmount,  DateTime? scheduledFrom,  DateTime? scheduledTo,  DateTime updatedAt,  int unreadMessages,  OfferDetail offer,  JobAddress address,  JobAppointment appointment,  List<JobEvent> timeline,  JobPayment payment,  DateTime? autoCompleteAt,  ReviewItem? review,  ComplaintRef? complaint,  List<String> allowedActions)  $default,) {final _that = this;
switch (_that) {
case _JobDetail():
return $default(_that.id,_that.publicCode,_that.requestId,_that.title,_that.categoryId,_that.status,_that.viewerRole,_that.counterpart,_that.totalAmount,_that.scheduledFrom,_that.scheduledTo,_that.updatedAt,_that.unreadMessages,_that.offer,_that.address,_that.appointment,_that.timeline,_that.payment,_that.autoCompleteAt,_that.review,_that.complaint,_that.allowedActions);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function(@JsonKey(fromJson: idFromJson)  String id,  String publicCode, @JsonKey(fromJson: idFromJson)  String requestId,  String title, @JsonKey(fromJson: idFromJson)  String categoryId,  JobStatus status,  PartyRole viewerRole,  JobCounterpart counterpart, @MoneyConverter()  Money totalAmount,  DateTime? scheduledFrom,  DateTime? scheduledTo,  DateTime updatedAt,  int unreadMessages,  OfferDetail offer,  JobAddress address,  JobAppointment appointment,  List<JobEvent> timeline,  JobPayment payment,  DateTime? autoCompleteAt,  ReviewItem? review,  ComplaintRef? complaint,  List<String> allowedActions)?  $default,) {final _that = this;
switch (_that) {
case _JobDetail() when $default != null:
return $default(_that.id,_that.publicCode,_that.requestId,_that.title,_that.categoryId,_that.status,_that.viewerRole,_that.counterpart,_that.totalAmount,_that.scheduledFrom,_that.scheduledTo,_that.updatedAt,_that.unreadMessages,_that.offer,_that.address,_that.appointment,_that.timeline,_that.payment,_that.autoCompleteAt,_that.review,_that.complaint,_that.allowedActions);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _JobDetail extends JobDetail {
  const _JobDetail({@JsonKey(fromJson: idFromJson) required this.id, required this.publicCode, @JsonKey(fromJson: idFromJson) required this.requestId, required this.title, @JsonKey(fromJson: idFromJson) required this.categoryId, required this.status, required this.viewerRole, required this.counterpart, @MoneyConverter() required this.totalAmount, this.scheduledFrom, this.scheduledTo, required this.updatedAt, this.unreadMessages = 0, required this.offer, required this.address, required this.appointment, this.timeline = const <JobEvent>[], required this.payment, this.autoCompleteAt, this.review, this.complaint, this.allowedActions = const <String>[]}): super._();
  factory _JobDetail.fromJson(Map<String, dynamic> json) => _$JobDetailFromJson(json);

@override@JsonKey(fromJson: idFromJson) final  String id;
@override final  String publicCode;
@override@JsonKey(fromJson: idFromJson) final  String requestId;
@override final  String title;
@override@JsonKey(fromJson: idFromJson) final  String categoryId;
@override final  JobStatus status;
@override final  PartyRole viewerRole;
@override final  JobCounterpart counterpart;
@override@MoneyConverter() final  Money totalAmount;
@override final  DateTime? scheduledFrom;
@override final  DateTime? scheduledTo;
@override final  DateTime updatedAt;
@override@JsonKey() final  int unreadMessages;
@override final  OfferDetail offer;
@override final  JobAddress address;
@override final  JobAppointment appointment;
@override@JsonKey() final  List<JobEvent> timeline;
@override final  JobPayment payment;
@override final  DateTime? autoCompleteAt;
@override final  ReviewItem? review;
@override final  ComplaintRef? complaint;
@override@JsonKey() final  List<String> allowedActions;

/// Create a copy of JobDetail
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$JobDetailCopyWith<_JobDetail> get copyWith => __$JobDetailCopyWithImpl<_JobDetail>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$JobDetailToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _JobDetail&&(identical(other.id, id) || other.id == id)&&(identical(other.publicCode, publicCode) || other.publicCode == publicCode)&&(identical(other.requestId, requestId) || other.requestId == requestId)&&(identical(other.title, title) || other.title == title)&&(identical(other.categoryId, categoryId) || other.categoryId == categoryId)&&(identical(other.status, status) || other.status == status)&&(identical(other.viewerRole, viewerRole) || other.viewerRole == viewerRole)&&(identical(other.counterpart, counterpart) || other.counterpart == counterpart)&&(identical(other.totalAmount, totalAmount) || other.totalAmount == totalAmount)&&(identical(other.scheduledFrom, scheduledFrom) || other.scheduledFrom == scheduledFrom)&&(identical(other.scheduledTo, scheduledTo) || other.scheduledTo == scheduledTo)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt)&&(identical(other.unreadMessages, unreadMessages) || other.unreadMessages == unreadMessages)&&(identical(other.offer, offer) || other.offer == offer)&&(identical(other.address, address) || other.address == address)&&(identical(other.appointment, appointment) || other.appointment == appointment)&&const DeepCollectionEquality().equals(other.timeline, timeline)&&(identical(other.payment, payment) || other.payment == payment)&&(identical(other.autoCompleteAt, autoCompleteAt) || other.autoCompleteAt == autoCompleteAt)&&(identical(other.review, review) || other.review == review)&&(identical(other.complaint, complaint) || other.complaint == complaint)&&const DeepCollectionEquality().equals(other.allowedActions, allowedActions));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hashAll([runtimeType,id,publicCode,requestId,title,categoryId,status,viewerRole,counterpart,totalAmount,scheduledFrom,scheduledTo,updatedAt,unreadMessages,offer,address,appointment,const DeepCollectionEquality().hash(timeline),payment,autoCompleteAt,review,complaint,const DeepCollectionEquality().hash(allowedActions)]);

@override
String toString() {
  return 'JobDetail(id: $id, publicCode: $publicCode, requestId: $requestId, title: $title, categoryId: $categoryId, status: $status, viewerRole: $viewerRole, counterpart: $counterpart, totalAmount: $totalAmount, scheduledFrom: $scheduledFrom, scheduledTo: $scheduledTo, updatedAt: $updatedAt, unreadMessages: $unreadMessages, offer: $offer, address: $address, appointment: $appointment, timeline: $timeline, payment: $payment, autoCompleteAt: $autoCompleteAt, review: $review, complaint: $complaint, allowedActions: $allowedActions)';
}


}

/// @nodoc
abstract mixin class _$JobDetailCopyWith<$Res> implements $JobDetailCopyWith<$Res> {
  factory _$JobDetailCopyWith(_JobDetail value, $Res Function(_JobDetail) _then) = __$JobDetailCopyWithImpl;
@override @useResult
$Res call({
@JsonKey(fromJson: idFromJson) String id, String publicCode,@JsonKey(fromJson: idFromJson) String requestId, String title,@JsonKey(fromJson: idFromJson) String categoryId, JobStatus status, PartyRole viewerRole, JobCounterpart counterpart,@MoneyConverter() Money totalAmount, DateTime? scheduledFrom, DateTime? scheduledTo, DateTime updatedAt, int unreadMessages, OfferDetail offer, JobAddress address, JobAppointment appointment, List<JobEvent> timeline, JobPayment payment, DateTime? autoCompleteAt, ReviewItem? review, ComplaintRef? complaint, List<String> allowedActions
});


@override $JobCounterpartCopyWith<$Res> get counterpart;@override $OfferDetailCopyWith<$Res> get offer;@override $JobAddressCopyWith<$Res> get address;@override $JobAppointmentCopyWith<$Res> get appointment;@override $JobPaymentCopyWith<$Res> get payment;@override $ReviewItemCopyWith<$Res>? get review;@override $ComplaintRefCopyWith<$Res>? get complaint;

}
/// @nodoc
class __$JobDetailCopyWithImpl<$Res>
    implements _$JobDetailCopyWith<$Res> {
  __$JobDetailCopyWithImpl(this._self, this._then);

  final _JobDetail _self;
  final $Res Function(_JobDetail) _then;

/// Create a copy of JobDetail
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? publicCode = null,Object? requestId = null,Object? title = null,Object? categoryId = null,Object? status = null,Object? viewerRole = null,Object? counterpart = null,Object? totalAmount = null,Object? scheduledFrom = freezed,Object? scheduledTo = freezed,Object? updatedAt = null,Object? unreadMessages = null,Object? offer = null,Object? address = null,Object? appointment = null,Object? timeline = null,Object? payment = null,Object? autoCompleteAt = freezed,Object? review = freezed,Object? complaint = freezed,Object? allowedActions = null,}) {
  return _then(_JobDetail(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,publicCode: null == publicCode ? _self.publicCode : publicCode // ignore: cast_nullable_to_non_nullable
as String,requestId: null == requestId ? _self.requestId : requestId // ignore: cast_nullable_to_non_nullable
as String,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,categoryId: null == categoryId ? _self.categoryId : categoryId // ignore: cast_nullable_to_non_nullable
as String,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as JobStatus,viewerRole: null == viewerRole ? _self.viewerRole : viewerRole // ignore: cast_nullable_to_non_nullable
as PartyRole,counterpart: null == counterpart ? _self.counterpart : counterpart // ignore: cast_nullable_to_non_nullable
as JobCounterpart,totalAmount: null == totalAmount ? _self.totalAmount : totalAmount // ignore: cast_nullable_to_non_nullable
as Money,scheduledFrom: freezed == scheduledFrom ? _self.scheduledFrom : scheduledFrom // ignore: cast_nullable_to_non_nullable
as DateTime?,scheduledTo: freezed == scheduledTo ? _self.scheduledTo : scheduledTo // ignore: cast_nullable_to_non_nullable
as DateTime?,updatedAt: null == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime,unreadMessages: null == unreadMessages ? _self.unreadMessages : unreadMessages // ignore: cast_nullable_to_non_nullable
as int,offer: null == offer ? _self.offer : offer // ignore: cast_nullable_to_non_nullable
as OfferDetail,address: null == address ? _self.address : address // ignore: cast_nullable_to_non_nullable
as JobAddress,appointment: null == appointment ? _self.appointment : appointment // ignore: cast_nullable_to_non_nullable
as JobAppointment,timeline: null == timeline ? _self.timeline : timeline // ignore: cast_nullable_to_non_nullable
as List<JobEvent>,payment: null == payment ? _self.payment : payment // ignore: cast_nullable_to_non_nullable
as JobPayment,autoCompleteAt: freezed == autoCompleteAt ? _self.autoCompleteAt : autoCompleteAt // ignore: cast_nullable_to_non_nullable
as DateTime?,review: freezed == review ? _self.review : review // ignore: cast_nullable_to_non_nullable
as ReviewItem?,complaint: freezed == complaint ? _self.complaint : complaint // ignore: cast_nullable_to_non_nullable
as ComplaintRef?,allowedActions: null == allowedActions ? _self.allowedActions : allowedActions // ignore: cast_nullable_to_non_nullable
as List<String>,
  ));
}

/// Create a copy of JobDetail
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$JobCounterpartCopyWith<$Res> get counterpart {
  
  return $JobCounterpartCopyWith<$Res>(_self.counterpart, (value) {
    return _then(_self.copyWith(counterpart: value));
  });
}/// Create a copy of JobDetail
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$OfferDetailCopyWith<$Res> get offer {
  
  return $OfferDetailCopyWith<$Res>(_self.offer, (value) {
    return _then(_self.copyWith(offer: value));
  });
}/// Create a copy of JobDetail
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$JobAddressCopyWith<$Res> get address {
  
  return $JobAddressCopyWith<$Res>(_self.address, (value) {
    return _then(_self.copyWith(address: value));
  });
}/// Create a copy of JobDetail
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$JobAppointmentCopyWith<$Res> get appointment {
  
  return $JobAppointmentCopyWith<$Res>(_self.appointment, (value) {
    return _then(_self.copyWith(appointment: value));
  });
}/// Create a copy of JobDetail
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$JobPaymentCopyWith<$Res> get payment {
  
  return $JobPaymentCopyWith<$Res>(_self.payment, (value) {
    return _then(_self.copyWith(payment: value));
  });
}/// Create a copy of JobDetail
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$ReviewItemCopyWith<$Res>? get review {
    if (_self.review == null) {
    return null;
  }

  return $ReviewItemCopyWith<$Res>(_self.review!, (value) {
    return _then(_self.copyWith(review: value));
  });
}/// Create a copy of JobDetail
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$ComplaintRefCopyWith<$Res>? get complaint {
    if (_self.complaint == null) {
    return null;
  }

  return $ComplaintRefCopyWith<$Res>(_self.complaint!, (value) {
    return _then(_self.copyWith(complaint: value));
  });
}
}


/// @nodoc
mixin _$ProposeSlotRequest {

 DateTime get slotFrom; DateTime get slotTo;
/// Create a copy of ProposeSlotRequest
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ProposeSlotRequestCopyWith<ProposeSlotRequest> get copyWith => _$ProposeSlotRequestCopyWithImpl<ProposeSlotRequest>(this as ProposeSlotRequest, _$identity);

  /// Serializes this ProposeSlotRequest to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ProposeSlotRequest&&(identical(other.slotFrom, slotFrom) || other.slotFrom == slotFrom)&&(identical(other.slotTo, slotTo) || other.slotTo == slotTo));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,slotFrom,slotTo);

@override
String toString() {
  return 'ProposeSlotRequest(slotFrom: $slotFrom, slotTo: $slotTo)';
}


}

/// @nodoc
abstract mixin class $ProposeSlotRequestCopyWith<$Res>  {
  factory $ProposeSlotRequestCopyWith(ProposeSlotRequest value, $Res Function(ProposeSlotRequest) _then) = _$ProposeSlotRequestCopyWithImpl;
@useResult
$Res call({
 DateTime slotFrom, DateTime slotTo
});




}
/// @nodoc
class _$ProposeSlotRequestCopyWithImpl<$Res>
    implements $ProposeSlotRequestCopyWith<$Res> {
  _$ProposeSlotRequestCopyWithImpl(this._self, this._then);

  final ProposeSlotRequest _self;
  final $Res Function(ProposeSlotRequest) _then;

/// Create a copy of ProposeSlotRequest
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? slotFrom = null,Object? slotTo = null,}) {
  return _then(_self.copyWith(
slotFrom: null == slotFrom ? _self.slotFrom : slotFrom // ignore: cast_nullable_to_non_nullable
as DateTime,slotTo: null == slotTo ? _self.slotTo : slotTo // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}

}


/// Adds pattern-matching-related methods to [ProposeSlotRequest].
extension ProposeSlotRequestPatterns on ProposeSlotRequest {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ProposeSlotRequest value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ProposeSlotRequest() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ProposeSlotRequest value)  $default,){
final _that = this;
switch (_that) {
case _ProposeSlotRequest():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ProposeSlotRequest value)?  $default,){
final _that = this;
switch (_that) {
case _ProposeSlotRequest() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( DateTime slotFrom,  DateTime slotTo)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ProposeSlotRequest() when $default != null:
return $default(_that.slotFrom,_that.slotTo);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( DateTime slotFrom,  DateTime slotTo)  $default,) {final _that = this;
switch (_that) {
case _ProposeSlotRequest():
return $default(_that.slotFrom,_that.slotTo);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( DateTime slotFrom,  DateTime slotTo)?  $default,) {final _that = this;
switch (_that) {
case _ProposeSlotRequest() when $default != null:
return $default(_that.slotFrom,_that.slotTo);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _ProposeSlotRequest implements ProposeSlotRequest {
  const _ProposeSlotRequest({required this.slotFrom, required this.slotTo});
  factory _ProposeSlotRequest.fromJson(Map<String, dynamic> json) => _$ProposeSlotRequestFromJson(json);

@override final  DateTime slotFrom;
@override final  DateTime slotTo;

/// Create a copy of ProposeSlotRequest
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ProposeSlotRequestCopyWith<_ProposeSlotRequest> get copyWith => __$ProposeSlotRequestCopyWithImpl<_ProposeSlotRequest>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ProposeSlotRequestToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ProposeSlotRequest&&(identical(other.slotFrom, slotFrom) || other.slotFrom == slotFrom)&&(identical(other.slotTo, slotTo) || other.slotTo == slotTo));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,slotFrom,slotTo);

@override
String toString() {
  return 'ProposeSlotRequest(slotFrom: $slotFrom, slotTo: $slotTo)';
}


}

/// @nodoc
abstract mixin class _$ProposeSlotRequestCopyWith<$Res> implements $ProposeSlotRequestCopyWith<$Res> {
  factory _$ProposeSlotRequestCopyWith(_ProposeSlotRequest value, $Res Function(_ProposeSlotRequest) _then) = __$ProposeSlotRequestCopyWithImpl;
@override @useResult
$Res call({
 DateTime slotFrom, DateTime slotTo
});




}
/// @nodoc
class __$ProposeSlotRequestCopyWithImpl<$Res>
    implements _$ProposeSlotRequestCopyWith<$Res> {
  __$ProposeSlotRequestCopyWithImpl(this._self, this._then);

  final _ProposeSlotRequest _self;
  final $Res Function(_ProposeSlotRequest) _then;

/// Create a copy of ProposeSlotRequest
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? slotFrom = null,Object? slotTo = null,}) {
  return _then(_ProposeSlotRequest(
slotFrom: null == slotFrom ? _self.slotFrom : slotFrom // ignore: cast_nullable_to_non_nullable
as DateTime,slotTo: null == slotTo ? _self.slotTo : slotTo // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}


}


/// @nodoc
mixin _$FinishJobRequest {

 String get note;@JsonKey(toJson: idListToJson, fromJson: idListFromJson) List<String> get photoIds;
/// Create a copy of FinishJobRequest
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$FinishJobRequestCopyWith<FinishJobRequest> get copyWith => _$FinishJobRequestCopyWithImpl<FinishJobRequest>(this as FinishJobRequest, _$identity);

  /// Serializes this FinishJobRequest to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is FinishJobRequest&&(identical(other.note, note) || other.note == note)&&const DeepCollectionEquality().equals(other.photoIds, photoIds));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,note,const DeepCollectionEquality().hash(photoIds));

@override
String toString() {
  return 'FinishJobRequest(note: $note, photoIds: $photoIds)';
}


}

/// @nodoc
abstract mixin class $FinishJobRequestCopyWith<$Res>  {
  factory $FinishJobRequestCopyWith(FinishJobRequest value, $Res Function(FinishJobRequest) _then) = _$FinishJobRequestCopyWithImpl;
@useResult
$Res call({
 String note,@JsonKey(toJson: idListToJson, fromJson: idListFromJson) List<String> photoIds
});




}
/// @nodoc
class _$FinishJobRequestCopyWithImpl<$Res>
    implements $FinishJobRequestCopyWith<$Res> {
  _$FinishJobRequestCopyWithImpl(this._self, this._then);

  final FinishJobRequest _self;
  final $Res Function(FinishJobRequest) _then;

/// Create a copy of FinishJobRequest
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? note = null,Object? photoIds = null,}) {
  return _then(_self.copyWith(
note: null == note ? _self.note : note // ignore: cast_nullable_to_non_nullable
as String,photoIds: null == photoIds ? _self.photoIds : photoIds // ignore: cast_nullable_to_non_nullable
as List<String>,
  ));
}

}


/// Adds pattern-matching-related methods to [FinishJobRequest].
extension FinishJobRequestPatterns on FinishJobRequest {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _FinishJobRequest value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _FinishJobRequest() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _FinishJobRequest value)  $default,){
final _that = this;
switch (_that) {
case _FinishJobRequest():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _FinishJobRequest value)?  $default,){
final _that = this;
switch (_that) {
case _FinishJobRequest() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String note, @JsonKey(toJson: idListToJson, fromJson: idListFromJson)  List<String> photoIds)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _FinishJobRequest() when $default != null:
return $default(_that.note,_that.photoIds);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String note, @JsonKey(toJson: idListToJson, fromJson: idListFromJson)  List<String> photoIds)  $default,) {final _that = this;
switch (_that) {
case _FinishJobRequest():
return $default(_that.note,_that.photoIds);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String note, @JsonKey(toJson: idListToJson, fromJson: idListFromJson)  List<String> photoIds)?  $default,) {final _that = this;
switch (_that) {
case _FinishJobRequest() when $default != null:
return $default(_that.note,_that.photoIds);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _FinishJobRequest implements FinishJobRequest {
  const _FinishJobRequest({required this.note, @JsonKey(toJson: idListToJson, fromJson: idListFromJson) this.photoIds = const <String>[]});
  factory _FinishJobRequest.fromJson(Map<String, dynamic> json) => _$FinishJobRequestFromJson(json);

@override final  String note;
@override@JsonKey(toJson: idListToJson, fromJson: idListFromJson) final  List<String> photoIds;

/// Create a copy of FinishJobRequest
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$FinishJobRequestCopyWith<_FinishJobRequest> get copyWith => __$FinishJobRequestCopyWithImpl<_FinishJobRequest>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$FinishJobRequestToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _FinishJobRequest&&(identical(other.note, note) || other.note == note)&&const DeepCollectionEquality().equals(other.photoIds, photoIds));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,note,const DeepCollectionEquality().hash(photoIds));

@override
String toString() {
  return 'FinishJobRequest(note: $note, photoIds: $photoIds)';
}


}

/// @nodoc
abstract mixin class _$FinishJobRequestCopyWith<$Res> implements $FinishJobRequestCopyWith<$Res> {
  factory _$FinishJobRequestCopyWith(_FinishJobRequest value, $Res Function(_FinishJobRequest) _then) = __$FinishJobRequestCopyWithImpl;
@override @useResult
$Res call({
 String note,@JsonKey(toJson: idListToJson, fromJson: idListFromJson) List<String> photoIds
});




}
/// @nodoc
class __$FinishJobRequestCopyWithImpl<$Res>
    implements _$FinishJobRequestCopyWith<$Res> {
  __$FinishJobRequestCopyWithImpl(this._self, this._then);

  final _FinishJobRequest _self;
  final $Res Function(_FinishJobRequest) _then;

/// Create a copy of FinishJobRequest
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? note = null,Object? photoIds = null,}) {
  return _then(_FinishJobRequest(
note: null == note ? _self.note : note // ignore: cast_nullable_to_non_nullable
as String,photoIds: null == photoIds ? _self.photoIds : photoIds // ignore: cast_nullable_to_non_nullable
as List<String>,
  ));
}


}


/// @nodoc
mixin _$JobNoteRequest {

@JsonKey(includeIfNull: false) String? get note;@JsonKey(toJson: idListToJson, fromJson: idListFromJson) List<String> get photoIds;
/// Create a copy of JobNoteRequest
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$JobNoteRequestCopyWith<JobNoteRequest> get copyWith => _$JobNoteRequestCopyWithImpl<JobNoteRequest>(this as JobNoteRequest, _$identity);

  /// Serializes this JobNoteRequest to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is JobNoteRequest&&(identical(other.note, note) || other.note == note)&&const DeepCollectionEquality().equals(other.photoIds, photoIds));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,note,const DeepCollectionEquality().hash(photoIds));

@override
String toString() {
  return 'JobNoteRequest(note: $note, photoIds: $photoIds)';
}


}

/// @nodoc
abstract mixin class $JobNoteRequestCopyWith<$Res>  {
  factory $JobNoteRequestCopyWith(JobNoteRequest value, $Res Function(JobNoteRequest) _then) = _$JobNoteRequestCopyWithImpl;
@useResult
$Res call({
@JsonKey(includeIfNull: false) String? note,@JsonKey(toJson: idListToJson, fromJson: idListFromJson) List<String> photoIds
});




}
/// @nodoc
class _$JobNoteRequestCopyWithImpl<$Res>
    implements $JobNoteRequestCopyWith<$Res> {
  _$JobNoteRequestCopyWithImpl(this._self, this._then);

  final JobNoteRequest _self;
  final $Res Function(JobNoteRequest) _then;

/// Create a copy of JobNoteRequest
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? note = freezed,Object? photoIds = null,}) {
  return _then(_self.copyWith(
note: freezed == note ? _self.note : note // ignore: cast_nullable_to_non_nullable
as String?,photoIds: null == photoIds ? _self.photoIds : photoIds // ignore: cast_nullable_to_non_nullable
as List<String>,
  ));
}

}


/// Adds pattern-matching-related methods to [JobNoteRequest].
extension JobNoteRequestPatterns on JobNoteRequest {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _JobNoteRequest value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _JobNoteRequest() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _JobNoteRequest value)  $default,){
final _that = this;
switch (_that) {
case _JobNoteRequest():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _JobNoteRequest value)?  $default,){
final _that = this;
switch (_that) {
case _JobNoteRequest() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function(@JsonKey(includeIfNull: false)  String? note, @JsonKey(toJson: idListToJson, fromJson: idListFromJson)  List<String> photoIds)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _JobNoteRequest() when $default != null:
return $default(_that.note,_that.photoIds);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function(@JsonKey(includeIfNull: false)  String? note, @JsonKey(toJson: idListToJson, fromJson: idListFromJson)  List<String> photoIds)  $default,) {final _that = this;
switch (_that) {
case _JobNoteRequest():
return $default(_that.note,_that.photoIds);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function(@JsonKey(includeIfNull: false)  String? note, @JsonKey(toJson: idListToJson, fromJson: idListFromJson)  List<String> photoIds)?  $default,) {final _that = this;
switch (_that) {
case _JobNoteRequest() when $default != null:
return $default(_that.note,_that.photoIds);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _JobNoteRequest implements JobNoteRequest {
  const _JobNoteRequest({@JsonKey(includeIfNull: false) this.note, @JsonKey(toJson: idListToJson, fromJson: idListFromJson) this.photoIds = const <String>[]});
  factory _JobNoteRequest.fromJson(Map<String, dynamic> json) => _$JobNoteRequestFromJson(json);

@override@JsonKey(includeIfNull: false) final  String? note;
@override@JsonKey(toJson: idListToJson, fromJson: idListFromJson) final  List<String> photoIds;

/// Create a copy of JobNoteRequest
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$JobNoteRequestCopyWith<_JobNoteRequest> get copyWith => __$JobNoteRequestCopyWithImpl<_JobNoteRequest>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$JobNoteRequestToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _JobNoteRequest&&(identical(other.note, note) || other.note == note)&&const DeepCollectionEquality().equals(other.photoIds, photoIds));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,note,const DeepCollectionEquality().hash(photoIds));

@override
String toString() {
  return 'JobNoteRequest(note: $note, photoIds: $photoIds)';
}


}

/// @nodoc
abstract mixin class _$JobNoteRequestCopyWith<$Res> implements $JobNoteRequestCopyWith<$Res> {
  factory _$JobNoteRequestCopyWith(_JobNoteRequest value, $Res Function(_JobNoteRequest) _then) = __$JobNoteRequestCopyWithImpl;
@override @useResult
$Res call({
@JsonKey(includeIfNull: false) String? note,@JsonKey(toJson: idListToJson, fromJson: idListFromJson) List<String> photoIds
});




}
/// @nodoc
class __$JobNoteRequestCopyWithImpl<$Res>
    implements _$JobNoteRequestCopyWith<$Res> {
  __$JobNoteRequestCopyWithImpl(this._self, this._then);

  final _JobNoteRequest _self;
  final $Res Function(_JobNoteRequest) _then;

/// Create a copy of JobNoteRequest
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? note = freezed,Object? photoIds = null,}) {
  return _then(_JobNoteRequest(
note: freezed == note ? _self.note : note // ignore: cast_nullable_to_non_nullable
as String?,photoIds: null == photoIds ? _self.photoIds : photoIds // ignore: cast_nullable_to_non_nullable
as List<String>,
  ));
}


}


/// @nodoc
mixin _$CancelJobRequest {

 String get reason;@JsonKey(includeIfNull: false) String? get note;
/// Create a copy of CancelJobRequest
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$CancelJobRequestCopyWith<CancelJobRequest> get copyWith => _$CancelJobRequestCopyWithImpl<CancelJobRequest>(this as CancelJobRequest, _$identity);

  /// Serializes this CancelJobRequest to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is CancelJobRequest&&(identical(other.reason, reason) || other.reason == reason)&&(identical(other.note, note) || other.note == note));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,reason,note);

@override
String toString() {
  return 'CancelJobRequest(reason: $reason, note: $note)';
}


}

/// @nodoc
abstract mixin class $CancelJobRequestCopyWith<$Res>  {
  factory $CancelJobRequestCopyWith(CancelJobRequest value, $Res Function(CancelJobRequest) _then) = _$CancelJobRequestCopyWithImpl;
@useResult
$Res call({
 String reason,@JsonKey(includeIfNull: false) String? note
});




}
/// @nodoc
class _$CancelJobRequestCopyWithImpl<$Res>
    implements $CancelJobRequestCopyWith<$Res> {
  _$CancelJobRequestCopyWithImpl(this._self, this._then);

  final CancelJobRequest _self;
  final $Res Function(CancelJobRequest) _then;

/// Create a copy of CancelJobRequest
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? reason = null,Object? note = freezed,}) {
  return _then(_self.copyWith(
reason: null == reason ? _self.reason : reason // ignore: cast_nullable_to_non_nullable
as String,note: freezed == note ? _self.note : note // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [CancelJobRequest].
extension CancelJobRequestPatterns on CancelJobRequest {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _CancelJobRequest value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _CancelJobRequest() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _CancelJobRequest value)  $default,){
final _that = this;
switch (_that) {
case _CancelJobRequest():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _CancelJobRequest value)?  $default,){
final _that = this;
switch (_that) {
case _CancelJobRequest() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String reason, @JsonKey(includeIfNull: false)  String? note)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _CancelJobRequest() when $default != null:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String reason, @JsonKey(includeIfNull: false)  String? note)  $default,) {final _that = this;
switch (_that) {
case _CancelJobRequest():
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String reason, @JsonKey(includeIfNull: false)  String? note)?  $default,) {final _that = this;
switch (_that) {
case _CancelJobRequest() when $default != null:
return $default(_that.reason,_that.note);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _CancelJobRequest implements CancelJobRequest {
  const _CancelJobRequest({required this.reason, @JsonKey(includeIfNull: false) this.note});
  factory _CancelJobRequest.fromJson(Map<String, dynamic> json) => _$CancelJobRequestFromJson(json);

@override final  String reason;
@override@JsonKey(includeIfNull: false) final  String? note;

/// Create a copy of CancelJobRequest
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$CancelJobRequestCopyWith<_CancelJobRequest> get copyWith => __$CancelJobRequestCopyWithImpl<_CancelJobRequest>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$CancelJobRequestToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _CancelJobRequest&&(identical(other.reason, reason) || other.reason == reason)&&(identical(other.note, note) || other.note == note));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,reason,note);

@override
String toString() {
  return 'CancelJobRequest(reason: $reason, note: $note)';
}


}

/// @nodoc
abstract mixin class _$CancelJobRequestCopyWith<$Res> implements $CancelJobRequestCopyWith<$Res> {
  factory _$CancelJobRequestCopyWith(_CancelJobRequest value, $Res Function(_CancelJobRequest) _then) = __$CancelJobRequestCopyWithImpl;
@override @useResult
$Res call({
 String reason,@JsonKey(includeIfNull: false) String? note
});




}
/// @nodoc
class __$CancelJobRequestCopyWithImpl<$Res>
    implements _$CancelJobRequestCopyWith<$Res> {
  __$CancelJobRequestCopyWithImpl(this._self, this._then);

  final _CancelJobRequest _self;
  final $Res Function(_CancelJobRequest) _then;

/// Create a copy of CancelJobRequest
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? reason = null,Object? note = freezed,}) {
  return _then(_CancelJobRequest(
reason: null == reason ? _self.reason : reason // ignore: cast_nullable_to_non_nullable
as String,note: freezed == note ? _self.note : note // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}


/// @nodoc
mixin _$ReviewRequest {

 int get rating; List<ReviewTag> get tags; String get comment; bool get anonymous;
/// Create a copy of ReviewRequest
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ReviewRequestCopyWith<ReviewRequest> get copyWith => _$ReviewRequestCopyWithImpl<ReviewRequest>(this as ReviewRequest, _$identity);

  /// Serializes this ReviewRequest to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ReviewRequest&&(identical(other.rating, rating) || other.rating == rating)&&const DeepCollectionEquality().equals(other.tags, tags)&&(identical(other.comment, comment) || other.comment == comment)&&(identical(other.anonymous, anonymous) || other.anonymous == anonymous));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,rating,const DeepCollectionEquality().hash(tags),comment,anonymous);

@override
String toString() {
  return 'ReviewRequest(rating: $rating, tags: $tags, comment: $comment, anonymous: $anonymous)';
}


}

/// @nodoc
abstract mixin class $ReviewRequestCopyWith<$Res>  {
  factory $ReviewRequestCopyWith(ReviewRequest value, $Res Function(ReviewRequest) _then) = _$ReviewRequestCopyWithImpl;
@useResult
$Res call({
 int rating, List<ReviewTag> tags, String comment, bool anonymous
});




}
/// @nodoc
class _$ReviewRequestCopyWithImpl<$Res>
    implements $ReviewRequestCopyWith<$Res> {
  _$ReviewRequestCopyWithImpl(this._self, this._then);

  final ReviewRequest _self;
  final $Res Function(ReviewRequest) _then;

/// Create a copy of ReviewRequest
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? rating = null,Object? tags = null,Object? comment = null,Object? anonymous = null,}) {
  return _then(_self.copyWith(
rating: null == rating ? _self.rating : rating // ignore: cast_nullable_to_non_nullable
as int,tags: null == tags ? _self.tags : tags // ignore: cast_nullable_to_non_nullable
as List<ReviewTag>,comment: null == comment ? _self.comment : comment // ignore: cast_nullable_to_non_nullable
as String,anonymous: null == anonymous ? _self.anonymous : anonymous // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}

}


/// Adds pattern-matching-related methods to [ReviewRequest].
extension ReviewRequestPatterns on ReviewRequest {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ReviewRequest value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ReviewRequest() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ReviewRequest value)  $default,){
final _that = this;
switch (_that) {
case _ReviewRequest():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ReviewRequest value)?  $default,){
final _that = this;
switch (_that) {
case _ReviewRequest() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int rating,  List<ReviewTag> tags,  String comment,  bool anonymous)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ReviewRequest() when $default != null:
return $default(_that.rating,_that.tags,_that.comment,_that.anonymous);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int rating,  List<ReviewTag> tags,  String comment,  bool anonymous)  $default,) {final _that = this;
switch (_that) {
case _ReviewRequest():
return $default(_that.rating,_that.tags,_that.comment,_that.anonymous);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int rating,  List<ReviewTag> tags,  String comment,  bool anonymous)?  $default,) {final _that = this;
switch (_that) {
case _ReviewRequest() when $default != null:
return $default(_that.rating,_that.tags,_that.comment,_that.anonymous);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _ReviewRequest implements ReviewRequest {
  const _ReviewRequest({required this.rating, this.tags = const <ReviewTag>[], this.comment = '', this.anonymous = false});
  factory _ReviewRequest.fromJson(Map<String, dynamic> json) => _$ReviewRequestFromJson(json);

@override final  int rating;
@override@JsonKey() final  List<ReviewTag> tags;
@override@JsonKey() final  String comment;
@override@JsonKey() final  bool anonymous;

/// Create a copy of ReviewRequest
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ReviewRequestCopyWith<_ReviewRequest> get copyWith => __$ReviewRequestCopyWithImpl<_ReviewRequest>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ReviewRequestToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ReviewRequest&&(identical(other.rating, rating) || other.rating == rating)&&const DeepCollectionEquality().equals(other.tags, tags)&&(identical(other.comment, comment) || other.comment == comment)&&(identical(other.anonymous, anonymous) || other.anonymous == anonymous));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,rating,const DeepCollectionEquality().hash(tags),comment,anonymous);

@override
String toString() {
  return 'ReviewRequest(rating: $rating, tags: $tags, comment: $comment, anonymous: $anonymous)';
}


}

/// @nodoc
abstract mixin class _$ReviewRequestCopyWith<$Res> implements $ReviewRequestCopyWith<$Res> {
  factory _$ReviewRequestCopyWith(_ReviewRequest value, $Res Function(_ReviewRequest) _then) = __$ReviewRequestCopyWithImpl;
@override @useResult
$Res call({
 int rating, List<ReviewTag> tags, String comment, bool anonymous
});




}
/// @nodoc
class __$ReviewRequestCopyWithImpl<$Res>
    implements _$ReviewRequestCopyWith<$Res> {
  __$ReviewRequestCopyWithImpl(this._self, this._then);

  final _ReviewRequest _self;
  final $Res Function(_ReviewRequest) _then;

/// Create a copy of ReviewRequest
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? rating = null,Object? tags = null,Object? comment = null,Object? anonymous = null,}) {
  return _then(_ReviewRequest(
rating: null == rating ? _self.rating : rating // ignore: cast_nullable_to_non_nullable
as int,tags: null == tags ? _self.tags : tags // ignore: cast_nullable_to_non_nullable
as List<ReviewTag>,comment: null == comment ? _self.comment : comment // ignore: cast_nullable_to_non_nullable
as String,anonymous: null == anonymous ? _self.anonymous : anonymous // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}


}


/// @nodoc
mixin _$ComplaintRequest {

 ComplaintReason get reason; String get description;@JsonKey(toJson: idListToJson, fromJson: idListFromJson) List<String> get evidenceIds;
/// Create a copy of ComplaintRequest
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ComplaintRequestCopyWith<ComplaintRequest> get copyWith => _$ComplaintRequestCopyWithImpl<ComplaintRequest>(this as ComplaintRequest, _$identity);

  /// Serializes this ComplaintRequest to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ComplaintRequest&&(identical(other.reason, reason) || other.reason == reason)&&(identical(other.description, description) || other.description == description)&&const DeepCollectionEquality().equals(other.evidenceIds, evidenceIds));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,reason,description,const DeepCollectionEquality().hash(evidenceIds));

@override
String toString() {
  return 'ComplaintRequest(reason: $reason, description: $description, evidenceIds: $evidenceIds)';
}


}

/// @nodoc
abstract mixin class $ComplaintRequestCopyWith<$Res>  {
  factory $ComplaintRequestCopyWith(ComplaintRequest value, $Res Function(ComplaintRequest) _then) = _$ComplaintRequestCopyWithImpl;
@useResult
$Res call({
 ComplaintReason reason, String description,@JsonKey(toJson: idListToJson, fromJson: idListFromJson) List<String> evidenceIds
});




}
/// @nodoc
class _$ComplaintRequestCopyWithImpl<$Res>
    implements $ComplaintRequestCopyWith<$Res> {
  _$ComplaintRequestCopyWithImpl(this._self, this._then);

  final ComplaintRequest _self;
  final $Res Function(ComplaintRequest) _then;

/// Create a copy of ComplaintRequest
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? reason = null,Object? description = null,Object? evidenceIds = null,}) {
  return _then(_self.copyWith(
reason: null == reason ? _self.reason : reason // ignore: cast_nullable_to_non_nullable
as ComplaintReason,description: null == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String,evidenceIds: null == evidenceIds ? _self.evidenceIds : evidenceIds // ignore: cast_nullable_to_non_nullable
as List<String>,
  ));
}

}


/// Adds pattern-matching-related methods to [ComplaintRequest].
extension ComplaintRequestPatterns on ComplaintRequest {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ComplaintRequest value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ComplaintRequest() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ComplaintRequest value)  $default,){
final _that = this;
switch (_that) {
case _ComplaintRequest():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ComplaintRequest value)?  $default,){
final _that = this;
switch (_that) {
case _ComplaintRequest() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( ComplaintReason reason,  String description, @JsonKey(toJson: idListToJson, fromJson: idListFromJson)  List<String> evidenceIds)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ComplaintRequest() when $default != null:
return $default(_that.reason,_that.description,_that.evidenceIds);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( ComplaintReason reason,  String description, @JsonKey(toJson: idListToJson, fromJson: idListFromJson)  List<String> evidenceIds)  $default,) {final _that = this;
switch (_that) {
case _ComplaintRequest():
return $default(_that.reason,_that.description,_that.evidenceIds);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( ComplaintReason reason,  String description, @JsonKey(toJson: idListToJson, fromJson: idListFromJson)  List<String> evidenceIds)?  $default,) {final _that = this;
switch (_that) {
case _ComplaintRequest() when $default != null:
return $default(_that.reason,_that.description,_that.evidenceIds);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _ComplaintRequest implements ComplaintRequest {
  const _ComplaintRequest({required this.reason, required this.description, @JsonKey(toJson: idListToJson, fromJson: idListFromJson) this.evidenceIds = const <String>[]});
  factory _ComplaintRequest.fromJson(Map<String, dynamic> json) => _$ComplaintRequestFromJson(json);

@override final  ComplaintReason reason;
@override final  String description;
@override@JsonKey(toJson: idListToJson, fromJson: idListFromJson) final  List<String> evidenceIds;

/// Create a copy of ComplaintRequest
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ComplaintRequestCopyWith<_ComplaintRequest> get copyWith => __$ComplaintRequestCopyWithImpl<_ComplaintRequest>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ComplaintRequestToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ComplaintRequest&&(identical(other.reason, reason) || other.reason == reason)&&(identical(other.description, description) || other.description == description)&&const DeepCollectionEquality().equals(other.evidenceIds, evidenceIds));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,reason,description,const DeepCollectionEquality().hash(evidenceIds));

@override
String toString() {
  return 'ComplaintRequest(reason: $reason, description: $description, evidenceIds: $evidenceIds)';
}


}

/// @nodoc
abstract mixin class _$ComplaintRequestCopyWith<$Res> implements $ComplaintRequestCopyWith<$Res> {
  factory _$ComplaintRequestCopyWith(_ComplaintRequest value, $Res Function(_ComplaintRequest) _then) = __$ComplaintRequestCopyWithImpl;
@override @useResult
$Res call({
 ComplaintReason reason, String description,@JsonKey(toJson: idListToJson, fromJson: idListFromJson) List<String> evidenceIds
});




}
/// @nodoc
class __$ComplaintRequestCopyWithImpl<$Res>
    implements _$ComplaintRequestCopyWith<$Res> {
  __$ComplaintRequestCopyWithImpl(this._self, this._then);

  final _ComplaintRequest _self;
  final $Res Function(_ComplaintRequest) _then;

/// Create a copy of ComplaintRequest
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? reason = null,Object? description = null,Object? evidenceIds = null,}) {
  return _then(_ComplaintRequest(
reason: null == reason ? _self.reason : reason // ignore: cast_nullable_to_non_nullable
as ComplaintReason,description: null == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String,evidenceIds: null == evidenceIds ? _self.evidenceIds : evidenceIds // ignore: cast_nullable_to_non_nullable
as List<String>,
  ));
}


}


/// @nodoc
mixin _$Complaint {

@JsonKey(fromJson: idFromJson) String get id; String get publicCode;@JsonKey(fromJson: idFromJson) String get jobId; ComplaintReason get reason; String get description; List<MediaRef> get evidence; ComplaintStatus get status; String? get decision; String? get decisionNote; DateTime get createdAt; DateTime? get decidedAt;
/// Create a copy of Complaint
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ComplaintCopyWith<Complaint> get copyWith => _$ComplaintCopyWithImpl<Complaint>(this as Complaint, _$identity);

  /// Serializes this Complaint to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Complaint&&(identical(other.id, id) || other.id == id)&&(identical(other.publicCode, publicCode) || other.publicCode == publicCode)&&(identical(other.jobId, jobId) || other.jobId == jobId)&&(identical(other.reason, reason) || other.reason == reason)&&(identical(other.description, description) || other.description == description)&&const DeepCollectionEquality().equals(other.evidence, evidence)&&(identical(other.status, status) || other.status == status)&&(identical(other.decision, decision) || other.decision == decision)&&(identical(other.decisionNote, decisionNote) || other.decisionNote == decisionNote)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.decidedAt, decidedAt) || other.decidedAt == decidedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,publicCode,jobId,reason,description,const DeepCollectionEquality().hash(evidence),status,decision,decisionNote,createdAt,decidedAt);

@override
String toString() {
  return 'Complaint(id: $id, publicCode: $publicCode, jobId: $jobId, reason: $reason, description: $description, evidence: $evidence, status: $status, decision: $decision, decisionNote: $decisionNote, createdAt: $createdAt, decidedAt: $decidedAt)';
}


}

/// @nodoc
abstract mixin class $ComplaintCopyWith<$Res>  {
  factory $ComplaintCopyWith(Complaint value, $Res Function(Complaint) _then) = _$ComplaintCopyWithImpl;
@useResult
$Res call({
@JsonKey(fromJson: idFromJson) String id, String publicCode,@JsonKey(fromJson: idFromJson) String jobId, ComplaintReason reason, String description, List<MediaRef> evidence, ComplaintStatus status, String? decision, String? decisionNote, DateTime createdAt, DateTime? decidedAt
});




}
/// @nodoc
class _$ComplaintCopyWithImpl<$Res>
    implements $ComplaintCopyWith<$Res> {
  _$ComplaintCopyWithImpl(this._self, this._then);

  final Complaint _self;
  final $Res Function(Complaint) _then;

/// Create a copy of Complaint
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? publicCode = null,Object? jobId = null,Object? reason = null,Object? description = null,Object? evidence = null,Object? status = null,Object? decision = freezed,Object? decisionNote = freezed,Object? createdAt = null,Object? decidedAt = freezed,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,publicCode: null == publicCode ? _self.publicCode : publicCode // ignore: cast_nullable_to_non_nullable
as String,jobId: null == jobId ? _self.jobId : jobId // ignore: cast_nullable_to_non_nullable
as String,reason: null == reason ? _self.reason : reason // ignore: cast_nullable_to_non_nullable
as ComplaintReason,description: null == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String,evidence: null == evidence ? _self.evidence : evidence // ignore: cast_nullable_to_non_nullable
as List<MediaRef>,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as ComplaintStatus,decision: freezed == decision ? _self.decision : decision // ignore: cast_nullable_to_non_nullable
as String?,decisionNote: freezed == decisionNote ? _self.decisionNote : decisionNote // ignore: cast_nullable_to_non_nullable
as String?,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,decidedAt: freezed == decidedAt ? _self.decidedAt : decidedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}

}


/// Adds pattern-matching-related methods to [Complaint].
extension ComplaintPatterns on Complaint {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _Complaint value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _Complaint() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _Complaint value)  $default,){
final _that = this;
switch (_that) {
case _Complaint():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _Complaint value)?  $default,){
final _that = this;
switch (_that) {
case _Complaint() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function(@JsonKey(fromJson: idFromJson)  String id,  String publicCode, @JsonKey(fromJson: idFromJson)  String jobId,  ComplaintReason reason,  String description,  List<MediaRef> evidence,  ComplaintStatus status,  String? decision,  String? decisionNote,  DateTime createdAt,  DateTime? decidedAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Complaint() when $default != null:
return $default(_that.id,_that.publicCode,_that.jobId,_that.reason,_that.description,_that.evidence,_that.status,_that.decision,_that.decisionNote,_that.createdAt,_that.decidedAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function(@JsonKey(fromJson: idFromJson)  String id,  String publicCode, @JsonKey(fromJson: idFromJson)  String jobId,  ComplaintReason reason,  String description,  List<MediaRef> evidence,  ComplaintStatus status,  String? decision,  String? decisionNote,  DateTime createdAt,  DateTime? decidedAt)  $default,) {final _that = this;
switch (_that) {
case _Complaint():
return $default(_that.id,_that.publicCode,_that.jobId,_that.reason,_that.description,_that.evidence,_that.status,_that.decision,_that.decisionNote,_that.createdAt,_that.decidedAt);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function(@JsonKey(fromJson: idFromJson)  String id,  String publicCode, @JsonKey(fromJson: idFromJson)  String jobId,  ComplaintReason reason,  String description,  List<MediaRef> evidence,  ComplaintStatus status,  String? decision,  String? decisionNote,  DateTime createdAt,  DateTime? decidedAt)?  $default,) {final _that = this;
switch (_that) {
case _Complaint() when $default != null:
return $default(_that.id,_that.publicCode,_that.jobId,_that.reason,_that.description,_that.evidence,_that.status,_that.decision,_that.decisionNote,_that.createdAt,_that.decidedAt);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _Complaint implements Complaint {
  const _Complaint({@JsonKey(fromJson: idFromJson) required this.id, required this.publicCode, @JsonKey(fromJson: idFromJson) required this.jobId, required this.reason, required this.description, this.evidence = const <MediaRef>[], required this.status, this.decision, this.decisionNote, required this.createdAt, this.decidedAt});
  factory _Complaint.fromJson(Map<String, dynamic> json) => _$ComplaintFromJson(json);

@override@JsonKey(fromJson: idFromJson) final  String id;
@override final  String publicCode;
@override@JsonKey(fromJson: idFromJson) final  String jobId;
@override final  ComplaintReason reason;
@override final  String description;
@override@JsonKey() final  List<MediaRef> evidence;
@override final  ComplaintStatus status;
@override final  String? decision;
@override final  String? decisionNote;
@override final  DateTime createdAt;
@override final  DateTime? decidedAt;

/// Create a copy of Complaint
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ComplaintCopyWith<_Complaint> get copyWith => __$ComplaintCopyWithImpl<_Complaint>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ComplaintToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _Complaint&&(identical(other.id, id) || other.id == id)&&(identical(other.publicCode, publicCode) || other.publicCode == publicCode)&&(identical(other.jobId, jobId) || other.jobId == jobId)&&(identical(other.reason, reason) || other.reason == reason)&&(identical(other.description, description) || other.description == description)&&const DeepCollectionEquality().equals(other.evidence, evidence)&&(identical(other.status, status) || other.status == status)&&(identical(other.decision, decision) || other.decision == decision)&&(identical(other.decisionNote, decisionNote) || other.decisionNote == decisionNote)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.decidedAt, decidedAt) || other.decidedAt == decidedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,publicCode,jobId,reason,description,const DeepCollectionEquality().hash(evidence),status,decision,decisionNote,createdAt,decidedAt);

@override
String toString() {
  return 'Complaint(id: $id, publicCode: $publicCode, jobId: $jobId, reason: $reason, description: $description, evidence: $evidence, status: $status, decision: $decision, decisionNote: $decisionNote, createdAt: $createdAt, decidedAt: $decidedAt)';
}


}

/// @nodoc
abstract mixin class _$ComplaintCopyWith<$Res> implements $ComplaintCopyWith<$Res> {
  factory _$ComplaintCopyWith(_Complaint value, $Res Function(_Complaint) _then) = __$ComplaintCopyWithImpl;
@override @useResult
$Res call({
@JsonKey(fromJson: idFromJson) String id, String publicCode,@JsonKey(fromJson: idFromJson) String jobId, ComplaintReason reason, String description, List<MediaRef> evidence, ComplaintStatus status, String? decision, String? decisionNote, DateTime createdAt, DateTime? decidedAt
});




}
/// @nodoc
class __$ComplaintCopyWithImpl<$Res>
    implements _$ComplaintCopyWith<$Res> {
  __$ComplaintCopyWithImpl(this._self, this._then);

  final _Complaint _self;
  final $Res Function(_Complaint) _then;

/// Create a copy of Complaint
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? publicCode = null,Object? jobId = null,Object? reason = null,Object? description = null,Object? evidence = null,Object? status = null,Object? decision = freezed,Object? decisionNote = freezed,Object? createdAt = null,Object? decidedAt = freezed,}) {
  return _then(_Complaint(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,publicCode: null == publicCode ? _self.publicCode : publicCode // ignore: cast_nullable_to_non_nullable
as String,jobId: null == jobId ? _self.jobId : jobId // ignore: cast_nullable_to_non_nullable
as String,reason: null == reason ? _self.reason : reason // ignore: cast_nullable_to_non_nullable
as ComplaintReason,description: null == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String,evidence: null == evidence ? _self.evidence : evidence // ignore: cast_nullable_to_non_nullable
as List<MediaRef>,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as ComplaintStatus,decision: freezed == decision ? _self.decision : decision // ignore: cast_nullable_to_non_nullable
as String?,decisionNote: freezed == decisionNote ? _self.decisionNote : decisionNote // ignore: cast_nullable_to_non_nullable
as String?,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,decidedAt: freezed == decidedAt ? _self.decidedAt : decidedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}


}

// dart format on
