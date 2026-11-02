/// Air-hockey table. Positions are in table units: width 1, height 1.7.
library;

import 'dart:math' as math;

enum Side { blue, red }

enum RinkPhase { faceoff, live, goal, over }

abstract final class TableGeom {
  static const double width = 1;
  static const double height = 1.7;
  static const double centerX = 0.5;
  static const double centerY = 0.85;
  static const double rail = 0.07;
  static const double malletR = 0.078;
  static const double puckR = 0.04;
  static const double goalHalf = 0.15;
  static const double blueHomeY = 0.36;
  static const double redHomeY = 1.34;
  static const double restitution = 0.92;
  static const double friction = 0.22;
  static const double maxSpeed = 3.2;
  static const double maxMalletSpeed = 6;
}

abstract final class TableRules {
  static const int goalsToWin = 3;
  static const Duration faceoff = Duration(milliseconds: 700);
  static const Duration goalHold = Duration(milliseconds: 900);
}

class TableState {
  const TableState({
    this.blue = 0,
    this.red = 0,
    this.phase = RinkPhase.faceoff,
    this.puckX = TableGeom.centerX,
    this.puckY = TableGeom.centerY,
    this.puckVx = 0,
    this.puckVy = 0,
    this.blueX = TableGeom.centerX,
    this.blueY = TableGeom.blueHomeY,
    this.redX = TableGeom.centerX,
    this.redY = TableGeom.redHomeY,
    this.blueVx = 0,
    this.blueVy = 0,
    this.redVx = 0,
    this.redVy = 0,
    this.lastScore,
    this.goalsToWin = TableRules.goalsToWin,
    this.struck = false,
  });

  final int blue;
  final int red;
  final RinkPhase phase;
  final double puckX;
  final double puckY;
  final double puckVx;
  final double puckVy;
  final double blueX;
  final double blueY;
  final double redX;
  final double redY;
  final double blueVx;
  final double blueVy;
  final double redVx;
  final double redVy;
  final Side? lastScore;
  final int goalsToWin;
  final bool struck;

  int scoreOf(Side side) => side == Side.blue ? blue : red;

  TableState copyWith({
    int? blue,
    int? red,
    RinkPhase? phase,
    double? puckX,
    double? puckY,
    double? puckVx,
    double? puckVy,
    double? blueX,
    double? blueY,
    double? redX,
    double? redY,
    double? blueVx,
    double? blueVy,
    double? redVx,
    double? redVy,
    Side? lastScore,
    bool clearLastScore = false,
    bool? struck,
  }) {
    return TableState(
      blue: blue ?? this.blue,
      red: red ?? this.red,
      phase: phase ?? this.phase,
      puckX: puckX ?? this.puckX,
      puckY: puckY ?? this.puckY,
      puckVx: puckVx ?? this.puckVx,
      puckVy: puckVy ?? this.puckVy,
      blueX: blueX ?? this.blueX,
      blueY: blueY ?? this.blueY,
      redX: redX ?? this.redX,
      redY: redY ?? this.redY,
      blueVx: blueVx ?? this.blueVx,
      blueVy: blueVy ?? this.blueVy,
      redVx: redVx ?? this.redVx,
      redVy: redVy ?? this.redVy,
      lastScore: clearLastScore ? null : (lastScore ?? this.lastScore),
      goalsToWin: goalsToWin,
      struck: struck ?? this.struck,
    );
  }
}

Side? winnerOf(TableState state) {
  if (state.blue >= state.goalsToWin) return Side.blue;
  if (state.red >= state.goalsToWin) return Side.red;
  return null;
}

TableState dropPuck(TableState state) {
  if (state.phase != RinkPhase.faceoff) return state;
  return state.copyWith(
    phase: RinkPhase.live,
    puckX: TableGeom.centerX,
    puckY: TableGeom.centerY,
    puckVx: 0,
    puckVy: 0,
    struck: false,
    clearLastScore: true,
  );
}

TableState finishGoalBeat(TableState state) {
  if (state.phase != RinkPhase.goal) return state;
  final won = winnerOf(state) != null;
  return TableState(
    blue: state.blue,
    red: state.red,
    phase: won ? RinkPhase.over : RinkPhase.faceoff,
    lastScore: won ? state.lastScore : null,
    goalsToWin: state.goalsToWin,
  );
}

(double, double) clampMallet(Side side, double x, double y) {
  const r = TableGeom.malletR;
  final minX = TableGeom.rail + r;
  final maxX = TableGeom.width - TableGeom.rail - r;
  final cx = x.clamp(minX, maxX).toDouble();
  if (side == Side.blue) {
    final minY = TableGeom.rail + TableGeom.malletR;
    final maxY = TableGeom.centerY - TableGeom.malletR;
    return (cx, y.clamp(minY, maxY).toDouble());
  }
  final minY = TableGeom.centerY + TableGeom.malletR;
  final maxY = TableGeom.height - TableGeom.rail - TableGeom.malletR;
  return (cx, y.clamp(minY, maxY).toDouble());
}

