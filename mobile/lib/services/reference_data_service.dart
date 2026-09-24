import 'dart:convert';
import 'dart:math' as math;

import 'package:drift/drift.dart';
import 'package:flutter/services.dart' show rootBundle;

import '../app/app.locator.dart';
import '../core/service_day.dart';
import '../data/api/commuttr_api.dart';
import '../data/db/app_database.dart';
import '../data/models/models.dart';
import 'connectivity_service.dart';
import 'settings_service.dart';

/// Operators, stops and stations, routes, timetable headers and footnotes: small,
/// slow-changing data that the app keeps entirely on the device.
///
/// First launch loads the snapshot bundled in `assets/seed/seed.json` — so stop search,
/// route browsing and "does this bus run today?" all work before the phone has ever been
/// online. When online, stops and routes are refreshed in the background.
class ReferenceDataService {
  ReferenceDataService({AppDatabase? db, CommuttrApi? api, SettingsService? settings})
    : _db = db ?? locator<AppDatabase>(),
      _api = api ?? locator<CommuttrApi>(),
      _settings = settings ?? locator<SettingsService>();

  final AppDatabase _db;
  final CommuttrApi _api;
  final SettingsService _settings;

  static const seedAsset = 'assets/seed/seed.json';

  /// Footnote legends by timetable number, cached in memory (~2k rows).
  Map<String, Map<String, String>>? _notesByNumber;

  /// Load the bundled snapshot if the database has none, or a different one.
  Future<void> seedIfNeeded({String? assetJson}) async {
    final raw = assetJson ?? await rootBundle.loadString(seedAsset);
    final seed = jsonDecode(raw) as Json;
    final version = seed['version'] as String;
    final current = _settings.dataVersion;
    final hasStops =
        (await (_db.selectOnly(
          _db.stops,
        )..addColumns([_db.stops.id.count()])).map((r) => r.read(_db.stops.id.count())).getSingle()) !=
        0;
    // Any difference means a new app release shipped different data (a new operator, new
    // timetables), so load it. Online refreshes don't touch the version.
    if (hasStops && current == version) return;

    await _db.transaction(() async {
      await _replaceOperators(((seed['operators'] as List?) ?? const []).cast<Json>());
      await _replaceStops((seed['stops'] as List).cast<Json>());
      await _replaceRoutes((seed['routes'] as List).cast<Json>());
      await _db.delete(_db.timetables).go();
      await _db.batch((b) => b.insertAll(_db.timetables, (seed['timetables'] as List).cast<Json>().map(_timetableRow)));
      await _db.delete(_db.timetableNotes).go();
      await _db.batch(
        (b) => b.insertAll(
          _db.timetableNotes,
          (seed['notes'] as List).cast<Json>().map(
            (n) => TimetableNotesCompanion.insert(
              timetableId: n['timetable_id'] as int,
              code: (n['code'] as String).toLowerCase(),
              description: (n['description'] as String?) ?? '',
            ),
          ),
        ),
      );
    });
    _notesByNumber = null;
    await _settings.setDataVersion(version);
  }

  TimetablesCompanion _timetableRow(Json t) => TimetablesCompanion.insert(
    id: Value(t['id'] as int),
    routeId: t['route_id'] as int,
    timetableNumber: (t['timetable_number'] as String?) ?? '',
    isPublicHoliday: Value(t['is_public_holiday'] == true),
    effectiveFrom: Value(t['effective_from'] as String?),
    effectiveTo: Value(t['effective_to'] as String?),
    pdfUrl: Value(t['pdf_url'] as String?),
  );

  Future<void> _replaceOperators(List<Json> rows) async {
    if (rows.isEmpty) return;
    await _db.delete(_db.operators).go();
    await _db.batch(
      (b) => b.insertAll(
        _db.operators,
        rows.map(
          (o) => OperatorsCompanion.insert(
            code: o['code'] as String,
            name: o['name'] as String,
            kind: o['kind'] as String,
            routeCount: Value((o['routes'] as num?)?.toInt() ?? 0),
          ),
        ),
      ),
    );
  }

