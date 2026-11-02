import 'package:faceoff/analytics/analytics_events.dart';
import 'package:faceoff/analytics/analytics_service.dart';
import 'package:faceoff/analytics/analytics_sink.dart';
import 'package:faceoff/analytics/match_analytics.dart';
import 'package:faceoff/engine/robot.dart';
import 'package:faceoff/engine/table.dart';
import 'package:faceoff/screens/home_screen.dart';
import 'package:faceoff/screens/match_screen.dart';
import 'package:faceoff/services/settings_service.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../support/harness.dart';

class RecordedEvent {
  RecordedEvent(this.name, this.params);
  final String name;
  final Map<String, Object> params;
  @override
  String toString() => '$name $params';
}

class FakeSink implements AnalyticsSink {
  final events = <RecordedEvent>[];
  String? userId;
  final props = <String, String>{};
  bool fail = false;

  @override
  Future<void> logEvent(String name, Map<String, Object> params) async {
    if (fail) throw StateError('network down');
    events.add(RecordedEvent(name, params));
  }

  @override
  Future<void> setUserId(String id) async => userId = id;

  @override
  Future<void> setUserProperty(String name, String value) async =>
      props[name] = value;

  List<String> get names => events.map((e) => e.name).toList();
  List<RecordedEvent> named(String name) =>
      events.where((e) => e.name == name).toList();
}

class FakeStopwatch implements Stopwatch {
  int ms = 0;
  bool running = false;
  @override
  int get elapsedMilliseconds => ms;
  @override
  int get elapsedMicroseconds => ms * 1000;
  @override
  int get elapsedTicks => ms * 1000;
  @override
  Duration get elapsed => Duration(milliseconds: ms);
  @override
  int get frequency => 1000000;
  @override
  bool get isRunning => running;
  @override
  void reset() => ms = 0;
  @override
  void start() => running = true;
  @override
  void stop() => running = false;
  void advance(int by) {
    if (running) ms += by;
  }
}

/// Sends run on a later event-loop turn.
Future<void> _drain() async {
  for (var i = 0; i < 5; i++) {
    await Future<void>.delayed(Duration.zero);
  }
}

