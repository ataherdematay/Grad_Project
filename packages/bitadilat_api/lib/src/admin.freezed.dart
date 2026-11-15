// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'admin.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$AdminStats {

 int get pendingApplications; int get openComplaints; int get activeJobs;@MoneyConverter() Money get lockedEscrowTotal;
/// Create a copy of AdminStats
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$AdminStatsCopyWith<AdminStats> get copyWith => _$AdminStatsCopyWithImpl<AdminStats>(this as AdminStats, _$identity);

  /// Serializes this AdminStats to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is AdminStats&&(identical(other.pendingApplications, pendingApplications) || other.pendingApplications == pendingApplications)&&(identical(other.openComplaints, openComplaints) || other.openComplaints == openComplaints)&&(identical(other.activeJobs, activeJobs) || other.activeJobs == activeJobs)&&(identical(other.lockedEscrowTotal, lockedEscrowTotal) || other.lockedEscrowTotal == lockedEscrowTotal));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,pendingApplications,openComplaints,activeJobs,lockedEscrowTotal);

@override
String toString() {
  return 'AdminStats(pendingApplications: $pendingApplications, openComplaints: $openComplaints, activeJobs: $activeJobs, lockedEscrowTotal: $lockedEscrowTotal)';
}


}

/// @nodoc
abstract mixin class $AdminStatsCopyWith<$Res>  {
  factory $AdminStatsCopyWith(AdminStats value, $Res Function(AdminStats) _then) = _$AdminStatsCopyWithImpl;
@useResult
$Res call({
 int pendingApplications, int openComplaints, int activeJobs,@MoneyConverter() Money lockedEscrowTotal
});




}
/// @nodoc
class _$AdminStatsCopyWithImpl<$Res>
    implements $AdminStatsCopyWith<$Res> {
  _$AdminStatsCopyWithImpl(this._self, this._then);

  final AdminStats _self;
  final $Res Function(AdminStats) _then;

/// Create a copy of AdminStats
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? pendingApplications = null,Object? openComplaints = null,Object? activeJobs = null,Object? lockedEscrowTotal = null,}) {
  return _then(_self.copyWith(
pendingApplications: null == pendingApplications ? _self.pendingApplications : pendingApplications // ignore: cast_nullable_to_non_nullable
as int,openComplaints: null == openComplaints ? _self.openComplaints : openComplaints // ignore: cast_nullable_to_non_nullable
as int,activeJobs: null == activeJobs ? _self.activeJobs : activeJobs // ignore: cast_nullable_to_non_nullable
as int,lockedEscrowTotal: null == lockedEscrowTotal ? _self.lockedEscrowTotal : lockedEscrowTotal // ignore: cast_nullable_to_non_nullable
as Money,
  ));
}

}


/// Adds pattern-matching-related methods to [AdminStats].
extension AdminStatsPatterns on AdminStats {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _AdminStats value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _AdminStats() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _AdminStats value)  $default,){
final _that = this;
switch (_that) {
case _AdminStats():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _AdminStats value)?  $default,){
final _that = this;
switch (_that) {
case _AdminStats() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int pendingApplications,  int openComplaints,  int activeJobs, @MoneyConverter()  Money lockedEscrowTotal)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _AdminStats() when $default != null:
return $default(_that.pendingApplications,_that.openComplaints,_that.activeJobs,_that.lockedEscrowTotal);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int pendingApplications,  int openComplaints,  int activeJobs, @MoneyConverter()  Money lockedEscrowTotal)  $default,) {final _that = this;
switch (_that) {
case _AdminStats():
return $default(_that.pendingApplications,_that.openComplaints,_that.activeJobs,_that.lockedEscrowTotal);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int pendingApplications,  int openComplaints,  int activeJobs, @MoneyConverter()  Money lockedEscrowTotal)?  $default,) {final _that = this;
switch (_that) {
case _AdminStats() when $default != null:
return $default(_that.pendingApplications,_that.openComplaints,_that.activeJobs,_that.lockedEscrowTotal);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _AdminStats implements AdminStats {
  const _AdminStats({required this.pendingApplications, required this.openComplaints, required this.activeJobs, @MoneyConverter() required this.lockedEscrowTotal});
  factory _AdminStats.fromJson(Map<String, dynamic> json) => _$AdminStatsFromJson(json);

@override final  int pendingApplications;
@override final  int openComplaints;
@override final  int activeJobs;
@override@MoneyConverter() final  Money lockedEscrowTotal;

/// Create a copy of AdminStats
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$AdminStatsCopyWith<_AdminStats> get copyWith => __$AdminStatsCopyWithImpl<_AdminStats>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$AdminStatsToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _AdminStats&&(identical(other.pendingApplications, pendingApplications) || other.pendingApplications == pendingApplications)&&(identical(other.openComplaints, openComplaints) || other.openComplaints == openComplaints)&&(identical(other.activeJobs, activeJobs) || other.activeJobs == activeJobs)&&(identical(other.lockedEscrowTotal, lockedEscrowTotal) || other.lockedEscrowTotal == lockedEscrowTotal));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,pendingApplications,openComplaints,activeJobs,lockedEscrowTotal);

@override
String toString() {
  return 'AdminStats(pendingApplications: $pendingApplications, openComplaints: $openComplaints, activeJobs: $activeJobs, lockedEscrowTotal: $lockedEscrowTotal)';
}


}

/// @nodoc
abstract mixin class _$AdminStatsCopyWith<$Res> implements $AdminStatsCopyWith<$Res> {
  factory _$AdminStatsCopyWith(_AdminStats value, $Res Function(_AdminStats) _then) = __$AdminStatsCopyWithImpl;
@override @useResult
$Res call({
 int pendingApplications, int openComplaints, int activeJobs,@MoneyConverter() Money lockedEscrowTotal
});




}
/// @nodoc
class __$AdminStatsCopyWithImpl<$Res>
    implements _$AdminStatsCopyWith<$Res> {
  __$AdminStatsCopyWithImpl(this._self, this._then);

  final _AdminStats _self;
  final $Res Function(_AdminStats) _then;

/// Create a copy of AdminStats
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? pendingApplications = null,Object? openComplaints = null,Object? activeJobs = null,Object? lockedEscrowTotal = null,}) {
  return _then(_AdminStats(
pendingApplications: null == pendingApplications ? _self.pendingApplications : pendingApplications // ignore: cast_nullable_to_non_nullable
as int,openComplaints: null == openComplaints ? _self.openComplaints : openComplaints // ignore: cast_nullable_to_non_nullable
as int,activeJobs: null == activeJobs ? _self.activeJobs : activeJobs // ignore: cast_nullable_to_non_nullable
as int,lockedEscrowTotal: null == lockedEscrowTotal ? _self.lockedEscrowTotal : lockedEscrowTotal // ignore: cast_nullable_to_non_nullable
as Money,
  ));
}


}


/// @nodoc
mixin _$AdminApplicationSummary {

@JsonKey(fromJson: idFromJson) String get proId; String get fullName; String get businessName;@JsonKey(fromJson: idListFromJson, toJson: idListToJson) List<String> get categoryIds; List<String> get districtNames; DateTime? get submittedAt; ReviewStatus get reviewStatus; int get documentCount;
/// Create a copy of AdminApplicationSummary
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$AdminApplicationSummaryCopyWith<AdminApplicationSummary> get copyWith => _$AdminApplicationSummaryCopyWithImpl<AdminApplicationSummary>(this as AdminApplicationSummary, _$identity);

  /// Serializes this AdminApplicationSummary to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is AdminApplicationSummary&&(identical(other.proId, proId) || other.proId == proId)&&(identical(other.fullName, fullName) || other.fullName == fullName)&&(identical(other.businessName, businessName) || other.businessName == businessName)&&const DeepCollectionEquality().equals(other.categoryIds, categoryIds)&&const DeepCollectionEquality().equals(other.districtNames, districtNames)&&(identical(other.submittedAt, submittedAt) || other.submittedAt == submittedAt)&&(identical(other.reviewStatus, reviewStatus) || other.reviewStatus == reviewStatus)&&(identical(other.documentCount, documentCount) || other.documentCount == documentCount));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,proId,fullName,businessName,const DeepCollectionEquality().hash(categoryIds),const DeepCollectionEquality().hash(districtNames),submittedAt,reviewStatus,documentCount);

@override
String toString() {
  return 'AdminApplicationSummary(proId: $proId, fullName: $fullName, businessName: $businessName, categoryIds: $categoryIds, districtNames: $districtNames, submittedAt: $submittedAt, reviewStatus: $reviewStatus, documentCount: $documentCount)';
}


}

/// @nodoc
abstract mixin class $AdminApplicationSummaryCopyWith<$Res>  {
  factory $AdminApplicationSummaryCopyWith(AdminApplicationSummary value, $Res Function(AdminApplicationSummary) _then) = _$AdminApplicationSummaryCopyWithImpl;
@useResult
$Res call({
@JsonKey(fromJson: idFromJson) String proId, String fullName, String businessName,@JsonKey(fromJson: idListFromJson, toJson: idListToJson) List<String> categoryIds, List<String> districtNames, DateTime? submittedAt, ReviewStatus reviewStatus, int documentCount
});




}
/// @nodoc
class _$AdminApplicationSummaryCopyWithImpl<$Res>
    implements $AdminApplicationSummaryCopyWith<$Res> {
  _$AdminApplicationSummaryCopyWithImpl(this._self, this._then);

  final AdminApplicationSummary _self;
  final $Res Function(AdminApplicationSummary) _then;

/// Create a copy of AdminApplicationSummary
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? proId = null,Object? fullName = null,Object? businessName = null,Object? categoryIds = null,Object? districtNames = null,Object? submittedAt = freezed,Object? reviewStatus = null,Object? documentCount = null,}) {
  return _then(_self.copyWith(
proId: null == proId ? _self.proId : proId // ignore: cast_nullable_to_non_nullable
as String,fullName: null == fullName ? _self.fullName : fullName // ignore: cast_nullable_to_non_nullable
as String,businessName: null == businessName ? _self.businessName : businessName // ignore: cast_nullable_to_non_nullable
as String,categoryIds: null == categoryIds ? _self.categoryIds : categoryIds // ignore: cast_nullable_to_non_nullable
as List<String>,districtNames: null == districtNames ? _self.districtNames : districtNames // ignore: cast_nullable_to_non_nullable
as List<String>,submittedAt: freezed == submittedAt ? _self.submittedAt : submittedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,reviewStatus: null == reviewStatus ? _self.reviewStatus : reviewStatus // ignore: cast_nullable_to_non_nullable
as ReviewStatus,documentCount: null == documentCount ? _self.documentCount : documentCount // ignore: cast_nullable_to_non_nullable
as int,
  ));
}

}


