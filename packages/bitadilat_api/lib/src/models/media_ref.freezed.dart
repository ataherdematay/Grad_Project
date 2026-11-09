// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'media_ref.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$MediaRef {

@JsonKey(fromJson: idFromJson) String get id; String get url; DateTime get expiresAt;
/// Create a copy of MediaRef
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$MediaRefCopyWith<MediaRef> get copyWith => _$MediaRefCopyWithImpl<MediaRef>(this as MediaRef, _$identity);

  /// Serializes this MediaRef to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is MediaRef&&(identical(other.id, id) || other.id == id)&&(identical(other.url, url) || other.url == url)&&(identical(other.expiresAt, expiresAt) || other.expiresAt == expiresAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,url,expiresAt);

@override
String toString() {
  return 'MediaRef(id: $id, url: $url, expiresAt: $expiresAt)';
}


}

/// @nodoc
abstract mixin class $MediaRefCopyWith<$Res>  {
  factory $MediaRefCopyWith(MediaRef value, $Res Function(MediaRef) _then) = _$MediaRefCopyWithImpl;
@useResult
$Res call({
@JsonKey(fromJson: idFromJson) String id, String url, DateTime expiresAt
});




}
/// @nodoc
class _$MediaRefCopyWithImpl<$Res>
    implements $MediaRefCopyWith<$Res> {
  _$MediaRefCopyWithImpl(this._self, this._then);

  final MediaRef _self;
  final $Res Function(MediaRef) _then;

/// Create a copy of MediaRef
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? url = null,Object? expiresAt = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,url: null == url ? _self.url : url // ignore: cast_nullable_to_non_nullable
as String,expiresAt: null == expiresAt ? _self.expiresAt : expiresAt // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}

}


