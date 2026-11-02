import 'package:flutter/widgets.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../analytics/analytics_events.dart';
import '../analytics/analytics_service.dart';
import '../config/app_config.dart';
import '../engine/robot.dart';

class SettingsService extends ChangeNotifier {
  SettingsService(this._prefs) {
    final lang = _prefs.getString(PrefsKeys.language);
    _language = supportedLanguages.contains(lang) ? lang : null;
    _music = _prefs.getBool(PrefsKeys.music) ?? true;
    _haptics = _prefs.getBool(PrefsKeys.haptics) ?? true;
    _onboardingDone = _prefs.getBool(PrefsKeys.onboardingDone) ?? false;
    final level = _prefs.getString(PrefsKeys.difficulty);
    _difficulty = Difficulty.values.firstWhere(
      (d) => d.name == level,
      orElse: () => Difficulty.normal,
    );
  }

  static Future<SettingsService> create() async =>
      SettingsService(await SharedPreferences.getInstance());

  final SharedPreferences _prefs;

  SharedPreferences get prefs => _prefs;

  static void _changed(String setting, String value) =>
      AnalyticsService.instance.logSettingsChange(setting, value);

  static const List<String> supportedLanguages = [
    'en',
    'es',
    'pt',
    'zh',
    'ja',
    'de',
    'fr',
    'ko',
    'it',
    'tr',
  ];

  static const Map<String, String> languageNames = {
    'en': 'English',
    'es': 'Español',
    'pt': 'Português',
    'zh': '简体中文',
    'ja': '日本語',
    'de': 'Deutsch',
    'fr': 'Français',
    'ko': '한국어',
    'it': 'Italiano',
    'tr': 'Türkçe',
  };

  String? _language;
  bool _music = true;
  bool _haptics = true;
  bool _onboardingDone = false;
  Difficulty _difficulty = Difficulty.normal;

  String? get language => _language;
  Locale? get locale => _language == null ? null : Locale(_language!);
  bool get music => _music;
  bool get haptics => _haptics;
  bool get onboardingDone => _onboardingDone;
  Difficulty get difficulty => _difficulty;

  Future<void> setDifficulty(Difficulty value) async {
    if (_difficulty == value) return;
    _changed(AnalyticsValues.settingDifficulty, value.name);
    _difficulty = value;
    notifyListeners();
    await _prefs.setString(PrefsKeys.difficulty, value.name);
  }

  Future<void> setLanguage(String? code) async {
    final next = supportedLanguages.contains(code) ? code : null;
    if (next != _language) {
      _changed(AnalyticsValues.settingLanguage, next ?? 'system');
    }
    _language = next;
    if (_language == null) {
      await _prefs.remove(PrefsKeys.language);
    } else {
      await _prefs.setString(PrefsKeys.language, _language!);
    }
    notifyListeners();
  }

  Future<void> setMusic(bool value) async {
    if (value != _music) {
      _changed(AnalyticsValues.settingMusic, value ? 'on' : 'off');
    }
    _music = value;
    await _prefs.setBool(PrefsKeys.music, value);
    notifyListeners();
  }

  Future<void> setHaptics(bool value) async {
    if (value != _haptics) {
      _changed(AnalyticsValues.settingHaptics, value ? 'on' : 'off');
    }
    _haptics = value;
    await _prefs.setBool(PrefsKeys.haptics, value);
    notifyListeners();
  }

  Future<void> setOnboardingDone() async {
    if (_onboardingDone) return;
    _onboardingDone = true;
    await _prefs.setBool(PrefsKeys.onboardingDone, true);
    notifyListeners();
  }
}
