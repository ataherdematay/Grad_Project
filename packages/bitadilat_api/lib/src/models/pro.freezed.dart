// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'pro.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$FeedItem {

@JsonKey(fromJson: idFromJson) String get id; String get publicCode; String get title;@JsonKey(fromJson: idFromJson) String get categoryId; RequestUrgency get urgency; String get districtName; String get neighborhood; DateTime get createdAt; DateTime? get preferredFrom; DateTime? get preferredTo; int get photoCount; int get offerCount;@JsonKey(fromJson: idFromJsonNullable) String? get myOfferId;
/// Create a copy of FeedItem
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$FeedItemCopyWith<FeedItem> get copyWith => _$FeedItemCopyWithImpl<FeedItem>(this as FeedItem, _$identity);

  /// Serializes this FeedItem to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is FeedItem&&(identical(other.id, id) || other.id == id)&&(identical(other.publicCode, publicCode) || other.publicCode == publicCode)&&(identical(other.title, title) || other.title == title)&&(identical(other.categoryId, categoryId) || other.categoryId == categoryId)&&(identical(other.urgency, urgency) || other.urgency == urgency)&&(identical(other.districtName, districtName) || other.districtName == districtName)&&(identical(other.neighborhood, neighborhood) || other.neighborhood == neighborhood)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.preferredFrom, preferredFrom) || other.preferredFrom == preferredFrom)&&(identical(other.preferredTo, preferredTo) || other.preferredTo == preferredTo)&&(identical(other.photoCount, photoCount) || other.photoCount == photoCount)&&(identical(other.offerCount, offerCount) || other.offerCount == offerCount)&&(identical(other.myOfferId, myOfferId) || other.myOfferId == myOfferId));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,publicCode,title,categoryId,urgency,districtName,neighborhood,createdAt,preferredFrom,preferredTo,photoCount,offerCount,myOfferId);

@override
String toString() {
  return 'FeedItem(id: $id, publicCode: $publicCode, title: $title, categoryId: $categoryId, urgency: $urgency, districtName: $districtName, neighborhood: $neighborhood, createdAt: $createdAt, preferredFrom: $preferredFrom, preferredTo: $preferredTo, photoCount: $photoCount, offerCount: $offerCount, myOfferId: $myOfferId)';
}


}

/// @nodoc
abstract mixin class $FeedItemCopyWith<$Res>  {
  factory $FeedItemCopyWith(FeedItem value, $Res Function(FeedItem) _then) = _$FeedItemCopyWithImpl;
@useResult
$Res call({
@JsonKey(fromJson: idFromJson) String id, String publicCode, String title,@JsonKey(fromJson: idFromJson) String categoryId, RequestUrgency urgency, String districtName, String neighborhood, DateTime createdAt, DateTime? preferredFrom, DateTime? preferredTo, int photoCount, int offerCount,@JsonKey(fromJson: idFromJsonNullable) String? myOfferId
});




}
/// @nodoc
class _$FeedItemCopyWithImpl<$Res>
    implements $FeedItemCopyWith<$Res> {
  _$FeedItemCopyWithImpl(this._self, this._then);

  final FeedItem _self;
  final $Res Function(FeedItem) _then;

/// Create a copy of FeedItem
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? publicCode = null,Object? title = null,Object? categoryId = null,Object? urgency = null,Object? districtName = null,Object? neighborhood = null,Object? createdAt = null,Object? preferredFrom = freezed,Object? preferredTo = freezed,Object? photoCount = null,Object? offerCount = null,Object? myOfferId = freezed,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,publicCode: null == publicCode ? _self.publicCode : publicCode // ignore: cast_nullable_to_non_nullable
as String,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,categoryId: null == categoryId ? _self.categoryId : categoryId // ignore: cast_nullable_to_non_nullable
as String,urgency: null == urgency ? _self.urgency : urgency // ignore: cast_nullable_to_non_nullable
as RequestUrgency,districtName: null == districtName ? _self.districtName : districtName // ignore: cast_nullable_to_non_nullable
as String,neighborhood: null == neighborhood ? _self.neighborhood : neighborhood // ignore: cast_nullable_to_non_nullable
as String,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,preferredFrom: freezed == preferredFrom ? _self.preferredFrom : preferredFrom // ignore: cast_nullable_to_non_nullable
as DateTime?,preferredTo: freezed == preferredTo ? _self.preferredTo : preferredTo // ignore: cast_nullable_to_non_nullable
as DateTime?,photoCount: null == photoCount ? _self.photoCount : photoCount // ignore: cast_nullable_to_non_nullable
as int,offerCount: null == offerCount ? _self.offerCount : offerCount // ignore: cast_nullable_to_non_nullable
as int,myOfferId: freezed == myOfferId ? _self.myOfferId : myOfferId // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [FeedItem].
extension FeedItemPatterns on FeedItem {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _FeedItem value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _FeedItem() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _FeedItem value)  $default,){
final _that = this;
switch (_that) {
case _FeedItem():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _FeedItem value)?  $default,){
final _that = this;
switch (_that) {
case _FeedItem() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function(@JsonKey(fromJson: idFromJson)  String id,  String publicCode,  String title, @JsonKey(fromJson: idFromJson)  String categoryId,  RequestUrgency urgency,  String districtName,  String neighborhood,  DateTime createdAt,  DateTime? preferredFrom,  DateTime? preferredTo,  int photoCount,  int offerCount, @JsonKey(fromJson: idFromJsonNullable)  String? myOfferId)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _FeedItem() when $default != null:
return $default(_that.id,_that.publicCode,_that.title,_that.categoryId,_that.urgency,_that.districtName,_that.neighborhood,_that.createdAt,_that.preferredFrom,_that.preferredTo,_that.photoCount,_that.offerCount,_that.myOfferId);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function(@JsonKey(fromJson: idFromJson)  String id,  String publicCode,  String title, @JsonKey(fromJson: idFromJson)  String categoryId,  RequestUrgency urgency,  String districtName,  String neighborhood,  DateTime createdAt,  DateTime? preferredFrom,  DateTime? preferredTo,  int photoCount,  int offerCount, @JsonKey(fromJson: idFromJsonNullable)  String? myOfferId)  $default,) {final _that = this;
switch (_that) {
case _FeedItem():
return $default(_that.id,_that.publicCode,_that.title,_that.categoryId,_that.urgency,_that.districtName,_that.neighborhood,_that.createdAt,_that.preferredFrom,_that.preferredTo,_that.photoCount,_that.offerCount,_that.myOfferId);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function(@JsonKey(fromJson: idFromJson)  String id,  String publicCode,  String title, @JsonKey(fromJson: idFromJson)  String categoryId,  RequestUrgency urgency,  String districtName,  String neighborhood,  DateTime createdAt,  DateTime? preferredFrom,  DateTime? preferredTo,  int photoCount,  int offerCount, @JsonKey(fromJson: idFromJsonNullable)  String? myOfferId)?  $default,) {final _that = this;
switch (_that) {
case _FeedItem() when $default != null:
return $default(_that.id,_that.publicCode,_that.title,_that.categoryId,_that.urgency,_that.districtName,_that.neighborhood,_that.createdAt,_that.preferredFrom,_that.preferredTo,_that.photoCount,_that.offerCount,_that.myOfferId);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _FeedItem implements FeedItem {
  const _FeedItem({@JsonKey(fromJson: idFromJson) required this.id, required this.publicCode, required this.title, @JsonKey(fromJson: idFromJson) required this.categoryId, required this.urgency, required this.districtName, required this.neighborhood, required this.createdAt, this.preferredFrom, this.preferredTo, this.photoCount = 0, this.offerCount = 0, @JsonKey(fromJson: idFromJsonNullable) this.myOfferId});
  factory _FeedItem.fromJson(Map<String, dynamic> json) => _$FeedItemFromJson(json);

@override@JsonKey(fromJson: idFromJson) final  String id;
@override final  String publicCode;
@override final  String title;
@override@JsonKey(fromJson: idFromJson) final  String categoryId;
@override final  RequestUrgency urgency;
@override final  String districtName;
@override final  String neighborhood;
@override final  DateTime createdAt;
@override final  DateTime? preferredFrom;
@override final  DateTime? preferredTo;
@override@JsonKey() final  int photoCount;
@override@JsonKey() final  int offerCount;
@override@JsonKey(fromJson: idFromJsonNullable) final  String? myOfferId;

/// Create a copy of FeedItem
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$FeedItemCopyWith<_FeedItem> get copyWith => __$FeedItemCopyWithImpl<_FeedItem>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$FeedItemToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _FeedItem&&(identical(other.id, id) || other.id == id)&&(identical(other.publicCode, publicCode) || other.publicCode == publicCode)&&(identical(other.title, title) || other.title == title)&&(identical(other.categoryId, categoryId) || other.categoryId == categoryId)&&(identical(other.urgency, urgency) || other.urgency == urgency)&&(identical(other.districtName, districtName) || other.districtName == districtName)&&(identical(other.neighborhood, neighborhood) || other.neighborhood == neighborhood)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.preferredFrom, preferredFrom) || other.preferredFrom == preferredFrom)&&(identical(other.preferredTo, preferredTo) || other.preferredTo == preferredTo)&&(identical(other.photoCount, photoCount) || other.photoCount == photoCount)&&(identical(other.offerCount, offerCount) || other.offerCount == offerCount)&&(identical(other.myOfferId, myOfferId) || other.myOfferId == myOfferId));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,publicCode,title,categoryId,urgency,districtName,neighborhood,createdAt,preferredFrom,preferredTo,photoCount,offerCount,myOfferId);

@override
String toString() {
  return 'FeedItem(id: $id, publicCode: $publicCode, title: $title, categoryId: $categoryId, urgency: $urgency, districtName: $districtName, neighborhood: $neighborhood, createdAt: $createdAt, preferredFrom: $preferredFrom, preferredTo: $preferredTo, photoCount: $photoCount, offerCount: $offerCount, myOfferId: $myOfferId)';
}


}

