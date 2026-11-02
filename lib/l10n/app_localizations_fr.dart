// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for French (`fr`).
class AppLocalizationsFr extends AppLocalizations {
  AppLocalizationsFr([String locale = 'fr']) : super(locale);

  @override
  String get appTitle => 'Faceoff';

  @override
  String get tagline => 'Glisse ton maillet. Pousse le palet.';

  @override
  String get play => 'Jouer';

  @override
  String get howToPlay => 'Comment jouer';

  @override
  String get settings => 'Réglages';

  @override
  String get howToLine =>
      'Glisse ton maillet. Pousse le palet dans l\'autre but.';

  @override
  String get skip => 'Passer';

  @override
  String get close => 'Fermer';

  @override
  String get blue => 'Bleu';

  @override
  String get red => 'Rouge';

  @override
  String firstTo(int count) {
    return 'Premier à $count';
  }

  @override
  String get ready => 'Prêt';

  @override
  String get goal => 'But';

  @override
  String winner(String name) {
    return '$name gagne';
  }

  @override
  String get rematch => 'Rejouer';

  @override
  String get home => 'Accueil';

  @override
  String get pause => 'Pause';

  @override
  String get paused => 'En pause';

  @override
  String get resume => 'Reprendre';

  @override
  String get restart => 'Recommencer';

  @override
  String get language => 'Langue';

  @override
  String get music => 'Musique';

  @override
  String get vibration => 'Vibration';

  @override
  String get privacy => 'Confidentialité';

  @override
  String get about => 'À propos';

  @override
  String versionLabel(String version) {
    return 'Version $version';
  }

  @override
  String get deviceLanguage => 'Langue de l\'appareil';

  @override
  String get privacyError =>
      'La page de confidentialité ne s\'est pas ouverte. Réessaie.';

  @override
  String tapSide(String name, int score) {
    return '$name, $score. Glisse';
  }

  @override
  String get youWin => 'Tu gagnes';

  @override
  String get robotWins => 'Le robot gagne';

  @override
  String get onePlayer => '1 joueur';

  @override
  String get twoPlayers => '2 joueurs';

  @override
  String get difficulty => 'Difficulté';

  @override
  String get easy => 'Facile';

  @override
  String get normal => 'Normal';

  @override
  String get hard => 'Difficile';

  @override
  String get start => 'Commencer';

  @override
  String get adSlot => 'Pub';

  @override
  String get logoTop => 'HOCKEY';

  @override
  String get logoBottom => 'DUEL';

  @override
  String get workingTitle => '(titre provisoire)';

  @override
  String get onePlayerHint => 'Contre le bot';

  @override
  String get twoPlayersHint => 'Face à face, un téléphone';

  @override
  String get goalShout => 'BUT !';

  @override
  String scoredBy(String name) {
    return '$name marque !';
  }

  @override
  String botTag(String level) {
    return 'BOT · $level';
  }

  @override
  String get youTag => 'TOI';

  @override
  String get menu => 'Menu';

  @override
  String get playAgain => 'Rejouer';

  @override
  String get youWinShout => 'GAGNÉ !';

  @override
  String get closeOne => 'Presque !';

  @override
  String wonRematch(String name) {
    return '$name gagne · Revanche ?';
  }

  @override
  String get bot => 'Bot';
}