void main() {
  setUp(() => SharedPreferences.setMockInitialValues(<String, Object>{}));
  tearDown(AnalyticsService.debugResetInstance);

  group('without Firebase config', () {
    test('start never throws, stays disabled, every log is a no-op', () async {
      final prefs = await SharedPreferences.getInstance();
      final service = AnalyticsService();
      await service.start(
        prefs,
        connect: () async => throw StateError('no google-services.json'),
      );
      expect(service.isEnabled, isFalse);
      expect(service.deviceId, isNotNull);
      expect(service.openCount, 1);
      service.logEvent(AnalyticsEvents.matchStart, {'x': 1});
      service.logSettingsOpen();
      service.logHowToPlayOpen(source: AnalyticsValues.sourceHome);
      service.logSettingsChange(AnalyticsValues.settingMusic, 'off');
      expect(service.nextMatchNumber(), 1);
      final tracker = MatchAnalytics(difficulty: null, service: service);
      tracker.matchStarted(trigger: AnalyticsValues.triggerNew);
      tracker.goal(const TableState(red: 1, lastScore: Side.red));
      tracker.matchEnded(
        const TableState(red: 7, phase: RinkPhase.over, lastScore: Side.red),
      );
      tracker.endChoice(AnalyticsValues.choiceMenu);
      await _drain();
    });

    test('logs before start (not ready) are dropped, not queued', () async {
      final prefs = await SharedPreferences.getInstance();
      final sink = FakeSink();
      final service = AnalyticsService();
      service.logEvent(AnalyticsEvents.settingsOpen, {'source': 'home'});
      await service.start(prefs, connect: () async => sink);
      await _drain();
      expect(sink.names, [AnalyticsEvents.appOpen]);
    });

    test('a failing send is swallowed and not retried', () async {
      final sink = FakeSink()..fail = true;
      final service = AnalyticsService(sink);
      expect(() => service.logEvent('match_start', {'a': 1}), returnsNormally);
      await _drain();
      sink.fail = false;
      await _drain();
      expect(sink.events, isEmpty);
    });

    testWidgets('screens and a full match run with no Firebase at all', (
      tester,
    ) async {
      useScreen(tester);
      final services = await testServices();
      await tester.pumpWidget(harness(services, const HomeScreen()));
      await tester.pump();
      await tester.tap(find.text('Ayarlar'));
      await tester.pump(const Duration(milliseconds: 400));
      await tester.pumpWidget(const SizedBox());
      await tester.pumpWidget(
        harness(services, const MatchScreen(difficulty: Difficulty.normal)),
      );
      await tester.pump(const Duration(milliseconds: 900));
      await tester.tap(find.bySemanticsLabel('Durdur'));
      await tester.pump(const Duration(milliseconds: 50));
      await tester.tap(find.text('Yeniden').last);
      await tester.pump(const Duration(milliseconds: 50));
      await tester.pumpWidget(const SizedBox());
      await tester.pumpWidget(
        harness(
          services,
          const MatchScreen(
            initialState: TableState(red: 7, phase: RinkPhase.over),
          ),
        ),
      );
      await tester.pump(const Duration(milliseconds: 900));
      await tester.tap(find.text('Tekrar oyna').last);
      await tester.pump(const Duration(milliseconds: 50));
      expect(tester.takeException(), isNull);
      await unmount(tester);
    });
  });

  test('app_open sets an anonymous UUID user id and counts opens', () async {
    final prefs = await SharedPreferences.getInstance();
    final sink = FakeSink();
    final first = AnalyticsService();
    await first.start(prefs, connect: () async => sink);
    await _drain();
    final id = first.deviceId!;
    expect(
      id,
      matches(
        RegExp(
          r'^[0-9a-f]{8}-[0-9a-f]{4}-4[0-9a-f]{3}-[89ab][0-9a-f]{3}-[0-9a-f]{12}$',
        ),
      ),
    );
    expect(sink.userId, id);
    expect(sink.props[AnalyticsUserProps.deviceId], id);
    expect(sink.events.single.params, {'device_id': id, 'open_count': 1});

    final sink2 = FakeSink();
    final second = AnalyticsService();
    await second.start(prefs, connect: () async => sink2);
    await _drain();
    expect(second.deviceId, id);
    expect(sink2.events.single.params['open_count'], 2);
  });

  test('sanitizer enforces GA4 limits', () {
    final out = AnalyticsService.sanitizeParams({
      'a' * 50: 'v',
      'nullable': null,
      'flag': true,
      'long': 'x' * 150,
      for (var i = 0; i < 30; i++) 'p$i': i,
    });
    expect(out.length, AnalyticsLimits.maxParams);
    expect(out.containsKey('a' * 40), isTrue);
    expect(out.containsKey('nullable'), isFalse);
    expect(out['flag'], 1);
    expect((out['long']! as String).length, 100);
  });

  test('event names are GA4-safe', () {
    const names = [
      AnalyticsEvents.appOpen,
      AnalyticsEvents.matchStart,
      AnalyticsEvents.goal,
      AnalyticsEvents.matchEnd,
      AnalyticsEvents.matchQuit,
      AnalyticsEvents.matchEndChoice,
      AnalyticsEvents.pauseOpen,
      AnalyticsEvents.settingsOpen,
      AnalyticsEvents.howToPlayOpen,
      AnalyticsEvents.settingsChange,
    ];
    for (final n in names) {
      expect(n, matches(RegExp(r'^[a-z][a-z0-9_]{0,39}$')));
    }
  });

  group('match sequence (tracker)', () {
    test(
      'vs bot: start, goals, pause, end once, choice; clock skips pauses',
      () async {
        final sink = FakeSink();
        final clock = FakeStopwatch();
        final tracker = MatchAnalytics(
          difficulty: Difficulty.hard,
          service: AnalyticsService(sink),
          clock: clock,
        );
        tracker.matchStarted(trigger: AnalyticsValues.triggerNew);
        clock.advance(20000);
        tracker.goal(const TableState(red: 1, lastScore: Side.red));
        tracker.paused(
          const TableState(red: 1),
          source: AnalyticsValues.sourceButton,
        );
        clock.advance(60000); // paused: not counted
        tracker.resumed();
        clock.advance(41600);
        tracker.goal(const TableState(red: 1, blue: 1, lastScore: Side.blue));
        const end = TableState(
          red: 7,
          blue: 3,
          phase: RinkPhase.over,
          lastScore: Side.red,
        );
        tracker.matchEnded(end);
        tracker.matchEnded(end); // no duplicate
        tracker.goal(end); // after the end: ignored
        tracker.endChoice(AnalyticsValues.choiceRematch);
        await _drain();

        expect(sink.names, [
          'match_start',
          'goal',
          'pause_open',
          'goal',
          'match_end',
          'match_end_choice',
        ]);
        expect(sink.events[0].params, {
          'match_number': 1,
          'trigger': 'new',
          'win_score': 7,
          'mode': '1p',
          'difficulty': 'hard',
        });
        expect(sink.events[1].params, {
          'match_number': 1,
          'scorer': 'p1',
          'score_p1': 1,
          'score_p2': 0,
          'mode': '1p',
          'difficulty': 'hard',
        });
        expect(sink.events[2].params['source'], 'button');
        expect(sink.events[3].params['scorer'], 'p2');
        expect(sink.named('match_end').single.params, {
          'match_number': 1,
          'winner': 'p1',
          'score': '7-3',
          'goals_p1': 7,
          'goals_p2': 3,
          'duration_s': 62,
          'win_score': 7,
          'mode': '1p',
          'difficulty': 'hard',
        });
        expect(sink.events.last.params, {
          'match_number': 1,
          'choice': 'rematch',
          'mode': '1p',
          'difficulty': 'hard',
        });
      },
    );

    test('2p quit: match_quit once, no match_end, no difficulty', () async {
      final sink = FakeSink();
      final tracker = MatchAnalytics(
        difficulty: null,
        service: AnalyticsService(sink),
      );
      tracker.matchStarted(trigger: AnalyticsValues.triggerNew);
      tracker.matchQuit(
        const TableState(red: 2, blue: 4),
        from: AnalyticsValues.fromMenu,
      );
      tracker.matchQuit(
        const TableState(red: 2, blue: 4),
        from: AnalyticsValues.fromBack,
      );
      tracker.matchEnded(const TableState(blue: 7, phase: RinkPhase.over));
      await _drain();
      expect(sink.names, ['match_start', 'match_quit']);
      final quit = sink.events[1].params;
      expect(quit['from'], 'menu');
      expect(quit['score'], '2-4');
      expect(quit['mode'], '2p');
      expect(quit.containsKey('difficulty'), isFalse);
    });

    test('match_number counts per device across matches', () async {
      SharedPreferences.setMockInitialValues({
        AnalyticsService.prefsMatchCount: 4,
      });
      final prefs = await SharedPreferences.getInstance();
      final sink = FakeSink();
      final service = AnalyticsService();
      await service.start(prefs, connect: () async => sink);
      final tracker = MatchAnalytics(difficulty: null, service: service);
      tracker.matchStarted(trigger: AnalyticsValues.triggerNew);
      tracker.matchStarted(trigger: AnalyticsValues.triggerRematch);
      await _drain();
      expect(sink.named('match_start').map((e) => e.params['match_number']), [
        5,
        6,
      ]);
      expect(prefs.getInt(AnalyticsService.prefsMatchCount), 6);
    });
  });

  group('wired into the screens', () {
    late FakeSink sink;
    setUp(() {
      sink = FakeSink();
      AnalyticsService.debugSetInstance(AnalyticsService(sink));
    });

    testWidgets(
      'pause → Yeniden: pause_open, match_quit(restart), match_start(restart)',
      (tester) async {
        useScreen(tester);
        await tester.pumpWidget(
          harness(
            await testServices(),
            const MatchScreen(difficulty: Difficulty.easy),
          ),
        );
        await tester.pump(const Duration(milliseconds: 100));
        await tester.tap(find.bySemanticsLabel('Durdur'));
        await tester.pump(const Duration(milliseconds: 50));
        await tester.tap(find.text('Yeniden').last);
        await tester.pump(const Duration(milliseconds: 50));
        expect(sink.names, [
          'match_start',
          'pause_open',
          'match_quit',
          'match_start',
        ]);
        expect(sink.events[0].params['trigger'], 'new');
        expect(sink.events[0].params['difficulty'], 'easy');
        expect(sink.events[2].params['from'], 'restart');
        expect(sink.events[3].params['trigger'], 'restart');
        expect(sink.events[3].params['match_number'], 2);
        await unmount(tester);
      },
    );

    testWidgets('a real goal fires one goal event', (tester) async {
      useScreen(tester);
      await tester.pumpWidget(
        harness(
          await testServices(),
          const MatchScreen(
            initialState: TableState(
              phase: RinkPhase.live,
              puckX: 0.5,
              puckY: 1.55,
              puckVy: 3,
              redX: 0.2,
              redY: 1.2,
            ),
          ),
        ),
      );
      for (var i = 0; i < 20; i++) {
        await tester.pump(const Duration(milliseconds: 16));
      }
      final goals = sink.named('goal');
      expect(goals, hasLength(1));
      expect(goals.single.params['scorer'], 'p2');
      expect(goals.single.params['score_p2'], 1);
      expect(goals.single.params['mode'], '2p');
      await unmount(tester);
    });

    testWidgets('end card: match_end when shown, then rematch choice', (
      tester,
    ) async {
      useScreen(tester);
      await tester.pumpWidget(
        harness(
          await testServices(),
          const MatchScreen(
            initialState: TableState(
              blue: 4,
              red: 7,
              phase: RinkPhase.over,
              lastScore: Side.red,
            ),
          ),
        ),
      );
      await tester.pump(const Duration(milliseconds: 900));
      expect(sink.names, ['match_start', 'match_end']);
      expect(sink.events[1].params['winner'], 'p1');
      expect(sink.events[1].params['score'], '7-4');
      await tester.tap(find.text('Tekrar oyna').last);
      await tester.pump(const Duration(milliseconds: 50));
      expect(sink.names.skip(2), ['match_end_choice', 'match_start']);
      expect(sink.events[2].params['choice'], 'rematch');
      expect(sink.events[3].params['trigger'], 'rematch');
      await unmount(tester);
    });

    testWidgets('home: settings_open; settings_change only on real changes', (
      tester,
    ) async {
      useScreen(tester);
      final services = await testServices();
      await tester.pumpWidget(harness(services, const HomeScreen()));
      await tester.pump();
      await tester.tap(find.text('Orta')); // already Orta: no change
      await tester.tap(find.text('Zor'));
      await tester.pump();
      await tester.tap(find.text('Ayarlar'));
      await tester.pump(const Duration(milliseconds: 400));
      final settings = services.settings;
      await settings.setMusic(settings.music); // unchanged
      await settings.setHaptics(!settings.haptics);
      await settings.setLanguage('tr'); // unchanged
      await tester.pump(const Duration(milliseconds: 50));
      expect(sink.names, [
        'settings_change',
        'settings_open',
        'settings_change',
      ]);
      expect(sink.events[0].params, {'setting': 'difficulty', 'value': 'hard'});
      expect(sink.events[1].params, {'source': 'home'});
      expect(sink.events[2].params, {'setting': 'haptics', 'value': 'off'});
      await unmount(tester);
    });

    testWidgets('how to play from home', (tester) async {
      useScreen(tester);
      await tester.pumpWidget(
        harness(await testServices(), const HomeScreen()),
      );
      await tester.pump();
      await tester.tap(find.text('Nasıl oynanır'));
      await tester.pump(const Duration(milliseconds: 400));
      expect(sink.names, ['how_to_play_open']);
      expect(sink.events.single.params, {'source': 'home'});
      await unmount(tester);
    });
  });

  test('settings service is importable without Firebase', () {
    expect(SettingsService.supportedLanguages, contains('tr'));
  });
}
