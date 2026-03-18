class ApiException implements Exception {
  final String message;
  final int? statusCode;

  const ApiException({required this.message, this.statusCode});

  @override
  String toString() => 'ApiException($statusCode): $message';
}

class BadRequestException extends ApiException {
  const BadRequestException({required super.message}) : super(statusCode: 400);
}

class UnauthorizedException extends ApiException {
  const UnauthorizedException({required super.message}) : super(statusCode: 401);
}

class ForbiddenException extends ApiException {
  const ForbiddenException({required super.message}) : super(statusCode: 403);
}

class NotFoundException extends ApiException {
  const NotFoundException({required super.message}) : super(statusCode: 404);
}

class ServerException extends ApiException {
  const ServerException({required super.message}) : super(statusCode: 500);
}

class NetworkException extends ApiException {
  const NetworkException({required super.message}) : super(statusCode: null);
}

class TimeoutException extends ApiException {
  const TimeoutException({required super.message}) : super(statusCode: null);
}