/// Adds pattern-matching-related methods to [AdminApplicationSummary].
extension AdminApplicationSummaryPatterns on AdminApplicationSummary {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _AdminApplicationSummary value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _AdminApplicationSummary() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _AdminApplicationSummary value)  $default,){
final _that = this;
switch (_that) {
case _AdminApplicationSummary():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _AdminApplicationSummary value)?  $default,){
final _that = this;
switch (_that) {
case _AdminApplicationSummary() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function(@JsonKey(fromJson: idFromJson)  String proId,  String fullName,  String businessName, @JsonKey(fromJson: idListFromJson, toJson: idListToJson)  List<String> categoryIds,  List<String> districtNames,  DateTime? submittedAt,  ReviewStatus reviewStatus,  int documentCount)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _AdminApplicationSummary() when $default != null:
return $default(_that.proId,_that.fullName,_that.businessName,_that.categoryIds,_that.districtNames,_that.submittedAt,_that.reviewStatus,_that.documentCount);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function(@JsonKey(fromJson: idFromJson)  String proId,  String fullName,  String businessName, @JsonKey(fromJson: idListFromJson, toJson: idListToJson)  List<String> categoryIds,  List<String> districtNames,  DateTime? submittedAt,  ReviewStatus reviewStatus,  int documentCount)  $default,) {final _that = this;
switch (_that) {
case _AdminApplicationSummary():
return $default(_that.proId,_that.fullName,_that.businessName,_that.categoryIds,_that.districtNames,_that.submittedAt,_that.reviewStatus,_that.documentCount);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function(@JsonKey(fromJson: idFromJson)  String proId,  String fullName,  String businessName, @JsonKey(fromJson: idListFromJson, toJson: idListToJson)  List<String> categoryIds,  List<String> districtNames,  DateTime? submittedAt,  ReviewStatus reviewStatus,  int documentCount)?  $default,) {final _that = this;
switch (_that) {
case _AdminApplicationSummary() when $default != null:
return $default(_that.proId,_that.fullName,_that.businessName,_that.categoryIds,_that.districtNames,_that.submittedAt,_that.reviewStatus,_that.documentCount);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _AdminApplicationSummary implements AdminApplicationSummary {
  const _AdminApplicationSummary({@JsonKey(fromJson: idFromJson) required this.proId, required this.fullName, required this.businessName, @JsonKey(fromJson: idListFromJson, toJson: idListToJson) this.categoryIds = const <String>[], this.districtNames = const <String>[], this.submittedAt, required this.reviewStatus, this.documentCount = 0});
  factory _AdminApplicationSummary.fromJson(Map<String, dynamic> json) => _$AdminApplicationSummaryFromJson(json);

@override@JsonKey(fromJson: idFromJson) final  String proId;
@override final  String fullName;
@override final  String businessName;
@override@JsonKey(fromJson: idListFromJson, toJson: idListToJson) final  List<String> categoryIds;
@override@JsonKey() final  List<String> districtNames;
@override final  DateTime? submittedAt;
@override final  ReviewStatus reviewStatus;
@override@JsonKey() final  int documentCount;

/// Create a copy of AdminApplicationSummary
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$AdminApplicationSummaryCopyWith<_AdminApplicationSummary> get copyWith => __$AdminApplicationSummaryCopyWithImpl<_AdminApplicationSummary>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$AdminApplicationSummaryToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _AdminApplicationSummary&&(identical(other.proId, proId) || other.proId == proId)&&(identical(other.fullName, fullName) || other.fullName == fullName)&&(identical(other.businessName, businessName) || other.businessName == businessName)&&const DeepCollectionEquality().equals(other.categoryIds, categoryIds)&&const DeepCollectionEquality().equals(other.districtNames, districtNames)&&(identical(other.submittedAt, submittedAt) || other.submittedAt == submittedAt)&&(identical(other.reviewStatus, reviewStatus) || other.reviewStatus == reviewStatus)&&(identical(other.documentCount, documentCount) || other.documentCount == documentCount));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,proId,fullName,businessName,const DeepCollectionEquality().hash(categoryIds),const DeepCollectionEquality().hash(districtNames),submittedAt,reviewStatus,documentCount);

@override
String toString() {
  return 'AdminApplicationSummary(proId: $proId, fullName: $fullName, businessName: $businessName, categoryIds: $categoryIds, districtNames: $districtNames, submittedAt: $submittedAt, reviewStatus: $reviewStatus, documentCount: $documentCount)';
}


}

/// @nodoc
abstract mixin class _$AdminApplicationSummaryCopyWith<$Res> implements $AdminApplicationSummaryCopyWith<$Res> {
  factory _$AdminApplicationSummaryCopyWith(_AdminApplicationSummary value, $Res Function(_AdminApplicationSummary) _then) = __$AdminApplicationSummaryCopyWithImpl;
@override @useResult
$Res call({
@JsonKey(fromJson: idFromJson) String proId, String fullName, String businessName,@JsonKey(fromJson: idListFromJson, toJson: idListToJson) List<String> categoryIds, List<String> districtNames, DateTime? submittedAt, ReviewStatus reviewStatus, int documentCount
});




}
/// @nodoc
class __$AdminApplicationSummaryCopyWithImpl<$Res>
    implements _$AdminApplicationSummaryCopyWith<$Res> {
  __$AdminApplicationSummaryCopyWithImpl(this._self, this._then);

  final _AdminApplicationSummary _self;
  final $Res Function(_AdminApplicationSummary) _then;

/// Create a copy of AdminApplicationSummary
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? proId = null,Object? fullName = null,Object? businessName = null,Object? categoryIds = null,Object? districtNames = null,Object? submittedAt = freezed,Object? reviewStatus = null,Object? documentCount = null,}) {
  return _then(_AdminApplicationSummary(
proId: null == proId ? _self.proId : proId // ignore: cast_nullable_to_non_nullable
as String,fullName: null == fullName ? _self.fullName : fullName // ignore: cast_nullable_to_non_nullable
as String,businessName: null == businessName ? _self.businessName : businessName // ignore: cast_nullable_to_non_nullable
as String,categoryIds: null == categoryIds ? _self.categoryIds : categoryIds // ignore: cast_nullable_to_non_nullable
as List<String>,districtNames: null == districtNames ? _self.districtNames : districtNames // ignore: cast_nullable_to_non_nullable
as List<String>,submittedAt: freezed == submittedAt ? _self.submittedAt : submittedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,reviewStatus: null == reviewStatus ? _self.reviewStatus : reviewStatus // ignore: cast_nullable_to_non_nullable
as ReviewStatus,documentCount: null == documentCount ? _self.documentCount : documentCount // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}


/// @nodoc
mixin _$AdminAction {

@JsonKey(fromJson: idFromJson) String get id; String get action; String? get note; String get adminName; DateTime get createdAt;
/// Create a copy of AdminAction
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$AdminActionCopyWith<AdminAction> get copyWith => _$AdminActionCopyWithImpl<AdminAction>(this as AdminAction, _$identity);

  /// Serializes this AdminAction to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is AdminAction&&(identical(other.id, id) || other.id == id)&&(identical(other.action, action) || other.action == action)&&(identical(other.note, note) || other.note == note)&&(identical(other.adminName, adminName) || other.adminName == adminName)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,action,note,adminName,createdAt);

@override
String toString() {
  return 'AdminAction(id: $id, action: $action, note: $note, adminName: $adminName, createdAt: $createdAt)';
}


}

/// @nodoc
abstract mixin class $AdminActionCopyWith<$Res>  {
  factory $AdminActionCopyWith(AdminAction value, $Res Function(AdminAction) _then) = _$AdminActionCopyWithImpl;
@useResult
$Res call({
@JsonKey(fromJson: idFromJson) String id, String action, String? note, String adminName, DateTime createdAt
});




}
/// @nodoc
class _$AdminActionCopyWithImpl<$Res>
    implements $AdminActionCopyWith<$Res> {
  _$AdminActionCopyWithImpl(this._self, this._then);

  final AdminAction _self;
  final $Res Function(AdminAction) _then;

/// Create a copy of AdminAction
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? action = null,Object? note = freezed,Object? adminName = null,Object? createdAt = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,action: null == action ? _self.action : action // ignore: cast_nullable_to_non_nullable
as String,note: freezed == note ? _self.note : note // ignore: cast_nullable_to_non_nullable
as String?,adminName: null == adminName ? _self.adminName : adminName // ignore: cast_nullable_to_non_nullable
as String,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}

}


/// Adds pattern-matching-related methods to [AdminAction].
extension AdminActionPatterns on AdminAction {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _AdminAction value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _AdminAction() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _AdminAction value)  $default,){
final _that = this;
switch (_that) {
case _AdminAction():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _AdminAction value)?  $default,){
final _that = this;
switch (_that) {
case _AdminAction() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function(@JsonKey(fromJson: idFromJson)  String id,  String action,  String? note,  String adminName,  DateTime createdAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _AdminAction() when $default != null:
return $default(_that.id,_that.action,_that.note,_that.adminName,_that.createdAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function(@JsonKey(fromJson: idFromJson)  String id,  String action,  String? note,  String adminName,  DateTime createdAt)  $default,) {final _that = this;
switch (_that) {
case _AdminAction():
return $default(_that.id,_that.action,_that.note,_that.adminName,_that.createdAt);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function(@JsonKey(fromJson: idFromJson)  String id,  String action,  String? note,  String adminName,  DateTime createdAt)?  $default,) {final _that = this;
switch (_that) {
case _AdminAction() when $default != null:
return $default(_that.id,_that.action,_that.note,_that.adminName,_that.createdAt);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _AdminAction implements AdminAction {
  const _AdminAction({@JsonKey(fromJson: idFromJson) required this.id, required this.action, this.note, required this.adminName, required this.createdAt});
  factory _AdminAction.fromJson(Map<String, dynamic> json) => _$AdminActionFromJson(json);

@override@JsonKey(fromJson: idFromJson) final  String id;
@override final  String action;
@override final  String? note;
@override final  String adminName;
@override final  DateTime createdAt;

/// Create a copy of AdminAction
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$AdminActionCopyWith<_AdminAction> get copyWith => __$AdminActionCopyWithImpl<_AdminAction>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$AdminActionToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _AdminAction&&(identical(other.id, id) || other.id == id)&&(identical(other.action, action) || other.action == action)&&(identical(other.note, note) || other.note == note)&&(identical(other.adminName, adminName) || other.adminName == adminName)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,action,note,adminName,createdAt);

@override
String toString() {
  return 'AdminAction(id: $id, action: $action, note: $note, adminName: $adminName, createdAt: $createdAt)';
}


}

/// @nodoc
abstract mixin class _$AdminActionCopyWith<$Res> implements $AdminActionCopyWith<$Res> {
  factory _$AdminActionCopyWith(_AdminAction value, $Res Function(_AdminAction) _then) = __$AdminActionCopyWithImpl;
@override @useResult
$Res call({
@JsonKey(fromJson: idFromJson) String id, String action, String? note, String adminName, DateTime createdAt
});




}
/// @nodoc
class __$AdminActionCopyWithImpl<$Res>
    implements _$AdminActionCopyWith<$Res> {
  __$AdminActionCopyWithImpl(this._self, this._then);

  final _AdminAction _self;
  final $Res Function(_AdminAction) _then;

/// Create a copy of AdminAction
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? action = null,Object? note = freezed,Object? adminName = null,Object? createdAt = null,}) {
  return _then(_AdminAction(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,action: null == action ? _self.action : action // ignore: cast_nullable_to_non_nullable
as String,note: freezed == note ? _self.note : note // ignore: cast_nullable_to_non_nullable
as String?,adminName: null == adminName ? _self.adminName : adminName // ignore: cast_nullable_to_non_nullable
as String,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}


}


/// @nodoc
mixin _$AdminApplicationDetail {

@JsonKey(fromJson: idFromJson) String get proId; String get fullName; String get businessName;@JsonKey(fromJson: idListFromJson, toJson: idListToJson) List<String> get categoryIds; List<String> get districtNames; DateTime? get submittedAt; ReviewStatus get reviewStatus; int get documentCount; String get email; String? get phone; String get bio; int get experienceYears; String? get reviewNote; List<ApplicationDocument> get documents; List<AdminAction> get history;
/// Create a copy of AdminApplicationDetail
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$AdminApplicationDetailCopyWith<AdminApplicationDetail> get copyWith => _$AdminApplicationDetailCopyWithImpl<AdminApplicationDetail>(this as AdminApplicationDetail, _$identity);

  /// Serializes this AdminApplicationDetail to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is AdminApplicationDetail&&(identical(other.proId, proId) || other.proId == proId)&&(identical(other.fullName, fullName) || other.fullName == fullName)&&(identical(other.businessName, businessName) || other.businessName == businessName)&&const DeepCollectionEquality().equals(other.categoryIds, categoryIds)&&const DeepCollectionEquality().equals(other.districtNames, districtNames)&&(identical(other.submittedAt, submittedAt) || other.submittedAt == submittedAt)&&(identical(other.reviewStatus, reviewStatus) || other.reviewStatus == reviewStatus)&&(identical(other.documentCount, documentCount) || other.documentCount == documentCount)&&(identical(other.email, email) || other.email == email)&&(identical(other.phone, phone) || other.phone == phone)&&(identical(other.bio, bio) || other.bio == bio)&&(identical(other.experienceYears, experienceYears) || other.experienceYears == experienceYears)&&(identical(other.reviewNote, reviewNote) || other.reviewNote == reviewNote)&&const DeepCollectionEquality().equals(other.documents, documents)&&const DeepCollectionEquality().equals(other.history, history));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,proId,fullName,businessName,const DeepCollectionEquality().hash(categoryIds),const DeepCollectionEquality().hash(districtNames),submittedAt,reviewStatus,documentCount,email,phone,bio,experienceYears,reviewNote,const DeepCollectionEquality().hash(documents),const DeepCollectionEquality().hash(history));

@override
String toString() {
  return 'AdminApplicationDetail(proId: $proId, fullName: $fullName, businessName: $businessName, categoryIds: $categoryIds, districtNames: $districtNames, submittedAt: $submittedAt, reviewStatus: $reviewStatus, documentCount: $documentCount, email: $email, phone: $phone, bio: $bio, experienceYears: $experienceYears, reviewNote: $reviewNote, documents: $documents, history: $history)';
}


}

/// @nodoc
abstract mixin class $AdminApplicationDetailCopyWith<$Res>  {
  factory $AdminApplicationDetailCopyWith(AdminApplicationDetail value, $Res Function(AdminApplicationDetail) _then) = _$AdminApplicationDetailCopyWithImpl;
@useResult
$Res call({
@JsonKey(fromJson: idFromJson) String proId, String fullName, String businessName,@JsonKey(fromJson: idListFromJson, toJson: idListToJson) List<String> categoryIds, List<String> districtNames, DateTime? submittedAt, ReviewStatus reviewStatus, int documentCount, String email, String? phone, String bio, int experienceYears, String? reviewNote, List<ApplicationDocument> documents, List<AdminAction> history
});




}
/// @nodoc
class _$AdminApplicationDetailCopyWithImpl<$Res>
    implements $AdminApplicationDetailCopyWith<$Res> {
  _$AdminApplicationDetailCopyWithImpl(this._self, this._then);

  final AdminApplicationDetail _self;
  final $Res Function(AdminApplicationDetail) _then;

/// Create a copy of AdminApplicationDetail
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? proId = null,Object? fullName = null,Object? businessName = null,Object? categoryIds = null,Object? districtNames = null,Object? submittedAt = freezed,Object? reviewStatus = null,Object? documentCount = null,Object? email = null,Object? phone = freezed,Object? bio = null,Object? experienceYears = null,Object? reviewNote = freezed,Object? documents = null,Object? history = null,}) {
  return _then(_self.copyWith(
proId: null == proId ? _self.proId : proId // ignore: cast_nullable_to_non_nullable
as String,fullName: null == fullName ? _self.fullName : fullName // ignore: cast_nullable_to_non_nullable
as String,businessName: null == businessName ? _self.businessName : businessName // ignore: cast_nullable_to_non_nullable
as String,categoryIds: null == categoryIds ? _self.categoryIds : categoryIds // ignore: cast_nullable_to_non_nullable
as List<String>,districtNames: null == districtNames ? _self.districtNames : districtNames // ignore: cast_nullable_to_non_nullable
as List<String>,submittedAt: freezed == submittedAt ? _self.submittedAt : submittedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,reviewStatus: null == reviewStatus ? _self.reviewStatus : reviewStatus // ignore: cast_nullable_to_non_nullable
as ReviewStatus,documentCount: null == documentCount ? _self.documentCount : documentCount // ignore: cast_nullable_to_non_nullable
as int,email: null == email ? _self.email : email // ignore: cast_nullable_to_non_nullable
as String,phone: freezed == phone ? _self.phone : phone // ignore: cast_nullable_to_non_nullable
as String?,bio: null == bio ? _self.bio : bio // ignore: cast_nullable_to_non_nullable
as String,experienceYears: null == experienceYears ? _self.experienceYears : experienceYears // ignore: cast_nullable_to_non_nullable
as int,reviewNote: freezed == reviewNote ? _self.reviewNote : reviewNote // ignore: cast_nullable_to_non_nullable
as String?,documents: null == documents ? _self.documents : documents // ignore: cast_nullable_to_non_nullable
as List<ApplicationDocument>,history: null == history ? _self.history : history // ignore: cast_nullable_to_non_nullable
as List<AdminAction>,
  ));
}

}


/// Adds pattern-matching-related methods to [AdminApplicationDetail].
extension AdminApplicationDetailPatterns on AdminApplicationDetail {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _AdminApplicationDetail value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _AdminApplicationDetail() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _AdminApplicationDetail value)  $default,){
final _that = this;
switch (_that) {
case _AdminApplicationDetail():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _AdminApplicationDetail value)?  $default,){
final _that = this;
switch (_that) {
case _AdminApplicationDetail() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function(@JsonKey(fromJson: idFromJson)  String proId,  String fullName,  String businessName, @JsonKey(fromJson: idListFromJson, toJson: idListToJson)  List<String> categoryIds,  List<String> districtNames,  DateTime? submittedAt,  ReviewStatus reviewStatus,  int documentCount,  String email,  String? phone,  String bio,  int experienceYears,  String? reviewNote,  List<ApplicationDocument> documents,  List<AdminAction> history)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _AdminApplicationDetail() when $default != null:
return $default(_that.proId,_that.fullName,_that.businessName,_that.categoryIds,_that.districtNames,_that.submittedAt,_that.reviewStatus,_that.documentCount,_that.email,_that.phone,_that.bio,_that.experienceYears,_that.reviewNote,_that.documents,_that.history);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function(@JsonKey(fromJson: idFromJson)  String proId,  String fullName,  String businessName, @JsonKey(fromJson: idListFromJson, toJson: idListToJson)  List<String> categoryIds,  List<String> districtNames,  DateTime? submittedAt,  ReviewStatus reviewStatus,  int documentCount,  String email,  String? phone,  String bio,  int experienceYears,  String? reviewNote,  List<ApplicationDocument> documents,  List<AdminAction> history)  $default,) {final _that = this;
switch (_that) {
case _AdminApplicationDetail():
return $default(_that.proId,_that.fullName,_that.businessName,_that.categoryIds,_that.districtNames,_that.submittedAt,_that.reviewStatus,_that.documentCount,_that.email,_that.phone,_that.bio,_that.experienceYears,_that.reviewNote,_that.documents,_that.history);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function(@JsonKey(fromJson: idFromJson)  String proId,  String fullName,  String businessName, @JsonKey(fromJson: idListFromJson, toJson: idListToJson)  List<String> categoryIds,  List<String> districtNames,  DateTime? submittedAt,  ReviewStatus reviewStatus,  int documentCount,  String email,  String? phone,  String bio,  int experienceYears,  String? reviewNote,  List<ApplicationDocument> documents,  List<AdminAction> history)?  $default,) {final _that = this;
switch (_that) {
case _AdminApplicationDetail() when $default != null:
return $default(_that.proId,_that.fullName,_that.businessName,_that.categoryIds,_that.districtNames,_that.submittedAt,_that.reviewStatus,_that.documentCount,_that.email,_that.phone,_that.bio,_that.experienceYears,_that.reviewNote,_that.documents,_that.history);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _AdminApplicationDetail implements AdminApplicationDetail {
  const _AdminApplicationDetail({@JsonKey(fromJson: idFromJson) required this.proId, required this.fullName, required this.businessName, @JsonKey(fromJson: idListFromJson, toJson: idListToJson) this.categoryIds = const <String>[], this.districtNames = const <String>[], this.submittedAt, required this.reviewStatus, this.documentCount = 0, required this.email, this.phone, this.bio = '', this.experienceYears = 0, this.reviewNote, this.documents = const <ApplicationDocument>[], this.history = const <AdminAction>[]});
  factory _AdminApplicationDetail.fromJson(Map<String, dynamic> json) => _$AdminApplicationDetailFromJson(json);

@override@JsonKey(fromJson: idFromJson) final  String proId;
@override final  String fullName;
@override final  String businessName;
@override@JsonKey(fromJson: idListFromJson, toJson: idListToJson) final  List<String> categoryIds;
@override@JsonKey() final  List<String> districtNames;
@override final  DateTime? submittedAt;
@override final  ReviewStatus reviewStatus;
@override@JsonKey() final  int documentCount;
@override final  String email;
@override final  String? phone;
@override@JsonKey() final  String bio;
@override@JsonKey() final  int experienceYears;
@override final  String? reviewNote;
@override@JsonKey() final  List<ApplicationDocument> documents;
@override@JsonKey() final  List<AdminAction> history;

/// Create a copy of AdminApplicationDetail
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$AdminApplicationDetailCopyWith<_AdminApplicationDetail> get copyWith => __$AdminApplicationDetailCopyWithImpl<_AdminApplicationDetail>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$AdminApplicationDetailToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _AdminApplicationDetail&&(identical(other.proId, proId) || other.proId == proId)&&(identical(other.fullName, fullName) || other.fullName == fullName)&&(identical(other.businessName, businessName) || other.businessName == businessName)&&const DeepCollectionEquality().equals(other.categoryIds, categoryIds)&&const DeepCollectionEquality().equals(other.districtNames, districtNames)&&(identical(other.submittedAt, submittedAt) || other.submittedAt == submittedAt)&&(identical(other.reviewStatus, reviewStatus) || other.reviewStatus == reviewStatus)&&(identical(other.documentCount, documentCount) || other.documentCount == documentCount)&&(identical(other.email, email) || other.email == email)&&(identical(other.phone, phone) || other.phone == phone)&&(identical(other.bio, bio) || other.bio == bio)&&(identical(other.experienceYears, experienceYears) || other.experienceYears == experienceYears)&&(identical(other.reviewNote, reviewNote) || other.reviewNote == reviewNote)&&const DeepCollectionEquality().equals(other.documents, documents)&&const DeepCollectionEquality().equals(other.history, history));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,proId,fullName,businessName,const DeepCollectionEquality().hash(categoryIds),const DeepCollectionEquality().hash(districtNames),submittedAt,reviewStatus,documentCount,email,phone,bio,experienceYears,reviewNote,const DeepCollectionEquality().hash(documents),const DeepCollectionEquality().hash(history));

@override
String toString() {
  return 'AdminApplicationDetail(proId: $proId, fullName: $fullName, businessName: $businessName, categoryIds: $categoryIds, districtNames: $districtNames, submittedAt: $submittedAt, reviewStatus: $reviewStatus, documentCount: $documentCount, email: $email, phone: $phone, bio: $bio, experienceYears: $experienceYears, reviewNote: $reviewNote, documents: $documents, history: $history)';
}


}

/// @nodoc
abstract mixin class _$AdminApplicationDetailCopyWith<$Res> implements $AdminApplicationDetailCopyWith<$Res> {
  factory _$AdminApplicationDetailCopyWith(_AdminApplicationDetail value, $Res Function(_AdminApplicationDetail) _then) = __$AdminApplicationDetailCopyWithImpl;
@override @useResult
$Res call({
@JsonKey(fromJson: idFromJson) String proId, String fullName, String businessName,@JsonKey(fromJson: idListFromJson, toJson: idListToJson) List<String> categoryIds, List<String> districtNames, DateTime? submittedAt, ReviewStatus reviewStatus, int documentCount, String email, String? phone, String bio, int experienceYears, String? reviewNote, List<ApplicationDocument> documents, List<AdminAction> history
});




}
/// @nodoc
class __$AdminApplicationDetailCopyWithImpl<$Res>
    implements _$AdminApplicationDetailCopyWith<$Res> {
  __$AdminApplicationDetailCopyWithImpl(this._self, this._then);

  final _AdminApplicationDetail _self;
  final $Res Function(_AdminApplicationDetail) _then;

/// Create a copy of AdminApplicationDetail
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? proId = null,Object? fullName = null,Object? businessName = null,Object? categoryIds = null,Object? districtNames = null,Object? submittedAt = freezed,Object? reviewStatus = null,Object? documentCount = null,Object? email = null,Object? phone = freezed,Object? bio = null,Object? experienceYears = null,Object? reviewNote = freezed,Object? documents = null,Object? history = null,}) {
  return _then(_AdminApplicationDetail(
proId: null == proId ? _self.proId : proId // ignore: cast_nullable_to_non_nullable
as String,fullName: null == fullName ? _self.fullName : fullName // ignore: cast_nullable_to_non_nullable
as String,businessName: null == businessName ? _self.businessName : businessName // ignore: cast_nullable_to_non_nullable
as String,categoryIds: null == categoryIds ? _self.categoryIds : categoryIds // ignore: cast_nullable_to_non_nullable
as List<String>,districtNames: null == districtNames ? _self.districtNames : districtNames // ignore: cast_nullable_to_non_nullable
as List<String>,submittedAt: freezed == submittedAt ? _self.submittedAt : submittedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,reviewStatus: null == reviewStatus ? _self.reviewStatus : reviewStatus // ignore: cast_nullable_to_non_nullable
as ReviewStatus,documentCount: null == documentCount ? _self.documentCount : documentCount // ignore: cast_nullable_to_non_nullable
as int,email: null == email ? _self.email : email // ignore: cast_nullable_to_non_nullable
as String,phone: freezed == phone ? _self.phone : phone // ignore: cast_nullable_to_non_nullable
as String?,bio: null == bio ? _self.bio : bio // ignore: cast_nullable_to_non_nullable
as String,experienceYears: null == experienceYears ? _self.experienceYears : experienceYears // ignore: cast_nullable_to_non_nullable
as int,reviewNote: freezed == reviewNote ? _self.reviewNote : reviewNote // ignore: cast_nullable_to_non_nullable
as String?,documents: null == documents ? _self.documents : documents // ignore: cast_nullable_to_non_nullable
as List<ApplicationDocument>,history: null == history ? _self.history : history // ignore: cast_nullable_to_non_nullable
as List<AdminAction>,
  ));
}


}


/// @nodoc
mixin _$ApproveApplicationRequest {

@JsonKey(includeIfNull: false) String? get note;
/// Create a copy of ApproveApplicationRequest
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ApproveApplicationRequestCopyWith<ApproveApplicationRequest> get copyWith => _$ApproveApplicationRequestCopyWithImpl<ApproveApplicationRequest>(this as ApproveApplicationRequest, _$identity);

  /// Serializes this ApproveApplicationRequest to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ApproveApplicationRequest&&(identical(other.note, note) || other.note == note));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,note);

@override
String toString() {
  return 'ApproveApplicationRequest(note: $note)';
}


}

/// @nodoc
abstract mixin class $ApproveApplicationRequestCopyWith<$Res>  {
  factory $ApproveApplicationRequestCopyWith(ApproveApplicationRequest value, $Res Function(ApproveApplicationRequest) _then) = _$ApproveApplicationRequestCopyWithImpl;
@useResult
$Res call({
@JsonKey(includeIfNull: false) String? note
});




}
/// @nodoc
class _$ApproveApplicationRequestCopyWithImpl<$Res>
    implements $ApproveApplicationRequestCopyWith<$Res> {
  _$ApproveApplicationRequestCopyWithImpl(this._self, this._then);

  final ApproveApplicationRequest _self;
  final $Res Function(ApproveApplicationRequest) _then;

/// Create a copy of ApproveApplicationRequest
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? note = freezed,}) {
  return _then(_self.copyWith(
note: freezed == note ? _self.note : note // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [ApproveApplicationRequest].
extension ApproveApplicationRequestPatterns on ApproveApplicationRequest {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ApproveApplicationRequest value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ApproveApplicationRequest() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ApproveApplicationRequest value)  $default,){
final _that = this;
switch (_that) {
case _ApproveApplicationRequest():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ApproveApplicationRequest value)?  $default,){
final _that = this;
switch (_that) {
case _ApproveApplicationRequest() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function(@JsonKey(includeIfNull: false)  String? note)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ApproveApplicationRequest() when $default != null:
return $default(_that.note);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function(@JsonKey(includeIfNull: false)  String? note)  $default,) {final _that = this;
switch (_that) {
case _ApproveApplicationRequest():
return $default(_that.note);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function(@JsonKey(includeIfNull: false)  String? note)?  $default,) {final _that = this;
switch (_that) {
case _ApproveApplicationRequest() when $default != null:
return $default(_that.note);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _ApproveApplicationRequest implements ApproveApplicationRequest {
  const _ApproveApplicationRequest({@JsonKey(includeIfNull: false) this.note});
  factory _ApproveApplicationRequest.fromJson(Map<String, dynamic> json) => _$ApproveApplicationRequestFromJson(json);

@override@JsonKey(includeIfNull: false) final  String? note;

/// Create a copy of ApproveApplicationRequest
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ApproveApplicationRequestCopyWith<_ApproveApplicationRequest> get copyWith => __$ApproveApplicationRequestCopyWithImpl<_ApproveApplicationRequest>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ApproveApplicationRequestToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ApproveApplicationRequest&&(identical(other.note, note) || other.note == note));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,note);

@override
String toString() {
  return 'ApproveApplicationRequest(note: $note)';
}


}

/// @nodoc
abstract mixin class _$ApproveApplicationRequestCopyWith<$Res> implements $ApproveApplicationRequestCopyWith<$Res> {
  factory _$ApproveApplicationRequestCopyWith(_ApproveApplicationRequest value, $Res Function(_ApproveApplicationRequest) _then) = __$ApproveApplicationRequestCopyWithImpl;
@override @useResult
$Res call({
@JsonKey(includeIfNull: false) String? note
});




}
/// @nodoc
class __$ApproveApplicationRequestCopyWithImpl<$Res>
    implements _$ApproveApplicationRequestCopyWith<$Res> {
  __$ApproveApplicationRequestCopyWithImpl(this._self, this._then);

  final _ApproveApplicationRequest _self;
  final $Res Function(_ApproveApplicationRequest) _then;

/// Create a copy of ApproveApplicationRequest
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? note = freezed,}) {
  return _then(_ApproveApplicationRequest(
note: freezed == note ? _self.note : note // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}


/// @nodoc
mixin _$AdminNoteRequest {

 String get note;
/// Create a copy of AdminNoteRequest
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$AdminNoteRequestCopyWith<AdminNoteRequest> get copyWith => _$AdminNoteRequestCopyWithImpl<AdminNoteRequest>(this as AdminNoteRequest, _$identity);

  /// Serializes this AdminNoteRequest to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is AdminNoteRequest&&(identical(other.note, note) || other.note == note));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,note);

@override
String toString() {
  return 'AdminNoteRequest(note: $note)';
}


}

/// @nodoc
abstract mixin class $AdminNoteRequestCopyWith<$Res>  {
  factory $AdminNoteRequestCopyWith(AdminNoteRequest value, $Res Function(AdminNoteRequest) _then) = _$AdminNoteRequestCopyWithImpl;
@useResult
$Res call({
 String note
});




}
/// @nodoc
class _$AdminNoteRequestCopyWithImpl<$Res>
    implements $AdminNoteRequestCopyWith<$Res> {
  _$AdminNoteRequestCopyWithImpl(this._self, this._then);

  final AdminNoteRequest _self;
  final $Res Function(AdminNoteRequest) _then;

/// Create a copy of AdminNoteRequest
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? note = null,}) {
  return _then(_self.copyWith(
note: null == note ? _self.note : note // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [AdminNoteRequest].
extension AdminNoteRequestPatterns on AdminNoteRequest {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _AdminNoteRequest value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _AdminNoteRequest() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _AdminNoteRequest value)  $default,){
final _that = this;
switch (_that) {
case _AdminNoteRequest():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _AdminNoteRequest value)?  $default,){
final _that = this;
switch (_that) {
case _AdminNoteRequest() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String note)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _AdminNoteRequest() when $default != null:
return $default(_that.note);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String note)  $default,) {final _that = this;
switch (_that) {
case _AdminNoteRequest():
return $default(_that.note);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String note)?  $default,) {final _that = this;
switch (_that) {
case _AdminNoteRequest() when $default != null:
return $default(_that.note);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _AdminNoteRequest implements AdminNoteRequest {
  const _AdminNoteRequest({required this.note});
  factory _AdminNoteRequest.fromJson(Map<String, dynamic> json) => _$AdminNoteRequestFromJson(json);

@override final  String note;

/// Create a copy of AdminNoteRequest
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$AdminNoteRequestCopyWith<_AdminNoteRequest> get copyWith => __$AdminNoteRequestCopyWithImpl<_AdminNoteRequest>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$AdminNoteRequestToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _AdminNoteRequest&&(identical(other.note, note) || other.note == note));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,note);

@override
String toString() {
  return 'AdminNoteRequest(note: $note)';
}


}

/// @nodoc
abstract mixin class _$AdminNoteRequestCopyWith<$Res> implements $AdminNoteRequestCopyWith<$Res> {
  factory _$AdminNoteRequestCopyWith(_AdminNoteRequest value, $Res Function(_AdminNoteRequest) _then) = __$AdminNoteRequestCopyWithImpl;
@override @useResult
$Res call({
 String note
});




}
/// @nodoc
class __$AdminNoteRequestCopyWithImpl<$Res>
    implements _$AdminNoteRequestCopyWith<$Res> {
  __$AdminNoteRequestCopyWithImpl(this._self, this._then);

  final _AdminNoteRequest _self;
  final $Res Function(_AdminNoteRequest) _then;

/// Create a copy of AdminNoteRequest
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? note = null,}) {
  return _then(_AdminNoteRequest(
note: null == note ? _self.note : note // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}


/// @nodoc
mixin _$RequestDocumentsRequest {

 String get note; List<ProDocumentType> get documentTypes;
/// Create a copy of RequestDocumentsRequest
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$RequestDocumentsRequestCopyWith<RequestDocumentsRequest> get copyWith => _$RequestDocumentsRequestCopyWithImpl<RequestDocumentsRequest>(this as RequestDocumentsRequest, _$identity);

  /// Serializes this RequestDocumentsRequest to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is RequestDocumentsRequest&&(identical(other.note, note) || other.note == note)&&const DeepCollectionEquality().equals(other.documentTypes, documentTypes));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,note,const DeepCollectionEquality().hash(documentTypes));

@override
String toString() {
  return 'RequestDocumentsRequest(note: $note, documentTypes: $documentTypes)';
}


}

/// @nodoc
abstract mixin class $RequestDocumentsRequestCopyWith<$Res>  {
  factory $RequestDocumentsRequestCopyWith(RequestDocumentsRequest value, $Res Function(RequestDocumentsRequest) _then) = _$RequestDocumentsRequestCopyWithImpl;
@useResult
$Res call({
 String note, List<ProDocumentType> documentTypes
});




}
/// @nodoc
class _$RequestDocumentsRequestCopyWithImpl<$Res>
    implements $RequestDocumentsRequestCopyWith<$Res> {
  _$RequestDocumentsRequestCopyWithImpl(this._self, this._then);

  final RequestDocumentsRequest _self;
  final $Res Function(RequestDocumentsRequest) _then;

/// Create a copy of RequestDocumentsRequest
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? note = null,Object? documentTypes = null,}) {
  return _then(_self.copyWith(
note: null == note ? _self.note : note // ignore: cast_nullable_to_non_nullable
as String,documentTypes: null == documentTypes ? _self.documentTypes : documentTypes // ignore: cast_nullable_to_non_nullable
as List<ProDocumentType>,
  ));
}

}


/// Adds pattern-matching-related methods to [RequestDocumentsRequest].
extension RequestDocumentsRequestPatterns on RequestDocumentsRequest {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _RequestDocumentsRequest value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _RequestDocumentsRequest() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _RequestDocumentsRequest value)  $default,){
final _that = this;
switch (_that) {
case _RequestDocumentsRequest():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _RequestDocumentsRequest value)?  $default,){
final _that = this;
switch (_that) {
case _RequestDocumentsRequest() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String note,  List<ProDocumentType> documentTypes)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _RequestDocumentsRequest() when $default != null:
return $default(_that.note,_that.documentTypes);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String note,  List<ProDocumentType> documentTypes)  $default,) {final _that = this;
switch (_that) {
case _RequestDocumentsRequest():
return $default(_that.note,_that.documentTypes);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String note,  List<ProDocumentType> documentTypes)?  $default,) {final _that = this;
switch (_that) {
case _RequestDocumentsRequest() when $default != null:
return $default(_that.note,_that.documentTypes);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _RequestDocumentsRequest implements RequestDocumentsRequest {
  const _RequestDocumentsRequest({required this.note, required this.documentTypes});
  factory _RequestDocumentsRequest.fromJson(Map<String, dynamic> json) => _$RequestDocumentsRequestFromJson(json);

@override final  String note;
@override final  List<ProDocumentType> documentTypes;

/// Create a copy of RequestDocumentsRequest
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$RequestDocumentsRequestCopyWith<_RequestDocumentsRequest> get copyWith => __$RequestDocumentsRequestCopyWithImpl<_RequestDocumentsRequest>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$RequestDocumentsRequestToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _RequestDocumentsRequest&&(identical(other.note, note) || other.note == note)&&const DeepCollectionEquality().equals(other.documentTypes, documentTypes));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,note,const DeepCollectionEquality().hash(documentTypes));

@override
String toString() {
  return 'RequestDocumentsRequest(note: $note, documentTypes: $documentTypes)';
}


}

/// @nodoc
abstract mixin class _$RequestDocumentsRequestCopyWith<$Res> implements $RequestDocumentsRequestCopyWith<$Res> {
  factory _$RequestDocumentsRequestCopyWith(_RequestDocumentsRequest value, $Res Function(_RequestDocumentsRequest) _then) = __$RequestDocumentsRequestCopyWithImpl;
@override @useResult
$Res call({
 String note, List<ProDocumentType> documentTypes
});




}
/// @nodoc
class __$RequestDocumentsRequestCopyWithImpl<$Res>
    implements _$RequestDocumentsRequestCopyWith<$Res> {
  __$RequestDocumentsRequestCopyWithImpl(this._self, this._then);

  final _RequestDocumentsRequest _self;
  final $Res Function(_RequestDocumentsRequest) _then;

/// Create a copy of RequestDocumentsRequest
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? note = null,Object? documentTypes = null,}) {
  return _then(_RequestDocumentsRequest(
note: null == note ? _self.note : note // ignore: cast_nullable_to_non_nullable
as String,documentTypes: null == documentTypes ? _self.documentTypes : documentTypes // ignore: cast_nullable_to_non_nullable
as List<ProDocumentType>,
  ));
}


}


/// @nodoc
mixin _$AdminComplaintItem {

@JsonKey(fromJson: idFromJson) String get id; String get publicCode;@JsonKey(fromJson: idFromJson) String get jobId; String get jobPublicCode; ComplaintReason get reason; ComplaintStatus get status; String get customerName; String get proBusinessName;@MoneyConverter() Money get amount; DateTime get createdAt;
/// Create a copy of AdminComplaintItem
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$AdminComplaintItemCopyWith<AdminComplaintItem> get copyWith => _$AdminComplaintItemCopyWithImpl<AdminComplaintItem>(this as AdminComplaintItem, _$identity);

  /// Serializes this AdminComplaintItem to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is AdminComplaintItem&&(identical(other.id, id) || other.id == id)&&(identical(other.publicCode, publicCode) || other.publicCode == publicCode)&&(identical(other.jobId, jobId) || other.jobId == jobId)&&(identical(other.jobPublicCode, jobPublicCode) || other.jobPublicCode == jobPublicCode)&&(identical(other.reason, reason) || other.reason == reason)&&(identical(other.status, status) || other.status == status)&&(identical(other.customerName, customerName) || other.customerName == customerName)&&(identical(other.proBusinessName, proBusinessName) || other.proBusinessName == proBusinessName)&&(identical(other.amount, amount) || other.amount == amount)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,publicCode,jobId,jobPublicCode,reason,status,customerName,proBusinessName,amount,createdAt);

@override
String toString() {
  return 'AdminComplaintItem(id: $id, publicCode: $publicCode, jobId: $jobId, jobPublicCode: $jobPublicCode, reason: $reason, status: $status, customerName: $customerName, proBusinessName: $proBusinessName, amount: $amount, createdAt: $createdAt)';
}


}

/// @nodoc
abstract mixin class $AdminComplaintItemCopyWith<$Res>  {
  factory $AdminComplaintItemCopyWith(AdminComplaintItem value, $Res Function(AdminComplaintItem) _then) = _$AdminComplaintItemCopyWithImpl;
@useResult
$Res call({
@JsonKey(fromJson: idFromJson) String id, String publicCode,@JsonKey(fromJson: idFromJson) String jobId, String jobPublicCode, ComplaintReason reason, ComplaintStatus status, String customerName, String proBusinessName,@MoneyConverter() Money amount, DateTime createdAt
});




}
/// @nodoc
class _$AdminComplaintItemCopyWithImpl<$Res>
    implements $AdminComplaintItemCopyWith<$Res> {
  _$AdminComplaintItemCopyWithImpl(this._self, this._then);

  final AdminComplaintItem _self;
  final $Res Function(AdminComplaintItem) _then;

/// Create a copy of AdminComplaintItem
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? publicCode = null,Object? jobId = null,Object? jobPublicCode = null,Object? reason = null,Object? status = null,Object? customerName = null,Object? proBusinessName = null,Object? amount = null,Object? createdAt = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,publicCode: null == publicCode ? _self.publicCode : publicCode // ignore: cast_nullable_to_non_nullable
as String,jobId: null == jobId ? _self.jobId : jobId // ignore: cast_nullable_to_non_nullable
as String,jobPublicCode: null == jobPublicCode ? _self.jobPublicCode : jobPublicCode // ignore: cast_nullable_to_non_nullable
as String,reason: null == reason ? _self.reason : reason // ignore: cast_nullable_to_non_nullable
as ComplaintReason,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as ComplaintStatus,customerName: null == customerName ? _self.customerName : customerName // ignore: cast_nullable_to_non_nullable
as String,proBusinessName: null == proBusinessName ? _self.proBusinessName : proBusinessName // ignore: cast_nullable_to_non_nullable
as String,amount: null == amount ? _self.amount : amount // ignore: cast_nullable_to_non_nullable
as Money,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}

}


/// Adds pattern-matching-related methods to [AdminComplaintItem].
extension AdminComplaintItemPatterns on AdminComplaintItem {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _AdminComplaintItem value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _AdminComplaintItem() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _AdminComplaintItem value)  $default,){
final _that = this;
switch (_that) {
case _AdminComplaintItem():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _AdminComplaintItem value)?  $default,){
final _that = this;
switch (_that) {
case _AdminComplaintItem() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function(@JsonKey(fromJson: idFromJson)  String id,  String publicCode, @JsonKey(fromJson: idFromJson)  String jobId,  String jobPublicCode,  ComplaintReason reason,  ComplaintStatus status,  String customerName,  String proBusinessName, @MoneyConverter()  Money amount,  DateTime createdAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _AdminComplaintItem() when $default != null:
return $default(_that.id,_that.publicCode,_that.jobId,_that.jobPublicCode,_that.reason,_that.status,_that.customerName,_that.proBusinessName,_that.amount,_that.createdAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function(@JsonKey(fromJson: idFromJson)  String id,  String publicCode, @JsonKey(fromJson: idFromJson)  String jobId,  String jobPublicCode,  ComplaintReason reason,  ComplaintStatus status,  String customerName,  String proBusinessName, @MoneyConverter()  Money amount,  DateTime createdAt)  $default,) {final _that = this;
switch (_that) {
case _AdminComplaintItem():
return $default(_that.id,_that.publicCode,_that.jobId,_that.jobPublicCode,_that.reason,_that.status,_that.customerName,_that.proBusinessName,_that.amount,_that.createdAt);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function(@JsonKey(fromJson: idFromJson)  String id,  String publicCode, @JsonKey(fromJson: idFromJson)  String jobId,  String jobPublicCode,  ComplaintReason reason,  ComplaintStatus status,  String customerName,  String proBusinessName, @MoneyConverter()  Money amount,  DateTime createdAt)?  $default,) {final _that = this;
switch (_that) {
case _AdminComplaintItem() when $default != null:
return $default(_that.id,_that.publicCode,_that.jobId,_that.jobPublicCode,_that.reason,_that.status,_that.customerName,_that.proBusinessName,_that.amount,_that.createdAt);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _AdminComplaintItem implements AdminComplaintItem {
  const _AdminComplaintItem({@JsonKey(fromJson: idFromJson) required this.id, required this.publicCode, @JsonKey(fromJson: idFromJson) required this.jobId, required this.jobPublicCode, required this.reason, required this.status, required this.customerName, required this.proBusinessName, @MoneyConverter() required this.amount, required this.createdAt});
  factory _AdminComplaintItem.fromJson(Map<String, dynamic> json) => _$AdminComplaintItemFromJson(json);

@override@JsonKey(fromJson: idFromJson) final  String id;
@override final  String publicCode;
@override@JsonKey(fromJson: idFromJson) final  String jobId;
@override final  String jobPublicCode;
@override final  ComplaintReason reason;
@override final  ComplaintStatus status;
@override final  String customerName;
@override final  String proBusinessName;
@override@MoneyConverter() final  Money amount;
@override final  DateTime createdAt;

/// Create a copy of AdminComplaintItem
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$AdminComplaintItemCopyWith<_AdminComplaintItem> get copyWith => __$AdminComplaintItemCopyWithImpl<_AdminComplaintItem>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$AdminComplaintItemToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _AdminComplaintItem&&(identical(other.id, id) || other.id == id)&&(identical(other.publicCode, publicCode) || other.publicCode == publicCode)&&(identical(other.jobId, jobId) || other.jobId == jobId)&&(identical(other.jobPublicCode, jobPublicCode) || other.jobPublicCode == jobPublicCode)&&(identical(other.reason, reason) || other.reason == reason)&&(identical(other.status, status) || other.status == status)&&(identical(other.customerName, customerName) || other.customerName == customerName)&&(identical(other.proBusinessName, proBusinessName) || other.proBusinessName == proBusinessName)&&(identical(other.amount, amount) || other.amount == amount)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,publicCode,jobId,jobPublicCode,reason,status,customerName,proBusinessName,amount,createdAt);

@override
String toString() {
  return 'AdminComplaintItem(id: $id, publicCode: $publicCode, jobId: $jobId, jobPublicCode: $jobPublicCode, reason: $reason, status: $status, customerName: $customerName, proBusinessName: $proBusinessName, amount: $amount, createdAt: $createdAt)';
}


}

/// @nodoc
abstract mixin class _$AdminComplaintItemCopyWith<$Res> implements $AdminComplaintItemCopyWith<$Res> {
  factory _$AdminComplaintItemCopyWith(_AdminComplaintItem value, $Res Function(_AdminComplaintItem) _then) = __$AdminComplaintItemCopyWithImpl;
@override @useResult
$Res call({
@JsonKey(fromJson: idFromJson) String id, String publicCode,@JsonKey(fromJson: idFromJson) String jobId, String jobPublicCode, ComplaintReason reason, ComplaintStatus status, String customerName, String proBusinessName,@MoneyConverter() Money amount, DateTime createdAt
});




}
/// @nodoc
class __$AdminComplaintItemCopyWithImpl<$Res>
    implements _$AdminComplaintItemCopyWith<$Res> {
  __$AdminComplaintItemCopyWithImpl(this._self, this._then);

  final _AdminComplaintItem _self;
  final $Res Function(_AdminComplaintItem) _then;

/// Create a copy of AdminComplaintItem
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? publicCode = null,Object? jobId = null,Object? jobPublicCode = null,Object? reason = null,Object? status = null,Object? customerName = null,Object? proBusinessName = null,Object? amount = null,Object? createdAt = null,}) {
  return _then(_AdminComplaintItem(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,publicCode: null == publicCode ? _self.publicCode : publicCode // ignore: cast_nullable_to_non_nullable
as String,jobId: null == jobId ? _self.jobId : jobId // ignore: cast_nullable_to_non_nullable
as String,jobPublicCode: null == jobPublicCode ? _self.jobPublicCode : jobPublicCode // ignore: cast_nullable_to_non_nullable
as String,reason: null == reason ? _self.reason : reason // ignore: cast_nullable_to_non_nullable
as ComplaintReason,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as ComplaintStatus,customerName: null == customerName ? _self.customerName : customerName // ignore: cast_nullable_to_non_nullable
as String,proBusinessName: null == proBusinessName ? _self.proBusinessName : proBusinessName // ignore: cast_nullable_to_non_nullable
as String,amount: null == amount ? _self.amount : amount // ignore: cast_nullable_to_non_nullable
as Money,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}


}


/// @nodoc
mixin _$AdminComplaintJob {

@JsonKey(fromJson: idFromJson) String get id; String get publicCode; String get title; JobStatus get status; JobStatus? get statusBeforeDispute; List<JobEvent> get timeline; OfferDetail get offer; String get districtName;
/// Create a copy of AdminComplaintJob
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$AdminComplaintJobCopyWith<AdminComplaintJob> get copyWith => _$AdminComplaintJobCopyWithImpl<AdminComplaintJob>(this as AdminComplaintJob, _$identity);

  /// Serializes this AdminComplaintJob to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is AdminComplaintJob&&(identical(other.id, id) || other.id == id)&&(identical(other.publicCode, publicCode) || other.publicCode == publicCode)&&(identical(other.title, title) || other.title == title)&&(identical(other.status, status) || other.status == status)&&(identical(other.statusBeforeDispute, statusBeforeDispute) || other.statusBeforeDispute == statusBeforeDispute)&&const DeepCollectionEquality().equals(other.timeline, timeline)&&(identical(other.offer, offer) || other.offer == offer)&&(identical(other.districtName, districtName) || other.districtName == districtName));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,publicCode,title,status,statusBeforeDispute,const DeepCollectionEquality().hash(timeline),offer,districtName);

@override
String toString() {
  return 'AdminComplaintJob(id: $id, publicCode: $publicCode, title: $title, status: $status, statusBeforeDispute: $statusBeforeDispute, timeline: $timeline, offer: $offer, districtName: $districtName)';
}


}

/// @nodoc
abstract mixin class $AdminComplaintJobCopyWith<$Res>  {
  factory $AdminComplaintJobCopyWith(AdminComplaintJob value, $Res Function(AdminComplaintJob) _then) = _$AdminComplaintJobCopyWithImpl;
@useResult
$Res call({
@JsonKey(fromJson: idFromJson) String id, String publicCode, String title, JobStatus status, JobStatus? statusBeforeDispute, List<JobEvent> timeline, OfferDetail offer, String districtName
});


$OfferDetailCopyWith<$Res> get offer;

}
/// @nodoc
class _$AdminComplaintJobCopyWithImpl<$Res>
    implements $AdminComplaintJobCopyWith<$Res> {
  _$AdminComplaintJobCopyWithImpl(this._self, this._then);

  final AdminComplaintJob _self;
  final $Res Function(AdminComplaintJob) _then;

/// Create a copy of AdminComplaintJob
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? publicCode = null,Object? title = null,Object? status = null,Object? statusBeforeDispute = freezed,Object? timeline = null,Object? offer = null,Object? districtName = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,publicCode: null == publicCode ? _self.publicCode : publicCode // ignore: cast_nullable_to_non_nullable
as String,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as JobStatus,statusBeforeDispute: freezed == statusBeforeDispute ? _self.statusBeforeDispute : statusBeforeDispute // ignore: cast_nullable_to_non_nullable
as JobStatus?,timeline: null == timeline ? _self.timeline : timeline // ignore: cast_nullable_to_non_nullable
as List<JobEvent>,offer: null == offer ? _self.offer : offer // ignore: cast_nullable_to_non_nullable
as OfferDetail,districtName: null == districtName ? _self.districtName : districtName // ignore: cast_nullable_to_non_nullable
as String,
  ));
}
/// Create a copy of AdminComplaintJob
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$OfferDetailCopyWith<$Res> get offer {
  
  return $OfferDetailCopyWith<$Res>(_self.offer, (value) {
    return _then(_self.copyWith(offer: value));
  });
}
}


/// Adds pattern-matching-related methods to [AdminComplaintJob].
extension AdminComplaintJobPatterns on AdminComplaintJob {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _AdminComplaintJob value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _AdminComplaintJob() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _AdminComplaintJob value)  $default,){
final _that = this;
switch (_that) {
case _AdminComplaintJob():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _AdminComplaintJob value)?  $default,){
final _that = this;
switch (_that) {
case _AdminComplaintJob() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function(@JsonKey(fromJson: idFromJson)  String id,  String publicCode,  String title,  JobStatus status,  JobStatus? statusBeforeDispute,  List<JobEvent> timeline,  OfferDetail offer,  String districtName)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _AdminComplaintJob() when $default != null:
return $default(_that.id,_that.publicCode,_that.title,_that.status,_that.statusBeforeDispute,_that.timeline,_that.offer,_that.districtName);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function(@JsonKey(fromJson: idFromJson)  String id,  String publicCode,  String title,  JobStatus status,  JobStatus? statusBeforeDispute,  List<JobEvent> timeline,  OfferDetail offer,  String districtName)  $default,) {final _that = this;
switch (_that) {
case _AdminComplaintJob():
return $default(_that.id,_that.publicCode,_that.title,_that.status,_that.statusBeforeDispute,_that.timeline,_that.offer,_that.districtName);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function(@JsonKey(fromJson: idFromJson)  String id,  String publicCode,  String title,  JobStatus status,  JobStatus? statusBeforeDispute,  List<JobEvent> timeline,  OfferDetail offer,  String districtName)?  $default,) {final _that = this;
switch (_that) {
case _AdminComplaintJob() when $default != null:
return $default(_that.id,_that.publicCode,_that.title,_that.status,_that.statusBeforeDispute,_that.timeline,_that.offer,_that.districtName);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _AdminComplaintJob implements AdminComplaintJob {
  const _AdminComplaintJob({@JsonKey(fromJson: idFromJson) required this.id, required this.publicCode, required this.title, required this.status, this.statusBeforeDispute, this.timeline = const <JobEvent>[], required this.offer, this.districtName = ''});
  factory _AdminComplaintJob.fromJson(Map<String, dynamic> json) => _$AdminComplaintJobFromJson(json);

@override@JsonKey(fromJson: idFromJson) final  String id;
@override final  String publicCode;
@override final  String title;
@override final  JobStatus status;
@override final  JobStatus? statusBeforeDispute;
@override@JsonKey() final  List<JobEvent> timeline;
@override final  OfferDetail offer;
@override@JsonKey() final  String districtName;

/// Create a copy of AdminComplaintJob
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$AdminComplaintJobCopyWith<_AdminComplaintJob> get copyWith => __$AdminComplaintJobCopyWithImpl<_AdminComplaintJob>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$AdminComplaintJobToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _AdminComplaintJob&&(identical(other.id, id) || other.id == id)&&(identical(other.publicCode, publicCode) || other.publicCode == publicCode)&&(identical(other.title, title) || other.title == title)&&(identical(other.status, status) || other.status == status)&&(identical(other.statusBeforeDispute, statusBeforeDispute) || other.statusBeforeDispute == statusBeforeDispute)&&const DeepCollectionEquality().equals(other.timeline, timeline)&&(identical(other.offer, offer) || other.offer == offer)&&(identical(other.districtName, districtName) || other.districtName == districtName));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,publicCode,title,status,statusBeforeDispute,const DeepCollectionEquality().hash(timeline),offer,districtName);

@override
String toString() {
  return 'AdminComplaintJob(id: $id, publicCode: $publicCode, title: $title, status: $status, statusBeforeDispute: $statusBeforeDispute, timeline: $timeline, offer: $offer, districtName: $districtName)';
}


}

/// @nodoc
abstract mixin class _$AdminComplaintJobCopyWith<$Res> implements $AdminComplaintJobCopyWith<$Res> {
  factory _$AdminComplaintJobCopyWith(_AdminComplaintJob value, $Res Function(_AdminComplaintJob) _then) = __$AdminComplaintJobCopyWithImpl;
@override @useResult
$Res call({
@JsonKey(fromJson: idFromJson) String id, String publicCode, String title, JobStatus status, JobStatus? statusBeforeDispute, List<JobEvent> timeline, OfferDetail offer, String districtName
});


@override $OfferDetailCopyWith<$Res> get offer;

}
/// @nodoc
class __$AdminComplaintJobCopyWithImpl<$Res>
    implements _$AdminComplaintJobCopyWith<$Res> {
  __$AdminComplaintJobCopyWithImpl(this._self, this._then);

  final _AdminComplaintJob _self;
  final $Res Function(_AdminComplaintJob) _then;

/// Create a copy of AdminComplaintJob
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? publicCode = null,Object? title = null,Object? status = null,Object? statusBeforeDispute = freezed,Object? timeline = null,Object? offer = null,Object? districtName = null,}) {
  return _then(_AdminComplaintJob(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,publicCode: null == publicCode ? _self.publicCode : publicCode // ignore: cast_nullable_to_non_nullable
as String,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as JobStatus,statusBeforeDispute: freezed == statusBeforeDispute ? _self.statusBeforeDispute : statusBeforeDispute // ignore: cast_nullable_to_non_nullable
as JobStatus?,timeline: null == timeline ? _self.timeline : timeline // ignore: cast_nullable_to_non_nullable
as List<JobEvent>,offer: null == offer ? _self.offer : offer // ignore: cast_nullable_to_non_nullable
as OfferDetail,districtName: null == districtName ? _self.districtName : districtName // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

/// Create a copy of AdminComplaintJob
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$OfferDetailCopyWith<$Res> get offer {
  
  return $OfferDetailCopyWith<$Res>(_self.offer, (value) {
    return _then(_self.copyWith(offer: value));
  });
}
}


/// @nodoc
mixin _$AdminPaymentSummary {

 String get ref; String get status; String get provider;@MoneyConverter() Money get totalAmount;@MoneyConverter() Money get commission;@MoneyConverter() Money get proPayout;@MoneyConverter() Money get refundedAmount;
/// Create a copy of AdminPaymentSummary
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$AdminPaymentSummaryCopyWith<AdminPaymentSummary> get copyWith => _$AdminPaymentSummaryCopyWithImpl<AdminPaymentSummary>(this as AdminPaymentSummary, _$identity);

  /// Serializes this AdminPaymentSummary to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is AdminPaymentSummary&&(identical(other.ref, ref) || other.ref == ref)&&(identical(other.status, status) || other.status == status)&&(identical(other.provider, provider) || other.provider == provider)&&(identical(other.totalAmount, totalAmount) || other.totalAmount == totalAmount)&&(identical(other.commission, commission) || other.commission == commission)&&(identical(other.proPayout, proPayout) || other.proPayout == proPayout)&&(identical(other.refundedAmount, refundedAmount) || other.refundedAmount == refundedAmount));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,ref,status,provider,totalAmount,commission,proPayout,refundedAmount);

@override
String toString() {
  return 'AdminPaymentSummary(ref: $ref, status: $status, provider: $provider, totalAmount: $totalAmount, commission: $commission, proPayout: $proPayout, refundedAmount: $refundedAmount)';
}


}

/// @nodoc
abstract mixin class $AdminPaymentSummaryCopyWith<$Res>  {
  factory $AdminPaymentSummaryCopyWith(AdminPaymentSummary value, $Res Function(AdminPaymentSummary) _then) = _$AdminPaymentSummaryCopyWithImpl;
@useResult
$Res call({
 String ref, String status, String provider,@MoneyConverter() Money totalAmount,@MoneyConverter() Money commission,@MoneyConverter() Money proPayout,@MoneyConverter() Money refundedAmount
});




}
/// @nodoc
class _$AdminPaymentSummaryCopyWithImpl<$Res>
    implements $AdminPaymentSummaryCopyWith<$Res> {
  _$AdminPaymentSummaryCopyWithImpl(this._self, this._then);

  final AdminPaymentSummary _self;
  final $Res Function(AdminPaymentSummary) _then;

/// Create a copy of AdminPaymentSummary
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? ref = null,Object? status = null,Object? provider = null,Object? totalAmount = null,Object? commission = null,Object? proPayout = null,Object? refundedAmount = null,}) {
  return _then(_self.copyWith(
ref: null == ref ? _self.ref : ref // ignore: cast_nullable_to_non_nullable
as String,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as String,provider: null == provider ? _self.provider : provider // ignore: cast_nullable_to_non_nullable
as String,totalAmount: null == totalAmount ? _self.totalAmount : totalAmount // ignore: cast_nullable_to_non_nullable
as Money,commission: null == commission ? _self.commission : commission // ignore: cast_nullable_to_non_nullable
as Money,proPayout: null == proPayout ? _self.proPayout : proPayout // ignore: cast_nullable_to_non_nullable
as Money,refundedAmount: null == refundedAmount ? _self.refundedAmount : refundedAmount // ignore: cast_nullable_to_non_nullable
as Money,
  ));
}

}


/// Adds pattern-matching-related methods to [AdminPaymentSummary].
extension AdminPaymentSummaryPatterns on AdminPaymentSummary {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _AdminPaymentSummary value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _AdminPaymentSummary() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _AdminPaymentSummary value)  $default,){
final _that = this;
switch (_that) {
case _AdminPaymentSummary():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _AdminPaymentSummary value)?  $default,){
final _that = this;
switch (_that) {
case _AdminPaymentSummary() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String ref,  String status,  String provider, @MoneyConverter()  Money totalAmount, @MoneyConverter()  Money commission, @MoneyConverter()  Money proPayout, @MoneyConverter()  Money refundedAmount)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _AdminPaymentSummary() when $default != null:
return $default(_that.ref,_that.status,_that.provider,_that.totalAmount,_that.commission,_that.proPayout,_that.refundedAmount);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String ref,  String status,  String provider, @MoneyConverter()  Money totalAmount, @MoneyConverter()  Money commission, @MoneyConverter()  Money proPayout, @MoneyConverter()  Money refundedAmount)  $default,) {final _that = this;
switch (_that) {
case _AdminPaymentSummary():
return $default(_that.ref,_that.status,_that.provider,_that.totalAmount,_that.commission,_that.proPayout,_that.refundedAmount);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String ref,  String status,  String provider, @MoneyConverter()  Money totalAmount, @MoneyConverter()  Money commission, @MoneyConverter()  Money proPayout, @MoneyConverter()  Money refundedAmount)?  $default,) {final _that = this;
switch (_that) {
case _AdminPaymentSummary() when $default != null:
return $default(_that.ref,_that.status,_that.provider,_that.totalAmount,_that.commission,_that.proPayout,_that.refundedAmount);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _AdminPaymentSummary implements AdminPaymentSummary {
  const _AdminPaymentSummary({required this.ref, required this.status, required this.provider, @MoneyConverter() required this.totalAmount, @MoneyConverter() this.commission = Money.zero, @MoneyConverter() this.proPayout = Money.zero, @MoneyConverter() this.refundedAmount = Money.zero});
  factory _AdminPaymentSummary.fromJson(Map<String, dynamic> json) => _$AdminPaymentSummaryFromJson(json);

@override final  String ref;
@override final  String status;
@override final  String provider;
@override@MoneyConverter() final  Money totalAmount;
@override@JsonKey()@MoneyConverter() final  Money commission;
@override@JsonKey()@MoneyConverter() final  Money proPayout;
@override@JsonKey()@MoneyConverter() final  Money refundedAmount;

/// Create a copy of AdminPaymentSummary
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$AdminPaymentSummaryCopyWith<_AdminPaymentSummary> get copyWith => __$AdminPaymentSummaryCopyWithImpl<_AdminPaymentSummary>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$AdminPaymentSummaryToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _AdminPaymentSummary&&(identical(other.ref, ref) || other.ref == ref)&&(identical(other.status, status) || other.status == status)&&(identical(other.provider, provider) || other.provider == provider)&&(identical(other.totalAmount, totalAmount) || other.totalAmount == totalAmount)&&(identical(other.commission, commission) || other.commission == commission)&&(identical(other.proPayout, proPayout) || other.proPayout == proPayout)&&(identical(other.refundedAmount, refundedAmount) || other.refundedAmount == refundedAmount));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,ref,status,provider,totalAmount,commission,proPayout,refundedAmount);

@override
String toString() {
  return 'AdminPaymentSummary(ref: $ref, status: $status, provider: $provider, totalAmount: $totalAmount, commission: $commission, proPayout: $proPayout, refundedAmount: $refundedAmount)';
}


}

/// @nodoc
abstract mixin class _$AdminPaymentSummaryCopyWith<$Res> implements $AdminPaymentSummaryCopyWith<$Res> {
  factory _$AdminPaymentSummaryCopyWith(_AdminPaymentSummary value, $Res Function(_AdminPaymentSummary) _then) = __$AdminPaymentSummaryCopyWithImpl;
@override @useResult
$Res call({
 String ref, String status, String provider,@MoneyConverter() Money totalAmount,@MoneyConverter() Money commission,@MoneyConverter() Money proPayout,@MoneyConverter() Money refundedAmount
});




}
/// @nodoc
class __$AdminPaymentSummaryCopyWithImpl<$Res>
    implements _$AdminPaymentSummaryCopyWith<$Res> {
  __$AdminPaymentSummaryCopyWithImpl(this._self, this._then);

  final _AdminPaymentSummary _self;
  final $Res Function(_AdminPaymentSummary) _then;

/// Create a copy of AdminPaymentSummary
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? ref = null,Object? status = null,Object? provider = null,Object? totalAmount = null,Object? commission = null,Object? proPayout = null,Object? refundedAmount = null,}) {
  return _then(_AdminPaymentSummary(
ref: null == ref ? _self.ref : ref // ignore: cast_nullable_to_non_nullable
as String,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as String,provider: null == provider ? _self.provider : provider // ignore: cast_nullable_to_non_nullable
as String,totalAmount: null == totalAmount ? _self.totalAmount : totalAmount // ignore: cast_nullable_to_non_nullable
as Money,commission: null == commission ? _self.commission : commission // ignore: cast_nullable_to_non_nullable
as Money,proPayout: null == proPayout ? _self.proPayout : proPayout // ignore: cast_nullable_to_non_nullable
as Money,refundedAmount: null == refundedAmount ? _self.refundedAmount : refundedAmount // ignore: cast_nullable_to_non_nullable
as Money,
  ));
}


}


/// @nodoc
mixin _$AdminMessage {

@JsonKey(fromJson: idFromJson) String get id; PartyRole get senderRole; String get body; MediaRef? get photo; DateTime get createdAt;
/// Create a copy of AdminMessage
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$AdminMessageCopyWith<AdminMessage> get copyWith => _$AdminMessageCopyWithImpl<AdminMessage>(this as AdminMessage, _$identity);

  /// Serializes this AdminMessage to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is AdminMessage&&(identical(other.id, id) || other.id == id)&&(identical(other.senderRole, senderRole) || other.senderRole == senderRole)&&(identical(other.body, body) || other.body == body)&&(identical(other.photo, photo) || other.photo == photo)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,senderRole,body,photo,createdAt);

@override
String toString() {
  return 'AdminMessage(id: $id, senderRole: $senderRole, body: $body, photo: $photo, createdAt: $createdAt)';
}


}

/// @nodoc
abstract mixin class $AdminMessageCopyWith<$Res>  {
  factory $AdminMessageCopyWith(AdminMessage value, $Res Function(AdminMessage) _then) = _$AdminMessageCopyWithImpl;
@useResult
$Res call({
@JsonKey(fromJson: idFromJson) String id, PartyRole senderRole, String body, MediaRef? photo, DateTime createdAt
});


$MediaRefCopyWith<$Res>? get photo;

}
/// @nodoc
class _$AdminMessageCopyWithImpl<$Res>
    implements $AdminMessageCopyWith<$Res> {
  _$AdminMessageCopyWithImpl(this._self, this._then);

  final AdminMessage _self;
  final $Res Function(AdminMessage) _then;

/// Create a copy of AdminMessage
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? senderRole = null,Object? body = null,Object? photo = freezed,Object? createdAt = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,senderRole: null == senderRole ? _self.senderRole : senderRole // ignore: cast_nullable_to_non_nullable
as PartyRole,body: null == body ? _self.body : body // ignore: cast_nullable_to_non_nullable
as String,photo: freezed == photo ? _self.photo : photo // ignore: cast_nullable_to_non_nullable
as MediaRef?,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}
/// Create a copy of AdminMessage
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


/// Adds pattern-matching-related methods to [AdminMessage].
extension AdminMessagePatterns on AdminMessage {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _AdminMessage value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _AdminMessage() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _AdminMessage value)  $default,){
final _that = this;
switch (_that) {
case _AdminMessage():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _AdminMessage value)?  $default,){
final _that = this;
switch (_that) {
case _AdminMessage() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function(@JsonKey(fromJson: idFromJson)  String id,  PartyRole senderRole,  String body,  MediaRef? photo,  DateTime createdAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _AdminMessage() when $default != null:
return $default(_that.id,_that.senderRole,_that.body,_that.photo,_that.createdAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function(@JsonKey(fromJson: idFromJson)  String id,  PartyRole senderRole,  String body,  MediaRef? photo,  DateTime createdAt)  $default,) {final _that = this;
switch (_that) {
case _AdminMessage():
return $default(_that.id,_that.senderRole,_that.body,_that.photo,_that.createdAt);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function(@JsonKey(fromJson: idFromJson)  String id,  PartyRole senderRole,  String body,  MediaRef? photo,  DateTime createdAt)?  $default,) {final _that = this;
switch (_that) {
case _AdminMessage() when $default != null:
return $default(_that.id,_that.senderRole,_that.body,_that.photo,_that.createdAt);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _AdminMessage implements AdminMessage {
  const _AdminMessage({@JsonKey(fromJson: idFromJson) required this.id, required this.senderRole, this.body = '', this.photo, required this.createdAt});
  factory _AdminMessage.fromJson(Map<String, dynamic> json) => _$AdminMessageFromJson(json);

@override@JsonKey(fromJson: idFromJson) final  String id;
@override final  PartyRole senderRole;
@override@JsonKey() final  String body;
@override final  MediaRef? photo;
@override final  DateTime createdAt;

/// Create a copy of AdminMessage
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$AdminMessageCopyWith<_AdminMessage> get copyWith => __$AdminMessageCopyWithImpl<_AdminMessage>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$AdminMessageToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _AdminMessage&&(identical(other.id, id) || other.id == id)&&(identical(other.senderRole, senderRole) || other.senderRole == senderRole)&&(identical(other.body, body) || other.body == body)&&(identical(other.photo, photo) || other.photo == photo)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,senderRole,body,photo,createdAt);

@override
String toString() {
  return 'AdminMessage(id: $id, senderRole: $senderRole, body: $body, photo: $photo, createdAt: $createdAt)';
}


}

/// @nodoc
abstract mixin class _$AdminMessageCopyWith<$Res> implements $AdminMessageCopyWith<$Res> {
  factory _$AdminMessageCopyWith(_AdminMessage value, $Res Function(_AdminMessage) _then) = __$AdminMessageCopyWithImpl;
@override @useResult
$Res call({
@JsonKey(fromJson: idFromJson) String id, PartyRole senderRole, String body, MediaRef? photo, DateTime createdAt
});


@override $MediaRefCopyWith<$Res>? get photo;

}
/// @nodoc
class __$AdminMessageCopyWithImpl<$Res>
    implements _$AdminMessageCopyWith<$Res> {
  __$AdminMessageCopyWithImpl(this._self, this._then);

  final _AdminMessage _self;
  final $Res Function(_AdminMessage) _then;

/// Create a copy of AdminMessage
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? senderRole = null,Object? body = null,Object? photo = freezed,Object? createdAt = null,}) {
  return _then(_AdminMessage(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,senderRole: null == senderRole ? _self.senderRole : senderRole // ignore: cast_nullable_to_non_nullable
as PartyRole,body: null == body ? _self.body : body // ignore: cast_nullable_to_non_nullable
as String,photo: freezed == photo ? _self.photo : photo // ignore: cast_nullable_to_non_nullable
as MediaRef?,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}

/// Create a copy of AdminMessage
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
mixin _$AdminPartyCustomer {

@JsonKey(fromJson: idFromJson) String get id; String get fullName;
/// Create a copy of AdminPartyCustomer
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$AdminPartyCustomerCopyWith<AdminPartyCustomer> get copyWith => _$AdminPartyCustomerCopyWithImpl<AdminPartyCustomer>(this as AdminPartyCustomer, _$identity);

  /// Serializes this AdminPartyCustomer to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is AdminPartyCustomer&&(identical(other.id, id) || other.id == id)&&(identical(other.fullName, fullName) || other.fullName == fullName));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,fullName);

@override
String toString() {
  return 'AdminPartyCustomer(id: $id, fullName: $fullName)';
}


}

/// @nodoc
abstract mixin class $AdminPartyCustomerCopyWith<$Res>  {
  factory $AdminPartyCustomerCopyWith(AdminPartyCustomer value, $Res Function(AdminPartyCustomer) _then) = _$AdminPartyCustomerCopyWithImpl;
@useResult
$Res call({
@JsonKey(fromJson: idFromJson) String id, String fullName
});




}
/// @nodoc
class _$AdminPartyCustomerCopyWithImpl<$Res>
    implements $AdminPartyCustomerCopyWith<$Res> {
  _$AdminPartyCustomerCopyWithImpl(this._self, this._then);

  final AdminPartyCustomer _self;
  final $Res Function(AdminPartyCustomer) _then;

/// Create a copy of AdminPartyCustomer
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? fullName = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,fullName: null == fullName ? _self.fullName : fullName // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [AdminPartyCustomer].
extension AdminPartyCustomerPatterns on AdminPartyCustomer {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _AdminPartyCustomer value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _AdminPartyCustomer() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _AdminPartyCustomer value)  $default,){
final _that = this;
switch (_that) {
case _AdminPartyCustomer():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _AdminPartyCustomer value)?  $default,){
final _that = this;
switch (_that) {
case _AdminPartyCustomer() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function(@JsonKey(fromJson: idFromJson)  String id,  String fullName)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _AdminPartyCustomer() when $default != null:
return $default(_that.id,_that.fullName);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function(@JsonKey(fromJson: idFromJson)  String id,  String fullName)  $default,) {final _that = this;
switch (_that) {
case _AdminPartyCustomer():
return $default(_that.id,_that.fullName);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function(@JsonKey(fromJson: idFromJson)  String id,  String fullName)?  $default,) {final _that = this;
switch (_that) {
case _AdminPartyCustomer() when $default != null:
return $default(_that.id,_that.fullName);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _AdminPartyCustomer implements AdminPartyCustomer {
  const _AdminPartyCustomer({@JsonKey(fromJson: idFromJson) required this.id, required this.fullName});
  factory _AdminPartyCustomer.fromJson(Map<String, dynamic> json) => _$AdminPartyCustomerFromJson(json);

@override@JsonKey(fromJson: idFromJson) final  String id;
@override final  String fullName;

/// Create a copy of AdminPartyCustomer
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$AdminPartyCustomerCopyWith<_AdminPartyCustomer> get copyWith => __$AdminPartyCustomerCopyWithImpl<_AdminPartyCustomer>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$AdminPartyCustomerToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _AdminPartyCustomer&&(identical(other.id, id) || other.id == id)&&(identical(other.fullName, fullName) || other.fullName == fullName));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,fullName);

@override
String toString() {
  return 'AdminPartyCustomer(id: $id, fullName: $fullName)';
}


}

/// @nodoc
abstract mixin class _$AdminPartyCustomerCopyWith<$Res> implements $AdminPartyCustomerCopyWith<$Res> {
  factory _$AdminPartyCustomerCopyWith(_AdminPartyCustomer value, $Res Function(_AdminPartyCustomer) _then) = __$AdminPartyCustomerCopyWithImpl;
@override @useResult
$Res call({
@JsonKey(fromJson: idFromJson) String id, String fullName
});




}
/// @nodoc
class __$AdminPartyCustomerCopyWithImpl<$Res>
    implements _$AdminPartyCustomerCopyWith<$Res> {
  __$AdminPartyCustomerCopyWithImpl(this._self, this._then);

  final _AdminPartyCustomer _self;
  final $Res Function(_AdminPartyCustomer) _then;

/// Create a copy of AdminPartyCustomer
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? fullName = null,}) {
  return _then(_AdminPartyCustomer(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,fullName: null == fullName ? _self.fullName : fullName // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}


/// @nodoc
mixin _$AdminPartyPro {

@JsonKey(fromJson: idFromJson) String get id; String get businessName; String get fullName; int get warningCount; int get cancellationCount;
/// Create a copy of AdminPartyPro
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$AdminPartyProCopyWith<AdminPartyPro> get copyWith => _$AdminPartyProCopyWithImpl<AdminPartyPro>(this as AdminPartyPro, _$identity);

  /// Serializes this AdminPartyPro to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is AdminPartyPro&&(identical(other.id, id) || other.id == id)&&(identical(other.businessName, businessName) || other.businessName == businessName)&&(identical(other.fullName, fullName) || other.fullName == fullName)&&(identical(other.warningCount, warningCount) || other.warningCount == warningCount)&&(identical(other.cancellationCount, cancellationCount) || other.cancellationCount == cancellationCount));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,businessName,fullName,warningCount,cancellationCount);

@override
String toString() {
  return 'AdminPartyPro(id: $id, businessName: $businessName, fullName: $fullName, warningCount: $warningCount, cancellationCount: $cancellationCount)';
}


}

/// @nodoc
abstract mixin class $AdminPartyProCopyWith<$Res>  {
  factory $AdminPartyProCopyWith(AdminPartyPro value, $Res Function(AdminPartyPro) _then) = _$AdminPartyProCopyWithImpl;
@useResult
$Res call({
@JsonKey(fromJson: idFromJson) String id, String businessName, String fullName, int warningCount, int cancellationCount
});




}
/// @nodoc
class _$AdminPartyProCopyWithImpl<$Res>
    implements $AdminPartyProCopyWith<$Res> {
  _$AdminPartyProCopyWithImpl(this._self, this._then);

  final AdminPartyPro _self;
  final $Res Function(AdminPartyPro) _then;

/// Create a copy of AdminPartyPro
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? businessName = null,Object? fullName = null,Object? warningCount = null,Object? cancellationCount = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,businessName: null == businessName ? _self.businessName : businessName // ignore: cast_nullable_to_non_nullable
as String,fullName: null == fullName ? _self.fullName : fullName // ignore: cast_nullable_to_non_nullable
as String,warningCount: null == warningCount ? _self.warningCount : warningCount // ignore: cast_nullable_to_non_nullable
as int,cancellationCount: null == cancellationCount ? _self.cancellationCount : cancellationCount // ignore: cast_nullable_to_non_nullable
as int,
  ));
}

}


/// Adds pattern-matching-related methods to [AdminPartyPro].
extension AdminPartyProPatterns on AdminPartyPro {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _AdminPartyPro value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _AdminPartyPro() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _AdminPartyPro value)  $default,){
final _that = this;
switch (_that) {
case _AdminPartyPro():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _AdminPartyPro value)?  $default,){
final _that = this;
switch (_that) {
case _AdminPartyPro() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function(@JsonKey(fromJson: idFromJson)  String id,  String businessName,  String fullName,  int warningCount,  int cancellationCount)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _AdminPartyPro() when $default != null:
return $default(_that.id,_that.businessName,_that.fullName,_that.warningCount,_that.cancellationCount);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function(@JsonKey(fromJson: idFromJson)  String id,  String businessName,  String fullName,  int warningCount,  int cancellationCount)  $default,) {final _that = this;
switch (_that) {
case _AdminPartyPro():
return $default(_that.id,_that.businessName,_that.fullName,_that.warningCount,_that.cancellationCount);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function(@JsonKey(fromJson: idFromJson)  String id,  String businessName,  String fullName,  int warningCount,  int cancellationCount)?  $default,) {final _that = this;
switch (_that) {
case _AdminPartyPro() when $default != null:
return $default(_that.id,_that.businessName,_that.fullName,_that.warningCount,_that.cancellationCount);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _AdminPartyPro implements AdminPartyPro {
  const _AdminPartyPro({@JsonKey(fromJson: idFromJson) required this.id, required this.businessName, required this.fullName, this.warningCount = 0, this.cancellationCount = 0});
  factory _AdminPartyPro.fromJson(Map<String, dynamic> json) => _$AdminPartyProFromJson(json);

@override@JsonKey(fromJson: idFromJson) final  String id;
@override final  String businessName;
@override final  String fullName;
@override@JsonKey() final  int warningCount;
@override@JsonKey() final  int cancellationCount;

/// Create a copy of AdminPartyPro
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$AdminPartyProCopyWith<_AdminPartyPro> get copyWith => __$AdminPartyProCopyWithImpl<_AdminPartyPro>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$AdminPartyProToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _AdminPartyPro&&(identical(other.id, id) || other.id == id)&&(identical(other.businessName, businessName) || other.businessName == businessName)&&(identical(other.fullName, fullName) || other.fullName == fullName)&&(identical(other.warningCount, warningCount) || other.warningCount == warningCount)&&(identical(other.cancellationCount, cancellationCount) || other.cancellationCount == cancellationCount));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,businessName,fullName,warningCount,cancellationCount);

@override
String toString() {
  return 'AdminPartyPro(id: $id, businessName: $businessName, fullName: $fullName, warningCount: $warningCount, cancellationCount: $cancellationCount)';
}


}

/// @nodoc
abstract mixin class _$AdminPartyProCopyWith<$Res> implements $AdminPartyProCopyWith<$Res> {
  factory _$AdminPartyProCopyWith(_AdminPartyPro value, $Res Function(_AdminPartyPro) _then) = __$AdminPartyProCopyWithImpl;
@override @useResult
$Res call({
@JsonKey(fromJson: idFromJson) String id, String businessName, String fullName, int warningCount, int cancellationCount
});




}
/// @nodoc
class __$AdminPartyProCopyWithImpl<$Res>
    implements _$AdminPartyProCopyWith<$Res> {
  __$AdminPartyProCopyWithImpl(this._self, this._then);

  final _AdminPartyPro _self;
  final $Res Function(_AdminPartyPro) _then;

/// Create a copy of AdminPartyPro
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? businessName = null,Object? fullName = null,Object? warningCount = null,Object? cancellationCount = null,}) {
  return _then(_AdminPartyPro(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,businessName: null == businessName ? _self.businessName : businessName // ignore: cast_nullable_to_non_nullable
as String,fullName: null == fullName ? _self.fullName : fullName // ignore: cast_nullable_to_non_nullable
as String,warningCount: null == warningCount ? _self.warningCount : warningCount // ignore: cast_nullable_to_non_nullable
as int,cancellationCount: null == cancellationCount ? _self.cancellationCount : cancellationCount // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}


/// @nodoc
mixin _$AdminComplaintDetail {

@JsonKey(fromJson: idFromJson) String get id; String get publicCode;@JsonKey(fromJson: idFromJson) String get jobId; ComplaintReason get reason; String get description; List<MediaRef> get evidence; ComplaintStatus get status; String? get decision; String? get decisionNote;@NullableMoneyConverter() Money? get refundAmount;@NullableMoneyConverter() Money? get proAmount; DateTime get createdAt; DateTime? get decidedAt;/// Karar bayrakları (karar verilmeden önce `false`).
 bool get warnPro; bool get suspendPro; AdminComplaintJob get job;/// Sunucu emanet kaydı yoksa `null` döner.
 AdminPaymentSummary? get payment; List<AdminMessage> get messages; AdminPartyCustomer get customer; AdminPartyPro get pro;
/// Create a copy of AdminComplaintDetail
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$AdminComplaintDetailCopyWith<AdminComplaintDetail> get copyWith => _$AdminComplaintDetailCopyWithImpl<AdminComplaintDetail>(this as AdminComplaintDetail, _$identity);

  /// Serializes this AdminComplaintDetail to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is AdminComplaintDetail&&(identical(other.id, id) || other.id == id)&&(identical(other.publicCode, publicCode) || other.publicCode == publicCode)&&(identical(other.jobId, jobId) || other.jobId == jobId)&&(identical(other.reason, reason) || other.reason == reason)&&(identical(other.description, description) || other.description == description)&&const DeepCollectionEquality().equals(other.evidence, evidence)&&(identical(other.status, status) || other.status == status)&&(identical(other.decision, decision) || other.decision == decision)&&(identical(other.decisionNote, decisionNote) || other.decisionNote == decisionNote)&&(identical(other.refundAmount, refundAmount) || other.refundAmount == refundAmount)&&(identical(other.proAmount, proAmount) || other.proAmount == proAmount)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.decidedAt, decidedAt) || other.decidedAt == decidedAt)&&(identical(other.warnPro, warnPro) || other.warnPro == warnPro)&&(identical(other.suspendPro, suspendPro) || other.suspendPro == suspendPro)&&(identical(other.job, job) || other.job == job)&&(identical(other.payment, payment) || other.payment == payment)&&const DeepCollectionEquality().equals(other.messages, messages)&&(identical(other.customer, customer) || other.customer == customer)&&(identical(other.pro, pro) || other.pro == pro));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hashAll([runtimeType,id,publicCode,jobId,reason,description,const DeepCollectionEquality().hash(evidence),status,decision,decisionNote,refundAmount,proAmount,createdAt,decidedAt,warnPro,suspendPro,job,payment,const DeepCollectionEquality().hash(messages),customer,pro]);

@override
String toString() {
  return 'AdminComplaintDetail(id: $id, publicCode: $publicCode, jobId: $jobId, reason: $reason, description: $description, evidence: $evidence, status: $status, decision: $decision, decisionNote: $decisionNote, refundAmount: $refundAmount, proAmount: $proAmount, createdAt: $createdAt, decidedAt: $decidedAt, warnPro: $warnPro, suspendPro: $suspendPro, job: $job, payment: $payment, messages: $messages, customer: $customer, pro: $pro)';
}


}

/// @nodoc
abstract mixin class $AdminComplaintDetailCopyWith<$Res>  {
  factory $AdminComplaintDetailCopyWith(AdminComplaintDetail value, $Res Function(AdminComplaintDetail) _then) = _$AdminComplaintDetailCopyWithImpl;
@useResult
$Res call({
@JsonKey(fromJson: idFromJson) String id, String publicCode,@JsonKey(fromJson: idFromJson) String jobId, ComplaintReason reason, String description, List<MediaRef> evidence, ComplaintStatus status, String? decision, String? decisionNote,@NullableMoneyConverter() Money? refundAmount,@NullableMoneyConverter() Money? proAmount, DateTime createdAt, DateTime? decidedAt, bool warnPro, bool suspendPro, AdminComplaintJob job, AdminPaymentSummary? payment, List<AdminMessage> messages, AdminPartyCustomer customer, AdminPartyPro pro
});


$AdminComplaintJobCopyWith<$Res> get job;$AdminPaymentSummaryCopyWith<$Res>? get payment;$AdminPartyCustomerCopyWith<$Res> get customer;$AdminPartyProCopyWith<$Res> get pro;

}
/// @nodoc
class _$AdminComplaintDetailCopyWithImpl<$Res>
    implements $AdminComplaintDetailCopyWith<$Res> {
  _$AdminComplaintDetailCopyWithImpl(this._self, this._then);

  final AdminComplaintDetail _self;
  final $Res Function(AdminComplaintDetail) _then;

/// Create a copy of AdminComplaintDetail
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? publicCode = null,Object? jobId = null,Object? reason = null,Object? description = null,Object? evidence = null,Object? status = null,Object? decision = freezed,Object? decisionNote = freezed,Object? refundAmount = freezed,Object? proAmount = freezed,Object? createdAt = null,Object? decidedAt = freezed,Object? warnPro = null,Object? suspendPro = null,Object? job = null,Object? payment = freezed,Object? messages = null,Object? customer = null,Object? pro = null,}) {
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
as String?,refundAmount: freezed == refundAmount ? _self.refundAmount : refundAmount // ignore: cast_nullable_to_non_nullable
as Money?,proAmount: freezed == proAmount ? _self.proAmount : proAmount // ignore: cast_nullable_to_non_nullable
as Money?,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,decidedAt: freezed == decidedAt ? _self.decidedAt : decidedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,warnPro: null == warnPro ? _self.warnPro : warnPro // ignore: cast_nullable_to_non_nullable
as bool,suspendPro: null == suspendPro ? _self.suspendPro : suspendPro // ignore: cast_nullable_to_non_nullable
as bool,job: null == job ? _self.job : job // ignore: cast_nullable_to_non_nullable
as AdminComplaintJob,payment: freezed == payment ? _self.payment : payment // ignore: cast_nullable_to_non_nullable
as AdminPaymentSummary?,messages: null == messages ? _self.messages : messages // ignore: cast_nullable_to_non_nullable
as List<AdminMessage>,customer: null == customer ? _self.customer : customer // ignore: cast_nullable_to_non_nullable
as AdminPartyCustomer,pro: null == pro ? _self.pro : pro // ignore: cast_nullable_to_non_nullable
as AdminPartyPro,
  ));
}
/// Create a copy of AdminComplaintDetail
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$AdminComplaintJobCopyWith<$Res> get job {
  
  return $AdminComplaintJobCopyWith<$Res>(_self.job, (value) {
    return _then(_self.copyWith(job: value));
  });
}/// Create a copy of AdminComplaintDetail
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$AdminPaymentSummaryCopyWith<$Res>? get payment {
    if (_self.payment == null) {
    return null;
  }

  return $AdminPaymentSummaryCopyWith<$Res>(_self.payment!, (value) {
    return _then(_self.copyWith(payment: value));
  });
}/// Create a copy of AdminComplaintDetail
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$AdminPartyCustomerCopyWith<$Res> get customer {
  
  return $AdminPartyCustomerCopyWith<$Res>(_self.customer, (value) {
    return _then(_self.copyWith(customer: value));
  });
}/// Create a copy of AdminComplaintDetail
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$AdminPartyProCopyWith<$Res> get pro {
  
  return $AdminPartyProCopyWith<$Res>(_self.pro, (value) {
    return _then(_self.copyWith(pro: value));
  });
}
}


/// Adds pattern-matching-related methods to [AdminComplaintDetail].
extension AdminComplaintDetailPatterns on AdminComplaintDetail {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _AdminComplaintDetail value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _AdminComplaintDetail() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _AdminComplaintDetail value)  $default,){
final _that = this;
switch (_that) {
case _AdminComplaintDetail():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _AdminComplaintDetail value)?  $default,){
final _that = this;
switch (_that) {
case _AdminComplaintDetail() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function(@JsonKey(fromJson: idFromJson)  String id,  String publicCode, @JsonKey(fromJson: idFromJson)  String jobId,  ComplaintReason reason,  String description,  List<MediaRef> evidence,  ComplaintStatus status,  String? decision,  String? decisionNote, @NullableMoneyConverter()  Money? refundAmount, @NullableMoneyConverter()  Money? proAmount,  DateTime createdAt,  DateTime? decidedAt,  bool warnPro,  bool suspendPro,  AdminComplaintJob job,  AdminPaymentSummary? payment,  List<AdminMessage> messages,  AdminPartyCustomer customer,  AdminPartyPro pro)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _AdminComplaintDetail() when $default != null:
return $default(_that.id,_that.publicCode,_that.jobId,_that.reason,_that.description,_that.evidence,_that.status,_that.decision,_that.decisionNote,_that.refundAmount,_that.proAmount,_that.createdAt,_that.decidedAt,_that.warnPro,_that.suspendPro,_that.job,_that.payment,_that.messages,_that.customer,_that.pro);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function(@JsonKey(fromJson: idFromJson)  String id,  String publicCode, @JsonKey(fromJson: idFromJson)  String jobId,  ComplaintReason reason,  String description,  List<MediaRef> evidence,  ComplaintStatus status,  String? decision,  String? decisionNote, @NullableMoneyConverter()  Money? refundAmount, @NullableMoneyConverter()  Money? proAmount,  DateTime createdAt,  DateTime? decidedAt,  bool warnPro,  bool suspendPro,  AdminComplaintJob job,  AdminPaymentSummary? payment,  List<AdminMessage> messages,  AdminPartyCustomer customer,  AdminPartyPro pro)  $default,) {final _that = this;
switch (_that) {
case _AdminComplaintDetail():
return $default(_that.id,_that.publicCode,_that.jobId,_that.reason,_that.description,_that.evidence,_that.status,_that.decision,_that.decisionNote,_that.refundAmount,_that.proAmount,_that.createdAt,_that.decidedAt,_that.warnPro,_that.suspendPro,_that.job,_that.payment,_that.messages,_that.customer,_that.pro);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function(@JsonKey(fromJson: idFromJson)  String id,  String publicCode, @JsonKey(fromJson: idFromJson)  String jobId,  ComplaintReason reason,  String description,  List<MediaRef> evidence,  ComplaintStatus status,  String? decision,  String? decisionNote, @NullableMoneyConverter()  Money? refundAmount, @NullableMoneyConverter()  Money? proAmount,  DateTime createdAt,  DateTime? decidedAt,  bool warnPro,  bool suspendPro,  AdminComplaintJob job,  AdminPaymentSummary? payment,  List<AdminMessage> messages,  AdminPartyCustomer customer,  AdminPartyPro pro)?  $default,) {final _that = this;
switch (_that) {
case _AdminComplaintDetail() when $default != null:
return $default(_that.id,_that.publicCode,_that.jobId,_that.reason,_that.description,_that.evidence,_that.status,_that.decision,_that.decisionNote,_that.refundAmount,_that.proAmount,_that.createdAt,_that.decidedAt,_that.warnPro,_that.suspendPro,_that.job,_that.payment,_that.messages,_that.customer,_that.pro);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _AdminComplaintDetail implements AdminComplaintDetail {
  const _AdminComplaintDetail({@JsonKey(fromJson: idFromJson) required this.id, required this.publicCode, @JsonKey(fromJson: idFromJson) required this.jobId, required this.reason, required this.description, this.evidence = const <MediaRef>[], required this.status, this.decision, this.decisionNote, @NullableMoneyConverter() this.refundAmount, @NullableMoneyConverter() this.proAmount, required this.createdAt, this.decidedAt, this.warnPro = false, this.suspendPro = false, required this.job, this.payment, this.messages = const <AdminMessage>[], required this.customer, required this.pro});
  factory _AdminComplaintDetail.fromJson(Map<String, dynamic> json) => _$AdminComplaintDetailFromJson(json);

@override@JsonKey(fromJson: idFromJson) final  String id;
@override final  String publicCode;
@override@JsonKey(fromJson: idFromJson) final  String jobId;
@override final  ComplaintReason reason;
@override final  String description;
@override@JsonKey() final  List<MediaRef> evidence;
@override final  ComplaintStatus status;
@override final  String? decision;
@override final  String? decisionNote;
@override@NullableMoneyConverter() final  Money? refundAmount;
@override@NullableMoneyConverter() final  Money? proAmount;
@override final  DateTime createdAt;
@override final  DateTime? decidedAt;
/// Karar bayrakları (karar verilmeden önce `false`).
@override@JsonKey() final  bool warnPro;
@override@JsonKey() final  bool suspendPro;
@override final  AdminComplaintJob job;
/// Sunucu emanet kaydı yoksa `null` döner.
@override final  AdminPaymentSummary? payment;
@override@JsonKey() final  List<AdminMessage> messages;
@override final  AdminPartyCustomer customer;
@override final  AdminPartyPro pro;

/// Create a copy of AdminComplaintDetail
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$AdminComplaintDetailCopyWith<_AdminComplaintDetail> get copyWith => __$AdminComplaintDetailCopyWithImpl<_AdminComplaintDetail>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$AdminComplaintDetailToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _AdminComplaintDetail&&(identical(other.id, id) || other.id == id)&&(identical(other.publicCode, publicCode) || other.publicCode == publicCode)&&(identical(other.jobId, jobId) || other.jobId == jobId)&&(identical(other.reason, reason) || other.reason == reason)&&(identical(other.description, description) || other.description == description)&&const DeepCollectionEquality().equals(other.evidence, evidence)&&(identical(other.status, status) || other.status == status)&&(identical(other.decision, decision) || other.decision == decision)&&(identical(other.decisionNote, decisionNote) || other.decisionNote == decisionNote)&&(identical(other.refundAmount, refundAmount) || other.refundAmount == refundAmount)&&(identical(other.proAmount, proAmount) || other.proAmount == proAmount)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.decidedAt, decidedAt) || other.decidedAt == decidedAt)&&(identical(other.warnPro, warnPro) || other.warnPro == warnPro)&&(identical(other.suspendPro, suspendPro) || other.suspendPro == suspendPro)&&(identical(other.job, job) || other.job == job)&&(identical(other.payment, payment) || other.payment == payment)&&const DeepCollectionEquality().equals(other.messages, messages)&&(identical(other.customer, customer) || other.customer == customer)&&(identical(other.pro, pro) || other.pro == pro));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hashAll([runtimeType,id,publicCode,jobId,reason,description,const DeepCollectionEquality().hash(evidence),status,decision,decisionNote,refundAmount,proAmount,createdAt,decidedAt,warnPro,suspendPro,job,payment,const DeepCollectionEquality().hash(messages),customer,pro]);

@override
String toString() {
  return 'AdminComplaintDetail(id: $id, publicCode: $publicCode, jobId: $jobId, reason: $reason, description: $description, evidence: $evidence, status: $status, decision: $decision, decisionNote: $decisionNote, refundAmount: $refundAmount, proAmount: $proAmount, createdAt: $createdAt, decidedAt: $decidedAt, warnPro: $warnPro, suspendPro: $suspendPro, job: $job, payment: $payment, messages: $messages, customer: $customer, pro: $pro)';
}


}

/// @nodoc
abstract mixin class _$AdminComplaintDetailCopyWith<$Res> implements $AdminComplaintDetailCopyWith<$Res> {
  factory _$AdminComplaintDetailCopyWith(_AdminComplaintDetail value, $Res Function(_AdminComplaintDetail) _then) = __$AdminComplaintDetailCopyWithImpl;
@override @useResult
$Res call({
@JsonKey(fromJson: idFromJson) String id, String publicCode,@JsonKey(fromJson: idFromJson) String jobId, ComplaintReason reason, String description, List<MediaRef> evidence, ComplaintStatus status, String? decision, String? decisionNote,@NullableMoneyConverter() Money? refundAmount,@NullableMoneyConverter() Money? proAmount, DateTime createdAt, DateTime? decidedAt, bool warnPro, bool suspendPro, AdminComplaintJob job, AdminPaymentSummary? payment, List<AdminMessage> messages, AdminPartyCustomer customer, AdminPartyPro pro
});


@override $AdminComplaintJobCopyWith<$Res> get job;@override $AdminPaymentSummaryCopyWith<$Res>? get payment;@override $AdminPartyCustomerCopyWith<$Res> get customer;@override $AdminPartyProCopyWith<$Res> get pro;

}
/// @nodoc
class __$AdminComplaintDetailCopyWithImpl<$Res>
    implements _$AdminComplaintDetailCopyWith<$Res> {
  __$AdminComplaintDetailCopyWithImpl(this._self, this._then);

  final _AdminComplaintDetail _self;
  final $Res Function(_AdminComplaintDetail) _then;

/// Create a copy of AdminComplaintDetail
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? publicCode = null,Object? jobId = null,Object? reason = null,Object? description = null,Object? evidence = null,Object? status = null,Object? decision = freezed,Object? decisionNote = freezed,Object? refundAmount = freezed,Object? proAmount = freezed,Object? createdAt = null,Object? decidedAt = freezed,Object? warnPro = null,Object? suspendPro = null,Object? job = null,Object? payment = freezed,Object? messages = null,Object? customer = null,Object? pro = null,}) {
  return _then(_AdminComplaintDetail(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,publicCode: null == publicCode ? _self.publicCode : publicCode // ignore: cast_nullable_to_non_nullable
as String,jobId: null == jobId ? _self.jobId : jobId // ignore: cast_nullable_to_non_nullable
as String,reason: null == reason ? _self.reason : reason // ignore: cast_nullable_to_non_nullable
as ComplaintReason,description: null == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String,evidence: null == evidence ? _self.evidence : evidence // ignore: cast_nullable_to_non_nullable
as List<MediaRef>,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as ComplaintStatus,decision: freezed == decision ? _self.decision : decision // ignore: cast_nullable_to_non_nullable
as String?,decisionNote: freezed == decisionNote ? _self.decisionNote : decisionNote // ignore: cast_nullable_to_non_nullable
as String?,refundAmount: freezed == refundAmount ? _self.refundAmount : refundAmount // ignore: cast_nullable_to_non_nullable
as Money?,proAmount: freezed == proAmount ? _self.proAmount : proAmount // ignore: cast_nullable_to_non_nullable
as Money?,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,decidedAt: freezed == decidedAt ? _self.decidedAt : decidedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,warnPro: null == warnPro ? _self.warnPro : warnPro // ignore: cast_nullable_to_non_nullable
as bool,suspendPro: null == suspendPro ? _self.suspendPro : suspendPro // ignore: cast_nullable_to_non_nullable
as bool,job: null == job ? _self.job : job // ignore: cast_nullable_to_non_nullable
as AdminComplaintJob,payment: freezed == payment ? _self.payment : payment // ignore: cast_nullable_to_non_nullable
as AdminPaymentSummary?,messages: null == messages ? _self.messages : messages // ignore: cast_nullable_to_non_nullable
as List<AdminMessage>,customer: null == customer ? _self.customer : customer // ignore: cast_nullable_to_non_nullable
as AdminPartyCustomer,pro: null == pro ? _self.pro : pro // ignore: cast_nullable_to_non_nullable
as AdminPartyPro,
  ));
}

/// Create a copy of AdminComplaintDetail
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$AdminComplaintJobCopyWith<$Res> get job {
  
  return $AdminComplaintJobCopyWith<$Res>(_self.job, (value) {
    return _then(_self.copyWith(job: value));
  });
}/// Create a copy of AdminComplaintDetail
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$AdminPaymentSummaryCopyWith<$Res>? get payment {
    if (_self.payment == null) {
    return null;
  }

  return $AdminPaymentSummaryCopyWith<$Res>(_self.payment!, (value) {
    return _then(_self.copyWith(payment: value));
  });
}/// Create a copy of AdminComplaintDetail
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$AdminPartyCustomerCopyWith<$Res> get customer {
  
  return $AdminPartyCustomerCopyWith<$Res>(_self.customer, (value) {
    return _then(_self.copyWith(customer: value));
  });
}/// Create a copy of AdminComplaintDetail
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$AdminPartyProCopyWith<$Res> get pro {
  
  return $AdminPartyProCopyWith<$Res>(_self.pro, (value) {
    return _then(_self.copyWith(pro: value));
  });
}
}


/// @nodoc
mixin _$ComplaintDecisionRequest {

 ComplaintDecision get decision; String get note; bool get warnPro; bool get suspendPro;
/// Create a copy of ComplaintDecisionRequest
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ComplaintDecisionRequestCopyWith<ComplaintDecisionRequest> get copyWith => _$ComplaintDecisionRequestCopyWithImpl<ComplaintDecisionRequest>(this as ComplaintDecisionRequest, _$identity);

  /// Serializes this ComplaintDecisionRequest to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ComplaintDecisionRequest&&(identical(other.decision, decision) || other.decision == decision)&&(identical(other.note, note) || other.note == note)&&(identical(other.warnPro, warnPro) || other.warnPro == warnPro)&&(identical(other.suspendPro, suspendPro) || other.suspendPro == suspendPro));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,decision,note,warnPro,suspendPro);

@override
String toString() {
  return 'ComplaintDecisionRequest(decision: $decision, note: $note, warnPro: $warnPro, suspendPro: $suspendPro)';
}


}

/// @nodoc
abstract mixin class $ComplaintDecisionRequestCopyWith<$Res>  {
  factory $ComplaintDecisionRequestCopyWith(ComplaintDecisionRequest value, $Res Function(ComplaintDecisionRequest) _then) = _$ComplaintDecisionRequestCopyWithImpl;
@useResult
$Res call({
 ComplaintDecision decision, String note, bool warnPro, bool suspendPro
});




}
/// @nodoc
class _$ComplaintDecisionRequestCopyWithImpl<$Res>
    implements $ComplaintDecisionRequestCopyWith<$Res> {
  _$ComplaintDecisionRequestCopyWithImpl(this._self, this._then);

  final ComplaintDecisionRequest _self;
  final $Res Function(ComplaintDecisionRequest) _then;

/// Create a copy of ComplaintDecisionRequest
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? decision = null,Object? note = null,Object? warnPro = null,Object? suspendPro = null,}) {
  return _then(_self.copyWith(
decision: null == decision ? _self.decision : decision // ignore: cast_nullable_to_non_nullable
as ComplaintDecision,note: null == note ? _self.note : note // ignore: cast_nullable_to_non_nullable
as String,warnPro: null == warnPro ? _self.warnPro : warnPro // ignore: cast_nullable_to_non_nullable
as bool,suspendPro: null == suspendPro ? _self.suspendPro : suspendPro // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}

}


/// Adds pattern-matching-related methods to [ComplaintDecisionRequest].
extension ComplaintDecisionRequestPatterns on ComplaintDecisionRequest {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ComplaintDecisionRequest value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ComplaintDecisionRequest() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ComplaintDecisionRequest value)  $default,){
final _that = this;
switch (_that) {
case _ComplaintDecisionRequest():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ComplaintDecisionRequest value)?  $default,){
final _that = this;
switch (_that) {
case _ComplaintDecisionRequest() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( ComplaintDecision decision,  String note,  bool warnPro,  bool suspendPro)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ComplaintDecisionRequest() when $default != null:
return $default(_that.decision,_that.note,_that.warnPro,_that.suspendPro);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( ComplaintDecision decision,  String note,  bool warnPro,  bool suspendPro)  $default,) {final _that = this;
switch (_that) {
case _ComplaintDecisionRequest():
return $default(_that.decision,_that.note,_that.warnPro,_that.suspendPro);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( ComplaintDecision decision,  String note,  bool warnPro,  bool suspendPro)?  $default,) {final _that = this;
switch (_that) {
case _ComplaintDecisionRequest() when $default != null:
return $default(_that.decision,_that.note,_that.warnPro,_that.suspendPro);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _ComplaintDecisionRequest implements ComplaintDecisionRequest {
  const _ComplaintDecisionRequest({required this.decision, required this.note, this.warnPro = false, this.suspendPro = false});
  factory _ComplaintDecisionRequest.fromJson(Map<String, dynamic> json) => _$ComplaintDecisionRequestFromJson(json);

@override final  ComplaintDecision decision;
@override final  String note;
@override@JsonKey() final  bool warnPro;
@override@JsonKey() final  bool suspendPro;

/// Create a copy of ComplaintDecisionRequest
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ComplaintDecisionRequestCopyWith<_ComplaintDecisionRequest> get copyWith => __$ComplaintDecisionRequestCopyWithImpl<_ComplaintDecisionRequest>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ComplaintDecisionRequestToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ComplaintDecisionRequest&&(identical(other.decision, decision) || other.decision == decision)&&(identical(other.note, note) || other.note == note)&&(identical(other.warnPro, warnPro) || other.warnPro == warnPro)&&(identical(other.suspendPro, suspendPro) || other.suspendPro == suspendPro));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,decision,note,warnPro,suspendPro);

@override
String toString() {
  return 'ComplaintDecisionRequest(decision: $decision, note: $note, warnPro: $warnPro, suspendPro: $suspendPro)';
}


}

/// @nodoc
abstract mixin class _$ComplaintDecisionRequestCopyWith<$Res> implements $ComplaintDecisionRequestCopyWith<$Res> {
  factory _$ComplaintDecisionRequestCopyWith(_ComplaintDecisionRequest value, $Res Function(_ComplaintDecisionRequest) _then) = __$ComplaintDecisionRequestCopyWithImpl;
@override @useResult
$Res call({
 ComplaintDecision decision, String note, bool warnPro, bool suspendPro
});




}
/// @nodoc
class __$ComplaintDecisionRequestCopyWithImpl<$Res>
    implements _$ComplaintDecisionRequestCopyWith<$Res> {
  __$ComplaintDecisionRequestCopyWithImpl(this._self, this._then);

  final _ComplaintDecisionRequest _self;
  final $Res Function(_ComplaintDecisionRequest) _then;

/// Create a copy of ComplaintDecisionRequest
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? decision = null,Object? note = null,Object? warnPro = null,Object? suspendPro = null,}) {
  return _then(_ComplaintDecisionRequest(
decision: null == decision ? _self.decision : decision // ignore: cast_nullable_to_non_nullable
as ComplaintDecision,note: null == note ? _self.note : note // ignore: cast_nullable_to_non_nullable
as String,warnPro: null == warnPro ? _self.warnPro : warnPro // ignore: cast_nullable_to_non_nullable
as bool,suspendPro: null == suspendPro ? _self.suspendPro : suspendPro // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}


}


/// @nodoc
mixin _$AdminUserPro {

 String get businessName; ReviewStatus get reviewStatus;
/// Create a copy of AdminUserPro
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$AdminUserProCopyWith<AdminUserPro> get copyWith => _$AdminUserProCopyWithImpl<AdminUserPro>(this as AdminUserPro, _$identity);

  /// Serializes this AdminUserPro to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is AdminUserPro&&(identical(other.businessName, businessName) || other.businessName == businessName)&&(identical(other.reviewStatus, reviewStatus) || other.reviewStatus == reviewStatus));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,businessName,reviewStatus);

@override
String toString() {
  return 'AdminUserPro(businessName: $businessName, reviewStatus: $reviewStatus)';
}


}

/// @nodoc
abstract mixin class $AdminUserProCopyWith<$Res>  {
  factory $AdminUserProCopyWith(AdminUserPro value, $Res Function(AdminUserPro) _then) = _$AdminUserProCopyWithImpl;
@useResult
$Res call({
 String businessName, ReviewStatus reviewStatus
});




}
/// @nodoc
class _$AdminUserProCopyWithImpl<$Res>
    implements $AdminUserProCopyWith<$Res> {
  _$AdminUserProCopyWithImpl(this._self, this._then);

  final AdminUserPro _self;
  final $Res Function(AdminUserPro) _then;

/// Create a copy of AdminUserPro
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? businessName = null,Object? reviewStatus = null,}) {
  return _then(_self.copyWith(
businessName: null == businessName ? _self.businessName : businessName // ignore: cast_nullable_to_non_nullable
as String,reviewStatus: null == reviewStatus ? _self.reviewStatus : reviewStatus // ignore: cast_nullable_to_non_nullable
as ReviewStatus,
  ));
}

}


/// Adds pattern-matching-related methods to [AdminUserPro].
extension AdminUserProPatterns on AdminUserPro {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _AdminUserPro value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _AdminUserPro() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _AdminUserPro value)  $default,){
final _that = this;
switch (_that) {
case _AdminUserPro():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _AdminUserPro value)?  $default,){
final _that = this;
switch (_that) {
case _AdminUserPro() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String businessName,  ReviewStatus reviewStatus)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _AdminUserPro() when $default != null:
return $default(_that.businessName,_that.reviewStatus);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String businessName,  ReviewStatus reviewStatus)  $default,) {final _that = this;
switch (_that) {
case _AdminUserPro():
return $default(_that.businessName,_that.reviewStatus);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String businessName,  ReviewStatus reviewStatus)?  $default,) {final _that = this;
switch (_that) {
case _AdminUserPro() when $default != null:
return $default(_that.businessName,_that.reviewStatus);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _AdminUserPro implements AdminUserPro {
  const _AdminUserPro({required this.businessName, required this.reviewStatus});
  factory _AdminUserPro.fromJson(Map<String, dynamic> json) => _$AdminUserProFromJson(json);

@override final  String businessName;
@override final  ReviewStatus reviewStatus;

/// Create a copy of AdminUserPro
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$AdminUserProCopyWith<_AdminUserPro> get copyWith => __$AdminUserProCopyWithImpl<_AdminUserPro>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$AdminUserProToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _AdminUserPro&&(identical(other.businessName, businessName) || other.businessName == businessName)&&(identical(other.reviewStatus, reviewStatus) || other.reviewStatus == reviewStatus));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,businessName,reviewStatus);

@override
String toString() {
  return 'AdminUserPro(businessName: $businessName, reviewStatus: $reviewStatus)';
}


}

/// @nodoc
abstract mixin class _$AdminUserProCopyWith<$Res> implements $AdminUserProCopyWith<$Res> {
  factory _$AdminUserProCopyWith(_AdminUserPro value, $Res Function(_AdminUserPro) _then) = __$AdminUserProCopyWithImpl;
@override @useResult
$Res call({
 String businessName, ReviewStatus reviewStatus
});




}
/// @nodoc
class __$AdminUserProCopyWithImpl<$Res>
    implements _$AdminUserProCopyWith<$Res> {
  __$AdminUserProCopyWithImpl(this._self, this._then);

  final _AdminUserPro _self;
  final $Res Function(_AdminUserPro) _then;

/// Create a copy of AdminUserPro
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? businessName = null,Object? reviewStatus = null,}) {
  return _then(_AdminUserPro(
businessName: null == businessName ? _self.businessName : businessName // ignore: cast_nullable_to_non_nullable
as String,reviewStatus: null == reviewStatus ? _self.reviewStatus : reviewStatus // ignore: cast_nullable_to_non_nullable
as ReviewStatus,
  ));
}


}


/// @nodoc
mixin _$AdminUser {

@JsonKey(fromJson: idFromJson) String get id; String get fullName; String get email; String? get phone; bool get isAdmin; AccountStatus get status; DateTime get createdAt; AdminUserPro? get pro;
/// Create a copy of AdminUser
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$AdminUserCopyWith<AdminUser> get copyWith => _$AdminUserCopyWithImpl<AdminUser>(this as AdminUser, _$identity);

  /// Serializes this AdminUser to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is AdminUser&&(identical(other.id, id) || other.id == id)&&(identical(other.fullName, fullName) || other.fullName == fullName)&&(identical(other.email, email) || other.email == email)&&(identical(other.phone, phone) || other.phone == phone)&&(identical(other.isAdmin, isAdmin) || other.isAdmin == isAdmin)&&(identical(other.status, status) || other.status == status)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.pro, pro) || other.pro == pro));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,fullName,email,phone,isAdmin,status,createdAt,pro);

@override
String toString() {
  return 'AdminUser(id: $id, fullName: $fullName, email: $email, phone: $phone, isAdmin: $isAdmin, status: $status, createdAt: $createdAt, pro: $pro)';
}


}

/// @nodoc
abstract mixin class $AdminUserCopyWith<$Res>  {
  factory $AdminUserCopyWith(AdminUser value, $Res Function(AdminUser) _then) = _$AdminUserCopyWithImpl;
@useResult
$Res call({
@JsonKey(fromJson: idFromJson) String id, String fullName, String email, String? phone, bool isAdmin, AccountStatus status, DateTime createdAt, AdminUserPro? pro
});


$AdminUserProCopyWith<$Res>? get pro;

}
/// @nodoc
class _$AdminUserCopyWithImpl<$Res>
    implements $AdminUserCopyWith<$Res> {
  _$AdminUserCopyWithImpl(this._self, this._then);

  final AdminUser _self;
  final $Res Function(AdminUser) _then;

/// Create a copy of AdminUser
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? fullName = null,Object? email = null,Object? phone = freezed,Object? isAdmin = null,Object? status = null,Object? createdAt = null,Object? pro = freezed,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,fullName: null == fullName ? _self.fullName : fullName // ignore: cast_nullable_to_non_nullable
as String,email: null == email ? _self.email : email // ignore: cast_nullable_to_non_nullable
as String,phone: freezed == phone ? _self.phone : phone // ignore: cast_nullable_to_non_nullable
as String?,isAdmin: null == isAdmin ? _self.isAdmin : isAdmin // ignore: cast_nullable_to_non_nullable
as bool,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as AccountStatus,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,pro: freezed == pro ? _self.pro : pro // ignore: cast_nullable_to_non_nullable
as AdminUserPro?,
  ));
}
/// Create a copy of AdminUser
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$AdminUserProCopyWith<$Res>? get pro {
    if (_self.pro == null) {
    return null;
  }

  return $AdminUserProCopyWith<$Res>(_self.pro!, (value) {
    return _then(_self.copyWith(pro: value));
  });
}
}