/// @nodoc
abstract mixin class _$FeedItemCopyWith<$Res> implements $FeedItemCopyWith<$Res> {
  factory _$FeedItemCopyWith(_FeedItem value, $Res Function(_FeedItem) _then) = __$FeedItemCopyWithImpl;
@override @useResult
$Res call({
@JsonKey(fromJson: idFromJson) String id, String publicCode, String title,@JsonKey(fromJson: idFromJson) String categoryId, RequestUrgency urgency, String districtName, String neighborhood, DateTime createdAt, DateTime? preferredFrom, DateTime? preferredTo, int photoCount, int offerCount,@JsonKey(fromJson: idFromJsonNullable) String? myOfferId
});




}
/// @nodoc
class __$FeedItemCopyWithImpl<$Res>
    implements _$FeedItemCopyWith<$Res> {
  __$FeedItemCopyWithImpl(this._self, this._then);

  final _FeedItem _self;
  final $Res Function(_FeedItem) _then;

/// Create a copy of FeedItem
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? publicCode = null,Object? title = null,Object? categoryId = null,Object? urgency = null,Object? districtName = null,Object? neighborhood = null,Object? createdAt = null,Object? preferredFrom = freezed,Object? preferredTo = freezed,Object? photoCount = null,Object? offerCount = null,Object? myOfferId = freezed,}) {
  return _then(_FeedItem(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,publicCode: null == publicCode ? _self.publicCode : publicCode // ignore: cast_nullable_to_non_nullable
as String,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,categoryId: null == categoryId ? _self.categoryId : categoryId // ignore: cast_nullable_to_non_nullable
as String,urgency: null == urgency ? _self.urgency : urgency // ignore: cast_nullable_to_non_nullable
as RequestUrgency,districtName: null == districtName ? _self.districtName : districtName // ignore: cast_nullable_to_non_nullable
as String,neighborhood: null == neighborhood ? _self.neighborhood : neighborhood // ignore: cast_nullable_to_non_nullable
as String,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,preferredFrom: freezed == preferredFrom ? _self.preferredFrom : preferredFrom // ignore: cast_nullable_to_non_nullable
as DateTime?,preferredTo: freezed == preferredTo ? _self.preferredTo : preferredTo // ignore: cast_nullable_to_non_nullable
as DateTime?,photoCount: null == photoCount ? _self.photoCount : photoCount // ignore: cast_nullable_to_non_nullable
as int,offerCount: null == offerCount ? _self.offerCount : offerCount // ignore: cast_nullable_to_non_nullable
as int,myOfferId: freezed == myOfferId ? _self.myOfferId : myOfferId // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}


/// @nodoc
mixin _$FeedPage {

 List<FeedItem> get items; bool get onBreak; String? get nextCursor;
/// Create a copy of FeedPage
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$FeedPageCopyWith<FeedPage> get copyWith => _$FeedPageCopyWithImpl<FeedPage>(this as FeedPage, _$identity);

  /// Serializes this FeedPage to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is FeedPage&&const DeepCollectionEquality().equals(other.items, items)&&(identical(other.onBreak, onBreak) || other.onBreak == onBreak)&&(identical(other.nextCursor, nextCursor) || other.nextCursor == nextCursor));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(items),onBreak,nextCursor);

@override
String toString() {
  return 'FeedPage(items: $items, onBreak: $onBreak, nextCursor: $nextCursor)';
}


}

/// @nodoc
abstract mixin class $FeedPageCopyWith<$Res>  {
  factory $FeedPageCopyWith(FeedPage value, $Res Function(FeedPage) _then) = _$FeedPageCopyWithImpl;
@useResult
$Res call({
 List<FeedItem> items, bool onBreak, String? nextCursor
});




}
/// @nodoc
class _$FeedPageCopyWithImpl<$Res>
    implements $FeedPageCopyWith<$Res> {
  _$FeedPageCopyWithImpl(this._self, this._then);

  final FeedPage _self;
  final $Res Function(FeedPage) _then;

/// Create a copy of FeedPage
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? items = null,Object? onBreak = null,Object? nextCursor = freezed,}) {
  return _then(_self.copyWith(
items: null == items ? _self.items : items // ignore: cast_nullable_to_non_nullable
as List<FeedItem>,onBreak: null == onBreak ? _self.onBreak : onBreak // ignore: cast_nullable_to_non_nullable
as bool,nextCursor: freezed == nextCursor ? _self.nextCursor : nextCursor // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [FeedPage].
extension FeedPagePatterns on FeedPage {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _FeedPage value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _FeedPage() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _FeedPage value)  $default,){
final _that = this;
switch (_that) {
case _FeedPage():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _FeedPage value)?  $default,){
final _that = this;
switch (_that) {
case _FeedPage() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( List<FeedItem> items,  bool onBreak,  String? nextCursor)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _FeedPage() when $default != null:
return $default(_that.items,_that.onBreak,_that.nextCursor);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( List<FeedItem> items,  bool onBreak,  String? nextCursor)  $default,) {final _that = this;
switch (_that) {
case _FeedPage():
return $default(_that.items,_that.onBreak,_that.nextCursor);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( List<FeedItem> items,  bool onBreak,  String? nextCursor)?  $default,) {final _that = this;
switch (_that) {
case _FeedPage() when $default != null:
return $default(_that.items,_that.onBreak,_that.nextCursor);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _FeedPage implements FeedPage {
  const _FeedPage({this.items = const <FeedItem>[], this.onBreak = false, this.nextCursor});
  factory _FeedPage.fromJson(Map<String, dynamic> json) => _$FeedPageFromJson(json);

@override@JsonKey() final  List<FeedItem> items;
@override@JsonKey() final  bool onBreak;
@override final  String? nextCursor;

/// Create a copy of FeedPage
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$FeedPageCopyWith<_FeedPage> get copyWith => __$FeedPageCopyWithImpl<_FeedPage>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$FeedPageToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _FeedPage&&const DeepCollectionEquality().equals(other.items, items)&&(identical(other.onBreak, onBreak) || other.onBreak == onBreak)&&(identical(other.nextCursor, nextCursor) || other.nextCursor == nextCursor));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(items),onBreak,nextCursor);

@override
String toString() {
  return 'FeedPage(items: $items, onBreak: $onBreak, nextCursor: $nextCursor)';
}


}

/// @nodoc
abstract mixin class _$FeedPageCopyWith<$Res> implements $FeedPageCopyWith<$Res> {
  factory _$FeedPageCopyWith(_FeedPage value, $Res Function(_FeedPage) _then) = __$FeedPageCopyWithImpl;
@override @useResult
$Res call({
 List<FeedItem> items, bool onBreak, String? nextCursor
});




}
/// @nodoc
class __$FeedPageCopyWithImpl<$Res>
    implements _$FeedPageCopyWith<$Res> {
  __$FeedPageCopyWithImpl(this._self, this._then);

  final _FeedPage _self;
  final $Res Function(_FeedPage) _then;

/// Create a copy of FeedPage
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? items = null,Object? onBreak = null,Object? nextCursor = freezed,}) {
  return _then(_FeedPage(
items: null == items ? _self.items : items // ignore: cast_nullable_to_non_nullable
as List<FeedItem>,onBreak: null == onBreak ? _self.onBreak : onBreak // ignore: cast_nullable_to_non_nullable
as bool,nextCursor: freezed == nextCursor ? _self.nextCursor : nextCursor // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}


/// @nodoc
mixin _$ProRequestDetail {

@JsonKey(fromJson: idFromJson) String get id; String get publicCode; String get title;@JsonKey(fromJson: idFromJson) String get categoryId; RequestUrgency get urgency; String get districtName; String get neighborhood; DateTime get createdAt; DateTime? get preferredFrom; DateTime? get preferredTo; int get photoCount; int get offerCount;@JsonKey(fromJson: idFromJsonNullable) String? get myOfferId; String get description; List<MediaRef> get photos; List<RequestAnswer> get answers; OfferDetail? get myOffer;
/// Create a copy of ProRequestDetail
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ProRequestDetailCopyWith<ProRequestDetail> get copyWith => _$ProRequestDetailCopyWithImpl<ProRequestDetail>(this as ProRequestDetail, _$identity);

  /// Serializes this ProRequestDetail to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ProRequestDetail&&(identical(other.id, id) || other.id == id)&&(identical(other.publicCode, publicCode) || other.publicCode == publicCode)&&(identical(other.title, title) || other.title == title)&&(identical(other.categoryId, categoryId) || other.categoryId == categoryId)&&(identical(other.urgency, urgency) || other.urgency == urgency)&&(identical(other.districtName, districtName) || other.districtName == districtName)&&(identical(other.neighborhood, neighborhood) || other.neighborhood == neighborhood)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.preferredFrom, preferredFrom) || other.preferredFrom == preferredFrom)&&(identical(other.preferredTo, preferredTo) || other.preferredTo == preferredTo)&&(identical(other.photoCount, photoCount) || other.photoCount == photoCount)&&(identical(other.offerCount, offerCount) || other.offerCount == offerCount)&&(identical(other.myOfferId, myOfferId) || other.myOfferId == myOfferId)&&(identical(other.description, description) || other.description == description)&&const DeepCollectionEquality().equals(other.photos, photos)&&const DeepCollectionEquality().equals(other.answers, answers)&&(identical(other.myOffer, myOffer) || other.myOffer == myOffer));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,publicCode,title,categoryId,urgency,districtName,neighborhood,createdAt,preferredFrom,preferredTo,photoCount,offerCount,myOfferId,description,const DeepCollectionEquality().hash(photos),const DeepCollectionEquality().hash(answers),myOffer);

@override
String toString() {
  return 'ProRequestDetail(id: $id, publicCode: $publicCode, title: $title, categoryId: $categoryId, urgency: $urgency, districtName: $districtName, neighborhood: $neighborhood, createdAt: $createdAt, preferredFrom: $preferredFrom, preferredTo: $preferredTo, photoCount: $photoCount, offerCount: $offerCount, myOfferId: $myOfferId, description: $description, photos: $photos, answers: $answers, myOffer: $myOffer)';
}


}

/// @nodoc
abstract mixin class $ProRequestDetailCopyWith<$Res>  {
  factory $ProRequestDetailCopyWith(ProRequestDetail value, $Res Function(ProRequestDetail) _then) = _$ProRequestDetailCopyWithImpl;
@useResult
$Res call({
@JsonKey(fromJson: idFromJson) String id, String publicCode, String title,@JsonKey(fromJson: idFromJson) String categoryId, RequestUrgency urgency, String districtName, String neighborhood, DateTime createdAt, DateTime? preferredFrom, DateTime? preferredTo, int photoCount, int offerCount,@JsonKey(fromJson: idFromJsonNullable) String? myOfferId, String description, List<MediaRef> photos, List<RequestAnswer> answers, OfferDetail? myOffer
});


$OfferDetailCopyWith<$Res>? get myOffer;

}
/// @nodoc
class _$ProRequestDetailCopyWithImpl<$Res>
    implements $ProRequestDetailCopyWith<$Res> {
  _$ProRequestDetailCopyWithImpl(this._self, this._then);

  final ProRequestDetail _self;
  final $Res Function(ProRequestDetail) _then;

/// Create a copy of ProRequestDetail
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? publicCode = null,Object? title = null,Object? categoryId = null,Object? urgency = null,Object? districtName = null,Object? neighborhood = null,Object? createdAt = null,Object? preferredFrom = freezed,Object? preferredTo = freezed,Object? photoCount = null,Object? offerCount = null,Object? myOfferId = freezed,Object? description = null,Object? photos = null,Object? answers = null,Object? myOffer = freezed,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,publicCode: null == publicCode ? _self.publicCode : publicCode // ignore: cast_nullable_to_non_nullable
as String,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,categoryId: null == categoryId ? _self.categoryId : categoryId // ignore: cast_nullable_to_non_nullable
as String,urgency: null == urgency ? _self.urgency : urgency // ignore: cast_nullable_to_non_nullable
as RequestUrgency,districtName: null == districtName ? _self.districtName : districtName // ignore: cast_nullable_to_non_nullable
as String,neighborhood: null == neighborhood ? _self.neighborhood : neighborhood // ignore: cast_nullable_to_non_nullable
as String,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,preferredFrom: freezed == preferredFrom ? _self.preferredFrom : preferredFrom // ignore: cast_nullable_to_non_nullable
as DateTime?,preferredTo: freezed == preferredTo ? _self.preferredTo : preferredTo // ignore: cast_nullable_to_non_nullable
as DateTime?,photoCount: null == photoCount ? _self.photoCount : photoCount // ignore: cast_nullable_to_non_nullable
as int,offerCount: null == offerCount ? _self.offerCount : offerCount // ignore: cast_nullable_to_non_nullable
as int,myOfferId: freezed == myOfferId ? _self.myOfferId : myOfferId // ignore: cast_nullable_to_non_nullable
as String?,description: null == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String,photos: null == photos ? _self.photos : photos // ignore: cast_nullable_to_non_nullable
as List<MediaRef>,answers: null == answers ? _self.answers : answers // ignore: cast_nullable_to_non_nullable
as List<RequestAnswer>,myOffer: freezed == myOffer ? _self.myOffer : myOffer // ignore: cast_nullable_to_non_nullable
as OfferDetail?,
  ));
}
/// Create a copy of ProRequestDetail
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$OfferDetailCopyWith<$Res>? get myOffer {
    if (_self.myOffer == null) {
    return null;
  }

  return $OfferDetailCopyWith<$Res>(_self.myOffer!, (value) {
    return _then(_self.copyWith(myOffer: value));
  });
}
}


/// Adds pattern-matching-related methods to [ProRequestDetail].
extension ProRequestDetailPatterns on ProRequestDetail {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ProRequestDetail value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ProRequestDetail() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ProRequestDetail value)  $default,){
final _that = this;
switch (_that) {
case _ProRequestDetail():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ProRequestDetail value)?  $default,){
final _that = this;
switch (_that) {
case _ProRequestDetail() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function(@JsonKey(fromJson: idFromJson)  String id,  String publicCode,  String title, @JsonKey(fromJson: idFromJson)  String categoryId,  RequestUrgency urgency,  String districtName,  String neighborhood,  DateTime createdAt,  DateTime? preferredFrom,  DateTime? preferredTo,  int photoCount,  int offerCount, @JsonKey(fromJson: idFromJsonNullable)  String? myOfferId,  String description,  List<MediaRef> photos,  List<RequestAnswer> answers,  OfferDetail? myOffer)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ProRequestDetail() when $default != null:
return $default(_that.id,_that.publicCode,_that.title,_that.categoryId,_that.urgency,_that.districtName,_that.neighborhood,_that.createdAt,_that.preferredFrom,_that.preferredTo,_that.photoCount,_that.offerCount,_that.myOfferId,_that.description,_that.photos,_that.answers,_that.myOffer);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function(@JsonKey(fromJson: idFromJson)  String id,  String publicCode,  String title, @JsonKey(fromJson: idFromJson)  String categoryId,  RequestUrgency urgency,  String districtName,  String neighborhood,  DateTime createdAt,  DateTime? preferredFrom,  DateTime? preferredTo,  int photoCount,  int offerCount, @JsonKey(fromJson: idFromJsonNullable)  String? myOfferId,  String description,  List<MediaRef> photos,  List<RequestAnswer> answers,  OfferDetail? myOffer)  $default,) {final _that = this;
switch (_that) {
case _ProRequestDetail():
return $default(_that.id,_that.publicCode,_that.title,_that.categoryId,_that.urgency,_that.districtName,_that.neighborhood,_that.createdAt,_that.preferredFrom,_that.preferredTo,_that.photoCount,_that.offerCount,_that.myOfferId,_that.description,_that.photos,_that.answers,_that.myOffer);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function(@JsonKey(fromJson: idFromJson)  String id,  String publicCode,  String title, @JsonKey(fromJson: idFromJson)  String categoryId,  RequestUrgency urgency,  String districtName,  String neighborhood,  DateTime createdAt,  DateTime? preferredFrom,  DateTime? preferredTo,  int photoCount,  int offerCount, @JsonKey(fromJson: idFromJsonNullable)  String? myOfferId,  String description,  List<MediaRef> photos,  List<RequestAnswer> answers,  OfferDetail? myOffer)?  $default,) {final _that = this;
switch (_that) {
case _ProRequestDetail() when $default != null:
return $default(_that.id,_that.publicCode,_that.title,_that.categoryId,_that.urgency,_that.districtName,_that.neighborhood,_that.createdAt,_that.preferredFrom,_that.preferredTo,_that.photoCount,_that.offerCount,_that.myOfferId,_that.description,_that.photos,_that.answers,_that.myOffer);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _ProRequestDetail implements ProRequestDetail {
  const _ProRequestDetail({@JsonKey(fromJson: idFromJson) required this.id, required this.publicCode, required this.title, @JsonKey(fromJson: idFromJson) required this.categoryId, required this.urgency, required this.districtName, required this.neighborhood, required this.createdAt, this.preferredFrom, this.preferredTo, this.photoCount = 0, this.offerCount = 0, @JsonKey(fromJson: idFromJsonNullable) this.myOfferId, required this.description, this.photos = const <MediaRef>[], this.answers = const <RequestAnswer>[], this.myOffer});
  factory _ProRequestDetail.fromJson(Map<String, dynamic> json) => _$ProRequestDetailFromJson(json);

@override@JsonKey(fromJson: idFromJson) final  String id;
@override final  String publicCode;
@override final  String title;
@override@JsonKey(fromJson: idFromJson) final  String categoryId;
@override final  RequestUrgency urgency;
@override final  String districtName;
@override final  String neighborhood;
@override final  DateTime createdAt;
@override final  DateTime? preferredFrom;
@override final  DateTime? preferredTo;
@override@JsonKey() final  int photoCount;
@override@JsonKey() final  int offerCount;
@override@JsonKey(fromJson: idFromJsonNullable) final  String? myOfferId;
@override final  String description;
@override@JsonKey() final  List<MediaRef> photos;
@override@JsonKey() final  List<RequestAnswer> answers;
@override final  OfferDetail? myOffer;

/// Create a copy of ProRequestDetail
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ProRequestDetailCopyWith<_ProRequestDetail> get copyWith => __$ProRequestDetailCopyWithImpl<_ProRequestDetail>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ProRequestDetailToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ProRequestDetail&&(identical(other.id, id) || other.id == id)&&(identical(other.publicCode, publicCode) || other.publicCode == publicCode)&&(identical(other.title, title) || other.title == title)&&(identical(other.categoryId, categoryId) || other.categoryId == categoryId)&&(identical(other.urgency, urgency) || other.urgency == urgency)&&(identical(other.districtName, districtName) || other.districtName == districtName)&&(identical(other.neighborhood, neighborhood) || other.neighborhood == neighborhood)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.preferredFrom, preferredFrom) || other.preferredFrom == preferredFrom)&&(identical(other.preferredTo, preferredTo) || other.preferredTo == preferredTo)&&(identical(other.photoCount, photoCount) || other.photoCount == photoCount)&&(identical(other.offerCount, offerCount) || other.offerCount == offerCount)&&(identical(other.myOfferId, myOfferId) || other.myOfferId == myOfferId)&&(identical(other.description, description) || other.description == description)&&const DeepCollectionEquality().equals(other.photos, photos)&&const DeepCollectionEquality().equals(other.answers, answers)&&(identical(other.myOffer, myOffer) || other.myOffer == myOffer));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,publicCode,title,categoryId,urgency,districtName,neighborhood,createdAt,preferredFrom,preferredTo,photoCount,offerCount,myOfferId,description,const DeepCollectionEquality().hash(photos),const DeepCollectionEquality().hash(answers),myOffer);

@override
String toString() {
  return 'ProRequestDetail(id: $id, publicCode: $publicCode, title: $title, categoryId: $categoryId, urgency: $urgency, districtName: $districtName, neighborhood: $neighborhood, createdAt: $createdAt, preferredFrom: $preferredFrom, preferredTo: $preferredTo, photoCount: $photoCount, offerCount: $offerCount, myOfferId: $myOfferId, description: $description, photos: $photos, answers: $answers, myOffer: $myOffer)';
}


}

/// @nodoc
abstract mixin class _$ProRequestDetailCopyWith<$Res> implements $ProRequestDetailCopyWith<$Res> {
  factory _$ProRequestDetailCopyWith(_ProRequestDetail value, $Res Function(_ProRequestDetail) _then) = __$ProRequestDetailCopyWithImpl;
@override @useResult
$Res call({
@JsonKey(fromJson: idFromJson) String id, String publicCode, String title,@JsonKey(fromJson: idFromJson) String categoryId, RequestUrgency urgency, String districtName, String neighborhood, DateTime createdAt, DateTime? preferredFrom, DateTime? preferredTo, int photoCount, int offerCount,@JsonKey(fromJson: idFromJsonNullable) String? myOfferId, String description, List<MediaRef> photos, List<RequestAnswer> answers, OfferDetail? myOffer
});


@override $OfferDetailCopyWith<$Res>? get myOffer;

}
/// @nodoc
class __$ProRequestDetailCopyWithImpl<$Res>
    implements _$ProRequestDetailCopyWith<$Res> {
  __$ProRequestDetailCopyWithImpl(this._self, this._then);

  final _ProRequestDetail _self;
  final $Res Function(_ProRequestDetail) _then;

/// Create a copy of ProRequestDetail
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? publicCode = null,Object? title = null,Object? categoryId = null,Object? urgency = null,Object? districtName = null,Object? neighborhood = null,Object? createdAt = null,Object? preferredFrom = freezed,Object? preferredTo = freezed,Object? photoCount = null,Object? offerCount = null,Object? myOfferId = freezed,Object? description = null,Object? photos = null,Object? answers = null,Object? myOffer = freezed,}) {
  return _then(_ProRequestDetail(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,publicCode: null == publicCode ? _self.publicCode : publicCode // ignore: cast_nullable_to_non_nullable
as String,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,categoryId: null == categoryId ? _self.categoryId : categoryId // ignore: cast_nullable_to_non_nullable
as String,urgency: null == urgency ? _self.urgency : urgency // ignore: cast_nullable_to_non_nullable
as RequestUrgency,districtName: null == districtName ? _self.districtName : districtName // ignore: cast_nullable_to_non_nullable
as String,neighborhood: null == neighborhood ? _self.neighborhood : neighborhood // ignore: cast_nullable_to_non_nullable
as String,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,preferredFrom: freezed == preferredFrom ? _self.preferredFrom : preferredFrom // ignore: cast_nullable_to_non_nullable
as DateTime?,preferredTo: freezed == preferredTo ? _self.preferredTo : preferredTo // ignore: cast_nullable_to_non_nullable
as DateTime?,photoCount: null == photoCount ? _self.photoCount : photoCount // ignore: cast_nullable_to_non_nullable
as int,offerCount: null == offerCount ? _self.offerCount : offerCount // ignore: cast_nullable_to_non_nullable
as int,myOfferId: freezed == myOfferId ? _self.myOfferId : myOfferId // ignore: cast_nullable_to_non_nullable
as String?,description: null == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String,photos: null == photos ? _self.photos : photos // ignore: cast_nullable_to_non_nullable
as List<MediaRef>,answers: null == answers ? _self.answers : answers // ignore: cast_nullable_to_non_nullable
as List<RequestAnswer>,myOffer: freezed == myOffer ? _self.myOffer : myOffer // ignore: cast_nullable_to_non_nullable
as OfferDetail?,
  ));
}

/// Create a copy of ProRequestDetail
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$OfferDetailCopyWith<$Res>? get myOffer {
    if (_self.myOffer == null) {
    return null;
  }

  return $OfferDetailCopyWith<$Res>(_self.myOffer!, (value) {
    return _then(_self.copyWith(myOffer: value));
  });
}
}


/// @nodoc
mixin _$ApplicationDocument {

@JsonKey(fromJson: idFromJson) String get id; ProDocumentType get type; DocumentStatus get status; MediaRef get media;
/// Create a copy of ApplicationDocument
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ApplicationDocumentCopyWith<ApplicationDocument> get copyWith => _$ApplicationDocumentCopyWithImpl<ApplicationDocument>(this as ApplicationDocument, _$identity);

  /// Serializes this ApplicationDocument to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ApplicationDocument&&(identical(other.id, id) || other.id == id)&&(identical(other.type, type) || other.type == type)&&(identical(other.status, status) || other.status == status)&&(identical(other.media, media) || other.media == media));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,type,status,media);

@override
String toString() {
  return 'ApplicationDocument(id: $id, type: $type, status: $status, media: $media)';
}


}

/// @nodoc
abstract mixin class $ApplicationDocumentCopyWith<$Res>  {
  factory $ApplicationDocumentCopyWith(ApplicationDocument value, $Res Function(ApplicationDocument) _then) = _$ApplicationDocumentCopyWithImpl;
@useResult
$Res call({
@JsonKey(fromJson: idFromJson) String id, ProDocumentType type, DocumentStatus status, MediaRef media
});


$MediaRefCopyWith<$Res> get media;

}
/// @nodoc
class _$ApplicationDocumentCopyWithImpl<$Res>
    implements $ApplicationDocumentCopyWith<$Res> {
  _$ApplicationDocumentCopyWithImpl(this._self, this._then);

  final ApplicationDocument _self;
  final $Res Function(ApplicationDocument) _then;

/// Create a copy of ApplicationDocument
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? type = null,Object? status = null,Object? media = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,type: null == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as ProDocumentType,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as DocumentStatus,media: null == media ? _self.media : media // ignore: cast_nullable_to_non_nullable
as MediaRef,
  ));
}
/// Create a copy of ApplicationDocument
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$MediaRefCopyWith<$Res> get media {
  
  return $MediaRefCopyWith<$Res>(_self.media, (value) {
    return _then(_self.copyWith(media: value));
  });
}
}