  Future<void> _replaceStops(List<Json> rows) async {
    final valid = rows.where((s) => s['lat'] != null && s['lon'] != null).toList();
    if (valid.isEmpty) return;
    await _db.delete(_db.stops).go();
    await _db.batch(
      (b) => b.insertAll(
        _db.stops,
        valid.map(
          (s) => StopsCompanion.insert(
            id: Value(s['id'] as int),
            name: s['name'] as String,
            lat: (s['lat'] as num).toDouble(),
            lon: (s['lon'] as num).toDouble(),
            operatorCode: Value((s['operator_code'] as String?) ?? 'gabs'),
            operatorKind: Value((s['operator_kind'] as String?) ?? 'bus'),
          ),
        ),
      ),
    );
  }

  Future<void> _replaceRoutes(List<Json> rows) async {
    if (rows.isEmpty) return;
    // /api/routes says whose route it is, but an older API does not (the seed always does).
    // Failing that, keep what we already know per id so a refresh never turns a train line
    // into a bus route — then per name, because reloading an operator's timetables gives
    // every route a new id but not a new name: all 47 MyCiTi routes came back under ids
    // the app had never seen, were filed under Golden Arrow, and the MyCiTi list was empty.
    // A route we have not seen at all is a train line when it is named like one.
    final existing = await _db.select(_db.busRoutes).get();
    final known = {for (final r in existing) r.id: r.operatorCode};
    final knownByName = {for (final r in existing) r.name: r.operatorCode};
    String operatorOf(Json r) =>
        (r['operator_code'] as String?) ??
        known[r['id'] as int] ??
        knownByName[r['name']] ??
        (RegExp(r'^[A-Z ]+ LINE:').hasMatch((r['name'] as String?) ?? '') ? 'metrorail' : 'gabs');
    await _db.delete(_db.busRoutes).go();
    await _db.batch(
      (b) => b.insertAll(
        _db.busRoutes,
        rows.map(
          (r) => BusRoutesCompanion.insert(
            id: Value(r['id'] as int),
            name: (r['name'] as String?) ?? '',
            origin: (r['origin'] as String?) ?? '',
            destination: (r['destination'] as String?) ?? '',
            letterGroup: (r['letter_group'] as String?) ?? '',
            timetableCount: Value((r['timetable_count'] as num?)?.toInt() ?? 0),
            operatorCode: Value(operatorOf(r)),
          ),
        ),
      ),
    );
  }

  /// Pull the latest stops and routes. Timetable headers refresh per route, on demand.
  /// Returns false when offline; never throws.
  Future<bool> refresh() async {
    try {
      final stops = jsonDecode(await _api.getRaw('/api/stops', {'q': '', 'limit': '100000'})) as Json;
      final routes = jsonDecode(await _api.getRaw('/api/routes')) as Json;
      final operators = jsonDecode(await _api.getRaw('/api/operators')) as Json;
      await _db.transaction(() async {
        await _replaceOperators(((operators['operators'] as List?) ?? const []).cast<Json>());
        await _replaceStops((stops['stops'] as List).cast<Json>());
        await _replaceRoutes((routes['routes'] as List).cast<Json>());
      });
      await _settings.setLastRefresh(DateTime.now());
      locator<ConnectivityService>().reportSuccess();
      return true;
    } on ApiException catch (e) {
      if (e.failure == ApiFailure.offline) locator<ConnectivityService>().reportOffline(timedOut: e.timedOut);
      return false;
    } catch (_) {
      return false;
    }
  }

  /// Refresh one route's timetable headers (new PDFs, new effective dates).
  Future<void> refreshRoute(int routeId) async {
    try {
      final j = jsonDecode(await _api.getRaw('/api/routes/$routeId')) as Json;
      final rows = (j['timetables'] as List).cast<Json>().where((t) => t['parse_status'] == 'parsed');
      await _db.transaction(() async {
        await (_db.delete(_db.timetables)..where((t) => t.routeId.equals(routeId))).go();
        await _db.batch(
          (b) => b.insertAll(_db.timetables, rows.map((t) => _timetableRow({...t, 'route_id': routeId}))),
        );
      });
    } catch (_) {
      // Keep what we have.
    }
  }

  Future<int> stopCount() => _db.stops.count().getSingle();

  // ---------------------------------------------------------------- operators

  /// Operators with timetables in Commuttr, in the order the database lists them.
  Future<List<OperatorRef>> operators() async {
    final rows = await _db.select(_db.operators).get();
    if (rows.isEmpty) return const [OperatorRef.goldenArrow];
    return rows.map((o) => OperatorRef.from(o.code, name: o.name, kind: o.kind)).toList();
  }

