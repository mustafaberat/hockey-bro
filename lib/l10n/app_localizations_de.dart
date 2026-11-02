// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for German (`de`).
class AppLocalizationsDe extends AppLocalizations {
  AppLocalizationsDe([String locale = 'de']) : super(locale);

  @override
  String get appTitle => 'Faceoff';

  @override
  String get tagline => 'Zieh deinen Schläger. Schieb den Puck.';

  @override
  String get play => 'Spielen';

  @override
  String get howToPlay => 'So geht\'s';

  @override
  String get settings => 'Einstellungen';

  @override
  String get howToLine =>
      'Zieh deinen Schläger. Schieb den Puck ins andere Tor.';

  @override
  String get skip => 'Überspringen';

  @override
  String get close => 'Schließen';

  @override
  String get blue => 'Blau';

  @override
  String get red => 'Rot';

  @override
  String firstTo(int count) {
    return 'Zuerst $count';
  }

  @override
  String get ready => 'Bereit';

  @override
  String get goal => 'Tor';

  @override
  String winner(String name) {
    return '$name gewinnt';
  }

  @override
  String get rematch => 'Nochmal';

  @override
  String get home => 'Start';

  @override
  String get pause => 'Pause';

  @override
  String get paused => 'Pausiert';

  @override
  String get resume => 'Weiter';

  @override
  String get restart => 'Neu starten';

  @override
  String get language => 'Sprache';

  @override
  String get music => 'Musik';

  @override
  String get vibration => 'Vibration';

  @override
  String get privacy => 'Datenschutz';

  @override
  String get about => 'Info';

  @override
  String versionLabel(String version) {
    return 'Version $version';
  }

  @override
  String get deviceLanguage => 'Gerätesprache';

  @override
  String get privacyError =>
      'Die Datenschutzseite hat sich nicht geöffnet. Versuch es noch einmal.';

  @override
  String tapSide(String name, int score) {
    return '$name, $score. Ziehen';
  }

  @override
  String get youWin => 'Du gewinnst';

  @override
  String get robotWins => 'Roboter gewinnt';

  @override
  String get onePlayer => '1 Spieler';

  @override
  String get twoPlayers => '2 Spieler';

  @override
  String get difficulty => 'Schwierigkeit';

  @override
  String get easy => 'Leicht';

  @override
  String get normal => 'Normal';

  @override
  String get hard => 'Schwer';

  @override
  String get start => 'Start';

  @override
  String get adSlot => 'Anzeige';

  @override
  String get logoTop => 'HOCKEY';

  @override
  String get logoBottom => 'DUELL';

  @override
  String get workingTitle => '(Arbeitstitel)';

  @override
  String get onePlayerHint => 'Gegen den Bot';

  @override
  String get twoPlayersHint => 'Gegenüber, ein Handy';

  @override
  String get goalShout => 'TOR!';

  @override
  String scoredBy(String name) {
    return '$name trifft!';
  }

  @override
  String botTag(String level) {
    return 'BOT · $level';
  }

  @override
  String get youTag => 'DU';

  @override
  String get menu => 'Menü';

  @override
  String get playAgain => 'Nochmal';

  @override
  String get youWinShout => 'GEWONNEN!';

  @override
  String get closeOne => 'Knapp!';

  @override
  String wonRematch(String name) {
    return '$name gewinnt · Revanche?';
  }

  @override
  String get bot => 'Bot';
}
