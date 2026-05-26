// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_config.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_AppConfig _$AppConfigFromJson(Map<String, dynamic> json) => _AppConfig(
  id: (json['id'] as num?)?.toInt(),
  key: json['key'] as String?,
  value: json['value'] as String?,
  metadata: json['metadata'],
  createdAt: json['created_at'] == null
      ? null
      : DateTime.parse(json['created_at'] as String),
  updatedAt: json['updated_at'] == null
      ? null
      : DateTime.parse(json['updated_at'] as String),
);

Map<String, dynamic> _$AppConfigToJson(_AppConfig instance) =>
    <String, dynamic>{
      'id': instance.id,
      'key': instance.key,
      'value': instance.value,
      'metadata': instance.metadata,
      'created_at': instance.createdAt?.toIso8601String(),
      'updated_at': instance.updatedAt?.toIso8601String(),
    };

_CreateAppConfig _$CreateAppConfigFromJson(Map<String, dynamic> json) =>
    _CreateAppConfig(
      key: json['key'] as String,
      value: json['value'] as String,
      metadata: json['metadata_json'] as Map<String, dynamic>?,
    );

Map<String, dynamic> _$CreateAppConfigToJson(_CreateAppConfig instance) =>
    <String, dynamic>{
      'key': instance.key,
      'value': instance.value,
      'metadata_json': instance.metadata,
    };

_UpdateAppConfig _$UpdateAppConfigFromJson(Map<String, dynamic> json) =>
    _UpdateAppConfig(
      key: json['key'] as String?,
      value: json['value'] as String?,
      metadata: json['metadata_json'] as Map<String, dynamic>?,
    );

Map<String, dynamic> _$UpdateAppConfigToJson(_UpdateAppConfig instance) =>
    <String, dynamic>{
      'key': instance.key,
      'value': instance.value,
      'metadata_json': instance.metadata,
    };
