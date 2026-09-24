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

  /// The service asked us to slow down (429). Nothing is wrong with the request or the
  /// rider's connection, and trying again shortly will work.
  ///
  /// This used to fall into [badRequest], whose whole meaning is "retrying will not help",
  /// so a rate-limited rider was told their stops were the problem and offered no retry.
  tooBusy,
}

class ApiException implements Exception {
  const ApiException(this.failure, this.message, {this.statusCode, this.timedOut = false});

  final ApiFailure failure;
  final String message;
  final int? statusCode;

  /// No answer in time. Still worth the cache, but a slow request is not proof the
  /// phone has lost its connection.
  final bool timedOut;

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

  /// POST [body] as JSON, for the usage the server cannot see for itself. Best effort:
  /// it never throws, because nothing a rider is doing depends on it.
  Future<void> post(String path, Map<String, Object?> body);

  /// Sent with every request while the rider leaves sharing on: an id this app made, and
  /// which front end is asking. Null clears them.
  void identify({String? deviceId, String? client});
}

class HttpCommuttrApi implements CommuttrApi {
  // 30 s, not 15: a search between two places in the city centre takes 15-16 s on the
  // current planner (it reads every trip through ~120 nearby stops at each end), and at
  // 15 it timed out and the rider was told they were offline.
  HttpCommuttrApi({http.Client? client, String? baseUrl, this.timeout = const Duration(seconds: 30)})
    : _client = client ?? http.Client(),
      _baseUrl = baseUrl ?? AppConfig.apiBaseUrl;

  final http.Client _client;
  final String _baseUrl;
  final Duration timeout;
  String? _deviceId;
  String? _client_;

  @override
  void identify({String? deviceId, String? client}) {
    _deviceId = deviceId;
    _client_ = client;
  }

  Map<String, String> get _headers => {
    'Accept': 'application/json',
    'X-Commuttr-Device': ?_deviceId,
    'X-Commuttr-Client': ?_client_,
  };

  @override
  Future<void> post(String path, Map<String, Object?> body) async {
    try {
      await _client
          .post(
            Uri.parse('$_baseUrl$path'),
            headers: {..._headers, 'Content-Type': 'application/json'},
            body: jsonEncode(body),
          )
          .timeout(const Duration(seconds: 10));
    } catch (_) {
      // Usage is never worth an error on a commuter's screen.
    }
  }

  @override
  Future<String> getRaw(String path, [Map<String, String>? query]) async {
    final uri = Uri.parse('$_baseUrl$path').replace(queryParameters: query);
    final http.Response res;
    try {
      res = await _client.get(uri, headers: _headers).timeout(timeout);
    } on TimeoutException {
      throw const ApiException(ApiFailure.offline, 'The request timed out.', timedOut: true);
    } on http.ClientException catch (e) {
      throw ApiException(ApiFailure.offline, e.message);
    } catch (e) {
      // SocketException and friends: dart:io is unavailable on web, so match loosely.
      throw ApiException(ApiFailure.offline, '$e');
    }
    if (res.statusCode >= 500) {
      throw ApiException(ApiFailure.server, 'Server error', statusCode: res.statusCode);
    }
    if (res.statusCode == 429) {
      throw ApiException(ApiFailure.tooBusy, 'The service is busy.', statusCode: 429);
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
