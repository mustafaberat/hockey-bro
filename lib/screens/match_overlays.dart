/// Overlays on top of the rink: goal moment, pause and match end. Each one
/// is mirrored for the top player in a two-player match.
library;

import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../components/comic.dart';
import '../components/confetti.dart';
import '../engine/table.dart';
import '../l10n/app_localizations.dart';
import '../theme/game_theme.dart';
import '../theme/table_painter.dart';

/// Two stacked halves. The [top] half is turned 180° so the top player
/// reads it the right way up.
class MirroredHalves extends StatelessWidget {
  const MirroredHalves({
    required this.bottom,
    this.top,
    this.padding = 14,
    super.key,
  });

  final Widget? top;
  final Widget bottom;
  final double padding;

  @override
  Widget build(BuildContext context) {
    Widget half(Widget? child) => Expanded(
      child: child == null
          ? const SizedBox.expand()
          : Padding(
              padding: EdgeInsets.all(padding),
              child: Center(child: child),
            ),
    );
    return Column(
      children: [
        half(
          top == null
              ? null
              : RotatedBox(quarterTurns: 2, child: Center(child: top)),
        ),
        half(bottom),
      ],
    );
  }
}

String sideName(AppLocalizations l10n, Side side, {required bool vsBot}) {
  if (vsBot && side == Side.blue) return l10n.bot;
  return side == Side.blue ? l10n.blue : l10n.red;
}

/// "GOL!" burst with confetti. Stays until [onBringPuck] is tapped.
/// A winning goal passes a null callback and the match screen moves on.
class GoalOverlay extends StatefulWidget {
  const GoalOverlay({
    required this.scorer,
    required this.blue,
    required this.red,
    required this.vsBot,
    required this.bringLabel,
    required this.onBringPuck,
    super.key,
  });

  final Side scorer;
  final int blue;
  final int red;
  final bool vsBot;
  final String bringLabel;
  final VoidCallback? onBringPuck;

  @override
  State<GoalOverlay> createState() => _GoalOverlayState();
}