TableState placeMallet(TableState state, Side side, double x, double y, double dt) {
  if (state.phase == RinkPhase.goal || state.phase == RinkPhase.over) return state;
  final next = clampMallet(side, x, y);
  final safeDt = dt <= 0 ? 1 / 60 : dt;
  var vx = (next.$1 - (side == Side.blue ? state.blueX : state.redX)) / safeDt;
  var vy = (next.$2 - (side == Side.blue ? state.blueY : state.redY)) / safeDt;
  final speed = math.sqrt(vx * vx + vy * vy);
  if (speed > TableGeom.maxMalletSpeed) {
    final scale = TableGeom.maxMalletSpeed / speed;
    vx *= scale;
    vy *= scale;
  }
  if (side == Side.blue) {
    return state.copyWith(blueX: next.$1, blueY: next.$2, blueVx: vx, blueVy: vy);
  }
  return state.copyWith(redX: next.$1, redY: next.$2, redVx: vx, redVy: vy);
}

TableState stepTable(TableState state, double dt) {
  if (state.phase != RinkPhase.live || dt <= 0) return state;
  const slices = 4;
  final h = dt / slices;
  var current = state.copyWith(struck: false);
  for (var i = 0; i < slices; i++) {
    current = _slice(current, h);
    if (current.phase != RinkPhase.live) return current;
  }
  return current;
}

TableState _slice(TableState state, double dt) {
  final damp = math.exp(-TableGeom.friction * dt);
  var vx = state.puckVx * damp;
  var vy = state.puckVy * damp;
  var x = state.puckX + vx * dt;
  var y = state.puckY + vy * dt;

  final left = TableGeom.rail + TableGeom.puckR;
  final right = TableGeom.width - TableGeom.rail - TableGeom.puckR;
  final top = TableGeom.rail + TableGeom.puckR;
  final bottom = TableGeom.height - TableGeom.rail - TableGeom.puckR;
  final goalL = TableGeom.centerX - TableGeom.goalHalf;
  final goalR = TableGeom.centerX + TableGeom.goalHalf;

  if (x < left) {
    x = left;
    vx = vx.abs() * TableGeom.restitution;
  } else if (x > right) {
    x = right;
    vx = -vx.abs() * TableGeom.restitution;
  }

  final inMouth = x > goalL && x < goalR;
  if (y < top && !inMouth) {
    y = top;
    if (vy < 0) vy = -vy * TableGeom.restitution;
  } else if (y > bottom && !inMouth) {
    y = bottom;
    if (vy > 0) vy = -vy * TableGeom.restitution;
  }

  if (y <= 0 && inMouth) {
    return state.copyWith(
      red: state.red + 1,
      phase: RinkPhase.goal,
      lastScore: Side.red,
      puckX: x,
      puckY: 0,
      puckVx: 0,
      puckVy: 0,
      struck: false,
    );
  }
  if (y >= TableGeom.height && inMouth) {
    return state.copyWith(
      blue: state.blue + 1,
      phase: RinkPhase.goal,
      lastScore: Side.blue,
      puckX: x,
      puckY: TableGeom.height,
      puckVx: 0,
      puckVy: 0,
      struck: false,
    );
  }

  var struck = false;
  final blueHit = _hitMallet(
    x, y, vx, vy,
    state.blueX, state.blueY, state.blueVx, state.blueVy,
  );
  x = blueHit.$1;
  y = blueHit.$2;
  vx = blueHit.$3;
  vy = blueHit.$4;
  struck = blueHit.$5;
  final redHit = _hitMallet(
    x, y, vx, vy,
    state.redX, state.redY, state.redVx, state.redVy,
  );
  x = redHit.$1;
  y = redHit.$2;
  vx = redHit.$3;
  vy = redHit.$4;
  struck = struck || redHit.$5;

  final speed = math.sqrt(vx * vx + vy * vy);
  if (speed > TableGeom.maxSpeed) {
    final scale = TableGeom.maxSpeed / speed;
    vx *= scale;
    vy *= scale;
  } else if (speed < 0.012) {
    vx = 0;
    vy = 0;
  }

  return state.copyWith(
    puckX: x,
    puckY: y,
    puckVx: vx,
    puckVy: vy,
    struck: state.struck || struck,
  );
}

(double, double, double, double, bool) _hitMallet(
  double x,
  double y,
  double vx,
  double vy,
  double mx,
  double my,
  double mvx,
  double mvy,
) {
  var dx = x - mx;
  var dy = y - my;
  var dist = math.sqrt(dx * dx + dy * dy);
  final minDist = TableGeom.puckR + TableGeom.malletR;
  if (dist >= minDist) return (x, y, vx, vy, false);
  if (dist == 0) {
    dx = 0;
    dy = -1;
    dist = 0.0001;
  }
  final nx = dx / dist;
  final ny = dy / dist;
  x += nx * (minDist - dist);
  final rel = (vx - mvx) * nx + (vy - mvy) * ny;
  if (rel < 0) {
    final impulse = -(1 + TableGeom.restitution) * rel;
    vx += impulse * nx;
    vy += impulse * ny;
  } else {
    vx += mvx * 0.45;
    vy += mvy * 0.45;
  }
  return (x, y, vx, vy, true);
}
