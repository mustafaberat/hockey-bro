# HockeyBro

HockeyBro: 2 Player Air Hockey

One Phone. Two Bros. One Winner.

Package: `com.arusoft.hockeybro`  
Firebase project id: `arusoft-hockeybro`  
Console: https://console.firebase.google.com/project/arusoft-hockeybro/overview

## Getting Started

This project is a starting point for a Flutter application.

A few resources to get you started if this is your first Flutter project:

- [Learn Flutter](https://docs.flutter.dev/get-started/learn-flutter)
- [Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Flutter learning resources](https://docs.flutter.dev/reference/learning-resources)

For help getting started with Flutter development, view the
[online documentation](https://docs.flutter.dev/), which offers tutorials,
samples, guidance on mobile development, and a full API reference.

## UI: Comic Arcade

- Theme tokens live in `lib/theme/game_theme.dart` (`GameTheme`, provided by `GameThemeScope`). Arcade is the only theme today.
- TODO: Ayarlardan 3 tema (Arcade, Neon, Candy) arasında geçiş.
- Fonts: Baloo 2 (display) and Nunito (body), both OFL (`assets/fonts/`). They cover Turkish ş/ğ/İ.
- `flutter test` checks every screen fits 320x568 without overflow.
- Screenshots: `flutter test test/capture --dart-define=CAPTURE=true` writes PNGs to `build/screens/`.
- Launcher icon: `assets/icon/`, regenerate with `dart run flutter_launcher_icons`
  (then revert the unrelated `ASSETCATALOG_COMPILER_GENERATE_SWIFT_ASSET_SYMBOL_EXTENSIONS` change it makes in `project.pbxproj`).
