import 'package:freezed_annotation/freezed_annotation.dart';

import 'json_helpers.dart';

part 'category.freezed.dart';
part 'category.g.dart';

@freezed
abstract class Category with _$Category {
  const factory Category({
    @JsonKey(fromJson: idFromJson) required String id,
    required String nameTr,
    required String nameEn,
    required String icon,
    required String colorHex,
    required int sortOrder,
  }) = _Category;

  factory Category.fromJson(Map<String, dynamic> json) =>
      _$CategoryFromJson(json);
}
