// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'generic_api_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

GenericApiResponse<T> _$GenericApiResponseFromJson<T>(
  Map<String, dynamic> json,
  T Function(Object? json) fromJsonT,
) => GenericApiResponse<T>(
  statusCode: (json['status_code'] as num?)?.toInt(),
  details: json['details'] as String?,
  data: _$nullableGenericFromJson(json['data'], fromJsonT),
);

Map<String, dynamic> _$GenericApiResponseToJson<T>(
  GenericApiResponse<T> instance,
  Object? Function(T value) toJsonT,
) => <String, dynamic>{
  'status_code': instance.statusCode,
  'details': instance.details,
  'data': _$nullableGenericToJson(instance.data, toJsonT),
};

T? _$nullableGenericFromJson<T>(
  Object? input,
  T Function(Object? json) fromJson,
) => input == null ? null : fromJson(input);

Object? _$nullableGenericToJson<T>(
  T? input,
  Object? Function(T value) toJson,
) => input == null ? null : toJson(input);
