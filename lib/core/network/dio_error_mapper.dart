import 'package:dio/dio.dart';

import '../error/exceptions.dart';

/// Translates a low-level [DioException] into one of our typed [AppException]s.
///
/// Centralised so every data source maps transport errors consistently and the
/// repository/Bloc layers never need to inspect Dio details.
AppException mapDioException(DioException error) {
  switch (error.type) {
    case DioExceptionType.connectionTimeout:
    case DioExceptionType.sendTimeout:
    case DioExceptionType.receiveTimeout:
    case DioExceptionType.transformTimeout:
      return const NetworkException('The connection timed out.');

    case DioExceptionType.connectionError:
      return const NetworkException();

    case DioExceptionType.cancel:
      return const NetworkException('The request was cancelled.');

    case DioExceptionType.badCertificate:
      return const NetworkException('Invalid server certificate.');

    case DioExceptionType.badResponse:
      final statusCode = error.response?.statusCode;
      if (statusCode == 404) {
        return const NotFoundException();
      }
      return ServerException(
        'Server responded with status ${statusCode ?? 'unknown'}.',
        statusCode,
      );

    case DioExceptionType.unknown:
      // Usually a SocketException (no network) wrapped by Dio.
      return const NetworkException();
  }
}
