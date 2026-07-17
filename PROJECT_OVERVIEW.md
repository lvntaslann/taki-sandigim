# Takı Sandığım — Project Documentation

## 1. Purpose of the Project

**Takı Sandığım** ("My Jewelry Box") is a Flutter mobile app for tracking
gold jewelry, bracelets, necklaces, and cash gifts exchanged at Turkish
weddings/engagements — a strong cultural tradition where guests pin gold
coins or cash onto the bride/groom. The core use cases are:

- Recording who received what at a wedding/engagement ("received by us")
  or what we gave to someone else ("given by us"),
- Automatically computing a per-person balance ("who owes us / who do we
  owe") so gift-giving reciprocity can be tracked over years,
- Photographing a handwritten "notebook page" from a wedding and using OCR
  to auto-parse lines into structured entries for bulk import,
- Converting gold-based gifts into TL value using the current gram gold
  rate, and showing an overall budget summary plus analytics charts.

The UI language and all in-app strings are entirely **Turkish**.

## 2. Tech Stack

| Layer | Technology |
|---|---|
| Framework | Flutter (Dart SDK ^3.11.5) |
| State management | `flutter_bloc` (BLoC pattern) + `equatable` |
| Routing | `go_router` (`StatefulShellRoute` for the bottom-tab shell) |
| Local database | `hive` / `hive_flutter` (NoSQL, code-generated type adapters) |
| Networking | `dio` (used by the gold rate service) |
| OCR | `google_mlkit_text_recognition` (Latin script) |
| Camera / gallery | `camera`, `image_picker`, `image` (cropping), `path_provider` |
| UI helpers | `google_fonts` (Plus Jakarta Sans), `flutter_screenutil` (responsive sizing), `fl_chart` (charts), `intl` (date formatting, `tr_TR` locale), `uuid` |
| Codegen | `build_runner` + `hive_generator` (`.g.dart` files) |

The app uses classic BLoC event/state flow via `flutter_bloc`, with screens
wiring things up through `BlocProvider` + `BlocBuilder`. The `provider`
package is listed in `pubspec.yaml` but is **not actually used** anywhere
in the code — likely added for future use, or a leftover that could be
removed.

## 3. Folder Structure (feature-first architecture)

```
lib/
├── main.dart                      # App entry point
├── app/
│   ├── routes/                    # go_router setup + bottom-tab shell
│   ├── theme/                     # Color palette and ThemeData
├── core/
│   ├── database/                  # Hive init, box names, settings repo
│   ├── network/                   # Dio client + gold rate service
│   ├── utils/                     # Currency converter, date formatter
│   └── widgets/                   # Shared custom UI components
└── features/
    ├── dashboard/                 # Home: summary, upcoming weddings, recent entries
    ├── scanner/                   # Camera/OCR notebook-scanning flow
    ├── tracker/                   # Add-gift, ledger, and analytics screens
    └── profile/                   # User name and basic settings
```

Each feature is consistently split into `data/` (models + repositories),
`domain/` (pure business logic, Flutter-independent), and `presentation/`
(bloc + screens + widgets). New features should follow this same pattern.

## 4. App Startup and Navigation

- `main.dart`: calls `HiveService.init()`, initializes the `tr_TR` date
  locale, and runs `MaterialApp.router` inside `ScreenUtilInit` (design
  reference size 375×812).
- `AppRouter` (`lib/app/routes/app_router.dart`): defines a root-level
  `StatefulShellRoute.indexedStack` with a 4-tab bottom navigation
  (`AppShell`): **Home** (`/`), **Ledger** (`/ledger`), **Analytics**
  (`/analytics`), **Profile** (`/profile`). Outside the shell there is a
  modal-like `/add-gift` route (opened from the dashboard with `extra: 0`
  or `extra: 1` to pre-select the "Add manually" or "Scan notebook" tab).

## 5. Data Model (Hive)

Hive boxes are declared in `lib/core/database/box_names.dart`: `weddings`,
`gifts`, `settings` (this last box is an untyped generic key-value store,
currently only used to store the user's display name).

### `WeddingModel` (typeId: 0)
Represents a single wedding/engagement event: `id`, `title`, `date`,
`location?`, `note?`. **Note:** `WeddingRepository` already has read/write
methods for this model, but **no screen anywhere creates a new
`WeddingModel`**. As a result, the dashboard's "Upcoming Weddings" section
is currently always empty. This is the most visible unfinished feature in
the project.

### `GiftModel` (typeId: 1)
A single gift/jewelry entry: `id`, `weddingId?`, `personName`, `giftType`,
`amount` (piece count / grams, or a TL amount for cash), `estimatedValueTl`
(computed TL value), `direction` (received vs. given), `date`, `note?`,
`goldRateTl?` (the gram gold rate at the time the entry was recorded),
`relationType` (defaults to `friend`).

### Enums (`gift_enums.dart`)
- **`GiftType`** (typeId: 2): `quarterGold` (1.75 g), `halfGold` (3.5 g),
  `fullGold` (7 g), `gremseGold` (3 g), `bracelet`, `necklace`, `cash`,
  `other`. Each type has a `label` extension (Turkish display name) and a
  `gramEquivalent` extension (gold gram equivalent).
- **`GiftDirection`** (typeId: 3): `received` ("Bize Takılan" — given to
  us) / `given` ("Bizim Taktığımız" — given by us).
- **`RelationType`** (typeId: 4): `family`, `relative`, `friend`.

`HiveService.init()` registers all adapters and opens the corresponding
boxes. When adding/removing model fields, `.g.dart` files must be
regenerated via `build_runner`, and **existing `@HiveField` indices must
never be changed** — Hive's backward compatibility relies on those
indices.

## 6. Business Logic (Domain Layer)

This layer has no Flutter dependency and consists of plain Dart classes —
making it the best place to add unit tests (currently there are none in
the project).

- **`BudgetCalculator` / `BudgetSummary`** (dashboard/domain): sums
  `estimatedValueTl` across all entries into `received` / `given`, and
  computes `netBalanceTl = received - given`. Feeds the dashboard's main
  balance card.
- **`CurrencyConverter`** (core/utils): if `GiftType.gramEquivalent > 0`,
  computes `amount * gramEquivalent * goldRateTl`; for `cash`, `amount` is
  used directly as TL; otherwise (`bracelet`, `necklace`, `other`) it falls
  back to `amount * goldRateTl`. **Note:** since bracelet/necklace/other
  have a gram equivalent of 0, that last branch effectively treats
  `amount` as grams times the gold rate — the UI assumes the user enters
  grams for these types. This behavior appears intentional but was
  undocumented in code, so it's worth double-checking before changing it.
- **`BalanceAnalyzer` / `BalanceStatus`** (tracker/domain): groups
  `received` and `given` totals per person, and computes
  `balanceTl = received - given` to determine who owes whom
  (`theyOweUs` / `weOwe` / `isBalanced`, with a ±1 TL tolerance). Powers
  the analytics bar chart and the balance badges on the ledger screen.
- **`PersonLedgerBuilder` / `PersonLedger`** (tracker/domain): groups all
  entries by person, attaches the matching `BalanceStatus`, and finds each
  person's most recent received/given gift (`lastReceived` / `lastGiven`).
  This is the data source for the expandable person cards on the "Ledger"
  screen.
- **OCR/parsing pipeline** (scanner/domain): `NotebookParser.parse(rawText)`
  turns raw OCR text into a list of `NotebookLine` objects (person name +
  gift description + optional amount), line by line. It first looks for
  separators (`-`, `:`, `–`, `—`); if none are found, `_guessSplit` uses
  known keywords (`çeyrek`, `bilezik`, `tl`, numbers, etc.) to guess where
  the name ends and the gift description begins. `GiftTypeGuesser.guess(text)`
  then infers a `GiftType` from keywords in the gift description. These
  parsers are purely regex/heuristic-based — no ML — and mis-parses are
  expected to be corrected manually by the user on the
  `LineConfirmationCard`, so 100% accuracy isn't required, just a
  reasonable first guess.

## 7. Repository / Service Layer

- **`GiftRepository`** / **`WeddingRepository`** (dashboard/data): direct
  CRUD on Hive boxes. They use global `Hive.box<T>(...)` access (no
  dependency injection — a singleton-style box lookup).
- **`TrackerRepository`** (tracker/data): wraps `GiftRepository`, generates
  ids with `uuid`, and exposes `addGift`/`delete` to the BLoC.
- **`UserSettingsRepository`** (core/database): reads/writes only the
  `user_name` key in the `settings` box.
- **`GoldRateService`** (core/network): issues a GET request to
  `https://example.com/api/gold-rate` — **this is a placeholder URL, not a
  real gold-rate API.** Since the request always fails (`example.com` is
  not a real API), it always falls back to
  `_fallbackGoldRateTl = 3200.0`. **Wiring up a real gold-rate API
  integration is the single most important next step for this project.**
- **`DioClient`** (core/network): provides a shared, pre-configured `Dio`
  instance.

## 8. Key Screens

- **Dashboard (`/`)**: greeting (uses saved user name if set), main
  balance card (`MainBalanceCard`: received/given/net), upcoming weddings
  list (currently always empty — see §5), quick-action buttons
  (Add manually / Scan notebook / Settings), last 5 entries. Listens to
  Hive box changes via `watch()` and refreshes automatically.
- **Add Gift (`/add-gift`)**: a `TabBarView` with two tabs: "Add manually"
  (a form for direction, person, relation, gift type, amount/grams → live
  TL calculation, date, note) and "Scan notebook" (`ScannerBody`).
- **Scanner (the "Scan notebook" tab)**: capture via a custom
  camera bottom-sheet (with a crop frame) or pick from gallery → OCR →
  a `PageView` of `LineConfirmationCard`s for reviewing/editing each parsed
  line (Add/Skip). Each "Add" calls `TrackerRepository.addGift` directly.
- **Ledger (`/ledger`)**: a searchable, person-grouped, expandable list.
  Each person card shows the most recent given/received gift, total
  balance, and the full entry history (deletable, with a confirmation
  dialog).
- **Analytics (`/analytics`)**: three `fl_chart` visualizations — a
  received-vs-given donut chart, a relation-type distribution donut chart,
  and a per-person net-balance bar chart (top 6 people). Plus total-entry
  and person-count stat tiles.
- **Profile (`/profile`)**: lets the user save a display name; also shows
  static info rows (notifications, gold rate, about) which are currently
  cosmetic only and not wired to real settings.

## 9. Shared UI Components (`core/widgets`)

`CustomButton` (filled/outline variants), `CustomCard` (rounded card),
`CustomTextField` — used consistently across all forms. Theming is
centralized via `AppTheme.light` (`app/theme/app_theme.dart`) and the
`AppColors` palette (`app/theme/app_colors.dart` — gold/navy/coral tones).
**Only a light theme exists; there is no dark theme.**

## 10. Known Gaps / Opportunities for AI-Assisted Development

A prioritized list for continued development:

1. **Real gold-rate API integration** — `GoldRateService` currently hits a
   fake URL and always returns the hardcoded fallback (3200 TL).
2. **No wedding-creation screen** — `WeddingModel` and `WeddingRepository`
   are ready, but no screen ever creates a new wedding, so the dashboard's
   "Upcoming Weddings" section can never populate. Additionally,
   `GiftModel.weddingId` is never set from any UI.
3. **No tests** — no `test/` folder or `*_test.dart` files were found. The
   domain layer (`BudgetCalculator`, `BalanceAnalyzer`, `NotebookParser`,
   `CurrencyConverter`, etc.) is pure Flutter-independent Dart and is
   well-suited for unit testing.
4. **Empty README** — `README.md` exists at the project root but has no
   content.
5. **No dark theme.**
6. **The Profile screen's "Notifications" and "Gold Rate" rows** are
   purely visual — not connected to a real settings/notification system.
7. **No dependency injection** — repositories are instantiated directly
   (e.g. `TrackerRepository()`) in each screen, relying on global
   `Hive.box<T>()` lookups. As the app grows, a DI approach (e.g.
   `get_it`, or actually using the already-included but unused `provider`
   package) would improve testability.
8. **Unused `provider` dependency** — either remove it or start using it
   for a real purpose.
9. **No editing, only deletion** — once a `GiftModel` entry is added, it
   can only be deleted, not edited.

## 11. Development Commands

```bash
flutter pub get                                   # install dependencies
flutter pub run build_runner build --delete-conflicting-outputs
                                                    # regenerate Hive .g.dart files
flutter run                                        # run the app
flutter analyze                                    # lint (flutter_lints ^6.0.0)
```

Whenever fields are added to `GiftModel`, `WeddingModel`, or the enums,
`build_runner` must be re-run; existing `@HiveField(n)` indices must never
be changed — new fields should always use the next unused index.
