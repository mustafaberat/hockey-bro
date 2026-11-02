/// Event / parameter names and values (GA4 limits: names <= 40 chars,
/// <= 25 params per event, string values <= 100 chars).
///
/// Players: `p1` is the bottom (red) mallet, which is "you" against the bot;
/// `p2` is the top (blue) mallet, which is the bot in 1-player mode.
library;

class AnalyticsEvents {
  AnalyticsEvents._();

  static const appOpen = 'app_open';
  static const matchStart = 'match_start';
  static const goal = 'goal';
  static const matchEnd = 'match_end';
  static const matchQuit = 'match_quit';
  static const matchEndChoice = 'match_end_choice';
  static const pauseOpen = 'pause_open';
  static const settingsOpen = 'settings_open';
  static const howToPlayOpen = 'how_to_play_open';
  static const settingsChange = 'settings_change';
}

class AnalyticsParams {
  AnalyticsParams._();

  static const deviceId = 'device_id';
  static const openCount = 'open_count';
  static const matchNumber = 'match_number';
  static const trigger = 'trigger';
  static const winScore = 'win_score';
  static const mode = 'mode';
  static const difficulty = 'difficulty';
  static const scorer = 'scorer';
  static const winner = 'winner';
  static const scoreP1 = 'score_p1';
  static const scoreP2 = 'score_p2';
  static const score = 'score';
  static const goalsP1 = 'goals_p1';
  static const goalsP2 = 'goals_p2';
  static const durationS = 'duration_s';
  static const from = 'from';
  static const choice = 'choice';
  static const source = 'source';
  static const setting = 'setting';
  static const value = 'value';
}

class AnalyticsUserProps {
  AnalyticsUserProps._();

  static const deviceId = 'device_id';
}

class AnalyticsValues {
  AnalyticsValues._();

  // players
  static const p1 = 'p1';
  static const p2 = 'p2';
  static const none = 'none';

  // mode
  static const mode1p = '1p';
  static const mode2p = '2p';

  // match_start trigger
  static const triggerNew = 'new';
  static const triggerRematch = 'rematch';
  static const triggerRestart = 'restart';

  // match_quit from
  static const fromMenu = 'menu';
  static const fromRestart = 'restart';
  static const fromBack = 'back';

  // match_end_choice
  static const choiceRematch = 'rematch';
  static const choiceMenu = 'menu';

  // pause_open / how_to_play_open / settings_open source
  static const sourceButton = 'button';
  static const sourceBack = 'back';
  static const sourceHome = 'home';
  static const sourceSettings = 'settings';
  static const sourceFirstRun = 'first_run';

  // settings_change setting
  static const settingLanguage = 'language';
  static const settingMusic = 'music';
  static const settingHaptics = 'haptics';
  static const settingDifficulty = 'difficulty';
}

class AnalyticsLimits {
  AnalyticsLimits._();

  static const maxName = 40;
  static const maxParams = 25;
  static const maxStringValue = 100;
  static const maxUserPropertyValue = 36;
}
