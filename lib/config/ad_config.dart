/// Test AdMob ids until the HockeyBro app exists under the ARU Soft publisher.
library;

import 'package:flutter/foundation.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

abstract final class AdConfig {
  static const String testAppIdAndroid =
      'ca-app-pub-3940256099942544~3347511713';
  static const String testAppIdIos = 'ca-app-pub-3940256099942544~1458002511';
  static const String testBanner = 'ca-app-pub-3940256099942544/6300978111';
  static const String testInterstitial =
      'ca-app-pub-3940256099942544/1033173712';

  static const String _tbd = '<TBD>';
  static const String releaseHomeBanner = 'ca-app-pub-1508520223269936/$_tbd';
  static const String releaseMatchEndInterstitial =
      'ca-app-pub-1508520223269936/$_tbd';

  static bool _ready(String id) => !id.contains(_tbd);

  static String _pick(String release, String test) =>
      kReleaseMode && _ready(release) ? release : test;

  static String get homeBanner => _pick(releaseHomeBanner, testBanner);

  static String get matchEndInterstitial =>
      _pick(releaseMatchEndInterstitial, testInterstitial);

  static RequestConfiguration get familiesRequestConfiguration {
    return RequestConfiguration(
      maxAdContentRating: MaxAdContentRating.g,
      // ignore: deprecated_member_use
      tagForChildDirectedTreatment: TagForChildDirectedTreatment.yes,
      // ignore: deprecated_member_use
      tagForUnderAgeOfConsent: TagForUnderAgeOfConsent.yes,
      ageRestrictedTreatment: AgeRestrictedTreatment.child,
    );
  }

  static const AdRequest request = AdRequest(nonPersonalizedAds: true);
}
