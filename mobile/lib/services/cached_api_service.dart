import 'dart:async';
import 'dart:convert';

import 'package:drift/drift.dart';

import '../app/app.locator.dart';
import '../data/api/commuttr_api.dart';
import '../data/db/app_database.dart';
import '../data/models/models.dart';
import 'connectivity_service.dart';
import 'settings_service.dart';

/// A response, and whether it came from the network or from the device.
class Cached<T> {
  const Cached(this.data, {required this.fromCache, required this.fetchedAt});

  final T data;
  final bool fromCache;
  final DateTime fetchedAt;

  /// Older than a week: timetables may have changed since.
  bool get isStale => DateTime.now().difference(fetchedAt) > const Duration(days: 7);

  Cached<R> map<R>(R Function(T) f) => Cached(f(data), fromCache: fromCache, fetchedAt: fetchedAt);
}

/// Thrown when there is no network and nothing saved for this request.
class NotAvailableOffline implements Exception {
  const NotAvailableOffline();
}

/// Network-first reads with an SQLite fallback.
///
/// Every successful response is stored, keyed by path + normalised query. When a request
/// fails for lack of network, the stored copy is returned instead, flagged `fromCache`
/// so the UI can say when it was saved. Unpinned entries are evicted least-recently-used
/// once the cache passes [maxBytes] (plan responses carry road geometry and add up).
class CachedApiService {
  CachedApiService({AppDatabase? db, CommuttrApi? api, ConnectivityService? connectivity, SettingsService? settings})
    : _db = db ?? locator<AppDatabase>(),
      _api = api ?? locator<CommuttrApi>(),
      _connectivity = connectivity ?? locator<ConnectivityService>(),
      _settings = settings ?? locator<SettingsService>();

  final AppDatabase _db;
  final CommuttrApi _api;
  final ConnectivityService _connectivity;
  final SettingsService _settings;

  static const maxBytes = 25 * 1024 * 1024;

  static String keyFor(String path, Map<String, String>? query) {
    final q = (query?.entries.toList() ?? [])..sort((a, b) => a.key.compareTo(b.key));
    return q.isEmpty ? path : '$path?${q.map((e) => '${e.key}=${e.value}').join('&')}';
  }

  Future<Cached<T>> get<T>(
    String path, {
    Map<String, String>? query,
    required T Function(Json) parse,
    bool pin = false,
    bool cacheFirst = false,
  }) async {
    final key = keyFor(path, query);
    if (cacheFirst) {
      final hit = await _read(key);
      if (hit != null) {
        return Cached(parse(jsonDecode(hit.body) as Json), fromCache: true, fetchedAt: _at(hit.fetchedAt));
      }
    }
    try {
      final body = await _api.getRaw(path, query);
      _connectivity.reportSuccess();
      final parsed = parse(jsonDecode(body) as Json);
      await _write(key, body, pin: pin);
      unawaited(_flushPending());
      return Cached(parsed, fromCache: false, fetchedAt: DateTime.now());
    } on ApiException catch (e) {
      // A saved copy beats an error whatever went wrong. This used to rethrow on anything
      // but "offline", so a 500 or a rate-limit threw a rider's own timetable away while
      // it sat on their phone - and the screen reported a fault rather than serving it.
      //
      // Only a genuine offline marks the app offline; a server that is up but unhappy is
      // not a statement about the rider's connection.
      final recoverable = e.failure == ApiFailure.offline
          || e.failure == ApiFailure.server
          || e.failure == ApiFailure.tooBusy;
      if (!recoverable) rethrow;
      if (e.failure == ApiFailure.offline) _connectivity.reportOffline(timedOut: e.timedOut);
      final hit = await _read(key);
      // Nothing saved: the caller still needs to know WHICH thing went wrong, so the
      // original error goes on rather than being flattened into "not available offline".
      if (hit == null && e.failure != ApiFailure.offline) rethrow;
      if (hit == null) throw const NotAvailableOffline();
      final json = jsonDecode(hit.body) as Json;
      // A trip answered from the phone is a trip somebody made, and the server never
      // sees it: offline is exactly when nothing can be sent. So it waits here and goes
      // with the next request that gets through.
      unawaited(_queueOffline(path, query, json));
      return Cached(parse(json), fromCache: true, fetchedAt: _at(hit.fetchedAt));
    }
  }

  /// Best effort and never awaited: usage is not worth a rider's time or an error.
  void reportUsage(Map<String, Object?> event) {
    if (!_settings.shareUsage) return;
    unawaited(_api.post('/api/usage', event));
  }

  /// How many answers a saved response held, for the count sent later.
  static int _countIn(Json json) {
    final options = json['options'] ?? json['connections'];
    return options is List ? options.length : 0;
  }

