# Takı Sandığım — Project Documentation

## 1. Purpose of the Project

**Takı Sandığım** ("My Jewelry Box") is a Flutter mobile app for tracking
gold jewelry, bracelets, necklaces, cash, and foreign-currency gifts
exchanged at Turkish weddings/engagements/henna nights — a strong cultural
tradition where guests pin gold coins or cash onto the bride/groom. The
core use cases are:

- Recording who received what at an event ("received by us") or what we
  gave to someone else ("given by us"), for weddings, engagements, henna
  nights, and nikah ceremonies,
- Automatically computing a per-person balance ("who owes us / who do we
  owe") so gift-giving reciprocity can be tracked over years,
- Photographing a handwritten "notebook page" from a wedding and using OCR
  to auto-parse lines into structured entries for bulk import,
- Converting gold-based gifts into TL value using the current gram gold
  rate, or foreign-currency gifts (USD/EUR/GBP) using the current exchange
  rate, and showing an overall budget summary plus analytics charts,
- Projecting how a gift's TL value has changed since it was recorded
  ("Değer Analizi" / Value Analysis), via a linear interpolation between
  the entry-day rate and the current rate,
- Exporting the full gift list as a PDF or Excel file, or sharing a text
  summary, from a dedicated Reports screen.

The UI language and all in-app strings are entirely **Turkish**.

## 2. Tech Stack

| Layer | Technology |
|---|---|
| Framework | Flutter (Dart SDK ^3.11.5) |
| State management | `flutter_bloc` (BLoC pattern) + `equatable` |
| Routing | `go_router` (`StatefulShellRoute` for the bottom-tab shell, plus a top-level `redirect` for onboarding) |
| Local database | `hive` / `hive_flutter` (NoSQL, code-generated type adapters) |
| Networking | `dio` (gold rate + currency rate services) |
| OCR | `google_mlkit_text_recognition` (Latin script) |
| Camera / gallery | `camera`, `image_picker`, `image` (cropping), `path_provider` |
| UI helpers | `google_fonts` (Plus Jakarta Sans), `flutter_screenutil` (responsive sizing), `fl_chart` (charts), `intl` (date formatting, `tr_TR` locale), `uuid` |
| Export / Share | `excel`, `pdf`, `share_plus` |
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
│   ├── theme/                     # Color palette, light/dark ThemeData, ThemeController
├── core/
│   ├── database/                  # Hive init, box names, settings repo
│   ├── network/                   # Dio client, gold rate + currency rate services
│   ├── utils/                     # Currency converter, date formatter
│   └── widgets/                   # Shared custom UI components
└── features/
    ├── dashboard/                 # Home: balance breakdown, per-person totals, upcoming weddings
    ├── scanner/                   # Camera/OCR notebook-scanning flow
    ├── tracker/                   # Add-gift, ledger, analytics, and value-analysis screens
    ├── profile/                   # User profile, gift export/share, reports
    ├── settings/                  # Dark mode, notifications, help, developers info
    └── onboarding/                # Intro, name entry, email entry
```

Each feature is consistently split into `data/` (models + repositories),
`domain/` (pure business logic, Flutter-independent), and `presentation/`
(bloc + screens + widgets). Smaller features (`settings`, `onboarding`)
only have a `presentation/` layer since they have no dedicated data model.

## 4. App Startup and Navigation

- `main.dart`: calls `HiveService.init()`, initializes the `tr_TR` date
  locale, and runs `MaterialApp.router` inside `ScreenUtilInit` (design
  reference size 375×812). `themeMode` is driven by `ThemeController`
  (`ValueListenableBuilder`), which persists the dark-mode preference via
  `UserSettingsRepository`.
- `AppRouter` (`lib/app/routes/app_router.dart`): defines a root-level
  `StatefulShellRoute.indexedStack` with a 5-tab bottom navigation
  (`AppShell`): **Home** (`/`), **Ledger** (`/ledger`), **Analytics**
  (`/analytics`), **Profile** (`/profile`), **Settings** (`/settings`).
  Outside the shell there are modal-like routes: `/add-gift` (opened with
  `extra: 0`/`1` to pre-select the "Add manually" or "Scan notebook" tab),
  `/reports`, `/gift-value-analysis` (takes a `GiftModel` via `extra`), and
  `/value-analysis` (takes a category key via `extra`).
- A top-level `redirect` checks `UserSettingsRepository().getName()` on
  every navigation: if a name is already saved and the current location is
  one of the onboarding routes (`/onboarding`, `/onboarding/name`,
  `/onboarding/email`), it redirects straight to `/`. This prevents
  onboarding from re-appearing on every app restart once it's been
  completed once.

## 5. Data Model (Hive)

Hive boxes are declared in `lib/core/database/box_names.dart`: `weddings`,
`gifts`, `settings` (this last box is an untyped generic key-value store —
name, email, dark-mode flag, notifications flag, profile photo (base64),
and per-event-type event dates).

### `WeddingModel` (typeId: 0)
Represents a single wedding/engagement event: `id`, `title`, `date`,
`location?`, `note?`. **Note:** `WeddingRepository` already has read/write
methods for this model, but **no screen anywhere creates a new
`WeddingModel`**. As a result, the dashboard's "Upcoming Weddings" section
is currently always empty. This is the most visible unfinished feature in
the project.

### `GiftModel` (typeId: 1)
A single gift/jewelry entry: `id`, `weddingId?`, `personName`, `giftType`,
`amount` (piece count / grams / foreign-currency amount, or a TL amount for
cash), `estimatedValueTl` (computed TL value), `direction` (received vs.
given), `date`, `note?`, `goldRateTl?` (the gram gold rate at the time the
entry was recorded, if gold-based), `relationType` (defaults to `friend`),
`eventType?` (which event the gift belongs to — wedding/engagement/henna/
nikah), `currencyCode?` and `currencyRateTl?` (set instead of `goldRateTl`
when the gift was entered in a foreign currency).

### Enums (`gift_enums.dart`)
- **`GiftType`** (typeId: 2): `quarterGold` (1.75 g), `halfGold` (3.5 g),
  `fullGold` (7 g), `gremseGold` (3 g), `bracelet`, `necklace`, `cash`,
  `other`. Each type has a `label` extension (Turkish display name) and a
  `gramEquivalent` extension (gold gram equivalent).
- **`GiftDirection`** (typeId: 3): `received` ("Bize Takılan" — given to
  us) / `given` ("Bizim Taktığımız" — given by us).
- **`RelationType`** (typeId: 4): `family`, `relative`, `friend`.
- **`EventType`** (typeId: 5): `wedding`, `engagement`, `henna`, `nikah` —
  each has a `label` and a `locationLabel` ("Düğünde takıldı", etc.) used
  on the per-gift detail rows.

`HiveService.init()` registers all adapters and opens the corresponding
boxes. When adding/removing model fields, `.g.dart` files must be
regenerated via `build_runner`, and **existing `@HiveField` indices must
never be changed** — Hive's backward compatibility relies on those
indices. The next free `GiftModel` index is `14`.

## 6. Business Logic (Domain Layer)

This layer has no Flutter dependency and consists of plain Dart classes —
making it the best place to add unit tests (currently there are none in
the project).

- **`BudgetCalculator` / `BudgetSummary`** (dashboard/domain): sums
  `estimatedValueTl` across all entries into `received` / `given`, and
  computes `netBalanceTl = received - given`.
- **`CurrencyConverter`** (core/utils): if `GiftType.gramEquivalent > 0`,
  computes `amount * gramEquivalent * goldRateTl`; for `cash`, `amount` is
  used directly as TL; for foreign-currency gifts, `amount * currencyRateTl`;
  otherwise (`bracelet`, `necklace`, `other`) it falls back to
  `amount * goldRateTl`, treating `amount` as grams.
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
- **`GiftValueCategory`** (tracker/domain): classifies a gift into a
  small, fixed set of categories for value analysis — one per gold
  `GiftType` that has a captured rate, or a single `Döviz` (currency)
  category for any foreign-currency gift. Gifts with no captured rate
  (`cash`, `other`, or missing `goldRateTl`) are excluded. `groupBy` turns
  a gift list into category → gifts groups, sorted by count, which backs
  the fixed category grid on the Analytics screen (chosen over an
  unbounded flat list so it doesn't grow without limit).
- **`GiftValueProjection`** (tracker/domain): given a gift's entry-day
  value and its current recalculated value, builds a **linearly
  interpolated** time series between those two points for a selected range
  (day/week/month/year/all-time). This is an approximation, not real
  historical market data — there's no historical rate API — and the UI
  (`GiftValueAnalysisScreen`) is explicit about this ("Uç noktalar gerçek,
  aradaki çizgi tahminidir" — "the endpoints are real, the line between
  them is estimated").
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
  ids with `uuid`, and exposes `addGift`/`delete` to the BLoC, forwarding
  the currency fields when present.
- **`UserSettingsRepository`** (core/database): reads/writes the user's
  name, email, dark-mode flag, notifications flag, profile photo, and
  per-event-type event dates in the `settings` box.
- **`GoldRateService`** (core/network): fetches the live gram-gold sell
  rate from `https://finans.truncgil.com/today.json` (a free, key-less
  endpoint), parsing Turkish-formatted numbers (`.` thousands, `,`
  decimal). Falls back to a hardcoded `3200.0` TL if the request fails.
