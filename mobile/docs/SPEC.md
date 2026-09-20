# Commuttr mobile & web app — specification v1.2

Flutter (Android, iOS, Web), Stacked MVVM, offline-first on SQLite (drift). No login.
v1.0 folded in reviews from five stakeholders: business analyst, commuter,
transport operator, customer support and a senior Flutter engineer (see §9).

## What changed in v1.2

- **MyCiTi added as a third operator.** The City of Cape Town's MyCiTi buses (operator code
  `myciti`, 47 routes such as T01, D05 and 101, with weekday, Saturday and Sunday service) are a
  normal operator everywhere Golden Arrow and Metrorail are: the operator filter, Explore's
  operator list, transport preferences and search results. Route families (T, D and the 100s)
  group the routes in Explore.
- MyCiTi stop positions come from OpenStreetMap. A few MyCiTi stops have no position yet and
  cannot be used as a start or end point.
- **MyCiTi fares are not published in Commuttr yet.** MyCiTi is distance-based and paid with a
  myconnect card; the UI says so and links to myciti.org.za rather than showing a price. MyCiTi
  timetables have no PDF link and no effective date.
- **The bundled offline seed is versioned by date + content hash**, so existing installs notice a
  new seed and reload it instead of keeping the old bundled data.
- Help, FAQ, Terms, About, Report an issue, onboarding and splash wording now name all three
  operators and state non-affiliation with all three.

## What changed in v1.1

- **Metrorail trains added.** PRASA's Cape Town Metrorail timetables (10 lines on the Central,
  Northern, Southern, Cape Flats and Monte Vista lines) sit alongside Golden Arrow buses.
  - Operator filter: Golden Arrow and Metrorail can each be switched on or off (MyCiTi joined them in v1.2).
  - Stations are labelled "station" so a train station is never confused with a bus stop of the same name.
  - The train line is used as the route name.
  - Weekday and Saturday service only: no Sunday trains are shown; public-holiday train service is to be
    confirmed with Metrorail.
  - Metrorail timetables have no PDF links and no footnotes; trip detail and timetable views omit both for trains.
- **Published cash fares are now shown.** v1.0 decided "no fares" because there was no fare source. The API
  now returns the operators' published fare tables, so that decision is superseded:
  - Only the **cash fare** is shown as the price. Golden Arrow card (Gold Card) prices are never shown as the price.
  - Golden Arrow publishes cash fares for only ~21 routes, so many bus trips show no price; nothing is
    estimated or filled in.
  - Train fares are Metrorail's single ticket (return, weekly and monthly under "About this fare"); tickets are
    bought at the station.
  - Every fare is labelled as the last published figure with its effective date, not a guarantee.
  - The transport-operator and customer-support stakeholders' v1.0 concern — never show a made-up or misleading
    price — is met by showing only dated, published cash fares, and nothing where none is published.
- Help, FAQ, Terms, About, Report an issue, onboarding and splash wording now name the operators, route
  riders to gabs.co.za (buses) or metrorail.co.za (trains), and state non-affiliation with them.

## 1. What the data can and cannot do

| Available (Commuttr API + bundled seed) | Not available — never implied in the UI |
| --- | --- |
| Golden Arrow published timetables (~1,870 PDFs, parsed) | Real-time bus or train positions, delays, cancellations |
| Metrorail (PRASA) published timetables: 10 lines, weekday + Saturday | Metrorail Sunday service; PDF links or footnotes for trains |
| MyCiTi (City of Cape Town) published timetables: 47 routes (T/D/100s), weekday + Saturday + Sunday | MyCiTi fares; MyCiTi PDF links, effective dates or footnotes |
| Stops (280 named timing points), stations, bus routes (544) and train lines | Wallet, payments, ticket sales |
| MyCiTi stop positions from OpenStreetMap | Positions for the few MyCiTi stops OSM does not have (they cannot start or end a trip) |
| Published cash fares (Golden Arrow ~21 routes; Metrorail by fare zone) with effective dates | Any price that isn't a published cash fare (incl. Gold Card prices as the price) |
| Day types: weekday / Saturday / Sunday / public holiday | Accessibility (wheelchair) data |
| Footnotes ("a = Mon–Thu", "b = Fridays") — Golden Arrow only | Real-time MyCiTi/myconnect balance or card data |
| Approximate (interpolated) and "via" (no published) times | Push alerts / disruption feed |
| Timetable effective dates + official PDF links (Golden Arrow) | User accounts, cross-device sync |
| Plans between stops or map pins; one-change connections | Offline *new* route planning (planning runs on the server) |

