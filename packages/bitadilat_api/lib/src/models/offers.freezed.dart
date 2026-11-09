// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'offers.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$ProCard {

@JsonKey(fromJson: idFromJson) String get id; String get businessName; String get fullName; double get ratingAvg; int get ratingCount; int get completedJobs; bool get verified;
/// Create a copy of ProCard
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ProCardCopyWith<ProCard> get copyWith => _$ProCardCopyWithImpl<ProCard>(this as ProCard, _$identity);

  /// Serializes this ProCard to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ProCard&&(identical(other.id, id) || other.id == id)&&(identical(other.businessName, businessName) || other.businessName == businessName)&&(identical(other.fullName, fullName) || other.fullName == fullName)&&(identical(other.ratingAvg, ratingAvg) || other.ratingAvg == ratingAvg)&&(identical(other.ratingCount, ratingCount) || other.ratingCount == ratingCount)&&(identical(other.completedJobs, completedJobs) || other.completedJobs == completedJobs)&&(identical(other.verified, verified) || other.verified == verified));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,businessName,fullName,ratingAvg,ratingCount,completedJobs,verified);

@override
String toString() {
  return 'ProCard(id: $id, businessName: $businessName, fullName: $fullName, ratingAvg: $ratingAvg, ratingCount: $ratingCount, completedJobs: $completedJobs, verified: $verified)';
}


}

/// @nodoc
abstract mixin class $ProCardCopyWith<$Res>  {
  factory $ProCardCopyWith(ProCard value, $Res Function(ProCard) _then) = _$ProCardCopyWithImpl;
@useResult
$Res call({
@JsonKey(fromJson: idFromJson) String id, String businessName, String fullName, double ratingAvg, int ratingCount, int completedJobs, bool verified
});




}
/// @nodoc
class _$ProCardCopyWithImpl<$Res>
    implements $ProCardCopyWith<$Res> {
  _$ProCardCopyWithImpl(this._self, this._then);

  final ProCard _self;
  final $Res Function(ProCard) _then;

/// Create a copy of ProCard
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? businessName = null,Object? fullName = null,Object? ratingAvg = null,Object? ratingCount = null,Object? completedJobs = null,Object? verified = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,businessName: null == businessName ? _self.businessName : businessName // ignore: cast_nullable_to_non_nullable
as String,fullName: null == fullName ? _self.fullName : fullName // ignore: cast_nullable_to_non_nullable
as String,ratingAvg: null == ratingAvg ? _self.ratingAvg : ratingAvg // ignore: cast_nullable_to_non_nullable
as double,ratingCount: null == ratingCount ? _self.ratingCount : ratingCount // ignore: cast_nullable_to_non_nullable
as int,completedJobs: null == completedJobs ? _self.completedJobs : completedJobs // ignore: cast_nullable_to_non_nullable
as int,verified: null == verified ? _self.verified : verified // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}

}


/// Adds pattern-matching-related methods to [ProCard].
extension ProCardPatterns on ProCard {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ProCard value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ProCard() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ProCard value)  $default,){
final _that = this;
switch (_that) {
case _ProCard():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ProCard value)?  $default,){
final _that = this;
switch (_that) {
case _ProCard() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function(@JsonKey(fromJson: idFromJson)  String id,  String businessName,  String fullName,  double ratingAvg,  int ratingCount,  int completedJobs,  bool verified)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ProCard() when $default != null:
return $default(_that.id,_that.businessName,_that.fullName,_that.ratingAvg,_that.ratingCount,_that.completedJobs,_that.verified);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function(@JsonKey(fromJson: idFromJson)  String id,  String businessName,  String fullName,  double ratingAvg,  int ratingCount,  int completedJobs,  bool verified)  $default,) {final _that = this;
switch (_that) {
case _ProCard():
return $default(_that.id,_that.businessName,_that.fullName,_that.ratingAvg,_that.ratingCount,_that.completedJobs,_that.verified);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function(@JsonKey(fromJson: idFromJson)  String id,  String businessName,  String fullName,  double ratingAvg,  int ratingCount,  int completedJobs,  bool verified)?  $default,) {final _that = this;
switch (_that) {
case _ProCard() when $default != null:
return $default(_that.id,_that.businessName,_that.fullName,_that.ratingAvg,_that.ratingCount,_that.completedJobs,_that.verified);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _ProCard implements ProCard {
  const _ProCard({@JsonKey(fromJson: idFromJson) required this.id, required this.businessName, required this.fullName, required this.ratingAvg, required this.ratingCount, required this.completedJobs, required this.verified});
  factory _ProCard.fromJson(Map<String, dynamic> json) => _$ProCardFromJson(json);

@override@JsonKey(fromJson: idFromJson) final  String id;
@override final  String businessName;
@override final  String fullName;
@override final  double ratingAvg;
@override final  int ratingCount;
@override final  int completedJobs;
@override final  bool verified;

/// Create a copy of ProCard
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ProCardCopyWith<_ProCard> get copyWith => __$ProCardCopyWithImpl<_ProCard>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ProCardToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ProCard&&(identical(other.id, id) || other.id == id)&&(identical(other.businessName, businessName) || other.businessName == businessName)&&(identical(other.fullName, fullName) || other.fullName == fullName)&&(identical(other.ratingAvg, ratingAvg) || other.ratingAvg == ratingAvg)&&(identical(other.ratingCount, ratingCount) || other.ratingCount == ratingCount)&&(identical(other.completedJobs, completedJobs) || other.completedJobs == completedJobs)&&(identical(other.verified, verified) || other.verified == verified));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,businessName,fullName,ratingAvg,ratingCount,completedJobs,verified);

@override
String toString() {
  return 'ProCard(id: $id, businessName: $businessName, fullName: $fullName, ratingAvg: $ratingAvg, ratingCount: $ratingCount, completedJobs: $completedJobs, verified: $verified)';
}


}

/// @nodoc
abstract mixin class _$ProCardCopyWith<$Res> implements $ProCardCopyWith<$Res> {
  factory _$ProCardCopyWith(_ProCard value, $Res Function(_ProCard) _then) = __$ProCardCopyWithImpl;
@override @useResult
$Res call({
@JsonKey(fromJson: idFromJson) String id, String businessName, String fullName, double ratingAvg, int ratingCount, int completedJobs, bool verified
});




}
/// @nodoc
class __$ProCardCopyWithImpl<$Res>
    implements _$ProCardCopyWith<$Res> {
  __$ProCardCopyWithImpl(this._self, this._then);

  final _ProCard _self;
  final $Res Function(_ProCard) _then;

/// Create a copy of ProCard
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? businessName = null,Object? fullName = null,Object? ratingAvg = null,Object? ratingCount = null,Object? completedJobs = null,Object? verified = null,}) {
  return _then(_ProCard(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,businessName: null == businessName ? _self.businessName : businessName // ignore: cast_nullable_to_non_nullable
as String,fullName: null == fullName ? _self.fullName : fullName // ignore: cast_nullable_to_non_nullable
as String,ratingAvg: null == ratingAvg ? _self.ratingAvg : ratingAvg // ignore: cast_nullable_to_non_nullable
as double,ratingCount: null == ratingCount ? _self.ratingCount : ratingCount // ignore: cast_nullable_to_non_nullable
as int,completedJobs: null == completedJobs ? _self.completedJobs : completedJobs // ignore: cast_nullable_to_non_nullable
as int,verified: null == verified ? _self.verified : verified // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}


}


/// @nodoc
mixin _$OfferItem {

 OfferItemKind get kind; String get description; num get quantity;@MoneyConverter() Money get unitPrice;@MoneyConverter() Money get lineTotal;
/// Create a copy of OfferItem
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$OfferItemCopyWith<OfferItem> get copyWith => _$OfferItemCopyWithImpl<OfferItem>(this as OfferItem, _$identity);

  /// Serializes this OfferItem to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is OfferItem&&(identical(other.kind, kind) || other.kind == kind)&&(identical(other.description, description) || other.description == description)&&(identical(other.quantity, quantity) || other.quantity == quantity)&&(identical(other.unitPrice, unitPrice) || other.unitPrice == unitPrice)&&(identical(other.lineTotal, lineTotal) || other.lineTotal == lineTotal));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,kind,description,quantity,unitPrice,lineTotal);

@override
String toString() {
  return 'OfferItem(kind: $kind, description: $description, quantity: $quantity, unitPrice: $unitPrice, lineTotal: $lineTotal)';
}


}

/// @nodoc
abstract mixin class $OfferItemCopyWith<$Res>  {
  factory $OfferItemCopyWith(OfferItem value, $Res Function(OfferItem) _then) = _$OfferItemCopyWithImpl;
@useResult
$Res call({
 OfferItemKind kind, String description, num quantity,@MoneyConverter() Money unitPrice,@MoneyConverter() Money lineTotal
});




}
/// @nodoc
class _$OfferItemCopyWithImpl<$Res>
    implements $OfferItemCopyWith<$Res> {
  _$OfferItemCopyWithImpl(this._self, this._then);

  final OfferItem _self;
  final $Res Function(OfferItem) _then;

/// Create a copy of OfferItem
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? kind = null,Object? description = null,Object? quantity = null,Object? unitPrice = null,Object? lineTotal = null,}) {
  return _then(_self.copyWith(
kind: null == kind ? _self.kind : kind // ignore: cast_nullable_to_non_nullable
as OfferItemKind,description: null == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String,quantity: null == quantity ? _self.quantity : quantity // ignore: cast_nullable_to_non_nullable
as num,unitPrice: null == unitPrice ? _self.unitPrice : unitPrice // ignore: cast_nullable_to_non_nullable
as Money,lineTotal: null == lineTotal ? _self.lineTotal : lineTotal // ignore: cast_nullable_to_non_nullable
as Money,
  ));
}

}


/// Adds pattern-matching-related methods to [OfferItem].
extension OfferItemPatterns on OfferItem {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _OfferItem value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _OfferItem() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _OfferItem value)  $default,){
final _that = this;
switch (_that) {
case _OfferItem():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _OfferItem value)?  $default,){
final _that = this;
switch (_that) {
case _OfferItem() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( OfferItemKind kind,  String description,  num quantity, @MoneyConverter()  Money unitPrice, @MoneyConverter()  Money lineTotal)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _OfferItem() when $default != null:
return $default(_that.kind,_that.description,_that.quantity,_that.unitPrice,_that.lineTotal);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( OfferItemKind kind,  String description,  num quantity, @MoneyConverter()  Money unitPrice, @MoneyConverter()  Money lineTotal)  $default,) {final _that = this;
switch (_that) {
case _OfferItem():
return $default(_that.kind,_that.description,_that.quantity,_that.unitPrice,_that.lineTotal);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( OfferItemKind kind,  String description,  num quantity, @MoneyConverter()  Money unitPrice, @MoneyConverter()  Money lineTotal)?  $default,) {final _that = this;
switch (_that) {
case _OfferItem() when $default != null:
return $default(_that.kind,_that.description,_that.quantity,_that.unitPrice,_that.lineTotal);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _OfferItem implements OfferItem {
  const _OfferItem({required this.kind, required this.description, required this.quantity, @MoneyConverter() required this.unitPrice, @MoneyConverter() required this.lineTotal});
  factory _OfferItem.fromJson(Map<String, dynamic> json) => _$OfferItemFromJson(json);

@override final  OfferItemKind kind;
@override final  String description;
@override final  num quantity;
@override@MoneyConverter() final  Money unitPrice;
@override@MoneyConverter() final  Money lineTotal;

/// Create a copy of OfferItem
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$OfferItemCopyWith<_OfferItem> get copyWith => __$OfferItemCopyWithImpl<_OfferItem>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$OfferItemToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _OfferItem&&(identical(other.kind, kind) || other.kind == kind)&&(identical(other.description, description) || other.description == description)&&(identical(other.quantity, quantity) || other.quantity == quantity)&&(identical(other.unitPrice, unitPrice) || other.unitPrice == unitPrice)&&(identical(other.lineTotal, lineTotal) || other.lineTotal == lineTotal));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,kind,description,quantity,unitPrice,lineTotal);

@override
String toString() {
  return 'OfferItem(kind: $kind, description: $description, quantity: $quantity, unitPrice: $unitPrice, lineTotal: $lineTotal)';
}


}

/// @nodoc
abstract mixin class _$OfferItemCopyWith<$Res> implements $OfferItemCopyWith<$Res> {
  factory _$OfferItemCopyWith(_OfferItem value, $Res Function(_OfferItem) _then) = __$OfferItemCopyWithImpl;
@override @useResult
$Res call({
 OfferItemKind kind, String description, num quantity,@MoneyConverter() Money unitPrice,@MoneyConverter() Money lineTotal
});




}
/// @nodoc
class __$OfferItemCopyWithImpl<$Res>
    implements _$OfferItemCopyWith<$Res> {
  __$OfferItemCopyWithImpl(this._self, this._then);

  final _OfferItem _self;
  final $Res Function(_OfferItem) _then;

/// Create a copy of OfferItem
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? kind = null,Object? description = null,Object? quantity = null,Object? unitPrice = null,Object? lineTotal = null,}) {
  return _then(_OfferItem(
kind: null == kind ? _self.kind : kind // ignore: cast_nullable_to_non_nullable
as OfferItemKind,description: null == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String,quantity: null == quantity ? _self.quantity : quantity // ignore: cast_nullable_to_non_nullable
as num,unitPrice: null == unitPrice ? _self.unitPrice : unitPrice // ignore: cast_nullable_to_non_nullable
as Money,lineTotal: null == lineTotal ? _self.lineTotal : lineTotal // ignore: cast_nullable_to_non_nullable
as Money,
  ));
}


}


