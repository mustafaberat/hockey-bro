/// Rink drawing. The rink itself never moves, so it lives in its own cached
/// layer ([RinkPainter]); mallets, puck and hit effects repaint every frame
/// from a [Listenable] ([PiecesPainter]) without rebuilding any widgets.
library;

import 'dart:math' as math;
import 'dart:ui' show PointMode;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../engine/table.dart';
import 'game_theme.dart';

class TableFit {
  TableFit(Size size)
    : scale = math.min(
        size.width / TableGeom.width,
        size.height / TableGeom.height,
      ),
      ox =
          (size.width -
              TableGeom.width *
                  math.min(
                    size.width / TableGeom.width,
                    size.height / TableGeom.height,
                  )) /
          2,
      oy =
          (size.height -
              TableGeom.height *
                  math.min(
                    size.width / TableGeom.width,
                    size.height / TableGeom.height,
                  )) /
          2;

  final double scale;
  final double ox;
  final double oy;

  Offset of(double x, double y) => Offset(ox + x * scale, oy + y * scale);

  /// The visible playing surface (inside the rail).
  Rect get ice => Rect.fromPoints(
    of(TableGeom.rail, TableGeom.rail),
    of(TableGeom.width - TableGeom.rail, TableGeom.height - TableGeom.rail),
  );
}

/// Static rink: surface, dots, creases, center line, goals.
class RinkPainter extends CustomPainter {
  const RinkPainter(this.theme);

  final GameTheme theme;

  @override
  void paint(Canvas canvas, Size size) => paintRink(canvas, size, theme);

  @override
  bool shouldRepaint(RinkPainter oldDelegate) => oldDelegate.theme != theme;
}

void paintRink(Canvas canvas, Size size, GameTheme theme) {
  final fit = TableFit(size);
  if (fit.scale <= 0) return;
  final k = fit.scale;
  final ink = theme.ink;
  final o = theme.outline;
  final ice = fit.ice;
  final rrect = RRect.fromRectAndRadius(ice, Radius.circular(k * 0.09));

  canvas.drawRRect(rrect, Paint()..color = theme.rink);
  canvas.save();
  canvas.clipRRect(rrect);

  final step = k * 0.042;
  final dots = <Offset>[
    for (var y = ice.top + step / 2; y < ice.bottom; y += step)
      for (var x = ice.left + step / 2; x < ice.right; x += step) Offset(x, y),
  ];
  canvas.drawPoints(
    PointMode.points,
    dots,
    Paint()
      ..color = theme.rinkDot
      ..strokeWidth = math.max(2, k * 0.008)
      ..strokeCap = StrokeCap.round,
  );

  // Goal creases.
  final creaseR = k * 0.24;
  for (final (side, cy) in [(Side.blue, ice.top), (Side.red, ice.bottom)]) {
    final c = Offset(ice.center.dx, cy);
    final color = theme.side(side);
    canvas.drawCircle(
      c,
      creaseR,
      Paint()..color = color.withValues(alpha: 0.1),
    );
    _ring(canvas, c, creaseR, color, k * 0.014, ink, o * 0.5);
  }

  // Center line.
  final cy = fit.of(0, TableGeom.centerY).dy;
  final lineH = k * 0.018;
  canvas.drawRect(
    Rect.fromLTRB(
      ice.left,
      cy - lineH / 2 - o * 0.5,
      ice.right,
      cy + lineH / 2 + o * 0.5,
    ),
    Paint()..color = ink,
  );
  canvas.drawRect(
    Rect.fromLTRB(ice.left, cy - lineH / 2, ice.right, cy + lineH / 2),
    Paint()..color = theme.line,
  );

  // Center circle and spot.
  final center = fit.of(TableGeom.centerX, TableGeom.centerY);
  _ring(canvas, center, k * 0.2, theme.line, k * 0.014, ink, o * 0.5);
  canvas.drawCircle(center, k * 0.028, Paint()..color = ink);
  canvas.drawCircle(center, k * 0.028 - o * 0.5, Paint()..color = theme.line);
  canvas.restore();

  // Rink outline.
  canvas.drawRRect(
    rrect,
    Paint()
      ..color = ink
      ..style = PaintingStyle.stroke
      ..strokeWidth = o * 1.3,
  );

  // Goal mouths sit on the outline.
  final goalW = TableGeom.goalHalf * 2 * k;
  final goalH = k * 0.045;
  final r = Radius.circular(goalH * 0.6);
  final top = Rect.fromCenter(
    center: Offset(ice.center.dx, ice.top + goalH * 0.15),
    width: goalW,
    height: goalH,
  );
  canvas.drawRRect(
    RRect.fromRectAndCorners(
      top.shift(Offset(0, o)),
      bottomLeft: r,
      bottomRight: r,
    ),
    Paint()..color = theme.blue,
  );
  canvas.drawRRect(
    RRect.fromRectAndCorners(top, bottomLeft: r, bottomRight: r),
    Paint()..color = ink,
  );
  final bottom = Rect.fromCenter(
    center: Offset(ice.center.dx, ice.bottom - goalH * 0.15),
    width: goalW,
    height: goalH,
  );
  canvas.drawRRect(
    RRect.fromRectAndCorners(
      bottom.shift(Offset(0, -o)),
      topLeft: r,
      topRight: r,
    ),
    Paint()..color = theme.red,
  );
  canvas.drawRRect(
    RRect.fromRectAndCorners(bottom, topLeft: r, topRight: r),
    Paint()..color = ink,
  );
}

