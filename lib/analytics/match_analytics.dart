/// Turns one MatchScreen's match lifecycle into analytics events.
///
/// Only match-level moments are reported: start, each goal, pause, the end
/// card, quitting and the end-card choice. Nothing per touch, per mallet move
/// or per physics frame, and no screen views or dwell time.
///
/// Players: p1 = bottom (red, "you" vs the bot), p2 = top (blue, the bot).
/// Every method is a few field reads; the send itself runs off the caller's
/// stack via [AnalyticsService.logEvent].
library;

import '../engine/robot.dart';
import '../engine/table.dart';
import 'analytics_events.dart';
import 'analytics_service.dart';

class MatchAnalytics {
  MatchAnalytics({
    required this.difficulty,
    this.service,
    Stopwatch? clock,
  }) : _clock = clock ?? Stopwatch();

  /// Null in a two-player match.
  final Difficulty? difficulty;
  /// Defaults to [AnalyticsService.instance]; tests pass their own.
  final AnalyticsService? service;
  final Stopwatch _clock;
  AnalyticsService get _a => service ?? AnalyticsService.instance;

  int _matchNumber = 0;
  bool _active = false;
  bool _ended = false;

  int get matchNumber => _matchNumber;
  bool get isRunning => _active && !_ended;

  String get _mode =>
      difficulty == null ? AnalyticsValues.mode2p : AnalyticsValues.mode1p;

  Map<String, Object?> get _modeParams => {
    AnalyticsParams.mode: _mode,
    AnalyticsParams.difficulty: difficulty?.name,
  };

  /// New match: first start, rematch from the end card, or restart from pause.
  void matchStarted({
    required String trigger,
    int winScore = TableRules.goalsToWin,
  }) {
    _matchNumber = _a.nextMatchNumber();
    _active = true;
    _ended = false;
    _clock
      ..reset()
      ..start();
    _a.logEvent(AnalyticsEvents.matchStart, {
      AnalyticsParams.matchNumber: _matchNumber,
      AnalyticsParams.trigger: trigger,
      AnalyticsParams.winScore: winScore,
      ..._modeParams,
    });
  }

  /// A goal just went in. [state] is the table right after it.
  void goal(TableState state) {
    if (!isRunning) return;
    final scorer = state.lastScore;
    _a.logEvent(AnalyticsEvents.goal, {
      AnalyticsParams.matchNumber: _matchNumber,
      AnalyticsParams.scorer: scorer == null
          ? AnalyticsValues.none
          : player(scorer),
      AnalyticsParams.scoreP1: state.red,
      AnalyticsParams.scoreP2: state.blue,
      ..._modeParams,
    });
  }

  /// The pause card opened. The match clock stops while paused.
  void paused(TableState state, {required String source}) {
    if (!isRunning) return;
    _clock.stop();
    _a.logEvent(AnalyticsEvents.pauseOpen, {
      AnalyticsParams.matchNumber: _matchNumber,
      AnalyticsParams.scoreP1: state.red,
      AnalyticsParams.scoreP2: state.blue,
      AnalyticsParams.source: source,
      ..._modeParams,
    });
  }

  void resumed() {
    if (isRunning) _clock.start();
  }

  /// The match-end card is on screen. Sent once per match.
  void matchEnded(TableState state) {
    if (!isRunning || state.phase != RinkPhase.over) return;
    _ended = true;
    _active = false;
    _clock.stop();
    final winner = winnerOf(state);
    _a.logEvent(AnalyticsEvents.matchEnd, {
      AnalyticsParams.matchNumber: _matchNumber,
      AnalyticsParams.winner: winner == null
          ? AnalyticsValues.none
          : player(winner),
      AnalyticsParams.score: '${state.red}-${state.blue}',
      AnalyticsParams.goalsP1: state.red,
      AnalyticsParams.goalsP2: state.blue,
      AnalyticsParams.durationS: _seconds,
      AnalyticsParams.winScore: state.goalsToWin,
      ..._modeParams,
    });
  }

  /// Left a running match (pause card menu / restart, or back while paused).
  void matchQuit(TableState state, {required String from}) {
    if (!isRunning) return;
    _active = false;
    _clock.stop();
    _a.logEvent(AnalyticsEvents.matchQuit, {
      AnalyticsParams.matchNumber: _matchNumber,
      AnalyticsParams.score: '${state.red}-${state.blue}',
      AnalyticsParams.scoreP1: state.red,
      AnalyticsParams.scoreP2: state.blue,
      AnalyticsParams.durationS: _seconds,
      AnalyticsParams.from: from,
      ..._modeParams,
    });
  }

  /// Button picked on the match-end card.
  void endChoice(String choice) {
    if (_matchNumber == 0) return;
    _a.logEvent(AnalyticsEvents.matchEndChoice, {
      AnalyticsParams.matchNumber: _matchNumber,
      AnalyticsParams.choice: choice,
      ..._modeParams,
    });
  }

  int get _seconds => (_clock.elapsedMilliseconds / 1000).round();

  static String player(Side side) =>
      side == Side.red ? AnalyticsValues.p1 : AnalyticsValues.p2;
}