/// Adds pattern-matching-related methods to [ApplicationDocument].
extension ApplicationDocumentPatterns on ApplicationDocument {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ApplicationDocument value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ApplicationDocument() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ApplicationDocument value)  $default,){
final _that = this;
switch (_that) {
case _ApplicationDocument():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ApplicationDocument value)?  $default,){
final _that = this;
switch (_that) {
case _ApplicationDocument() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function(@JsonKey(fromJson: idFromJson)  String id,  ProDocumentType type,  DocumentStatus status,  MediaRef media)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ApplicationDocument() when $default != null:
return $default(_that.id,_that.type,_that.status,_that.media);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function(@JsonKey(fromJson: idFromJson)  String id,  ProDocumentType type,  DocumentStatus status,  MediaRef media)  $default,) {final _that = this;
switch (_that) {
case _ApplicationDocument():
return $default(_that.id,_that.type,_that.status,_that.media);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function(@JsonKey(fromJson: idFromJson)  String id,  ProDocumentType type,  DocumentStatus status,  MediaRef media)?  $default,) {final _that = this;
switch (_that) {
case _ApplicationDocument() when $default != null:
return $default(_that.id,_that.type,_that.status,_that.media);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _ApplicationDocument implements ApplicationDocument {
  const _ApplicationDocument({@JsonKey(fromJson: idFromJson) required this.id, required this.type, required this.status, required this.media});
  factory _ApplicationDocument.fromJson(Map<String, dynamic> json) => _$ApplicationDocumentFromJson(json);

@override@JsonKey(fromJson: idFromJson) final  String id;
@override final  ProDocumentType type;
@override final  DocumentStatus status;
@override final  MediaRef media;

/// Create a copy of ApplicationDocument
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ApplicationDocumentCopyWith<_ApplicationDocument> get copyWith => __$ApplicationDocumentCopyWithImpl<_ApplicationDocument>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ApplicationDocumentToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ApplicationDocument&&(identical(other.id, id) || other.id == id)&&(identical(other.type, type) || other.type == type)&&(identical(other.status, status) || other.status == status)&&(identical(other.media, media) || other.media == media));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,type,status,media);

@override
String toString() {
  return 'ApplicationDocument(id: $id, type: $type, status: $status, media: $media)';
}


}

/// @nodoc
abstract mixin class _$ApplicationDocumentCopyWith<$Res> implements $ApplicationDocumentCopyWith<$Res> {
  factory _$ApplicationDocumentCopyWith(_ApplicationDocument value, $Res Function(_ApplicationDocument) _then) = __$ApplicationDocumentCopyWithImpl;
@override @useResult
$Res call({
@JsonKey(fromJson: idFromJson) String id, ProDocumentType type, DocumentStatus status, MediaRef media
});


@override $MediaRefCopyWith<$Res> get media;

}
/// @nodoc
class __$ApplicationDocumentCopyWithImpl<$Res>
    implements _$ApplicationDocumentCopyWith<$Res> {
  __$ApplicationDocumentCopyWithImpl(this._self, this._then);

  final _ApplicationDocument _self;
  final $Res Function(_ApplicationDocument) _then;

/// Create a copy of ApplicationDocument
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? type = null,Object? status = null,Object? media = null,}) {
  return _then(_ApplicationDocument(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,type: null == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as ProDocumentType,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as DocumentStatus,media: null == media ? _self.media : media // ignore: cast_nullable_to_non_nullable
as MediaRef,
  ));
}

/// Create a copy of ApplicationDocument
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$MediaRefCopyWith<$Res> get media {
  
  return $MediaRefCopyWith<$Res>(_self.media, (value) {
    return _then(_self.copyWith(media: value));
  });
}
}


/// @nodoc
mixin _$ProApplication {

 ReviewStatus get reviewStatus; String? get reviewNote; String get businessName; String get bio; int get experienceYears;@JsonKey(fromJson: idListFromJson, toJson: idListToJson) List<String> get categoryIds;@JsonKey(fromJson: idListFromJson, toJson: idListToJson) List<String> get districtIds; List<ApplicationDocument> get documents; DateTime? get submittedAt;
/// Create a copy of ProApplication
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ProApplicationCopyWith<ProApplication> get copyWith => _$ProApplicationCopyWithImpl<ProApplication>(this as ProApplication, _$identity);

  /// Serializes this ProApplication to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ProApplication&&(identical(other.reviewStatus, reviewStatus) || other.reviewStatus == reviewStatus)&&(identical(other.reviewNote, reviewNote) || other.reviewNote == reviewNote)&&(identical(other.businessName, businessName) || other.businessName == businessName)&&(identical(other.bio, bio) || other.bio == bio)&&(identical(other.experienceYears, experienceYears) || other.experienceYears == experienceYears)&&const DeepCollectionEquality().equals(other.categoryIds, categoryIds)&&const DeepCollectionEquality().equals(other.districtIds, districtIds)&&const DeepCollectionEquality().equals(other.documents, documents)&&(identical(other.submittedAt, submittedAt) || other.submittedAt == submittedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,reviewStatus,reviewNote,businessName,bio,experienceYears,const DeepCollectionEquality().hash(categoryIds),const DeepCollectionEquality().hash(districtIds),const DeepCollectionEquality().hash(documents),submittedAt);

@override
String toString() {
  return 'ProApplication(reviewStatus: $reviewStatus, reviewNote: $reviewNote, businessName: $businessName, bio: $bio, experienceYears: $experienceYears, categoryIds: $categoryIds, districtIds: $districtIds, documents: $documents, submittedAt: $submittedAt)';
}


}

