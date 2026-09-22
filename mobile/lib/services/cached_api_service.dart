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
      return Cached(parsed, fromCache: false, fetchedAt: DateTime.now());
    } on ApiException catch (e) {
      if (e.failure != ApiFailure.offline) rethrow;
      _connectivity.reportOffline(timedOut: e.timedOut);
      final hit = await _read(key);
      if (hit == null) throw const NotAvailableOffline();
      return Cached(parse(jsonDecode(hit.body) as Json), fromCache: true, fetchedAt: _at(hit.fetchedAt));
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
