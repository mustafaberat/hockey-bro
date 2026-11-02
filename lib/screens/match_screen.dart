import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';

import '../analytics/analytics_events.dart';
import '../analytics/match_analytics.dart';
import '../app_scope.dart';
import '../components/comic.dart';
import '../engine/robot.dart';
import '../engine/table.dart';
import '../l10n/app_localizations.dart';
import '../theme/game_theme.dart';
import '../theme/table_painter.dart';
import 'match_overlays.dart';

class MatchScreen extends StatefulWidget {
  const MatchScreen({
    this.difficulty,
    @visibleForTesting this.initialState,
    @visibleForTesting this.startPaused = false,
    super.key,
  });

  /// Set when the top mallet is a robot. Null is a two-player match.
  final Difficulty? difficulty;
  final TableState? initialState;
  final bool startPaused;

  @override
  State<MatchScreen> createState() => _MatchScreenState();
}

/// Pings painters without rebuilding widgets.
class _Repaint extends ChangeNotifier {
  void ping() => notifyListeners();
}

class _MatchScreenState extends State<MatchScreen>
    with SingleTickerProviderStateMixin {
  // Per-frame data lives in notifiers. Only the painters listen to [_table];
  // widgets listen to the slow ones (score, phase, pause), so the frame loop
  // never rebuilds the screen.
  late final ValueNotifier<TableState> _table = ValueNotifier(
    widget.initialState ?? const TableState(),
  );
  late final ValueNotifier<RinkPhase> _phase = ValueNotifier(
    _table.value.phase,
  );
  late final ValueNotifier<(int, int)> _score = ValueNotifier((
    _table.value.blue,
    _table.value.red,
  ));
  late final ValueNotifier<bool> _paused = ValueNotifier(widget.startPaused);
  late final MatchAnalytics _analytics = MatchAnalytics(
    difficulty: widget.difficulty,
  );
  final _repaint = _Repaint();
  final _fx = RinkFx();
  final Map<int, Side> _pointers = {};
  Timer? _beat;
  late final Ticker _ticker;
  Duration _last = Duration.zero;
  double _frameDt = 1 / 60;
  var _reported = false;
  var _touching = false;
  var _goalId = 0;
  var _matchId = 0;
  Size _boardSize = Size.zero;

  bool get _vsBot => widget.difficulty != null;
  TableState get _state => _table.value;

  set _state(TableState next) {
    _table.value = next;
    _phase.value = next.phase;
    final score = (next.blue, next.red);
    if (_score.value != score) _score.value = score;
  }

  @override
  void initState() {
    super.initState();
    if (_state.phase == RinkPhase.goal) _goalId++;
    _ticker = createTicker(_onTick)..start();
    _analytics.matchStarted(trigger: AnalyticsValues.triggerNew);
    _armBeat();
  }

  @override
  void dispose() {
    _beat?.cancel();
    _ticker.dispose();
    _table.dispose();
    _phase.dispose();
    _score.dispose();
    _paused.dispose();
    _repaint.dispose();
    super.dispose();
  }

  void _onTick(Duration elapsed) {
    final raw = _last == Duration.zero
        ? 0.0
        : (elapsed - _last).inMicroseconds / 1e6;
    _last = elapsed;
    _frameDt = raw.clamp(0.0, 0.033).toDouble();
    _fx.now = elapsed.inMicroseconds / 1e6;
    if (!mounted) return;
    final hadFx = _fx.active;
    _fx.prune();
    if (_paused.value || _frameDt <= 0 || _state.phase != RinkPhase.live) {
      if (hadFx) _repaint.ping();
      return;
    }
    final robot = widget.difficulty;
    var frame = _state;
    if (robot != null) {
      final aim = robotAim(frame, robot, _frameDt);
      frame = placeMallet(frame, Side.blue, aim.$1, aim.$2, _frameDt);
    }
    final next = stepTable(frame, _frameDt);
    final hit = next.struck && !_touching;
    _touching = next.struck;
    if (hit) {
      _fx.add(RinkFxKind.hit, next.puckX, next.puckY, Colors.black);
      if (AppScope.read(context).settings.haptics) HapticFeedback.lightImpact();
    }
    _state = next;
    if (next.phase == RinkPhase.goal) {
      _goalId++;
      _analytics.goal(next);
      _pointers.clear();
      if (AppScope.read(context).settings.haptics) {
        HapticFeedback.mediumImpact();
      }
    }
    if (next.phase != RinkPhase.live) _armBeat();
  }

  void _armBeat() {
    _beat?.cancel();
    if (_paused.value) return;
    if (_state.phase == RinkPhase.faceoff) {
      _beat = Timer(TableRules.faceoff, () {
        if (!mounted || _paused.value) return;
        _state = dropPuck(_state);
      });
    } else if (_state.phase == RinkPhase.goal) {
      _beat = Timer(TableRules.goalHold, () {
        if (!mounted || _paused.value) return;
        _state = finishGoalBeat(_state);
        _afterPhase();
        _armBeat();
      });
    } else if (_state.phase == RinkPhase.over) {
      _afterPhase();
    }
  }

  void _afterPhase() {
    if (_state.phase == RinkPhase.over && !_reported) {
      _reported = true;
      _touching = false;
      _pointers.clear();
      AppScope.read(context).ads.onMatchFinished();
    }
  }

  Offset? _tablePoint(Offset local) {
    if (_boardSize.isEmpty) return null;
    final fit = TableFit(_boardSize);
    if (fit.scale == 0) return null;
    return Offset(
      (local.dx - fit.ox) / fit.scale,
      (local.dy - fit.oy) / fit.scale,
    );
  }

  bool get _blocked =>
      _paused.value ||
      _state.phase == RinkPhase.goal ||
      _state.phase == RinkPhase.over;

  void _down(PointerDownEvent event) {
    if (_blocked) return;
    final point = _tablePoint(event.localPosition);
    if (point == null) return;
    final side = point.dy < TableGeom.centerY ? Side.blue : Side.red;
    if (_vsBot && side == Side.blue) return;
    if (_pointers.containsValue(side)) return;
    _pointers[event.pointer] = side;
    _drag(side, point);
    final mallet = side == Side.blue
        ? (_state.blueX, _state.blueY)
        : (_state.redX, _state.redY);
    _fx.add(
      RinkFxKind.grab,
      mallet.$1,
      mallet.$2,
      GameThemeScope.of(context).side(side),
    );
    _repaint.ping();
  }

  void _move(PointerMoveEvent event) {
    final side = _pointers[event.pointer];
    if (side == null || _blocked) return;
    final point = _tablePoint(event.localPosition);
    if (point == null) return;
    _drag(side, point);
  }

  void _up(PointerEvent event) {
    final side = _pointers.remove(event.pointer);
    if (side == null) return;
    _state = side == Side.blue
        ? _state.copyWith(blueVx: 0, blueVy: 0)
        : _state.copyWith(redVx: 0, redVy: 0);
  }

  void _drag(Side side, Offset point) {
    _state = placeMallet(_state, side, point.dx, point.dy, _frameDt);
  }

  void _pause({String source = AnalyticsValues.sourceButton}) {
    if (_state.phase == RinkPhase.over || _paused.value) return;
    _analytics.paused(_state, source: source);
    _beat?.cancel();
    _pointers.clear();
    _paused.value = true;
  }

  void _resume() {
    _analytics.resumed();
    _paused.value = false;
    _last = Duration.zero;
    _armBeat();
  }

  void _restart({required String trigger}) {
    _pointers.clear();
    _fx.clear();
    _paused.value = false;
    _reported = false;
    _touching = false;
    _matchId++;
    _state = const TableState();
    _analytics.matchStarted(trigger: trigger);
    _armBeat();
  }

  void _restartFromPause() {
    _analytics.matchQuit(_state, from: AnalyticsValues.fromRestart);
    _restart(trigger: AnalyticsValues.triggerRestart);
  }

  void _rematch() {
    _analytics.endChoice(AnalyticsValues.choiceRematch);
    _restart(trigger: AnalyticsValues.triggerRematch);
  }

  Future<void> _home({required bool afterMatch}) async {
    final ads = AppScope.read(context).ads;
    if (afterMatch) {
      _analytics.endChoice(AnalyticsValues.choiceMenu);
    } else {
      _analytics.matchQuit(_state, from: AnalyticsValues.fromMenu);
    }
    Navigator.of(context).pop();
    if (afterMatch) await ads.maybeShowMatchEndInterstitial();
  }

  @override
  Widget build(BuildContext context) {
    final theme = GameThemeScope.of(context);
    final l10n = AppLocalizations.of(context);
    return ValueListenableBuilder<bool>(
      valueListenable: _paused,
      builder: (context, paused, child) => PopScope(
        canPop: paused || _state.phase == RinkPhase.over,
        onPopInvokedWithResult: (didPop, _) {
          if (!didPop) {
            _pause(source: AnalyticsValues.sourceBack);
          } else {
            // Back from the pause card. No-op if the menu button already
            // reported the quit or the match is over.
            _analytics.matchQuit(_state, from: AnalyticsValues.fromBack);
          }
        },
        child: child!,
      ),
      child: Scaffold(
        backgroundColor: theme.background,
        body: DottedBackground(
          child: SafeArea(
            child: LayoutBuilder(
              builder: (context, box) {
                _boardSize = box.biggest;
                final fit = TableFit(box.biggest);
                return Stack(
                  fit: StackFit.expand,
                  children: [
                    RepaintBoundary(
                      child: CustomPaint(
                        painter: RinkPainter(theme),
                        isComplex: true,
                        willChange: false,
                      ),
                    ),
                    Listener(
                      behavior: HitTestBehavior.opaque,
                      onPointerDown: _down,
                      onPointerMove: _move,
                      onPointerUp: _up,
                      onPointerCancel: _up,
                      child: Semantics(
                        label: l10n.howToLine,
                        child: RepaintBoundary(
                          child: CustomPaint(
                            painter: PiecesPainter(
                              table: _table,
                              theme: theme,
                              fx: _fx,
                              repaint: Listenable.merge([_table, _repaint]),
                            ),
                          ),
                        ),
                      ),
                    ),
                    ..._hud(context, fit, l10n),
                    ValueListenableBuilder<RinkPhase>(
                      valueListenable: _phase,
                      builder: (context, phase, _) {
                        if (phase != RinkPhase.goal) {
                          return const SizedBox.shrink();
                        }
                        final s = _state;
                        return GoalOverlay(
                          key: ValueKey('goal-$_matchId-$_goalId'),
                          scorer: s.lastScore ?? Side.red,
                          blue: s.blue,
                          red: s.red,
                          vsBot: _vsBot,
                          duration: TableRules.goalHold,
                        );
                      },
                    ),
                    ValueListenableBuilder<bool>(
                      valueListenable: _paused,
                      builder: (context, paused, _) {
                        if (!paused) return const SizedBox.shrink();
                        return PauseOverlay(
                          vsBot: _vsBot,
                          onResume: _resume,
                          onRestart: _restartFromPause,
                          onMenu: () => _home(afterMatch: false),
                        );
                      },
                    ),
                    ValueListenableBuilder<RinkPhase>(
                      valueListenable: _phase,
                      builder: (context, phase, _) {
                        if (phase != RinkPhase.over) {
                          return const SizedBox.shrink();
                        }
                        final s = _state;
                        return MatchEndOverlay(
                          key: ValueKey('end-$_matchId'),
                          winner: winnerOf(s) ?? Side.red,
                          blue: s.blue,
                          red: s.red,
                          vsBot: _vsBot,
                          onRematch: _rematch,
                          onShown: () => _analytics.matchEnded(_state),
                          onMenu: () => _home(afterMatch: true),
                        );
                      },
                    ),
                  ],
                );
              },
            ),
          ),
        ),
      ),
    );
  }

  List<Widget> _hud(BuildContext context, TableFit fit, AppLocalizations l10n) {
    final theme = GameThemeScope.of(context);
    final ice = fit.ice;
    final midY = fit.of(0, TableGeom.centerY).dy;
    final edge = (fit.scale * 0.012).clamp(3.0, 8.0);
    final level = switch (widget.difficulty) {
      Difficulty.easy => l10n.easy,
      Difficulty.normal => l10n.normal,
      Difficulty.hard => l10n.hard,
      null => '',
    };
    return [
      // Score pills and pause, on the right edge of the center line.
      Positioned(
        right: _boardSize.width - ice.right + edge,
        top: 0,
        bottom: 0,
        child: Center(
          child: ValueListenableBuilder<(int, int)>(
            valueListenable: _score,
            builder: (context, score, _) => Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                RotatedBox(
                  quarterTurns: _vsBot ? 0 : 2,
                  child: _ScorePill(value: score.$1, side: Side.blue),
                ),
                const SizedBox(height: 10),
                _PauseButton(onPressed: _pause, tooltip: l10n.pause),
                const SizedBox(height: 10),
                _ScorePill(value: score.$2, side: Side.red),
              ],
            ),
          ),
        ),
      ),
      // First-to-N pips on the left, one row per player.
      Positioned(
        left: ice.left + edge * 2,
        top: midY - 26,
        child: IgnorePointer(
          child: ValueListenableBuilder<(int, int)>(
            valueListenable: _score,
            builder: (context, score, _) => RotatedBox(
              quarterTurns: _vsBot ? 0 : 2,
              child: _Pips(
                filled: score.$1,
                total: _state.goalsToWin,
                color: theme.blue,
              ),
            ),
          ),
        ),
      ),
      Positioned(
        left: ice.left + edge * 2,
        top: midY + 14,
        child: IgnorePointer(
          child: ValueListenableBuilder<(int, int)>(
            valueListenable: _score,
            builder: (context, score, _) => _Pips(
              filled: score.$2,
              total: _state.goalsToWin,
              color: theme.red,
            ),
          ),
        ),
      ),
      if (_vsBot) ...[
        Positioned(
          left: ice.left + edge * 3,
          top: ice.top + fit.scale * 0.06,
          child: IgnorePointer(
            child: _Tag(
              text: l10n.botTag(level.toUpperCase()),
              color: theme.blueText,
            ),
          ),
        ),
        Positioned(
          left: ice.left + edge * 3,
          bottom: _boardSize.height - ice.bottom + fit.scale * 0.06,
          child: IgnorePointer(
            child: _Tag(text: l10n.youTag, color: theme.redText),
          ),
        ),
      ],
    ];
  }
}