/// @nodoc
abstract mixin class $ProApplicationCopyWith<$Res>  {
  factory $ProApplicationCopyWith(ProApplication value, $Res Function(ProApplication) _then) = _$ProApplicationCopyWithImpl;
@useResult
$Res call({
 ReviewStatus reviewStatus, String? reviewNote, String businessName, String bio, int experienceYears,@JsonKey(fromJson: idListFromJson, toJson: idListToJson) List<String> categoryIds,@JsonKey(fromJson: idListFromJson, toJson: idListToJson) List<String> districtIds, List<ApplicationDocument> documents, DateTime? submittedAt
});




}
/// @nodoc
class _$ProApplicationCopyWithImpl<$Res>
    implements $ProApplicationCopyWith<$Res> {
  _$ProApplicationCopyWithImpl(this._self, this._then);

  final ProApplication _self;
  final $Res Function(ProApplication) _then;

/// Create a copy of ProApplication
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? reviewStatus = null,Object? reviewNote = freezed,Object? businessName = null,Object? bio = null,Object? experienceYears = null,Object? categoryIds = null,Object? districtIds = null,Object? documents = null,Object? submittedAt = freezed,}) {
  return _then(_self.copyWith(
reviewStatus: null == reviewStatus ? _self.reviewStatus : reviewStatus // ignore: cast_nullable_to_non_nullable
as ReviewStatus,reviewNote: freezed == reviewNote ? _self.reviewNote : reviewNote // ignore: cast_nullable_to_non_nullable
as String?,businessName: null == businessName ? _self.businessName : businessName // ignore: cast_nullable_to_non_nullable
as String,bio: null == bio ? _self.bio : bio // ignore: cast_nullable_to_non_nullable
as String,experienceYears: null == experienceYears ? _self.experienceYears : experienceYears // ignore: cast_nullable_to_non_nullable
as int,categoryIds: null == categoryIds ? _self.categoryIds : categoryIds // ignore: cast_nullable_to_non_nullable
as List<String>,districtIds: null == districtIds ? _self.districtIds : districtIds // ignore: cast_nullable_to_non_nullable
as List<String>,documents: null == documents ? _self.documents : documents // ignore: cast_nullable_to_non_nullable
as List<ApplicationDocument>,submittedAt: freezed == submittedAt ? _self.submittedAt : submittedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}

}


/// Adds pattern-matching-related methods to [ProApplication].
extension ProApplicationPatterns on ProApplication {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ProApplication value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ProApplication() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ProApplication value)  $default,){
final _that = this;
switch (_that) {
case _ProApplication():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ProApplication value)?  $default,){
final _that = this;
switch (_that) {
case _ProApplication() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( ReviewStatus reviewStatus,  String? reviewNote,  String businessName,  String bio,  int experienceYears, @JsonKey(fromJson: idListFromJson, toJson: idListToJson)  List<String> categoryIds, @JsonKey(fromJson: idListFromJson, toJson: idListToJson)  List<String> districtIds,  List<ApplicationDocument> documents,  DateTime? submittedAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ProApplication() when $default != null:
return $default(_that.reviewStatus,_that.reviewNote,_that.businessName,_that.bio,_that.experienceYears,_that.categoryIds,_that.districtIds,_that.documents,_that.submittedAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( ReviewStatus reviewStatus,  String? reviewNote,  String businessName,  String bio,  int experienceYears, @JsonKey(fromJson: idListFromJson, toJson: idListToJson)  List<String> categoryIds, @JsonKey(fromJson: idListFromJson, toJson: idListToJson)  List<String> districtIds,  List<ApplicationDocument> documents,  DateTime? submittedAt)  $default,) {final _that = this;
switch (_that) {
case _ProApplication():
return $default(_that.reviewStatus,_that.reviewNote,_that.businessName,_that.bio,_that.experienceYears,_that.categoryIds,_that.districtIds,_that.documents,_that.submittedAt);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( ReviewStatus reviewStatus,  String? reviewNote,  String businessName,  String bio,  int experienceYears, @JsonKey(fromJson: idListFromJson, toJson: idListToJson)  List<String> categoryIds, @JsonKey(fromJson: idListFromJson, toJson: idListToJson)  List<String> districtIds,  List<ApplicationDocument> documents,  DateTime? submittedAt)?  $default,) {final _that = this;
switch (_that) {
case _ProApplication() when $default != null:
return $default(_that.reviewStatus,_that.reviewNote,_that.businessName,_that.bio,_that.experienceYears,_that.categoryIds,_that.districtIds,_that.documents,_that.submittedAt);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _ProApplication implements ProApplication {
  const _ProApplication({required this.reviewStatus, this.reviewNote, required this.businessName, this.bio = '', this.experienceYears = 0, @JsonKey(fromJson: idListFromJson, toJson: idListToJson) this.categoryIds = const <String>[], @JsonKey(fromJson: idListFromJson, toJson: idListToJson) this.districtIds = const <String>[], this.documents = const <ApplicationDocument>[], this.submittedAt});
  factory _ProApplication.fromJson(Map<String, dynamic> json) => _$ProApplicationFromJson(json);

@override final  ReviewStatus reviewStatus;
@override final  String? reviewNote;
@override final  String businessName;
@override@JsonKey() final  String bio;
@override@JsonKey() final  int experienceYears;
@override@JsonKey(fromJson: idListFromJson, toJson: idListToJson) final  List<String> categoryIds;
@override@JsonKey(fromJson: idListFromJson, toJson: idListToJson) final  List<String> districtIds;
@override@JsonKey() final  List<ApplicationDocument> documents;
@override final  DateTime? submittedAt;

/// Create a copy of ProApplication
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ProApplicationCopyWith<_ProApplication> get copyWith => __$ProApplicationCopyWithImpl<_ProApplication>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ProApplicationToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ProApplication&&(identical(other.reviewStatus, reviewStatus) || other.reviewStatus == reviewStatus)&&(identical(other.reviewNote, reviewNote) || other.reviewNote == reviewNote)&&(identical(other.businessName, businessName) || other.businessName == businessName)&&(identical(other.bio, bio) || other.bio == bio)&&(identical(other.experienceYears, experienceYears) || other.experienceYears == experienceYears)&&const DeepCollectionEquality().equals(other.categoryIds, categoryIds)&&const DeepCollectionEquality().equals(other.districtIds, districtIds)&&const DeepCollectionEquality().equals(other.documents, documents)&&(identical(other.submittedAt, submittedAt) || other.submittedAt == submittedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,reviewStatus,reviewNote,businessName,bio,experienceYears,const DeepCollectionEquality().hash(categoryIds),const DeepCollectionEquality().hash(districtIds),const DeepCollectionEquality().hash(documents),submittedAt);

@override
String toString() {
  return 'ProApplication(reviewStatus: $reviewStatus, reviewNote: $reviewNote, businessName: $businessName, bio: $bio, experienceYears: $experienceYears, categoryIds: $categoryIds, districtIds: $districtIds, documents: $documents, submittedAt: $submittedAt)';
}


}

/// @nodoc
abstract mixin class _$ProApplicationCopyWith<$Res> implements $ProApplicationCopyWith<$Res> {
  factory _$ProApplicationCopyWith(_ProApplication value, $Res Function(_ProApplication) _then) = __$ProApplicationCopyWithImpl;
@override @useResult
$Res call({
 ReviewStatus reviewStatus, String? reviewNote, String businessName, String bio, int experienceYears,@JsonKey(fromJson: idListFromJson, toJson: idListToJson) List<String> categoryIds,@JsonKey(fromJson: idListFromJson, toJson: idListToJson) List<String> districtIds, List<ApplicationDocument> documents, DateTime? submittedAt
});




}
/// @nodoc
class __$ProApplicationCopyWithImpl<$Res>
    implements _$ProApplicationCopyWith<$Res> {
  __$ProApplicationCopyWithImpl(this._self, this._then);

  final _ProApplication _self;
  final $Res Function(_ProApplication) _then;

/// Create a copy of ProApplication
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? reviewStatus = null,Object? reviewNote = freezed,Object? businessName = null,Object? bio = null,Object? experienceYears = null,Object? categoryIds = null,Object? districtIds = null,Object? documents = null,Object? submittedAt = freezed,}) {
  return _then(_ProApplication(
reviewStatus: null == reviewStatus ? _self.reviewStatus : reviewStatus // ignore: cast_nullable_to_non_nullable
as ReviewStatus,reviewNote: freezed == reviewNote ? _self.reviewNote : reviewNote // ignore: cast_nullable_to_non_nullable
as String?,businessName: null == businessName ? _self.businessName : businessName // ignore: cast_nullable_to_non_nullable
as String,bio: null == bio ? _self.bio : bio // ignore: cast_nullable_to_non_nullable
as String,experienceYears: null == experienceYears ? _self.experienceYears : experienceYears // ignore: cast_nullable_to_non_nullable
as int,categoryIds: null == categoryIds ? _self.categoryIds : categoryIds // ignore: cast_nullable_to_non_nullable
as List<String>,districtIds: null == districtIds ? _self.districtIds : districtIds // ignore: cast_nullable_to_non_nullable
as List<String>,documents: null == documents ? _self.documents : documents // ignore: cast_nullable_to_non_nullable
as List<ApplicationDocument>,submittedAt: freezed == submittedAt ? _self.submittedAt : submittedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}


}


/// @nodoc
mixin _$DocumentInput {

 ProDocumentType get type;@JsonKey(fromJson: idFromJson, toJson: wireId) String get mediaId;
/// Create a copy of DocumentInput
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$DocumentInputCopyWith<DocumentInput> get copyWith => _$DocumentInputCopyWithImpl<DocumentInput>(this as DocumentInput, _$identity);

  /// Serializes this DocumentInput to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is DocumentInput&&(identical(other.type, type) || other.type == type)&&(identical(other.mediaId, mediaId) || other.mediaId == mediaId));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,type,mediaId);

@override
String toString() {
  return 'DocumentInput(type: $type, mediaId: $mediaId)';
}


}

/// @nodoc
abstract mixin class $DocumentInputCopyWith<$Res>  {
  factory $DocumentInputCopyWith(DocumentInput value, $Res Function(DocumentInput) _then) = _$DocumentInputCopyWithImpl;
@useResult
$Res call({
 ProDocumentType type,@JsonKey(fromJson: idFromJson, toJson: wireId) String mediaId
});




}
/// @nodoc
class _$DocumentInputCopyWithImpl<$Res>
    implements $DocumentInputCopyWith<$Res> {
  _$DocumentInputCopyWithImpl(this._self, this._then);

  final DocumentInput _self;
  final $Res Function(DocumentInput) _then;

/// Create a copy of DocumentInput
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? type = null,Object? mediaId = null,}) {
  return _then(_self.copyWith(
type: null == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as ProDocumentType,mediaId: null == mediaId ? _self.mediaId : mediaId // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [DocumentInput].
extension DocumentInputPatterns on DocumentInput {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _DocumentInput value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _DocumentInput() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _DocumentInput value)  $default,){
final _that = this;
switch (_that) {
case _DocumentInput():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _DocumentInput value)?  $default,){
final _that = this;
switch (_that) {
case _DocumentInput() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( ProDocumentType type, @JsonKey(fromJson: idFromJson, toJson: wireId)  String mediaId)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _DocumentInput() when $default != null:
return $default(_that.type,_that.mediaId);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( ProDocumentType type, @JsonKey(fromJson: idFromJson, toJson: wireId)  String mediaId)  $default,) {final _that = this;
switch (_that) {
case _DocumentInput():
return $default(_that.type,_that.mediaId);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( ProDocumentType type, @JsonKey(fromJson: idFromJson, toJson: wireId)  String mediaId)?  $default,) {final _that = this;
switch (_that) {
case _DocumentInput() when $default != null:
return $default(_that.type,_that.mediaId);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _DocumentInput implements DocumentInput {
  const _DocumentInput({required this.type, @JsonKey(fromJson: idFromJson, toJson: wireId) required this.mediaId});
  factory _DocumentInput.fromJson(Map<String, dynamic> json) => _$DocumentInputFromJson(json);

@override final  ProDocumentType type;
@override@JsonKey(fromJson: idFromJson, toJson: wireId) final  String mediaId;

/// Create a copy of DocumentInput
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$DocumentInputCopyWith<_DocumentInput> get copyWith => __$DocumentInputCopyWithImpl<_DocumentInput>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$DocumentInputToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _DocumentInput&&(identical(other.type, type) || other.type == type)&&(identical(other.mediaId, mediaId) || other.mediaId == mediaId));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,type,mediaId);

@override
String toString() {
  return 'DocumentInput(type: $type, mediaId: $mediaId)';
}


}

/// @nodoc
abstract mixin class _$DocumentInputCopyWith<$Res> implements $DocumentInputCopyWith<$Res> {
  factory _$DocumentInputCopyWith(_DocumentInput value, $Res Function(_DocumentInput) _then) = __$DocumentInputCopyWithImpl;
@override @useResult
$Res call({
 ProDocumentType type,@JsonKey(fromJson: idFromJson, toJson: wireId) String mediaId
});




}
/// @nodoc
class __$DocumentInputCopyWithImpl<$Res>
    implements _$DocumentInputCopyWith<$Res> {
  __$DocumentInputCopyWithImpl(this._self, this._then);

  final _DocumentInput _self;
  final $Res Function(_DocumentInput) _then;

/// Create a copy of DocumentInput
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? type = null,Object? mediaId = null,}) {
  return _then(_DocumentInput(
type: null == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as ProDocumentType,mediaId: null == mediaId ? _self.mediaId : mediaId // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}


/// @nodoc
mixin _$ApplicationInput {

 String get businessName; String get bio; int get experienceYears;@JsonKey(fromJson: idListFromJson, toJson: idListToJson) List<String> get categoryIds;@JsonKey(fromJson: idListFromJson, toJson: idListToJson) List<String> get districtIds; List<DocumentInput> get documents;
/// Create a copy of ApplicationInput
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ApplicationInputCopyWith<ApplicationInput> get copyWith => _$ApplicationInputCopyWithImpl<ApplicationInput>(this as ApplicationInput, _$identity);

  /// Serializes this ApplicationInput to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ApplicationInput&&(identical(other.businessName, businessName) || other.businessName == businessName)&&(identical(other.bio, bio) || other.bio == bio)&&(identical(other.experienceYears, experienceYears) || other.experienceYears == experienceYears)&&const DeepCollectionEquality().equals(other.categoryIds, categoryIds)&&const DeepCollectionEquality().equals(other.districtIds, districtIds)&&const DeepCollectionEquality().equals(other.documents, documents));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,businessName,bio,experienceYears,const DeepCollectionEquality().hash(categoryIds),const DeepCollectionEquality().hash(districtIds),const DeepCollectionEquality().hash(documents));

@override
String toString() {
  return 'ApplicationInput(businessName: $businessName, bio: $bio, experienceYears: $experienceYears, categoryIds: $categoryIds, districtIds: $districtIds, documents: $documents)';
}


}

/// @nodoc
abstract mixin class $ApplicationInputCopyWith<$Res>  {
  factory $ApplicationInputCopyWith(ApplicationInput value, $Res Function(ApplicationInput) _then) = _$ApplicationInputCopyWithImpl;
@useResult
$Res call({
 String businessName, String bio, int experienceYears,@JsonKey(fromJson: idListFromJson, toJson: idListToJson) List<String> categoryIds,@JsonKey(fromJson: idListFromJson, toJson: idListToJson) List<String> districtIds, List<DocumentInput> documents
});




}
/// @nodoc
class _$ApplicationInputCopyWithImpl<$Res>
    implements $ApplicationInputCopyWith<$Res> {
  _$ApplicationInputCopyWithImpl(this._self, this._then);

  final ApplicationInput _self;
  final $Res Function(ApplicationInput) _then;

/// Create a copy of ApplicationInput
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? businessName = null,Object? bio = null,Object? experienceYears = null,Object? categoryIds = null,Object? districtIds = null,Object? documents = null,}) {
  return _then(_self.copyWith(
businessName: null == businessName ? _self.businessName : businessName // ignore: cast_nullable_to_non_nullable
as String,bio: null == bio ? _self.bio : bio // ignore: cast_nullable_to_non_nullable
as String,experienceYears: null == experienceYears ? _self.experienceYears : experienceYears // ignore: cast_nullable_to_non_nullable
as int,categoryIds: null == categoryIds ? _self.categoryIds : categoryIds // ignore: cast_nullable_to_non_nullable
as List<String>,districtIds: null == districtIds ? _self.districtIds : districtIds // ignore: cast_nullable_to_non_nullable
as List<String>,documents: null == documents ? _self.documents : documents // ignore: cast_nullable_to_non_nullable
as List<DocumentInput>,
  ));
}

}


/// Adds pattern-matching-related methods to [ApplicationInput].
extension ApplicationInputPatterns on ApplicationInput {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ApplicationInput value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ApplicationInput() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ApplicationInput value)  $default,){
final _that = this;
switch (_that) {
case _ApplicationInput():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ApplicationInput value)?  $default,){
final _that = this;
switch (_that) {
case _ApplicationInput() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String businessName,  String bio,  int experienceYears, @JsonKey(fromJson: idListFromJson, toJson: idListToJson)  List<String> categoryIds, @JsonKey(fromJson: idListFromJson, toJson: idListToJson)  List<String> districtIds,  List<DocumentInput> documents)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ApplicationInput() when $default != null:
return $default(_that.businessName,_that.bio,_that.experienceYears,_that.categoryIds,_that.districtIds,_that.documents);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String businessName,  String bio,  int experienceYears, @JsonKey(fromJson: idListFromJson, toJson: idListToJson)  List<String> categoryIds, @JsonKey(fromJson: idListFromJson, toJson: idListToJson)  List<String> districtIds,  List<DocumentInput> documents)  $default,) {final _that = this;
switch (_that) {
case _ApplicationInput():
return $default(_that.businessName,_that.bio,_that.experienceYears,_that.categoryIds,_that.districtIds,_that.documents);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String businessName,  String bio,  int experienceYears, @JsonKey(fromJson: idListFromJson, toJson: idListToJson)  List<String> categoryIds, @JsonKey(fromJson: idListFromJson, toJson: idListToJson)  List<String> districtIds,  List<DocumentInput> documents)?  $default,) {final _that = this;
switch (_that) {
case _ApplicationInput() when $default != null:
return $default(_that.businessName,_that.bio,_that.experienceYears,_that.categoryIds,_that.districtIds,_that.documents);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _ApplicationInput implements ApplicationInput {
  const _ApplicationInput({required this.businessName, this.bio = '', required this.experienceYears, @JsonKey(fromJson: idListFromJson, toJson: idListToJson) required this.categoryIds, @JsonKey(fromJson: idListFromJson, toJson: idListToJson) required this.districtIds, required this.documents});
  factory _ApplicationInput.fromJson(Map<String, dynamic> json) => _$ApplicationInputFromJson(json);

@override final  String businessName;
@override@JsonKey() final  String bio;
@override final  int experienceYears;
@override@JsonKey(fromJson: idListFromJson, toJson: idListToJson) final  List<String> categoryIds;
@override@JsonKey(fromJson: idListFromJson, toJson: idListToJson) final  List<String> districtIds;
@override final  List<DocumentInput> documents;

/// Create a copy of ApplicationInput
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ApplicationInputCopyWith<_ApplicationInput> get copyWith => __$ApplicationInputCopyWithImpl<_ApplicationInput>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ApplicationInputToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ApplicationInput&&(identical(other.businessName, businessName) || other.businessName == businessName)&&(identical(other.bio, bio) || other.bio == bio)&&(identical(other.experienceYears, experienceYears) || other.experienceYears == experienceYears)&&const DeepCollectionEquality().equals(other.categoryIds, categoryIds)&&const DeepCollectionEquality().equals(other.districtIds, districtIds)&&const DeepCollectionEquality().equals(other.documents, documents));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,businessName,bio,experienceYears,const DeepCollectionEquality().hash(categoryIds),const DeepCollectionEquality().hash(districtIds),const DeepCollectionEquality().hash(documents));

@override
String toString() {
  return 'ApplicationInput(businessName: $businessName, bio: $bio, experienceYears: $experienceYears, categoryIds: $categoryIds, districtIds: $districtIds, documents: $documents)';
}


}

/// @nodoc
abstract mixin class _$ApplicationInputCopyWith<$Res> implements $ApplicationInputCopyWith<$Res> {
  factory _$ApplicationInputCopyWith(_ApplicationInput value, $Res Function(_ApplicationInput) _then) = __$ApplicationInputCopyWithImpl;
@override @useResult
$Res call({
 String businessName, String bio, int experienceYears,@JsonKey(fromJson: idListFromJson, toJson: idListToJson) List<String> categoryIds,@JsonKey(fromJson: idListFromJson, toJson: idListToJson) List<String> districtIds, List<DocumentInput> documents
});




}
/// @nodoc
class __$ApplicationInputCopyWithImpl<$Res>
    implements _$ApplicationInputCopyWith<$Res> {
  __$ApplicationInputCopyWithImpl(this._self, this._then);

  final _ApplicationInput _self;
  final $Res Function(_ApplicationInput) _then;

/// Create a copy of ApplicationInput
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? businessName = null,Object? bio = null,Object? experienceYears = null,Object? categoryIds = null,Object? districtIds = null,Object? documents = null,}) {
  return _then(_ApplicationInput(
businessName: null == businessName ? _self.businessName : businessName // ignore: cast_nullable_to_non_nullable
as String,bio: null == bio ? _self.bio : bio // ignore: cast_nullable_to_non_nullable
as String,experienceYears: null == experienceYears ? _self.experienceYears : experienceYears // ignore: cast_nullable_to_non_nullable
as int,categoryIds: null == categoryIds ? _self.categoryIds : categoryIds // ignore: cast_nullable_to_non_nullable
as List<String>,districtIds: null == districtIds ? _self.districtIds : districtIds // ignore: cast_nullable_to_non_nullable
as List<String>,documents: null == documents ? _self.documents : documents // ignore: cast_nullable_to_non_nullable
as List<DocumentInput>,
  ));
}


}


/// @nodoc
mixin _$WorkingHours {

/// 1 (pazartesi) - 7 (pazar).
 int get weekday;/// `HH:mm`.
 String get start; String get end; bool get acceptsUrgent;
/// Create a copy of WorkingHours
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$WorkingHoursCopyWith<WorkingHours> get copyWith => _$WorkingHoursCopyWithImpl<WorkingHours>(this as WorkingHours, _$identity);

  /// Serializes this WorkingHours to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is WorkingHours&&(identical(other.weekday, weekday) || other.weekday == weekday)&&(identical(other.start, start) || other.start == start)&&(identical(other.end, end) || other.end == end)&&(identical(other.acceptsUrgent, acceptsUrgent) || other.acceptsUrgent == acceptsUrgent));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,weekday,start,end,acceptsUrgent);

@override
String toString() {
  return 'WorkingHours(weekday: $weekday, start: $start, end: $end, acceptsUrgent: $acceptsUrgent)';
}


}

/// @nodoc
abstract mixin class $WorkingHoursCopyWith<$Res>  {
  factory $WorkingHoursCopyWith(WorkingHours value, $Res Function(WorkingHours) _then) = _$WorkingHoursCopyWithImpl;
@useResult
$Res call({
 int weekday, String start, String end, bool acceptsUrgent
});




}
/// @nodoc
class _$WorkingHoursCopyWithImpl<$Res>
    implements $WorkingHoursCopyWith<$Res> {
  _$WorkingHoursCopyWithImpl(this._self, this._then);

  final WorkingHours _self;
  final $Res Function(WorkingHours) _then;

/// Create a copy of WorkingHours
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? weekday = null,Object? start = null,Object? end = null,Object? acceptsUrgent = null,}) {
  return _then(_self.copyWith(
weekday: null == weekday ? _self.weekday : weekday // ignore: cast_nullable_to_non_nullable
as int,start: null == start ? _self.start : start // ignore: cast_nullable_to_non_nullable
as String,end: null == end ? _self.end : end // ignore: cast_nullable_to_non_nullable
as String,acceptsUrgent: null == acceptsUrgent ? _self.acceptsUrgent : acceptsUrgent // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}

}


/// Adds pattern-matching-related methods to [WorkingHours].
extension WorkingHoursPatterns on WorkingHours {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _WorkingHours value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _WorkingHours() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _WorkingHours value)  $default,){
final _that = this;
switch (_that) {
case _WorkingHours():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _WorkingHours value)?  $default,){
final _that = this;
switch (_that) {
case _WorkingHours() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int weekday,  String start,  String end,  bool acceptsUrgent)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _WorkingHours() when $default != null:
return $default(_that.weekday,_that.start,_that.end,_that.acceptsUrgent);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int weekday,  String start,  String end,  bool acceptsUrgent)  $default,) {final _that = this;
switch (_that) {
case _WorkingHours():
return $default(_that.weekday,_that.start,_that.end,_that.acceptsUrgent);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int weekday,  String start,  String end,  bool acceptsUrgent)?  $default,) {final _that = this;
switch (_that) {
case _WorkingHours() when $default != null:
return $default(_that.weekday,_that.start,_that.end,_that.acceptsUrgent);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _WorkingHours implements WorkingHours {
  const _WorkingHours({required this.weekday, required this.start, required this.end, this.acceptsUrgent = false});
  factory _WorkingHours.fromJson(Map<String, dynamic> json) => _$WorkingHoursFromJson(json);

/// 1 (pazartesi) - 7 (pazar).
@override final  int weekday;
/// `HH:mm`.
@override final  String start;
@override final  String end;
@override@JsonKey() final  bool acceptsUrgent;

/// Create a copy of WorkingHours
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$WorkingHoursCopyWith<_WorkingHours> get copyWith => __$WorkingHoursCopyWithImpl<_WorkingHours>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$WorkingHoursToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _WorkingHours&&(identical(other.weekday, weekday) || other.weekday == weekday)&&(identical(other.start, start) || other.start == start)&&(identical(other.end, end) || other.end == end)&&(identical(other.acceptsUrgent, acceptsUrgent) || other.acceptsUrgent == acceptsUrgent));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,weekday,start,end,acceptsUrgent);

@override
String toString() {
  return 'WorkingHours(weekday: $weekday, start: $start, end: $end, acceptsUrgent: $acceptsUrgent)';
}


}

/// @nodoc
abstract mixin class _$WorkingHoursCopyWith<$Res> implements $WorkingHoursCopyWith<$Res> {
  factory _$WorkingHoursCopyWith(_WorkingHours value, $Res Function(_WorkingHours) _then) = __$WorkingHoursCopyWithImpl;
@override @useResult
$Res call({
 int weekday, String start, String end, bool acceptsUrgent
});




}
/// @nodoc
class __$WorkingHoursCopyWithImpl<$Res>
    implements _$WorkingHoursCopyWith<$Res> {
  __$WorkingHoursCopyWithImpl(this._self, this._then);

  final _WorkingHours _self;
  final $Res Function(_WorkingHours) _then;

/// Create a copy of WorkingHours
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? weekday = null,Object? start = null,Object? end = null,Object? acceptsUrgent = null,}) {
  return _then(_WorkingHours(
weekday: null == weekday ? _self.weekday : weekday // ignore: cast_nullable_to_non_nullable
as int,start: null == start ? _self.start : start // ignore: cast_nullable_to_non_nullable
as String,end: null == end ? _self.end : end // ignore: cast_nullable_to_non_nullable
as String,acceptsUrgent: null == acceptsUrgent ? _self.acceptsUrgent : acceptsUrgent // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}


}


/// @nodoc
mixin _$ProProfile {

 String get businessName; String get bio; int get experienceYears;@JsonKey(fromJson: idListFromJson, toJson: idListToJson) List<String> get categoryIds;@JsonKey(fromJson: idListFromJson, toJson: idListToJson) List<String> get districtIds; List<WorkingHours> get workingHours; ReviewStatus get reviewStatus; ProAvailability get availability; double get ratingAvg; int get ratingCount; int get completedJobs;
/// Create a copy of ProProfile
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ProProfileCopyWith<ProProfile> get copyWith => _$ProProfileCopyWithImpl<ProProfile>(this as ProProfile, _$identity);

  /// Serializes this ProProfile to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ProProfile&&(identical(other.businessName, businessName) || other.businessName == businessName)&&(identical(other.bio, bio) || other.bio == bio)&&(identical(other.experienceYears, experienceYears) || other.experienceYears == experienceYears)&&const DeepCollectionEquality().equals(other.categoryIds, categoryIds)&&const DeepCollectionEquality().equals(other.districtIds, districtIds)&&const DeepCollectionEquality().equals(other.workingHours, workingHours)&&(identical(other.reviewStatus, reviewStatus) || other.reviewStatus == reviewStatus)&&(identical(other.availability, availability) || other.availability == availability)&&(identical(other.ratingAvg, ratingAvg) || other.ratingAvg == ratingAvg)&&(identical(other.ratingCount, ratingCount) || other.ratingCount == ratingCount)&&(identical(other.completedJobs, completedJobs) || other.completedJobs == completedJobs));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,businessName,bio,experienceYears,const DeepCollectionEquality().hash(categoryIds),const DeepCollectionEquality().hash(districtIds),const DeepCollectionEquality().hash(workingHours),reviewStatus,availability,ratingAvg,ratingCount,completedJobs);

@override
String toString() {
  return 'ProProfile(businessName: $businessName, bio: $bio, experienceYears: $experienceYears, categoryIds: $categoryIds, districtIds: $districtIds, workingHours: $workingHours, reviewStatus: $reviewStatus, availability: $availability, ratingAvg: $ratingAvg, ratingCount: $ratingCount, completedJobs: $completedJobs)';
}


}

/// @nodoc
abstract mixin class $ProProfileCopyWith<$Res>  {
  factory $ProProfileCopyWith(ProProfile value, $Res Function(ProProfile) _then) = _$ProProfileCopyWithImpl;
@useResult
$Res call({
 String businessName, String bio, int experienceYears,@JsonKey(fromJson: idListFromJson, toJson: idListToJson) List<String> categoryIds,@JsonKey(fromJson: idListFromJson, toJson: idListToJson) List<String> districtIds, List<WorkingHours> workingHours, ReviewStatus reviewStatus, ProAvailability availability, double ratingAvg, int ratingCount, int completedJobs
});




}
/// @nodoc
class _$ProProfileCopyWithImpl<$Res>
    implements $ProProfileCopyWith<$Res> {
  _$ProProfileCopyWithImpl(this._self, this._then);

  final ProProfile _self;
  final $Res Function(ProProfile) _then;

/// Create a copy of ProProfile
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? businessName = null,Object? bio = null,Object? experienceYears = null,Object? categoryIds = null,Object? districtIds = null,Object? workingHours = null,Object? reviewStatus = null,Object? availability = null,Object? ratingAvg = null,Object? ratingCount = null,Object? completedJobs = null,}) {
  return _then(_self.copyWith(
businessName: null == businessName ? _self.businessName : businessName // ignore: cast_nullable_to_non_nullable
as String,bio: null == bio ? _self.bio : bio // ignore: cast_nullable_to_non_nullable
as String,experienceYears: null == experienceYears ? _self.experienceYears : experienceYears // ignore: cast_nullable_to_non_nullable
as int,categoryIds: null == categoryIds ? _self.categoryIds : categoryIds // ignore: cast_nullable_to_non_nullable
as List<String>,districtIds: null == districtIds ? _self.districtIds : districtIds // ignore: cast_nullable_to_non_nullable
as List<String>,workingHours: null == workingHours ? _self.workingHours : workingHours // ignore: cast_nullable_to_non_nullable
as List<WorkingHours>,reviewStatus: null == reviewStatus ? _self.reviewStatus : reviewStatus // ignore: cast_nullable_to_non_nullable
as ReviewStatus,availability: null == availability ? _self.availability : availability // ignore: cast_nullable_to_non_nullable
as ProAvailability,ratingAvg: null == ratingAvg ? _self.ratingAvg : ratingAvg // ignore: cast_nullable_to_non_nullable
as double,ratingCount: null == ratingCount ? _self.ratingCount : ratingCount // ignore: cast_nullable_to_non_nullable
as int,completedJobs: null == completedJobs ? _self.completedJobs : completedJobs // ignore: cast_nullable_to_non_nullable
as int,
  ));
}

}


/// Adds pattern-matching-related methods to [ProProfile].
extension ProProfilePatterns on ProProfile {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ProProfile value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ProProfile() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ProProfile value)  $default,){
final _that = this;
switch (_that) {
case _ProProfile():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ProProfile value)?  $default,){
final _that = this;
switch (_that) {
case _ProProfile() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String businessName,  String bio,  int experienceYears, @JsonKey(fromJson: idListFromJson, toJson: idListToJson)  List<String> categoryIds, @JsonKey(fromJson: idListFromJson, toJson: idListToJson)  List<String> districtIds,  List<WorkingHours> workingHours,  ReviewStatus reviewStatus,  ProAvailability availability,  double ratingAvg,  int ratingCount,  int completedJobs)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ProProfile() when $default != null:
return $default(_that.businessName,_that.bio,_that.experienceYears,_that.categoryIds,_that.districtIds,_that.workingHours,_that.reviewStatus,_that.availability,_that.ratingAvg,_that.ratingCount,_that.completedJobs);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String businessName,  String bio,  int experienceYears, @JsonKey(fromJson: idListFromJson, toJson: idListToJson)  List<String> categoryIds, @JsonKey(fromJson: idListFromJson, toJson: idListToJson)  List<String> districtIds,  List<WorkingHours> workingHours,  ReviewStatus reviewStatus,  ProAvailability availability,  double ratingAvg,  int ratingCount,  int completedJobs)  $default,) {final _that = this;
switch (_that) {
case _ProProfile():
return $default(_that.businessName,_that.bio,_that.experienceYears,_that.categoryIds,_that.districtIds,_that.workingHours,_that.reviewStatus,_that.availability,_that.ratingAvg,_that.ratingCount,_that.completedJobs);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String businessName,  String bio,  int experienceYears, @JsonKey(fromJson: idListFromJson, toJson: idListToJson)  List<String> categoryIds, @JsonKey(fromJson: idListFromJson, toJson: idListToJson)  List<String> districtIds,  List<WorkingHours> workingHours,  ReviewStatus reviewStatus,  ProAvailability availability,  double ratingAvg,  int ratingCount,  int completedJobs)?  $default,) {final _that = this;
switch (_that) {
case _ProProfile() when $default != null:
return $default(_that.businessName,_that.bio,_that.experienceYears,_that.categoryIds,_that.districtIds,_that.workingHours,_that.reviewStatus,_that.availability,_that.ratingAvg,_that.ratingCount,_that.completedJobs);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _ProProfile implements ProProfile {
  const _ProProfile({required this.businessName, this.bio = '', this.experienceYears = 0, @JsonKey(fromJson: idListFromJson, toJson: idListToJson) this.categoryIds = const <String>[], @JsonKey(fromJson: idListFromJson, toJson: idListToJson) this.districtIds = const <String>[], this.workingHours = const <WorkingHours>[], required this.reviewStatus, required this.availability, this.ratingAvg = 0.0, this.ratingCount = 0, this.completedJobs = 0});
  factory _ProProfile.fromJson(Map<String, dynamic> json) => _$ProProfileFromJson(json);

@override final  String businessName;
@override@JsonKey() final  String bio;
@override@JsonKey() final  int experienceYears;
@override@JsonKey(fromJson: idListFromJson, toJson: idListToJson) final  List<String> categoryIds;
@override@JsonKey(fromJson: idListFromJson, toJson: idListToJson) final  List<String> districtIds;
@override@JsonKey() final  List<WorkingHours> workingHours;
@override final  ReviewStatus reviewStatus;
@override final  ProAvailability availability;
@override@JsonKey() final  double ratingAvg;
@override@JsonKey() final  int ratingCount;
@override@JsonKey() final  int completedJobs;

/// Create a copy of ProProfile
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ProProfileCopyWith<_ProProfile> get copyWith => __$ProProfileCopyWithImpl<_ProProfile>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ProProfileToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ProProfile&&(identical(other.businessName, businessName) || other.businessName == businessName)&&(identical(other.bio, bio) || other.bio == bio)&&(identical(other.experienceYears, experienceYears) || other.experienceYears == experienceYears)&&const DeepCollectionEquality().equals(other.categoryIds, categoryIds)&&const DeepCollectionEquality().equals(other.districtIds, districtIds)&&const DeepCollectionEquality().equals(other.workingHours, workingHours)&&(identical(other.reviewStatus, reviewStatus) || other.reviewStatus == reviewStatus)&&(identical(other.availability, availability) || other.availability == availability)&&(identical(other.ratingAvg, ratingAvg) || other.ratingAvg == ratingAvg)&&(identical(other.ratingCount, ratingCount) || other.ratingCount == ratingCount)&&(identical(other.completedJobs, completedJobs) || other.completedJobs == completedJobs));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,businessName,bio,experienceYears,const DeepCollectionEquality().hash(categoryIds),const DeepCollectionEquality().hash(districtIds),const DeepCollectionEquality().hash(workingHours),reviewStatus,availability,ratingAvg,ratingCount,completedJobs);

@override
String toString() {
  return 'ProProfile(businessName: $businessName, bio: $bio, experienceYears: $experienceYears, categoryIds: $categoryIds, districtIds: $districtIds, workingHours: $workingHours, reviewStatus: $reviewStatus, availability: $availability, ratingAvg: $ratingAvg, ratingCount: $ratingCount, completedJobs: $completedJobs)';
}


}

/// @nodoc
abstract mixin class _$ProProfileCopyWith<$Res> implements $ProProfileCopyWith<$Res> {
  factory _$ProProfileCopyWith(_ProProfile value, $Res Function(_ProProfile) _then) = __$ProProfileCopyWithImpl;
@override @useResult
$Res call({
 String businessName, String bio, int experienceYears,@JsonKey(fromJson: idListFromJson, toJson: idListToJson) List<String> categoryIds,@JsonKey(fromJson: idListFromJson, toJson: idListToJson) List<String> districtIds, List<WorkingHours> workingHours, ReviewStatus reviewStatus, ProAvailability availability, double ratingAvg, int ratingCount, int completedJobs
});




}
/// @nodoc
class __$ProProfileCopyWithImpl<$Res>
    implements _$ProProfileCopyWith<$Res> {
  __$ProProfileCopyWithImpl(this._self, this._then);

  final _ProProfile _self;
  final $Res Function(_ProProfile) _then;

/// Create a copy of ProProfile
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? businessName = null,Object? bio = null,Object? experienceYears = null,Object? categoryIds = null,Object? districtIds = null,Object? workingHours = null,Object? reviewStatus = null,Object? availability = null,Object? ratingAvg = null,Object? ratingCount = null,Object? completedJobs = null,}) {
  return _then(_ProProfile(
businessName: null == businessName ? _self.businessName : businessName // ignore: cast_nullable_to_non_nullable
as String,bio: null == bio ? _self.bio : bio // ignore: cast_nullable_to_non_nullable
as String,experienceYears: null == experienceYears ? _self.experienceYears : experienceYears // ignore: cast_nullable_to_non_nullable
as int,categoryIds: null == categoryIds ? _self.categoryIds : categoryIds // ignore: cast_nullable_to_non_nullable
as List<String>,districtIds: null == districtIds ? _self.districtIds : districtIds // ignore: cast_nullable_to_non_nullable
as List<String>,workingHours: null == workingHours ? _self.workingHours : workingHours // ignore: cast_nullable_to_non_nullable
as List<WorkingHours>,reviewStatus: null == reviewStatus ? _self.reviewStatus : reviewStatus // ignore: cast_nullable_to_non_nullable
as ReviewStatus,availability: null == availability ? _self.availability : availability // ignore: cast_nullable_to_non_nullable
as ProAvailability,ratingAvg: null == ratingAvg ? _self.ratingAvg : ratingAvg // ignore: cast_nullable_to_non_nullable
as double,ratingCount: null == ratingCount ? _self.ratingCount : ratingCount // ignore: cast_nullable_to_non_nullable
as int,completedJobs: null == completedJobs ? _self.completedJobs : completedJobs // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}


/// @nodoc
mixin _$ProProfileInput {

 String get businessName; String get bio; int get experienceYears;@JsonKey(fromJson: idListFromJson, toJson: idListToJson) List<String> get categoryIds;@JsonKey(fromJson: idListFromJson, toJson: idListToJson) List<String> get districtIds; List<WorkingHours> get workingHours;
/// Create a copy of ProProfileInput
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ProProfileInputCopyWith<ProProfileInput> get copyWith => _$ProProfileInputCopyWithImpl<ProProfileInput>(this as ProProfileInput, _$identity);

  /// Serializes this ProProfileInput to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ProProfileInput&&(identical(other.businessName, businessName) || other.businessName == businessName)&&(identical(other.bio, bio) || other.bio == bio)&&(identical(other.experienceYears, experienceYears) || other.experienceYears == experienceYears)&&const DeepCollectionEquality().equals(other.categoryIds, categoryIds)&&const DeepCollectionEquality().equals(other.districtIds, districtIds)&&const DeepCollectionEquality().equals(other.workingHours, workingHours));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,businessName,bio,experienceYears,const DeepCollectionEquality().hash(categoryIds),const DeepCollectionEquality().hash(districtIds),const DeepCollectionEquality().hash(workingHours));

@override
String toString() {
  return 'ProProfileInput(businessName: $businessName, bio: $bio, experienceYears: $experienceYears, categoryIds: $categoryIds, districtIds: $districtIds, workingHours: $workingHours)';
}


}

/// @nodoc
abstract mixin class $ProProfileInputCopyWith<$Res>  {
  factory $ProProfileInputCopyWith(ProProfileInput value, $Res Function(ProProfileInput) _then) = _$ProProfileInputCopyWithImpl;
@useResult
$Res call({
 String businessName, String bio, int experienceYears,@JsonKey(fromJson: idListFromJson, toJson: idListToJson) List<String> categoryIds,@JsonKey(fromJson: idListFromJson, toJson: idListToJson) List<String> districtIds, List<WorkingHours> workingHours
});




}
/// @nodoc
class _$ProProfileInputCopyWithImpl<$Res>
    implements $ProProfileInputCopyWith<$Res> {
  _$ProProfileInputCopyWithImpl(this._self, this._then);

  final ProProfileInput _self;
  final $Res Function(ProProfileInput) _then;

/// Create a copy of ProProfileInput
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? businessName = null,Object? bio = null,Object? experienceYears = null,Object? categoryIds = null,Object? districtIds = null,Object? workingHours = null,}) {
  return _then(_self.copyWith(
businessName: null == businessName ? _self.businessName : businessName // ignore: cast_nullable_to_non_nullable
as String,bio: null == bio ? _self.bio : bio // ignore: cast_nullable_to_non_nullable
as String,experienceYears: null == experienceYears ? _self.experienceYears : experienceYears // ignore: cast_nullable_to_non_nullable
as int,categoryIds: null == categoryIds ? _self.categoryIds : categoryIds // ignore: cast_nullable_to_non_nullable
as List<String>,districtIds: null == districtIds ? _self.districtIds : districtIds // ignore: cast_nullable_to_non_nullable
as List<String>,workingHours: null == workingHours ? _self.workingHours : workingHours // ignore: cast_nullable_to_non_nullable
as List<WorkingHours>,
  ));
}

}


/// Adds pattern-matching-related methods to [ProProfileInput].
extension ProProfileInputPatterns on ProProfileInput {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ProProfileInput value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ProProfileInput() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ProProfileInput value)  $default,){
final _that = this;
switch (_that) {
case _ProProfileInput():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ProProfileInput value)?  $default,){
final _that = this;
switch (_that) {
case _ProProfileInput() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String businessName,  String bio,  int experienceYears, @JsonKey(fromJson: idListFromJson, toJson: idListToJson)  List<String> categoryIds, @JsonKey(fromJson: idListFromJson, toJson: idListToJson)  List<String> districtIds,  List<WorkingHours> workingHours)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ProProfileInput() when $default != null:
return $default(_that.businessName,_that.bio,_that.experienceYears,_that.categoryIds,_that.districtIds,_that.workingHours);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String businessName,  String bio,  int experienceYears, @JsonKey(fromJson: idListFromJson, toJson: idListToJson)  List<String> categoryIds, @JsonKey(fromJson: idListFromJson, toJson: idListToJson)  List<String> districtIds,  List<WorkingHours> workingHours)  $default,) {final _that = this;
switch (_that) {
case _ProProfileInput():
return $default(_that.businessName,_that.bio,_that.experienceYears,_that.categoryIds,_that.districtIds,_that.workingHours);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String businessName,  String bio,  int experienceYears, @JsonKey(fromJson: idListFromJson, toJson: idListToJson)  List<String> categoryIds, @JsonKey(fromJson: idListFromJson, toJson: idListToJson)  List<String> districtIds,  List<WorkingHours> workingHours)?  $default,) {final _that = this;
switch (_that) {
case _ProProfileInput() when $default != null:
return $default(_that.businessName,_that.bio,_that.experienceYears,_that.categoryIds,_that.districtIds,_that.workingHours);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _ProProfileInput implements ProProfileInput {
  const _ProProfileInput({required this.businessName, this.bio = '', required this.experienceYears, @JsonKey(fromJson: idListFromJson, toJson: idListToJson) required this.categoryIds, @JsonKey(fromJson: idListFromJson, toJson: idListToJson) required this.districtIds, required this.workingHours});
  factory _ProProfileInput.fromJson(Map<String, dynamic> json) => _$ProProfileInputFromJson(json);

@override final  String businessName;
@override@JsonKey() final  String bio;
@override final  int experienceYears;
@override@JsonKey(fromJson: idListFromJson, toJson: idListToJson) final  List<String> categoryIds;
@override@JsonKey(fromJson: idListFromJson, toJson: idListToJson) final  List<String> districtIds;
@override final  List<WorkingHours> workingHours;

/// Create a copy of ProProfileInput
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ProProfileInputCopyWith<_ProProfileInput> get copyWith => __$ProProfileInputCopyWithImpl<_ProProfileInput>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ProProfileInputToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ProProfileInput&&(identical(other.businessName, businessName) || other.businessName == businessName)&&(identical(other.bio, bio) || other.bio == bio)&&(identical(other.experienceYears, experienceYears) || other.experienceYears == experienceYears)&&const DeepCollectionEquality().equals(other.categoryIds, categoryIds)&&const DeepCollectionEquality().equals(other.districtIds, districtIds)&&const DeepCollectionEquality().equals(other.workingHours, workingHours));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,businessName,bio,experienceYears,const DeepCollectionEquality().hash(categoryIds),const DeepCollectionEquality().hash(districtIds),const DeepCollectionEquality().hash(workingHours));

@override
String toString() {
  return 'ProProfileInput(businessName: $businessName, bio: $bio, experienceYears: $experienceYears, categoryIds: $categoryIds, districtIds: $districtIds, workingHours: $workingHours)';
}


}