- **`CurrencyRateService`** (core/network): fetches the live TL rate for a
  `SupportedCurrency` (USD, EUR, GBP) from the same `truncgil.com`
  endpoint, with a fallback rate baked into each `SupportedCurrency`
  constant if the request fails.
- **`GiftExportService`** (profile/data): builds PDF (`pdf` package) and
  Excel (`excel` package) exports of the full gift list, writes them to a
  real temp file via `path_provider` (required for `share_plus` to honor a
  custom file name on Android), and shares them via `share_plus`. Also
  builds a plain-text summary for the "share as text" option. All share
  calls have a 20s timeout so the UI never spins forever if the share
  sheet fails to open.
- **`DioClient`** (core/network): provides a shared, pre-configured `Dio`
  instance.

## 8. Key Screens

- **Dashboard (`/`)**: greeting (uses saved user name if set), a
  received/given direction toggle, a balance breakdown card (pie chart by
  gift type, with per-slice title color chosen for contrast against the
  slice's background), a per-person totals list (expandable, shows each
  person's individual gifts), and an upcoming weddings list (currently
  always empty — see §5). Listens to Hive box changes via `watch()` and
  refreshes automatically.
- **Add Gift (`/add-gift`)**: a `TabBarView` with two tabs: "Add manually"
  (a form for direction, person, relation, event type, gift type, and
  amount — either grams/pieces converted via the live gold rate, or a
  foreign-currency amount converted via the live currency rate — plus
  date and note) and "Scan notebook" (`ScannerBody`).
