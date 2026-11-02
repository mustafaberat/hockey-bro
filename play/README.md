# Play Console assets (HockeyBro)

Nothing here is uploaded. Files only.

| File | Play Console field |
|---|---|
| `listing.txt` | Store listing JSON, 10 locales: title (≤30), short (≤80), full description |
| `whatsnew.txt` | Release notes (existing file, kept as is) |
| `icon-512.png` | App icon 512×512 (arcade_3) |
| `feature-graphic.png` | Feature graphic 1024×500 (same as `-en`); `feature-graphic-tr.png` for tr-TR |
| `screenshots/framed/{tr,en}/` | Phone screenshots 1080×1920 with captions |
| `screenshots/raw/<lang>/` | Plain 1080×1920 screenshots (tr en de es pt fr it) |
| `contact_play.png` | Overview |

Regenerate raw shots: `flutter test test/capture/store_capture_test.dart --dart-define=CAPTURE=true`
(writes `build/store/<lang>/`; ja/ko/zh are skipped because tests have no CJK font).

## Open before release
- **Release signing:** `android/app/build.gradle.kts` signs release with the debug key.
  Needs an upload keystore + `android/key.properties` + a release signingConfig (not created).
- **Privacy policy URL** `https://arusoft.vercel.app/privacy/hockeybro` returns 404.
  The policy must cover Firebase Analytics (random device id, game events) and AdMob.
- **Firebase:** `android/app/google-services.json` for `com.arusoft.hockeybro` (iOS: GoogleService-Info.plist).
- **AdMob:** real app id + unit ids (Google test ids now).
- **Data safety:** app activity + device id (analytics), advertising id (ads); no account, no location.
