import 'package:freezed_annotation/freezed_annotation.dart';

import 'me.dart';

part 'auth_response.freezed.dart';
part 'auth_response.g.dart';

@freezed
abstract class AuthResponse with _$AuthResponse {
  const factory AuthResponse({
    required String accessToken,
    required String refreshToken,

    /// Saniye cinsinden access token ömrü.
    required int accessExpiresIn,
    required Me user,
  }) = _AuthResponse;

  factory AuthResponse.fromJson(Map<String, dynamic> json) =>
      _$AuthResponseFromJson(json);
}
