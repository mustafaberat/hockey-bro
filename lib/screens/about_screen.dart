import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:url_launcher/url_launcher.dart';

import '../components/comic.dart';
import '../config/app_config.dart';
import '../l10n/app_localizations.dart';
import '../theme/game_theme.dart';

class AboutScreen extends StatefulWidget {
  const AboutScreen({super.key});

  @override
  State<AboutScreen> createState() => _AboutScreenState();
}

class _AboutScreenState extends State<AboutScreen> {
  String _version = '';

  @override
  void initState() {
    super.initState();
    _loadVersion();
  }

  Future<void> _loadVersion() async {
    try {
      final info = await PackageInfo.fromPlatform();
      if (mounted) {
        setState(() => _version = '${info.version}+${info.buildNumber}');
      }
    } catch (_) {}
  }

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

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = GameThemeScope.of(context);
    return ComicPage(
      title: l10n.about,
      child: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
        children: [
          ComicCard(
            child: Column(
              children: [
                Text(l10n.appTitle, style: theme.display(26)),
                const SizedBox(height: 4),
                Text(
                  l10n.slogan,
                  textAlign: TextAlign.center,
                  style: theme.body(14, color: theme.subtle),
                ),
                const SizedBox(height: 6),
                Text(
                  AppIdentity.developer,
                  style: theme.body(14, color: theme.subtle),
                ),
                if (_version.isNotEmpty) ...[
                  const SizedBox(height: 6),
                  Text(
                    l10n.versionLabel(_version),
                    style: theme.body(13, color: theme.subtle),
                  ),
                ],
                const SizedBox(height: 14),
                ComicButton(
                  label: l10n.privacy,
                  icon: Icons.shield_outlined,
                  onPressed: _privacy,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
