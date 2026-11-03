import 'dart:math' as math;

import 'package:hockey_bro/app.dart';
import 'package:hockey_bro/app_scope.dart';
import 'package:hockey_bro/config/app_config.dart';
import 'package:hockey_bro/engine/robot.dart';
import 'package:hockey_bro/engine/table.dart';
import 'package:hockey_bro/services/ad_service.dart';
import 'package:hockey_bro/services/audio_service.dart';
import 'package:hockey_bro/services/interstitial_policy.dart';
import 'package:hockey_bro/services/settings_service.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  test('the puck waits during faceoff', () {
    final state = stepTable(const TableState(puckVy: -1), 0.5);
    expect(state.puckY, TableGeom.centerY);
    expect(state.phase, RinkPhase.faceoff);
  });

  test('the side wall sends the puck back', () {
    var state = const TableState(
      phase: RinkPhase.live,
      puckX: 0.3,
      puckY: 0.85,
      puckVx: -2,
    );
    for (var i = 0; i < 40 && state.puckVx < 0; i++) {
      state = stepTable(state, 1 / 60);
    }
    expect(state.phase, RinkPhase.live);
    expect(state.puckVx, greaterThan(0));
    expect(state.puckX, greaterThan(TableGeom.rail));
  });

  test('the top wall outside the goal bounces', () {
    var state = const TableState(
      phase: RinkPhase.live,
      puckX: 0.12,
      puckY: 0.25,
      puckVy: -2,
    );
    for (var i = 0; i < 20; i++) {
      state = stepTable(state, 1 / 60);
    }
    expect(state.phase, RinkPhase.live);
    expect(state.puckVy, greaterThan(0));
  });

  test('the top goal scores for red', () {
    var state = const TableState(
      phase: RinkPhase.live,
      puckX: 0.5,
      puckY: 0.2,
      puckVy: -2,
    );
    for (var i = 0; i < 40 && state.phase == RinkPhase.live; i++) {
      state = stepTable(state, 1 / 60);
    }
    expect(state.phase, RinkPhase.goal);
    expect(state.red, 1);
    expect(state.blue, 0);
  });

  test('a mallet stays in its half', () {
    final state = placeMallet(const TableState(), Side.red, 0.5, 0.2, 1 / 60);
    expect(state.redY, greaterThan(TableGeom.centerY));
  });

  test('a mallet slides toward a far tap and a short drag stays slow', () {
    const start = TableState(phase: RinkPhase.live);
    const dt = 1 / 60;
    const reach = 0.3;
    final rush = placeMallet(start, Side.red, start.redX, start.redY - reach, dt);
    final soft = placeMallet(start, Side.red, start.redX, start.redY - 0.02, dt);
    expect(rush.redY, greaterThan(start.redY - reach));
    expect(rush.redY, lessThan(start.redY));
    final rushSpeed = math.sqrt(rush.redVx * rush.redVx + rush.redVy * rush.redVy);
    final softSpeed = math.sqrt(soft.redVx * soft.redVx + soft.redVy * soft.redVy);
    expect(rushSpeed, closeTo(TableGeom.maxMalletSpeed, 0.05));
    expect(softSpeed, lessThan(2));
    var held = start;
    for (var i = 0; i < 30; i++) {
      held = placeMallet(held, Side.red, start.redX, start.redY - reach, dt);
    }
    expect(held.redY, closeTo(start.redY - reach, 0.02));
  });

  test('a light hit keeps the puck gliding', () {
    var state = const TableState(
      phase: RinkPhase.live,
      puckX: 0.5,
      puckY: TableGeom.centerY,
      puckVx: 0.05,
    );
    for (var i = 0; i < 180; i++) {
      state = stepTable(state, 1 / 60);
    }
    final speed = math.sqrt(state.puckVx * state.puckVx + state.puckVy * state.puckVy);
    expect(speed, greaterThanOrEqualTo(TableGeom.minSpeed * 0.98));
  });

  test('a mallet pushes the puck', () {
    var state = dropPuck(const TableState());
    state = state.copyWith(
      redX: TableGeom.centerX,
      redY: TableGeom.centerY + TableGeom.malletR * 0.3,
      redVy: -4,
    );
    state = stepTable(state, 1 / 60);
    expect(state.puckVy, lessThan(0));
    expect(state.puckY, lessThan(TableGeom.centerY));
  });

  test('seven goals end the match', () {
    expect(TableRules.goalsToWin, 7);
    final state = finishGoalBeat(
      const TableState(blue: 7, phase: RinkPhase.goal, lastScore: Side.blue),
    );
    expect(state.phase, RinkPhase.over);
    expect(winnerOf(state), Side.blue);
    expect(state.puckY, TableGeom.centerY);
  });

  test('a goal before the end returns to faceoff', () {
    final state = finishGoalBeat(
      const TableState(red: 1, phase: RinkPhase.goal, lastScore: Side.red),
    );
    expect(state.phase, RinkPhase.faceoff);
    expect(state.red, 1);
    expect(state.puckX, TableGeom.centerX);
  });

  test('a harder robot closes on the puck faster', () {
    const state = TableState(
      phase: RinkPhase.live,
      puckX: 0.2,
      puckY: 0.4,
      puckVy: -0.4,
    );
    final easy = Robot(Difficulty.easy, random: math.Random(1)).aim(state, 0.05);
    final hard = Robot(Difficulty.hard, random: math.Random(1)).aim(state, 0.05);
    expect(easy.$1, lessThan(TableGeom.centerX));
    expect(hard.$1, lessThan(easy.$1));
  });

  test('the hard bot strikes an open puck instead of sticking to it', () {
    final played = _playBot(Difficulty.hard, 1);
    expect(played.goals, 1, reason: 'open net, seed 1');
    expect(played.maxDownSpeed, greaterThan(1.4));
    expect(played.contactFraction, lessThan(0.2));
  });

  test('the hard bot hits a puck that is coming at it', () {
    final robot = Robot(Difficulty.hard, random: math.Random(2));
    var state = TableState(
      phase: RinkPhase.live,
      puckX: 0.48,
      puckY: TableGeom.centerY + 0.05,
      puckVy: -1.6,
      redX: 0.12,
      redY: TableGeom.redHomeY,
    );
    const dt = 1 / 60;
    var sentBack = false;
    for (var i = 0; i < 180 && state.phase == RinkPhase.live; i++) {
      final aim = robot.aim(state, dt);
      state = placeMallet(state, Side.blue, aim.$1, aim.$2, dt);
      state = placeMallet(state, Side.red, 0.12, TableGeom.redHomeY, dt);
      state = stepTable(state, dt);
      if (state.puckVy > 1.2) sentBack = true;
    }
    expect(state.red, 0, reason: 'does not let the puck sit in its own goal');
    expect(sentBack || state.blue > 0, isTrue);
  });

  test('easy misses more open shots than hard', () {
    var easyGoals = 0;
    var hardGoals = 0;
    for (var seed = 0; seed < 8; seed++) {
      if (_playBot(Difficulty.easy, seed).goals > 0) easyGoals++;
      if (_playBot(Difficulty.hard, seed).goals > 0) hardGoals++;
    }
    expect(hardGoals, greaterThan(easyGoals));
    expect(hardGoals, greaterThan(4));
  });

  test('the first finished match skips the interstitial', () {
    final policy = InterstitialPolicy();
    final start = DateTime(2026);
    policy.onMatchFinished();
    expect(policy.shouldShow(start), isFalse);
    policy.onMatchFinished();
    expect(policy.shouldShow(start), isTrue);
    policy.onShown(start);
    policy.onMatchFinished();
    expect(policy.shouldShow(start.add(const Duration(seconds: 10))), isFalse);
    expect(policy.shouldShow(start.add(AdRules.minInterstitialGap)), isTrue);
  });

  testWidgets('home shows play and the ad slot', (tester) async {
    SharedPreferences.setMockInitialValues({
      PrefsKeys.onboardingDone: true,
      PrefsKeys.language: 'en',
    });
    final settings = SettingsService(await SharedPreferences.getInstance());
    final audio = AudioService();
    await audio.init(enabled: false);
    await tester.pumpWidget(
      HockeyBroApp(
        services: AppServices(
          settings: settings,
          audio: audio,
          ads: AdService.instance,
        ),
      ),
    );
    await tester.pump();
    expect(find.text('HOCKEY'), findsWidgets);
    expect(find.text('BRO'), findsWidgets);
    expect(find.text('One Phone. Two Bros. One Winner.'), findsOneWidget);
    expect(find.text('1 Player'), findsOneWidget);
    expect(find.text('2 Players'), findsOneWidget);
    expect(find.text('Settings'), findsOneWidget);
    expect(find.text('How to play'), findsOneWidget);
    expect(find.text('Ad'), findsOneWidget);
    expect(find.text('Skip'), findsNothing);
  });
}

