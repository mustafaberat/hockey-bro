import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

import '../config/ad_config.dart';
import '../config/app_config.dart';
import 'interstitial_policy.dart';
import 'platform_env.dart';

/// Banner on Home. Interstitial when a finished match returns Home.
class AdService {
  AdService._();

  static final AdService instance = AdService._();

  final InterstitialPolicy _policy = InterstitialPolicy();
  final ValueNotifier<BannerAd?> banner = ValueNotifier(null);
  InterstitialAd? _interstitial;
  bool _loadingInterstitial = false;
  bool _initialized = false;

  bool get enabled => !kIsWeb && !isFlutterTest;

  void initialize() {
    if (_initialized) return;
    _initialized = true;
    if (!enabled) return;
    unawaited(_initializeSdk());
  }

  Future<void> _initializeSdk() async {
    try {
      final config = AdConfig.familiesRequestConfiguration;
      await MobileAds.instance.updateRequestConfiguration(config);
      await MobileAds.instance.initialize();
      await MobileAds.instance.updateRequestConfiguration(config);
      _loadBanner();
    } catch (error, stack) {
      debugPrint('ads init failed: $error\n$stack');
    }
  }

  void _loadBanner() {
    banner.value?.dispose();
    banner.value = null;
    BannerAd(
      adUnitId: AdConfig.homeBanner,
      size: AdSize.banner,
      request: AdConfig.request,
      listener: BannerAdListener(
        onAdLoaded: (ad) => banner.value = ad as BannerAd,
        onAdFailedToLoad: (ad, _) => ad.dispose(),
      ),
    ).load();
  }

  void onMatchFinished() {
    _policy.onMatchFinished();
    if (enabled && _policy.shouldShow(DateTime.now())) _loadInterstitial();
  }

  void _loadInterstitial() {
    if (_loadingInterstitial || _interstitial != null) return;
    _loadingInterstitial = true;
    InterstitialAd.load(
      adUnitId: AdConfig.matchEndInterstitial,
      request: AdConfig.request,
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (ad) {
          _interstitial = ad;
          _loadingInterstitial = false;
        },
        onAdFailedToLoad: (_) => _loadingInterstitial = false,
      ),
    );
  }

  Future<void> maybeShowMatchEndInterstitial() async {
    if (!enabled || !_policy.shouldShow(DateTime.now())) return;
    if (_interstitial == null) {
      _loadInterstitial();
      await Future<void>.delayed(AdRules.interstitialLoadWait);
      if (_interstitial == null) return;
    }
    final ad = _interstitial!;
    _interstitial = null;
    final done = Completer<void>();
    ad.fullScreenContentCallback = FullScreenContentCallback(
      onAdDismissedFullScreenContent: (ad) {
        ad.dispose();
        if (!done.isCompleted) done.complete();
      },
      onAdFailedToShowFullScreenContent: (ad, _) {
        ad.dispose();
        if (!done.isCompleted) done.complete();
      },
    );
    _policy.onShown(DateTime.now());
    await ad.show();
    return done.future.timeout(AdRules.interstitialTimeout, onTimeout: () {});
  }
}
