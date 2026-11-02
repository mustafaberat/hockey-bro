import 'package:flutter/material.dart';

import '../app_scope.dart';
import '../components/comic.dart';
import '../engine/table.dart';
import '../l10n/app_localizations.dart';
import '../theme/game_theme.dart';
import '../theme/table_painter.dart';

class HowToPlayScreen extends StatefulWidget {
  const HowToPlayScreen({this.firstRun = false, super.key});

  final bool firstRun;

  @override
  State<HowToPlayScreen> createState() => _HowToPlayScreenState();
}

class _HowToPlayScreenState extends State<HowToPlayScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _play = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1600),
  );

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final reduce = MediaQuery.disableAnimationsOf(context);
    if (reduce) {
      _play.value = 0.42;
      _play.stop();
    } else if (!_play.isAnimating) {
      _play.repeat();
    }
  }

  @override
  void dispose() {
    _play.dispose();
    super.dispose();
  }

  void _close() {
    AppScope.read(context).settings.setOnboardingDone();
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = GameThemeScope.of(context);
    return PopScope(
      onPopInvokedWithResult: (didPop, _) {
        if (didPop) AppScope.read(context).settings.setOnboardingDone();
      },
      child: ComicPage(
        title: l10n.howToPlay,
        onBack: _close,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 4, 20, 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(
                child: RepaintBoundary(
                  child: AnimatedBuilder(
                    animation: _play,
                    builder: (context, _) => CustomPaint(
                      painter: TablePainter(_demo(_play.value), theme),
                      child: const SizedBox.expand(),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Text(
                l10n.howToLine,
                textAlign: TextAlign.center,
                style: theme.display(18),
              ),
              const SizedBox(height: 4),
              Text(
                l10n.firstTo(TableRules.goalsToWin),
                textAlign: TextAlign.center,
                style: theme.body(14, color: theme.subtle),
              ),
              const SizedBox(height: 12),
              ComicButton(
                label: widget.firstRun ? l10n.skip : l10n.close,
                color: theme.primary,
                onPressed: _close,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

TableState _demo(double t) {
  const hit = 0.42;
  final approach = (t / hit).clamp(0.0, 1.0);
  final travel = ((t - hit) / 0.4).clamp(0.0, 1.0);
  final malletY =
      TableGeom.redHomeY +
      (TableGeom.centerY +
              TableGeom.malletR +
              TableGeom.puckR -
              TableGeom.redHomeY) *
          approach;
  final puckY = t < hit
      ? TableGeom.centerY
      : TableGeom.centerY +
            (TableGeom.puckR * 0.3 - TableGeom.centerY) * travel;
  return TableState(phase: RinkPhase.live, redY: malletY, puckY: puckY);
}