class _BotPlay {
  const _BotPlay({
    required this.goals,
    required this.maxDownSpeed,
    required this.contactFraction,
  });

  final int goals;
  final double maxDownSpeed;
  final double contactFraction;
}

/// Open net: puck sits in the bot's half, the human mallet waits in the corner.
_BotPlay _playBot(Difficulty difficulty, int seed) {
  final robot = Robot(difficulty, random: math.Random(seed));
  var state = TableState(
    phase: RinkPhase.live,
    puckX: TableGeom.centerX,
    puckY: TableGeom.centerY - 0.28,
    redX: 0.12,
    redY: TableGeom.redHomeY,
  );
  const dt = 1 / 60;
  const touch = TableGeom.malletR + TableGeom.puckR;
  var frames = 0;
  var contacts = 0;
  var maxDown = 0.0;
  for (var i = 0; i < 240 && state.phase == RinkPhase.live; i++) {
    final aim = robot.aim(state, dt);
    state = placeMallet(state, Side.blue, aim.$1, aim.$2, dt);
    state = placeMallet(state, Side.red, 0.12, TableGeom.redHomeY, dt);
    final dx = state.puckX - state.blueX;
    final dy = state.puckY - state.blueY;
    if (math.sqrt(dx * dx + dy * dy) < touch) contacts++;
    state = stepTable(state, dt);
    frames++;
    if (state.puckVy > maxDown) maxDown = state.puckVy;
  }
  return _BotPlay(
    goals: state.blue,
    maxDownSpeed: maxDown,
    contactFraction: frames == 0 ? 1 : contacts / frames,
  );
}