/// Adds pattern-matching-related methods to [AdminUser].
extension AdminUserPatterns on AdminUser {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _AdminUser value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _AdminUser() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _AdminUser value)  $default,){
final _that = this;
switch (_that) {
case _AdminUser():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _AdminUser value)?  $default,){
final _that = this;
switch (_that) {
case _AdminUser() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function(@JsonKey(fromJson: idFromJson)  String id,  String fullName,  String email,  String? phone,  bool isAdmin,  AccountStatus status,  DateTime createdAt,  AdminUserPro? pro)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _AdminUser() when $default != null:
return $default(_that.id,_that.fullName,_that.email,_that.phone,_that.isAdmin,_that.status,_that.createdAt,_that.pro);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function(@JsonKey(fromJson: idFromJson)  String id,  String fullName,  String email,  String? phone,  bool isAdmin,  AccountStatus status,  DateTime createdAt,  AdminUserPro? pro)  $default,) {final _that = this;
switch (_that) {
case _AdminUser():
return $default(_that.id,_that.fullName,_that.email,_that.phone,_that.isAdmin,_that.status,_that.createdAt,_that.pro);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function(@JsonKey(fromJson: idFromJson)  String id,  String fullName,  String email,  String? phone,  bool isAdmin,  AccountStatus status,  DateTime createdAt,  AdminUserPro? pro)?  $default,) {final _that = this;
switch (_that) {
case _AdminUser() when $default != null:
return $default(_that.id,_that.fullName,_that.email,_that.phone,_that.isAdmin,_that.status,_that.createdAt,_that.pro);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _AdminUser implements AdminUser {
  const _AdminUser({@JsonKey(fromJson: idFromJson) required this.id, required this.fullName, required this.email, this.phone, this.isAdmin = false, required this.status, required this.createdAt, this.pro});
  factory _AdminUser.fromJson(Map<String, dynamic> json) => _$AdminUserFromJson(json);

@override@JsonKey(fromJson: idFromJson) final  String id;
@override final  String fullName;
@override final  String email;
@override final  String? phone;
@override@JsonKey() final  bool isAdmin;
@override final  AccountStatus status;
@override final  DateTime createdAt;
@override final  AdminUserPro? pro;

/// Create a copy of AdminUser
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$AdminUserCopyWith<_AdminUser> get copyWith => __$AdminUserCopyWithImpl<_AdminUser>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$AdminUserToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _AdminUser&&(identical(other.id, id) || other.id == id)&&(identical(other.fullName, fullName) || other.fullName == fullName)&&(identical(other.email, email) || other.email == email)&&(identical(other.phone, phone) || other.phone == phone)&&(identical(other.isAdmin, isAdmin) || other.isAdmin == isAdmin)&&(identical(other.status, status) || other.status == status)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.pro, pro) || other.pro == pro));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,fullName,email,phone,isAdmin,status,createdAt,pro);

@override
String toString() {
  return 'AdminUser(id: $id, fullName: $fullName, email: $email, phone: $phone, isAdmin: $isAdmin, status: $status, createdAt: $createdAt, pro: $pro)';
}


}

