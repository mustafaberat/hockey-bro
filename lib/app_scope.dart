import 'package:flutter/widgets.dart';

import 'services/ad_service.dart';
import 'services/audio_service.dart';
import 'services/settings_service.dart';

class AppServices {
  AppServices({required this.settings, required this.audio, AdService? ads})
    : ads = ads ?? AdService.instance;

  final SettingsService settings;
  final AudioService audio;
  final AdService ads;
}

class AppScope extends InheritedNotifier<SettingsService> {
  AppScope({required this.services, required super.child, super.key})
    : super(notifier: services.settings);

  final AppServices services;

  static AppServices of(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<AppScope>()!.services;

  static AppServices read(BuildContext context) =>
      context.getInheritedWidgetOfExactType<AppScope>()!.services;
}
