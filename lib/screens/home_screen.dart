import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../app_scope.dart';
import '../components/banner_slot.dart';
import '../components/comic.dart';
import '../engine/robot.dart';
import '../engine/table.dart';
import '../l10n/app_localizations.dart';
import '../theme/game_theme.dart';
import '../theme/table_painter.dart';
import 'how_to_play_screen.dart';
import 'match_screen.dart';
import 'settings_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  var _askedHowTo = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _openFirstHowTo());
  }

  void _openFirstHowTo() {
    if (!mounted || _askedHowTo) return;
    if (AppScope.read(context).settings.onboardingDone) return;
    _askedHowTo = true;
    _howTo(firstRun: true);
  }

  void _howTo({bool firstRun = false}) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        fullscreenDialog: true,
        builder: (_) => HowToPlayScreen(firstRun: firstRun),
      ),
    );
  }

  Future<void> _play({Difficulty? difficulty}) async {
    await AppScope.read(context).audio.play();
    if (!mounted) return;
    await Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => MatchScreen(difficulty: difficulty),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = GameThemeScope.of(context);
    final settings = AppScope.of(context).settings;
    return Scaffold(
      backgroundColor: theme.background,
      body: DottedBackground(
        child: SafeArea(
          child: Column(
            children: [
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 12, 20, 12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const Spacer(),
                      _Logo(
                        top: l10n.logoTop,
                        bottom: l10n.logoBottom,
                        note: l10n.workingTitle,
                      ),
                      const Expanded(flex: 5, child: _Hero()),
                      _ModeButton(
                        title: l10n.onePlayer,
                        subtitle: l10n.onePlayerHint,
                        icon: Icons.smart_toy_rounded,
                        color: theme.red,
                        onPressed: () => _play(difficulty: settings.difficulty),
                      ),
                      const SizedBox(height: 8),
                      _DifficultyPicker(
                        value: settings.difficulty,
                        labels: {
                          Difficulty.easy: l10n.easy,
                          Difficulty.normal: l10n.normal,
                          Difficulty.hard: l10n.hard,
                        },
                        onChanged: settings.setDifficulty,
                      ),
                      const SizedBox(height: 10),
                      _ModeButton(
                        title: l10n.twoPlayers,
                        subtitle: l10n.twoPlayersHint,
                        icon: Icons.people_alt_rounded,
                        color: theme.blue,
                        onPressed: () => _play(),
                      ),
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          Expanded(
                            child: ComicButton(
                              label: l10n.settings,
                              icon: Icons.settings_rounded,
                              height: 40,
                              fontSize: 15,
                              onPressed: () => Navigator.of(context).push(
                                MaterialPageRoute<void>(
                                  builder: (_) => const SettingsScreen(),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: ComicButton(
                              label: l10n.howToPlay,
                              icon: Icons.help_outline_rounded,
                              height: 40,
                              fontSize: 15,
                              onPressed: _howTo,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const BannerSlot(),
            ],
          ),
        ),
      ),
    );
  }
}

class _Logo extends StatelessWidget {
  const _Logo({required this.top, required this.bottom, required this.note});

  final String top;
  final String bottom;
  final String note;

  @override
  Widget build(BuildContext context) {
    final theme = GameThemeScope.of(context);
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        FittedBox(
          fit: BoxFit.scaleDown,
          child: OutlinedText(top, size: 52, color: theme.red),
        ),
        FittedBox(
          fit: BoxFit.scaleDown,
          child: OutlinedText(bottom, size: 44, color: theme.blue),
        ),
        const SizedBox(height: 4),
        Text(
          note,
          style: theme.body(11, color: theme.subtle, weight: FontWeight.w600),
        ),
      ],
    );
  }
}

/// Two mallets and the puck, drawn with the rink painters.
class _Hero extends StatelessWidget {
  const _Hero();

  @override
  Widget build(BuildContext context) {
    final theme = GameThemeScope.of(context);
    return ExcludeSemantics(
      child: RepaintBoundary(
        child: CustomPaint(
          painter: _HeroPainter(theme),
          child: const SizedBox.expand(),
        ),
      ),
    );
  }
}

class _HeroPainter extends CustomPainter {
  const _HeroPainter(this.theme);

  final GameTheme theme;

  @override
  void paint(Canvas canvas, Size size) {
    final r = math.min(size.height * 0.3, size.width * 0.11);
    if (r < 8) return;
    final c = size.center(Offset.zero);
    paintMallet(canvas, c + Offset(-r * 2.3, -r * 0.15), r, Side.blue, theme);
    paintPuck(canvas, c + Offset(0, -r * 0.35), r * 0.62, theme);
    paintMallet(canvas, c + Offset(r * 2.3, r * 0.2), r, Side.red, theme);
  }

  @override
  bool shouldRepaint(_HeroPainter oldDelegate) => oldDelegate.theme != theme;
}

class _ModeButton extends StatefulWidget {
  const _ModeButton({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.color,
    required this.onPressed,
  });

  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;
  final VoidCallback onPressed;

  @override
  State<_ModeButton> createState() => _ModeButtonState();
}

class _ModeButtonState extends State<_ModeButton> {
  var _down = false;

  void _set(bool down) {
    if (_down != down) setState(() => _down = down);
  }

  @override
  Widget build(BuildContext context) {
    final theme = GameThemeScope.of(context);
    final shadow = theme.shadow * 1.3;
    final sink = _down ? shadow : 0.0;
    return Semantics(
      button: true,
      label: '${widget.title}. ${widget.subtitle}',
      excludeSemantics: true,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTapDown: (_) => _set(true),
        onTapUp: (_) => _set(false),
        onTapCancel: () => _set(false),
        onTap: widget.onPressed,
        child: Padding(
          padding: EdgeInsets.only(top: sink, bottom: shadow - sink),
          child: Container(
            height: 60,
            padding: const EdgeInsets.symmetric(horizontal: 12),
            decoration: BoxDecoration(
              color: widget.color,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: theme.ink, width: theme.outline),
              boxShadow: _down
                  ? null
                  : [BoxShadow(color: theme.ink, offset: Offset(0, shadow))],
            ),
            child: Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: theme.surface,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: theme.ink,
                      width: theme.outline * 0.8,
                    ),
                  ),
                  child: Icon(widget.icon, color: theme.ink, size: 24),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: theme
                            .display(22, color: Colors.white)
                            .copyWith(
                              shadows: [
                                Shadow(
                                  color: theme.ink,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                      ),
                      Text(
                        widget.subtitle,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: theme.body(12.5, color: Colors.white),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _DifficultyPicker extends StatelessWidget {
  const _DifficultyPicker({
    required this.value,
    required this.labels,
    required this.onChanged,
  });

  final Difficulty value;
  final Map<Difficulty, String> labels;
  final ValueChanged<Difficulty> onChanged;

  @override
  Widget build(BuildContext context) {
    final theme = GameThemeScope.of(context);
    return Container(
      height: 44,
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: theme.card,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: theme.ink, width: theme.outline * 0.8),
      ),
      child: Row(
        children: [
          for (final level in Difficulty.values)
            Expanded(
              child: Semantics(
                button: true,
                selected: level == value,
                label: labels[level],
                excludeSemantics: true,
                child: GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: () => onChanged(level),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 160),
                    alignment: Alignment.center,
                    decoration: level == value
                        ? BoxDecoration(
                            color: theme.red,
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: theme.ink, width: 2),
                          )
                        : const BoxDecoration(),
                    child: Text(
                      labels[level]!,
                      maxLines: 1,
                      style: theme
                          .display(
                            16,
                            color: level == value ? Colors.white : theme.subtle,
                          )
                          .copyWith(
                            shadows: level == value
                                ? [
                                    Shadow(
                                      color: theme.ink,
                                      offset: const Offset(0, 1.5),
                                    ),
                                  ]
                                : null,
                          ),
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
