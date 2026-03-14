# Developer Guide – HSK Teacher

This document describes the project architecture, coding conventions, and the main workflows for development, testing, and release.

## Tech Stack
- Flutter 3.9.x+
- Dart SDK per `environment` in `pubspec.yaml`
- Routing: `go_router`
- Localization: Flutter gen-l10n (English and French)
- Storage: `shared_preferences`
- Platforms: Android, iOS, Web, Desktop (macOS/Linux/Windows)

## Project Overview
The app helps learners browse HSK levels (1–6), list words by level/page, and view a detailed card for each word (hanzi, pinyin, meanings). It supports deep linking on the web with clean path URLs and provides a themed UI with internationalization.

## Repository Structure (selected)
- `lib/`
  - `app.dart` – Root `MyApp` widget, sets theme, localization, and `GoRouter` config.
  - `main.dart` – Entry point, initializes storage and web URL strategy.
  - `router.dart` – `AppRouter` with `GoRouter` + `ShellRoute` and pages.
  - `theme.dart` – `AppTheme` class that centralizes UI theming and constants.
  - `main_layout.dart` – Shared app scaffold with AppBar and Home button.
  - `error_page.dart` – Friendly error page for unknown routes.
  - `level_selection_page.dart` – Home screen to pick HSK level.
  - `words_list_page.dart` – Paginated table of words for a level.
  - `word_detail_page.dart` and `word_detail_content.dart` – Word details UI.
  - `services/storage_service.dart` – Persistence for learned/visited words and last path/level with `SharedPreferences`.
  - `l10n/` – Generated localizations and ARB sources (see Localization section).
  - `url_strategy_web.dart` and `url_strategy_noop.dart` – Web path URL strategy vs. no-op on non-web.
- `assets/data/levels/level_{1..6}/` – JSON chunks per level.
- `l10n.yaml` – gen-l10n configuration.
- `pubspec.yaml` – dependencies and assets.

## Key Design Decisions (align with guidelines)
- Widgets are defined in separate files (e.g., `error_page.dart`, `main_layout.dart`, individual pages).
- Constants inside classes are declared as `static` (see `AppTheme`).
- Routing uses `GoRouter` with a `ShellRoute` and named routes, configured in `AppRouter`.
- Web routing applies the path URL strategy (no hash). Server must fallback to `index.html` for client-side routes.
- Internationalization defaults to English and French.
- A dedicated error page is provided and used by the router on errors.
- Theme management is centralized in `AppTheme`, applied at the app root in `MyApp`.

## Architecture
- Root: `MaterialApp.router` in `MyApp` (see `app.dart`).
  - `theme: AppTheme.lightTheme`
  - `routerConfig: AppRouter.router`
  - `supportedLocales: [Locale('en'), Locale('fr')]`
  - Localization delegates include `AppLocalizations`.
- Routing (`router.dart`):
  - `GoRouter` with `ShellRoute` that wraps pages in `MainLayout`.
  - Routes:
    - `/` – `LevelSelectionPage`
    - `/level/:level/page/:page` – `WordsListPage`
    - `/level/:level/word/:index` – `WordDetailPage`
  - `errorBuilder` → `ErrorPage`.
  - `redirect` saves the last visited path via `StorageService`.
- Storage (`StorageService`):
  - Keys: `keyLearnedWords`, `keyVisitedWords`, `keyLastLevel`, `keyLastPath`.
  - Provides helpers to toggle learned state, track visited words, save last level/path.
- Data loading:
  - Words are served from JSON assets under `assets/data/levels/` and loaded per page.

## Localization
- Config: `l10n.yaml`
  - `arb-dir: lib/l10n`
  - `template-arb-file: app_en.arb`
  - `output-localization-file: app_localizations.dart`
- Add/Update translations:
  1. Edit `lib/l10n/app_en.arb` and `lib/l10n/app_fr.arb` keys.
  2. Run `flutter gen-l10n` or rely on `flutter run` to regenerate.
  3. Use in code via `AppLocalizations.of(context)!.yourKey`.

## Theming
- Use `AppTheme` for colors, paddings, shapes, and typography-related constants.
- When adding new UI, reuse existing styles or extend `AppTheme` with new static constants.
- Avoid hardcoded values in widgets; prefer `AppTheme` constants.

## Web URL Strategy
- `url_strategy_web.dart` calls `usePathUrlStrategy()`; imported from `main.dart` for web targets.
- Hosting requirement: Configure the server to route unknown paths to `index.html` (SPA fallback). Without this, deep links will 404.

## Coding Conventions
- One widget/page per file to keep code modular.
- Constants in classes must be declared `static` (and `const` when possible).
- Prefer stateless/stateful widgets over functions for UI components that hold state.
- Use `GoRouter` navigation helpers (`context.go`, `context.push`) with named routes.
- Keep business logic out of widgets where possible—factor into services/helpers.
- Keep localization text in ARB files; do not hardcode user-facing strings.

## Common Tasks

### Run
- Android: `flutter run -d android`
- iOS: `flutter run -d ios`
- Web: `flutter run -d chrome`
- Desktop: `flutter run -d macos` (or `linux` / `windows` if enabled)

### Analyze, Format, Test
- Static analysis: `flutter analyze`
- Format: `dart format .`
- Tests (if present): `flutter test`

### Build
- Android APK: `flutter build apk`
- iOS: `flutter build ios`
- Web: `flutter build web`
- Desktop: `flutter build <platform>`

## Adding a New Page/Route
1. Create a new widget file under `lib/` (e.g., `new_feature_page.dart`).
2. Use `MainLayout` if you need consistent AppBar/Home button, or add via `ShellRoute` wrapper.
3. Register the route in `router.dart`:
   - Add a `GoRoute` with `path`, `name`, and a `builder`.
   - Localize the title with `AppLocalizations` inside the `ShellRoute` builder as needed.
4. If the page needs persistent state, add a key under `StorageService` (static constant) and implement helpers.
5. Add localized strings to ARB files.

## Working with Data
- Place new data JSON under the relevant `assets/data/levels/level_X/` folder.
- Update `pubspec.yaml` if new top-level asset directories are introduced.
- Parse and display in the corresponding pages/components.

## Error Handling
- Unknown routes or thrown errors during routing display `ErrorPage`.
- Consider logging errors (console for now) and provide user-friendly messages via l10n.

## Contribution Workflow
- Create feature branches from `main`.
- Follow the coding conventions above.
- Keep commits small and descriptive.
- Run `flutter analyze` and format before committing.
- Open a PR with a clear description, screenshots (if UI changes), and testing notes.

## Release Notes
- Update `version:` in `pubspec.yaml` per semver.
- Build for targeted platforms (see Build section).
- For web hosting, ensure SPA fallback is configured.

## Troubleshooting
- Web deep-links 404 → misconfigured host fallback to `index.html`.
- Missing assets → verify `pubspec.yaml` assets paths and run `flutter pub get`.
- iOS build issues → run from Xcode to accept signing settings; ensure CocoaPods installed.
- Android build issues → check `minSdkVersion`, Gradle, and Java versions in Android Studio.

## License
See repository license information.