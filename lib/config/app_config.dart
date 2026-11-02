/// Identity, routes, and ad timing. The working title stays in one place
/// until a name is chosen.
library;

abstract final class AppIdentity {
  static const String appName = 'Faceoff';
  static const String developer = 'ARU SOFT';
  static const String packageId = 'com.arusoft.faceoff';
  static const String privacyUrl = 'https://arusoft.vercel.app/privacy/faceoff';
}

abstract final class AppRoutes {
  static const String home = '/';
  static const String match = '/match';
  static const String settings = '/settings';
  static const String howTo = '/how-to-play';
}

abstract final class PrefsKeys {
  static const String language = 'language';
  static const String music = 'music';
  static const String haptics = 'haptics';
  static const String onboardingDone = 'onboarding_done';
  static const String difficulty = 'difficulty';
  // TODO(theme): store the chosen theme (Arcade, Neon, Candy) here.
}

abstract final class AdRules {
  static const Duration interstitialLoadWait = Duration(milliseconds: 800);
  static const Duration interstitialTimeout = Duration(seconds: 8);
  static const Duration minInterstitialGap = Duration(seconds: 45);
}