/// @nodoc
abstract mixin class _$AdminUserCopyWith<$Res> implements $AdminUserCopyWith<$Res> {
  factory _$AdminUserCopyWith(_AdminUser value, $Res Function(_AdminUser) _then) = __$AdminUserCopyWithImpl;
@override @useResult
$Res call({
@JsonKey(fromJson: idFromJson) String id, String fullName, String email, String? phone, bool isAdmin, AccountStatus status, DateTime createdAt, AdminUserPro? pro
});


@override $AdminUserProCopyWith<$Res>? get pro;

}
/// @nodoc
class __$AdminUserCopyWithImpl<$Res>
    implements _$AdminUserCopyWith<$Res> {
  __$AdminUserCopyWithImpl(this._self, this._then);

  final _AdminUser _self;
  final $Res Function(_AdminUser) _then;

/// Create a copy of AdminUser
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? fullName = null,Object? email = null,Object? phone = freezed,Object? isAdmin = null,Object? status = null,Object? createdAt = null,Object? pro = freezed,}) {
  return _then(_AdminUser(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,fullName: null == fullName ? _self.fullName : fullName // ignore: cast_nullable_to_non_nullable
as String,email: null == email ? _self.email : email // ignore: cast_nullable_to_non_nullable
as String,phone: freezed == phone ? _self.phone : phone // ignore: cast_nullable_to_non_nullable
as String?,isAdmin: null == isAdmin ? _self.isAdmin : isAdmin // ignore: cast_nullable_to_non_nullable
as bool,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as AccountStatus,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,pro: freezed == pro ? _self.pro : pro // ignore: cast_nullable_to_non_nullable
as AdminUserPro?,
  ));
}

