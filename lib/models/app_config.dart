import 'package:freezed_annotation/freezed_annotation.dart';

part 'app_config.freezed.dart';
part 'app_config.g.dart';

@freezed
abstract class AppConfig with _$AppConfig {
  const factory AppConfig({
    int? id,
    String? key,
    String? value,
    dynamic metadata,
    @JsonKey(name: 'created_at') DateTime? createdAt,
    @JsonKey(name: 'updated_at') DateTime? updatedAt,
  }) = _AppConfig;

  factory AppConfig.fromJson(Map<String, dynamic> json) => _$AppConfigFromJson(json);
}

@freezed
abstract class CreateAppConfig with _$CreateAppConfig {
  const factory CreateAppConfig({
    required String key,
    required String value,
    @JsonKey(name: 'metadata_json') Map<String, dynamic>? metadata,
  }) = _CreateAppConfig;

  factory CreateAppConfig.fromJson(Map<String, dynamic> json) => _$CreateAppConfigFromJson(json);
}

@freezed
abstract class UpdateAppConfig with _$UpdateAppConfig {
  const factory UpdateAppConfig({
    String? key,
    String? value,
    @JsonKey(name: 'metadata_json') Map<String, dynamic>? metadata,
  }) = _UpdateAppConfig;

  factory UpdateAppConfig.fromJson(Map<String, dynamic> json) => _$UpdateAppConfigFromJson(json);
}
