/// App-wide analytics facade.
///
/// Rules (owner's call):
/// * Every `log*` is fire-and-forget: returns void, never throws, never makes
///   the caller wait. The actual send runs on a later event-loop turn.
/// * No queue, buffer, retry or fallback. If Firebase is not ready (missing
///   `google-services.json`, init failed, still starting) or a send fails,
///   the event is silently dropped.
/// * Nothing per tap and no screen-time / dwell events.
library;

import 'dart:async';
import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'analytics_events.dart';
import 'analytics_sink.dart';
import 'firebase_analytics_sink.dart';

typedef AnalyticsConnector = Future<AnalyticsSink> Function();

class AnalyticsService {
  AnalyticsService([this._sink]);

  static AnalyticsService instance = AnalyticsService();

  static const String prefsDeviceId = 'analytics_device_id';
  static const String prefsOpenCount = 'analytics_open_count';
  static const String prefsMatchCount = 'analytics_match_count';
  static const Duration _connectTimeout = Duration(seconds: 10);

  AnalyticsSink? _sink;
  SharedPreferences? _prefs;
  bool _started = false;
  String? _deviceId;
  int _openCount = 0;
  int _matchCount = 0;

  /// Null until [start] ran (or when prefs are unavailable).
  String? get deviceId => _deviceId;
  int get openCount => _openCount;
  int get matchCount => _matchCount;
  bool get isEnabled => _sink != null;

  @visibleForTesting
  static void debugSetInstance(AnalyticsService service) => instance = service;

  @visibleForTesting
  static void debugResetInstance() => instance = AnalyticsService();

  /// Loads the anonymous device id and counters, then connects Firebase.
  /// Call unawaited after `runApp`; it never throws.
  Future<void> start(
    SharedPreferences prefs, {
    AnalyticsConnector connect = connectFirebaseAnalytics,
  }) async {
    if (_started) return;
    _started = true;
    try {
      _loadCounters(prefs);
    } catch (e) {
      debugPrint('analytics: prefs unavailable ($e)');
    }
    if (_sink == null) {
      try {
        _sink = await connect().timeout(_connectTimeout);
      } catch (e) {
        debugPrint('analytics: disabled ($e)');
        return;
      }
    }
    final id = _deviceId;
    if (id != null) {
      _send((s) => s.setUserId(id));
      _send(
        (s) => s.setUserProperty(
          AnalyticsUserProps.deviceId,
          _clip(id, AnalyticsLimits.maxUserPropertyValue),
        ),
      );
    }
    logEvent(AnalyticsEvents.appOpen, {
      AnalyticsParams.deviceId: id,
      AnalyticsParams.openCount: _openCount,
    });
  }

  void _loadCounters(SharedPreferences prefs) {
    _prefs = prefs;
    var id = prefs.getString(prefsDeviceId);
    if (id == null || id.isEmpty) {
      id = newDeviceId();
      unawaited(prefs.setString(prefsDeviceId, id).catchError((_) => false));
    }
    _deviceId = id;
    _openCount = (prefs.getInt(prefsOpenCount) ?? 0) + 1;
    unawaited(
      prefs.setInt(prefsOpenCount, _openCount).catchError((_) => false),
    );
    _matchCount = prefs.getInt(prefsMatchCount) ?? 0;
  }

  /// Per-device match counter (1-based), persisted. Works without Firebase.
  int nextMatchNumber() {
    _matchCount++;
    final prefs = _prefs;
    if (prefs != null) {
      try {
        unawaited(
          prefs.setInt(prefsMatchCount, _matchCount).catchError((_) => false),
        );
      } catch (_) {}
    }
    return _matchCount;
  }

  /// Fire-and-forget. Drops silently when Firebase is not ready.
  void logEvent(String name, Map<String, Object?> params) {
    if (_sink == null) return;
    final clean = sanitizeParams(params);
    _send((s) => s.logEvent(_clip(name, AnalyticsLimits.maxName), clean));
  }

  void _send(Future<void> Function(AnalyticsSink sink) call) {
    final sink = _sink;
    if (sink == null) return;
    // Off the caller's stack (taps, frames): run on a later event-loop turn.
    Timer.run(() {
      try {
        unawaited(call(sink).catchError((Object _) {}));
      } catch (_) {}
    });
  }

  // ---- Navigation ----

  void logSettingsOpen({String source = AnalyticsValues.sourceHome}) =>
      logEvent(AnalyticsEvents.settingsOpen, {AnalyticsParams.source: source});

  void logHowToPlayOpen({required String source}) =>
      logEvent(AnalyticsEvents.howToPlayOpen, {AnalyticsParams.source: source});

  void logSettingsChange(String setting, String value) => logEvent(
    AnalyticsEvents.settingsChange,
    {AnalyticsParams.setting: setting, AnalyticsParams.value: value},
  );

  /// GA4-safe params: drops nulls, bools → 0/1, strings ≤ 100 chars,
  /// names ≤ 40 chars, at most 25 entries.
  static Map<String, Object> sanitizeParams(Map<String, Object?> raw) {
    final out = <String, Object>{};
    for (final e in raw.entries) {
      if (out.length >= AnalyticsLimits.maxParams) break;
      final v = e.value;
      if (v == null) continue;
      final key = _clip(e.key, AnalyticsLimits.maxName);
      out[key] = switch (v) {
        bool b => b ? 1 : 0,
        num n => n,
        String s => _clip(s, AnalyticsLimits.maxStringValue),
        _ => _clip(v.toString(), AnalyticsLimits.maxStringValue),
      };
    }
    return out;
  }

  static String _clip(String s, int max) =>
      s.length <= max ? s : s.substring(0, max);

  /// Random v4 UUID (36 chars), no extra package.
  static String newDeviceId([Random? random]) {
    final r = random ?? Random.secure();
    final b = List<int>.generate(16, (_) => r.nextInt(256));
    b[6] = (b[6] & 0x0f) | 0x40;
    b[8] = (b[8] & 0x3f) | 0x80;
    final h = b.map((x) => x.toRadixString(16).padLeft(2, '0')).join();
    return '${h.substring(0, 8)}-${h.substring(8, 12)}-${h.substring(12, 16)}-'
        '${h.substring(16, 20)}-${h.substring(20)}';
  }
}
