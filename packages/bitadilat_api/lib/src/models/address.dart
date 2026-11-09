import 'package:freezed_annotation/freezed_annotation.dart';

import 'json_helpers.dart';

part 'address.freezed.dart';
part 'address.g.dart';

@freezed
abstract class Address with _$Address {
  const factory Address({
    @JsonKey(fromJson: idFromJson) required String id,
    required String label,
    @JsonKey(fromJson: idFromJson) required String districtId,
    required String districtName,
    required String neighborhood,
    required String lineFull,
    String? doorNote,
    required bool isDefault,
  }) = _Address;

  factory Address.fromJson(Map<String, dynamic> json) =>
      _$AddressFromJson(json);
}
