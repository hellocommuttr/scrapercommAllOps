import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';

part 'app_database.g.dart';

// ---------------------------------------------------------------- reference data (seeded)

/// Who runs the service: Golden Arrow (bus), Metrorail (train), later others.
class Operators extends Table {
  TextColumn get code => text()(); // 'gabs', 'metrorail'
  TextColumn get name => text()();
  TextColumn get kind => text()(); // 'bus' | 'train'
  IntColumn get routeCount => integer().withDefault(const Constant(0))();

  @override
  Set<Column> get primaryKey => {code};
}

/// Named bus timing points and train stations. The same place name can appear once per
/// operator ("CAPE TOWN" the bus terminus and "CAPE TOWN" the station), so the operator
/// is part of what a stop is. Seeded from the bundled snapshot, refreshed online.
class Stops extends Table {
  IntColumn get id => integer()();
  TextColumn get name => text()();
  RealColumn get lat => real()();
  RealColumn get lon => real()();
  TextColumn get operatorCode => text().withDefault(const Constant('gabs'))();
  TextColumn get operatorKind => text().withDefault(const Constant('bus'))();

  @override
  Set<Column> get primaryKey => {id};
}

class BusRoutes extends Table {
  IntColumn get id => integer()();
  TextColumn get name => text()();
  TextColumn get origin => text()();
  TextColumn get destination => text()();
  TextColumn get letterGroup => text()();
  IntColumn get timetableCount => integer().withDefault(const Constant(0))();
  TextColumn get operatorCode => text().withDefault(const Constant('gabs'))();

  @override
  Set<Column> get primaryKey => {id};
}

/// Timetable headers: which PDF is current, and from when.
class Timetables extends Table {
  IntColumn get id => integer()();
  IntColumn get routeId => integer()();
  TextColumn get timetableNumber => text()();
  BoolColumn get isPublicHoliday => boolean().withDefault(const Constant(false))();
  TextColumn get effectiveFrom => text().nullable()();
  TextColumn get effectiveTo => text().nullable()();
  TextColumn get pdfUrl => text().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}

/// Footnote legends per timetable ("b" -> "Fridays").
class TimetableNotes extends Table {
  IntColumn get timetableId => integer()();
  TextColumn get code => text()();
  TextColumn get description => text()();

  @override
  Set<Column> get primaryKey => {timetableId, code};
}

// ---------------------------------------------------------------- cache

/// Responses kept so a search that worked once keeps working offline.
@DataClassName('CachedResponse')
class ApiCache extends Table {
  TextColumn get cacheKey => text()();
  TextColumn get body => text()();
  IntColumn get fetchedAt => integer()(); // epoch ms
  IntColumn get lastUsedAt => integer()(); // epoch ms, for least-recently-used eviction
  TextColumn get dataVersion => text()();
  IntColumn get sizeBytes => integer()();

  /// Pinned entries (the saved commute, planner trips) are never evicted.
  BoolColumn get pinned => boolean().withDefault(const Constant(false))();

  @override
  Set<Column> get primaryKey => {cacheKey};
}

// ---------------------------------------------------------------- the commuter's own data

/// A bus ride on the commuter's planner. Carries a snapshot of the ride's stop times, so
/// it stays readable offline and survives a re-scrape renumbering schedule ids.
class SavedJourneys extends Table {
  TextColumn get id => text()();
  TextColumn get serviceDate => text()(); // yyyy-mm-dd, Cape Town
  TextColumn get fromEndpoint => text()();
  TextColumn get toEndpoint => text()();
  TextColumn get routeLabel => text()();
  TextColumn get operatorCode => text().withDefault(const Constant('gabs'))();
  TextColumn get operatorName => text().withDefault(const Constant('Golden Arrow Buses'))();
  TextColumn get operatorKind => text().withDefault(const Constant('bus'))();
  IntColumn get cashFareCents => integer().nullable()();
  TextColumn get timetableNumber => text()();
  TextColumn get dayType => text()();
  TextColumn get dayLabel => text()();
  TextColumn get boardRaw => text()();
  TextColumn get arriveRaw => text()();
  RealColumn get boardMinutes => real()();
  RealColumn get arriveMinutes => real().nullable()();
  BoolColumn get boardApprox => boolean()();
  BoolColumn get arriveApprox => boolean()();
  IntColumn get scheduleId => integer()();
  IntColumn get tripIndex => integer()();
  IntColumn get fromSeq => integer()();
  IntColumn get toSeq => integer()();
  TextColumn get tripSnapshot => text().nullable()(); // TripStopsResponse JSON
  TextColumn get status => text().withDefault(const Constant('planned'))(); // planned|active|completed
  IntColumn get reminderLeadMinutes => integer().nullable()();
  TextColumn get groupId => text().nullable()(); // legs of one connection share a group
  // Where the rider gets on and off when it is a point on the road ("between A and B"),
  // so a saved trip can still say the bus is not sure to stop there. Null before v3.
  TextColumn get boardLabel => text().nullable()();
  TextColumn get alightLabel => text().nullable()();
  IntColumn get createdAt => integer()();
  IntColumn get completedAt => integer().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}

