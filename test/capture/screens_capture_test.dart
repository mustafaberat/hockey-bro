// Renders every screen at 320x568 with the real fonts into build/screens/.
// Off by default; run with:
//   flutter test test/capture --dart-define=CAPTURE=true
import 'dart:io';
import 'dart:ui' as ui;

import 'package:hockey_bro/engine/robot.dart';
import 'package:hockey_bro/engine/table.dart';
import 'package:hockey_bro/screens/home_screen.dart';
import 'package:hockey_bro/screens/how_to_play_screen.dart';
import 'package:hockey_bro/screens/match_screen.dart';
import 'package:hockey_bro/screens/settings_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';

import '../support/fonts.dart';
import '../support/harness.dart';

const bool _capture = bool.fromEnvironment('CAPTURE');

void main() {
  setUpAll(() async {
    if (_capture) await loadAppFonts();
  });

  final shots = <String, (Widget, Duration)>{
    '1_home': (const HomeScreen(), const Duration(milliseconds: 50)),
    '2_game_2p': (
      const MatchScreen(
        initialState: TableState(
          blue: 3,
          red: 2,
          phase: RinkPhase.live,
          puckX: 0.38,
          puckY: 1.0,
          puckVx: -1.2,
          puckVy: 1.6,
          blueX: 0.32,
          blueY: 0.48,
          redX: 0.58,
          redY: 1.42,
        ),
      ),
      const Duration(milliseconds: 16),
    ),
    '2b_game_bot': (
      const MatchScreen(
        difficulty: Difficulty.normal,
        initialState: TableState(
          blue: 3,
          red: 2,
          phase: RinkPhase.live,
          puckX: 0.62,
          puckY: 0.7,
          puckVx: 0.4,
          puckVy: -1.8,
        ),
      ),
      const Duration(milliseconds: 16),
    ),
    '3_goal': (
      const MatchScreen(
        initialState: TableState(
          blue: 2,
          red: 4,
          phase: RinkPhase.goal,
          lastScore: Side.red,
        ),
      ),
      const Duration(milliseconds: 200),
    ),
    '4_pause': (
      const MatchScreen(
        startPaused: true,
        initialState: TableState(blue: 3, red: 2),
      ),
      const Duration(milliseconds: 60),
    ),
    '5_match_end': (
      const MatchScreen(
        initialState: TableState(
          blue: 4,
          red: 7,
          phase: RinkPhase.over,
          lastScore: Side.red,
        ),
      ),
      const Duration(milliseconds: 1000),
    ),
    '5b_match_end_bot': (
      const MatchScreen(
        difficulty: Difficulty.hard,
        initialState: TableState(
          blue: 7,
          red: 5,
          phase: RinkPhase.over,
          lastScore: Side.blue,
        ),
      ),
      const Duration(milliseconds: 1000),
    ),
    '6_settings': (const SettingsScreen(), const Duration(milliseconds: 50)),
    '7_how_to_play': (
      const HowToPlayScreen(firstRun: true),
      const Duration(milliseconds: 650),
    ),
  };

  for (final shot in shots.entries) {
    testWidgets('capture ${shot.key}', (tester) async {
      useScreen(tester);
      final key = GlobalKey();
      await tester.pumpWidget(
        harness(await testServices(), shot.value.$1, key: key),
      );
      await tester.pump(shot.value.$2);
      // Let implicit animations (button unlock fade etc.) finish.
      await tester.pump(const Duration(milliseconds: 250));
      await tester.pump();
      await tester.runAsync(() async {
        final boundary =
            key.currentContext!.findRenderObject()! as RenderRepaintBoundary;
        final image = await boundary.toImage(pixelRatio: 2);
        final data = await image.toByteData(format: ui.ImageByteFormat.png);
        final out = File('build/screens/${shot.key}_320x568.png')
          ..createSync(recursive: true);
        out.writeAsBytesSync(data!.buffer.asUint8List());
      });
      await unmount(tester);
    }, skip: !_capture);
  }
}