void _ring(
  Canvas canvas,
  Offset c,
  double radius,
  Color color,
  double width,
  Color ink,
  double edge,
) {
  canvas.drawCircle(
    c,
    radius,
    Paint()
      ..color = ink
      ..style = PaintingStyle.stroke
      ..strokeWidth = width + edge * 2,
  );
  canvas.drawCircle(
    c,
    radius,
    Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = width,
  );
}

/// One short-lived effect on the rink, in table units.
class RinkFxItem {
  RinkFxItem(this.kind, this.x, this.y, this.color, this.born);

  final RinkFxKind kind;
  final double x;
  final double y;
  final Color color;
  final double born;
}

enum RinkFxKind { hit, grab }

/// Ring buffer of hit and grab effects. New effects always get a slot (the
/// oldest is dropped), so every tap and hit shows up.
class RinkFx {
  static const int capacity = 16;
  static const double life = 0.32;

  final List<RinkFxItem> items = [];
  double now = 0;

  bool get active => items.isNotEmpty;

  void add(RinkFxKind kind, double x, double y, Color color) {
    if (items.length >= capacity) items.removeAt(0);
    items.add(RinkFxItem(kind, x, y, color, now));
  }

  void prune() => items.removeWhere((fx) => now - fx.born > life);

  void clear() => items.clear();
}

/// Mallets, puck, speed lines and effects. Repaints on [repaint] only.
class PiecesPainter extends CustomPainter {
  PiecesPainter({
    required this.table,
    required this.theme,
    this.fx,
    this.showPuck = true,
    super.repaint,
  });

  final ValueListenable<TableState> table;
  final GameTheme theme;
  final RinkFx? fx;
  final bool showPuck;

  @override
  void paint(Canvas canvas, Size size) {
    final fit = TableFit(size);
    if (fit.scale <= 0) return;
    paintPieces(canvas, fit, table.value, theme, showPuck: showPuck);
    final effects = fx;
    if (effects != null && effects.active) _paintFx(canvas, fit, effects);
  }

  void _paintFx(Canvas canvas, TableFit fit, RinkFx fx) {
    final k = fit.scale;
    for (final item in fx.items) {
      final t = ((fx.now - item.born) / RinkFx.life).clamp(0.0, 1.0);
      final fade = 1 - t;
      final c = fit.of(item.x, item.y);
      if (item.kind == RinkFxKind.hit) {
        final r0 = k * TableGeom.puckR * 1.2;
        final r = r0 + k * 0.07 * Curves.easeOut.transform(t);
        final paint = Paint()
          ..color = theme.ink.withValues(alpha: fade)
          ..strokeWidth = theme.outline * 0.9
          ..strokeCap = StrokeCap.round;
        for (var i = 0; i < 8; i++) {
          final a = i * math.pi / 4 + 0.3;
          final dir = Offset(math.cos(a), math.sin(a));
          canvas.drawLine(c + dir * r, c + dir * (r + k * 0.03 * fade), paint);
        }
      } else {
        final r =
            k * TableGeom.malletR * (1 + 0.6 * Curves.easeOut.transform(t));
        canvas.drawCircle(
          c,
          r,
          Paint()
            ..color = item.color.withValues(alpha: 0.7 * fade)
            ..style = PaintingStyle.stroke
            ..strokeWidth = theme.outline * 1.2,
        );
      }
    }
  }

