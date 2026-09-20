import 'dart:convert';

import 'package:drift/drift.dart';
import 'package:stacked/stacked.dart';

import '../app/app.locator.dart';
import '../data/db/app_database.dart';
import '../data/models/models.dart';

enum PlaceKind { home, work, other }

class SavedPlace {
  SavedPlace(Place row)
    : id = row.id,
      kind = PlaceKind.values.asNameMap()[row.kind] ?? PlaceKind.other,
      label = row.label,
      endpoint = Endpoint.fromJson(jsonDecode(row.endpointJson) as Json);

  final String id;
  final PlaceKind kind;
  final String label;
  final Endpoint endpoint;
}

class TripPair {
  const TripPair(this.id, this.from, this.to, {this.timesSearched = 0});

  final String id;
  final Endpoint from;
  final Endpoint to;
  final int timesSearched;

  String get title => '${from.displayName} → ${to.displayName}';
}

/// Home, Work, saved trips and search history — all on this device.
class FavouritesService with ListenableServiceMixin {
  FavouritesService({AppDatabase? db}) : _db = db ?? locator<AppDatabase>();

  final AppDatabase _db;

  Future<List<SavedPlace>> places() async => (await (_db.select(
    _db.places,
  )..orderBy([(p) => OrderingTerm.asc(p.createdAt)])).get()).map(SavedPlace.new).toList();

  Future<SavedPlace?> place(PlaceKind kind) async => (await places()).where((p) => p.kind == kind).firstOrNull;

  Future<void> setPlace(PlaceKind kind, Endpoint endpoint, {String? label}) async {
    if (kind != PlaceKind.other) {
      await (_db.delete(_db.places)..where((p) => p.kind.equals(kind.name))).go();
    }
    await _db
        .into(_db.places)
        .insert(
          PlacesCompanion.insert(
            id: kind == PlaceKind.other ? 'other-${DateTime.now().microsecondsSinceEpoch}' : kind.name,
            kind: kind.name,
            label:
                label ??
                switch (kind) {
                  PlaceKind.home => 'Home',
                  PlaceKind.work => 'Work',
                  _ => endpoint.displayName,
                },
            endpointJson: jsonEncode(endpoint.toJson()),
            createdAt: DateTime.now().millisecondsSinceEpoch,
          ),
        );
    notifyListeners();
  }

  Future<void> removePlace(String id) async {
    await (_db.delete(_db.places)..where((p) => p.id.equals(id))).go();
    notifyListeners();
  }

  static String pairId(Endpoint from, Endpoint to) => '${from.cacheKey}|${to.cacheKey}';

  Future<List<TripPair>> savedTrips() async {
    final rows = await (_db.select(_db.savedTrips)..orderBy([(t) => OrderingTerm.desc(t.createdAt)])).get();
    return rows
        .map(
          (r) => TripPair(
            r.id,
            Endpoint.fromJson(jsonDecode(r.fromEndpoint) as Json),
            Endpoint.fromJson(jsonDecode(r.toEndpoint) as Json),
          ),
        )
        .toList();
  }

  Future<bool> isSaved(Endpoint from, Endpoint to) async =>
      await _db.savedTrips.count(where: (t) => t.id.equals(pairId(from, to))).getSingle() > 0;

  Future<void> toggleSavedTrip(Endpoint from, Endpoint to) async {
    final id = pairId(from, to);
    if (await isSaved(from, to)) {
      await (_db.delete(_db.savedTrips)..where((t) => t.id.equals(id))).go();
    } else {
      await _db
          .into(_db.savedTrips)
          .insert(
            SavedTripsCompanion.insert(
              id: id,
              fromEndpoint: jsonEncode(from.toJson()),
              toEndpoint: jsonEncode(to.toJson()),
              createdAt: DateTime.now().millisecondsSinceEpoch,
            ),
          );
    }
    notifyListeners();
  }

  Future<void> recordSearch(Endpoint from, Endpoint to) async {
    final id = pairId(from, to);
    final now = DateTime.now().millisecondsSinceEpoch;
    final existing = await (_db.select(_db.recentSearches)..where((r) => r.id.equals(id))).getSingleOrNull();
    if (existing == null) {
      await _db
          .into(_db.recentSearches)
          .insert(
            RecentSearchesCompanion.insert(
              id: id,
              fromEndpoint: jsonEncode(from.toJson()),
              toEndpoint: jsonEncode(to.toJson()),
              lastSearchedAt: now,
            ),
          );
    } else {
      await (_db.update(_db.recentSearches)..where((r) => r.id.equals(id))).write(
        RecentSearchesCompanion(timesSearched: Value(existing.timesSearched + 1), lastSearchedAt: Value(now)),
      );
    }
    notifyListeners();
  }

  /// Most recent first.
  Future<List<TripPair>> recentSearches({int limit = 8}) =>
      _searches([(r) => OrderingTerm.desc(r.lastSearchedAt)], limit);

  /// Most searched first — "Your frequent trips".
  Future<List<TripPair>> frequentTrips({int limit = 5}) =>
      _searches([(r) => OrderingTerm.desc(r.timesSearched), (r) => OrderingTerm.desc(r.lastSearchedAt)], limit);

  Future<List<TripPair>> _searches(List<OrderClauseGenerator<$RecentSearchesTable>> order, int limit) async {
    final rows =
        await (_db.select(_db.recentSearches)
              ..orderBy(order)
              ..limit(limit))
            .get();
    return rows
        .map(
          (r) => TripPair(
            r.id,
            Endpoint.fromJson(jsonDecode(r.fromEndpoint) as Json),
            Endpoint.fromJson(jsonDecode(r.toEndpoint) as Json),
            timesSearched: r.timesSearched,
          ),
        )
        .toList();
  }

  Future<void> clearHistory() async {
    await _db.delete(_db.recentSearches).go();
    notifyListeners();
  }

  // ---------------------------------------------------------------- export / import

  Future<Json> exportAll() async => {
    'places': (await _db.select(_db.places).get()).map((r) => r.toJson()).toList(),
    'saved_trips': (await _db.select(_db.savedTrips).get()).map((r) => r.toJson()).toList(),
    'recent_searches': (await _db.select(_db.recentSearches).get()).map((r) => r.toJson()).toList(),
  };

  Future<void> importAll(Json j) async {
    List<Json> rows(String k) => ((j[k] as List?) ?? const []).cast<Json>();
    await _db.batch((b) {
      b.insertAllOnConflictUpdate(_db.places, rows('places').map(Place.fromJson));
      b.insertAllOnConflictUpdate(_db.savedTrips, rows('saved_trips').map(SavedTrip.fromJson));
      b.insertAllOnConflictUpdate(_db.recentSearches, rows('recent_searches').map(RecentSearch.fromJson));
    });
    notifyListeners();
  }
}
