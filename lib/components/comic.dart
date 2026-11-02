/// Comic Arcade building blocks: dotted paper, chunky buttons, cards and
/// outlined headline text. Everything reads the active [GameTheme].
library;

import 'dart:ui' show PointMode;

import 'package:flutter/material.dart';

import '../theme/game_theme.dart';

/// Warm yellow halftone paper. Painted once and cached.
class DottedBackground extends StatelessWidget {
  const DottedBackground({this.child, super.key});

  final Widget? child;

  @override
  Widget build(BuildContext context) {
    final theme = GameThemeScope.of(context);
    return CustomPaint(
      painter: _DotsPainter(theme),
      isComplex: true,
      willChange: false,
      child: child ?? const SizedBox.expand(),
    );
  }
}

class _DotsPainter extends CustomPainter {
  const _DotsPainter(this.theme);

  final GameTheme theme;

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    canvas.drawRect(
      rect,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [theme.backgroundTop, theme.background],
        ).createShader(rect),
    );
    const step = 13.0;
    final points = <Offset>[
      for (var y = step / 2; y < size.height; y += step)
        for (var x = step / 2; x < size.width; x += step) Offset(x, y),
    ];
    canvas.drawPoints(
      PointMode.points,
      points,
      Paint()
        ..color = theme.backgroundDot
        ..strokeWidth = 4
        ..strokeCap = StrokeCap.round,
    );
  }

  @override
  bool shouldRepaint(_DotsPainter oldDelegate) => oldDelegate.theme != theme;
}

/// Cream card with a thick outline and a hard offset shadow.
class ComicCard extends StatelessWidget {
  const ComicCard({
    required this.child,
    this.padding = const EdgeInsets.all(16),
    super.key,
  });

  final Widget child;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    final theme = GameThemeScope.of(context);
    return DecoratedBox(
      decoration: BoxDecoration(
        color: theme.card,
        borderRadius: BorderRadius.circular(theme.radius * 1.5),
        border: Border.all(color: theme.ink, width: theme.outline + 0.5),
        boxShadow: [
          BoxShadow(
            color: theme.ink,
            offset: Offset(theme.shadow, theme.shadow * 1.4),
          ),
        ],
      ),
      child: Padding(padding: padding, child: child),
    );
  }
}

/// Chunky pill button that sinks into its shadow while pressed.
///
/// [onPressed] null shows it locked (dimmed and ignoring taps).
class ComicButton extends StatefulWidget {
  const ComicButton({
    required this.label,
    required this.onPressed,
    this.color,
    this.icon,
    this.height = 46,
    this.fontSize = 17,
    super.key,
  });

  final String label;
  final VoidCallback? onPressed;

  /// Fill. Null is the plain white button with ink text.
  final Color? color;
  final IconData? icon;
  final double height;
  final double fontSize;

  @override
  State<ComicButton> createState() => _ComicButtonState();
}

class _ComicButtonState extends State<ComicButton> {
  var _down = false;

  void _set(bool down) {
    if (_down != down) setState(() => _down = down);
  }

