import 'package:faceoff/app.dart';
import 'package:faceoff/app_scope.dart';
import 'package:faceoff/config/app_config.dart';
import 'package:faceoff/engine/robot.dart';
import 'package:faceoff/engine/table.dart';
import 'package:faceoff/services/ad_service.dart';
import 'package:faceoff/services/audio_service.dart';
import 'package:faceoff/services/interstitial_policy.dart';
import 'package:faceoff/services/settings_service.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  test('the puck waits during faceoff', () {
    final state = stepTable(const TableState(puckVy: -1), 0.5);
    expect(state.puckY, TableGeom.centerY);
    expect(state.phase, RinkPhase.faceoff);
  });

  test('the side wall sends the puck back', () {
    var state = const TableState(phase: RinkPhase.live, puckX: 0.3, puckY: 0.85, puckVx: -2);
    for (var i = 0; i < 40 && state.puckVx < 0; i++) {
      state = stepTable(state, 1 / 60);
    }
    expect(state.phase, RinkPhase.live);
    expect(state.puckVx, greaterThan(0));
    expect(state.puckX, greaterThan(TableGeom.rail));
  });

  test('the top wall outside the goal bounces', () {
    var state = const TableState(phase: RinkPhase.live, puckX: 0.12, puckY: 0.25, puckVy: -2);
    for (var i = 0; i < 20; i++) {
      state = stepTable(state, 1 / 60);
    }
    expect(state.phase, RinkPhase.live);
    expect(state.puckVy, greaterThan(0));
  });

  test('the top goal scores for red', () {
    var state = const TableState(phase: RinkPhase.live, puckX: 0.5, puckY: 0.2, puckVy: -2);
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

  test('three goals end the match', () {
    final state = finishGoalBeat(
      const TableState(blue: 3, phase: RinkPhase.goal, lastScore: Side.blue),
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
    final easy = robotAim(state, Difficulty.easy, 0.05);
    final hard = robotAim(state, Difficulty.hard, 0.05);
    expect(easy.$1, lessThan(TableGeom.centerX));
    expect(hard.$1, lessThan(easy.$1));
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
      FaceoffApp(
        services: AppServices(settings: settings, audio: audio, ads: AdService.instance),
      ),
    );
    await tester.pump();
    expect(find.text('1 player'), findsOneWidget);
    expect(find.text('2 players'), findsOneWidget);
    expect(find.text('Settings'), findsOneWidget);
    expect(find.text('About'), findsOneWidget);
    expect(find.text('Ad'), findsOneWidget);
    expect(find.text('Skip'), findsNothing);
  });
}
