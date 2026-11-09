// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'requests.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_RegisterRequest _$RegisterRequestFromJson(Map<String, dynamic> json) =>
    _RegisterRequest(
      fullName: json['fullName'] as String,
      email: json['email'] as String,
      phone: json['phone'] as String,
      password: json['password'] as String,
      wantsPro: json['wantsPro'] as bool,
      kvkkAccepted: json['kvkkAccepted'] as bool,
      termsAccepted: json['termsAccepted'] as bool,
    );

Map<String, dynamic> _$RegisterRequestToJson(_RegisterRequest instance) =>
    <String, dynamic>{
      'fullName': instance.fullName,
      'email': instance.email,
      'phone': instance.phone,
      'password': instance.password,
      'wantsPro': instance.wantsPro,
      'kvkkAccepted': instance.kvkkAccepted,
      'termsAccepted': instance.termsAccepted,
    };

_LoginRequest _$LoginRequestFromJson(Map<String, dynamic> json) =>
    _LoginRequest(
      identifier: json['identifier'] as String,
      password: json['password'] as String,
    );

Map<String, dynamic> _$LoginRequestToJson(_LoginRequest instance) =>
    <String, dynamic>{
      'identifier': instance.identifier,
      'password': instance.password,
    };

_RefreshRequest _$RefreshRequestFromJson(Map<String, dynamic> json) =>
    _RefreshRequest(refreshToken: json['refreshToken'] as String);

Map<String, dynamic> _$RefreshRequestToJson(_RefreshRequest instance) =>
    <String, dynamic>{'refreshToken': instance.refreshToken};

_ForgotPasswordRequest _$ForgotPasswordRequestFromJson(
  Map<String, dynamic> json,
) => _ForgotPasswordRequest(email: json['email'] as String);

Map<String, dynamic> _$ForgotPasswordRequestToJson(
  _ForgotPasswordRequest instance,
) => <String, dynamic>{'email': instance.email};

_ResetPasswordRequest _$ResetPasswordRequestFromJson(
  Map<String, dynamic> json,
) => _ResetPasswordRequest(
  email: json['email'] as String,
  code: json['code'] as String,
  newPassword: json['newPassword'] as String,
);

Map<String, dynamic> _$ResetPasswordRequestToJson(
  _ResetPasswordRequest instance,
) => <String, dynamic>{
  'email': instance.email,
  'code': instance.code,
  'newPassword': instance.newPassword,
};

_UpdateMeRequest _$UpdateMeRequestFromJson(Map<String, dynamic> json) =>
    _UpdateMeRequest(
      fullName: json['fullName'] as String?,
      locale: json['locale'] as String?,
      lastMode: $enumDecodeNullable(_$UserModeEnumMap, json['lastMode']),
    );

Map<String, dynamic> _$UpdateMeRequestToJson(_UpdateMeRequest instance) =>
    <String, dynamic>{
      'fullName': ?instance.fullName,
      'locale': ?instance.locale,
      'lastMode': ?_$UserModeEnumMap[instance.lastMode],
    };

const _$UserModeEnumMap = {UserMode.customer: 'CUSTOMER', UserMode.pro: 'PRO'};

_ChangePasswordRequest _$ChangePasswordRequestFromJson(
  Map<String, dynamic> json,
) => _ChangePasswordRequest(
  currentPassword: json['currentPassword'] as String,
  newPassword: json['newPassword'] as String,
);

Map<String, dynamic> _$ChangePasswordRequestToJson(
  _ChangePasswordRequest instance,
) => <String, dynamic>{
  'currentPassword': instance.currentPassword,
  'newPassword': instance.newPassword,
};
