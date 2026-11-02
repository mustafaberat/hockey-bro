import 'package:faceoff/engine/robot.dart';
import 'package:faceoff/engine/table.dart';
import 'package:faceoff/screens/about_screen.dart';
import 'package:faceoff/screens/home_screen.dart';
import 'package:faceoff/screens/how_to_play_screen.dart';
import 'package:faceoff/screens/match_screen.dart';
import 'package:faceoff/screens/settings_screen.dart';
import 'package:faceoff/services/settings_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'support/harness.dart';

const _goal = TableState(
  blue: 2,
  red: 4,
  phase: RinkPhase.goal,
  lastScore: Side.red,
);
const _over = TableState(
  blue: 4,
  red: 7,
  phase: RinkPhase.over,
  lastScore: Side.red,
);

void main() {
  // Any RenderFlex overflow fails these tests, so "pumps cleanly at 320x568"
  // means "fits the smallest phone".
  for (final language in SettingsService.supportedLanguages) {
    testWidgets('home fits 320x568 ($language)', (tester) async {
      useScreen(tester);
      await tester.pumpWidget(
        harness(await testServices(language: language), const HomeScreen()),
      );
      await tester.pump();
      expect(tester.takeException(), isNull);
      await unmount(tester);
    });
  }

  testWidgets('home shows the arcade menu in Turkish', (tester) async {
    useScreen(tester);
    await tester.pumpWidget(harness(await testServices(), const HomeScreen()));
    await tester.pump();
    for (final text in ['HOKEY', 'DÜELLOSU']) {
      expect(find.text(text), findsWidgets);
    }
    for (final text in [
      '1 Oyuncu',
      'Bota karşı',
      'Kolay',
      'Orta',
      'Zor',
      '2 Oyuncu',
      'Ayarlar',
      'Nasıl oynanır',
    ]) {
      expect(find.text(text), findsOneWidget, reason: text);
    }
    await tester.tap(find.text('Zor'));
    await tester.pump();
    final context = tester.element(find.byType(HomeScreen));
    expect(context.mounted, isTrue);
    await unmount(tester);
  });

  for (final difficulty in [null, Difficulty.normal]) {
    final mode = difficulty == null ? '2P' : 'bot';
    testWidgets('match fits and pauses ($mode)', (tester) async {
      useScreen(tester);
      await tester.pumpWidget(
        harness(await testServices(), MatchScreen(difficulty: difficulty)),
      );
      await tester.pump(const Duration(milliseconds: 800));
      expect(find.text('0'), findsNWidgets(2));
      if (difficulty != null) {
        expect(find.text('BOT · ORTA'), findsOneWidget);
        expect(find.text('SEN'), findsOneWidget);
      }
      await tester.tap(find.bySemanticsLabel('Durdur'));
      await tester.pump(const Duration(milliseconds: 50));
      // Outlined titles draw the text twice per card.
      expect(
        find.text('Duraklatıldı'),
        findsNWidgets(difficulty == null ? 4 : 2),
      );
      expect(find.text('Devam et'), findsNWidgets(difficulty == null ? 2 : 1));
      await tester.tap(find.text('Devam et').last);
      await tester.pump(const Duration(milliseconds: 50));
      expect(find.text('Duraklatıldı'), findsNothing);
      expect(tester.takeException(), isNull);
      await unmount(tester);
    });

    testWidgets('goal burst plays and clears ($mode)', (tester) async {
      useScreen(tester);
      await tester.pumpWidget(
        harness(
          await testServices(),
          MatchScreen(difficulty: difficulty, initialState: _goal),
        ),
      );
      await tester.pump(const Duration(milliseconds: 300));
      expect(find.text('GOL!'), findsNWidgets(difficulty == null ? 4 : 2));
      await tester.pump(TableRules.goalHold);
      await tester.pump(const Duration(milliseconds: 50));
      expect(find.text('GOL!'), findsNothing);
      expect(find.text('4'), findsOneWidget);
      expect(tester.takeException(), isNull);
      await unmount(tester);
    });

    testWidgets('match end locks buttons for 800ms ($mode)', (tester) async {
      useScreen(tester);
      await tester.pumpWidget(
        harness(
          await testServices(),
          MatchScreen(difficulty: difficulty, initialState: _over),
        ),
      );
      await tester.pump(const Duration(milliseconds: 100));
      expect(find.text('KAZANDIN!'), findsNWidgets(2));
      expect(find.text('Az kaldı!'), findsNWidgets(difficulty == null ? 2 : 0));
      await tester.tap(find.text('Tekrar oyna').last, warnIfMissed: false);
      await tester.pump(const Duration(milliseconds: 100));
      expect(
        find.text('KAZANDIN!'),
        findsNWidgets(2),
        reason: 'early tap must be ignored',
      );
      await tester.pump(const Duration(milliseconds: 700));
      await tester.tap(find.text('Tekrar oyna').last);
      await tester.pump(const Duration(milliseconds: 50));
      expect(find.text('KAZANDIN!'), findsNothing);
      expect(find.text('0'), findsNWidgets(2));
      await unmount(tester);
    });
  }

  for (final language in ['tr', 'de', 'en']) {
    testWidgets('overlays fit 320x568 ($language)', (tester) async {
      useScreen(tester);
      final services = await testServices(language: language);
      for (final state in [_goal, _over]) {
        await tester.pumpWidget(
          harness(services, MatchScreen(key: UniqueKey(), initialState: state)),
        );
        await tester.pump(const Duration(milliseconds: 400));
        expect(tester.takeException(), isNull);
      }
      await tester.pumpWidget(
        harness(services, MatchScreen(key: UniqueKey(), startPaused: true)),
      );
      await tester.pump(const Duration(milliseconds: 100));
      expect(tester.takeException(), isNull);
      await unmount(tester);
    });
  }

  for (final page in <String, Widget>{
    'settings': const SettingsScreen(),
    'how to play': const HowToPlayScreen(firstRun: true),
    'about': const AboutScreen(),
  }.entries) {
    testWidgets('${page.key} fits 320x568', (tester) async {
      useScreen(tester);
      await tester.pumpWidget(harness(await testServices(), page.value));
      await tester.pump(const Duration(milliseconds: 100));
      expect(tester.takeException(), isNull);
      await unmount(tester);
    });
  }
}
