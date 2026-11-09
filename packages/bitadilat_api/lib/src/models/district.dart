import 'package:freezed_annotation/freezed_annotation.dart';

import 'json_helpers.dart';

part 'district.freezed.dart';
part 'district.g.dart';

@freezed
abstract class District with _$District {
  const factory District({
    @JsonKey(fromJson: idFromJson) required String id,
    required String name,

    /// `ANADOLU` veya `AVRUPA`.
    required String side,
  }) = _District;

  factory District.fromJson(Map<String, dynamic> json) =>
      _$DistrictFromJson(json);
}