/// @nodoc
abstract mixin class _$ProProfileInputCopyWith<$Res> implements $ProProfileInputCopyWith<$Res> {
  factory _$ProProfileInputCopyWith(_ProProfileInput value, $Res Function(_ProProfileInput) _then) = __$ProProfileInputCopyWithImpl;
@override @useResult
$Res call({
 String businessName, String bio, int experienceYears,@JsonKey(fromJson: idListFromJson, toJson: idListToJson) List<String> categoryIds,@JsonKey(fromJson: idListFromJson, toJson: idListToJson) List<String> districtIds, List<WorkingHours> workingHours
});




}
/// @nodoc
class __$ProProfileInputCopyWithImpl<$Res>
    implements _$ProProfileInputCopyWith<$Res> {
  __$ProProfileInputCopyWithImpl(this._self, this._then);

  final _ProProfileInput _self;
  final $Res Function(_ProProfileInput) _then;

/// Create a copy of ProProfileInput
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? businessName = null,Object? bio = null,Object? experienceYears = null,Object? categoryIds = null,Object? districtIds = null,Object? workingHours = null,}) {
  return _then(_ProProfileInput(
businessName: null == businessName ? _self.businessName : businessName // ignore: cast_nullable_to_non_nullable
as String,bio: null == bio ? _self.bio : bio // ignore: cast_nullable_to_non_nullable
as String,experienceYears: null == experienceYears ? _self.experienceYears : experienceYears // ignore: cast_nullable_to_non_nullable
as int,categoryIds: null == categoryIds ? _self.categoryIds : categoryIds // ignore: cast_nullable_to_non_nullable
as List<String>,districtIds: null == districtIds ? _self.districtIds : districtIds // ignore: cast_nullable_to_non_nullable
as List<String>,workingHours: null == workingHours ? _self.workingHours : workingHours // ignore: cast_nullable_to_non_nullable
as List<WorkingHours>,
  ));
}


}


