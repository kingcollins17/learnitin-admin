// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'log_entry.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_LogEntry _$LogEntryFromJson(Map<String, dynamic> json) => _LogEntry(
  id: (json['id'] as num?)?.toInt(),
  level: json['level'] as String?,
  message: json['message'] as String?,
  data: json['data'] as Map<String, dynamic>?,
  createdAt: json['created_at'] == null
      ? null
      : DateTime.parse(json['created_at'] as String),
);

Map<String, dynamic> _$LogEntryToJson(_LogEntry instance) => <String, dynamic>{
  'id': instance.id,
  'level': instance.level,
  'message': instance.message,
  'data': instance.data,
  'created_at': instance.createdAt?.toIso8601String(),
};
