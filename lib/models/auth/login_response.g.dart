// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'login_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

LoginResponse _$LoginResponseFromJson(Map<String, dynamic> json) =>
    LoginResponse(
      accessToken: json['access_token'] as String?,
      tokenType: json['token_type'] as String?,
      userId: (json['user_id'] as num?)?.toInt(),
      email: json['email'] as String?,
      username: json['username'] as String?,
      isActive: json['is_active'] as bool?,
      detail: json['detail'] as String?,
    );

Map<String, dynamic> _$LoginResponseToJson(LoginResponse instance) =>
    <String, dynamic>{
      'access_token': instance.accessToken,
      'token_type': instance.tokenType,
      'user_id': instance.userId,
      'email': instance.email,
      'username': instance.username,
      'detail': instance.detail,
      'is_active': instance.isActive,
    };
