// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'HockeyBro';

  @override
  String get tagline => 'Drag your mallet. Push the puck in.';

  @override
  String get play => 'Play';

  @override
  String get howToPlay => 'How to play';

  @override
  String get settings => 'Settings';

  @override
  String get howToLine =>
      'Drag your mallet. Push the puck into the other goal.';

  @override
  String get skip => 'Skip';

  @override
  String get close => 'Close';

  @override
  String get blue => 'Blue';

  @override
  String get red => 'Red';

  @override
  String firstTo(int count) {
    return 'First to $count';
  }

  @override
  String get ready => 'Ready';

  @override
  String get goal => 'Goal';

  @override
  String winner(String name) {
    return '$name wins';
  }

  @override
  String get rematch => 'Rematch';

  @override
  String get home => 'Home';

  @override
  String get pause => 'Pause';

  @override
  String get paused => 'Paused';

  @override
  String get resume => 'Resume';

  @override
  String get restart => 'Restart';

  @override
  String get language => 'Language';

  @override
  String get music => 'Music';

  @override
  String get vibration => 'Vibration';

  @override
  String get privacy => 'Privacy';

  @override
  String get about => 'About';

  @override
  String versionLabel(String version) {
    return 'Version $version';
  }

  @override
  String get deviceLanguage => 'Device language';

  @override
  String get privacyError => 'The privacy page did not open. Try again.';

  @override
  String tapSide(String name, int score) {
    return '$name, $score. Drag';
  }

  @override
  String get youWin => 'You win';

  @override
  String get robotWins => 'Robot wins';

  @override
  String get onePlayer => '1 Player';

  @override
  String get twoPlayers => '2 Players';

  @override
  String get difficulty => 'Difficulty';

  @override
  String get easy => 'Easy';

  @override
  String get normal => 'Normal';

  @override
  String get hard => 'Hard';

  @override
  String get start => 'Start';

  @override
  String get adSlot => 'Ad';

  @override
  String get logoTop => 'HOCKEY';

  @override
  String get logoBottom => 'BRO';

  @override
  String get slogan => 'One Phone. Two Bros. One Winner.';

  @override
  String get onePlayerHint => 'Against the bot';

  @override
  String get twoPlayersHint => 'Face to face, one phone';

  @override
  String get goalShout => 'GOAL!';

  @override
  String get bringPuck => 'Bring the puck';

  @override
  String scoredBy(String name) {
    return '$name scores!';
  }

  @override
  String botTag(String level) {
    return 'BOT · $level';
  }

  @override
  String get youTag => 'YOU';

  @override
  String get menu => 'Menu';

  @override
  String get playAgain => 'Play again';

  @override
  String get youWinShout => 'YOU WIN!';

  @override
  String get closeOne => 'So close!';

  @override
  String wonRematch(String name) {
    return '$name won · Rematch?';
  }

  @override
  String get bot => 'Bot';
}