/// Adds pattern-matching-related methods to [MediaRef].
extension MediaRefPatterns on MediaRef {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _MediaRef value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _MediaRef() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _MediaRef value)  $default,){
final _that = this;
switch (_that) {
case _MediaRef():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _MediaRef value)?  $default,){
final _that = this;
switch (_that) {
case _MediaRef() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function(@JsonKey(fromJson: idFromJson)  String id,  String url,  DateTime expiresAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _MediaRef() when $default != null:
return $default(_that.id,_that.url,_that.expiresAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function(@JsonKey(fromJson: idFromJson)  String id,  String url,  DateTime expiresAt)  $default,) {final _that = this;
switch (_that) {
case _MediaRef():
return $default(_that.id,_that.url,_that.expiresAt);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function(@JsonKey(fromJson: idFromJson)  String id,  String url,  DateTime expiresAt)?  $default,) {final _that = this;
switch (_that) {
case _MediaRef() when $default != null:
return $default(_that.id,_that.url,_that.expiresAt);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _MediaRef implements MediaRef {
  const _MediaRef({@JsonKey(fromJson: idFromJson) required this.id, required this.url, required this.expiresAt});
  factory _MediaRef.fromJson(Map<String, dynamic> json) => _$MediaRefFromJson(json);

@override@JsonKey(fromJson: idFromJson) final  String id;
@override final  String url;
@override final  DateTime expiresAt;

/// Create a copy of MediaRef
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$MediaRefCopyWith<_MediaRef> get copyWith => __$MediaRefCopyWithImpl<_MediaRef>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$MediaRefToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _MediaRef&&(identical(other.id, id) || other.id == id)&&(identical(other.url, url) || other.url == url)&&(identical(other.expiresAt, expiresAt) || other.expiresAt == expiresAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,url,expiresAt);

@override
String toString() {
  return 'MediaRef(id: $id, url: $url, expiresAt: $expiresAt)';
}


}

/// @nodoc
abstract mixin class _$MediaRefCopyWith<$Res> implements $MediaRefCopyWith<$Res> {
  factory _$MediaRefCopyWith(_MediaRef value, $Res Function(_MediaRef) _then) = __$MediaRefCopyWithImpl;
@override @useResult
$Res call({
@JsonKey(fromJson: idFromJson) String id, String url, DateTime expiresAt
});




}
/// @nodoc
class __$MediaRefCopyWithImpl<$Res>
    implements _$MediaRefCopyWith<$Res> {
  __$MediaRefCopyWithImpl(this._self, this._then);

  final _MediaRef _self;
  final $Res Function(_MediaRef) _then;

/// Create a copy of MediaRef
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? url = null,Object? expiresAt = null,}) {
  return _then(_MediaRef(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,url: null == url ? _self.url : url // ignore: cast_nullable_to_non_nullable
as String,expiresAt: null == expiresAt ? _self.expiresAt : expiresAt // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}


}


/// @nodoc
mixin _$UploadedMedia {

@JsonKey(fromJson: idFromJson) String get id; String get contentType; int get sizeBytes; int? get width; int? get height;
/// Create a copy of UploadedMedia
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$UploadedMediaCopyWith<UploadedMedia> get copyWith => _$UploadedMediaCopyWithImpl<UploadedMedia>(this as UploadedMedia, _$identity);

  /// Serializes this UploadedMedia to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is UploadedMedia&&(identical(other.id, id) || other.id == id)&&(identical(other.contentType, contentType) || other.contentType == contentType)&&(identical(other.sizeBytes, sizeBytes) || other.sizeBytes == sizeBytes)&&(identical(other.width, width) || other.width == width)&&(identical(other.height, height) || other.height == height));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,contentType,sizeBytes,width,height);

@override
String toString() {
  return 'UploadedMedia(id: $id, contentType: $contentType, sizeBytes: $sizeBytes, width: $width, height: $height)';
}


}

/// @nodoc
abstract mixin class $UploadedMediaCopyWith<$Res>  {
  factory $UploadedMediaCopyWith(UploadedMedia value, $Res Function(UploadedMedia) _then) = _$UploadedMediaCopyWithImpl;
@useResult
$Res call({
@JsonKey(fromJson: idFromJson) String id, String contentType, int sizeBytes, int? width, int? height
});




}
/// @nodoc
class _$UploadedMediaCopyWithImpl<$Res>
    implements $UploadedMediaCopyWith<$Res> {
  _$UploadedMediaCopyWithImpl(this._self, this._then);

  final UploadedMedia _self;
  final $Res Function(UploadedMedia) _then;

/// Create a copy of UploadedMedia
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? contentType = null,Object? sizeBytes = null,Object? width = freezed,Object? height = freezed,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,contentType: null == contentType ? _self.contentType : contentType // ignore: cast_nullable_to_non_nullable
as String,sizeBytes: null == sizeBytes ? _self.sizeBytes : sizeBytes // ignore: cast_nullable_to_non_nullable
as int,width: freezed == width ? _self.width : width // ignore: cast_nullable_to_non_nullable
as int?,height: freezed == height ? _self.height : height // ignore: cast_nullable_to_non_nullable
as int?,
  ));
}

}


/// Adds pattern-matching-related methods to [UploadedMedia].
extension UploadedMediaPatterns on UploadedMedia {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _UploadedMedia value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _UploadedMedia() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _UploadedMedia value)  $default,){
final _that = this;
switch (_that) {
case _UploadedMedia():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _UploadedMedia value)?  $default,){
final _that = this;
switch (_that) {
case _UploadedMedia() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function(@JsonKey(fromJson: idFromJson)  String id,  String contentType,  int sizeBytes,  int? width,  int? height)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _UploadedMedia() when $default != null:
return $default(_that.id,_that.contentType,_that.sizeBytes,_that.width,_that.height);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function(@JsonKey(fromJson: idFromJson)  String id,  String contentType,  int sizeBytes,  int? width,  int? height)  $default,) {final _that = this;
switch (_that) {
case _UploadedMedia():
return $default(_that.id,_that.contentType,_that.sizeBytes,_that.width,_that.height);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function(@JsonKey(fromJson: idFromJson)  String id,  String contentType,  int sizeBytes,  int? width,  int? height)?  $default,) {final _that = this;
switch (_that) {
case _UploadedMedia() when $default != null:
return $default(_that.id,_that.contentType,_that.sizeBytes,_that.width,_that.height);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _UploadedMedia implements UploadedMedia {
  const _UploadedMedia({@JsonKey(fromJson: idFromJson) required this.id, required this.contentType, required this.sizeBytes, this.width, this.height});
  factory _UploadedMedia.fromJson(Map<String, dynamic> json) => _$UploadedMediaFromJson(json);

@override@JsonKey(fromJson: idFromJson) final  String id;
@override final  String contentType;
@override final  int sizeBytes;
@override final  int? width;
@override final  int? height;

/// Create a copy of UploadedMedia
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$UploadedMediaCopyWith<_UploadedMedia> get copyWith => __$UploadedMediaCopyWithImpl<_UploadedMedia>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$UploadedMediaToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _UploadedMedia&&(identical(other.id, id) || other.id == id)&&(identical(other.contentType, contentType) || other.contentType == contentType)&&(identical(other.sizeBytes, sizeBytes) || other.sizeBytes == sizeBytes)&&(identical(other.width, width) || other.width == width)&&(identical(other.height, height) || other.height == height));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,contentType,sizeBytes,width,height);

@override
String toString() {
  return 'UploadedMedia(id: $id, contentType: $contentType, sizeBytes: $sizeBytes, width: $width, height: $height)';
}


}

/// @nodoc
abstract mixin class _$UploadedMediaCopyWith<$Res> implements $UploadedMediaCopyWith<$Res> {
  factory _$UploadedMediaCopyWith(_UploadedMedia value, $Res Function(_UploadedMedia) _then) = __$UploadedMediaCopyWithImpl;
@override @useResult
$Res call({
@JsonKey(fromJson: idFromJson) String id, String contentType, int sizeBytes, int? width, int? height
});




}
/// @nodoc
class __$UploadedMediaCopyWithImpl<$Res>
    implements _$UploadedMediaCopyWith<$Res> {
  __$UploadedMediaCopyWithImpl(this._self, this._then);

  final _UploadedMedia _self;
  final $Res Function(_UploadedMedia) _then;

/// Create a copy of UploadedMedia
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? contentType = null,Object? sizeBytes = null,Object? width = freezed,Object? height = freezed,}) {
  return _then(_UploadedMedia(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,contentType: null == contentType ? _self.contentType : contentType // ignore: cast_nullable_to_non_nullable
as String,sizeBytes: null == sizeBytes ? _self.sizeBytes : sizeBytes // ignore: cast_nullable_to_non_nullable
as int,width: freezed == width ? _self.width : width // ignore: cast_nullable_to_non_nullable
as int?,height: freezed == height ? _self.height : height // ignore: cast_nullable_to_non_nullable
as int?,
  ));
}


}

// dart format on
