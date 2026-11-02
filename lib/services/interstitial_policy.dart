import '../config/app_config.dart';

/// Skips the first finished match, then allows one interstitial per match
/// once [AdRules.minInterstitialGap] has passed.
class InterstitialPolicy {
  int _finished = 0;
  DateTime? _lastShown;

  void onMatchFinished() => _finished++;

  bool shouldShow(DateTime now) {
    if (_finished <= 1) return false;
    final last = _lastShown;
    if (last != null && now.difference(last) < AdRules.minInterstitialGap) {
      return false;
    }
    return true;
  }

  void onShown(DateTime now) => _lastShown = now;
}
