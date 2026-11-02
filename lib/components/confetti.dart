import 'dart:math' as math;

import 'package:flutter/material.dart';

/// Falling paper confetti driven by an [Animation] (0..1 over its life).
class ConfettiPainter extends CustomPainter {
  ConfettiPainter({
    required this.progress,
    required this.colors,
    required this.ink,
    this.seed = 7,
    this.count = 56,
  }) : super(repaint: progress);

  final Animation<double> progress;
  final List<Color> colors;
  final Color ink;
  final int seed;
  final int count;

  @override
  void paint(Canvas canvas, Size size) {
    final t = progress.value;
    if (t <= 0 || t >= 1) return;
    final rnd = math.Random(seed);
    final fade = t > 0.8 ? (1 - t) / 0.2 : 1.0;
    final outline = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1
      ..color = ink.withValues(alpha: 0.5 * fade);
    for (var i = 0; i < count; i++) {
      final x0 = rnd.nextDouble();
      final y0 = rnd.nextDouble() * 1.1 - 0.15;
      final fall = 0.25 + rnd.nextDouble() * 0.35;
      final sway = (rnd.nextDouble() - 0.5) * 0.08;
      final spin = (rnd.nextDouble() - 0.5) * 10;
      final w = 5 + rnd.nextDouble() * 6;
      final h = w * (1.8 + rnd.nextDouble());
      final color = colors[i % colors.length];
      final x = (x0 + sway * math.sin(t * 9 + i)) * size.width;
      final y = (y0 + fall * t) * size.height;
      canvas.save();
      canvas.translate(x, y);
      canvas.rotate(spin * t + i);
      final rect = RRect.fromRectAndRadius(
        Rect.fromCenter(center: Offset.zero, width: w, height: h),
        const Radius.circular(2),
      );
      canvas.drawRRect(rect, Paint()..color = color.withValues(alpha: fade));
      canvas.drawRRect(rect, outline);
      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(ConfettiPainter oldDelegate) =>
      oldDelegate.progress != progress || oldDelegate.seed != seed;
}

/// Spiky comic speech burst behind a big shout.
class StarBurstPainter extends CustomPainter {
  const StarBurstPainter({
    required this.fill,
    required this.ink,
    required this.outline,
  });

  final Color fill;
  final Color ink;
  final double outline;

  @override
  void paint(Canvas canvas, Size size) {
    const points = 14;
    final c = size.center(Offset.zero);
    final rx = size.width / 2;
    final ry = size.height / 2;
    final path = Path();
    for (var i = 0; i < points * 2; i++) {
      final a = -math.pi / 2 + i * math.pi / points;
      final outer = i.isEven;
      final jag = outer ? (i % 4 == 0 ? 1.0 : 0.9) : 0.7;
      final p = c + Offset(math.cos(a) * rx * jag, math.sin(a) * ry * jag);
      if (i == 0) {
        path.moveTo(p.dx, p.dy);
      } else {
        path.lineTo(p.dx, p.dy);
      }
    }
    path.close();
    canvas.drawPath(
      path.shift(Offset(outline * 1.4, outline * 2)),
      Paint()..color = ink,
    );
    canvas.drawPath(path, Paint()..color = fill);
    canvas.drawPath(
      path,
      Paint()
        ..color = ink
        ..style = PaintingStyle.stroke
        ..strokeWidth = outline
        ..strokeJoin = StrokeJoin.round,
    );
  }

  @override
  bool shouldRepaint(StarBurstPainter oldDelegate) =>
      oldDelegate.fill != fill ||
      oldDelegate.ink != ink ||
      oldDelegate.outline != outline;
}