/// @nodoc
mixin _$OfferSummary {

@JsonKey(fromJson: idFromJson) String get id; String get publicCode;@JsonKey(fromJson: idFromJson) String get requestId; OfferStatus get status; ProCard get pro;@MoneyConverter() Money get laborAmount;@MoneyConverter() Money get materialsAmount;@MoneyConverter() Money get totalAmount; DateTime get arrivalFrom; DateTime get arrivalTo; int get warrantyMonths; String? get note; DateTime get validUntil; DateTime get createdAt;
/// Create a copy of OfferSummary
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$OfferSummaryCopyWith<OfferSummary> get copyWith => _$OfferSummaryCopyWithImpl<OfferSummary>(this as OfferSummary, _$identity);

  /// Serializes this OfferSummary to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is OfferSummary&&(identical(other.id, id) || other.id == id)&&(identical(other.publicCode, publicCode) || other.publicCode == publicCode)&&(identical(other.requestId, requestId) || other.requestId == requestId)&&(identical(other.status, status) || other.status == status)&&(identical(other.pro, pro) || other.pro == pro)&&(identical(other.laborAmount, laborAmount) || other.laborAmount == laborAmount)&&(identical(other.materialsAmount, materialsAmount) || other.materialsAmount == materialsAmount)&&(identical(other.totalAmount, totalAmount) || other.totalAmount == totalAmount)&&(identical(other.arrivalFrom, arrivalFrom) || other.arrivalFrom == arrivalFrom)&&(identical(other.arrivalTo, arrivalTo) || other.arrivalTo == arrivalTo)&&(identical(other.warrantyMonths, warrantyMonths) || other.warrantyMonths == warrantyMonths)&&(identical(other.note, note) || other.note == note)&&(identical(other.validUntil, validUntil) || other.validUntil == validUntil)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,publicCode,requestId,status,pro,laborAmount,materialsAmount,totalAmount,arrivalFrom,arrivalTo,warrantyMonths,note,validUntil,createdAt);

@override
String toString() {
  return 'OfferSummary(id: $id, publicCode: $publicCode, requestId: $requestId, status: $status, pro: $pro, laborAmount: $laborAmount, materialsAmount: $materialsAmount, totalAmount: $totalAmount, arrivalFrom: $arrivalFrom, arrivalTo: $arrivalTo, warrantyMonths: $warrantyMonths, note: $note, validUntil: $validUntil, createdAt: $createdAt)';
}


}

/// @nodoc
abstract mixin class $OfferSummaryCopyWith<$Res>  {
  factory $OfferSummaryCopyWith(OfferSummary value, $Res Function(OfferSummary) _then) = _$OfferSummaryCopyWithImpl;
@useResult
$Res call({
@JsonKey(fromJson: idFromJson) String id, String publicCode,@JsonKey(fromJson: idFromJson) String requestId, OfferStatus status, ProCard pro,@MoneyConverter() Money laborAmount,@MoneyConverter() Money materialsAmount,@MoneyConverter() Money totalAmount, DateTime arrivalFrom, DateTime arrivalTo, int warrantyMonths, String? note, DateTime validUntil, DateTime createdAt
});


$ProCardCopyWith<$Res> get pro;

}
/// @nodoc
class _$OfferSummaryCopyWithImpl<$Res>
    implements $OfferSummaryCopyWith<$Res> {
  _$OfferSummaryCopyWithImpl(this._self, this._then);

  final OfferSummary _self;
  final $Res Function(OfferSummary) _then;

/// Create a copy of OfferSummary
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? publicCode = null,Object? requestId = null,Object? status = null,Object? pro = null,Object? laborAmount = null,Object? materialsAmount = null,Object? totalAmount = null,Object? arrivalFrom = null,Object? arrivalTo = null,Object? warrantyMonths = null,Object? note = freezed,Object? validUntil = null,Object? createdAt = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,publicCode: null == publicCode ? _self.publicCode : publicCode // ignore: cast_nullable_to_non_nullable
as String,requestId: null == requestId ? _self.requestId : requestId // ignore: cast_nullable_to_non_nullable
as String,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as OfferStatus,pro: null == pro ? _self.pro : pro // ignore: cast_nullable_to_non_nullable
as ProCard,laborAmount: null == laborAmount ? _self.laborAmount : laborAmount // ignore: cast_nullable_to_non_nullable
as Money,materialsAmount: null == materialsAmount ? _self.materialsAmount : materialsAmount // ignore: cast_nullable_to_non_nullable
as Money,totalAmount: null == totalAmount ? _self.totalAmount : totalAmount // ignore: cast_nullable_to_non_nullable
as Money,arrivalFrom: null == arrivalFrom ? _self.arrivalFrom : arrivalFrom // ignore: cast_nullable_to_non_nullable
as DateTime,arrivalTo: null == arrivalTo ? _self.arrivalTo : arrivalTo // ignore: cast_nullable_to_non_nullable
as DateTime,warrantyMonths: null == warrantyMonths ? _self.warrantyMonths : warrantyMonths // ignore: cast_nullable_to_non_nullable
as int,note: freezed == note ? _self.note : note // ignore: cast_nullable_to_non_nullable
as String?,validUntil: null == validUntil ? _self.validUntil : validUntil // ignore: cast_nullable_to_non_nullable
as DateTime,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}
/// Create a copy of OfferSummary
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$ProCardCopyWith<$Res> get pro {
  
  return $ProCardCopyWith<$Res>(_self.pro, (value) {
    return _then(_self.copyWith(pro: value));
  });
}
}


