import 'package:faceoff/app.dart';
import 'package:faceoff/app_scope.dart';
import 'package:faceoff/config/app_config.dart';
import 'package:faceoff/l10n/app_localizations.dart';
import 'package:faceoff/services/ad_service.dart';
import 'package:faceoff/services/audio_service.dart';
import 'package:faceoff/services/settings_service.dart';
import 'package:faceoff/theme/game_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Smallest phone we support.
const Size smallPhone = Size(320, 568);

void useScreen(WidgetTester tester, [Size size = smallPhone]) {
  tester.view.physicalSize = size;
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);
}

Future<AppServices> testServices({String language = 'tr'}) async {
  SharedPreferences.setMockInitialValues({
    PrefsKeys.onboardingDone: true,
    PrefsKeys.language: language,
  });
  final settings = SettingsService(await SharedPreferences.getInstance());
  final audio = AudioService();
  await audio.init(enabled: false);
  return AppServices(settings: settings, audio: audio, ads: AdService.instance);
}

Widget harness(AppServices services, Widget home, {Key? key}) {
  return RepaintBoundary(
    key: key,
    child: MaterialApp(
      debugShowCheckedModeBanner: false,
      locale: services.settings.locale,
      supportedLocales: AppLocalizations.supportedLocales,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      theme: buildMaterialTheme(GameThemes.arcade),
      builder: (context, child) => GameThemeScope(
        theme: GameThemes.arcade,
        child: AppScope(services: services, child: child!),
      ),
      home: home,
    ),
  );
}

/// Tears the tree down so tickers and timers stop before the test ends.
Future<void> unmount(WidgetTester tester) async {
  await tester.pumpWidget(const SizedBox.shrink());
  await tester.pump(const Duration(seconds: 3));
}