class _ScorePill extends StatelessWidget {
  const _ScorePill({required this.value, required this.side});

  final int value;
  final Side side;

  @override
  Widget build(BuildContext context) {
    final theme = GameThemeScope.of(context);
    return TweenAnimationBuilder<double>(
      key: ValueKey(value),
      tween: Tween(begin: value == 0 ? 1 : 1.45, end: 1),
      duration: const Duration(milliseconds: 420),
      curve: Curves.elasticOut,
      builder: (context, scale, child) =>
          Transform.scale(scale: scale, child: child),
      child: Container(
        width: 38,
        height: 44,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: theme.surface,
          borderRadius: BorderRadius.circular(11),
          border: Border.all(color: theme.ink, width: theme.outline),
          boxShadow: [
            BoxShadow(
              color: theme.ink,
              offset: Offset(theme.shadow * 0.5, theme.shadow * 0.8),
            ),
          ],
        ),
        child: Text(
          '$value',
          style: theme.display(28, color: theme.sideText(side)),
        ),
      ),
    );
  }
}

class _PauseButton extends StatelessWidget {
  const _PauseButton({required this.onPressed, required this.tooltip});

  final VoidCallback onPressed;
  final String tooltip;

  @override
  Widget build(BuildContext context) {
    final theme = GameThemeScope.of(context);
    Widget bar() => Container(
      width: 5,
      height: 14,
      decoration: BoxDecoration(
        color: theme.ink,
        borderRadius: BorderRadius.circular(3),
      ),
    );
    return Semantics(
      button: true,
      label: tooltip,
      excludeSemantics: true,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onPressed,
        child: Padding(
          padding: const EdgeInsets.all(4),
          child: Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: theme.gold,
              shape: BoxShape.circle,
              border: Border.all(color: theme.ink, width: theme.outline),
              boxShadow: [
                BoxShadow(
                  color: theme.ink,
                  offset: Offset(theme.shadow * 0.5, theme.shadow * 0.8),
                ),
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [bar(), const SizedBox(width: 4), bar()],
            ),
          ),
        ),
      ),
    );
  }
}

class _Pips extends StatelessWidget {
  const _Pips({required this.filled, required this.total, required this.color});

  final int filled;
  final int total;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final theme = GameThemeScope.of(context);
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        for (var i = 0; i < total; i++)
          Container(
            width: 10,
            height: 10,
            margin: const EdgeInsets.only(right: 4),
            decoration: BoxDecoration(
              color: i < filled ? color : theme.surface,
              shape: BoxShape.circle,
              border: Border.all(color: theme.ink, width: 1.6),
            ),
          ),
      ],
    );
  }
}

class _Tag extends StatelessWidget {
  const _Tag({required this.text, required this.color});

  final String text;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final theme = GameThemeScope.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 2),
      decoration: BoxDecoration(
        color: theme.surface,
        borderRadius: BorderRadius.circular(99),
        border: Border.all(color: theme.ink, width: 2),
      ),
      child: Text(text, style: theme.display(12, color: color)),
    );
  }
}
