import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:async';

import '../config/env_config.dart';
import '../utils/logger.dart';

class ApiClient {
  static final ApiClient _instance = ApiClient._internal();

  late http.Client _httpClient;
  late String _baseUrl;
  late int _timeoutSeconds;
  String? _authToken;

  factory ApiClient() {
    return _instance;
  }

  ApiClient._internal() {
    _httpClient = http.Client();
    _baseUrl = EnvConfig.apiBaseUrl();
    _timeoutSeconds = EnvConfig.apiTimeout();
  }

  /// Set authentication token for subsequent requests
  void setAuthToken(String token) {
    _authToken = token;
  }

  /// Clear authentication token
  void clearAuthToken() {
    _authToken = null;
  }

  /// Build headers with authentication if available
  Map<String, String> _buildHeaders({
    bool includeAuth = true,
    Map<String, String>? customHeaders,
  }) {
    final headers = <String, String>{
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };

    if (includeAuth && _authToken != null) {
      headers['Authorization'] = 'Bearer $_authToken';
    }

    if (customHeaders != null) {
      headers.addAll(customHeaders);
    }

    return headers;
  }

  /// GET request
  Future<ApiResponse<T>> get<T>(
    String endpoint, {
    Map<String, String>? queryParameters,
    T Function(dynamic)? fromJson,
    bool includeAuth = true,
  }) async {
    try {
      final uri = _buildUri(endpoint, queryParameters);

      if (EnvConfig.isDebugMode()) {
        Logger.debug('GET $uri', 'ApiClient.get');
      }

      final response = await _httpClient
          .get(uri, headers: _buildHeaders(includeAuth: includeAuth))
          .timeout(Duration(seconds: _timeoutSeconds));

      return _parseResponse<T>(response, fromJson);
    } on TimeoutException {
      return ApiResponse.error(
        'Request timeout. Please check your connection.',
        statusCode: 408,
      );
    } catch (e) {
      return ApiResponse.error(e.toString());
    }
  }

  /// POST request
  Future<ApiResponse<T>> post<T>(
    String endpoint, {
    Map<String, dynamic>? body,
    Map<String, String>? customHeaders,
    T Function(dynamic)? fromJson,
    bool includeAuth = true,
  }) async {
    try {
      final uri = _buildUri(endpoint);

      if (EnvConfig.isDebugMode()) {
        Logger.debug('POST $uri', 'ApiClient.post');
        if (body != null) {
          Logger.debug('Body: ${jsonEncode(body)}', 'ApiClient.post');
        }
      }

      final response = await _httpClient
          .post(
            uri,
            headers: _buildHeaders(
              includeAuth: includeAuth,
              customHeaders: customHeaders,
            ),
            body: body != null ? jsonEncode(body) : null,
          )
          .timeout(Duration(seconds: _timeoutSeconds));

      return _parseResponse<T>(response, fromJson);
    } on TimeoutException {
      return ApiResponse.error(
        'Request timeout. Please check your connection.',
        statusCode: 408,
      );
    } catch (e) {
      return ApiResponse.error(e.toString());
    }
  }

  /// PUT request
  Future<ApiResponse<T>> put<T>(
    String endpoint, {
    Map<String, dynamic>? body,
    Map<String, String>? customHeaders,
    T Function(dynamic)? fromJson,
    bool includeAuth = true,
  }) async {
    try {
      final uri = _buildUri(endpoint);

      if (EnvConfig.isDebugMode()) {
        Logger.debug('PUT $uri', 'ApiClient.put');
        if (body != null) {
          Logger.debug('Body: ${jsonEncode(body)}', 'ApiClient.put');
        }
      }

      final response = await _httpClient
          .put(
            uri,
            headers: _buildHeaders(
              includeAuth: includeAuth,
              customHeaders: customHeaders,
            ),
            body: body != null ? jsonEncode(body) : null,
          )
          .timeout(Duration(seconds: _timeoutSeconds));

      return _parseResponse<T>(response, fromJson);
    } on TimeoutException {
      return ApiResponse.error(
        'Request timeout. Please check your connection.',
        statusCode: 408,
      );
    } catch (e) {
      return ApiResponse.error(e.toString());
    }
  }

