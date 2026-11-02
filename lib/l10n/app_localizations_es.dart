// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Spanish Castilian (`es`).
class AppLocalizationsEs extends AppLocalizations {
  AppLocalizationsEs([String locale = 'es']) : super(locale);

  @override
  String get appTitle => 'HockeyBro';

  @override
  String get tagline => 'Arrastra tu mazo. Empuja el disco.';

  @override
  String get play => 'Jugar';

  @override
  String get howToPlay => 'Cómo jugar';

  @override
  String get settings => 'Ajustes';

  @override
  String get howToLine => 'Arrastra tu mazo. Empuja el disco al otro arco.';

  @override
  String get skip => 'Saltar';

  @override
  String get close => 'Cerrar';

  @override
  String get blue => 'Azul';

  @override
  String get red => 'Rojo';

  @override
  String firstTo(int count) {
    return 'Primero en $count';
  }

  @override
  String get ready => 'Listo';

  @override
  String get goal => 'Gol';

  @override
  String winner(String name) {
    return 'Gana $name';
  }

  @override
  String get rematch => 'Otra vez';

  @override
  String get home => 'Inicio';

  @override
  String get pause => 'Pausar';

  @override
  String get paused => 'Pausa';

  @override
  String get resume => 'Seguir';

  @override
  String get restart => 'Reiniciar';

  @override
  String get language => 'Idioma';

  @override
  String get music => 'Música';

  @override
  String get vibration => 'Vibración';

  @override
  String get privacy => 'Privacidad';

  @override
  String get about => 'Info';

  @override
  String versionLabel(String version) {
    return 'Versión $version';
  }

  @override
  String get deviceLanguage => 'Idioma del dispositivo';

  @override
  String get privacyError =>
      'La página de privacidad no se abrió. Inténtalo de nuevo.';

  @override
  String tapSide(String name, int score) {
    return '$name, $score. Arrastra';
  }

  @override
  String get youWin => 'Ganaste';

  @override
  String get robotWins => 'Gana el robot';

  @override
  String get onePlayer => '1 jugador';

  @override
  String get twoPlayers => '2 jugadores';

  @override
  String get difficulty => 'Dificultad';

  @override
  String get easy => 'Fácil';

  @override
  String get normal => 'Normal';

  @override
  String get hard => 'Difícil';

  @override
  String get start => 'Empezar';

  @override
  String get adSlot => 'Anuncio';

  @override
  String get logoTop => 'HOCKEY';

  @override
  String get logoBottom => 'BRO';

  @override
  String get slogan => 'Un teléfono. Dos hermanos. Un ganador.';

  @override
  String get onePlayerHint => 'Contra el bot';

  @override
  String get twoPlayersHint => 'Cara a cara, un teléfono';

  @override
  String get goalShout => '¡GOL!';

  @override
  String scoredBy(String name) {
    return '¡Marca $name!';
  }

  @override
  String botTag(String level) {
    return 'BOT · $level';
  }

  @override
  String get youTag => 'TÚ';

  @override
  String get menu => 'Menú';

  @override
  String get playAgain => 'Otra vez';

  @override
  String get youWinShout => '¡GANASTE!';

  @override
  String get closeOne => '¡Casi!';

  @override
  String wonRematch(String name) {
    return 'Ganó $name · ¿Revancha?';
  }

  @override
  String get bot => 'Bot';
}
