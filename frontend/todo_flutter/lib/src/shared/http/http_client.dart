/// Contract for HTTP clients used across the application.
///
/// All methods return a `Map<String, dynamic>` representing the decoded JSON
/// response body, or throw an [HttpException] subclass on failure.
abstract class HttpClient {
  /// Sends a GET request to [url].
  ///
  /// Optional [headers] are merged with any default headers set by the
  /// underlying implementation.
  Future<Map<String, dynamic>> get(String url, {Map<String, String>? headers});

  /// Sends a POST request to [url] with an optional JSON [body].
  ///
  /// Optional [headers] are merged with any default headers set by the
  /// underlying implementation.
  Future<Map<String, dynamic>> post(String url, {Map<String, String>? headers, Map<String, dynamic>? body});

  /// Sends a PUT request to [url] with an optional JSON [body].
  ///
  /// Optional [headers] are merged with any default headers set by the
  /// underlying implementation.
  Future<Map<String, dynamic>> put(String url, {Map<String, String>? headers, Map<String, dynamic>? body});

  /// Sends a DELETE request to [url].
  ///
  /// Optional [headers] are merged with any default headers set by the
  /// underlying implementation.
  Future<Map<String, dynamic>> delete(String url, {Map<String, String>? headers});
}
