import 'dart:async';

import 'package:flutter/foundation.dart';

/// AdMob disabled - no real ad IDs configured yet.
class AdService {
  AdService._();

  static final AdService instance = AdService._();

  final ValueNotifier<Object?> banner = ValueNotifier(null);

  bool get enabled => false;

  void initialize() {}

  void onMatchFinished() {}

  Future<void> showMatchEndInterstitial() async {}

  Future<void> maybeShowMatchEndInterstitial() async {}
}
