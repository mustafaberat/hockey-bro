import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../app_scope.dart';
import '../config/app_config.dart';
import '../l10n/app_localizations.dart';
import '../services/settings_service.dart';
import 'how_to_play_screen.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  Future<void> _privacy() async {
    final l10n = AppLocalizations.of(context);
    final opened = await launchUrl(
      Uri.parse(AppIdentity.privacyUrl),
      mode: LaunchMode.externalApplication,
    );
    if (!opened && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.privacyError)),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final settings = AppScope.of(context).settings;
    return Scaffold(
      appBar: AppBar(title: Text(l10n.settings)),
      body: SafeArea(
        child: ListView(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
              child: DropdownButtonFormField<String>(
                initialValue: settings.language ?? '',
                isExpanded: true,
                decoration: InputDecoration(labelText: l10n.language),
                items: [
                  DropdownMenuItem(value: '', child: Text(l10n.deviceLanguage)),
                  for (final code in SettingsService.supportedLanguages)
                    DropdownMenuItem(
                      value: code,
                      child: Text(SettingsService.languageNames[code]!),
                    ),
                ],
                onChanged: (value) => settings.setLanguage(
                  value == null || value.isEmpty ? null : value,
                ),
              ),
            ),
            SwitchListTile(
              title: Text(l10n.music),
              value: settings.music,
              onChanged: (value) async {
                await settings.setMusic(value);
                if (!context.mounted) return;
                await AppScope.read(context).audio.setEnabled(value);
              },
            ),
            SwitchListTile(
              title: Text(l10n.vibration),
              value: settings.haptics,
              onChanged: settings.setHaptics,
            ),
            ListTile(
              title: Text(l10n.howToPlay),
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute<void>(
                    fullscreenDialog: true,
                    builder: (_) => const HowToPlayScreen(),
                  ),
                );
              },
            ),
            ListTile(
              title: Text(l10n.privacy),
              onTap: _privacy,
            ),
          ],
        ),
      ),
    );
  }
}