  Future<Map<String, int>> routeCounts() async => {
    for (final o in await _db.select(_db.operators).get()) o.code: o.routeCount,
  };

  StopDto _stop(Stop r) => StopDto(
    id: r.id,
    name: r.name,
    lat: r.lat,
    lon: r.lon,
    operatorCode: r.operatorCode,
    operatorKind: r.operatorKind,
  );

  // ---------------------------------------------------------------- stops

  Future<List<StopDto>> searchStops(String query, {int limit = 30}) async {
    final q = query.trim().toUpperCase();
    final sel = _db.select(_db.stops)..orderBy([(s) => OrderingTerm.asc(s.name)]);
    if (q.isNotEmpty) {
      // Prefix matches first, then anywhere in the name.
      sel.where((s) => s.name.upper().like('%$q%'));
    }
    sel.limit(q.isEmpty ? 500 : 200);
    final rows = await sel.get();
    final out = rows.map(_stop).toList();
    if (q.isNotEmpty) {
      out.sort((a, b) {
        final ap = a.name.toUpperCase().startsWith(q) ? 0 : 1;
        final bp = b.name.toUpperCase().startsWith(q) ? 0 : 1;
        return ap != bp ? ap - bp : a.name.compareTo(b.name);
      });
    }
    return out.take(limit).toList();
  }

  Future<StopDto?> stopById(int id) async {
    final r = await (_db.select(_db.stops)..where((s) => s.id.equals(id))).getSingleOrNull();
    return r == null ? null : _stop(r);
  }

  /// Stops nearest a point, with distance in metres. Works offline.
  Future<List<(StopDto, double)>> nearestStops(double lat, double lon, {int limit = 10}) async {
    final rows = await _db.select(_db.stops).get();
    final scored = rows.map((r) => (_stop(r), distanceMetres(lat, lon, r.lat, r.lon))).toList()
      ..sort((a, b) => a.$2.compareTo(b.$2));
    return scored.take(limit).toList();
  }

  /// Stops called exactly [name] (any case) within [maxMetres] of a point, with distance.
  /// "Main Road" is a stop in several suburbs, so only the ones near the place count.
  Future<List<(StopDto, double)>> stopsNamed(String name, double lat, double lon, {double maxMetres = 8000}) async {
    final n = name.trim().toUpperCase();
    if (n.isEmpty) return const [];
    final rows = await (_db.select(_db.stops)..where((s) => s.name.upper().equals(n))).get();
    return [
      for (final r in rows)
        if (distanceMetres(lat, lon, r.lat, r.lon) <= maxMetres) (_stop(r), distanceMetres(lat, lon, r.lat, r.lon)),
    ];
  }

  /// Each operator's closest stop to a point, nearest first, leaving out any further than
  /// [maxMetres]. Someone near a bus stop and a station can take either, and the few
  /// closest stops overall are usually all one operator's.
  Future<List<(StopDto, double)>> nearestStopPerOperator(double lat, double lon, {double maxMetres = 5000}) async {
    final best = <String, (StopDto, double)>{};
    for (final r in await _db.select(_db.stops).get()) {
      final d = distanceMetres(lat, lon, r.lat, r.lon);
      if (d > maxMetres) continue;
      final held = best[r.operatorCode];
      if (held == null || d < held.$2) best[r.operatorCode] = (_stop(r), d);
    }
    return best.values.toList()..sort((a, b) => a.$2.compareTo(b.$2));
  }

  // ---------------------------------------------------------------- routes & timetables

  /// Routes whose name matches [query], optionally only one operator's.
  Future<List<RouteSummary>> searchRoutes(String query, {String? operatorCode}) async {
    final q = query.trim().toUpperCase();
    final sel = _db.select(_db.busRoutes)..orderBy([(r) => OrderingTerm.asc(r.name)]);
    if (q.isNotEmpty) sel.where((r) => r.name.upper().like('%$q%'));
    if (operatorCode != null) sel.where((r) => r.operatorCode.equals(operatorCode));
    return (await sel.get())
        .map(
          (r) => RouteSummary(
            id: r.id,
            name: r.name,
            origin: r.origin,
            destination: r.destination,
            letterGroup: r.letterGroup,
            timetableCount: r.timetableCount,
            operatorCode: r.operatorCode,
          ),
        )
        .toList();
  }

