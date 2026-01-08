class ApiException implements Exception {
  final String message;
  final String? code;
  final dynamic originalError;

  ApiException(this.message, {this.code, this.originalError});

  @override
  String toString() => 'ApiException: $message${code != null ? ' (code: $code)' : ''}';
}

class ApiConnectionException extends ApiException {
  ApiConnectionException(String message, {dynamic originalError})
      : super(message, code: 'CONNECTION_ERROR', originalError: originalError);
}

class ApiNotFoundException extends ApiException {
  ApiNotFoundException(String message, {dynamic originalError})
      : super(message, code: 'NOT_FOUND', originalError: originalError);
}

class ApiServerException extends ApiException {
  ApiServerException(String message, {dynamic originalError})
      : super(message, code: 'SERVER_ERROR', originalError: originalError);
}
