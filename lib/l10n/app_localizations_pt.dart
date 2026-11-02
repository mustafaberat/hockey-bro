// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Portuguese (`pt`).
class AppLocalizationsPt extends AppLocalizations {
  AppLocalizationsPt([String locale = 'pt']) : super(locale);

  @override
  String get appTitle => 'HockeyBro';

  @override
  String get tagline => 'Arraste o seu taco. Empurre o disco.';

  @override
  String get play => 'Jogar';

  @override
  String get howToPlay => 'Como jogar';

  @override
  String get settings => 'Ajustes';

  @override
  String get howToLine => 'Arraste o seu taco. Empurre o disco no outro gol.';

  @override
  String get skip => 'Pular';

  @override
  String get close => 'Fechar';

  @override
  String get blue => 'Azul';

  @override
  String get red => 'Vermelho';

  @override
  String firstTo(int count) {
    return 'Primeiro a $count';
  }

  @override
  String get ready => 'Pronto';

  @override
  String get goal => 'Gol';

  @override
  String winner(String name) {
    return '$name venceu';
  }

  @override
  String get rematch => 'De novo';

  @override
  String get home => 'Início';

  @override
  String get pause => 'Pausar';

  @override
  String get paused => 'Pausa';

  @override
  String get resume => 'Continuar';

  @override
  String get restart => 'Recomeçar';

  @override
  String get language => 'Idioma';

  @override
  String get music => 'Música';

  @override
  String get vibration => 'Vibração';

  @override
  String get privacy => 'Privacidade';

  @override
  String get about => 'Sobre';

  @override
  String versionLabel(String version) {
    return 'Versão $version';
  }

  @override
  String get deviceLanguage => 'Idioma do aparelho';

  @override
  String get privacyError =>
      'A página de privacidade não abriu. Tente de novo.';

  @override
  String tapSide(String name, int score) {
    return '$name, $score. Arraste';
  }

  @override
  String get youWin => 'Você venceu';

  @override
  String get robotWins => 'O robô venceu';

  @override
  String get onePlayer => '1 jogador';

  @override
  String get twoPlayers => '2 jogadores';

  @override
  String get difficulty => 'Dificuldade';

  @override
  String get easy => 'Fácil';

  @override
  String get normal => 'Normal';

  @override
  String get hard => 'Difícil';

  @override
  String get start => 'Começar';

  @override
  String get adSlot => 'Anúncio';

  @override
  String get logoTop => 'HOCKEY';

  @override
  String get logoBottom => 'BRO';

  @override
  String get slogan => 'Um telefone. Dois irmãos. Um vencedor.';

  @override
  String get onePlayerHint => 'Contra o bot';

  @override
  String get twoPlayersHint => 'Frente a frente, um celular';

  @override
  String get goalShout => 'GOL!';

  @override
  String scoredBy(String name) {
    return '$name marcou!';
  }

  @override
  String botTag(String level) {
    return 'BOT · $level';
  }

  @override
  String get youTag => 'VOCÊ';

  @override
  String get menu => 'Menu';

  @override
  String get playAgain => 'Jogar de novo';

  @override
  String get youWinShout => 'VOCÊ VENCEU!';

  @override
  String get closeOne => 'Quase!';

  @override
  String wonRematch(String name) {
    return '$name venceu · Revanche?';
  }

  @override
  String get bot => 'Bot';
}
