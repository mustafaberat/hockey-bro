// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Chinese (`zh`).
class AppLocalizationsZh extends AppLocalizations {
  AppLocalizationsZh([String locale = 'zh']) : super(locale);

  @override
  String get appTitle => 'Faceoff';

  @override
  String get tagline => '拖动球拍，把球推进去。';

  @override
  String get play => '开始';

  @override
  String get howToPlay => '怎么玩';

  @override
  String get settings => '设置';

  @override
  String get howToLine => '拖动球拍，把球推进对方球门。';

  @override
  String get skip => '跳过';

  @override
  String get close => '关闭';

  @override
  String get blue => '蓝';

  @override
  String get red => '红';

  @override
  String firstTo(int count) {
    return '先到 $count';
  }

  @override
  String get ready => '准备';

  @override
  String get goal => '进球';

  @override
  String winner(String name) {
    return '$name 赢了';
  }

  @override
  String get rematch => '再来';

  @override
  String get home => '主页';

  @override
  String get pause => '暂停';

  @override
  String get paused => '已暂停';

  @override
  String get resume => '继续';

  @override
  String get restart => '重来';

  @override
  String get language => '语言';

  @override
  String get music => '音乐';

  @override
  String get vibration => '振动';

  @override
  String get privacy => '隐私';

  @override
  String get about => '关于';

  @override
  String versionLabel(String version) {
    return '版本 $version';
  }

  @override
  String get deviceLanguage => '设备语言';

  @override
  String get privacyError => '隐私页面没有打开。请再试一次。';

  @override
  String tapSide(String name, int score) {
    return '$name，$score。拖动';
  }

  @override
  String get youWin => '你赢了';

  @override
  String get robotWins => '机器人赢了';

  @override
  String get onePlayer => '1 人';

  @override
  String get twoPlayers => '2 人';

  @override
  String get difficulty => '难度';

  @override
  String get easy => '容易';

  @override
  String get normal => '普通';

  @override
  String get hard => '困难';

  @override
  String get start => '开始';

  @override
  String get adSlot => '广告';

  @override
  String get logoTop => '冰球';

  @override
  String get logoBottom => '对决';

  @override
  String get workingTitle => '（暂定名）';

  @override
  String get onePlayerHint => '对战机器人';

  @override
  String get twoPlayersHint => '同一部手机，面对面';

  @override
  String get goalShout => '进球！';

  @override
  String scoredBy(String name) {
    return '$name得分！';
  }

  @override
  String botTag(String level) {
    return '机器人 · $level';
  }

  @override
  String get youTag => '你';

  @override
  String get menu => '菜单';

  @override
  String get playAgain => '再来一局';

  @override
  String get youWinShout => '你赢了！';

  @override
  String get closeOne => '差一点！';

  @override
  String wonRematch(String name) {
    return '$name获胜 · 再战？';
  }

  @override
  String get bot => '机器人';
}
