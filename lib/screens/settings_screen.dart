import '../analytics/analytics_events.dart';
import '../analytics/analytics_service.dart';

import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../app_scope.dart';
import '../components/comic.dart';
import '../config/app_config.dart';
import '../l10n/app_localizations.dart';
import '../services/settings_service.dart';
import '../theme/game_theme.dart';
import 'about_screen.dart';
import 'how_to_play_screen.dart';

// TODO(theme): Ayarlardan 3 tema (Arcade, Neon, Candy) arasında geçiş.
// Add a theme row here once Neon and Candy exist in GameThemes.

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
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(l10n.privacyError)));
    }
  }

  void _open(Widget page, {bool dialog = false}) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(fullscreenDialog: dialog, builder: (_) => page),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = GameThemeScope.of(context);
    final settings = AppScope.of(context).settings;
    final divider = Divider(
      height: 1,
      thickness: 2,
      color: theme.ink.withValues(alpha: 0.12),
    );
    return ComicPage(
      title: l10n.settings,
      child: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
        children: [
          ComicCard(
            padding: const EdgeInsets.symmetric(vertical: 6),
            child: Column(
              children: [
                _Row(
                  icon: Icons.translate_rounded,
                  label: l10n.language,
                  trailing: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      value: settings.language ?? '',
                      style: theme.body(14),
                      dropdownColor: theme.card,
                      borderRadius: BorderRadius.circular(12),
                      items: [
                        DropdownMenuItem(
                          value: '',
                          child: Text(l10n.deviceLanguage),
                        ),
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
                ),
                divider,
                _Row(
                  icon: Icons.music_note_rounded,
                  label: l10n.music,
                  trailing: Switch(
                    value: settings.music,
                    activeTrackColor: theme.primary,
                    onChanged: (value) async {
                      await settings.setMusic(value);
                      if (!context.mounted) return;
                      await AppScope.read(context).audio.setEnabled(value);
                    },
                  ),
                ),
                divider,
                _Row(
                  icon: Icons.vibration_rounded,
                  label: l10n.vibration,
                  trailing: Switch(
                    value: settings.haptics,
                    activeTrackColor: theme.primary,
                    onChanged: settings.setHaptics,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          ComicCard(
            padding: const EdgeInsets.symmetric(vertical: 6),
            child: Column(
              children: [
                _Row(
                  icon: Icons.help_outline_rounded,
                  label: l10n.howToPlay,
                  onTap: () {
                    AnalyticsService.instance.logHowToPlayOpen(
                      source: AnalyticsValues.sourceSettings,
                    );
                    _open(const HowToPlayScreen(), dialog: true);
                  },
                ),
                divider,
                _Row(
                  icon: Icons.shield_outlined,
                  label: l10n.privacy,
                  onTap: _privacy,
                ),
                divider,
                _Row(
                  icon: Icons.info_outline_rounded,
                  label: l10n.about,
                  onTap: () => _open(const AboutScreen()),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _Row extends StatelessWidget {
  const _Row({
    required this.icon,
    required this.label,
    this.trailing,
    this.onTap,
  });

  final IconData icon;
  final String label;
  final Widget? trailing;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final theme = GameThemeScope.of(context);
    return InkWell(
      onTap: onTap,
      child: ConstrainedBox(
        constraints: const BoxConstraints(minHeight: 52),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14),
          child: Row(
            children: [
              Icon(icon, color: theme.ink, size: 22),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  label,
                  style: theme.display(17),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              ?trailing,
              if (trailing == null && onTap != null)
                Icon(Icons.chevron_right_rounded, color: theme.ink),
            ],
          ),
        ),
      ),
    );
  }
}
