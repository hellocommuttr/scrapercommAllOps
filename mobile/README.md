# Commuttr — Flutter app (Android, iOS, Web)

Golden Arrow bus, MyCiTi bus and Metrorail train times for Cape Town, with the published
cash fares. Offline-first, no login. Stacked MVVM on drift (SQLite).

- Product spec, stakeholder sign-off and acceptance criteria: [docs/SPEC.md](docs/SPEC.md).
- Screen-by-screen designs, the source of truth for the UI: [docs/DESIGN.md](docs/DESIGN.md).

## Run

The app talks to the Spring Boot API in `../backend`. Start the database and the API first,
and load MyCiTi, by following steps 1–4 of the [repository README](../README.md#getting-it-running).

```bash
flutter pub get
flutter run --dart-define-from-file=env/dev.json          # Android emulator uses http://10.0.2.2:8000
flutter run -d chrome --dart-define-from-file=env/dev.json
flutter build apk --dart-define-from-file=env/prod.json
flutter build web --release --dart-define-from-file=env/prod.json
```

`env/*.json` sets `API_BASE_URL` (empty = local default per platform) and `SUPPORT_EMAIL`.

## How it behaves

- **Three operators, equal footing.** Golden Arrow, MyCiTi and Metrorail all appear in
  search, Explore, Filters and preferences. An operator is never shown as "coming soon".
- **Results cross operators.** A plan between two stop ids only ever returns that stop's
  operator, so someone at a Golden Arrow stop would never see the MyCiTi stop across the
  road. The same trip is therefore planned a second time between the two *points*, and any
  other operator's service whose stops are within `JourneyService.maxTransferWalkM` (1200 m)
  of both places is merged in, with the walk shown on the card ("382 m walk") and spelled
  out on the trip. Operators switched off in Filters are never added.
- **Scheduled times, not live tracking.** Everything comes from the operators' published
  timetables and the clock, in Cape Town time, with SA public holidays and footnote rules
  ("Fridays only") applied. The app says so wherever a time is shown.
- **Offline-first.** The app ships a snapshot of stops, routes, timetables and footnotes in
  `assets/seed/seed.json` and loads it on first launch. Searches are network-first and fall
  back to the cached copy, flagged as saved. Planner, favourites and profile are local only.

## Layout

| Path | What |
| --- | --- |
| `lib/app/app.dart` | `@StackedApp`: routes, services, dialogs, sheets. Run `dart run build_runner build -d` after changing it or the drift schema. |
| `lib/core/` | Config, Cape Town clock + SA public holidays, footnote rules |
| `lib/data/` | API client, wire models, drift database |
| `lib/services/` | Journey planning, cache, planner, favourites, reminders, inbox, support/export |
| `lib/ui/` | Views + ViewModels per screen, theme, shared widgets, onboarding dialog, filters sheet |
| `assets/seed/seed.json` | Bundled stops/routes/timetables/footnotes. Rebuild: `python mobile/tool/build_seed.py` (needs the database container). Its `version` changes whenever the data changes, which is what makes an installed app reload it. |
| `web/sqlite3.wasm`, `web/drift_worker.js` | Web SQLite. The worker is compiled from `tool/web/drift_worker.dart` so it matches the resolved sqlite3 version; recompile after upgrading drift/sqlite3. |

## Test

```bash
flutter analyze
flutter test
```

The tests cover the parts that are easy to get quietly wrong: day types and public
holidays, footnote filtering, fares, the three operators and the cross-operator merge, the
bundled seed, and the onboarding dialog. They run against `assets/seed/seed.json`, so
rebuild the seed before running them if the database has changed.