  @override
  Widget build(BuildContext context) {
    final theme = GameThemeScope.of(context);
    final enabled = widget.onPressed != null;
    final fill = widget.color ?? theme.surface;
    final light = widget.color == null;
    final fg = light ? theme.ink : Colors.white;
    final shadow = theme.shadow;
    final sink = _down ? shadow : 0.0;
    final textStyle = theme
        .display(widget.fontSize, color: fg)
        .copyWith(
          shadows: light
              ? null
              : [
                  Shadow(
                    color: theme.ink,
                    offset: Offset(0, widget.fontSize * 0.08),
                  ),
                ],
        );
    return Semantics(
      button: true,
      enabled: enabled,
      label: widget.label,
      excludeSemantics: true,
      child: AnimatedOpacity(
        duration: const Duration(milliseconds: 180),
        opacity: enabled ? 1 : 0.55,
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTapDown: enabled ? (_) => _set(true) : null,
          onTapCancel: () => _set(false),
          onTapUp: enabled ? (_) => _set(false) : null,
          onTap: widget.onPressed,
          child: SizedBox(
            height: widget.height + shadow,
            child: Padding(
              padding: EdgeInsets.only(top: sink, bottom: shadow - sink),
              child: DecoratedBox(
                decoration: BoxDecoration(
                  color: fill,
                  borderRadius: BorderRadius.circular(widget.height * 0.32),
                  border: Border.all(color: theme.ink, width: theme.outline),
                  boxShadow: _down
                      ? null
                      : [
                          BoxShadow(
                            color: theme.ink,
                            offset: Offset(0, shadow),
                          ),
                        ],
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  child: Center(
                    child: FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (widget.icon != null) ...[
                            Icon(
                              widget.icon,
                              size: widget.fontSize * 1.25,
                              color: fg,
                              shadows: textStyle.shadows,
                            ),
                            SizedBox(width: widget.fontSize * 0.4),
                          ],
                          Text(widget.label, maxLines: 1, style: textStyle),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Headline text with a thick ink outline and a hard drop shadow.
class OutlinedText extends StatelessWidget {
  const OutlinedText(
    this.text, {
    required this.size,
    required this.color,
    this.stroke,
    this.textAlign = TextAlign.center,
    super.key,
  });

  final String text;
  final double size;
  final Color color;
  final double? stroke;
  final TextAlign textAlign;

  @override
  Widget build(BuildContext context) {
    final theme = GameThemeScope.of(context);
    final width = stroke ?? (size * 0.11).clamp(2.0, 9.0);
    final base = theme.display(size);
    return Stack(
      children: [
        Text(
          text,
          maxLines: 1,
          textAlign: textAlign,
          style: base.copyWith(
            foreground: Paint()
              ..style = PaintingStyle.stroke
              ..strokeWidth = width
              ..strokeJoin = StrokeJoin.round
              ..color = theme.ink,
            shadows: [
              Shadow(
                color: theme.ink,
                offset: Offset(size * 0.05, size * 0.09),
              ),
            ],
          ),
        ),
        Text(
          text,
          maxLines: 1,
          textAlign: textAlign,
          style: base.copyWith(color: color),
        ),
      ],
    );
  }
}

/// Round outlined icon button, used for "back" on the menu pages.
class ComicIconButton extends StatelessWidget {
  const ComicIconButton({
    required this.icon,
    required this.onPressed,
    required this.tooltip,
    this.color,
    this.size = 44,
    super.key,
  });

  final IconData icon;
  final VoidCallback onPressed;
  final String tooltip;
  final Color? color;
  final double size;

  @override
  Widget build(BuildContext context) {
    final theme = GameThemeScope.of(context);
    return Tooltip(
      message: tooltip,
      child: Semantics(
        button: true,
        label: tooltip,
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: onPressed,
          child: Container(
            width: size,
            height: size,
            decoration: BoxDecoration(
              color: color ?? theme.surface,
              shape: BoxShape.circle,
              border: Border.all(color: theme.ink, width: theme.outline),
              boxShadow: [
                BoxShadow(
                  color: theme.ink,
                  offset: Offset(theme.shadow * 0.5, theme.shadow * 0.8),
                ),
              ],
            ),
            child: Icon(icon, color: theme.ink, size: size * 0.5),
          ),
        ),
      ),
    );
  }
}

/// Menu page frame: dotted paper, back button and an outlined title.
class ComicPage extends StatelessWidget {
  const ComicPage({
    required this.title,
    required this.child,
    this.onBack,
    super.key,
  });

  final String title;
  final Widget child;
  final VoidCallback? onBack;

  @override
  Widget build(BuildContext context) {
    final theme = GameThemeScope.of(context);
    return Scaffold(
      backgroundColor: theme.background,
      body: DottedBackground(
        child: SafeArea(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
                child: Row(
                  children: [
                    ComicIconButton(
                      icon: Icons.arrow_back_rounded,
                      tooltip: MaterialLocalizations.of(context)
                          .backButtonTooltip,
                      onPressed:
                          onBack ?? () => Navigator.of(context).maybePop(),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: FittedBox(
                        alignment: Alignment.centerLeft,
                        fit: BoxFit.scaleDown,
                        child: OutlinedText(
                          title,
                          size: 30,
                          color: theme.surface,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(child: child),
            ],
          ),
        ),
      ),
    );
  }
}
