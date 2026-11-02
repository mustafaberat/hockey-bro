// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Italian (`it`).
class AppLocalizationsIt extends AppLocalizations {
  AppLocalizationsIt([String locale = 'it']) : super(locale);

  @override
  String get appTitle => 'HockeyBro';

  @override
  String get tagline => 'Trascina la mazza. Spingi il disco.';

  @override
  String get play => 'Gioca';

  @override
  String get howToPlay => 'Come si gioca';

  @override
  String get settings => 'Impostazioni';

  @override
  String get howToLine =>
      'Trascina la mazza. Spingi il disco nell\'altra porta.';

  @override
  String get skip => 'Salta';

  @override
  String get close => 'Chiudi';

  @override
  String get blue => 'Blu';

  @override
  String get red => 'Rosso';

  @override
  String firstTo(int count) {
    return 'Primo a $count';
  }

  @override
  String get ready => 'Pronto';

  @override
  String get goal => 'Gol';

  @override
  String winner(String name) {
    return 'Vince $name';
  }

  @override
  String get rematch => 'Rivincita';

  @override
  String get home => 'Home';

  @override
  String get pause => 'Pausa';

  @override
  String get paused => 'In pausa';

  @override
  String get resume => 'Riprendi';

  @override
  String get restart => 'Ricomincia';

  @override
  String get language => 'Lingua';

  @override
  String get music => 'Musica';

  @override
  String get vibration => 'Vibrazione';

  @override
  String get privacy => 'Privacy';

  @override
  String get about => 'Info';

  @override
  String versionLabel(String version) {
    return 'Versione $version';
  }

  @override
  String get deviceLanguage => 'Lingua del dispositivo';

  @override
  String get privacyError => 'La pagina privacy non si è aperta. Riprova.';

  @override
  String tapSide(String name, int score) {
    return '$name, $score. Trascina';
  }

  @override
  String get youWin => 'Hai vinto';

  @override
  String get robotWins => 'Il robot vince';

  @override
  String get onePlayer => '1 giocatore';

  @override
  String get twoPlayers => '2 giocatori';

  @override
  String get difficulty => 'Difficoltà';

  @override
  String get easy => 'Facile';

  @override
  String get normal => 'Normale';

  @override
  String get hard => 'Difficile';

  @override
  String get start => 'Inizia';

  @override
  String get adSlot => 'Annuncio';

  @override
  String get logoTop => 'HOCKEY';

  @override
  String get logoBottom => 'BRO';

  @override
  String get slogan => 'Un telefono. Due fratelli. Un vincitore.';

  @override
  String get onePlayerHint => 'Contro il bot';

  @override
  String get twoPlayersHint => 'Faccia a faccia, un telefono';

  @override
  String get goalShout => 'GOL!';

  @override
  String scoredBy(String name) {
    return 'Segna $name!';
  }

  @override
  String botTag(String level) {
    return 'BOT · $level';
  }

  @override
  String get youTag => 'TU';

  @override
  String get menu => 'Menu';

  @override
  String get playAgain => 'Rigioca';

  @override
  String get youWinShout => 'HAI VINTO!';

  @override
  String get closeOne => 'Quasi!';

  @override
  String wonRematch(String name) {
    return 'Vince $name · Rivincita?';
  }

  @override
  String get bot => 'Bot';
}
