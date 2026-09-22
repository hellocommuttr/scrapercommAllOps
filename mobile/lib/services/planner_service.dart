import 'dart:convert';

import 'package:drift/drift.dart';
import 'package:stacked/stacked.dart';

import '../app/app.locator.dart';
import '../core/service_day.dart';
import '../data/db/app_database.dart';
import '../data/models/models.dart';
import 'journey_service.dart';
import 'settings_service.dart';

enum JourneyStatus { planned, active, completed }

/// A ride on the commuter's planner, with everything needed to show it offline.
class PlannedJourney {
  PlannedJourney(this.row)
    : from = Endpoint.fromJson(jsonDecode(row.fromEndpoint) as Json),
      to = Endpoint.fromJson(jsonDecode(row.toEndpoint) as Json),
      date = ServiceDate.parse(row.serviceDate),
      trip = row.tripSnapshot == null ? null : TripStopsResponse.fromJson(jsonDecode(row.tripSnapshot!) as Json);

  final SavedJourney row;
  final Endpoint from;
  final Endpoint to;
  final ServiceDate date;
  final TripStopsResponse? trip;

  String get id => row.id;
  JourneyStatus get status => JourneyStatus.values.asNameMap()[row.status] ?? JourneyStatus.planned;
  double get boardMinutes => row.boardMinutes;
  double? get arriveMinutes {
    final a = row.arriveMinutes;
    if (a == null) return null;
    return a < row.boardMinutes ? a + 1440 : a;
  }

  double? get durationMinutes => rideMinutes(boardMinutes, arriveMinutes, approx: approx);
  OperatorRef get operator => OperatorRef.from(row.operatorCode, name: row.operatorName, kind: row.operatorKind);

  /// Bus number or train line, as on the route chip.
  String get routeNumber => routeShortName(row.timetableNumber, row.routeLabel, operator);

  /// Where the rider gets on and off, as the search named it: a stop, or "between A and B"
  /// for a point on the road. Empty for trips saved before this was kept.
  String get boardLabel => row.boardLabel ?? '';
  String get alightLabel => row.alightLabel ?? '';

  /// Why the bus may not stop where this trip gets on or off, when that is a point on the road.
  String? get unofficialStopAdvice => unofficialStopAdviceFor(boardLabel, alightLabel, operator);

  /// The published cash fare when the ride was saved, if there was one.
  int? get cashFareCents => pricesShownFor(operator) ? row.cashFareCents : null;

  String get boardTime => formatMinutes(boardMinutes);
  String? get arriveTime => arriveMinutes == null ? null : formatMinutes(arriveMinutes!);
  bool get approx => row.boardApprox || row.arriveApprox;
  DateTime get departsAt => date.at(boardMinutes);
  DateTime? get arrivesAt => arriveMinutes == null ? null : date.at(arriveMinutes!);
}

/// The commuter's planner: local-only, no account needed.
class PlannerService with ListenableServiceMixin {
  PlannerService({AppDatabase? db, SettingsService? settings})
    : _db = db ?? locator<AppDatabase>(),
      _settings = settings ?? locator<SettingsService>();

  final AppDatabase _db;
  final SettingsService _settings;

  Future<List<PlannedJourney>> forDate(ServiceDate date) async {
    final rows =
        await (_db.select(_db.savedJourneys)
              ..where((j) => j.serviceDate.equals(date.iso))
              ..orderBy([(j) => OrderingTerm.asc(j.boardMinutes)]))
            .get();
    return rows.map(PlannedJourney.new).toList();
  }

  /// Planned journeys from [from] onwards, soonest first.
  Future<List<PlannedJourney>> upcoming(ServiceDate from, {int limit = 20}) async {
    final rows =
        await (_db.select(_db.savedJourneys)
              ..where((j) => j.serviceDate.isBiggerOrEqualValue(from.iso) & j.status.isNotValue('completed'))
              ..orderBy([(j) => OrderingTerm.asc(j.serviceDate), (j) => OrderingTerm.asc(j.boardMinutes)])
              ..limit(limit))
            .get();
    return rows.map(PlannedJourney.new).toList();
  }

  Future<int> countFor(ServiceDate date) =>
      _db.savedJourneys.count(where: (j) => j.serviceDate.equals(date.iso)).getSingle();

  Future<PlannedJourney?> byId(String id) async {
    final row = await (_db.select(_db.savedJourneys)..where((j) => j.id.equals(id))).getSingleOrNull();
    return row == null ? null : PlannedJourney(row);
  }

  Future<bool> contains(ServiceDate date, String rideKey) async {
    final p = rideKey.split(':').map(int.parse).toList();
    final n = await _db.savedJourneys
        .count(
          where: (j) =>
              j.serviceDate.equals(date.iso) &
              j.scheduleId.equals(p[0]) &
              j.tripIndex.equals(p[1]) &
              j.fromSeq.equals(p[2]) &
              j.toSeq.equals(p[3]),
        )
        .getSingle();
    return n > 0;
  }