- **Scanner (the "Scan notebook" tab)**: capture via a custom
  camera bottom-sheet (with a crop frame) or pick from gallery → OCR →
  a `PageView` of `LineConfirmationCard`s for reviewing/editing each parsed
  line (Add/Skip). Each "Add" calls `TrackerRepository.addGift` directly.
- **Ledger (`/ledger`)**: a searchable, person-grouped, expandable list.
  Each person card shows the most recent given/received gift, total
  balance, and the full entry history (deletable, with a confirmation
  dialog).
- **Analytics (`/analytics`)**: a live gold-rate card, total-entry and
  person-count stat tiles, a received-vs-given donut chart, a per-person
  net-balance bar chart (top 6 people), and a **Değer Analizi** (Value
  Analysis) section — a fixed category grid (one tile per gold type +
  one for currency gifts) that navigates to a category-scoped, searchable
  person list.
- **Value Analysis List (`/value-analysis`)**: gifts within a single
  category, searchable by person name, each row tagged with a
  `BasisBadge` (gold type or currency code) and navigating to the detail
  screen.
- **Gift Value Analysis (`/gift-value-analysis`)**: shows a single gift's
  entry-day value vs. its current recalculated value, the percentage
  change, and a line chart (day/week/month/year/all-time range selector)
  built from `GiftValueProjection` — see §6 for the linear-interpolation
  caveat.
