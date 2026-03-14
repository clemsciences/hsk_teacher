# HSK Teacher

Learn HSK Chinese characters (汉字) by level, browse word lists, and open detailed cards with pinyin and meanings. Available on mobile, desktop, and the web.

## Key Features
- HSK levels 1–6 with built‑in data (offline once installed)
- Word list pages with pagination
- Word detail page with hanzi, pinyin, and meanings
- Smart routing with GoRouter
- Works on the web with path‑based URLs (no hash) and a friendly error page
- Localization: English and French (auto‑detected from system, switch via OS)
- Consistent look & feel with a central theme

## Quick Start

### Prerequisites
- Flutter SDK (3.9.x or newer)
- A recent Android Studio / Xcode if targeting Android/iOS
- Chrome (web), or macOS/Linux/Windows tools for desktop

### Run
- Android: `flutter run -d android`
- iOS: `flutter run -d ios`
- Web: `flutter run -d chrome`
- Desktop: `flutter run -d macos` (or `linux` / `windows` if enabled)

### Build
- Android APK: `flutter build apk`
- iOS (archive): `flutter build ios`
- Web: `flutter build web`
- macOS/Linux/Windows: `flutter build <platform>`

## Using the App
1. Start on the Home page and choose an HSK level
2. Browse the list of words for that level (use pagination controls)
3. Tap a row to open the word details
4. Use the Home icon to return at any time

Tip: On the web you can share direct links to lists and word details. The app uses clean path URLs.

## Languages
- English (en)
- Français (fr)

Your device language is used automatically. Content (definitions) may remain in English depending on data sources.

## Web Notes
- Clean URLs are enabled (no `#/`): server hosting must route all unknown paths to `index.html` (single‑page app fallback)
- An error page is displayed if a route is invalid

## Data & Privacy
- Word lists are bundled as app assets
- The app may store a minimal last visited path locally to help you resume where you left off
- No personal analytics are collected by default

## Troubleshooting
- If the web app shows 404s on deep links, configure your host to serve `index.html` for all app routes
- If lists are empty, ensure assets are included (they are declared under `assets/` in `pubspec.yaml`)
- Clear the app/site storage if navigation seems stuck, then retry

## Credits
- Built with Flutter and GoRouter
- HSK data compiled from public resources

## License
This project is provided under an open license by the repository owner. See the repository for details.
