# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Overview

HSK Teacher is a Flutter app for learning HSK Chinese characters (汉字) by level (1–6).
It runs on Android, iOS, Web, and Desktop (macOS/Linux/Windows). All word data is
bundled as assets, so it works offline once installed.

## Commands

- Install deps: `flutter pub get`
- Run: `flutter run -d chrome` (or `-d android`, `-d ios`, `-d macos`, `-d linux`, `-d windows`)
- Analyze: `flutter analyze`
- Format: `dart format .`
- All tests: `flutter test`
- Single test file: `flutter test test/storage_service_test.dart`
- Single test by name: `flutter test --plain-name "substring of test name"`
- Regenerate localizations: `flutter gen-l10n` (also runs automatically on `flutter run`)
- Build: `flutter build apk` / `flutter build web` / `flutter build <platform>`

CI (`.github/workflows/build.yaml`) builds the APK + Web on push/PR to `main`, and
creates a draft GitHub Release when a `v*` tag is pushed.

## Data pipeline (important, non-obvious)

Word data has two layers, and the runtime only reads the second:

1. `lib/data/complete.json` — the full source dictionary.
2. `lib/hsk_parser.dart` — a **standalone Dart script** (has its own `main()`, not part
   of the app). Run it with `dart run lib/hsk_parser.dart` to regenerate the bundled
   assets. It splits `complete.json` per HSK level into 10-word chunks under
   `assets/data/levels/level_{1..6}/`:
   - `chunk_<N>.json` — 10 words each, fields `hanzi`, `pinyin`, `meanings`.
   - `metadata.json` — `{ total_items, chunk_size (10), total_chunks }`.

At runtime, pages load data via `rootBundle.loadString(...)` (see `words_list_page.dart`
and `word_detail_page.dart`): they read `metadata.json`, then compute
`chunkIndex = globalIndex ~/ chunk_size` and `localIndex = globalIndex % chunk_size`.
**A list page's `page` route param equals the chunk index** (page 0 = `chunk_0.json`).

If you add/change word data, edit `complete.json` and re-run the parser; do not hand-edit
the generated chunk files. `lib/data/hsk_data.dart` is a legacy hardcoded map and is **not
referenced** by the app.

## Architecture

- Entry: `lib/main.dart` → initializes `StorageService`, calls `setupUrlStrategy()`, runs `MyApp`.
- `lib/app.dart` — `MyApp` (`MaterialApp.router`) wraps everything in a `StorageServiceProvider`
  (an `InheritedWidget`); access it anywhere via `StorageServiceProvider.of(context)`.
- `lib/router.dart` — `AppRouter.router`, a `GoRouter` with a single `ShellRoute` that wraps
  pages in `MainLayout` and derives the AppBar title from `state.fullPath`. Routes:
  - `/` → `LevelSelectionPage`
  - `/quiz` → `QuizPage`
  - `/level/:level/page/:page` → `WordsListPage`
  - `/level/:level/word/:index` → `WordDetailPage`
  - `errorBuilder` → `ErrorPage`; `redirect` persists the current path via `StorageService.saveLastPath`.
  - Word navigation can pass `hanzi`/`pinyin`/`meanings` through `state.extra` (a Map) to avoid a reload.
- `lib/quiz_page.dart` — self-contained quiz, reached from a button on `LevelSelectionPage`.
  See the Quiz section below.
- `lib/word_detail_content.dart` — `WordDetailContent`, the reusable word display (hanzi, level
  badge, pinyin, meanings; `compact` flag). Used by `WordDetailPage`, `LevelSelectionPage`,
  `WordsListPage`, and `QuizPage`. It **requires a `level`**, which the chunk JSON does not carry —
  callers must supply it.
- `lib/services/storage_service.dart` — `SharedPreferences` wrapper. Keys: learned words,
  visited words (history), last level, last path. Word keys use the format `level_<level>_<hanzi>`.
- Web URL strategy uses conditional imports: `url_strategy_noop.dart` on non-web,
  `url_strategy_web.dart` (calls `usePathUrlStrategy()`, clean URLs without `#/`) on web.
  **Web hosting must fall back to `index.html` for all routes**, or deep links 404.
- `lib/theme.dart` — `AppTheme` centralizes theming; applied at the root via `AppTheme.lightTheme`.

## Quiz (`lib/quiz_page.dart`)

A single `QuizPage` `StatefulWidget` driven by a `_QuizPhase` enum (setup → loading → playing →
finished). Questions are generated on the fly; nothing is persisted.

- Setup screen configures: number of questions (slider, 5–30), quiz type (dropdown), and level
  (dropdown; `null` = all levels).
- **One quiz = one type.** `QuizType` (`pinyinToHanzi`, `hanziToPinyin`, `hanziToMeaning`) is chosen
  once in setup; every question in the run uses that single type. Do not re-randomize the type per
  question.
- On start, `_loadPool` reads every chunk of the selected level(s) in parallel (`Future.wait`) into a
  flat in-memory list, **injecting `entry['level'] = level`** since chunks omit it (needed by
  `WordDetailContent`). `_buildQuestion` then picks a correct word + 3 distinct distractors (deduped
  via a `Set`) per question.
- After an answer, the full word page (`WordDetailContent`) is shown responsively: a **popup
  (`showDialog`)** on mobile, a **side panel** beside the question on desktop/web. The breakpoint is
  `QuizPage.wideBreakpoint` (800), matching the convention below.

## Responsive layout conventions

- Width breakpoint for "wide" (desktop/web) vs "narrow" (mobile) is **800** logical px, via
  `LayoutBuilder` (`WordsListPage`, `QuizPage`). Wide layouts use side-by-side panels; narrow use
  stacked columns / dialogs.
- `MainLayout` wraps its body in `SafeArea` — Android edge-to-edge otherwise clips content behind the
  system navigation bar. Keep page content inside `MainLayout` (via the `ShellRoute`) rather than
  building separate scaffolds.
- `DataTable` (in `WordsListPage`) does not reflow; on mobile its meanings column width and column
  spacing are computed from `constraints.maxWidth`, and the table is wrapped in a horizontal
  `SingleChildScrollView` so wide content scrolls instead of clipping.

## Conventions (from `.junie/guidelines.md`)

- One widget per file.
- Class-level constants must be `static` (see `AppTheme`, `StorageService` keys).
- All user-facing strings live in ARB files (`lib/l10n/app_en.arb`, `app_fr.arb`); access via
  `AppLocalizations.of(context)!.yourKey`. Never hardcode UI text. English and French are required.
- Use `GoRouter` for navigation; web targets must apply the path URL strategy and define an error page.

## Localization

Config is in `l10n.yaml` (arb-dir `lib/l10n`, template `app_en.arb`, output `app_localizations.dart`).
To add a string: edit both `app_en.arb` and `app_fr.arb`, then run `flutter gen-l10n`. The generated
`app_localizations*.dart` files are committed.
