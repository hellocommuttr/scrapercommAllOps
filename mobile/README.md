# Commuttr — Flutter app (Android, iOS, Web)

Golden Arrow bus and Metrorail train times (with published cash fares) for Cape Town. Offline-first, no login. Stacked MVVM on drift (SQLite).
Product spec, stakeholder sign-off and acceptance criteria: [docs/SPEC.md](docs/SPEC.md).

## Run

The app talks to the Spring Boot API in `../backend` (start it first, see the repository README).

```bash
flutter pub get
flutter run --dart-define-from-file=env/dev.json          # Android emulator uses http://10.0.2.2:8000
flutter run -d chrome --dart-define-from-file=env/dev.json
flutter build apk --dart-define-from-file=env/prod.json
flutter build web --release --dart-define-from-file=env/prod.json
```

`env/*.json` sets `API_BASE_URL` (empty = local default per platform) and `SUPPORT_EMAIL`.

## Layout

| Path | What |
| --- | --- |
| `lib/app/app.dart` | `@StackedApp`: routes, services, dialogs, sheets. Run `dart run build_runner build -d` after changing it or the drift schema. |
| `lib/core/` | Config, Cape Town clock + SA public holidays, footnote rules |
| `lib/data/` | API client, wire models, drift database |
| `lib/services/` | Journey planning, cache, planner, favourites, reminders, inbox, support/export |
| `lib/ui/` | Views + ViewModels per screen, theme, shared widgets, onboarding dialog, filters sheet |
| `assets/seed/seed.json` | Bundled stops/routes/timetables/footnotes. Rebuild: `python mobile/tool/build_seed.py` (needs the database container) |
| `web/sqlite3.wasm`, `web/drift_worker.js` | Web SQLite. The worker is compiled from `tool/web/drift_worker.dart` so it matches the resolved sqlite3 version; recompile after upgrading drift/sqlite3. |

## Test

```bash
flutter analyze
flutter test
```
