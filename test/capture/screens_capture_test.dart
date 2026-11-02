// Renders every screen at 320x568 with the real fonts into build/screens/.
// Off by default; run with:
//   flutter test test/capture --dart-define=CAPTURE=true
import 'dart:io';
import 'dart:ui' as ui;

import 'package:faceoff/engine/robot.dart';
import 'package:faceoff/engine/table.dart';
import 'package:faceoff/screens/home_screen.dart';
import 'package:faceoff/screens/how_to_play_screen.dart';
import 'package:faceoff/screens/match_screen.dart';
import 'package:faceoff/screens/settings_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

import '../support/harness.dart';

const bool _capture = bool.fromEnvironment('CAPTURE');

Future<void> _loadFont(String family, List<String> files) async {
  final loader = FontLoader(family);
  for (final file in files) {
    final bytes = File(file).readAsBytesSync();
    loader.addFont(Future.value(ByteData.view(bytes.buffer)));
  }
  await loader.load();
}

String? _materialIcons() {
  var dir = File(Platform.resolvedExecutable).parent;
  for (var i = 0; i < 8; i++) {
    final f = File(
      '${dir.path}/artifacts/material_fonts/MaterialIcons-Regular.otf',
    );
    if (f.existsSync()) return f.path;
    final g = File(
      '${dir.path}/cache/artifacts/material_fonts/MaterialIcons-Regular.otf',
    );
    if (g.existsSync()) return g.path;
    dir = dir.parent;
  }
  return null;
}

void main() {
  setUpAll(() async {
    if (!_capture) return;
    await _loadFont('Baloo2', [
      'assets/fonts/Baloo2-Bold.ttf',
      'assets/fonts/Baloo2-ExtraBold.ttf',
    ]);
    await _loadFont('Nunito', [
      'assets/fonts/Nunito-SemiBold.ttf',
      'assets/fonts/Nunito-Bold.ttf',
    ]);
    final icons = _materialIcons();
    if (icons != null) await _loadFont('MaterialIcons', [icons]);
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
