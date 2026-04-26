import 'package:json_annotation/json_annotation.dart';

part 'generic_api_response.g.dart';

@JsonSerializable(genericArgumentFactories: true)
class GenericApiResponse<T> {
  @JsonKey(name: 'status_code')
  final int? statusCode;
  final String? details;
  final T? data;

  GenericApiResponse({
    this.statusCode,
    this.details,
    this.data,
  });

  bool get isSuccess => data != null;

  String? getErrorMsg() => details;

  factory GenericApiResponse.fromJson(
    Map<String, dynamic> json,
    T Function(Object? json) fromJsonT,
  ) => _$GenericApiResponseFromJson(json, fromJsonT);

  Map<String, dynamic> toJson(Object? Function(T value) toJsonT) => _$GenericApiResponseToJson(this, toJsonT);
}