## 2. Product-owner requirements → where they are met

| Requirement | Implementation | Verified by |
| --- | --- | --- |
| Android, iOS, Web | One Flutter codebase; drift uses native SQLite on mobile and sqlite3 WASM (OPFS/IndexedDB) on web | `flutter build apk`, `flutter build web`; iOS build needs macOS |
| Stacked MVVM | `lib/app/app.dart` `@StackedApp`; every screen is `StackedView` + `ViewModel`; services injected via generated locator | code review |
| Offline ready | Bundled seed, network-first cache with SQLite fallback, local-only user data (§4) | `test/services/*`, AC-OFF-* |
| SQLite | drift (`lib/data/db/app_database.dart`), schema v1 with migration strategy | `test/services/offline_data_test.dart` |
| Splash → Home | `StartupView` → `MainView` (Home tab) | AC-START-* |
| Onboarding dialog on Home | `OnboardingDialog`, first launch, re-openable from Profile/Help | AC-ONB-* |
| No login | No auth anywhere; data stays on device; export/import for moving phones | — |

## 3. Time and timetable rules (all screens)

- **Time zone:** Cape Town time (SAST, fixed UTC+2 — SA has no DST), never the device zone. `lib/core/service_day.dart`.
- **Day type:** computed from the date. SA public holidays computed per Public Holidays Act (fixed dates, Easter-relative Good Friday & Family Day, Sunday → Monday). Once-off declared holidays are not predicted.
- **Public holiday:** use the route's PUBLIC_HOLIDAY timetable; if none exists, show the Sunday timetable with a banner "Public holiday — showing Sunday times. Confirm holiday service with Golden Arrow."
- **Footnotes:** a departure whose footnote days exclude the travel date is hidden (never a Friday-only bus on a Monday). Footnote text shown in full ("Fridays only"). An uninterpretable footnote keeps the departure and flags "Check the official timetable".
- **Approximate / via:** approximate times say "approx." and are styled differently; "via" = "time not published". Neither is used for "arrives in X" claims or a get-off reminder without the label.
- **Wording:** "Scheduled 07:15", "scheduled in 12 min". Never "live", "tracking", "arriving", "on time".
- **Effective dates:** trip detail and timetable view show "Timetable valid from …", data snapshot date and, for Golden Arrow, a link to the official PDF on gabs.co.za (Metrorail and MyCiTi timetables have no PDF link and no valid-from date). Fares show their effective date.

## 4. Offline behaviour

| Works offline | How |
| --- | --- |
| Stop search, nearby stops (GPS optional), route list, footnote rules | Bundled seed loaded into SQLite on first launch |
| Any search, trip detail or timetable opened before | Network-first cache; served from SQLite with "Saved <time>" label; LRU-evicted past 25 MB |
| Planner, favourites, recent searches, profile, preferences, inbox | Local-only tables |
| Trip detail & "On my trip" for planner items | Stop-time snapshot stored with each planner item |
| Reminders | Scheduled with the OS (Android/iOS); fire with app closed and no network |

Not offline: a *new* search never run before (shows "Not saved for offline — connect to search this trip", with saved alternatives), place (address) search, map tiles.

Connectivity truth comes from request outcomes, not just connectivity_plus.

## 5. Screens

Tabs: **Home · Planner · On my trip · Explore · Profile**. Every tab app-bar has the notifications bell.

