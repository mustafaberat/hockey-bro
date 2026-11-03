import 'dart:math' as math;

import 'table.dart';

enum Difficulty { easy, normal, hard }

enum _Beat { guard, windup, strike, recover }

/// Top mallet. It keeps its distance, then swings through the puck at the
/// goal. Easy swings wide. Hard is sharper and still misses sometimes.
class Robot {
  Robot(this.difficulty, {math.Random? random}) : _rng = random ?? math.Random();

  final Difficulty difficulty;
  final math.Random _rng;

  _Beat _beat = _Beat.guard;
  double _time = 0;
  double _wait = 0;
  double _shotX = TableGeom.centerX;

  void reset() {
    _beat = _Beat.guard;
    _time = 0;
    _wait = _rollWait();
  }

  (double, double) aim(TableState state, double dt) {
    final stepDt = dt <= 0 ? 1 / 60 : dt;
    _time += stepDt;
    if (_beat == _Beat.guard && _wait == 0) _wait = _rollWait();
    _advance(state);
    return _move(state, _target(state), _speed, stepDt);
  }

  void _advance(TableState state) {
    switch (_beat) {
      case _Beat.guard:
        if (_time >= _wait && _canAttack(state)) _beginWindup(state);
      case _Beat.windup:
        final linedUp = (state.blueX - _shotX).abs() < 0.05;
        if (_time >= _windupFor || (_behind(state) && linedUp && _time > 0.06)) {
          _beginStrike(state);
        }
      case _Beat.strike:
        if (state.struck || _time >= _strikeFor) _beginRecover();
      case _Beat.recover:
        if (_time >= _recoverFor) {
          _beat = _Beat.guard;
          _time = 0;
          _wait = _rollWait();
        }
    }
  }

  bool _canAttack(TableState state) {
    final inHalf = state.puckY < TableGeom.centerY - TableGeom.puckR;
    final incoming =
        state.puckVy < -0.35 && state.puckY < TableGeom.centerY + 0.3;
    return inHalf || incoming;
  }

  /// Mallet center is on the goal side of the puck, clear of the disc.
  bool _behind(TableState state) {
    const gap = TableGeom.malletR + TableGeom.puckR + 0.06;
    return state.blueY < state.puckY - gap;
  }

  void _beginWindup(TableState state) {
    _beat = _Beat.windup;
    _time = 0;
    _shotX = _clampX(state.puckX);
  }

  void _beginStrike(TableState state) {
    _beat = _Beat.strike;
    _time = 0;
    final lead = switch (difficulty) {
      Difficulty.easy => 0.0,
      Difficulty.normal => 0.08,
      Difficulty.hard => 0.14,
    };
    var error = (_rng.nextDouble() * 2 - 1) * _aimError;
    final whiff = switch (difficulty) {
      Difficulty.easy => 0.34,
      Difficulty.normal => 0.18,
      Difficulty.hard => 0.1,
    };
    if (_rng.nextDouble() < whiff) {
      error += (_rng.nextBool() ? 1 : -1) * _aimError * 2.2;
    }
    _shotX = _clampX(state.puckX + state.puckVx * lead + error);
  }

  void _beginRecover() {
    _beat = _Beat.recover;
    _time = 0;
  }

  (double, double) _target(TableState state) {
    switch (_beat) {
      case _Beat.guard:
      case _Beat.recover:
        return (_clampX(state.puckX), _holdY(state));
      case _Beat.windup:
        return (_shotX, _holdY(state));
      case _Beat.strike:
        // Past the puck, toward the far goal, so the mallet does not stop
        // on the disc.
        final through = state.puckY + TableGeom.malletR + TableGeom.puckR + 0.16;
        return (_shotX, through);
    }
  }

  /// Stay up the ice. Never park on top of the puck.
  double _holdY(TableState state) {
    const gap = TableGeom.malletR + TableGeom.puckR + 0.08;
    final minY = TableGeom.rail + TableGeom.malletR;
    final maxY = TableGeom.centerY - TableGeom.malletR;
    final pulled = math.min(TableGeom.blueHomeY, state.puckY - gap);
    return pulled.clamp(minY, maxY).toDouble();
  }

  double _clampX(double value) {
    final minX = TableGeom.rail + TableGeom.malletR;
    final maxX = TableGeom.width - TableGeom.rail - TableGeom.malletR;
    return value.clamp(minX, maxX).toDouble();
  }

  (double, double) _move(TableState state, (double, double) target, double speed, double dt) {
    final dx = target.$1 - state.blueX;
    final dy = target.$2 - state.blueY;
    final dist = math.sqrt(dx * dx + dy * dy);
    final step = speed * dt;
    if (dist <= step || dist == 0) return target;
    return (state.blueX + dx / dist * step, state.blueY + dy / dist * step);
  }

  double get _speed => switch (_beat) {
    _Beat.guard => switch (difficulty) {
      Difficulty.easy => 1.35,
      Difficulty.normal => 2.1,
      Difficulty.hard => 2.8,
    },
    _Beat.windup => switch (difficulty) {
      Difficulty.easy => 1.6,
      Difficulty.normal => 2.6,
      Difficulty.hard => 3.6,
    },
    _Beat.strike => switch (difficulty) {
      Difficulty.easy => 3.1,
      Difficulty.normal => 4.5,
      Difficulty.hard => 5.8,
    },
    _Beat.recover => switch (difficulty) {
      Difficulty.easy => 2.2,
      Difficulty.normal => 3.4,
      Difficulty.hard => 4.8,
    },
  };

  double _rollWait() => switch (difficulty) {
    Difficulty.easy => 0.35 + _rng.nextDouble() * 0.45,
    Difficulty.normal => 0.18 + _rng.nextDouble() * 0.28,
    Difficulty.hard => 0.08 + _rng.nextDouble() * 0.16,
  };

  double get _windupFor => switch (difficulty) {
    Difficulty.easy => 0.28,
    Difficulty.normal => 0.16,
    Difficulty.hard => 0.1,
  };

  double get _strikeFor => 0.28;

  double get _recoverFor => switch (difficulty) {
    Difficulty.easy => 0.42,
    Difficulty.normal => 0.28,
    Difficulty.hard => 0.18,
  };

  double get _aimError => switch (difficulty) {
    Difficulty.easy => 0.2,
    Difficulty.normal => 0.09,
    Difficulty.hard => 0.035,
  };
}