/// @nodoc
mixin _$DistrictRef {

@JsonKey(fromJson: idFromJson) String get id; String get name;
/// Create a copy of DistrictRef
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$DistrictRefCopyWith<DistrictRef> get copyWith => _$DistrictRefCopyWithImpl<DistrictRef>(this as DistrictRef, _$identity);

  /// Serializes this DistrictRef to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is DistrictRef&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,name);

@override
String toString() {
  return 'DistrictRef(id: $id, name: $name)';
}


}

/// @nodoc
abstract mixin class $DistrictRefCopyWith<$Res>  {
  factory $DistrictRefCopyWith(DistrictRef value, $Res Function(DistrictRef) _then) = _$DistrictRefCopyWithImpl;
@useResult
$Res call({
@JsonKey(fromJson: idFromJson) String id, String name
});




}
/// @nodoc
class _$DistrictRefCopyWithImpl<$Res>
    implements $DistrictRefCopyWith<$Res> {
  _$DistrictRefCopyWithImpl(this._self, this._then);

  final DistrictRef _self;
  final $Res Function(DistrictRef) _then;

/// Create a copy of DistrictRef
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? name = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [DistrictRef].
extension DistrictRefPatterns on DistrictRef {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _DistrictRef value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _DistrictRef() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _DistrictRef value)  $default,){
final _that = this;
switch (_that) {
case _DistrictRef():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _DistrictRef value)?  $default,){
final _that = this;
switch (_that) {
case _DistrictRef() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function(@JsonKey(fromJson: idFromJson)  String id,  String name)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _DistrictRef() when $default != null:
return $default(_that.id,_that.name);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function(@JsonKey(fromJson: idFromJson)  String id,  String name)  $default,) {final _that = this;
switch (_that) {
case _DistrictRef():
return $default(_that.id,_that.name);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function(@JsonKey(fromJson: idFromJson)  String id,  String name)?  $default,) {final _that = this;
switch (_that) {
case _DistrictRef() when $default != null:
return $default(_that.id,_that.name);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _DistrictRef implements DistrictRef {
  const _DistrictRef({@JsonKey(fromJson: idFromJson) required this.id, required this.name});
  factory _DistrictRef.fromJson(Map<String, dynamic> json) => _$DistrictRefFromJson(json);

@override@JsonKey(fromJson: idFromJson) final  String id;
@override final  String name;

/// Create a copy of DistrictRef
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$DistrictRefCopyWith<_DistrictRef> get copyWith => __$DistrictRefCopyWithImpl<_DistrictRef>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$DistrictRefToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _DistrictRef&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,name);

@override
String toString() {
  return 'DistrictRef(id: $id, name: $name)';
}


}

/// @nodoc
abstract mixin class _$DistrictRefCopyWith<$Res> implements $DistrictRefCopyWith<$Res> {
  factory _$DistrictRefCopyWith(_DistrictRef value, $Res Function(_DistrictRef) _then) = __$DistrictRefCopyWithImpl;
@override @useResult
$Res call({
@JsonKey(fromJson: idFromJson) String id, String name
});




}
/// @nodoc
class __$DistrictRefCopyWithImpl<$Res>
    implements _$DistrictRefCopyWith<$Res> {
  __$DistrictRefCopyWithImpl(this._self, this._then);

  final _DistrictRef _self;
  final $Res Function(_DistrictRef) _then;

/// Create a copy of DistrictRef
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? name = null,}) {
  return _then(_DistrictRef(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}


/// @nodoc
mixin _$ProPublicProfile {

@JsonKey(fromJson: idFromJson) String get id; String get businessName; String get fullName; String? get bio; int get experienceYears; double get ratingAvg; int get ratingCount; int get completedJobs; DateTime? get memberSince;@JsonKey(fromJson: idListFromJson, toJson: idListToJson) List<String> get categoryIds; List<DistrictRef> get districts; List<ProDocumentType> get verifiedDocuments;
/// Create a copy of ProPublicProfile
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ProPublicProfileCopyWith<ProPublicProfile> get copyWith => _$ProPublicProfileCopyWithImpl<ProPublicProfile>(this as ProPublicProfile, _$identity);

  /// Serializes this ProPublicProfile to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ProPublicProfile&&(identical(other.id, id) || other.id == id)&&(identical(other.businessName, businessName) || other.businessName == businessName)&&(identical(other.fullName, fullName) || other.fullName == fullName)&&(identical(other.bio, bio) || other.bio == bio)&&(identical(other.experienceYears, experienceYears) || other.experienceYears == experienceYears)&&(identical(other.ratingAvg, ratingAvg) || other.ratingAvg == ratingAvg)&&(identical(other.ratingCount, ratingCount) || other.ratingCount == ratingCount)&&(identical(other.completedJobs, completedJobs) || other.completedJobs == completedJobs)&&(identical(other.memberSince, memberSince) || other.memberSince == memberSince)&&const DeepCollectionEquality().equals(other.categoryIds, categoryIds)&&const DeepCollectionEquality().equals(other.districts, districts)&&const DeepCollectionEquality().equals(other.verifiedDocuments, verifiedDocuments));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,businessName,fullName,bio,experienceYears,ratingAvg,ratingCount,completedJobs,memberSince,const DeepCollectionEquality().hash(categoryIds),const DeepCollectionEquality().hash(districts),const DeepCollectionEquality().hash(verifiedDocuments));

@override
String toString() {
  return 'ProPublicProfile(id: $id, businessName: $businessName, fullName: $fullName, bio: $bio, experienceYears: $experienceYears, ratingAvg: $ratingAvg, ratingCount: $ratingCount, completedJobs: $completedJobs, memberSince: $memberSince, categoryIds: $categoryIds, districts: $districts, verifiedDocuments: $verifiedDocuments)';
}


}

/// @nodoc
abstract mixin class $ProPublicProfileCopyWith<$Res>  {
  factory $ProPublicProfileCopyWith(ProPublicProfile value, $Res Function(ProPublicProfile) _then) = _$ProPublicProfileCopyWithImpl;
@useResult
$Res call({
@JsonKey(fromJson: idFromJson) String id, String businessName, String fullName, String? bio, int experienceYears, double ratingAvg, int ratingCount, int completedJobs, DateTime? memberSince,@JsonKey(fromJson: idListFromJson, toJson: idListToJson) List<String> categoryIds, List<DistrictRef> districts, List<ProDocumentType> verifiedDocuments
});




}
/// @nodoc
class _$ProPublicProfileCopyWithImpl<$Res>
    implements $ProPublicProfileCopyWith<$Res> {
  _$ProPublicProfileCopyWithImpl(this._self, this._then);

  final ProPublicProfile _self;
  final $Res Function(ProPublicProfile) _then;

/// Create a copy of ProPublicProfile
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? businessName = null,Object? fullName = null,Object? bio = freezed,Object? experienceYears = null,Object? ratingAvg = null,Object? ratingCount = null,Object? completedJobs = null,Object? memberSince = freezed,Object? categoryIds = null,Object? districts = null,Object? verifiedDocuments = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,businessName: null == businessName ? _self.businessName : businessName // ignore: cast_nullable_to_non_nullable
as String,fullName: null == fullName ? _self.fullName : fullName // ignore: cast_nullable_to_non_nullable
as String,bio: freezed == bio ? _self.bio : bio // ignore: cast_nullable_to_non_nullable
as String?,experienceYears: null == experienceYears ? _self.experienceYears : experienceYears // ignore: cast_nullable_to_non_nullable
as int,ratingAvg: null == ratingAvg ? _self.ratingAvg : ratingAvg // ignore: cast_nullable_to_non_nullable
as double,ratingCount: null == ratingCount ? _self.ratingCount : ratingCount // ignore: cast_nullable_to_non_nullable
as int,completedJobs: null == completedJobs ? _self.completedJobs : completedJobs // ignore: cast_nullable_to_non_nullable
as int,memberSince: freezed == memberSince ? _self.memberSince : memberSince // ignore: cast_nullable_to_non_nullable
as DateTime?,categoryIds: null == categoryIds ? _self.categoryIds : categoryIds // ignore: cast_nullable_to_non_nullable
as List<String>,districts: null == districts ? _self.districts : districts // ignore: cast_nullable_to_non_nullable
as List<DistrictRef>,verifiedDocuments: null == verifiedDocuments ? _self.verifiedDocuments : verifiedDocuments // ignore: cast_nullable_to_non_nullable
as List<ProDocumentType>,
  ));
}

}


/// Adds pattern-matching-related methods to [ProPublicProfile].
extension ProPublicProfilePatterns on ProPublicProfile {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ProPublicProfile value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ProPublicProfile() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ProPublicProfile value)  $default,){
final _that = this;
switch (_that) {
case _ProPublicProfile():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ProPublicProfile value)?  $default,){
final _that = this;
switch (_that) {
case _ProPublicProfile() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function(@JsonKey(fromJson: idFromJson)  String id,  String businessName,  String fullName,  String? bio,  int experienceYears,  double ratingAvg,  int ratingCount,  int completedJobs,  DateTime? memberSince, @JsonKey(fromJson: idListFromJson, toJson: idListToJson)  List<String> categoryIds,  List<DistrictRef> districts,  List<ProDocumentType> verifiedDocuments)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ProPublicProfile() when $default != null:
return $default(_that.id,_that.businessName,_that.fullName,_that.bio,_that.experienceYears,_that.ratingAvg,_that.ratingCount,_that.completedJobs,_that.memberSince,_that.categoryIds,_that.districts,_that.verifiedDocuments);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function(@JsonKey(fromJson: idFromJson)  String id,  String businessName,  String fullName,  String? bio,  int experienceYears,  double ratingAvg,  int ratingCount,  int completedJobs,  DateTime? memberSince, @JsonKey(fromJson: idListFromJson, toJson: idListToJson)  List<String> categoryIds,  List<DistrictRef> districts,  List<ProDocumentType> verifiedDocuments)  $default,) {final _that = this;
switch (_that) {
case _ProPublicProfile():
return $default(_that.id,_that.businessName,_that.fullName,_that.bio,_that.experienceYears,_that.ratingAvg,_that.ratingCount,_that.completedJobs,_that.memberSince,_that.categoryIds,_that.districts,_that.verifiedDocuments);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function(@JsonKey(fromJson: idFromJson)  String id,  String businessName,  String fullName,  String? bio,  int experienceYears,  double ratingAvg,  int ratingCount,  int completedJobs,  DateTime? memberSince, @JsonKey(fromJson: idListFromJson, toJson: idListToJson)  List<String> categoryIds,  List<DistrictRef> districts,  List<ProDocumentType> verifiedDocuments)?  $default,) {final _that = this;
switch (_that) {
case _ProPublicProfile() when $default != null:
return $default(_that.id,_that.businessName,_that.fullName,_that.bio,_that.experienceYears,_that.ratingAvg,_that.ratingCount,_that.completedJobs,_that.memberSince,_that.categoryIds,_that.districts,_that.verifiedDocuments);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _ProPublicProfile implements ProPublicProfile {
  const _ProPublicProfile({@JsonKey(fromJson: idFromJson) required this.id, required this.businessName, required this.fullName, this.bio, this.experienceYears = 0, this.ratingAvg = 0.0, this.ratingCount = 0, this.completedJobs = 0, this.memberSince, @JsonKey(fromJson: idListFromJson, toJson: idListToJson) this.categoryIds = const <String>[], this.districts = const <DistrictRef>[], this.verifiedDocuments = const <ProDocumentType>[]});
  factory _ProPublicProfile.fromJson(Map<String, dynamic> json) => _$ProPublicProfileFromJson(json);

@override@JsonKey(fromJson: idFromJson) final  String id;
@override final  String businessName;
@override final  String fullName;
@override final  String? bio;
@override@JsonKey() final  int experienceYears;
@override@JsonKey() final  double ratingAvg;
@override@JsonKey() final  int ratingCount;
@override@JsonKey() final  int completedJobs;
@override final  DateTime? memberSince;
@override@JsonKey(fromJson: idListFromJson, toJson: idListToJson) final  List<String> categoryIds;
@override@JsonKey() final  List<DistrictRef> districts;
@override@JsonKey() final  List<ProDocumentType> verifiedDocuments;

/// Create a copy of ProPublicProfile
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ProPublicProfileCopyWith<_ProPublicProfile> get copyWith => __$ProPublicProfileCopyWithImpl<_ProPublicProfile>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ProPublicProfileToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ProPublicProfile&&(identical(other.id, id) || other.id == id)&&(identical(other.businessName, businessName) || other.businessName == businessName)&&(identical(other.fullName, fullName) || other.fullName == fullName)&&(identical(other.bio, bio) || other.bio == bio)&&(identical(other.experienceYears, experienceYears) || other.experienceYears == experienceYears)&&(identical(other.ratingAvg, ratingAvg) || other.ratingAvg == ratingAvg)&&(identical(other.ratingCount, ratingCount) || other.ratingCount == ratingCount)&&(identical(other.completedJobs, completedJobs) || other.completedJobs == completedJobs)&&(identical(other.memberSince, memberSince) || other.memberSince == memberSince)&&const DeepCollectionEquality().equals(other.categoryIds, categoryIds)&&const DeepCollectionEquality().equals(other.districts, districts)&&const DeepCollectionEquality().equals(other.verifiedDocuments, verifiedDocuments));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,businessName,fullName,bio,experienceYears,ratingAvg,ratingCount,completedJobs,memberSince,const DeepCollectionEquality().hash(categoryIds),const DeepCollectionEquality().hash(districts),const DeepCollectionEquality().hash(verifiedDocuments));

@override
String toString() {
  return 'ProPublicProfile(id: $id, businessName: $businessName, fullName: $fullName, bio: $bio, experienceYears: $experienceYears, ratingAvg: $ratingAvg, ratingCount: $ratingCount, completedJobs: $completedJobs, memberSince: $memberSince, categoryIds: $categoryIds, districts: $districts, verifiedDocuments: $verifiedDocuments)';
}


}

/// @nodoc
abstract mixin class _$ProPublicProfileCopyWith<$Res> implements $ProPublicProfileCopyWith<$Res> {
  factory _$ProPublicProfileCopyWith(_ProPublicProfile value, $Res Function(_ProPublicProfile) _then) = __$ProPublicProfileCopyWithImpl;
@override @useResult
$Res call({
@JsonKey(fromJson: idFromJson) String id, String businessName, String fullName, String? bio, int experienceYears, double ratingAvg, int ratingCount, int completedJobs, DateTime? memberSince,@JsonKey(fromJson: idListFromJson, toJson: idListToJson) List<String> categoryIds, List<DistrictRef> districts, List<ProDocumentType> verifiedDocuments
});




}
/// @nodoc
class __$ProPublicProfileCopyWithImpl<$Res>
    implements _$ProPublicProfileCopyWith<$Res> {
  __$ProPublicProfileCopyWithImpl(this._self, this._then);

  final _ProPublicProfile _self;
  final $Res Function(_ProPublicProfile) _then;

/// Create a copy of ProPublicProfile
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? businessName = null,Object? fullName = null,Object? bio = freezed,Object? experienceYears = null,Object? ratingAvg = null,Object? ratingCount = null,Object? completedJobs = null,Object? memberSince = freezed,Object? categoryIds = null,Object? districts = null,Object? verifiedDocuments = null,}) {
  return _then(_ProPublicProfile(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,businessName: null == businessName ? _self.businessName : businessName // ignore: cast_nullable_to_non_nullable
as String,fullName: null == fullName ? _self.fullName : fullName // ignore: cast_nullable_to_non_nullable
as String,bio: freezed == bio ? _self.bio : bio // ignore: cast_nullable_to_non_nullable
as String?,experienceYears: null == experienceYears ? _self.experienceYears : experienceYears // ignore: cast_nullable_to_non_nullable
as int,ratingAvg: null == ratingAvg ? _self.ratingAvg : ratingAvg // ignore: cast_nullable_to_non_nullable
as double,ratingCount: null == ratingCount ? _self.ratingCount : ratingCount // ignore: cast_nullable_to_non_nullable
as int,completedJobs: null == completedJobs ? _self.completedJobs : completedJobs // ignore: cast_nullable_to_non_nullable
as int,memberSince: freezed == memberSince ? _self.memberSince : memberSince // ignore: cast_nullable_to_non_nullable
as DateTime?,categoryIds: null == categoryIds ? _self.categoryIds : categoryIds // ignore: cast_nullable_to_non_nullable
as List<String>,districts: null == districts ? _self.districts : districts // ignore: cast_nullable_to_non_nullable
as List<DistrictRef>,verifiedDocuments: null == verifiedDocuments ? _self.verifiedDocuments : verifiedDocuments // ignore: cast_nullable_to_non_nullable
as List<ProDocumentType>,
  ));
}


}


