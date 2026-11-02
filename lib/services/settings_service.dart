import 'package:flutter/widgets.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../config/app_config.dart';

class SettingsService extends ChangeNotifier {
  SettingsService(this._prefs) {
    final lang = _prefs.getString(PrefsKeys.language);
    _language = supportedLanguages.contains(lang) ? lang : null;
    _music = _prefs.getBool(PrefsKeys.music) ?? true;
    _haptics = _prefs.getBool(PrefsKeys.haptics) ?? true;
    _onboardingDone = _prefs.getBool(PrefsKeys.onboardingDone) ?? false;
  }

  static Future<SettingsService> create() async =>
      SettingsService(await SharedPreferences.getInstance());

  final SharedPreferences _prefs;

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

  String? get language => _language;
  Locale? get locale => _language == null ? null : Locale(_language!);
  bool get music => _music;
  bool get haptics => _haptics;
  bool get onboardingDone => _onboardingDone;

  Future<void> setLanguage(String? code) async {
    _language = supportedLanguages.contains(code) ? code : null;
    if (_language == null) {
      await _prefs.remove(PrefsKeys.language);
    } else {
      await _prefs.setString(PrefsKeys.language, _language!);
    }
    notifyListeners();
  }

  Future<void> setMusic(bool value) async {
    _music = value;
    await _prefs.setBool(PrefsKeys.music, value);
    notifyListeners();
  }

  Future<void> setHaptics(bool value) async {
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
