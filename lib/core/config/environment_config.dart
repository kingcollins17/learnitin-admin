class EnvironmentConfig {
  static final EnvironmentConfig _instance = EnvironmentConfig._internal();

  factory EnvironmentConfig() => _instance;

  EnvironmentConfig._internal();

  final String baseUrl = 'https://learnitin-api-982845074244.us-central1.run.app';
  final String apiVersion = 'v1';

  String get fullApiUrl => '$baseUrl/api/$apiVersion';
}