/// @nodoc
mixin _$ReviewItem {

@JsonKey(fromJson: idFromJson) String get id; int get rating; List<String> get tags; String? get comment; String get authorDisplay; DateTime get createdAt;
/// Create a copy of ReviewItem
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ReviewItemCopyWith<ReviewItem> get copyWith => _$ReviewItemCopyWithImpl<ReviewItem>(this as ReviewItem, _$identity);

  /// Serializes this ReviewItem to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ReviewItem&&(identical(other.id, id) || other.id == id)&&(identical(other.rating, rating) || other.rating == rating)&&const DeepCollectionEquality().equals(other.tags, tags)&&(identical(other.comment, comment) || other.comment == comment)&&(identical(other.authorDisplay, authorDisplay) || other.authorDisplay == authorDisplay)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,rating,const DeepCollectionEquality().hash(tags),comment,authorDisplay,createdAt);

@override
String toString() {
  return 'ReviewItem(id: $id, rating: $rating, tags: $tags, comment: $comment, authorDisplay: $authorDisplay, createdAt: $createdAt)';
}


}

/// @nodoc
abstract mixin class $ReviewItemCopyWith<$Res>  {
  factory $ReviewItemCopyWith(ReviewItem value, $Res Function(ReviewItem) _then) = _$ReviewItemCopyWithImpl;
@useResult
$Res call({
@JsonKey(fromJson: idFromJson) String id, int rating, List<String> tags, String? comment, String authorDisplay, DateTime createdAt
});




}
/// @nodoc
class _$ReviewItemCopyWithImpl<$Res>
    implements $ReviewItemCopyWith<$Res> {
  _$ReviewItemCopyWithImpl(this._self, this._then);

  final ReviewItem _self;
  final $Res Function(ReviewItem) _then;

/// Create a copy of ReviewItem
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? rating = null,Object? tags = null,Object? comment = freezed,Object? authorDisplay = null,Object? createdAt = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,rating: null == rating ? _self.rating : rating // ignore: cast_nullable_to_non_nullable
as int,tags: null == tags ? _self.tags : tags // ignore: cast_nullable_to_non_nullable
as List<String>,comment: freezed == comment ? _self.comment : comment // ignore: cast_nullable_to_non_nullable
as String?,authorDisplay: null == authorDisplay ? _self.authorDisplay : authorDisplay // ignore: cast_nullable_to_non_nullable
as String,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}

}


