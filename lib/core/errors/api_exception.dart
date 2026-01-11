class ApiException implements Exception {
  final String message;
  final String? code;
  final dynamic originalError;

  ApiException(this.message, {this.code, this.originalError});

  @override
  String toString() => 'ApiException: $message${code != null ? ' (code: $code)' : ''}';
}

class ApiConnectionException extends ApiException {
  ApiConnectionException(super.message, {super.originalError})
      : super(code: 'CONNECTION_ERROR');
}

class ApiNotFoundException extends ApiException {
  ApiNotFoundException(super.message, {super.originalError})
      : super(code: 'NOT_FOUND');
}

class ApiServerException extends ApiException {
  ApiServerException(super.message, {super.originalError})
      : super(code: 'SERVER_ERROR');
}

class ApiRateLimitException extends ApiException {
  final int retryAfterSeconds;

  ApiRateLimitException(
    super.message, {
    this.retryAfterSeconds = 60,
    super.originalError,
  }) : super(code: 'RATE_LIMIT');
}
