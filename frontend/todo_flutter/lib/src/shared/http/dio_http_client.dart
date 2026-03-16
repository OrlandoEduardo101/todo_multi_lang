import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:todo_flutter/src/modules/auth/stores/auth_session_store.dart';
import 'package:todo_flutter/src/shared/http/interceptors/auth_interceptor.dart';
import 'http_client.dart';
import 'http_exception.dart';

/// [HttpClient] implementation backed by the [Dio] HTTP package.
///
/// Configures default JSON headers, maps [DioException]s to typed
/// [HttpException] subclasses, and normalises every response body to a
/// `Map<String, dynamic>`.
class DioHttpClient implements HttpClient {
  final Dio _dio;

  /// Base URL prepended to every request path.
  final String baseUrl;

  final AuthSessionStore authSessionStore;

  /// Creates a [DioHttpClient].
  ///
  /// A custom [dio] instance can be injected for testing. When omitted a
  /// default [Dio] instance is used.
  DioHttpClient({Dio? dio, required this.authSessionStore, this.baseUrl = 'http://localhost:3000'})
    : _dio = dio ?? Dio() {
    start();
  }

  final Map<String, String> _defaultHeaders = {'Content-Type': 'application/json', 'Accept': 'application/json'};

  /// Configures [_dio] with the base URL and the global error-handling interceptor.
  void start() {
    // final Options options = Options(headers: _defaultHeaders, responseType: ResponseType.json);

    _dio.options.baseUrl = baseUrl;

    _dio.options.headers.addAll(_defaultHeaders);

    _dio.interceptors.add(AuthInterceptor(authSessionStore));
  }

  /// {@macro HttpClient.delete}
  @override
  Future<Map<String, dynamic>> delete(String url, {Map<String, String>? headers}) async {
    try {
      final response = await _dio.delete(url, options: Options(headers: headers));
      dynamic data = response.data;

      data = dataCheckMap(data);

      return data;
    } on DioException catch (e) {
      HttpException exception = errorCheckMapper(e);
      throw exception;
    }
  }

  /// {@macro HttpClient.get}
  @override
  Future<Map<String, dynamic>> get(String url, {Map<String, String>? headers}) async {
    try {
      final response = await _dio.get(url, options: Options(headers: headers));
      dynamic data = response.data;
      data = dataCheckMap(data);
      return data;
    } on DioException catch (e) {
      HttpException exception = errorCheckMapper(e);
      throw exception;
    }
  }

  /// {@macro HttpClient.post}
  @override
  Future<Map<String, dynamic>> post(String url, {Map<String, String>? headers, Map<String, dynamic>? body}) async {
    try {
      final response = await _dio.post(
        url,
        data: body,
        options: Options(headers: headers),
      );
      dynamic data = response.data;
      data = dataCheckMap(data);
      return data;
    } on DioException catch (e) {
      HttpException exception = errorCheckMapper(e);
      throw exception;
    }
  }

  /// {@macro HttpClient.put}
  @override
  Future<Map<String, dynamic>> put(String url, {Map<String, String>? headers, Map<String, dynamic>? body}) async {
    try {
      final response = await _dio.put(
        url,
        data: body,
        options: Options(headers: headers),
      );
      dynamic data = response.data;
      data = dataCheckMap(data);
      return data;
    } on DioException catch (e) {
      HttpException exception = errorCheckMapper(e);
      throw exception;
    }
  }

  /// Maps a [DioException] to the appropriate [HttpException] subclass.
  ///
  /// Returns [UnauthorizedException] for 401, a generic [HttpException] for
  /// any other known status code, or a plain [HttpException] when no response
  /// is available.
  HttpException errorCheckMapper(DioException e) {
    // Interceptor already typed this error — unwrap directly.
    if (e.error is HttpException) return e.error as HttpException;

    if (e.response?.statusCode == 401) {
      return UnauthorizedException('Unauthorized: ${e.message}', statusCode: e.response?.statusCode ?? 401);
    } else if (e.response?.statusCode != null) {
      return HttpException(
        'Failed to perform ${e.requestOptions.method} request: ${e.message}',
        statusCode: e.response?.statusCode,
      );
    } else {
      return NetworkException('No internet connection');
    }
  }

  /// Normalises [data] to a `Map<String, dynamic>`.
  ///
  /// - Strings are JSON-decoded.
  /// - Lists are wrapped under the key `"data"`.
  /// - Maps are returned as a new copy.
  /// - Any other type throws [HttpException].
  dataCheckMap(data) {
    if (data is String) {
      data = jsonDecode(data);
    } else if (data is List) {
      data = <String, dynamic>{'data': data};
    } else if (data is Map<String, dynamic>) {
      data = Map<String, dynamic>.from(data);
    } else {
      throw HttpException('Invalid response format: expected a JSON object');
    }
    return data;
  }
}
