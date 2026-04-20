import 'package:dio/dio.dart';
import 'api_exceptions.dart';
import 'dio_config.dart';

class ApiClient {
  late final Dio _dio;

  ApiClient({Dio? dio}) {
    _dio = dio ?? DioConfig.createDio();
  }

  /// GET request
  Future<dynamic> get(
    String endpoint, {
    Map<String, String>? headers,
    Map<String, dynamic>? queryParams,
  }) async {
    try {
      final response = await _dio.get(
        endpoint,
        queryParameters: queryParams,
        options: Options(headers: headers),
      );
      return _handleResponse(response);
    } on DioException catch (e) {
      throw _handleDioException(e);
    } catch (e) {
      throw ApiException(message: 'GET $endpoint failed: $e');
    }
  }

  /// POST request
  Future<dynamic> post(
    String endpoint, {
    Map<String, String>? headers,
    dynamic body,
  }) async {
    try {
      final response = await _dio.post(
        endpoint,
        data: body,
        options: Options(headers: headers),
      );
      return _handleResponse(response);
    } on DioException catch (e) {
      throw _handleDioException(e);
    } catch (e) {
      throw ApiException(message: 'POST $endpoint failed: $e');
    }
  }

  /// PUT request
  Future<dynamic> put(
    String endpoint, {
    Map<String, String>? headers,
    dynamic body,
  }) async {
    try {
      final response = await _dio.put(
        endpoint,
        data: body,
        options: Options(headers: headers),
      );
      return _handleResponse(response);
    } on DioException catch (e) {
      throw _handleDioException(e);
    } catch (e) {
      throw ApiException(message: 'PUT $endpoint failed: $e');
    }
  }

  /// DELETE request
  Future<dynamic> delete(
    String endpoint, {
    Map<String, String>? headers,
    dynamic body,
  }) async {
    try {
      final response = await _dio.delete(
        endpoint,
        options: Options(headers: headers),
        data: body,
      );
      return _handleResponse(response);
    } on DioException catch (e) {
      throw _handleDioException(e);
    } catch (e) {
      throw ApiException(message: 'DELETE $endpoint failed: $e');
    }
  }

  /// Multipart upload request
  Future<dynamic> uploadFile(
    String endpoint, {
    Map<String, String>? headers,
    required String fieldName,
    required dynamic file,
    Map<String, dynamic>? additionalFields,
  }) async {
    try {
      final formData = FormData();

      // Add the file
      if (file is MultipartFile) {
        formData.files.add(MapEntry(fieldName, file));
      } else if (file is String) {
        // Assume it's a file path
        formData.files.add(MapEntry(
          fieldName,
          await MultipartFile.fromFile(file),
        ));
      }

      // Add additional fields if any
      if (additionalFields != null) {
        formData.fields.addAll(additionalFields.entries.map(
          (e) => MapEntry(e.key, e.value.toString()),
        ));
      }

      final response = await _dio.post(
        endpoint,
        data: formData,
        options: Options(headers: headers),
      );
      return _handleResponse(response);
    } on DioException catch (e) {
      throw _handleDioException(e);
    } catch (e) {
      throw ApiException(message: 'UPLOAD $endpoint failed: $e');
    }
  }

  /// Download file request
  Future<dynamic> downloadFile(
    String endpoint,
    String savePath, {
    Map<String, String>? headers,
    ProgressCallback? onReceiveProgress,
  }) async {
    try {
      final response = await _dio.download(
        endpoint,
        savePath,
        options: Options(headers: headers),
        onReceiveProgress: onReceiveProgress,
      );
      return response;
    } on DioException catch (e) {
      throw _handleDioException(e);
    } catch (e) {
      throw ApiException(message: 'DOWNLOAD $endpoint failed: $e');
    }
  }

  /// Handle successful HTTP response
  dynamic _handleResponse(Response response) {
    final statusCode = response.statusCode ?? 200;

    if (statusCode == 200 || statusCode == 201) {
      if (response.data == null ||
          (response.data as dynamic)?.isEmpty == true) {
        return null;
      }
      return response.data;
    }

    // This should rarely happen due to DioException handling
    throw ApiException(
      message: 'Unexpected status code: $statusCode',
      statusCode: statusCode,
    );
  }

  /// Convert DioException to ApiException
  ApiException _handleDioException(DioException dioException) {
    final statusCode = dioException.response?.statusCode;
    final responseData = dioException.response?.data;

    // Extract error message from response if available
    String errorMessage = _extractErrorMessage(responseData);

    switch (dioException.type) {
      case DioExceptionType.connectionTimeout:
        return TimeoutException(message: 'Connection timeout: $errorMessage');

      case DioExceptionType.sendTimeout:
        return TimeoutException(message: 'Send timeout: $errorMessage');

      case DioExceptionType.receiveTimeout:
        return TimeoutException(message: 'Receive timeout: $errorMessage');

      case DioExceptionType.badResponse:
        // Handle different HTTP status codes
        switch (statusCode) {
          case 400:
            return BadRequestException(message: errorMessage);
          case 401:
            return UnauthorizedException(message: errorMessage);
          case 403:
            return ForbiddenException(message: errorMessage);
          case 404:
            return NotFoundException(message: errorMessage);
          case 500:
            return ServerException(message: errorMessage);
          default:
            return ApiException(
              message: 'HTTP Error: $errorMessage',
              statusCode: statusCode,
            );
        }

      case DioExceptionType.connectionError:
        return NetworkException(
            message: 'Network error: ${dioException.message}');

      case DioExceptionType.cancel:
        return ApiException(message: 'Request cancelled');

      case DioExceptionType.badCertificate:
        return NetworkException(
            message: 'Bad certificate: ${dioException.message}');

      case DioExceptionType.unknown:
        return NetworkException(
          message: 'Unknown error: ${dioException.message}',
        );
    }
  }

  /// Extract error message from response data
  String _extractErrorMessage(dynamic responseData) {
    try {
      if (responseData is Map<String, dynamic>) {
        // Try common error message field names
        if (responseData.containsKey('message')) {
          return responseData['message'] as String? ?? 'An error occurred';
        }
        if (responseData.containsKey('error')) {
          return responseData['error'] as String? ?? 'An error occurred';
        }
        if (responseData.containsKey('detail')) {
          return responseData['detail'] as String? ?? 'An error occurred';
        }
      }
      if (responseData is String) {
        return responseData;
      }
    } catch (e) {
      // Fallback if parsing fails
    }
    return 'An error occurred';
  }

  /// Close and cleanup
  void dispose() => _dio.close();
}
