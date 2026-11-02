// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Turkish (`tr`).
class AppLocalizationsTr extends AppLocalizations {
  AppLocalizationsTr([String locale = 'tr']) : super(locale);

  @override
  String get appTitle => 'Faceoff';

  @override
  String get tagline => 'Tokmağını sürükle. Diski it.';

  @override
  String get play => 'Oyna';

  @override
  String get howToPlay => 'Nasıl oynanır';

  @override
  String get settings => 'Ayarlar';

  @override
  String get howToLine => 'Tokmağını sürükle. Diski öteki kaleye it.';

  @override
  String get skip => 'Geç';

  @override
  String get close => 'Kapat';

  @override
  String get blue => 'Mavi';

  @override
  String get red => 'Kırmızı';

  @override
  String firstTo(int count) {
    return 'İlk $count gol';
  }

  @override
  String get ready => 'Hazır';

  @override
  String get goal => 'Gol';

  @override
  String winner(String name) {
    return '$name kazandı';
  }

  @override
  String get rematch => 'Yeniden';

  @override
  String get home => 'Ana sayfa';

  @override
  String get pause => 'Durdur';

  @override
  String get paused => 'Durdu';

  @override
  String get resume => 'Devam';

  @override
  String get restart => 'Baştan';

  @override
  String get language => 'Dil';

  @override
  String get music => 'Müzik';

  @override
  String get vibration => 'Titreşim';

  @override
  String get privacy => 'Gizlilik';

  @override
  String get about => 'Hakkında';

  @override
  String versionLabel(String version) {
    return 'Sürüm $version';
  }

  @override
  String get deviceLanguage => 'Cihaz dili';

  @override
  String get privacyError => 'Gizlilik sayfası açılmadı. Tekrar dene.';

  @override
  String tapSide(String name, int score) {
    return '$name, $score. Sürükle';
  }

  @override
  String get youWin => 'Kazandın';

  @override
  String get robotWins => 'Robot kazandı';

  @override
  String get onePlayer => '1 oyuncu';

  @override
  String get twoPlayers => '2 oyuncu';

  @override
  String get difficulty => 'Zorluk';

  @override
  String get easy => 'Kolay';

  @override
  String get normal => 'Normal';

  @override
  String get hard => 'Zor';

  @override
  String get start => 'Başla';

  @override
  String get adSlot => 'Reklam';
}