/// Adds pattern-matching-related methods to [OfferSummary].
extension OfferSummaryPatterns on OfferSummary {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _OfferSummary value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _OfferSummary() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _OfferSummary value)  $default,){
final _that = this;
switch (_that) {
case _OfferSummary():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _OfferSummary value)?  $default,){
final _that = this;
switch (_that) {
case _OfferSummary() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function(@JsonKey(fromJson: idFromJson)  String id,  String publicCode, @JsonKey(fromJson: idFromJson)  String requestId,  OfferStatus status,  ProCard pro, @MoneyConverter()  Money laborAmount, @MoneyConverter()  Money materialsAmount, @MoneyConverter()  Money totalAmount,  DateTime arrivalFrom,  DateTime arrivalTo,  int warrantyMonths,  String? note,  DateTime validUntil,  DateTime createdAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _OfferSummary() when $default != null:
return $default(_that.id,_that.publicCode,_that.requestId,_that.status,_that.pro,_that.laborAmount,_that.materialsAmount,_that.totalAmount,_that.arrivalFrom,_that.arrivalTo,_that.warrantyMonths,_that.note,_that.validUntil,_that.createdAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function(@JsonKey(fromJson: idFromJson)  String id,  String publicCode, @JsonKey(fromJson: idFromJson)  String requestId,  OfferStatus status,  ProCard pro, @MoneyConverter()  Money laborAmount, @MoneyConverter()  Money materialsAmount, @MoneyConverter()  Money totalAmount,  DateTime arrivalFrom,  DateTime arrivalTo,  int warrantyMonths,  String? note,  DateTime validUntil,  DateTime createdAt)  $default,) {final _that = this;
switch (_that) {
case _OfferSummary():
return $default(_that.id,_that.publicCode,_that.requestId,_that.status,_that.pro,_that.laborAmount,_that.materialsAmount,_that.totalAmount,_that.arrivalFrom,_that.arrivalTo,_that.warrantyMonths,_that.note,_that.validUntil,_that.createdAt);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function(@JsonKey(fromJson: idFromJson)  String id,  String publicCode, @JsonKey(fromJson: idFromJson)  String requestId,  OfferStatus status,  ProCard pro, @MoneyConverter()  Money laborAmount, @MoneyConverter()  Money materialsAmount, @MoneyConverter()  Money totalAmount,  DateTime arrivalFrom,  DateTime arrivalTo,  int warrantyMonths,  String? note,  DateTime validUntil,  DateTime createdAt)?  $default,) {final _that = this;
switch (_that) {
case _OfferSummary() when $default != null:
return $default(_that.id,_that.publicCode,_that.requestId,_that.status,_that.pro,_that.laborAmount,_that.materialsAmount,_that.totalAmount,_that.arrivalFrom,_that.arrivalTo,_that.warrantyMonths,_that.note,_that.validUntil,_that.createdAt);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _OfferSummary implements OfferSummary {
  const _OfferSummary({@JsonKey(fromJson: idFromJson) required this.id, required this.publicCode, @JsonKey(fromJson: idFromJson) required this.requestId, required this.status, required this.pro, @MoneyConverter() required this.laborAmount, @MoneyConverter() required this.materialsAmount, @MoneyConverter() required this.totalAmount, required this.arrivalFrom, required this.arrivalTo, required this.warrantyMonths, this.note, required this.validUntil, required this.createdAt});
  factory _OfferSummary.fromJson(Map<String, dynamic> json) => _$OfferSummaryFromJson(json);

@override@JsonKey(fromJson: idFromJson) final  String id;
@override final  String publicCode;
@override@JsonKey(fromJson: idFromJson) final  String requestId;
@override final  OfferStatus status;
@override final  ProCard pro;
@override@MoneyConverter() final  Money laborAmount;
@override@MoneyConverter() final  Money materialsAmount;
@override@MoneyConverter() final  Money totalAmount;
@override final  DateTime arrivalFrom;
@override final  DateTime arrivalTo;
@override final  int warrantyMonths;
@override final  String? note;
@override final  DateTime validUntil;
@override final  DateTime createdAt;

/// Create a copy of OfferSummary
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$OfferSummaryCopyWith<_OfferSummary> get copyWith => __$OfferSummaryCopyWithImpl<_OfferSummary>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$OfferSummaryToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _OfferSummary&&(identical(other.id, id) || other.id == id)&&(identical(other.publicCode, publicCode) || other.publicCode == publicCode)&&(identical(other.requestId, requestId) || other.requestId == requestId)&&(identical(other.status, status) || other.status == status)&&(identical(other.pro, pro) || other.pro == pro)&&(identical(other.laborAmount, laborAmount) || other.laborAmount == laborAmount)&&(identical(other.materialsAmount, materialsAmount) || other.materialsAmount == materialsAmount)&&(identical(other.totalAmount, totalAmount) || other.totalAmount == totalAmount)&&(identical(other.arrivalFrom, arrivalFrom) || other.arrivalFrom == arrivalFrom)&&(identical(other.arrivalTo, arrivalTo) || other.arrivalTo == arrivalTo)&&(identical(other.warrantyMonths, warrantyMonths) || other.warrantyMonths == warrantyMonths)&&(identical(other.note, note) || other.note == note)&&(identical(other.validUntil, validUntil) || other.validUntil == validUntil)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,publicCode,requestId,status,pro,laborAmount,materialsAmount,totalAmount,arrivalFrom,arrivalTo,warrantyMonths,note,validUntil,createdAt);

@override
String toString() {
  return 'OfferSummary(id: $id, publicCode: $publicCode, requestId: $requestId, status: $status, pro: $pro, laborAmount: $laborAmount, materialsAmount: $materialsAmount, totalAmount: $totalAmount, arrivalFrom: $arrivalFrom, arrivalTo: $arrivalTo, warrantyMonths: $warrantyMonths, note: $note, validUntil: $validUntil, createdAt: $createdAt)';
}


}

/// @nodoc
abstract mixin class _$OfferSummaryCopyWith<$Res> implements $OfferSummaryCopyWith<$Res> {
  factory _$OfferSummaryCopyWith(_OfferSummary value, $Res Function(_OfferSummary) _then) = __$OfferSummaryCopyWithImpl;
@override @useResult
$Res call({
@JsonKey(fromJson: idFromJson) String id, String publicCode,@JsonKey(fromJson: idFromJson) String requestId, OfferStatus status, ProCard pro,@MoneyConverter() Money laborAmount,@MoneyConverter() Money materialsAmount,@MoneyConverter() Money totalAmount, DateTime arrivalFrom, DateTime arrivalTo, int warrantyMonths, String? note, DateTime validUntil, DateTime createdAt
});


@override $ProCardCopyWith<$Res> get pro;

}
/// @nodoc
class __$OfferSummaryCopyWithImpl<$Res>
    implements _$OfferSummaryCopyWith<$Res> {
  __$OfferSummaryCopyWithImpl(this._self, this._then);

  final _OfferSummary _self;
  final $Res Function(_OfferSummary) _then;

/// Create a copy of OfferSummary
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? publicCode = null,Object? requestId = null,Object? status = null,Object? pro = null,Object? laborAmount = null,Object? materialsAmount = null,Object? totalAmount = null,Object? arrivalFrom = null,Object? arrivalTo = null,Object? warrantyMonths = null,Object? note = freezed,Object? validUntil = null,Object? createdAt = null,}) {
  return _then(_OfferSummary(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,publicCode: null == publicCode ? _self.publicCode : publicCode // ignore: cast_nullable_to_non_nullable
as String,requestId: null == requestId ? _self.requestId : requestId // ignore: cast_nullable_to_non_nullable
as String,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as OfferStatus,pro: null == pro ? _self.pro : pro // ignore: cast_nullable_to_non_nullable
as ProCard,laborAmount: null == laborAmount ? _self.laborAmount : laborAmount // ignore: cast_nullable_to_non_nullable
as Money,materialsAmount: null == materialsAmount ? _self.materialsAmount : materialsAmount // ignore: cast_nullable_to_non_nullable
as Money,totalAmount: null == totalAmount ? _self.totalAmount : totalAmount // ignore: cast_nullable_to_non_nullable
as Money,arrivalFrom: null == arrivalFrom ? _self.arrivalFrom : arrivalFrom // ignore: cast_nullable_to_non_nullable
as DateTime,arrivalTo: null == arrivalTo ? _self.arrivalTo : arrivalTo // ignore: cast_nullable_to_non_nullable
as DateTime,warrantyMonths: null == warrantyMonths ? _self.warrantyMonths : warrantyMonths // ignore: cast_nullable_to_non_nullable
as int,note: freezed == note ? _self.note : note // ignore: cast_nullable_to_non_nullable
as String?,validUntil: null == validUntil ? _self.validUntil : validUntil // ignore: cast_nullable_to_non_nullable
as DateTime,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}

/// Create a copy of OfferSummary
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$ProCardCopyWith<$Res> get pro {
  
  return $ProCardCopyWith<$Res>(_self.pro, (value) {
    return _then(_self.copyWith(pro: value));
  });
}
}


/// @nodoc
mixin _$OfferDetail {

@JsonKey(fromJson: idFromJson) String get id; String get publicCode;@JsonKey(fromJson: idFromJson) String get requestId; OfferStatus get status; ProCard get pro;@MoneyConverter() Money get laborAmount;@MoneyConverter() Money get materialsAmount;@MoneyConverter() Money get totalAmount; DateTime get arrivalFrom; DateTime get arrivalTo; int get warrantyMonths; String? get note; DateTime get validUntil; DateTime get createdAt; List<OfferItem> get items;@NullableMoneyConverter() Money? get serviceFee;@NullableMoneyConverter() Money? get netEarning; String? get declineReason;
/// Create a copy of OfferDetail
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$OfferDetailCopyWith<OfferDetail> get copyWith => _$OfferDetailCopyWithImpl<OfferDetail>(this as OfferDetail, _$identity);

  /// Serializes this OfferDetail to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is OfferDetail&&(identical(other.id, id) || other.id == id)&&(identical(other.publicCode, publicCode) || other.publicCode == publicCode)&&(identical(other.requestId, requestId) || other.requestId == requestId)&&(identical(other.status, status) || other.status == status)&&(identical(other.pro, pro) || other.pro == pro)&&(identical(other.laborAmount, laborAmount) || other.laborAmount == laborAmount)&&(identical(other.materialsAmount, materialsAmount) || other.materialsAmount == materialsAmount)&&(identical(other.totalAmount, totalAmount) || other.totalAmount == totalAmount)&&(identical(other.arrivalFrom, arrivalFrom) || other.arrivalFrom == arrivalFrom)&&(identical(other.arrivalTo, arrivalTo) || other.arrivalTo == arrivalTo)&&(identical(other.warrantyMonths, warrantyMonths) || other.warrantyMonths == warrantyMonths)&&(identical(other.note, note) || other.note == note)&&(identical(other.validUntil, validUntil) || other.validUntil == validUntil)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&const DeepCollectionEquality().equals(other.items, items)&&(identical(other.serviceFee, serviceFee) || other.serviceFee == serviceFee)&&(identical(other.netEarning, netEarning) || other.netEarning == netEarning)&&(identical(other.declineReason, declineReason) || other.declineReason == declineReason));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,publicCode,requestId,status,pro,laborAmount,materialsAmount,totalAmount,arrivalFrom,arrivalTo,warrantyMonths,note,validUntil,createdAt,const DeepCollectionEquality().hash(items),serviceFee,netEarning,declineReason);

@override
String toString() {
  return 'OfferDetail(id: $id, publicCode: $publicCode, requestId: $requestId, status: $status, pro: $pro, laborAmount: $laborAmount, materialsAmount: $materialsAmount, totalAmount: $totalAmount, arrivalFrom: $arrivalFrom, arrivalTo: $arrivalTo, warrantyMonths: $warrantyMonths, note: $note, validUntil: $validUntil, createdAt: $createdAt, items: $items, serviceFee: $serviceFee, netEarning: $netEarning, declineReason: $declineReason)';
}


}

/// @nodoc
abstract mixin class $OfferDetailCopyWith<$Res>  {
  factory $OfferDetailCopyWith(OfferDetail value, $Res Function(OfferDetail) _then) = _$OfferDetailCopyWithImpl;
@useResult
$Res call({
@JsonKey(fromJson: idFromJson) String id, String publicCode,@JsonKey(fromJson: idFromJson) String requestId, OfferStatus status, ProCard pro,@MoneyConverter() Money laborAmount,@MoneyConverter() Money materialsAmount,@MoneyConverter() Money totalAmount, DateTime arrivalFrom, DateTime arrivalTo, int warrantyMonths, String? note, DateTime validUntil, DateTime createdAt, List<OfferItem> items,@NullableMoneyConverter() Money? serviceFee,@NullableMoneyConverter() Money? netEarning, String? declineReason
});


$ProCardCopyWith<$Res> get pro;

}
/// @nodoc
class _$OfferDetailCopyWithImpl<$Res>
    implements $OfferDetailCopyWith<$Res> {
  _$OfferDetailCopyWithImpl(this._self, this._then);

  final OfferDetail _self;
  final $Res Function(OfferDetail) _then;

/// Create a copy of OfferDetail
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? publicCode = null,Object? requestId = null,Object? status = null,Object? pro = null,Object? laborAmount = null,Object? materialsAmount = null,Object? totalAmount = null,Object? arrivalFrom = null,Object? arrivalTo = null,Object? warrantyMonths = null,Object? note = freezed,Object? validUntil = null,Object? createdAt = null,Object? items = null,Object? serviceFee = freezed,Object? netEarning = freezed,Object? declineReason = freezed,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,publicCode: null == publicCode ? _self.publicCode : publicCode // ignore: cast_nullable_to_non_nullable
as String,requestId: null == requestId ? _self.requestId : requestId // ignore: cast_nullable_to_non_nullable
as String,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as OfferStatus,pro: null == pro ? _self.pro : pro // ignore: cast_nullable_to_non_nullable
as ProCard,laborAmount: null == laborAmount ? _self.laborAmount : laborAmount // ignore: cast_nullable_to_non_nullable
as Money,materialsAmount: null == materialsAmount ? _self.materialsAmount : materialsAmount // ignore: cast_nullable_to_non_nullable
as Money,totalAmount: null == totalAmount ? _self.totalAmount : totalAmount // ignore: cast_nullable_to_non_nullable
as Money,arrivalFrom: null == arrivalFrom ? _self.arrivalFrom : arrivalFrom // ignore: cast_nullable_to_non_nullable
as DateTime,arrivalTo: null == arrivalTo ? _self.arrivalTo : arrivalTo // ignore: cast_nullable_to_non_nullable
as DateTime,warrantyMonths: null == warrantyMonths ? _self.warrantyMonths : warrantyMonths // ignore: cast_nullable_to_non_nullable
as int,note: freezed == note ? _self.note : note // ignore: cast_nullable_to_non_nullable
as String?,validUntil: null == validUntil ? _self.validUntil : validUntil // ignore: cast_nullable_to_non_nullable
as DateTime,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,items: null == items ? _self.items : items // ignore: cast_nullable_to_non_nullable
as List<OfferItem>,serviceFee: freezed == serviceFee ? _self.serviceFee : serviceFee // ignore: cast_nullable_to_non_nullable
as Money?,netEarning: freezed == netEarning ? _self.netEarning : netEarning // ignore: cast_nullable_to_non_nullable
as Money?,declineReason: freezed == declineReason ? _self.declineReason : declineReason // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}
/// Create a copy of OfferDetail
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$ProCardCopyWith<$Res> get pro {
  
  return $ProCardCopyWith<$Res>(_self.pro, (value) {
    return _then(_self.copyWith(pro: value));
  });
}
}


/// Adds pattern-matching-related methods to [OfferDetail].
extension OfferDetailPatterns on OfferDetail {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _OfferDetail value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _OfferDetail() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _OfferDetail value)  $default,){
final _that = this;
switch (_that) {
case _OfferDetail():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _OfferDetail value)?  $default,){
final _that = this;
switch (_that) {
case _OfferDetail() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function(@JsonKey(fromJson: idFromJson)  String id,  String publicCode, @JsonKey(fromJson: idFromJson)  String requestId,  OfferStatus status,  ProCard pro, @MoneyConverter()  Money laborAmount, @MoneyConverter()  Money materialsAmount, @MoneyConverter()  Money totalAmount,  DateTime arrivalFrom,  DateTime arrivalTo,  int warrantyMonths,  String? note,  DateTime validUntil,  DateTime createdAt,  List<OfferItem> items, @NullableMoneyConverter()  Money? serviceFee, @NullableMoneyConverter()  Money? netEarning,  String? declineReason)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _OfferDetail() when $default != null:
return $default(_that.id,_that.publicCode,_that.requestId,_that.status,_that.pro,_that.laborAmount,_that.materialsAmount,_that.totalAmount,_that.arrivalFrom,_that.arrivalTo,_that.warrantyMonths,_that.note,_that.validUntil,_that.createdAt,_that.items,_that.serviceFee,_that.netEarning,_that.declineReason);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function(@JsonKey(fromJson: idFromJson)  String id,  String publicCode, @JsonKey(fromJson: idFromJson)  String requestId,  OfferStatus status,  ProCard pro, @MoneyConverter()  Money laborAmount, @MoneyConverter()  Money materialsAmount, @MoneyConverter()  Money totalAmount,  DateTime arrivalFrom,  DateTime arrivalTo,  int warrantyMonths,  String? note,  DateTime validUntil,  DateTime createdAt,  List<OfferItem> items, @NullableMoneyConverter()  Money? serviceFee, @NullableMoneyConverter()  Money? netEarning,  String? declineReason)  $default,) {final _that = this;
switch (_that) {
case _OfferDetail():
return $default(_that.id,_that.publicCode,_that.requestId,_that.status,_that.pro,_that.laborAmount,_that.materialsAmount,_that.totalAmount,_that.arrivalFrom,_that.arrivalTo,_that.warrantyMonths,_that.note,_that.validUntil,_that.createdAt,_that.items,_that.serviceFee,_that.netEarning,_that.declineReason);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function(@JsonKey(fromJson: idFromJson)  String id,  String publicCode, @JsonKey(fromJson: idFromJson)  String requestId,  OfferStatus status,  ProCard pro, @MoneyConverter()  Money laborAmount, @MoneyConverter()  Money materialsAmount, @MoneyConverter()  Money totalAmount,  DateTime arrivalFrom,  DateTime arrivalTo,  int warrantyMonths,  String? note,  DateTime validUntil,  DateTime createdAt,  List<OfferItem> items, @NullableMoneyConverter()  Money? serviceFee, @NullableMoneyConverter()  Money? netEarning,  String? declineReason)?  $default,) {final _that = this;
switch (_that) {
case _OfferDetail() when $default != null:
return $default(_that.id,_that.publicCode,_that.requestId,_that.status,_that.pro,_that.laborAmount,_that.materialsAmount,_that.totalAmount,_that.arrivalFrom,_that.arrivalTo,_that.warrantyMonths,_that.note,_that.validUntil,_that.createdAt,_that.items,_that.serviceFee,_that.netEarning,_that.declineReason);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _OfferDetail extends OfferDetail {
  const _OfferDetail({@JsonKey(fromJson: idFromJson) required this.id, required this.publicCode, @JsonKey(fromJson: idFromJson) required this.requestId, required this.status, required this.pro, @MoneyConverter() required this.laborAmount, @MoneyConverter() required this.materialsAmount, @MoneyConverter() required this.totalAmount, required this.arrivalFrom, required this.arrivalTo, required this.warrantyMonths, this.note, required this.validUntil, required this.createdAt, this.items = const <OfferItem>[], @NullableMoneyConverter() this.serviceFee, @NullableMoneyConverter() this.netEarning, this.declineReason}): super._();
  factory _OfferDetail.fromJson(Map<String, dynamic> json) => _$OfferDetailFromJson(json);

@override@JsonKey(fromJson: idFromJson) final  String id;
@override final  String publicCode;
@override@JsonKey(fromJson: idFromJson) final  String requestId;
@override final  OfferStatus status;
@override final  ProCard pro;
@override@MoneyConverter() final  Money laborAmount;
@override@MoneyConverter() final  Money materialsAmount;
@override@MoneyConverter() final  Money totalAmount;
@override final  DateTime arrivalFrom;
@override final  DateTime arrivalTo;
@override final  int warrantyMonths;
@override final  String? note;
@override final  DateTime validUntil;
@override final  DateTime createdAt;
@override@JsonKey() final  List<OfferItem> items;
@override@NullableMoneyConverter() final  Money? serviceFee;
@override@NullableMoneyConverter() final  Money? netEarning;
@override final  String? declineReason;

/// Create a copy of OfferDetail
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$OfferDetailCopyWith<_OfferDetail> get copyWith => __$OfferDetailCopyWithImpl<_OfferDetail>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$OfferDetailToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _OfferDetail&&(identical(other.id, id) || other.id == id)&&(identical(other.publicCode, publicCode) || other.publicCode == publicCode)&&(identical(other.requestId, requestId) || other.requestId == requestId)&&(identical(other.status, status) || other.status == status)&&(identical(other.pro, pro) || other.pro == pro)&&(identical(other.laborAmount, laborAmount) || other.laborAmount == laborAmount)&&(identical(other.materialsAmount, materialsAmount) || other.materialsAmount == materialsAmount)&&(identical(other.totalAmount, totalAmount) || other.totalAmount == totalAmount)&&(identical(other.arrivalFrom, arrivalFrom) || other.arrivalFrom == arrivalFrom)&&(identical(other.arrivalTo, arrivalTo) || other.arrivalTo == arrivalTo)&&(identical(other.warrantyMonths, warrantyMonths) || other.warrantyMonths == warrantyMonths)&&(identical(other.note, note) || other.note == note)&&(identical(other.validUntil, validUntil) || other.validUntil == validUntil)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&const DeepCollectionEquality().equals(other.items, items)&&(identical(other.serviceFee, serviceFee) || other.serviceFee == serviceFee)&&(identical(other.netEarning, netEarning) || other.netEarning == netEarning)&&(identical(other.declineReason, declineReason) || other.declineReason == declineReason));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,publicCode,requestId,status,pro,laborAmount,materialsAmount,totalAmount,arrivalFrom,arrivalTo,warrantyMonths,note,validUntil,createdAt,const DeepCollectionEquality().hash(items),serviceFee,netEarning,declineReason);

@override
String toString() {
  return 'OfferDetail(id: $id, publicCode: $publicCode, requestId: $requestId, status: $status, pro: $pro, laborAmount: $laborAmount, materialsAmount: $materialsAmount, totalAmount: $totalAmount, arrivalFrom: $arrivalFrom, arrivalTo: $arrivalTo, warrantyMonths: $warrantyMonths, note: $note, validUntil: $validUntil, createdAt: $createdAt, items: $items, serviceFee: $serviceFee, netEarning: $netEarning, declineReason: $declineReason)';
}


}

/// @nodoc
abstract mixin class _$OfferDetailCopyWith<$Res> implements $OfferDetailCopyWith<$Res> {
  factory _$OfferDetailCopyWith(_OfferDetail value, $Res Function(_OfferDetail) _then) = __$OfferDetailCopyWithImpl;
@override @useResult
$Res call({
@JsonKey(fromJson: idFromJson) String id, String publicCode,@JsonKey(fromJson: idFromJson) String requestId, OfferStatus status, ProCard pro,@MoneyConverter() Money laborAmount,@MoneyConverter() Money materialsAmount,@MoneyConverter() Money totalAmount, DateTime arrivalFrom, DateTime arrivalTo, int warrantyMonths, String? note, DateTime validUntil, DateTime createdAt, List<OfferItem> items,@NullableMoneyConverter() Money? serviceFee,@NullableMoneyConverter() Money? netEarning, String? declineReason
});


@override $ProCardCopyWith<$Res> get pro;

}
/// @nodoc
class __$OfferDetailCopyWithImpl<$Res>
    implements _$OfferDetailCopyWith<$Res> {
  __$OfferDetailCopyWithImpl(this._self, this._then);

  final _OfferDetail _self;
  final $Res Function(_OfferDetail) _then;

/// Create a copy of OfferDetail
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? publicCode = null,Object? requestId = null,Object? status = null,Object? pro = null,Object? laborAmount = null,Object? materialsAmount = null,Object? totalAmount = null,Object? arrivalFrom = null,Object? arrivalTo = null,Object? warrantyMonths = null,Object? note = freezed,Object? validUntil = null,Object? createdAt = null,Object? items = null,Object? serviceFee = freezed,Object? netEarning = freezed,Object? declineReason = freezed,}) {
  return _then(_OfferDetail(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,publicCode: null == publicCode ? _self.publicCode : publicCode // ignore: cast_nullable_to_non_nullable
as String,requestId: null == requestId ? _self.requestId : requestId // ignore: cast_nullable_to_non_nullable
as String,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as OfferStatus,pro: null == pro ? _self.pro : pro // ignore: cast_nullable_to_non_nullable
as ProCard,laborAmount: null == laborAmount ? _self.laborAmount : laborAmount // ignore: cast_nullable_to_non_nullable
as Money,materialsAmount: null == materialsAmount ? _self.materialsAmount : materialsAmount // ignore: cast_nullable_to_non_nullable
as Money,totalAmount: null == totalAmount ? _self.totalAmount : totalAmount // ignore: cast_nullable_to_non_nullable
as Money,arrivalFrom: null == arrivalFrom ? _self.arrivalFrom : arrivalFrom // ignore: cast_nullable_to_non_nullable
as DateTime,arrivalTo: null == arrivalTo ? _self.arrivalTo : arrivalTo // ignore: cast_nullable_to_non_nullable
as DateTime,warrantyMonths: null == warrantyMonths ? _self.warrantyMonths : warrantyMonths // ignore: cast_nullable_to_non_nullable
as int,note: freezed == note ? _self.note : note // ignore: cast_nullable_to_non_nullable
as String?,validUntil: null == validUntil ? _self.validUntil : validUntil // ignore: cast_nullable_to_non_nullable
as DateTime,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,items: null == items ? _self.items : items // ignore: cast_nullable_to_non_nullable
as List<OfferItem>,serviceFee: freezed == serviceFee ? _self.serviceFee : serviceFee // ignore: cast_nullable_to_non_nullable
as Money?,netEarning: freezed == netEarning ? _self.netEarning : netEarning // ignore: cast_nullable_to_non_nullable
as Money?,declineReason: freezed == declineReason ? _self.declineReason : declineReason // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

/// Create a copy of OfferDetail
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$ProCardCopyWith<$Res> get pro {
  
  return $ProCardCopyWith<$Res>(_self.pro, (value) {
    return _then(_self.copyWith(pro: value));
  });
}
}


/// @nodoc
mixin _$OfferList {

 List<OfferSummary> get items; int get declinedCount;
/// Create a copy of OfferList
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$OfferListCopyWith<OfferList> get copyWith => _$OfferListCopyWithImpl<OfferList>(this as OfferList, _$identity);

  /// Serializes this OfferList to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is OfferList&&const DeepCollectionEquality().equals(other.items, items)&&(identical(other.declinedCount, declinedCount) || other.declinedCount == declinedCount));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(items),declinedCount);

@override
String toString() {
  return 'OfferList(items: $items, declinedCount: $declinedCount)';
}


}

/// @nodoc
abstract mixin class $OfferListCopyWith<$Res>  {
  factory $OfferListCopyWith(OfferList value, $Res Function(OfferList) _then) = _$OfferListCopyWithImpl;
@useResult
$Res call({
 List<OfferSummary> items, int declinedCount
});




}
/// @nodoc
class _$OfferListCopyWithImpl<$Res>
    implements $OfferListCopyWith<$Res> {
  _$OfferListCopyWithImpl(this._self, this._then);

  final OfferList _self;
  final $Res Function(OfferList) _then;

/// Create a copy of OfferList
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? items = null,Object? declinedCount = null,}) {
  return _then(_self.copyWith(
items: null == items ? _self.items : items // ignore: cast_nullable_to_non_nullable
as List<OfferSummary>,declinedCount: null == declinedCount ? _self.declinedCount : declinedCount // ignore: cast_nullable_to_non_nullable
as int,
  ));
}

}


/// Adds pattern-matching-related methods to [OfferList].
extension OfferListPatterns on OfferList {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _OfferList value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _OfferList() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _OfferList value)  $default,){
final _that = this;
switch (_that) {
case _OfferList():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _OfferList value)?  $default,){
final _that = this;
switch (_that) {
case _OfferList() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( List<OfferSummary> items,  int declinedCount)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _OfferList() when $default != null:
return $default(_that.items,_that.declinedCount);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( List<OfferSummary> items,  int declinedCount)  $default,) {final _that = this;
switch (_that) {
case _OfferList():
return $default(_that.items,_that.declinedCount);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( List<OfferSummary> items,  int declinedCount)?  $default,) {final _that = this;
switch (_that) {
case _OfferList() when $default != null:
return $default(_that.items,_that.declinedCount);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _OfferList implements OfferList {
  const _OfferList({required this.items, this.declinedCount = 0});
  factory _OfferList.fromJson(Map<String, dynamic> json) => _$OfferListFromJson(json);

@override final  List<OfferSummary> items;
@override@JsonKey() final  int declinedCount;

/// Create a copy of OfferList
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$OfferListCopyWith<_OfferList> get copyWith => __$OfferListCopyWithImpl<_OfferList>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$OfferListToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _OfferList&&const DeepCollectionEquality().equals(other.items, items)&&(identical(other.declinedCount, declinedCount) || other.declinedCount == declinedCount));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(items),declinedCount);

@override
String toString() {
  return 'OfferList(items: $items, declinedCount: $declinedCount)';
}


}

/// @nodoc
abstract mixin class _$OfferListCopyWith<$Res> implements $OfferListCopyWith<$Res> {
  factory _$OfferListCopyWith(_OfferList value, $Res Function(_OfferList) _then) = __$OfferListCopyWithImpl;
@override @useResult
$Res call({
 List<OfferSummary> items, int declinedCount
});




}
/// @nodoc
class __$OfferListCopyWithImpl<$Res>
    implements _$OfferListCopyWith<$Res> {
  __$OfferListCopyWithImpl(this._self, this._then);

  final _OfferList _self;
  final $Res Function(_OfferList) _then;

/// Create a copy of OfferList
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? items = null,Object? declinedCount = null,}) {
  return _then(_OfferList(
items: null == items ? _self.items : items // ignore: cast_nullable_to_non_nullable
as List<OfferSummary>,declinedCount: null == declinedCount ? _self.declinedCount : declinedCount // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}


/// @nodoc
mixin _$OfferRequestRef {

@JsonKey(fromJson: idFromJson) String get id; String get publicCode; String get title; String get districtName;
/// Create a copy of OfferRequestRef
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$OfferRequestRefCopyWith<OfferRequestRef> get copyWith => _$OfferRequestRefCopyWithImpl<OfferRequestRef>(this as OfferRequestRef, _$identity);

  /// Serializes this OfferRequestRef to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is OfferRequestRef&&(identical(other.id, id) || other.id == id)&&(identical(other.publicCode, publicCode) || other.publicCode == publicCode)&&(identical(other.title, title) || other.title == title)&&(identical(other.districtName, districtName) || other.districtName == districtName));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,publicCode,title,districtName);

@override
String toString() {
  return 'OfferRequestRef(id: $id, publicCode: $publicCode, title: $title, districtName: $districtName)';
}


}

/// @nodoc
abstract mixin class $OfferRequestRefCopyWith<$Res>  {
  factory $OfferRequestRefCopyWith(OfferRequestRef value, $Res Function(OfferRequestRef) _then) = _$OfferRequestRefCopyWithImpl;
@useResult
$Res call({
@JsonKey(fromJson: idFromJson) String id, String publicCode, String title, String districtName
});




}
/// @nodoc
class _$OfferRequestRefCopyWithImpl<$Res>
    implements $OfferRequestRefCopyWith<$Res> {
  _$OfferRequestRefCopyWithImpl(this._self, this._then);

  final OfferRequestRef _self;
  final $Res Function(OfferRequestRef) _then;

/// Create a copy of OfferRequestRef
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? publicCode = null,Object? title = null,Object? districtName = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,publicCode: null == publicCode ? _self.publicCode : publicCode // ignore: cast_nullable_to_non_nullable
as String,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,districtName: null == districtName ? _self.districtName : districtName // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [OfferRequestRef].
extension OfferRequestRefPatterns on OfferRequestRef {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _OfferRequestRef value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _OfferRequestRef() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _OfferRequestRef value)  $default,){
final _that = this;
switch (_that) {
case _OfferRequestRef():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _OfferRequestRef value)?  $default,){
final _that = this;
switch (_that) {
case _OfferRequestRef() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function(@JsonKey(fromJson: idFromJson)  String id,  String publicCode,  String title,  String districtName)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _OfferRequestRef() when $default != null:
return $default(_that.id,_that.publicCode,_that.title,_that.districtName);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function(@JsonKey(fromJson: idFromJson)  String id,  String publicCode,  String title,  String districtName)  $default,) {final _that = this;
switch (_that) {
case _OfferRequestRef():
return $default(_that.id,_that.publicCode,_that.title,_that.districtName);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function(@JsonKey(fromJson: idFromJson)  String id,  String publicCode,  String title,  String districtName)?  $default,) {final _that = this;
switch (_that) {
case _OfferRequestRef() when $default != null:
return $default(_that.id,_that.publicCode,_that.title,_that.districtName);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _OfferRequestRef implements OfferRequestRef {
  const _OfferRequestRef({@JsonKey(fromJson: idFromJson) required this.id, required this.publicCode, required this.title, required this.districtName});
  factory _OfferRequestRef.fromJson(Map<String, dynamic> json) => _$OfferRequestRefFromJson(json);

@override@JsonKey(fromJson: idFromJson) final  String id;
@override final  String publicCode;
@override final  String title;
@override final  String districtName;

/// Create a copy of OfferRequestRef
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$OfferRequestRefCopyWith<_OfferRequestRef> get copyWith => __$OfferRequestRefCopyWithImpl<_OfferRequestRef>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$OfferRequestRefToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _OfferRequestRef&&(identical(other.id, id) || other.id == id)&&(identical(other.publicCode, publicCode) || other.publicCode == publicCode)&&(identical(other.title, title) || other.title == title)&&(identical(other.districtName, districtName) || other.districtName == districtName));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,publicCode,title,districtName);

@override
String toString() {
  return 'OfferRequestRef(id: $id, publicCode: $publicCode, title: $title, districtName: $districtName)';
}


}

/// @nodoc
abstract mixin class _$OfferRequestRefCopyWith<$Res> implements $OfferRequestRefCopyWith<$Res> {
  factory _$OfferRequestRefCopyWith(_OfferRequestRef value, $Res Function(_OfferRequestRef) _then) = __$OfferRequestRefCopyWithImpl;
@override @useResult
$Res call({
@JsonKey(fromJson: idFromJson) String id, String publicCode, String title, String districtName
});




}
/// @nodoc
class __$OfferRequestRefCopyWithImpl<$Res>
    implements _$OfferRequestRefCopyWith<$Res> {
  __$OfferRequestRefCopyWithImpl(this._self, this._then);

  final _OfferRequestRef _self;
  final $Res Function(_OfferRequestRef) _then;

/// Create a copy of OfferRequestRef
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? publicCode = null,Object? title = null,Object? districtName = null,}) {
  return _then(_OfferRequestRef(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,publicCode: null == publicCode ? _self.publicCode : publicCode // ignore: cast_nullable_to_non_nullable
as String,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,districtName: null == districtName ? _self.districtName : districtName // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}


/// @nodoc
mixin _$OfferItemInput {

 OfferItemKind get kind; String get description; num get quantity;@MoneyConverter() Money get unitPrice;
/// Create a copy of OfferItemInput
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$OfferItemInputCopyWith<OfferItemInput> get copyWith => _$OfferItemInputCopyWithImpl<OfferItemInput>(this as OfferItemInput, _$identity);

  /// Serializes this OfferItemInput to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is OfferItemInput&&(identical(other.kind, kind) || other.kind == kind)&&(identical(other.description, description) || other.description == description)&&(identical(other.quantity, quantity) || other.quantity == quantity)&&(identical(other.unitPrice, unitPrice) || other.unitPrice == unitPrice));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,kind,description,quantity,unitPrice);

@override
String toString() {
  return 'OfferItemInput(kind: $kind, description: $description, quantity: $quantity, unitPrice: $unitPrice)';
}


}

/// @nodoc
abstract mixin class $OfferItemInputCopyWith<$Res>  {
  factory $OfferItemInputCopyWith(OfferItemInput value, $Res Function(OfferItemInput) _then) = _$OfferItemInputCopyWithImpl;
@useResult
$Res call({
 OfferItemKind kind, String description, num quantity,@MoneyConverter() Money unitPrice
});




}
/// @nodoc
class _$OfferItemInputCopyWithImpl<$Res>
    implements $OfferItemInputCopyWith<$Res> {
  _$OfferItemInputCopyWithImpl(this._self, this._then);

  final OfferItemInput _self;
  final $Res Function(OfferItemInput) _then;

/// Create a copy of OfferItemInput
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? kind = null,Object? description = null,Object? quantity = null,Object? unitPrice = null,}) {
  return _then(_self.copyWith(
kind: null == kind ? _self.kind : kind // ignore: cast_nullable_to_non_nullable
as OfferItemKind,description: null == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String,quantity: null == quantity ? _self.quantity : quantity // ignore: cast_nullable_to_non_nullable
as num,unitPrice: null == unitPrice ? _self.unitPrice : unitPrice // ignore: cast_nullable_to_non_nullable
as Money,
  ));
}

}


/// Adds pattern-matching-related methods to [OfferItemInput].
extension OfferItemInputPatterns on OfferItemInput {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _OfferItemInput value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _OfferItemInput() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _OfferItemInput value)  $default,){
final _that = this;
switch (_that) {
case _OfferItemInput():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _OfferItemInput value)?  $default,){
final _that = this;
switch (_that) {
case _OfferItemInput() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( OfferItemKind kind,  String description,  num quantity, @MoneyConverter()  Money unitPrice)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _OfferItemInput() when $default != null:
return $default(_that.kind,_that.description,_that.quantity,_that.unitPrice);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( OfferItemKind kind,  String description,  num quantity, @MoneyConverter()  Money unitPrice)  $default,) {final _that = this;
switch (_that) {
case _OfferItemInput():
return $default(_that.kind,_that.description,_that.quantity,_that.unitPrice);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( OfferItemKind kind,  String description,  num quantity, @MoneyConverter()  Money unitPrice)?  $default,) {final _that = this;
switch (_that) {
case _OfferItemInput() when $default != null:
return $default(_that.kind,_that.description,_that.quantity,_that.unitPrice);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _OfferItemInput implements OfferItemInput {
  const _OfferItemInput({required this.kind, required this.description, required this.quantity, @MoneyConverter() required this.unitPrice});
  factory _OfferItemInput.fromJson(Map<String, dynamic> json) => _$OfferItemInputFromJson(json);

@override final  OfferItemKind kind;
@override final  String description;
@override final  num quantity;
@override@MoneyConverter() final  Money unitPrice;

/// Create a copy of OfferItemInput
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$OfferItemInputCopyWith<_OfferItemInput> get copyWith => __$OfferItemInputCopyWithImpl<_OfferItemInput>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$OfferItemInputToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _OfferItemInput&&(identical(other.kind, kind) || other.kind == kind)&&(identical(other.description, description) || other.description == description)&&(identical(other.quantity, quantity) || other.quantity == quantity)&&(identical(other.unitPrice, unitPrice) || other.unitPrice == unitPrice));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,kind,description,quantity,unitPrice);

@override
String toString() {
  return 'OfferItemInput(kind: $kind, description: $description, quantity: $quantity, unitPrice: $unitPrice)';
}


}

/// @nodoc
abstract mixin class _$OfferItemInputCopyWith<$Res> implements $OfferItemInputCopyWith<$Res> {
  factory _$OfferItemInputCopyWith(_OfferItemInput value, $Res Function(_OfferItemInput) _then) = __$OfferItemInputCopyWithImpl;
@override @useResult
$Res call({
 OfferItemKind kind, String description, num quantity,@MoneyConverter() Money unitPrice
});




}
/// @nodoc
class __$OfferItemInputCopyWithImpl<$Res>
    implements _$OfferItemInputCopyWith<$Res> {
  __$OfferItemInputCopyWithImpl(this._self, this._then);

  final _OfferItemInput _self;
  final $Res Function(_OfferItemInput) _then;

/// Create a copy of OfferItemInput
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? kind = null,Object? description = null,Object? quantity = null,Object? unitPrice = null,}) {
  return _then(_OfferItemInput(
kind: null == kind ? _self.kind : kind // ignore: cast_nullable_to_non_nullable
as OfferItemKind,description: null == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String,quantity: null == quantity ? _self.quantity : quantity // ignore: cast_nullable_to_non_nullable
as num,unitPrice: null == unitPrice ? _self.unitPrice : unitPrice // ignore: cast_nullable_to_non_nullable
as Money,
  ));
}


}


/// @nodoc
mixin _$CreateOfferRequest {

@MoneyConverter() Money get laborAmount;@MoneyConverter() Money get materialsAmount; DateTime get arrivalFrom; DateTime get arrivalTo; int get warrantyMonths; String get note; List<OfferItemInput> get items;
/// Create a copy of CreateOfferRequest
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$CreateOfferRequestCopyWith<CreateOfferRequest> get copyWith => _$CreateOfferRequestCopyWithImpl<CreateOfferRequest>(this as CreateOfferRequest, _$identity);

  /// Serializes this CreateOfferRequest to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is CreateOfferRequest&&(identical(other.laborAmount, laborAmount) || other.laborAmount == laborAmount)&&(identical(other.materialsAmount, materialsAmount) || other.materialsAmount == materialsAmount)&&(identical(other.arrivalFrom, arrivalFrom) || other.arrivalFrom == arrivalFrom)&&(identical(other.arrivalTo, arrivalTo) || other.arrivalTo == arrivalTo)&&(identical(other.warrantyMonths, warrantyMonths) || other.warrantyMonths == warrantyMonths)&&(identical(other.note, note) || other.note == note)&&const DeepCollectionEquality().equals(other.items, items));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,laborAmount,materialsAmount,arrivalFrom,arrivalTo,warrantyMonths,note,const DeepCollectionEquality().hash(items));

@override
String toString() {
  return 'CreateOfferRequest(laborAmount: $laborAmount, materialsAmount: $materialsAmount, arrivalFrom: $arrivalFrom, arrivalTo: $arrivalTo, warrantyMonths: $warrantyMonths, note: $note, items: $items)';
}


}

/// @nodoc
abstract mixin class $CreateOfferRequestCopyWith<$Res>  {
  factory $CreateOfferRequestCopyWith(CreateOfferRequest value, $Res Function(CreateOfferRequest) _then) = _$CreateOfferRequestCopyWithImpl;
@useResult
$Res call({
@MoneyConverter() Money laborAmount,@MoneyConverter() Money materialsAmount, DateTime arrivalFrom, DateTime arrivalTo, int warrantyMonths, String note, List<OfferItemInput> items
});




}
/// @nodoc
class _$CreateOfferRequestCopyWithImpl<$Res>
    implements $CreateOfferRequestCopyWith<$Res> {
  _$CreateOfferRequestCopyWithImpl(this._self, this._then);

  final CreateOfferRequest _self;
  final $Res Function(CreateOfferRequest) _then;

/// Create a copy of CreateOfferRequest
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? laborAmount = null,Object? materialsAmount = null,Object? arrivalFrom = null,Object? arrivalTo = null,Object? warrantyMonths = null,Object? note = null,Object? items = null,}) {
  return _then(_self.copyWith(
laborAmount: null == laborAmount ? _self.laborAmount : laborAmount // ignore: cast_nullable_to_non_nullable
as Money,materialsAmount: null == materialsAmount ? _self.materialsAmount : materialsAmount // ignore: cast_nullable_to_non_nullable
as Money,arrivalFrom: null == arrivalFrom ? _self.arrivalFrom : arrivalFrom // ignore: cast_nullable_to_non_nullable
as DateTime,arrivalTo: null == arrivalTo ? _self.arrivalTo : arrivalTo // ignore: cast_nullable_to_non_nullable
as DateTime,warrantyMonths: null == warrantyMonths ? _self.warrantyMonths : warrantyMonths // ignore: cast_nullable_to_non_nullable
as int,note: null == note ? _self.note : note // ignore: cast_nullable_to_non_nullable
as String,items: null == items ? _self.items : items // ignore: cast_nullable_to_non_nullable
as List<OfferItemInput>,
  ));
}

}


/// Adds pattern-matching-related methods to [CreateOfferRequest].
extension CreateOfferRequestPatterns on CreateOfferRequest {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _CreateOfferRequest value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _CreateOfferRequest() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _CreateOfferRequest value)  $default,){
final _that = this;
switch (_that) {
case _CreateOfferRequest():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _CreateOfferRequest value)?  $default,){
final _that = this;
switch (_that) {
case _CreateOfferRequest() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function(@MoneyConverter()  Money laborAmount, @MoneyConverter()  Money materialsAmount,  DateTime arrivalFrom,  DateTime arrivalTo,  int warrantyMonths,  String note,  List<OfferItemInput> items)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _CreateOfferRequest() when $default != null:
return $default(_that.laborAmount,_that.materialsAmount,_that.arrivalFrom,_that.arrivalTo,_that.warrantyMonths,_that.note,_that.items);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function(@MoneyConverter()  Money laborAmount, @MoneyConverter()  Money materialsAmount,  DateTime arrivalFrom,  DateTime arrivalTo,  int warrantyMonths,  String note,  List<OfferItemInput> items)  $default,) {final _that = this;
switch (_that) {
case _CreateOfferRequest():
return $default(_that.laborAmount,_that.materialsAmount,_that.arrivalFrom,_that.arrivalTo,_that.warrantyMonths,_that.note,_that.items);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function(@MoneyConverter()  Money laborAmount, @MoneyConverter()  Money materialsAmount,  DateTime arrivalFrom,  DateTime arrivalTo,  int warrantyMonths,  String note,  List<OfferItemInput> items)?  $default,) {final _that = this;
switch (_that) {
case _CreateOfferRequest() when $default != null:
return $default(_that.laborAmount,_that.materialsAmount,_that.arrivalFrom,_that.arrivalTo,_that.warrantyMonths,_that.note,_that.items);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _CreateOfferRequest implements CreateOfferRequest {
  const _CreateOfferRequest({@MoneyConverter() required this.laborAmount, @MoneyConverter() required this.materialsAmount, required this.arrivalFrom, required this.arrivalTo, required this.warrantyMonths, this.note = '', this.items = const <OfferItemInput>[]});
  factory _CreateOfferRequest.fromJson(Map<String, dynamic> json) => _$CreateOfferRequestFromJson(json);

@override@MoneyConverter() final  Money laborAmount;
@override@MoneyConverter() final  Money materialsAmount;
@override final  DateTime arrivalFrom;
@override final  DateTime arrivalTo;
@override final  int warrantyMonths;
@override@JsonKey() final  String note;
@override@JsonKey() final  List<OfferItemInput> items;

/// Create a copy of CreateOfferRequest
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$CreateOfferRequestCopyWith<_CreateOfferRequest> get copyWith => __$CreateOfferRequestCopyWithImpl<_CreateOfferRequest>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$CreateOfferRequestToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _CreateOfferRequest&&(identical(other.laborAmount, laborAmount) || other.laborAmount == laborAmount)&&(identical(other.materialsAmount, materialsAmount) || other.materialsAmount == materialsAmount)&&(identical(other.arrivalFrom, arrivalFrom) || other.arrivalFrom == arrivalFrom)&&(identical(other.arrivalTo, arrivalTo) || other.arrivalTo == arrivalTo)&&(identical(other.warrantyMonths, warrantyMonths) || other.warrantyMonths == warrantyMonths)&&(identical(other.note, note) || other.note == note)&&const DeepCollectionEquality().equals(other.items, items));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,laborAmount,materialsAmount,arrivalFrom,arrivalTo,warrantyMonths,note,const DeepCollectionEquality().hash(items));

@override
String toString() {
  return 'CreateOfferRequest(laborAmount: $laborAmount, materialsAmount: $materialsAmount, arrivalFrom: $arrivalFrom, arrivalTo: $arrivalTo, warrantyMonths: $warrantyMonths, note: $note, items: $items)';
}


}

/// @nodoc
abstract mixin class _$CreateOfferRequestCopyWith<$Res> implements $CreateOfferRequestCopyWith<$Res> {
  factory _$CreateOfferRequestCopyWith(_CreateOfferRequest value, $Res Function(_CreateOfferRequest) _then) = __$CreateOfferRequestCopyWithImpl;
@override @useResult
$Res call({
@MoneyConverter() Money laborAmount,@MoneyConverter() Money materialsAmount, DateTime arrivalFrom, DateTime arrivalTo, int warrantyMonths, String note, List<OfferItemInput> items
});




}
/// @nodoc
class __$CreateOfferRequestCopyWithImpl<$Res>
    implements _$CreateOfferRequestCopyWith<$Res> {
  __$CreateOfferRequestCopyWithImpl(this._self, this._then);

  final _CreateOfferRequest _self;
  final $Res Function(_CreateOfferRequest) _then;

/// Create a copy of CreateOfferRequest
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? laborAmount = null,Object? materialsAmount = null,Object? arrivalFrom = null,Object? arrivalTo = null,Object? warrantyMonths = null,Object? note = null,Object? items = null,}) {
  return _then(_CreateOfferRequest(
laborAmount: null == laborAmount ? _self.laborAmount : laborAmount // ignore: cast_nullable_to_non_nullable
as Money,materialsAmount: null == materialsAmount ? _self.materialsAmount : materialsAmount // ignore: cast_nullable_to_non_nullable
as Money,arrivalFrom: null == arrivalFrom ? _self.arrivalFrom : arrivalFrom // ignore: cast_nullable_to_non_nullable
as DateTime,arrivalTo: null == arrivalTo ? _self.arrivalTo : arrivalTo // ignore: cast_nullable_to_non_nullable
as DateTime,warrantyMonths: null == warrantyMonths ? _self.warrantyMonths : warrantyMonths // ignore: cast_nullable_to_non_nullable
as int,note: null == note ? _self.note : note // ignore: cast_nullable_to_non_nullable
as String,items: null == items ? _self.items : items // ignore: cast_nullable_to_non_nullable
as List<OfferItemInput>,
  ));
}


}


/// @nodoc
mixin _$DeclineOfferRequest {

 DeclineReason get reason;@JsonKey(includeIfNull: false) String? get note; bool get keepRequestOpen;
/// Create a copy of DeclineOfferRequest
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$DeclineOfferRequestCopyWith<DeclineOfferRequest> get copyWith => _$DeclineOfferRequestCopyWithImpl<DeclineOfferRequest>(this as DeclineOfferRequest, _$identity);

  /// Serializes this DeclineOfferRequest to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is DeclineOfferRequest&&(identical(other.reason, reason) || other.reason == reason)&&(identical(other.note, note) || other.note == note)&&(identical(other.keepRequestOpen, keepRequestOpen) || other.keepRequestOpen == keepRequestOpen));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,reason,note,keepRequestOpen);

@override
String toString() {
  return 'DeclineOfferRequest(reason: $reason, note: $note, keepRequestOpen: $keepRequestOpen)';
}


}

/// @nodoc
abstract mixin class $DeclineOfferRequestCopyWith<$Res>  {
  factory $DeclineOfferRequestCopyWith(DeclineOfferRequest value, $Res Function(DeclineOfferRequest) _then) = _$DeclineOfferRequestCopyWithImpl;
@useResult
$Res call({
 DeclineReason reason,@JsonKey(includeIfNull: false) String? note, bool keepRequestOpen
});




}
/// @nodoc
class _$DeclineOfferRequestCopyWithImpl<$Res>
    implements $DeclineOfferRequestCopyWith<$Res> {
  _$DeclineOfferRequestCopyWithImpl(this._self, this._then);

  final DeclineOfferRequest _self;
  final $Res Function(DeclineOfferRequest) _then;

/// Create a copy of DeclineOfferRequest
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? reason = null,Object? note = freezed,Object? keepRequestOpen = null,}) {
  return _then(_self.copyWith(
reason: null == reason ? _self.reason : reason // ignore: cast_nullable_to_non_nullable
as DeclineReason,note: freezed == note ? _self.note : note // ignore: cast_nullable_to_non_nullable
as String?,keepRequestOpen: null == keepRequestOpen ? _self.keepRequestOpen : keepRequestOpen // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}

}


/// Adds pattern-matching-related methods to [DeclineOfferRequest].
extension DeclineOfferRequestPatterns on DeclineOfferRequest {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _DeclineOfferRequest value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _DeclineOfferRequest() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _DeclineOfferRequest value)  $default,){
final _that = this;
switch (_that) {
case _DeclineOfferRequest():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _DeclineOfferRequest value)?  $default,){
final _that = this;
switch (_that) {
case _DeclineOfferRequest() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( DeclineReason reason, @JsonKey(includeIfNull: false)  String? note,  bool keepRequestOpen)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _DeclineOfferRequest() when $default != null:
return $default(_that.reason,_that.note,_that.keepRequestOpen);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( DeclineReason reason, @JsonKey(includeIfNull: false)  String? note,  bool keepRequestOpen)  $default,) {final _that = this;
switch (_that) {
case _DeclineOfferRequest():
return $default(_that.reason,_that.note,_that.keepRequestOpen);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( DeclineReason reason, @JsonKey(includeIfNull: false)  String? note,  bool keepRequestOpen)?  $default,) {final _that = this;
switch (_that) {
case _DeclineOfferRequest() when $default != null:
return $default(_that.reason,_that.note,_that.keepRequestOpen);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _DeclineOfferRequest implements DeclineOfferRequest {
  const _DeclineOfferRequest({required this.reason, @JsonKey(includeIfNull: false) this.note, required this.keepRequestOpen});
  factory _DeclineOfferRequest.fromJson(Map<String, dynamic> json) => _$DeclineOfferRequestFromJson(json);

@override final  DeclineReason reason;
@override@JsonKey(includeIfNull: false) final  String? note;
@override final  bool keepRequestOpen;

/// Create a copy of DeclineOfferRequest
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$DeclineOfferRequestCopyWith<_DeclineOfferRequest> get copyWith => __$DeclineOfferRequestCopyWithImpl<_DeclineOfferRequest>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$DeclineOfferRequestToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _DeclineOfferRequest&&(identical(other.reason, reason) || other.reason == reason)&&(identical(other.note, note) || other.note == note)&&(identical(other.keepRequestOpen, keepRequestOpen) || other.keepRequestOpen == keepRequestOpen));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,reason,note,keepRequestOpen);

@override
String toString() {
  return 'DeclineOfferRequest(reason: $reason, note: $note, keepRequestOpen: $keepRequestOpen)';
}


}

/// @nodoc
abstract mixin class _$DeclineOfferRequestCopyWith<$Res> implements $DeclineOfferRequestCopyWith<$Res> {
  factory _$DeclineOfferRequestCopyWith(_DeclineOfferRequest value, $Res Function(_DeclineOfferRequest) _then) = __$DeclineOfferRequestCopyWithImpl;
@override @useResult
$Res call({
 DeclineReason reason,@JsonKey(includeIfNull: false) String? note, bool keepRequestOpen
});




}
/// @nodoc
class __$DeclineOfferRequestCopyWithImpl<$Res>
    implements _$DeclineOfferRequestCopyWith<$Res> {
  __$DeclineOfferRequestCopyWithImpl(this._self, this._then);

  final _DeclineOfferRequest _self;
  final $Res Function(_DeclineOfferRequest) _then;

/// Create a copy of DeclineOfferRequest
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? reason = null,Object? note = freezed,Object? keepRequestOpen = null,}) {
  return _then(_DeclineOfferRequest(
reason: null == reason ? _self.reason : reason // ignore: cast_nullable_to_non_nullable
as DeclineReason,note: freezed == note ? _self.note : note // ignore: cast_nullable_to_non_nullable
as String?,keepRequestOpen: null == keepRequestOpen ? _self.keepRequestOpen : keepRequestOpen // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}


}

// dart format on