class _GoalOverlayState extends State<GoalOverlay>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 500),
  )..forward();
  late final CurvedAnimation _pop = CurvedAnimation(
    parent: _c,
    curve: Curves.elasticOut,
  );
  late final CurvedAnimation _spot = CurvedAnimation(
    parent: _c,
    curve: Curves.easeOutBack,
  );

  @override
  void dispose() {
    _spot.dispose();
    _pop.dispose();
    _c.dispose();
    super.dispose();
  }

  Widget _banner(BuildContext context, Side reader) {
    final theme = GameThemeScope.of(context);
    final l10n = AppLocalizations.of(context);
    final mine = reader == Side.blue ? widget.blue : widget.red;
    final theirs = reader == Side.blue ? widget.red : widget.blue;
    return LayoutBuilder(
      builder: (context, box) {
        final w = box.maxWidth.clamp(200.0, 340.0);
        final h = (w * 0.42).clamp(0.0, box.maxHeight - 40);
        return ScaleTransition(
          scale: _pop,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(
                width: w,
                height: h,
                child: CustomPaint(
                  painter: StarBurstPainter(
                    fill: theme.card,
                    ink: theme.ink,
                    outline: theme.outline,
                  ),
                  child: Center(
                    child: FittedBox(
                      child: OutlinedText(
                        l10n.goalShout,
                        size: w * 0.22,
                        color: theme.gold,
                      ),
                    ),
                  ),
                ),
              ),
              Transform.translate(
                offset: Offset(0, -h * 0.12),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 5,
                  ),
                  decoration: BoxDecoration(
                    color: theme.side(widget.scorer),
                    borderRadius: BorderRadius.circular(99),
                    border: Border.all(color: theme.ink, width: theme.outline),
                    boxShadow: [
                      BoxShadow(
                        color: theme.ink,
                        offset: Offset(0, theme.shadow * 0.8),
                      ),
                    ],
                  ),
                  child: Text.rich(
                    TextSpan(
                      children: [
                        TextSpan(
                          text: l10n.scoredBy(
                            sideName(l10n, widget.scorer, vsBot: widget.vsBot),
                          ),
                        ),
                        TextSpan(
                          text: '  $mine',
                          style: TextStyle(color: theme.gold),
                        ),
                        const TextSpan(text: ' – '),
                        TextSpan(text: '$theirs'),
                      ],
                    ),
                    style: theme
                        .display(16, color: Colors.white)
                        .copyWith(
                          shadows: [
                            Shadow(
                              color: theme.ink,
                              offset: const Offset(0, 1.5),
                            ),
                          ],
                        ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = GameThemeScope.of(context);
    return RepaintBoundary(
      child: Stack(
        fit: StackFit.expand,
        children: [
          ColoredBox(color: theme.dim.withValues(alpha: 0.18)),
          IgnorePointer(
            child: CustomPaint(
              painter: ConfettiPainter(
                progress: _c,
                colors: theme.confetti,
                ink: theme.ink,
                seed: widget.blue * 31 + widget.red,
              ),
            ),
          ),
          MirroredHalves(
            top: widget.vsBot ? null : _banner(context, Side.blue),
            bottom: _banner(context, Side.red),
          ),
          if (widget.onBringPuck != null)
            Center(
              child: _BringPuckButton(
                label: widget.bringLabel,
                scale: _spot,
                onPressed: widget.onBringPuck!,
              ),
            ),
        ],
      ),
    );
  }
}

/// Round button between the two goal shouts. A dashed ring spins and blinks
/// so either player can see that the puck is the thing to tap.
class _BringPuckButton extends StatefulWidget {
  const _BringPuckButton({
    required this.label,
    required this.scale,
    required this.onPressed,
  });

  final String label;
  final Animation<double> scale;
  final VoidCallback onPressed;

  @override
  State<_BringPuckButton> createState() => _BringPuckButtonState();
}

class _BringPuckButtonState extends State<_BringPuckButton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _spin = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 900),
  )..repeat();

  @override
  void dispose() {
    _spin.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = GameThemeScope.of(context);
    const size = 92.0;
    final shadow = theme.shadow;
    return ScaleTransition(
      scale: widget.scale,
      child: Semantics(
        button: true,
        label: widget.label,
        child: GestureDetector(
          onTap: widget.onPressed,
          behavior: HitTestBehavior.opaque,
          child: SizedBox(
            width: size,
            height: size + shadow,
            child: Padding(
              padding: EdgeInsets.only(bottom: shadow),
              child: DecoratedBox(
                decoration: BoxDecoration(
                  color: theme.card,
                  shape: BoxShape.circle,
                  border: Border.all(color: theme.ink, width: theme.outline),
                  boxShadow: [
                    BoxShadow(color: theme.ink, offset: Offset(0, shadow)),
                  ],
                ),
                child: CustomPaint(
                  painter: _PuckIconPainter(theme, _spin),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _PuckIconPainter extends CustomPainter {
  _PuckIconPainter(this.theme, this.spin) : super(repaint: spin);

  final GameTheme theme;
  final Animation<double> spin;

  @override
  void paint(Canvas canvas, Size size) {
    final c = size.center(Offset.zero);
    final t = spin.value;
    final blink = t < 0.55 ? 1.0 : 0.28;
    final ring = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.5
      ..strokeCap = StrokeCap.round
      ..color = theme.ink.withValues(alpha: blink);
    final radius = size.shortestSide * 0.4;
    final rect = Rect.fromCircle(center: c, radius: radius);
    const dashes = 10;
    const sweep = math.pi * 2 / dashes * 0.55;
    final turn = t * math.pi * 2;
    for (var i = 0; i < dashes; i++) {
      canvas.drawArc(rect, turn + i * math.pi * 2 / dashes, sweep, false, ring);
    }
    paintPuck(canvas, c, size.shortestSide * 0.24, theme);
  }

  @override
  bool shouldRepaint(_PuckIconPainter oldDelegate) => oldDelegate.theme != theme;
}

/// Puck falling onto the center spot: large and high, then small as it lands.
/// The shadow stays on the ice and darkens as the puck arrives.
class FallingPuckPainter extends CustomPainter {
  FallingPuckPainter({
    required this.t,
    required this.theme,
    required Listenable repaint,
  }) : super(repaint: repaint);

  final double Function() t;
  final GameTheme theme;

  @override
  void paint(Canvas canvas, Size size) {
    final fit = TableFit(size);
    if (fit.scale <= 0) return;
    final fall = Curves.easeIn.transform(t().clamp(0.0, 1.0));
    final land = fit.of(TableGeom.centerX, TableGeom.centerY);
    final start = fit.of(TableGeom.centerX, TableGeom.rail + TableGeom.puckR);
    final puck = Offset.lerp(start, land, fall)!;
    final puckR = fit.scale * TableGeom.puckR;
    final radius = puckR * (2.7 - 1.7 * fall);
    final shadowW = puckR * (0.45 + fall);
    final shadowH = shadowW * 0.38;
    canvas.drawOval(
      Rect.fromCenter(
        center: land + Offset(0, puckR * 0.55),
        width: shadowW * 2,
        height: shadowH * 2,
      ),
      Paint()..color = theme.ink.withValues(alpha: 0.12 + 0.5 * fall),
    );
    paintPuck(canvas, puck, radius, theme);
  }

  @override
  bool shouldRepaint(FallingPuckPainter oldDelegate) =>
      oldDelegate.theme != theme;
}

class PauseOverlay extends StatelessWidget {
  const PauseOverlay({
    required this.vsBot,
    required this.onResume,
    required this.onRestart,
    required this.onMenu,
    super.key,
  });

  final bool vsBot;
  final VoidCallback onResume;
  final VoidCallback onRestart;
  final VoidCallback onMenu;

  Widget _card(BuildContext context) {
    final theme = GameThemeScope.of(context);
    final l10n = AppLocalizations.of(context);
    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 360),
      child: ComicCard(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            FittedBox(
              fit: BoxFit.scaleDown,
              child: OutlinedText(l10n.paused, size: 32, color: theme.gold),
            ),
            const SizedBox(height: 12),
            ComicButton(
              label: l10n.resume,
              icon: Icons.play_arrow_rounded,
              color: theme.primary,
              onPressed: onResume,
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: ComicButton(
                    label: l10n.restart,
                    icon: Icons.refresh_rounded,
                    height: 40,
                    fontSize: 15,
                    onPressed: onRestart,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: ComicButton(
                    label: l10n.menu,
                    icon: Icons.home_rounded,
                    height: 40,
                    fontSize: 15,
                    onPressed: onMenu,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = GameThemeScope.of(context);
    return Stack(
      fit: StackFit.expand,
      children: [
        ModalBarrier(color: theme.dim, dismissible: false),
        MirroredHalves(
          top: vsBot ? null : _card(context),
          bottom: _card(context),
        ),
      ],
    );
  }
}

/// Winner and loser halves. Buttons stay locked for [lock] so a tap that was
/// meant for the puck does not skip the result.
class MatchEndOverlay extends StatefulWidget {
  const MatchEndOverlay({
    required this.winner,
    required this.blue,
    required this.red,
    required this.vsBot,
    required this.onRematch,
    this.onShown,
    required this.onMenu,
    this.lock = const Duration(milliseconds: 800),
    super.key,
  });

  final Side winner;
  final int blue;
  final int red;
  final bool vsBot;
  final VoidCallback onRematch;

  /// Called once, after the card's first frame is on screen.
  final VoidCallback? onShown;
  final VoidCallback onMenu;
  final Duration lock;

  @override
  State<MatchEndOverlay> createState() => _MatchEndOverlayState();
}

class _MatchEndOverlayState extends State<MatchEndOverlay>
    with SingleTickerProviderStateMixin {
  Timer? _unlock;
  var _open = false;
  late final AnimationController _c = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 2400),
  )..forward();
  late final CurvedAnimation _in = CurvedAnimation(
    parent: _c,
    curve: const Interval(0, 0.2, curve: Curves.easeOutBack),
  );

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) widget.onShown?.call();
    });
    _unlock = Timer(widget.lock, () {
      if (mounted) setState(() => _open = true);
    });
  }

  @override
  void dispose() {
    _unlock?.cancel();
    _in.dispose();
    _c.dispose();
    super.dispose();
  }

  Widget _card(BuildContext context, Side reader) {
    final theme = GameThemeScope.of(context);
    final l10n = AppLocalizations.of(context);
    final won = reader == widget.winner;
    final mine = reader == Side.blue ? widget.blue : widget.red;
    final theirs = reader == Side.blue ? widget.red : widget.blue;
    final other = reader == Side.blue ? Side.red : Side.blue;
    final color = theme.side(reader);
    final title = won ? l10n.youWinShout : l10n.closeOne;
    final scoreStyle = theme.display(38, shadow: true);
    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 360),
      child: ScaleTransition(
        scale: _in,
        child: ComicCard(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 14),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (won)
                Icon(
                  Icons.emoji_events_rounded,
                  size: 44,
                  color: theme.gold,
                  shadows: [
                    Shadow(color: theme.ink, offset: const Offset(2, 3)),
                  ],
                ),
              FittedBox(
                fit: BoxFit.scaleDown,
                child: OutlinedText(title, size: 32, color: color),
              ),
              if (!won) ...[
                const SizedBox(height: 4),
                Text(
                  l10n.wonRematch(
                    sideName(l10n, widget.winner, vsBot: widget.vsBot),
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: theme.body(13, color: theme.subtle),
                ),
              ],
              const SizedBox(height: 2),
              Text.rich(
                TextSpan(
                  children: [
                    TextSpan(
                      text: '$mine',
                      style: TextStyle(color: color),
                    ),
                    const TextSpan(text: ' – '),
                    TextSpan(
                      text: '$theirs',
                      style: TextStyle(color: theme.side(other)),
                    ),
                  ],
                ),
                textAlign: TextAlign.center,
                style: scoreStyle,
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                    flex: 3,
                    child: ComicButton(
                      label: l10n.playAgain,
                      icon: Icons.replay_rounded,
                      color: color,
                      height: 44,
                      fontSize: 16,
                      onPressed: _open ? widget.onRematch : null,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    flex: 2,
                    child: ComicButton(
                      label: l10n.menu,
                      icon: Icons.home_rounded,
                      height: 44,
                      fontSize: 16,
                      onPressed: _open ? widget.onMenu : null,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = GameThemeScope.of(context);
    return Stack(
      fit: StackFit.expand,
      children: [
        ModalBarrier(color: theme.dim, dismissible: false),
        IgnorePointer(
          child: RepaintBoundary(
            child: CustomPaint(
              painter: ConfettiPainter(
                progress: _c,
                colors: theme.confetti,
                ink: theme.ink,
                seed: 3,
                count: 40,
              ),
            ),
          ),
        ),
        MirroredHalves(
          top: widget.vsBot ? null : _card(context, Side.blue),
          bottom: _card(context, Side.red),
        ),
      ],
    );
  }
}
