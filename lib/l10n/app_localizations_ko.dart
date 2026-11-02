// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Korean (`ko`).
class AppLocalizationsKo extends AppLocalizations {
  AppLocalizationsKo([String locale = 'ko']) : super(locale);

  @override
  String get appTitle => 'Faceoff';

  @override
  String get tagline => '채를 끌어 퍽을 미세요.';

  @override
  String get play => '플레이';

  @override
  String get howToPlay => '플레이 방법';

  @override
  String get settings => '설정';

  @override
  String get howToLine => '채를 끌어 퍽을 상대 골로 미세요.';

  @override
  String get skip => '건너뛰기';

  @override
  String get close => '닫기';

  @override
  String get blue => '파랑';

  @override
  String get red => '빨강';

  @override
  String firstTo(int count) {
    return '먼저 $count';
  }

  @override
  String get ready => '준비';

  @override
  String get goal => '골';

  @override
  String winner(String name) {
    return '$name 승';
  }

  @override
  String get rematch => '다시';

  @override
  String get home => '홈';

  @override
  String get pause => '일시 정지';

  @override
  String get paused => '일시 정지됨';

  @override
  String get resume => '계속';

  @override
  String get restart => '다시 시작';

  @override
  String get language => '언어';

  @override
  String get music => '음악';

  @override
  String get vibration => '진동';

  @override
  String get privacy => '개인정보';

  @override
  String get about => '정보';

  @override
  String versionLabel(String version) {
    return '버전 $version';
  }

  @override
  String get deviceLanguage => '기기 언어';

  @override
  String get privacyError => '개인정보 페이지가 열리지 않았습니다. 다시 시도하세요.';

  @override
  String tapSide(String name, int score) {
    return '$name, $score. 끌기';
  }

  @override
  String get youWin => '당신이 이김';

  @override
  String get robotWins => '로봇이 이김';

  @override
  String get onePlayer => '1인';

  @override
  String get twoPlayers => '2인';

  @override
  String get difficulty => '난이도';

  @override
  String get easy => '쉬움';

  @override
  String get normal => '보통';

  @override
  String get hard => '어려움';

  @override
  String get start => '시작';

  @override
  String get adSlot => '광고';
}
