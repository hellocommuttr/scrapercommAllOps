import 'dart:convert';

import 'package:commuttr/data/api/commuttr_api.dart';
import 'package:commuttr/data/db/app_database.dart';
import 'package:commuttr/services/cached_api_service.dart';
import 'package:commuttr/services/connectivity_service.dart';
import 'package:commuttr/services/settings_service.dart';
import 'package:drift/drift.dart' show driftRuntimeOptions;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

/// Counting how the network is used, and the switch that stops it.
///
/// A search row said what was searched and never by whom, so it could only answer "how
/// many searches" - and 500 searches can be 500 commuters or one. The app now sends an id
/// it made itself, which is not a device identifier and belongs to nobody.
class _Api implements CommuttrApi {
  _Api(this.body);

  final String body;
  bool offline = false;
  final List<Map<String, Object?>> posts = [];
  String? deviceId;
  String? client;

  @override
  Future<String> getRaw(String path, [Map<String, String>? query]) async {
    if (offline) throw const ApiException(ApiFailure.offline, 'no network');
    return body;
  }

  @override
  Future<void> post(String path, Map<String, Object?> body) async => posts.add({'path': path, ...body});

  @override
  void identify({String? deviceId, String? client}) {
    this.deviceId = deviceId;
    this.client = client;
  }
}

void main() {
  late AppDatabase db;
  late SettingsService settings;
  late _Api api;
  late CachedApiService cached;

  setUp(() async {
    driftRuntimeOptions.dontWarnAboutMultipleDatabases = true;
    db = AppDatabase(NativeDatabase.memory());
    settings = SettingsService(db: db);
    await settings.load();
    api = _Api(jsonEncode({'options': [1, 2, 3]}));
    cached = CachedApiService(db: db, api: api, connectivity: ConnectivityService(), settings: settings);
  });

  tearDown(() => db.close());

  test('the id is made once and kept', () async {
    final first = await settings.ensureInstallId();

    expect(first, isNotNull);
    expect(first!.length, 24);
    expect(await settings.ensureInstallId(), first, reason: 'the same phone stays one phone');
  });

  test('turning sharing off forgets the id, so coming back is a new phone', () async {
    final before = await settings.ensureInstallId();

    await settings.setShareUsage(false);

    expect(settings.installId, isNull);
    expect(await settings.ensureInstallId(), isNull, reason: 'nothing is made while sharing is off');

    await settings.setShareUsage(true);
    expect(await settings.ensureInstallId(), isNot(before));
  });

  test('a trip answered offline is kept and sent when a request gets through', () async {
    // Seed the cache with a live answer, then lose the network and ask again.
    await cached.get('/api/plan', query: {'from': '1', 'to': '2'}, parse: (j) => j);
    api.offline = true;
    final again = await cached.get('/api/plan', query: {'from': '1', 'to': '2'}, parse: (j) => j);

    expect(again.fromCache, isTrue);
    expect(api.posts, isEmpty, reason: 'there is no connection at that moment, by definition');

    api.offline = false;
    await cached.get('/api/plan', query: {'from': '1', 'to': '2'}, parse: (j) => j);
    await Future<void>.delayed(const Duration(milliseconds: 50));

    expect(api.posts, hasLength(1));
    expect(api.posts.single['path'], '/api/usage');
    expect(api.posts.single['kind'], 'cached_search');
    expect(api.posts.single['result_count'], 3, reason: 'the saved answer held three options');
    expect(api.posts.single['from'], 1);
  });

  test('sharing off sends nothing at all', () async {
    await settings.setShareUsage(false);
    await cached.get('/api/plan', query: {'from': '1', 'to': '2'}, parse: (j) => j);
    api.offline = true;
    await cached.get('/api/plan', query: {'from': '1', 'to': '2'}, parse: (j) => j);
    api.offline = false;
    await cached.get('/api/plan', query: {'from': '1', 'to': '2'}, parse: (j) => j);
    await Future<void>.delayed(const Duration(milliseconds: 50));

    expect(api.posts, isEmpty);
    cached.reportUsage({'kind': 'place_search', 'query': 'kraaifontein'});
    expect(api.posts, isEmpty);
  });
}