  /// PATCH request
  Future<ApiResponse<T>> patch<T>(
    String endpoint, {
    Map<String, dynamic>? body,
    Map<String, String>? customHeaders,
    T Function(dynamic)? fromJson,
    bool includeAuth = true,
  }) async {
    try {
      final uri = _buildUri(endpoint);

      if (EnvConfig.isDebugMode()) {
        Logger.debug('PATCH $uri', 'ApiClient.patch');
        if (body != null) {
          Logger.debug('Body: ${jsonEncode(body)}', 'ApiClient.patch');
        }
      }

      final response = await _httpClient
          .patch(
            uri,
            headers: _buildHeaders(
              includeAuth: includeAuth,
              customHeaders: customHeaders,
            ),
            body: body != null ? jsonEncode(body) : null,
          )
          .timeout(Duration(seconds: _timeoutSeconds));

      return _parseResponse<T>(response, fromJson);
    } on TimeoutException {
      return ApiResponse.error(
        'Request timeout. Please check your connection.',
        statusCode: 408,
      );
    } catch (e) {
      return ApiResponse.error(e.toString());
    }
  }

  /// DELETE request
  Future<ApiResponse<T>> delete<T>(
    String endpoint, {
    Map<String, dynamic>? body,
    T Function(dynamic)? fromJson,
    bool includeAuth = true,
  }) async {
    try {
      final uri = _buildUri(endpoint);

      if (EnvConfig.isDebugMode()) {
        Logger.debug('DELETE $uri', 'ApiClient.delete');
      }

      final response = await _httpClient
          .delete(
            uri,
            headers: _buildHeaders(includeAuth: includeAuth),
            body: body != null ? jsonEncode(body) : null,
          )
          .timeout(Duration(seconds: _timeoutSeconds));

      return _parseResponse<T>(response, fromJson);
    } on TimeoutException {
      return ApiResponse.error(
        'Request timeout. Please check your connection.',
        statusCode: 408,
      );
    } catch (e) {
      return ApiResponse.error(e.toString());
    }
  }

  /// Build complete URI from endpoint
  Uri _buildUri(String endpoint, [Map<String, String>? queryParameters]) {
    final url = _baseUrl + endpoint;
    return Uri.parse(url).replace(queryParameters: queryParameters);
  }

  /// Parse HTTP response
  ApiResponse<T> _parseResponse<T>(
    http.Response response,
    T Function(dynamic)? fromJson,
  ) {
    if (EnvConfig.isDebugMode()) {
      Logger.debug(
        'Response ${response.statusCode}: ${response.body}',
        'ApiClient._parseResponse',
      );
    }

    try {
      // Handle empty response
      if (response.body.isEmpty) {
        return ApiResponse.success(
          statusCode: response.statusCode,
          data: null as T,
        );
      }

      final json = jsonDecode(response.body) as Map<String, dynamic>;

      // 2xx status codes are successful
      if (response.statusCode >= 200 && response.statusCode < 300) {
        final data = fromJson != null
            ? fromJson(json['data'] ?? json)
            : null as T;
        return ApiResponse.success(
          statusCode: response.statusCode,
          data: data,
          message: json['message'] as String?,
        );
      }

      // Handle error responses
      final errorMessage =
          json['message'] as String? ??
          json['error'] as String? ??
          'An error occurred';

      return ApiResponse.error(
        errorMessage,
        statusCode: response.statusCode,
        errorCode: json['code'] as String?,
      );
    } catch (e) {
      return ApiResponse.error(
        'Failed to parse response: $e',
        statusCode: response.statusCode,
      );
    }
  }
}

/// Standard API response wrapper
class ApiResponse<T> {
  final bool success;
  final T? data;
  final String? message;
  final String? errorCode;
  final int? statusCode;

  ApiResponse({
    required this.success,
    this.data,
    this.message,
    this.errorCode,
    this.statusCode,
  });

  factory ApiResponse.success({
    required T? data,
    String? message,
    int? statusCode,
  }) {
    return ApiResponse(
      success: true,
      data: data,
      message: message,
      statusCode: statusCode,
    );
  }

  factory ApiResponse.error(
    String message, {
    String? errorCode,
    int? statusCode,
  }) {
    return ApiResponse(
      success: false,
      message: message,
      errorCode: errorCode,
      statusCode: statusCode,
    );
  }

  @override
  String toString() {
    return 'ApiResponse(success: $success, statusCode: $statusCode, message: $message, data: $data)';
  }
}
