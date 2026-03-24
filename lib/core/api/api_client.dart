import 'dart:convert';
import 'package:http/http.dart' as http;
import 'api_constants.dart';
import 'api_exceptions.dart';

class ApiClient {
  final http.Client _client;
  final String _baseUrl;

  ApiClient({
    http.Client? client,
    String? baseUrl,
  })  : _client = client ?? http.Client(),
        _baseUrl = baseUrl ?? ApiConstants.baseUrl;

  // GET request
  Future<dynamic> get(
    String endpoint, {
    Map<String, String>? headers,
    Map<String, dynamic>? queryParams,
  }) async {
    final uri = _buildUri(endpoint, queryParams);
    try {
      final response = await _client.get(uri, headers: _buildHeaders(headers));
      return _handleResponse(response);
    } catch (e) {
      throw ApiException(message: 'GET $endpoint failed: $e');
    }
  }

  // POST request
  Future<dynamic> post(
    String endpoint, {
    Map<String, String>? headers,
    dynamic body,
  }) async {
    final uri = _buildUri(endpoint);
    try {
      final response = await _client.post(
        uri,
        headers: _buildHeaders(headers),
        body: jsonEncode(body),
      );
      return _handleResponse(response);
    } catch (e) {
      throw ApiException(message: 'POST $endpoint failed: $e');
    }
  }

  // PUT request
  Future<dynamic> put(
    String endpoint, {
    Map<String, String>? headers,
    dynamic body,
  }) async {
    final uri = _buildUri(endpoint);
    try {
      final response = await _client.put(
        uri,
        headers: _buildHeaders(headers),
        body: jsonEncode(body),
      );
      return _handleResponse(response);
    } catch (e) {
      throw ApiException(message: 'PUT $endpoint failed: $e');
    }
  }

  // DELETE request
  Future<dynamic> delete(
    String endpoint, {
    Map<String, String>? headers,
  }) async {
    final uri = _buildUri(endpoint);
    try {
      final response = await _client.delete(uri, headers: _buildHeaders(headers));
      return _handleResponse(response);
    } catch (e) {
      throw ApiException(message: 'DELETE $endpoint failed: $e');
    }
  }

  // Build URI with query parameters
  Uri _buildUri(String endpoint, [Map<String, dynamic>? queryParams]) {
    final uri = Uri.parse('$_baseUrl$endpoint');
    if (queryParams != null && queryParams.isNotEmpty) {
      return uri.replace(
        queryParameters: queryParams.map((k, v) => MapEntry(k, v.toString())),
      );
    }
    return uri;
  }

  // Build headers with auth token
  Map<String, String> _buildHeaders(Map<String, String>? extra) {
    final headers = {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };
    if (extra != null) headers.addAll(extra);
    return headers;
  }

  // Handle HTTP response
  dynamic _handleResponse(http.Response response) {
    switch (response.statusCode) {
      case 200:
      case 201:
        if (response.body.isEmpty) return null;
        return jsonDecode(response.body);
      case 400:
        throw BadRequestException(message: response.body);
      case 401:
        throw const UnauthorizedException(message: 'Unauthorized access');
      case 403:
        throw const ForbiddenException(message: 'Forbidden');
      case 404:
        throw const NotFoundException(message: 'Resource not found');
      case 500:
        throw const ServerException(message: 'Internal server error');
      default:
        throw ApiException(
          message: 'Error ${response.statusCode}: ${response.body}',
          statusCode: response.statusCode,
        );
    }
  }

  void dispose() => _client.close();
}
