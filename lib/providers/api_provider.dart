import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:jaspr/jaspr.dart';
import 'package:jaspr_riverpod/jaspr_riverpod.dart';
import 'package:jaspr_riverpod/legacy.dart';
import 'package:learnitin_admin/core/config/environment_config.dart';
import 'package:learnitin_admin/providers/local_storage_provider.dart';
import 'package:learnitin_admin/services/api_service.dart';

final environmentProvider = StateProvider<AppEnvironment>((ref) {
  return kDebugMode ? AppEnvironment.staging : AppEnvironment.live;
});

final dioProvider = Provider<Dio>((ref) {
  final env = ref.watch(environmentProvider);
  final baseUrl = env == AppEnvironment.live ? EnvironmentConfig.liveUrl : EnvironmentConfig.devUrl;
  final fullApiUrl = '$baseUrl/api/v1';

  final localStorage = ref.watch(localStorageProvider);
  final dio = Dio(
    BaseOptions(
      baseUrl: fullApiUrl,
      connectTimeout: const Duration(seconds: 120),
      receiveTimeout: const Duration(seconds: 120),
      contentType: Headers.jsonContentType,
      validateStatus: (status) => true,
    ),
  );

  dio.interceptors.add(
    InterceptorsWrapper(
      onRequest: (options, handler) {
        final token = localStorage.accessToken;
        if (token != null) {
          options.headers['Authorization'] = 'Bearer $token';
        }
        return handler.next(options);
      },
    ),
  );

  // JSON Logging Interceptor
  dio.interceptors.add(
    InterceptorsWrapper(
      onRequest: (options, handler) {
        print('🚀 [API Request] ${options.method} ${options.uri}');
        if (options.data != null) {
          try {
            const encoder = JsonEncoder.withIndent('  ');
            print('📦 Payload:\n${encoder.convert(options.data)}');
          } catch (_) {
            print('📦 Payload: ${options.data}');
          }
        }
        return handler.next(options);
      },
      onResponse: (response, handler) {
        print('✅ [API Response] ${response.statusCode} ${response.requestOptions.uri}');
        if (response.data != null) {
          try {
            const encoder = JsonEncoder.withIndent('  ');
            print('📄 Data:\n${encoder.convert(response.data)}');
          } catch (_) {
            print('📄 Data: ${response.data}');
          }
        }
        return handler.next(response);
      },
      onError: (err, handler) {
        print('❌ [API Error] ${err.response?.statusCode} ${err.requestOptions.uri}');
        print('⚠️ Message: ${err.message}');
        if (err.response?.data != null) {
          try {
            const encoder = JsonEncoder.withIndent('  ');
            print('📄 Error Data:\n${encoder.convert(err.response?.data)}');
          } catch (_) {
            print('📄 Error Data: ${err.response?.data}');
          }
        }
        return handler.next(err);
      },
    ),
  );

  return dio;
});

final apiServiceProvider = Provider<ApiService>((ref) {
  final dio = ref.watch(dioProvider);
  return ApiService(dio);
});
