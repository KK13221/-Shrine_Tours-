import 'package:dio/dio.dart';
import 'package:shrine_tours/core/di/injection.dart';
import 'package:shrine_tours/features/auth/domain/repositories/auth_repository.dart';
import 'package:shrine_tours/features/auth/domain/repositories/token_storage_repo.dart';
import 'api_constants.dart';

class DioConfig {
  static Dio createDio() {
    final dio = Dio(
      BaseOptions(
        baseUrl: ApiConstants.baseUrl,
        connectTimeout: ApiConstants.connectionTimeout,
        receiveTimeout: ApiConstants.receiveTimeout,
        contentType: 'application/json',
        headers: {
          'Accept': 'application/json',
          'Content-Type': 'application/json',
        },
      ),
    );

    // Add interceptors
    dio.interceptors.add(TokenInterceptor(dio));
    dio.interceptors.add(LoggingInterceptor());

    return dio;
  }
}

/// Interceptor for handling auth tokens
class TokenInterceptor extends Interceptor {
  final Dio _dio;

  TokenInterceptor(this._dio);

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    // Define paths that don't need a token
    final unauthenticatedPaths = [
      ApiConstants.login,
      ApiConstants.register,
      ApiConstants.googleSignIn,
      ApiConstants.refreshToken,
      // Add other unauthenticated paths here if needed (e.g. forgot-password)
    ];

    final isUnauthenticated = unauthenticatedPaths.any((path) => options.path.contains(path));

    if (!isUnauthenticated) {
      final storage = getIt<TokenStorageRepo>();
      final tokens = storage.getTokens();
      
      if (tokens != null) {
        options.headers['Authorization'] = 'Bearer ${tokens.accessToken}';
      }
    }
    
    super.onRequest(options, handler);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    // Handle 401 - token expired
    if (err.response?.statusCode == 401) {
      try {
        final authRepo = getIt<AuthRepository>();
        final success = await authRepo.refreshToken();
        
        if (success) {
          final storage = getIt<TokenStorageRepo>();
          final tokens = storage.getTokens();
          
          if (tokens != null) {
            // Update the header with the new token
            err.requestOptions.headers['Authorization'] = 'Bearer ${tokens.accessToken}';
            
            // Retry the original request
            final retryResponse = await _dio.fetch(err.requestOptions);
            return handler.resolve(retryResponse);
          }
        }
      } catch (e) {
        // Fall back to rejecting if the refresh failed
        return handler.next(err);
      }
    }
    
    return handler.next(err);
  }
}

/// Logging interceptor for debugging
class LoggingInterceptor extends Interceptor {
  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    print('╔═══════════════════════════════════════════════════════════════');
    print('║ REQUEST: ${options.method} ${options.path}');
    print('├─ URL: ${options.uri}');
    print('├─ Headers: ${options.headers}');
    if (options.data != null) {
      print('├─ Body: ${options.data}');
    }
    print('╚═══════════════════════════════════════════════════════════════');
    super.onRequest(options, handler);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    print('╔═══════════════════════════════════════════════════════════════');
    print('║ RESPONSE: ${response.statusCode} ${response.requestOptions.path}');
    print('├─ Data: ${response.data}');
    print('╚═══════════════════════════════════════════════════════════════');
    super.onResponse(response, handler);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    print('╔═══════════════════════════════════════════════════════════════');
    print('║ ERROR: ${err.type} - ${err.message}');
    print('├─ Status Code: ${err.response?.statusCode}');
    print('├─ Path: ${err.requestOptions.path}');
    if (err.response?.data != null) {
      print('├─ Response: ${err.response?.data}');
    }
    print('╚═══════════════════════════════════════════════════════════════');
    super.onError(err, handler);
  }
}