/// Home, Work, and other saved places.
class Places extends Table {
  TextColumn get id => text()();
  TextColumn get kind => text()(); // home|work|other
  TextColumn get label => text()();
  TextColumn get endpointJson => text()();
  IntColumn get createdAt => integer()();

  @override
  Set<Column> get primaryKey => {id};
}

/// Trips the commuter saved as favourites ("Bellville -> Cape Town").
class SavedTrips extends Table {
  TextColumn get id => text()();
  TextColumn get fromEndpoint => text()();
  TextColumn get toEndpoint => text()();
  IntColumn get createdAt => integer()();

  @override
  Set<Column> get primaryKey => {id};
}

/// Searches the commuter ran; the most frequent become "Your frequent trips".
@DataClassName('RecentSearch')
class RecentSearches extends Table {
  TextColumn get id => text()(); // fromKey|toKey
  TextColumn get fromEndpoint => text()();
  TextColumn get toEndpoint => text()();
  IntColumn get timesSearched => integer().withDefault(const Constant(1))();
  IntColumn get lastSearchedAt => integer()();

  @override
  Set<Column> get primaryKey => {id};
}

/// The in-app inbox. Not push: these are written by the app itself.
class InboxMessages extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get kind => text()(); // update|reminder|info
  TextColumn get title => text()();
  TextColumn get body => text()();
  IntColumn get createdAt => integer()();
  BoolColumn get isRead => boolean().withDefault(const Constant(false))();
}

/// Small settings and flags.
class KeyValues extends Table {
  TextColumn get key => text()();
  TextColumn get value => text()();

  @override
  Set<Column> get primaryKey => {key};
}

@DriftDatabase(
  tables: [
    Operators,
    Stops,
    BusRoutes,
    Timetables,
    TimetableNotes,
    ApiCache,
    SavedJourneys,
    Places,
    SavedTrips,
    RecentSearches,
    InboxMessages,
    KeyValues,
  ],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase([QueryExecutor? executor]) : super(executor ?? _open());

  static QueryExecutor _open() => driftDatabase(
    name: 'commuttr',
    web: DriftWebOptions(sqlite3Wasm: Uri.parse('sqlite3.wasm'), driftWorker: Uri.parse('drift_worker.js')),
  );

  @override
  int get schemaVersion => 3;

  @override
  MigrationStrategy get migration => MigrationStrategy(
    onCreate: (m) async {
      await m.createAll();
      await customStatement('CREATE INDEX IF NOT EXISTS idx_journeys_date ON saved_journeys (service_date)');
      await customStatement('CREATE INDEX IF NOT EXISTS idx_timetables_number ON timetables (timetable_number)');
    },
    // Future schema changes go here as `if (from < 2) { ... }` steps, never as a
    // drop-and-recreate: the planner and favourites exist nowhere else.
    onUpgrade: (m, from, to) async {
      if (from < 3) {
        await m.addColumn(savedJourneys, savedJourneys.boardLabel);
        await m.addColumn(savedJourneys, savedJourneys.alightLabel);
      }
    },
    beforeOpen: (details) async {
      await customStatement('PRAGMA foreign_keys = ON');
    },
  );

  /// Wipe the commuter's own data and the cache; reference data is re-seeded by the caller.
  Future<void> eraseEverything() => transaction(() async {
    for (final table in allTables) {
      await delete(table).go();
    }
  });
}
