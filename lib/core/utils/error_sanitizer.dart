import 'package:dio/dio.dart';
import 'package:learnitin_admin/core/constants/app_strings.dart';

extension ErrorSanitizer on Object? {
  /// Converts an error or exception into a user-friendly string message.
  String toFriendlyMessage() {
    final error = this;
    if (error == null) return AppStrings.unknownError;

    if (error is DioException) {
      return _handleDioError(error);
    }

    if (error is Exception) {
      // Remove 'Exception: ' prefix if present
      final msg = error.toString();
      if (msg.startsWith('Exception: ')) {
        return msg.replaceFirst('Exception: ', '');
      }
      return msg;
    }

    if (error is Error) {
      return 'A system error occurred. Please try again later.';
    }

    return error.toString();
  }

  String _handleDioError(DioException error) {
    switch (error.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return 'The connection timed out. Please check your internet and try again.';
      
      case DioExceptionType.badResponse:
        final status = error.response?.statusCode;
        final data = error.response?.data;

        // Try to extract message from backend response if it follows a common pattern
        if (data is Map && (data.containsKey('message') || data.containsKey('detail'))) {
          return (data['message'] ?? data['detail']).toString();
        }

        if (status == 401) return 'Unauthorized. Please login again.';
        if (status == 403) return 'You do not have permission to perform this action.';
        if (status == 404) return 'The requested resource was not found.';
        if (status != null && status >= 500) return 'Server error ($status). We are working to fix this.';
        
        return 'Received an invalid response from the server ($status).';

      case DioExceptionType.cancel:
        return 'The request was cancelled.';

      case DioExceptionType.connectionError:
        return 'Unable to connect to the server. Please verify your connection.';

      case DioExceptionType.badCertificate:
        return 'Secure connection failed. Please contact support if this persists.';

      case DioExceptionType.unknown:
      default:
        if (error.message?.contains('SocketException') ?? false) {
          return 'No internet connection detected.';
        }
        return 'An unexpected network error occurred.';
    }
  }
}