/// Adds pattern-matching-related methods to [ReviewItem].
extension ReviewItemPatterns on ReviewItem {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ReviewItem value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ReviewItem() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ReviewItem value)  $default,){
final _that = this;
switch (_that) {
case _ReviewItem():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ReviewItem value)?  $default,){
final _that = this;
switch (_that) {
case _ReviewItem() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function(@JsonKey(fromJson: idFromJson)  String id,  int rating,  List<String> tags,  String? comment,  String authorDisplay,  DateTime createdAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ReviewItem() when $default != null:
return $default(_that.id,_that.rating,_that.tags,_that.comment,_that.authorDisplay,_that.createdAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function(@JsonKey(fromJson: idFromJson)  String id,  int rating,  List<String> tags,  String? comment,  String authorDisplay,  DateTime createdAt)  $default,) {final _that = this;
switch (_that) {
case _ReviewItem():
return $default(_that.id,_that.rating,_that.tags,_that.comment,_that.authorDisplay,_that.createdAt);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function(@JsonKey(fromJson: idFromJson)  String id,  int rating,  List<String> tags,  String? comment,  String authorDisplay,  DateTime createdAt)?  $default,) {final _that = this;
switch (_that) {
case _ReviewItem() when $default != null:
return $default(_that.id,_that.rating,_that.tags,_that.comment,_that.authorDisplay,_that.createdAt);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _ReviewItem implements ReviewItem {
  const _ReviewItem({@JsonKey(fromJson: idFromJson) required this.id, required this.rating, this.tags = const <String>[], this.comment, required this.authorDisplay, required this.createdAt});
  factory _ReviewItem.fromJson(Map<String, dynamic> json) => _$ReviewItemFromJson(json);

@override@JsonKey(fromJson: idFromJson) final  String id;
@override final  int rating;
@override@JsonKey() final  List<String> tags;
@override final  String? comment;
@override final  String authorDisplay;
@override final  DateTime createdAt;

/// Create a copy of ReviewItem
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ReviewItemCopyWith<_ReviewItem> get copyWith => __$ReviewItemCopyWithImpl<_ReviewItem>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ReviewItemToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ReviewItem&&(identical(other.id, id) || other.id == id)&&(identical(other.rating, rating) || other.rating == rating)&&const DeepCollectionEquality().equals(other.tags, tags)&&(identical(other.comment, comment) || other.comment == comment)&&(identical(other.authorDisplay, authorDisplay) || other.authorDisplay == authorDisplay)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,rating,const DeepCollectionEquality().hash(tags),comment,authorDisplay,createdAt);

@override
String toString() {
  return 'ReviewItem(id: $id, rating: $rating, tags: $tags, comment: $comment, authorDisplay: $authorDisplay, createdAt: $createdAt)';
}


}

/// @nodoc
abstract mixin class _$ReviewItemCopyWith<$Res> implements $ReviewItemCopyWith<$Res> {
  factory _$ReviewItemCopyWith(_ReviewItem value, $Res Function(_ReviewItem) _then) = __$ReviewItemCopyWithImpl;
@override @useResult
$Res call({
@JsonKey(fromJson: idFromJson) String id, int rating, List<String> tags, String? comment, String authorDisplay, DateTime createdAt
});




}
/// @nodoc
class __$ReviewItemCopyWithImpl<$Res>
    implements _$ReviewItemCopyWith<$Res> {
  __$ReviewItemCopyWithImpl(this._self, this._then);

  final _ReviewItem _self;
  final $Res Function(_ReviewItem) _then;

/// Create a copy of ReviewItem
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? rating = null,Object? tags = null,Object? comment = freezed,Object? authorDisplay = null,Object? createdAt = null,}) {
  return _then(_ReviewItem(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,rating: null == rating ? _self.rating : rating // ignore: cast_nullable_to_non_nullable
as int,tags: null == tags ? _self.tags : tags // ignore: cast_nullable_to_non_nullable
as List<String>,comment: freezed == comment ? _self.comment : comment // ignore: cast_nullable_to_non_nullable
as String?,authorDisplay: null == authorDisplay ? _self.authorDisplay : authorDisplay // ignore: cast_nullable_to_non_nullable
as String,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}


}

// dart format on