  /// Add a ride. [trip] is the stop-by-stop snapshot, when already loaded.
  Future<String> add(Ride ride, {TripStopsResponse? trip, String? groupId}) async {
    final d = ride.departure;
    final id = '${ride.date.iso}-${d.rideKey}-${DateTime.now().microsecondsSinceEpoch}';
    await _db
        .into(_db.savedJourneys)
        .insert(
          SavedJourneysCompanion.insert(
            id: id,
            serviceDate: ride.date.iso,
            fromEndpoint: jsonEncode(ride.from.toJson()),
            toEndpoint: jsonEncode(ride.to.toJson()),
            routeLabel: ride.option.routeLabel,
            operatorCode: Value(ride.operator.code),
            operatorName: Value(ride.operator.name),
            operatorKind: Value(ride.operator.kind),
            cashFareCents: Value(ride.priceCents),
            timetableNumber: ride.option.timetableNumber,
            dayType: ride.option.dayType,
            dayLabel: ride.option.dayLabel,
            boardRaw: d.boardRaw,
            arriveRaw: d.arriveRaw,
            boardMinutes: d.boardMinutes!,
            arriveMinutes: Value(d.arriveMinutes),
            boardApprox: d.boardApprox,
            arriveApprox: d.arriveApprox,
            scheduleId: d.scheduleId,
            tripIndex: d.tripIndex,
            fromSeq: d.fromSeq,
            toSeq: d.toSeq,
            tripSnapshot: Value(trip == null ? null : jsonEncode(trip.toJson())),
            groupId: Value(groupId),
            boardLabel: Value(ride.option.boardLabel),
            alightLabel: Value(ride.option.alightLabel),
            createdAt: DateTime.now().millisecondsSinceEpoch,
          ),
        );
    notifyListeners();
    return id;
  }

  Future<void> saveSnapshot(String id, TripStopsResponse trip) async {
    await (_db.update(
      _db.savedJourneys,
    )..where((j) => j.id.equals(id))).write(SavedJourneysCompanion(tripSnapshot: Value(jsonEncode(trip.toJson()))));
  }

  Future<void> setReminder(String id, int? leadMinutes) async {
    await (_db.update(
      _db.savedJourneys,
    )..where((j) => j.id.equals(id))).write(SavedJourneysCompanion(reminderLeadMinutes: Value(leadMinutes)));
    notifyListeners();
  }

  Future<void> remove(String id) async {
    await (_db.delete(_db.savedJourneys)..where((j) => j.id.equals(id))).go();
    if (_settings.activeJourneyId == id) await _settings.setActiveJourneyId(null);
    notifyListeners();
  }

  Future<void> moveTo(String id, ServiceDate date) async {
    await (_db.update(_db.savedJourneys)..where((j) => j.id.equals(id))).write(
      SavedJourneysCompanion(serviceDate: Value(date.iso), status: const Value('planned')),
    );
    notifyListeners();
  }

  // ---------------------------------------------------------------- the trip in progress

  Future<PlannedJourney?> active() async {
    final id = _settings.activeJourneyId;
    return id == null ? null : byId(id);
  }

  Future<void> start(String id) async {
    final current = _settings.activeJourneyId;
    if (current != null && current != id) {
      await (_db.update(_db.savedJourneys)..where((j) => j.id.equals(current) & j.status.equals('active'))).write(
        const SavedJourneysCompanion(status: Value('planned')),
      );
    }
    await (_db.update(
      _db.savedJourneys,
    )..where((j) => j.id.equals(id))).write(const SavedJourneysCompanion(status: Value('active')));
    await _settings.setActiveJourneyId(id);
    notifyListeners();
  }

  Future<void> complete(String id) async {
    await (_db.update(_db.savedJourneys)..where((j) => j.id.equals(id))).write(
      SavedJourneysCompanion(
        status: const Value('completed'),
        completedAt: Value(DateTime.now().millisecondsSinceEpoch),
      ),
    );
    if (_settings.activeJourneyId == id) await _settings.setActiveJourneyId(null);
    notifyListeners();
  }

  Future<void> stop(String id) async {
    await (_db.update(
      _db.savedJourneys,
    )..where((j) => j.id.equals(id))).write(const SavedJourneysCompanion(status: Value('planned')));
    if (_settings.activeJourneyId == id) await _settings.setActiveJourneyId(null);
    notifyListeners();
  }

  // ---------------------------------------------------------------- export / import

  Future<List<Json>> exportRows() async => (await _db.select(_db.savedJourneys).get()).map((r) => r.toJson()).toList();

  Future<void> importRows(List<Json> rows) async {
    await _db.batch((b) => b.insertAllOnConflictUpdate(_db.savedJourneys, rows.map(SavedJourney.fromJson)));
    notifyListeners();
  }
}