  @override
  bool shouldRepaint(PiecesPainter oldDelegate) =>
      oldDelegate.table != table ||
      oldDelegate.theme != theme ||
      oldDelegate.fx != fx ||
      oldDelegate.showPuck != showPuck;
}

void paintPieces(
  Canvas canvas,
  TableFit fit,
  TableState state,
  GameTheme theme, {
  bool showPuck = true,
}) {
  paintMallet(
    canvas,
    fit.of(state.blueX, state.blueY),
    fit.scale * TableGeom.malletR,
    Side.blue,
    theme,
  );
  paintMallet(
    canvas,
    fit.of(state.redX, state.redY),
    fit.scale * TableGeom.malletR,
    Side.red,
    theme,
  );
  if (!showPuck) return;
  final puck = fit.of(state.puckX, state.puckY);
  final r = fit.scale * TableGeom.puckR;
  final speed = math.sqrt(
    state.puckVx * state.puckVx + state.puckVy * state.puckVy,
  );
  if (state.phase == RinkPhase.live && speed > 0.9) {
    final back = Offset(-state.puckVx, -state.puckVy) / speed;
    final side = Offset(-back.dy, back.dx);
    final len = r * (0.6 + (speed / TableGeom.maxSpeed).clamp(0.0, 1.0) * 1.2);
    final paint = Paint()
      ..color = theme.ink.withValues(alpha: 0.75)
      ..strokeWidth = theme.outline * 0.8
      ..strokeCap = StrokeCap.round;
    for (final lane in const [-0.55, 0.0, 0.55]) {
      final start = puck + back * (r * 1.5) + side * (r * lane);
      canvas.drawLine(
        start,
        start + back * (lane == 0 ? len * 1.3 : len),
        paint,
      );
    }
  }
  paintPuck(canvas, puck, r, theme);
}

void paintMallet(
  Canvas canvas,
  Offset c,
  double r,
  Side side,
  GameTheme theme,
) {
  final o = theme.outline;
  canvas.drawCircle(
    c + Offset(r * 0.09, r * 0.14),
    r,
    Paint()..color = theme.ink,
  );
  canvas.drawCircle(c, r, Paint()..color = theme.ink);
  canvas.drawCircle(c, r - o, Paint()..color = theme.side(side));
  canvas.drawCircle(c, r * 0.56, Paint()..color = theme.ink);
  canvas.drawCircle(
    c,
    r * 0.56 - o * 0.8,
    Paint()..color = theme.sideLight(side),
  );
  canvas.save();
  canvas.translate(c.dx - r * 0.12, c.dy - r * 0.16);
  canvas.rotate(-0.5);
  canvas.drawOval(
    Rect.fromCenter(center: Offset.zero, width: r * 0.2, height: r * 0.13),
    Paint()..color = Colors.white,
  );
  canvas.restore();
}

void paintPuck(Canvas canvas, Offset c, double r, GameTheme theme) {
  final o = theme.outline;
  canvas.drawCircle(
    c + Offset(r * 0.14, r * 0.22),
    r,
    Paint()..color = theme.ink,
  );
  canvas.drawCircle(c, r, Paint()..color = theme.ink);
  canvas.drawCircle(c, r - o * 0.85, Paint()..color = theme.puck);
}

/// Rink plus pieces in one painter, for small static boards (how to play).
class TablePainter extends CustomPainter {
  const TablePainter(this.state, this.theme);

  final TableState state;
  final GameTheme theme;

  @override
  void paint(Canvas canvas, Size size) {
    paintRink(canvas, size, theme);
    final fit = TableFit(size);
    if (fit.scale > 0) paintPieces(canvas, fit, state, theme);
  }

  @override
  bool shouldRepaint(TablePainter oldDelegate) =>
      oldDelegate.state != state || oldDelegate.theme != theme;
}