- **Profile (`/profile`)**: profile photo (from gallery), name/email
  editing, event-type + date selection ("Özel Günlerinizin Tarihi"),
  sharing the gift list as a text summary, a navigation card into
  **Reports**, and Logout / Delete Account (both device-local — there's
  no server-side account system, so these only clear/reset local Hive
  data).
- **Reports (`/reports`)**: three rows — PDF export, Excel export, and
  text share — each with its own independent loading state
  (`_processingKey`) so one export in progress doesn't block or visually
  affect the others, and a shared 20s timeout guard.
- **Settings (`/settings`)**: dark mode toggle (drives `ThemeController`),
  notifications toggle, a read-only "gold rate" info row, a Help section
  (send feedback, app version, privacy policy dialogs), and a Developers
  section (static credits).

## 9. Shared UI Components (`core/widgets`)

`CustomButton` (filled/outline variants, optional loading state),
`CustomCard` (rounded card, optional `onTap`/custom padding),
`CustomTextField`, and `BasisBadge` (a small solid-background pill tag for
gold type / currency code, deliberately opaque rather than a translucent
tint so it stays legible on both light and dark card backgrounds) — used
consistently across screens.

Theming is centralized via `AppTheme.light` / `AppTheme.dark`
(`app/theme/app_theme.dart`, both `Material3`/`ColorScheme.fromSeed`-based)
and the `AppColors` palette (`app/theme/app_colors.dart` — gold/brown
tones). `AppColors.muted(context)` is a theme-aware helper for
secondary/caption text: it returns the light-mode muted brown-gray on
light backgrounds, and a separate lighter `textMutedDark` tone in dark
mode, since a single fixed muted color doesn't have enough contrast in
both themes. Dark mode is toggled from Settings and persisted via
`ThemeController`.

## 10. Known Gaps / Opportunities for AI-Assisted Development

A prioritized list for continued development:

1. **No wedding-creation screen** — `WeddingModel` and `WeddingRepository`
   are ready, but no screen ever creates a new wedding, so the dashboard's
   "Upcoming Weddings" section can never populate. Additionally,
   `GiftModel.weddingId` is never set from any UI (event association is
   tracked via `eventType` instead, which is a lighter-weight substitute).
2. **No tests** — no `test/` folder or `*_test.dart` files exist. The
   domain layer (`BudgetCalculator`, `BalanceAnalyzer`, `NotebookParser`,
   `CurrencyConverter`, `GiftValueProjection`, `GiftValueCategory`, etc.)
   is pure Flutter-independent Dart and is well-suited for unit testing.
3. **No dependency injection** — repositories are instantiated directly
   (e.g. `TrackerRepository()`) in each screen, relying on global
   `Hive.box<T>()` lookups. As the app grows, a DI approach (e.g.
   `get_it`, or actually using the already-included but unused `provider`
   package) would improve testability.
4. **Unused `provider` dependency** — either remove it or start using it
   for a real purpose.
5. **No editing, only deletion** — once a `GiftModel` entry is added, it
   can only be deleted, not edited.
6. **Value analysis is an approximation, not real historical data** — see
   §6; there's no historical gold/currency rate API integrated, so the
   in-between chart points are a straight-line estimate between the entry
   date and today, clearly labeled as such in the UI.
7. **No real backend/account system** — "Logout" and "Delete Account" on
   the Profile screen only affect local Hive data on the device; there's
   no server, so nothing is actually synced or recoverable across devices.

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