  Future<RouteSummary?> routeById(int id) async => (await searchRoutes('')).where((r) => r.id == id).firstOrNull;

  Future<List<TimetableInfo>> timetablesForRoute(int routeId) async {
    final rows =
        await (_db.select(_db.timetables)
              ..where((t) => t.routeId.equals(routeId))
              ..orderBy([(t) => OrderingTerm.desc(t.effectiveFrom)]))
            .get();
    return rows.map(_info).toList();
  }

  /// The timetable in force on [date] for a route number, preferring the regular
  /// (non-holiday) PDF. Falls back to the newest one we know of.
  /// The timetable a rider should be shown for [timetableNumber] on [date].
  ///
  /// [publicHoliday] says which SHEET the journey came from, which is not the same
  /// question as what day it is. A route can publish a separate public holiday sheet with
  /// its own times, and this used to prefer the ordinary one outright - so on a public
  /// holiday the app offered a rider the 22:00 holiday bus and then opened a PDF that has
  /// no 22:00 in it, because that departure exists only on the holiday sheet. They
  /// reasonably concluded the app had made the time up.
  Future<TimetableInfo?> currentTimetable(
    String timetableNumber,
    ServiceDate date, {
    bool publicHoliday = false,
  }) async {
    // Train timetables are unnumbered: an empty number would match every one of them.
    if (timetableNumber.isEmpty) return null;
    final rows =
        await (_db.select(_db.timetables)
              ..where((t) => t.timetableNumber.equals(timetableNumber))
              ..orderBy([(t) => OrderingTerm.desc(t.effectiveFrom)]))
            .get();
    if (rows.isEmpty) return null;
    final infos = rows.map(_info).toList();
    bool inForce(TimetableInfo t) =>
        (t.effectiveFrom == null || t.effectiveFrom!.compareTo(date.iso) <= 0) &&
        (t.effectiveTo == null || t.effectiveTo!.compareTo(date.iso) >= 0);
    // The sheet the journey actually came from first; then any sheet in force; then
    // whatever we hold, so a rider is never left with no timetable at all.
    return infos.where((t) => inForce(t) && t.isPublicHoliday == publicHoliday).firstOrNull ??
        infos.where(inForce).firstOrNull ??
        infos.first;
  }

  TimetableInfo _info(Timetable r) => TimetableInfo(
    id: r.id,
    routeId: r.routeId,
    timetableNumber: r.timetableNumber,
    isPublicHoliday: r.isPublicHoliday,
    effectiveFrom: r.effectiveFrom,
    effectiveTo: r.effectiveTo,
    pdfUrl: r.pdfUrl,
  );

  /// Footnote legend for a route number: code -> description.
  Future<Map<String, String>> notesFor(String timetableNumber) async {
    if (timetableNumber.isEmpty) return const {};
    _notesByNumber ??= await _loadNotes();
    return _notesByNumber![timetableNumber] ?? const {};
  }

  Future<Map<String, Map<String, String>>> _loadNotes() async {
    final q = _db.select(_db.timetableNotes).join([
      innerJoin(_db.timetables, _db.timetables.id.equalsExp(_db.timetableNotes.timetableId)),
    ])..orderBy([OrderingTerm.asc(_db.timetables.effectiveFrom)]);
    final out = <String, Map<String, String>>{};
    for (final row in await q.get()) {
      final t = row.readTable(_db.timetables);
      final n = row.readTable(_db.timetableNotes);
      // Later timetables overwrite earlier ones, so the newest legend wins.
      (out[t.timetableNumber] ??= {})[n.code] = n.description;
    }
    return out;
  }
}

/// Great-circle distance in metres.
double distanceMetres(double lat1, double lon1, double lat2, double lon2) {
  const r = 6371000.0;
  final p1 = lat1 * math.pi / 180, p2 = lat2 * math.pi / 180;
  final dp = (lat2 - lat1) * math.pi / 180, dl = (lon2 - lon1) * math.pi / 180;
  final a = math.sin(dp / 2) * math.sin(dp / 2) + math.cos(p1) * math.cos(p2) * math.sin(dl / 2) * math.sin(dl / 2);
  return 2 * r * math.asin(math.sqrt(a));
}
