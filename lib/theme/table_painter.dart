import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../config/tokens.dart';
import '../engine/table.dart';

class TableFit {
  TableFit(Size size)
    : scale = math.min(size.width / TableGeom.width, size.height / TableGeom.height),
      ox = (size.width - TableGeom.width * math.min(size.width / TableGeom.width, size.height / TableGeom.height)) / 2,
      oy = (size.height - TableGeom.height * math.min(size.width / TableGeom.width, size.height / TableGeom.height)) / 2;

  final double scale;
  final double ox;
  final double oy;

  Offset of(double x, double y) => Offset(ox + x * scale, oy + y * scale);
}

class TablePainter extends CustomPainter {
  const TablePainter(this.state);

  final TableState state;

  @override
  void paint(Canvas canvas, Size size) {
    final fit = TableFit(size);
    final rail = Paint()..color = AppColors.rail;
    canvas.drawRect(Offset.zero & size, rail);

    final ice = Rect.fromPoints(
      fit.of(TableGeom.rail, TableGeom.rail),
      fit.of(TableGeom.width - TableGeom.rail, TableGeom.height - TableGeom.rail),
    );
    canvas.drawRect(ice, Paint()..color = AppColors.ice);

    final dot = Paint()..color = AppColors.dot;
    for (var y = TableGeom.rail + 0.04; y < TableGeom.height - TableGeom.rail; y += 0.048) {
      for (var x = TableGeom.rail + 0.04; x < TableGeom.width - TableGeom.rail; x += 0.048) {
        canvas.drawCircle(fit.of(x, y), 1.15, dot);
      }
    }

    final goal = Paint()..color = AppColors.goal;
    final goalL = TableGeom.centerX - TableGeom.goalHalf;
    final goalR = TableGeom.centerX + TableGeom.goalHalf;
    canvas.drawRect(
      Rect.fromPoints(fit.of(goalL, 0), fit.of(goalR, TableGeom.rail)),
      goal,
    );
    canvas.drawRect(
      Rect.fromPoints(
        fit.of(goalL, TableGeom.height - TableGeom.rail),
        fit.of(goalR, TableGeom.height),
      ),
      goal,
    );

    final cap = 0.13;
    final capPaint = Paint()..color = AppColors.white;
    final corners = <(double, double)>[
      (0.0, 0.0),
      (TableGeom.width - cap, 0.0),
      (0.0, TableGeom.height - cap),
      (TableGeom.width - cap, TableGeom.height - cap),
    ];
    for (final corner in corners) {
      canvas.drawRect(
        Rect.fromPoints(fit.of(corner.$1, corner.$2), fit.of(corner.$1 + cap, corner.$2 + cap)),
        capPaint,
      );
    }

    final line = Paint()
      ..color = AppColors.line
      ..style = PaintingStyle.stroke
      ..strokeWidth = fit.scale * 0.016;
    canvas.drawLine(
      fit.of(TableGeom.rail, TableGeom.centerY),
      fit.of(TableGeom.width - TableGeom.rail, TableGeom.centerY),
      line,
    );
    canvas.drawCircle(fit.of(TableGeom.centerX, TableGeom.centerY), fit.scale * 0.2, line);
    canvas.drawCircle(fit.of(TableGeom.centerX, TableGeom.blueHomeY), fit.scale * 0.15, line);
    canvas.drawCircle(fit.of(TableGeom.centerX, TableGeom.redHomeY), fit.scale * 0.15, line);
    canvas.drawArc(
      Rect.fromCircle(center: fit.of(TableGeom.centerX, TableGeom.rail), radius: fit.scale * 0.2),
      0,
      math.pi,
      false,
      line,
    );
    canvas.drawArc(
      Rect.fromCircle(
        center: fit.of(TableGeom.centerX, TableGeom.height - TableGeom.rail),
        radius: fit.scale * 0.2,
      ),
      math.pi,
      math.pi,
      false,
      line,
    );

    _mallet(canvas, fit, state.blueX, state.blueY, AppColors.blue, AppColors.blueInk);
    _mallet(canvas, fit, state.redX, state.redY, AppColors.red, AppColors.redInk);
    canvas.drawCircle(
      fit.of(state.puckX, state.puckY),
      fit.scale * TableGeom.puckR,
      Paint()..color = AppColors.green,
    );
    canvas.drawCircle(
      fit.of(state.puckX, state.puckY),
      fit.scale * TableGeom.puckR * 0.42,
      Paint()..color = AppColors.greenInk,
    );
  }

  void _mallet(Canvas canvas, TableFit fit, double x, double y, Color fill, Color hole) {
    final center = fit.of(x, y);
    canvas.drawCircle(center, fit.scale * TableGeom.malletR, Paint()..color = fill);
    canvas.drawCircle(center, fit.scale * TableGeom.malletR * 0.4, Paint()..color = hole);
  }

  @override
  bool shouldRepaint(TablePainter oldDelegate) => true;
}
