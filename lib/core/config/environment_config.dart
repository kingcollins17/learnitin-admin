import 'package:jaspr/jaspr.dart';

enum AppEnvironment { live, staging }

class EnvironmentConfig {
  static final EnvironmentConfig _instance = EnvironmentConfig._internal(
    baseUrl: kDebugMode ? devUrl : liveUrl,
  );

  factory EnvironmentConfig() => _instance;

  EnvironmentConfig._internal({required this.baseUrl});

  static const liveUrl = 'https://learnitin-api-982845074244.us-central1.run.app';
  static const devUrl = 'https://learnitin-api.onrender.com';

  final String baseUrl;
  final String apiVersion = 'v1';

  String get fullApiUrl => '$baseUrl/api/$apiVersion';
}

final enviroment = EnvironmentConfig();
