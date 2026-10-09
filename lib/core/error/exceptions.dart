/// Typed exceptions thrown by the data layer.
///
/// The repository implementation is responsible for translating low-level
/// errors (e.g. [DioException], parsing errors) into one of these, so the
/// presentation layer (Cubit/Bloc) can map them to user-facing states without
/// knowing anything about HTTP or JSON.
library;

/// Base type for every expected failure in the app.
///
/// Sealed so Bloc/Cubit can exhaustively switch over the known cases.
sealed class AppException implements Exception {
  const AppException(this.message);

  /// Human-readable, developer-facing description. UI copy is decided in the
  /// presentation layer, not here.
  final String message;

  @override
  String toString() => '$runtimeType: $message';
}

/// No connectivity, timeout, or the request was cancelled.
class NetworkException extends AppException {
  const NetworkException([super.message = 'No internet connection.']);
}

/// The server answered with a non-success status code (5xx, unexpected 4xx…).
class ServerException extends AppException {
  const ServerException([
    super.message = 'Unexpected server error.',
    this.statusCode,
  ]);

  final int? statusCode;
}

/// The requested resource does not exist (HTTP 404).
class NotFoundException extends AppException {
  const NotFoundException([super.message = 'Resource not found.']);
}

/// The response could not be parsed/mapped into a domain entity.
class ParsingException extends AppException {
  const ParsingException([super.message = 'Failed to read server response.']);
}
