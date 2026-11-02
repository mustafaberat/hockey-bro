import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';

import '../app_scope.dart';
import '../config/tokens.dart';
import '../engine/robot.dart';
import '../engine/table.dart';
import '../l10n/app_localizations.dart';
import '../theme/table_painter.dart';

class MatchScreen extends StatefulWidget {
  const MatchScreen({this.difficulty, super.key});

  /// Set when the top mallet is a robot. Null is a two-player match.
  final Difficulty? difficulty;

  @override
  State<MatchScreen> createState() => _MatchScreenState();
}

class _MatchScreenState extends State<MatchScreen> with SingleTickerProviderStateMixin {
  TableState _state = const TableState();
  final Map<int, Side> _pointers = {};
  Timer? _beat;
  late final Ticker _ticker;
  Duration _last = Duration.zero;
  double _frameDt = 1 / 60;
  var _paused = false;
  var _reported = false;
  final _boardKey = GlobalKey();
  var _touching = false;

  @override
  void initState() {
    super.initState();
    _ticker = createTicker(_onTick)..start();
    _armBeat();
  }

  @override
  void dispose() {
    _beat?.cancel();
    _ticker.dispose();
    super.dispose();
  }

  void _onTick(Duration elapsed) {
    final raw = _last == Duration.zero ? 0.0 : (elapsed - _last).inMicroseconds / 1e6;
    _last = elapsed;
    _frameDt = raw.clamp(0.0, 0.033).toDouble();
    if (!mounted || _paused || _frameDt <= 0 || _state.phase != RinkPhase.live) return;
    final robot = widget.difficulty;
    var frame = _state;
    if (robot != null) {
      final aim = robotAim(frame, robot, _frameDt);
      frame = placeMallet(frame, Side.blue, aim.$1, aim.$2, _frameDt);
    }
    final next = stepTable(frame, _frameDt);
    final hit = next.struck && !_touching;
    _touching = next.struck;
    if (hit && AppScope.read(context).settings.haptics) {
      HapticFeedback.lightImpact();
    }
    setState(() => _state = next);
    if (next.phase != RinkPhase.live) _armBeat();
  }

