// Play Store phone screenshots, 1080x1920 (360x640 @3x), one folder per
// language, into build/store/<lang>/. Off by default; run with:
//   flutter test test/capture/store_capture_test.dart --dart-define=CAPTURE=true
//
// CJK languages are skipped: tests have no CJK fallback font (phones do).
import 'dart:io';
import 'dart:ui' as ui;

import 'package:hockey_bro/engine/robot.dart';
import 'package:hockey_bro/engine/table.dart';
import 'package:hockey_bro/screens/home_screen.dart';
import 'package:hockey_bro/screens/match_screen.dart';
import 'package:hockey_bro/screens/settings_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';

import '../support/fonts.dart';
import '../support/harness.dart';

const bool _capture = bool.fromEnvironment('CAPTURE');
const _languages = ['tr', 'en', 'de', 'es', 'pt', 'fr', 'it'];

void main() {
  setUpAll(() async {
    if (_capture) await loadAppFonts();
  });

  final shots = <String, (Widget, Duration)>{
    '1_home': (
      const HomeScreen(storeShot: true),
      const Duration(milliseconds: 50),
    ),
    '2_game_2p': (
      const MatchScreen(
        initialState: TableState(
          blue: 3,
          red: 4,
          phase: RinkPhase.live,
          puckX: 0.36,
          puckY: 0.98,
          puckVx: -1.2,
          puckVy: 1.6,
          blueX: 0.3,
          blueY: 0.46,
          redX: 0.6,
          redY: 1.42,
        ),
      ),
      const Duration(milliseconds: 16),
    ),
    '3_goal': (
      const MatchScreen(
        initialState: TableState(
          blue: 2,
          red: 5,
          phase: RinkPhase.goal,
          lastScore: Side.red,
        ),
      ),
      const Duration(milliseconds: 200),
    ),
    '4_match_end': (
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
    '5_vs_bot': (
      const MatchScreen(
        difficulty: Difficulty.hard,
        initialState: TableState(
          blue: 2,
          red: 3,
          phase: RinkPhase.live,
          puckX: 0.64,
          puckY: 0.72,
          puckVx: 0.5,
          puckVy: -1.9,
          redX: 0.42,
          redY: 1.3,
        ),
      ),
      const Duration(milliseconds: 16),
    ),
    '6_settings': (const SettingsScreen(), const Duration(milliseconds: 50)),
  };

  for (final language in _languages) {
    for (final shot in shots.entries) {
      testWidgets('store $language ${shot.key}', (tester) async {
        useScreen(tester, const Size(360, 640));
        final key = GlobalKey();
        await tester.pumpWidget(
          harness(
            await testServices(language: language),
            shot.value.$1,
            key: key,
          ),
        );
        await tester.pump(shot.value.$2);
        await tester.pump(const Duration(milliseconds: 250));
        await tester.pump();
        await tester.runAsync(() async {
          final boundary =
              key.currentContext!.findRenderObject()! as RenderRepaintBoundary;
          final image = await boundary.toImage(pixelRatio: 3);
          final data = await image.toByteData(format: ui.ImageByteFormat.png);
          final out = File('build/store/$language/${shot.key}.png')
            ..createSync(recursive: true);
          out.writeAsBytesSync(data!.buffer.asUint8List());
        });
        await unmount(tester);
      }, skip: !_capture);
    }
  }
}