1. **Splash** — brand, seed import on first run, non-affiliation line. Never waits on network.
2. **Home** — greeting; "My commute" card (Home↔Work next 3 buses, when set) ; From/To (stop picker: my location, Home/Work, recents, all stops offline, place search online), swap; date/time + Filter (badge count); results: time, arrival, duration, route badge, "scheduled in X", approx/footnote tags, first & last bus of the day; one-change connections when no direct bus; explicit empty states (no service today → which days run; outside network; not saved offline); save trip ★; Your planner (next item); Explore shortcuts. **Onboarding dialog** on first open.
3. **Filters (sheet)** — operators (Golden Arrow, MyCiTi and Metrorail, all on by default); travel date (today/tomorrow/pick); depart after / arrive by; sort (departure, arrival, duration); include approximate times. Reset / Apply (n).
4. **Trip detail** — route, times, duration, stop-by-stop list with times (approx/via labelled), footnotes in full, map (hidden when "Show maps" off or offline), timetable valid-from + PDF link (buses only), fare panel (published cash fare with effective date, or no price; train ticket options), disclaimer, "be at stop N min early"; actions: Add to planner (date), Start trip, Remind me to leave, Share (WhatsApp-friendly text), Report a problem (pre-filled).
5. **Connection detail** — legs, change stop, wait time; night/long-wait safety note (wait > 20 min or after 19:00); add all legs to planner.
6. **Planner** — date bar (prev/next/pick), stats (journeys, total travel time, operator), Planned / Completed tabs, cards with overflow (Start, Remind me, Move to another day, Delete), note "Times are scheduled; arrive 5–10 min early". Add journey → Home.
7. **On my trip** — the active planner item: progress along stops from the timetable and the Cape Town clock (clearly "Scheduled progress — not live tracking"), next stop, "Get off" reminder toggle (OS notification), map, timeline, End trip (→ completed), Share trip, Get help. Empty state offers the next planned journey.
8. **Explore** — search routes/areas (offline), quick access (Timetables, Nearby stops, Your frequent trips, Favourites), operators list (Golden Arrow → routes; MyCiTi → routes by family T / D / 100s; Metrorail → lines), your frequent trips. No partner-offers carousel (no content source).
9. **Route detail / Timetable** — route's timetables with valid-from dates and PDF links; timetable grid by direction & day type, footnote legend, disclaimer, non-affiliation line.
10. **Nearby stops** — GPS once (opt-in), nearest seed stops with distance; permission/off states explained.
11. **Profile** — local profile ("on this device only"), My planner summary, Favourites (Home, Work, saved trips, nearby stops), Preferences, Offline & data, Support (Help, How Commuttr works, Share, Terms, Privacy, About). No log out.
12. **Edit profile** — name, home area. No email/phone/password (no accounts).
13. **Preferences** — theme (dark/light/system), reminder lead time, get-off alerts, show maps (data saver), arrive-early minutes.
14. **Offline & data** — data snapshot date, last refresh, cache size; Refresh timetable data (keeps planner); Export backup; Import backup; Erase everything (confirm, lists what is lost). Web warning: clearing browser data erases everything.
15. **Help & support** — searchable offline FAQ; topics; contact Commuttr (email); "We're not Golden Arrow, MyCiTi or Metrorail" routing (tickets, lost property, complaints, disruptions → gabs.co.za / myciti.org.za / metrorail.co.za); Report an issue (payload preview, no location); Safety: SAPS 10111.
16. **Report an issue** — category, description, auto-filled details shown in full before opening the mail app; report ID.
17. **Notifications** — in-app inbox (welcome, reminders set, data refreshed); mark all read; explains it is not a live alerts feed.
18. **Terms / Privacy** — accordion text: independent of all three operators, scheduled data, fares are last-published figures that may be out of date, not a ticket seller, no warranty; privacy per POPIA: what leaves the device (search stops/pins to Commuttr API, place text to OpenStreetMap Nominatim via our API, server logs incl. IP, map tiles fetched directly from OpenStreetMap, which sees the device IP), nothing else; no accounts; retention; Information Officer contact = support email (TBC).
19. **About** — version, data snapshot, sources & attribution (Golden Arrow published PDF timetables and fare tables; MyCiTi — the City of Cape Town's published route timetables (myciti.org.za), stop positions © OpenStreetMap contributors; Metrorail/PRASA published timetables and fare zones; © OpenStreetMap contributors), non-affiliation statement for all three operators.

## 6. Acceptance criteria (selection — each maps to a test or manual check)

- **AC-START-1** Given a fresh install in airplane mode, when the app opens, then Splash → Home in < 3 s and stop search returns "Bellville" within 1 s.
- **AC-ONB-1** Given first launch, when Home appears, then the onboarding dialog shows; Skip or Done dismisses it and it does not show again; Profile → "How Commuttr works" re-opens it.
- **AC-DAY-1** Given a Monday, when searching Bellville → Cape Town, then no departure footnoted "Fridays" is listed, and the hidden count is explained.
- **AC-DAY-2** Given 16 June (Youth Day), then results use the holiday timetable or show the Sunday-fallback banner.
- **AC-OFF-1** Given a search done online, when repeated offline, then the same results appear labelled "Saved <time>".
- **AC-OFF-2** Given a new search offline, then the app says it is not saved for offline and offers saved trips.
- **AC-PLAN-1** Given a ride added to the planner, when offline, then its trip detail and On my trip progress still show stop times.
- **AC-REM-1** Given a reminder set for a future bus on Android/iOS, when the app is closed, then a notification fires at departure − lead time.
- **AC-TXT-1** No screen claims live or real-time data (explicit "not live" disclaimers are required, not forbidden), shows a fare amount that isn't a published cash fare (with its effective date), or contains the placeholder number 021 123 4567.
- **AC-DATA-1** "Erase everything" removes planner, favourites, history, inbox and settings, then reloads the bundled timetables.

## 7. Non-functional

- Cold start to Home ≤ 3 s on a mid-range Android; seed asset ~650 KB; cache cap 25 MB.
- WCAG 2.2 AA intent: contrast ≥ 4.5:1 for text, 48 dp targets, semantics labels, supports system text scaling, reduce-motion respected by default widgets.
- No analytics SDKs, no ads, no third-party trackers.
- Configuration via `--dart-define-from-file=env/<flavor>.json` (`API_BASE_URL`, `SUPPORT_EMAIL`).

## 8. Out of scope for v1 (backlog)

Push/disruption alerts (needs an operator feed) · home-screen widget · isiXhosa and Afrikaans translations (strings are ready to extract to ARB; needs native-speaker translation) · landmarks for stops · accounts/sync · MyCiTi fares · backend `/api/snapshot` endpoint for versioned seed builds · offline map tiles (OSM tile policy forbids bulk caching).

## 9. Stakeholder sign-off log

| Stakeholder | Verdict on v0.1 | Key changes adopted in v1.0 |
| --- | --- | --- |
| Business analyst | Approve with changes | Offline scope table (§4), traceability (§2), acceptance criteria (§6), privacy corrected, holiday rule, NFRs (§7) |
| Commuter | Might use | "My commute" card, first/last bus, auto day type + footnote filtering, OS reminders with app closed, data-saver maps, trip sharing, fares link, shorter skippable onboarding |
| Transport operator | Conditionally acceptable | No "live" wording, effective dates + PDF link everywhere, footnotes applied, approx/via labelled, holiday handling, non-affiliation statement, disclaimers, official-channel routing, no fares |
| Customer support | Changes needed | Report payload + preview + report ID, export/import, split refresh vs erase, POPIA-accurate privacy, "we are not Golden Arrow" routing, specific empty states, FAQ topics |
| Software engineer | Go once changes made | SAST clock + holiday calc, web WASM files, bundled seed, planner snapshots, cache keys/LRU, hand-written unions, request-based offline detection, dart-define config, maps online-only |

Open items needing a product-owner decision before release: final support email and Information Officer; legal review of Terms/Privacy; whether to request Golden Arrow's and PRASA's permission to reference their names, timetables and fares.