/// Create a copy of AdminUser
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$AdminUserProCopyWith<$Res>? get pro {
    if (_self.pro == null) {
    return null;
  }

  return $AdminUserProCopyWith<$Res>(_self.pro!, (value) {
    return _then(_self.copyWith(pro: value));
  });
}
}


/// @nodoc
mixin _$AdminPaymentRow {

 String get ref; String? get jobPublicCode; String get status; String get provider;@MoneyConverter() Money get totalAmount;@MoneyConverter() Money get commission;@MoneyConverter() Money get proPayout;@MoneyConverter() Money get refundedAmount; String? get customerName; String? get proBusinessName; DateTime get createdAt; DateTime? get lockedAt; DateTime? get releasedAt; DateTime? get refundedAt; String? get errorCode;
/// Create a copy of AdminPaymentRow
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$AdminPaymentRowCopyWith<AdminPaymentRow> get copyWith => _$AdminPaymentRowCopyWithImpl<AdminPaymentRow>(this as AdminPaymentRow, _$identity);

  /// Serializes this AdminPaymentRow to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is AdminPaymentRow&&(identical(other.ref, ref) || other.ref == ref)&&(identical(other.jobPublicCode, jobPublicCode) || other.jobPublicCode == jobPublicCode)&&(identical(other.status, status) || other.status == status)&&(identical(other.provider, provider) || other.provider == provider)&&(identical(other.totalAmount, totalAmount) || other.totalAmount == totalAmount)&&(identical(other.commission, commission) || other.commission == commission)&&(identical(other.proPayout, proPayout) || other.proPayout == proPayout)&&(identical(other.refundedAmount, refundedAmount) || other.refundedAmount == refundedAmount)&&(identical(other.customerName, customerName) || other.customerName == customerName)&&(identical(other.proBusinessName, proBusinessName) || other.proBusinessName == proBusinessName)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.lockedAt, lockedAt) || other.lockedAt == lockedAt)&&(identical(other.releasedAt, releasedAt) || other.releasedAt == releasedAt)&&(identical(other.refundedAt, refundedAt) || other.refundedAt == refundedAt)&&(identical(other.errorCode, errorCode) || other.errorCode == errorCode));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,ref,jobPublicCode,status,provider,totalAmount,commission,proPayout,refundedAmount,customerName,proBusinessName,createdAt,lockedAt,releasedAt,refundedAt,errorCode);

@override
String toString() {
  return 'AdminPaymentRow(ref: $ref, jobPublicCode: $jobPublicCode, status: $status, provider: $provider, totalAmount: $totalAmount, commission: $commission, proPayout: $proPayout, refundedAmount: $refundedAmount, customerName: $customerName, proBusinessName: $proBusinessName, createdAt: $createdAt, lockedAt: $lockedAt, releasedAt: $releasedAt, refundedAt: $refundedAt, errorCode: $errorCode)';
}


}

