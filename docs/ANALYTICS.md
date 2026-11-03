# HockeyBro — Firebase Analytics

Mağaza adı: HockeyBro: 2 Player Air Hockey. Uygulama içi kısa ad: HockeyBro.

Android paket adı ve iOS bundle: `com.arusoft.hockeybro`. Firebase proje kimliği: `arusoft-hockeybro`. Görünen ad: HockeyBro.

Proje ve iki uygulama konsolda duruyor:

- https://console.firebase.google.com/project/arusoft-hockeybro/overview
- Android: `com.arusoft.hockeybro`
- iOS: `com.arusoft.hockeybro`

`google-services.json` `android/app/` altında, `GoogleService-Info.plist` `ios/Runner/` altında. İkisi de Firebase’den indirildi. Dosya silinirse oyun yine açılır ve Analytics sessizce kapanır. Android’de Gradle eklentisi dosya varken uygulanır.

Ekranlar `FirebaseAnalytics` çağırmaz. Olaylar `lib/analytics/analytics_service.dart` üzerinden gider.

## Olaylar

| Olay | Ne zaman | Parametreler |
|---|---|---|
| `app_open` | Açılış | `device_id`, `open_count` |
| `match_start` | Maç başladı | `match_number`, `trigger` (`new`, `rematch`, `restart`), `win_score`, `mode` (`1p`, `2p`), `difficulty` |
| `goal` | Gol | `match_number`, `scorer` (`p1`, `p2`), `score_p1`, `score_p2`, `mode`, `difficulty` |
| `match_end` | Maç bitti | `match_number`, `winner`, `score`, `goals_p1`, `goals_p2`, `duration_s`, `win_score`, `mode`, `difficulty` |
| `match_quit` | Bitmeden çıkış | `match_number`, `score`, `score_p1`, `score_p2`, `duration_s`, `from` (`menu`, `restart`, `back`), `mode`, `difficulty` |
| `match_end_choice` | Bitiş kartındaki seçim | `match_number`, `choice` (`rematch`, `menu`), `mode`, `difficulty` |
| `pause_open` | Duraklatma | `match_number`, `score_p1`, `score_p2`, `source`, `mode`, `difficulty` |
| `settings_open` | Ayarlar | `source` |
| `how_to_play_open` | Nasıl oynanır | `source` |
| `settings_change` | Dil, müzik, titreşim, zorluk | `setting`, `value` |

`p1` alttaki kırmızı, `p2` üstteki mavi. Dokunuş, sopa hareketi ve fizik karesi başına olay yok.
