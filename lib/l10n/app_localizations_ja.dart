// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Japanese (`ja`).
class AppLocalizationsJa extends AppLocalizations {
  AppLocalizationsJa([String locale = 'ja']) : super(locale);

  @override
  String get appTitle => 'HockeyBro';

  @override
  String get tagline => 'マレットをドラッグ。パックを押せ。';

  @override
  String get play => 'プレイ';

  @override
  String get howToPlay => '遊び方';

  @override
  String get settings => '設定';

  @override
  String get howToLine => 'マレットをドラッグ。パックを相手のゴールへ。';

  @override
  String get skip => 'スキップ';

  @override
  String get close => '閉じる';

  @override
  String get blue => '青';

  @override
  String get red => '赤';

  @override
  String firstTo(int count) {
    return '先に $count';
  }

  @override
  String get ready => '準備';

  @override
  String get goal => 'ゴール';

  @override
  String winner(String name) {
    return '$name の勝ち';
  }

  @override
  String get rematch => 'もう一回';

  @override
  String get home => 'ホーム';

  @override
  String get pause => '停止';

  @override
  String get paused => '停止中';

  @override
  String get resume => '再開';

  @override
  String get restart => '最初から';

  @override
  String get language => '言語';

  @override
  String get music => '音楽';

  @override
  String get vibration => '振動';

  @override
  String get privacy => 'プライバシー';

  @override
  String get about => '情報';

  @override
  String versionLabel(String version) {
    return 'バージョン $version';
  }

  @override
  String get deviceLanguage => '端末の言語';

  @override
  String get privacyError => 'プライバシーページを開けませんでした。もう一度試してください。';

  @override
  String tapSide(String name, int score) {
    return '$name、$score。ドラッグ';
  }

  @override
  String get youWin => 'あなたの勝ち';

  @override
  String get robotWins => 'ロボットの勝ち';

  @override
  String get onePlayer => '1人';

  @override
  String get twoPlayers => '2人';

  @override
  String get difficulty => '難易度';

  @override
  String get easy => '易しい';

  @override
  String get normal => '普通';

  @override
  String get hard => '難しい';

  @override
  String get start => 'スタート';

  @override
  String get adSlot => '広告';

  @override
  String get logoTop => 'HOCKEY';

  @override
  String get logoBottom => 'BRO';

  @override
  String get slogan => 'スマホ1台。兄弟2人。勝者は1人。';

  @override
  String get onePlayerHint => 'ボットと対戦';

  @override
  String get twoPlayersHint => '1台で向かい合って';

  @override
  String get goalShout => 'ゴール！';

  @override
  String scoredBy(String name) {
    return '$nameの得点！';
  }

  @override
  String botTag(String level) {
    return 'ボット · $level';
  }

  @override
  String get youTag => 'あなた';

  @override
  String get menu => 'メニュー';

  @override
  String get playAgain => 'もう一回';

  @override
  String get youWinShout => '勝ち！';

  @override
  String get closeOne => 'おしい！';

  @override
  String wonRematch(String name) {
    return '$nameの勝ち · リベンジ？';
  }

  @override
  String get bot => 'ボット';
}
