import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'analytics/analytics_service.dart';
import 'app_scope.dart';
import 'l10n/app_localizations.dart';
import 'screens/home_screen.dart';
import 'services/ad_service.dart';
import 'services/audio_service.dart';
import 'services/settings_service.dart';
import 'theme/game_theme.dart';

class FaceoffApp extends StatefulWidget {
  const FaceoffApp({required this.services, super.key});

  final AppServices services;

  @override
  State<FaceoffApp> createState() => _FaceoffAppState();
}

class _FaceoffAppState extends State<FaceoffApp> with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    final audio = widget.services.audio;
    if (state == AppLifecycleState.resumed) {
      audio.resumeOutput();
    } else if (state == AppLifecycleState.paused ||
        state == AppLifecycleState.hidden) {
      audio.pauseOutput();
    }
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: widget.services.settings,
      builder: (context, _) {
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          onGenerateTitle: (context) => AppLocalizations.of(context).appTitle,
          locale: widget.services.settings.locale,
          supportedLocales: AppLocalizations.supportedLocales,
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          localeResolutionCallback: _resolveLocale,
          theme: buildMaterialTheme(GameThemes.arcade),
          builder: (context, child) {
            // TODO(theme): pick the theme from settings once Neon and Candy exist.
            return GameThemeScope(
              theme: GameThemes.arcade,
              child: AppScope(
                services: widget.services,
                child: child ?? const SizedBox.shrink(),
              ),
            );
          },
          home: const HomeScreen(),
        );
      },
    );
  }

  static Locale _resolveLocale(Locale? device, Iterable<Locale> supported) {
    if (device != null) {
      for (final locale in supported) {
        if (locale.languageCode == device.languageCode) return locale;
      }
    }
    return const Locale('en');
  }
}

ThemeData buildMaterialTheme(GameTheme game) {
  return ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    fontFamily: game.bodyFont,
    scaffoldBackgroundColor: game.background,
    colorScheme: ColorScheme.light(
      surface: game.card,
      onSurface: game.ink,
      primary: game.primary,
      onPrimary: Colors.white,
      secondary: game.blue,
      onSecondary: Colors.white,
      error: game.red,
      onError: Colors.white,
    ),
    snackBarTheme: SnackBarThemeData(
      backgroundColor: game.ink,
      contentTextStyle: game.body(14, color: Colors.white),
    ),
  );
}

Future<void> bootstrap() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.dark);

  final settings = await SettingsService.create();
  final audio = AudioService();
  await audio.init(enabled: settings.music);
  await audio.play();

  final ads = AdService.instance;
  ads.initialize();

  runApp(
    FaceoffApp(
      services: AppServices(settings: settings, audio: audio, ads: ads),
    ),
  );
  // After runApp and unawaited: Firebase never delays the first frame. No
  // config / any failure = analytics stays off for this session.
  unawaited(
    AnalyticsService.instance.start(settings.prefs).catchError((Object _) {}),
  );
}