  void _armBeat() {
    _beat?.cancel();
    if (_paused) return;
    if (_state.phase == RinkPhase.faceoff) {
      _beat = Timer(TableRules.faceoff, () {
        if (!mounted || _paused) return;
        setState(() => _state = dropPuck(_state));
      });
    } else if (_state.phase == RinkPhase.goal) {
      _beat = Timer(TableRules.goalHold, () {
        if (!mounted || _paused) return;
        setState(() => _state = finishGoalBeat(_state));
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
      AppScope.read(context).ads.onMatchFinished();
    }
  }

  Offset? _tablePoint(Offset local) {
    final box = _boardKey.currentContext?.findRenderObject() as RenderBox?;
    if (box == null || !box.hasSize) return null;
    final fit = TableFit(box.size);
    if (fit.scale == 0) return null;
    return Offset((local.dx - fit.ox) / fit.scale, (local.dy - fit.oy) / fit.scale);
  }

  void _down(PointerDownEvent event) {
    if (_paused || _state.phase == RinkPhase.goal || _state.phase == RinkPhase.over) return;
    final point = _tablePoint(event.localPosition);
    if (point == null) return;
    final side = point.dy < TableGeom.centerY ? Side.blue : Side.red;
    if (widget.difficulty != null && side == Side.blue) return;
    if (_pointers.containsValue(side)) return;
    _pointers[event.pointer] = side;
    _drag(side, point);
  }

  void _move(PointerMoveEvent event) {
    final side = _pointers[event.pointer];
    if (side == null) return;
    final point = _tablePoint(event.localPosition);
    if (point == null) return;
    _drag(side, point);
  }

  void _up(PointerEvent event) {
    final side = _pointers.remove(event.pointer);
    if (side == null) return;
    setState(() {
      _state = side == Side.blue
          ? _state.copyWith(blueVx: 0, blueVy: 0)
          : _state.copyWith(redVx: 0, redVy: 0);
    });
  }

  void _drag(Side side, Offset point) {
    setState(() => _state = placeMallet(_state, side, point.dx, point.dy, _frameDt));
  }

  void _pause() {
    if (_state.phase == RinkPhase.over) return;
    _beat?.cancel();
    setState(() => _paused = true);
  }

  void _resume() {
    setState(() => _paused = false);
    _armBeat();
  }

  void _restart() {
    _pointers.clear();
    setState(() {
      _state = const TableState();
      _paused = false;
      _reported = false;
      _touching = false;
    });
    _armBeat();
  }

  Future<void> _home({required bool afterMatch}) async {
    final ads = AppScope.read(context).ads;
    Navigator.of(context).pop();
    if (afterMatch) await ads.maybeShowMatchEndInterstitial();
  }

  String _winnerTitle(AppLocalizations l10n) {
    final winner = winnerOf(_state) ?? Side.blue;
    if (widget.difficulty != null) {
      return winner == Side.red ? l10n.youWin : l10n.robotWins;
    }
    return l10n.winner(winner == Side.blue ? l10n.blue : l10n.red);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final beat = switch (_state.phase) {
      RinkPhase.faceoff => l10n.ready,
      RinkPhase.goal => l10n.goal,
      _ => null,
    };
    return Scaffold(
      backgroundColor: AppColors.rail,
      body: SafeArea(
        child: Stack(
          children: [
            Positioned.fill(
              child: Listener(
                behavior: HitTestBehavior.opaque,
                onPointerDown: _down,
                onPointerMove: _move,
                onPointerUp: _up,
                onPointerCancel: _up,
                child: Semantics(
                  label: '${l10n.tapSide(l10n.blue, _state.blue)} ${l10n.tapSide(l10n.red, _state.red)}',
                  child: CustomPaint(
                    key: _boardKey,
                    painter: TablePainter(_state),
                    child: const SizedBox.expand(),
                  ),
                ),
              ),
            ),
            Positioned.fill(
              child: IgnorePointer(
                child: CustomPaint(
                  painter: _ScorePainter(
                    blue: '${_state.blue}',
                    red: '${_state.red}',
                    beat: beat,
                  ),
                ),
              ),
            ),
            Positioned(
              right: 4,
              top: 0,
              bottom: 0,
              child: Center(
                child: IconButton(
                  onPressed: _state.phase == RinkPhase.over ? null : _pause,
                  icon: const Icon(Icons.pause, color: AppColors.blueInk),
                  tooltip: l10n.pause,
                ),
              ),
            ),
            if (_paused)
              _Sheet(
                title: l10n.paused,
                primary: l10n.resume,
                onPrimary: _resume,
                secondary: l10n.restart,
                onSecondary: _restart,
                tertiary: l10n.home,
                onTertiary: () => _home(afterMatch: false),
              ),
            if (_state.phase == RinkPhase.over)
              _Sheet(
                title: _winnerTitle(l10n),
                detail: '${_state.blue} – ${_state.red}',
                primary: l10n.rematch,
                onPrimary: _restart,
                secondary: l10n.home,
                onSecondary: () => _home(afterMatch: true),
              ),
          ],
        ),
      ),
    );
  }
}

class _ScorePainter extends CustomPainter {
  _ScorePainter({required this.blue, required this.red, required this.beat});

  final String blue;
  final String red;
  final String? beat;

  @override
  void paint(Canvas canvas, Size size) {
    final fit = TableFit(size);
    _corner(canvas, fit, blue, 0.065, 0.065, AppColors.blueInk, turn: true);
    _corner(canvas, fit, red, 0.065, TableGeom.height - 0.065, AppColors.redInk, turn: false);
    if (beat == null) return;
    final painter = TextPainter(
      text: TextSpan(
        text: beat,
        style: const TextStyle(color: AppColors.ink, fontSize: 28, fontWeight: FontWeight.w700),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    final center = fit.of(TableGeom.centerX, TableGeom.centerY);
    painter.paint(canvas, center - Offset(painter.width / 2, painter.height / 2));
  }

  void _corner(
    Canvas canvas,
    TableFit fit,
    String text,
    double x,
    double y,
    Color color, {
    required bool turn,
  }) {
    final painter = TextPainter(
      text: TextSpan(
        text: text,
        style: TextStyle(color: color, fontSize: 18, fontWeight: FontWeight.w700),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    final at = fit.of(x, y);
    canvas.save();
    canvas.translate(at.dx, at.dy);
    if (turn) canvas.rotate(mathPi);
    painter.paint(canvas, Offset(-painter.width / 2, -painter.height / 2));
    canvas.restore();
  }

  static const mathPi = 3.141592653589793;

  @override
  bool shouldRepaint(_ScorePainter oldDelegate) =>
      oldDelegate.blue != blue || oldDelegate.red != red || oldDelegate.beat != beat;
}

class _Sheet extends StatelessWidget {
  const _Sheet({
    required this.title,
    required this.primary,
    required this.onPrimary,
    required this.secondary,
    required this.onSecondary,
    this.detail,
    this.tertiary,
    this.onTertiary,
  });

  final String title;
  final String? detail;
  final String primary;
  final VoidCallback onPrimary;
  final String secondary;
  final VoidCallback onSecondary;
  final String? tertiary;
  final VoidCallback? onTertiary;

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: const Color(0xCC141414),
      child: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                title,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  color: AppColors.white,
                  fontWeight: FontWeight.w700,
                ),
              ),
              if (detail != null) ...[
                const SizedBox(height: 8),
                Text(detail!, style: const TextStyle(color: AppColors.white)),
              ],
              const SizedBox(height: 20),
              FilledButton(onPressed: onPrimary, child: Text(primary)),
              TextButton(onPressed: onSecondary, child: Text(secondary)),
              if (tertiary != null) TextButton(onPressed: onTertiary, child: Text(tertiary!)),
            ],
          ),
        ),
      ),
    );
  }
}