  /// Remembered, not sent: there is no connection at this moment by definition.
  Future<void> _queueOffline(String path, Map<String, String>? query, Json json) async {
    if (!_settings.shareUsage || (path != '/api/plan' && path != '/api/connections')) return;
    final pending = _pending()
      ..add({
        'kind': 'cached_search',
        'endpoint': path,
        'result_count': _countIn(json),
        if (query?['from'] != null) 'from': int.tryParse(query!['from']!),
        if (query?['to'] != null) 'to': int.tryParse(query!['to']!),
        if (query?['from_lat'] != null) 'from_lat': double.tryParse(query!['from_lat']!),
        if (query?['from_lon'] != null) 'from_lon': double.tryParse(query!['from_lon']!),
        if (query?['to_lat'] != null) 'to_lat': double.tryParse(query!['to_lat']!),
        if (query?['to_lon'] != null) 'to_lon': double.tryParse(query!['to_lon']!),
      });
    // A phone offline for a week should not come back with a thousand of these.
    while (pending.length > 50) {
      pending.removeAt(0);
    }
    await _settings.setPendingUsage(jsonEncode(pending));
  }

  List<Map<String, Object?>> _pending() {
    final raw = _settings.pendingUsage;
    if (raw == null || raw.isEmpty) return [];
    try {
      return (jsonDecode(raw) as List).cast<Map<String, Object?>>();
    } catch (_) {
      return [];
    }
  }

  Future<void> _flushPending() async {
    final pending = _pending();
    if (pending.isEmpty || !_settings.shareUsage) return;
    await _settings.setPendingUsage(null);
    for (final event in pending) {
      await _api.post('/api/usage', event);
    }
  }

  /// Only what is stored; never touches the network.
  Future<Cached<T>?> peek<T>(String path, {Map<String, String>? query, required T Function(Json) parse}) async {
    final hit = await _read(keyFor(path, query));
    return hit == null
        ? null
        : Cached(parse(jsonDecode(hit.body) as Json), fromCache: true, fetchedAt: _at(hit.fetchedAt));
  }

  DateTime _at(int ms) => DateTime.fromMillisecondsSinceEpoch(ms);

  Future<CachedResponse?> _read(String key) async {
    final row = await (_db.select(_db.apiCache)..where((c) => c.cacheKey.equals(key))).getSingleOrNull();
    if (row != null) {
      await (_db.update(_db.apiCache)..where((c) => c.cacheKey.equals(key))).write(
        ApiCacheCompanion(lastUsedAt: Value(DateTime.now().millisecondsSinceEpoch)),
      );
    }
    return row;
  }

  Future<void> _write(String key, String body, {required bool pin}) async {
    final now = DateTime.now().millisecondsSinceEpoch;
    final existing = await (_db.select(_db.apiCache)..where((c) => c.cacheKey.equals(key))).getSingleOrNull();
    await _db
        .into(_db.apiCache)
        .insertOnConflictUpdate(
          ApiCacheCompanion.insert(
            cacheKey: key,
            body: body,
            fetchedAt: now,
            lastUsedAt: now,
            dataVersion: _settings.dataVersion ?? '',
            sizeBytes: body.length,
            pinned: Value(pin || (existing?.pinned ?? false)),
          ),
        );
    await _evict();
  }

  Future<void> _evict() async {
    final total = _db.apiCache.sizeBytes.sum();
    final size = await (_db.selectOnly(_db.apiCache)..addColumns([total])).map((r) => r.read(total) ?? 0).getSingle();
    if (size <= maxBytes) return;
    final victims =
        await (_db.select(_db.apiCache)
              ..where((c) => c.pinned.equals(false))
              ..orderBy([(c) => OrderingTerm.asc(c.lastUsedAt)]))
            .get();
    var over = size - maxBytes;
    for (final v in victims) {
      if (over <= 0) break;
      await (_db.delete(_db.apiCache)..where((c) => c.cacheKey.equals(v.cacheKey))).go();
      over -= v.sizeBytes;
    }
  }

  Future<void> setPinned(String path, Map<String, String>? query, bool pinned) => (_db.update(
    _db.apiCache,
  )..where((c) => c.cacheKey.equals(keyFor(path, query)))).write(ApiCacheCompanion(pinned: Value(pinned)));

  Future<void> clear() => _db.delete(_db.apiCache).go();

  Future<void> clearUnpinned() => (_db.delete(_db.apiCache)..where((c) => c.pinned.equals(false))).go();

  /// Total bytes stored, for the "Offline & data" screen.
  Future<int> sizeBytes() async {
    final total = _db.apiCache.sizeBytes.sum();
    return (_db.selectOnly(_db.apiCache)..addColumns([total])).map((r) => r.read(total) ?? 0).getSingle();
  }
}