/// @nodoc
abstract mixin class $AdminPaymentRowCopyWith<$Res>  {
  factory $AdminPaymentRowCopyWith(AdminPaymentRow value, $Res Function(AdminPaymentRow) _then) = _$AdminPaymentRowCopyWithImpl;
@useResult
$Res call({
 String ref, String? jobPublicCode, String status, String provider,@MoneyConverter() Money totalAmount,@MoneyConverter() Money commission,@MoneyConverter() Money proPayout,@MoneyConverter() Money refundedAmount, String? customerName, String? proBusinessName, DateTime createdAt, DateTime? lockedAt, DateTime? releasedAt, DateTime? refundedAt, String? errorCode
});




}
/// @nodoc
class _$AdminPaymentRowCopyWithImpl<$Res>
    implements $AdminPaymentRowCopyWith<$Res> {
  _$AdminPaymentRowCopyWithImpl(this._self, this._then);

  final AdminPaymentRow _self;
  final $Res Function(AdminPaymentRow) _then;

/// Create a copy of AdminPaymentRow
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? ref = null,Object? jobPublicCode = freezed,Object? status = null,Object? provider = null,Object? totalAmount = null,Object? commission = null,Object? proPayout = null,Object? refundedAmount = null,Object? customerName = freezed,Object? proBusinessName = freezed,Object? createdAt = null,Object? lockedAt = freezed,Object? releasedAt = freezed,Object? refundedAt = freezed,Object? errorCode = freezed,}) {
  return _then(_self.copyWith(
ref: null == ref ? _self.ref : ref // ignore: cast_nullable_to_non_nullable
as String,jobPublicCode: freezed == jobPublicCode ? _self.jobPublicCode : jobPublicCode // ignore: cast_nullable_to_non_nullable
as String?,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as String,provider: null == provider ? _self.provider : provider // ignore: cast_nullable_to_non_nullable
as String,totalAmount: null == totalAmount ? _self.totalAmount : totalAmount // ignore: cast_nullable_to_non_nullable
as Money,commission: null == commission ? _self.commission : commission // ignore: cast_nullable_to_non_nullable
as Money,proPayout: null == proPayout ? _self.proPayout : proPayout // ignore: cast_nullable_to_non_nullable
as Money,refundedAmount: null == refundedAmount ? _self.refundedAmount : refundedAmount // ignore: cast_nullable_to_non_nullable
as Money,customerName: freezed == customerName ? _self.customerName : customerName // ignore: cast_nullable_to_non_nullable
as String?,proBusinessName: freezed == proBusinessName ? _self.proBusinessName : proBusinessName // ignore: cast_nullable_to_non_nullable
as String?,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,lockedAt: freezed == lockedAt ? _self.lockedAt : lockedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,releasedAt: freezed == releasedAt ? _self.releasedAt : releasedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,refundedAt: freezed == refundedAt ? _self.refundedAt : refundedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,errorCode: freezed == errorCode ? _self.errorCode : errorCode // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [AdminPaymentRow].
extension AdminPaymentRowPatterns on AdminPaymentRow {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _AdminPaymentRow value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _AdminPaymentRow() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _AdminPaymentRow value)  $default,){
final _that = this;
switch (_that) {
case _AdminPaymentRow():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _AdminPaymentRow value)?  $default,){
final _that = this;
switch (_that) {
case _AdminPaymentRow() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String ref,  String? jobPublicCode,  String status,  String provider, @MoneyConverter()  Money totalAmount, @MoneyConverter()  Money commission, @MoneyConverter()  Money proPayout, @MoneyConverter()  Money refundedAmount,  String? customerName,  String? proBusinessName,  DateTime createdAt,  DateTime? lockedAt,  DateTime? releasedAt,  DateTime? refundedAt,  String? errorCode)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _AdminPaymentRow() when $default != null:
return $default(_that.ref,_that.jobPublicCode,_that.status,_that.provider,_that.totalAmount,_that.commission,_that.proPayout,_that.refundedAmount,_that.customerName,_that.proBusinessName,_that.createdAt,_that.lockedAt,_that.releasedAt,_that.refundedAt,_that.errorCode);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String ref,  String? jobPublicCode,  String status,  String provider, @MoneyConverter()  Money totalAmount, @MoneyConverter()  Money commission, @MoneyConverter()  Money proPayout, @MoneyConverter()  Money refundedAmount,  String? customerName,  String? proBusinessName,  DateTime createdAt,  DateTime? lockedAt,  DateTime? releasedAt,  DateTime? refundedAt,  String? errorCode)  $default,) {final _that = this;
switch (_that) {
case _AdminPaymentRow():
return $default(_that.ref,_that.jobPublicCode,_that.status,_that.provider,_that.totalAmount,_that.commission,_that.proPayout,_that.refundedAmount,_that.customerName,_that.proBusinessName,_that.createdAt,_that.lockedAt,_that.releasedAt,_that.refundedAt,_that.errorCode);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String ref,  String? jobPublicCode,  String status,  String provider, @MoneyConverter()  Money totalAmount, @MoneyConverter()  Money commission, @MoneyConverter()  Money proPayout, @MoneyConverter()  Money refundedAmount,  String? customerName,  String? proBusinessName,  DateTime createdAt,  DateTime? lockedAt,  DateTime? releasedAt,  DateTime? refundedAt,  String? errorCode)?  $default,) {final _that = this;
switch (_that) {
case _AdminPaymentRow() when $default != null:
return $default(_that.ref,_that.jobPublicCode,_that.status,_that.provider,_that.totalAmount,_that.commission,_that.proPayout,_that.refundedAmount,_that.customerName,_that.proBusinessName,_that.createdAt,_that.lockedAt,_that.releasedAt,_that.refundedAt,_that.errorCode);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _AdminPaymentRow implements AdminPaymentRow {
  const _AdminPaymentRow({required this.ref, this.jobPublicCode, required this.status, required this.provider, @MoneyConverter() required this.totalAmount, @MoneyConverter() this.commission = Money.zero, @MoneyConverter() this.proPayout = Money.zero, @MoneyConverter() this.refundedAmount = Money.zero, this.customerName, this.proBusinessName, required this.createdAt, this.lockedAt, this.releasedAt, this.refundedAt, this.errorCode});
  factory _AdminPaymentRow.fromJson(Map<String, dynamic> json) => _$AdminPaymentRowFromJson(json);

@override final  String ref;
@override final  String? jobPublicCode;
@override final  String status;
@override final  String provider;
@override@MoneyConverter() final  Money totalAmount;
@override@JsonKey()@MoneyConverter() final  Money commission;
@override@JsonKey()@MoneyConverter() final  Money proPayout;
@override@JsonKey()@MoneyConverter() final  Money refundedAmount;
@override final  String? customerName;
@override final  String? proBusinessName;
@override final  DateTime createdAt;
@override final  DateTime? lockedAt;
@override final  DateTime? releasedAt;
@override final  DateTime? refundedAt;
@override final  String? errorCode;

/// Create a copy of AdminPaymentRow
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$AdminPaymentRowCopyWith<_AdminPaymentRow> get copyWith => __$AdminPaymentRowCopyWithImpl<_AdminPaymentRow>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$AdminPaymentRowToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _AdminPaymentRow&&(identical(other.ref, ref) || other.ref == ref)&&(identical(other.jobPublicCode, jobPublicCode) || other.jobPublicCode == jobPublicCode)&&(identical(other.status, status) || other.status == status)&&(identical(other.provider, provider) || other.provider == provider)&&(identical(other.totalAmount, totalAmount) || other.totalAmount == totalAmount)&&(identical(other.commission, commission) || other.commission == commission)&&(identical(other.proPayout, proPayout) || other.proPayout == proPayout)&&(identical(other.refundedAmount, refundedAmount) || other.refundedAmount == refundedAmount)&&(identical(other.customerName, customerName) || other.customerName == customerName)&&(identical(other.proBusinessName, proBusinessName) || other.proBusinessName == proBusinessName)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.lockedAt, lockedAt) || other.lockedAt == lockedAt)&&(identical(other.releasedAt, releasedAt) || other.releasedAt == releasedAt)&&(identical(other.refundedAt, refundedAt) || other.refundedAt == refundedAt)&&(identical(other.errorCode, errorCode) || other.errorCode == errorCode));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,ref,jobPublicCode,status,provider,totalAmount,commission,proPayout,refundedAmount,customerName,proBusinessName,createdAt,lockedAt,releasedAt,refundedAt,errorCode);

