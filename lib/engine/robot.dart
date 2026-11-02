import 'dart:math' as math;

import 'table.dart';

enum Difficulty { easy, normal, hard }

/// Moves the top mallet toward the puck. [dt] limits how far it can travel.
(double, double) robotAim(TableState state, Difficulty difficulty, double dt) {
  final speed = switch (difficulty) {
    Difficulty.easy => 1.15,
    Difficulty.normal => 2.2,
    Difficulty.hard => 4.2,
  };
  final lead = switch (difficulty) {
    Difficulty.easy => 0.0,
    Difficulty.normal => 0.1,
    Difficulty.hard => 0.22,
  };
  final attack = switch (difficulty) {
    Difficulty.easy => 0.35,
    Difficulty.normal => 0.7,
    Difficulty.hard => 0.95,
  };

  final coming = state.puckVy < 0.15 || state.puckY < TableGeom.centerY + 0.05;
  var wantX = coming ? state.puckX + state.puckVx * lead : TableGeom.centerX;
  wantX = wantX.clamp(0.12, 0.88).toDouble();

  var wantY = TableGeom.blueHomeY;
  if (coming) {
    final front = state.puckY - TableGeom.malletR - TableGeom.puckR;
    wantY = TableGeom.blueHomeY + (front - TableGeom.blueHomeY) * attack;
  }

  final dx = wantX - state.blueX;
  final dy = wantY - state.blueY;
  final dist = math.sqrt(dx * dx + dy * dy);
  final step = speed * (dt <= 0 ? 1 / 60 : dt);
  if (dist <= step || dist == 0) return (wantX, wantY);
  return (state.blueX + dx / dist * step, state.blueY + dy / dist * step);
}
