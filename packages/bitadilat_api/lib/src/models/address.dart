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

/// `POST` ve `PATCH /me/addresses` gövdesi. `PATCH`te boş `doorNote` notu
/// temizler.
@freezed
abstract class AddressInput with _$AddressInput {
  const factory AddressInput({
    required String label,
    @JsonKey(fromJson: idFromJson, toJson: wireId) required String districtId,
    required String neighborhood,
    required String lineFull,
    @JsonKey(includeIfNull: false) String? doorNote,
    @JsonKey(includeIfNull: false) bool? isDefault,
  }) = _AddressInput;

  factory AddressInput.fromJson(Map<String, dynamic> json) =>
      _$AddressInputFromJson(json);
}
