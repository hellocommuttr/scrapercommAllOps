import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;

import '../../core/config.dart';

/// Why a request failed, in terms the UI can act on.
enum ApiFailure {
  /// No connection, DNS failure, or timeout — worth falling back to the cache.
  offline,

  /// The server answered with an error.
  server,

  /// The request itself was rejected (4xx): retrying will not help.
  badRequest,
}

class ApiException implements Exception {
  const ApiException(this.failure, this.message, {this.statusCode});

  final ApiFailure failure;
  final String message;
  final int? statusCode;

  /// A short code support can ask for, e.g. "E-OFFLINE" or "E-500".
  String get code => switch (failure) {
    ApiFailure.offline => 'E-OFFLINE',
    _ => 'E-${statusCode ?? 'UNKNOWN'}',
  };

  @override
  String toString() => 'ApiException($code): $message';
}

/// Raw access to the read-only Commuttr API. Returns decoded JSON bodies as text-backed
/// maps; repositories own parsing and caching. An interface so tests can fake it.
abstract interface class CommuttrApi {
  /// GET [path] with [query]; returns the raw response body.
  Future<String> getRaw(String path, [Map<String, String>? query]);
}

class HttpCommuttrApi implements CommuttrApi {
  HttpCommuttrApi({http.Client? client, String? baseUrl, this.timeout = const Duration(seconds: 15)})
    : _client = client ?? http.Client(),
      _baseUrl = baseUrl ?? AppConfig.apiBaseUrl;

  final http.Client _client;
  final String _baseUrl;
  final Duration timeout;

  @override
  Future<String> getRaw(String path, [Map<String, String>? query]) async {
    final uri = Uri.parse('$_baseUrl$path').replace(queryParameters: query);
    final http.Response res;
    try {
      res = await _client.get(uri, headers: const {'Accept': 'application/json'}).timeout(timeout);
    } on TimeoutException {
      throw const ApiException(ApiFailure.offline, 'The request timed out.');
    } on http.ClientException catch (e) {
      throw ApiException(ApiFailure.offline, e.message);
    } catch (e) {
      // SocketException and friends: dart:io is unavailable on web, so match loosely.
      throw ApiException(ApiFailure.offline, '$e');
    }
    if (res.statusCode >= 500) {
      throw ApiException(ApiFailure.server, 'Server error', statusCode: res.statusCode);
    }
    if (res.statusCode >= 400) {
      String detail = res.reasonPhrase ?? 'Bad request';
      try {
        final body = jsonDecode(utf8.decode(res.bodyBytes));
        if (body is Map && body['detail'] is String) detail = body['detail'] as String;
      } catch (_) {}
      throw ApiException(ApiFailure.badRequest, detail, statusCode: res.statusCode);
    }
    return utf8.decode(res.bodyBytes);
  }
}