@override
String toString() {
  return 'AdminPaymentRow(ref: $ref, jobPublicCode: $jobPublicCode, status: $status, provider: $provider, totalAmount: $totalAmount, commission: $commission, proPayout: $proPayout, refundedAmount: $refundedAmount, customerName: $customerName, proBusinessName: $proBusinessName, createdAt: $createdAt, lockedAt: $lockedAt, releasedAt: $releasedAt, refundedAt: $refundedAt, errorCode: $errorCode)';
}


}

/// @nodoc
abstract mixin class _$AdminPaymentRowCopyWith<$Res> implements $AdminPaymentRowCopyWith<$Res> {
  factory _$AdminPaymentRowCopyWith(_AdminPaymentRow value, $Res Function(_AdminPaymentRow) _then) = __$AdminPaymentRowCopyWithImpl;
@override @useResult
$Res call({
 String ref, String? jobPublicCode, String status, String provider,@MoneyConverter() Money totalAmount,@MoneyConverter() Money commission,@MoneyConverter() Money proPayout,@MoneyConverter() Money refundedAmount, String? customerName, String? proBusinessName, DateTime createdAt, DateTime? lockedAt, DateTime? releasedAt, DateTime? refundedAt, String? errorCode
});




}
/// @nodoc
class __$AdminPaymentRowCopyWithImpl<$Res>
    implements _$AdminPaymentRowCopyWith<$Res> {
  __$AdminPaymentRowCopyWithImpl(this._self, this._then);

  final _AdminPaymentRow _self;
  final $Res Function(_AdminPaymentRow) _then;

/// Create a copy of AdminPaymentRow
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? ref = null,Object? jobPublicCode = freezed,Object? status = null,Object? provider = null,Object? totalAmount = null,Object? commission = null,Object? proPayout = null,Object? refundedAmount = null,Object? customerName = freezed,Object? proBusinessName = freezed,Object? createdAt = null,Object? lockedAt = freezed,Object? releasedAt = freezed,Object? refundedAt = freezed,Object? errorCode = freezed,}) {
  return _then(_AdminPaymentRow(
ref: null == ref ? _self.ref : ref // ignore: cast_nullable_to_non_nullable
as String,jobPublicCode: freezed == jobPublicCode ? _self.jobPublicCode : jobPublicCode // ignore: cast_nullable_to_non_nullable
as String?,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as String,provider: null == provider ? _self.provider : provider // ignore: cast_nullable_to_non_nullable
as String,totalAmount: null == totalAmount ? _self.totalAmount : totalAmount // ignore: cast_nullable_to_non_nullable
as Money,commission: null == commission ? _self.commission : commission // ignore: cast_nullable_to_non_nullable
as Money,proPayout: null == proPayout ? _self.proPayout : proPayout // ignore: cast_nullable_to_non_nullable
as Money,refundedAmount: null == refundedAmount ? _self.refundedAmount : refundedAmount // ignore: cast_nullable_to_non_nullable
as Money,customerName: freezed == customerName ? _self.customerName : customerName // ignore: cast_nullable_to_non_nullable
as String?,proBusinessName: freezed == proBusinessName ? _self.proBusinessName : proBusinessName // ignore: cast_nullable_to_non_nullable
as String?,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,lockedAt: freezed == lockedAt ? _self.lockedAt : lockedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,releasedAt: freezed == releasedAt ? _self.releasedAt : releasedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,refundedAt: freezed == refundedAt ? _self.refundedAt : refundedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,errorCode: freezed == errorCode ? _self.errorCode : errorCode // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}


/// @nodoc
mixin _$AdminPaymentTotals {

@MoneyConverter() Money get lockedTotal;@MoneyConverter() Money get releasedTotal;@MoneyConverter() Money get commissionTotal;@MoneyConverter() Money get refundedTotal;
/// Create a copy of AdminPaymentTotals
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$AdminPaymentTotalsCopyWith<AdminPaymentTotals> get copyWith => _$AdminPaymentTotalsCopyWithImpl<AdminPaymentTotals>(this as AdminPaymentTotals, _$identity);

  /// Serializes this AdminPaymentTotals to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is AdminPaymentTotals&&(identical(other.lockedTotal, lockedTotal) || other.lockedTotal == lockedTotal)&&(identical(other.releasedTotal, releasedTotal) || other.releasedTotal == releasedTotal)&&(identical(other.commissionTotal, commissionTotal) || other.commissionTotal == commissionTotal)&&(identical(other.refundedTotal, refundedTotal) || other.refundedTotal == refundedTotal));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,lockedTotal,releasedTotal,commissionTotal,refundedTotal);

@override
String toString() {
  return 'AdminPaymentTotals(lockedTotal: $lockedTotal, releasedTotal: $releasedTotal, commissionTotal: $commissionTotal, refundedTotal: $refundedTotal)';
}


}

/// @nodoc
abstract mixin class $AdminPaymentTotalsCopyWith<$Res>  {
  factory $AdminPaymentTotalsCopyWith(AdminPaymentTotals value, $Res Function(AdminPaymentTotals) _then) = _$AdminPaymentTotalsCopyWithImpl;
@useResult
$Res call({
@MoneyConverter() Money lockedTotal,@MoneyConverter() Money releasedTotal,@MoneyConverter() Money commissionTotal,@MoneyConverter() Money refundedTotal
});




}
/// @nodoc
class _$AdminPaymentTotalsCopyWithImpl<$Res>
    implements $AdminPaymentTotalsCopyWith<$Res> {
  _$AdminPaymentTotalsCopyWithImpl(this._self, this._then);

  final AdminPaymentTotals _self;
  final $Res Function(AdminPaymentTotals) _then;

/// Create a copy of AdminPaymentTotals
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? lockedTotal = null,Object? releasedTotal = null,Object? commissionTotal = null,Object? refundedTotal = null,}) {
  return _then(_self.copyWith(
lockedTotal: null == lockedTotal ? _self.lockedTotal : lockedTotal // ignore: cast_nullable_to_non_nullable
as Money,releasedTotal: null == releasedTotal ? _self.releasedTotal : releasedTotal // ignore: cast_nullable_to_non_nullable
as Money,commissionTotal: null == commissionTotal ? _self.commissionTotal : commissionTotal // ignore: cast_nullable_to_non_nullable
as Money,refundedTotal: null == refundedTotal ? _self.refundedTotal : refundedTotal // ignore: cast_nullable_to_non_nullable
as Money,
  ));
}

}


/// Adds pattern-matching-related methods to [AdminPaymentTotals].
extension AdminPaymentTotalsPatterns on AdminPaymentTotals {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _AdminPaymentTotals value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _AdminPaymentTotals() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _AdminPaymentTotals value)  $default,){
final _that = this;
switch (_that) {
case _AdminPaymentTotals():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _AdminPaymentTotals value)?  $default,){
final _that = this;
switch (_that) {
case _AdminPaymentTotals() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function(@MoneyConverter()  Money lockedTotal, @MoneyConverter()  Money releasedTotal, @MoneyConverter()  Money commissionTotal, @MoneyConverter()  Money refundedTotal)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _AdminPaymentTotals() when $default != null:
return $default(_that.lockedTotal,_that.releasedTotal,_that.commissionTotal,_that.refundedTotal);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function(@MoneyConverter()  Money lockedTotal, @MoneyConverter()  Money releasedTotal, @MoneyConverter()  Money commissionTotal, @MoneyConverter()  Money refundedTotal)  $default,) {final _that = this;
switch (_that) {
case _AdminPaymentTotals():
return $default(_that.lockedTotal,_that.releasedTotal,_that.commissionTotal,_that.refundedTotal);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function(@MoneyConverter()  Money lockedTotal, @MoneyConverter()  Money releasedTotal, @MoneyConverter()  Money commissionTotal, @MoneyConverter()  Money refundedTotal)?  $default,) {final _that = this;
switch (_that) {
case _AdminPaymentTotals() when $default != null:
return $default(_that.lockedTotal,_that.releasedTotal,_that.commissionTotal,_that.refundedTotal);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _AdminPaymentTotals implements AdminPaymentTotals {
  const _AdminPaymentTotals({@MoneyConverter() this.lockedTotal = Money.zero, @MoneyConverter() this.releasedTotal = Money.zero, @MoneyConverter() this.commissionTotal = Money.zero, @MoneyConverter() this.refundedTotal = Money.zero});
  factory _AdminPaymentTotals.fromJson(Map<String, dynamic> json) => _$AdminPaymentTotalsFromJson(json);

@override@JsonKey()@MoneyConverter() final  Money lockedTotal;
@override@JsonKey()@MoneyConverter() final  Money releasedTotal;
@override@JsonKey()@MoneyConverter() final  Money commissionTotal;
@override@JsonKey()@MoneyConverter() final  Money refundedTotal;

/// Create a copy of AdminPaymentTotals
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$AdminPaymentTotalsCopyWith<_AdminPaymentTotals> get copyWith => __$AdminPaymentTotalsCopyWithImpl<_AdminPaymentTotals>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$AdminPaymentTotalsToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _AdminPaymentTotals&&(identical(other.lockedTotal, lockedTotal) || other.lockedTotal == lockedTotal)&&(identical(other.releasedTotal, releasedTotal) || other.releasedTotal == releasedTotal)&&(identical(other.commissionTotal, commissionTotal) || other.commissionTotal == commissionTotal)&&(identical(other.refundedTotal, refundedTotal) || other.refundedTotal == refundedTotal));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,lockedTotal,releasedTotal,commissionTotal,refundedTotal);

@override
String toString() {
  return 'AdminPaymentTotals(lockedTotal: $lockedTotal, releasedTotal: $releasedTotal, commissionTotal: $commissionTotal, refundedTotal: $refundedTotal)';
}


}

/// @nodoc
abstract mixin class _$AdminPaymentTotalsCopyWith<$Res> implements $AdminPaymentTotalsCopyWith<$Res> {
  factory _$AdminPaymentTotalsCopyWith(_AdminPaymentTotals value, $Res Function(_AdminPaymentTotals) _then) = __$AdminPaymentTotalsCopyWithImpl;
@override @useResult
$Res call({
@MoneyConverter() Money lockedTotal,@MoneyConverter() Money releasedTotal,@MoneyConverter() Money commissionTotal,@MoneyConverter() Money refundedTotal
});




}
/// @nodoc
class __$AdminPaymentTotalsCopyWithImpl<$Res>
    implements _$AdminPaymentTotalsCopyWith<$Res> {
  __$AdminPaymentTotalsCopyWithImpl(this._self, this._then);

  final _AdminPaymentTotals _self;
  final $Res Function(_AdminPaymentTotals) _then;

/// Create a copy of AdminPaymentTotals
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? lockedTotal = null,Object? releasedTotal = null,Object? commissionTotal = null,Object? refundedTotal = null,}) {
  return _then(_AdminPaymentTotals(
lockedTotal: null == lockedTotal ? _self.lockedTotal : lockedTotal // ignore: cast_nullable_to_non_nullable
as Money,releasedTotal: null == releasedTotal ? _self.releasedTotal : releasedTotal // ignore: cast_nullable_to_non_nullable
as Money,commissionTotal: null == commissionTotal ? _self.commissionTotal : commissionTotal // ignore: cast_nullable_to_non_nullable
as Money,refundedTotal: null == refundedTotal ? _self.refundedTotal : refundedTotal // ignore: cast_nullable_to_non_nullable
as Money,
  ));
}


}

// dart format on
