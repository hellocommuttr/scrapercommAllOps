import 'dart:convert';
import 'dart:io';

import 'package:commuttr/app/app.locator.dart';
import 'package:commuttr/data/api/commuttr_api.dart';
import 'package:commuttr/data/db/app_database.dart';
import 'package:commuttr/services/connectivity_service.dart';
import 'package:commuttr/services/reference_data_service.dart';
import 'package:commuttr/services/settings_service.dart';
import 'package:drift/drift.dart' hide isNull, isNotNull;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

/// Whose route each route is, after an online refresh.
///
/// Reloading MyCiTi into the database gave all 47 of its routes new ids. /api/routes did
/// not say whose route it was, the app did not recognise the ids, and it filed every one
/// under Golden Arrow — so the MyCiTi list on Explore came up empty.
void main() {
  // In the bundled seed, under id 4320.
  const mycitiName = '101: Vredehoek - Gardens - Civic Centre (Clockwise)';

  late AppDatabase db;
  late _FakeApi api;
  late ReferenceDataService reference;

  setUp(() async {
    driftRuntimeOptions.dontWarnAboutMultipleDatabases = true;
    db = AppDatabase(NativeDatabase.memory());
    final settings = SettingsService(db: db);
    await settings.load();
    locator.registerSingleton<ConnectivityService>(ConnectivityService());
    api = _FakeApi()
      ..bodies['/api/stops?limit=100000&q='] = jsonEncode({'stops': []})
      ..bodies['/api/operators'] = jsonEncode({'operators': []});
    reference = ReferenceDataService(db: db, api: api, settings: settings);
    await reference.seedIfNeeded(assetJson: File('assets/seed/seed.json').readAsStringSync());
  });

  tearDown(() async {
    await locator.reset();
    await db.close();
  });

  Map<String, Object?> route(int id, String name, {String? operatorCode}) => {
    'id': id,
    'name': name,
    'origin': 'Civic Centre',
    'destination': 'Wexford',
    'letter_group': null,
    'timetable_count': 6,
    'operator_code': ?operatorCode,
  };

  Future<String?> operatorOf(int id) async =>
      (await reference.searchRoutes('')).where((r) => r.id == id).firstOrNull?.operatorCode;

  test('the API saying whose route it is wins', () async {
    api.bodies['/api/routes'] = jsonEncode({
      'routes': [route(99001, 'A ROUTE NOBODY HAS SEEN', operatorCode: 'myciti')],
    });

    expect(await reference.refresh(), isTrue);
    expect(await operatorOf(99001), 'myciti');
  });

  test('from an older API, a route under a new id keeps its operator by name', () async {
    // What the database gave after MyCiTi was reloaded: same name, new id, no operator.
    api.bodies['/api/routes'] = jsonEncode({
      'routes': [route(4359, mycitiName)],
    });

    expect(await reference.refresh(), isTrue);
    expect(await operatorOf(4359), 'myciti', reason: 'not filed under Golden Arrow');
    expect(await reference.searchRoutes('', operatorCode: 'myciti'), isNotEmpty);
  });

  test('a route never seen by id or name, and not named like a train line, is Golden Arrow', () async {
    api.bodies['/api/routes'] = jsonEncode({
      'routes': [route(99002, 'KHAYELITSHA - BELLVILLE')],
    });

    expect(await reference.refresh(), isTrue);
    expect(await operatorOf(99002), 'gabs');
  });
}

/// Answers from a map of full request keys ("path?sorted=query"), recording what was asked.
class _FakeApi implements CommuttrApi {
  final Map<String, String> bodies = {};

  @override
  Future<String> getRaw(String path, [Map<String, String>? query]) async {
    final q = (query?.entries.toList() ?? [])..sort((a, b) => a.key.compareTo(b.key));
    final key = q.isEmpty ? path : '$path?${q.map((e) => '${e.key}=${e.value}').join('&')}';
    final body = bodies[key];
    if (body == null) throw Exception('no canned answer for $key');
    return body;
  }
}
