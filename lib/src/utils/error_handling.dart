class AppException implements Exception {
  final String message;

  AppException(this.message);

  @override
  String toString() => message;
}

class NetworkException extends AppException {
  NetworkException(String message) : super(message);
}

class ApiException extends AppException {
  final int statusCode;

  ApiException(String message, this.statusCode) : super(message);

  @override
  String toString() => '$statusCode: $message';
}
