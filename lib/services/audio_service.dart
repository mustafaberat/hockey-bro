import 'package:flutter/foundation.dart';
import 'package:just_audio/just_audio.dart';

import 'platform_env.dart';

/// Loops the rink track while the app is open and music is on.
class AudioService {
  AudioPlayer? _player;
  bool _ready = false;
  bool _enabled = true;
  bool _want = false;

  bool get isEnabled => _enabled;

  Future<void> init({required bool enabled}) async {
    _enabled = enabled;
    if (isFlutterTest) return;
    try {
      final player = AudioPlayer();
      _player = player;
      await player.setAsset('assets/audio/rink.wav');
      await player.setLoopMode(LoopMode.one);
      await player.setVolume(0.4);
      _ready = true;
    } catch (error, stack) {
      debugPrint('audio init failed: $error\n$stack');
    }
  }

  Future<void> setEnabled(bool enabled) async {
    _enabled = enabled;
    if (enabled && _want) {
      await resumeOutput();
    } else {
      await pauseOutput();
    }
  }

  Future<void> play() async {
    _want = true;
    await resumeOutput();
  }

  Future<void> pauseOutput() async {
    try {
      await _player?.pause();
    } catch (_) {}
  }

  Future<void> resumeOutput() async {
    if (!_ready || !_enabled || !_want) return;
    try {
      await _player?.play();
    } catch (_) {}
  }
}
