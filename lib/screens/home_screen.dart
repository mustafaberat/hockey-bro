import 'package:flutter/material.dart';

import '../app_scope.dart';
import '../components/banner_slot.dart';
import '../config/tokens.dart';
import '../l10n/app_localizations.dart';
import 'about_screen.dart';
import 'difficulty_screen.dart';
import 'how_to_play_screen.dart';
import 'match_screen.dart';
import 'settings_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  var _askedHowTo = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _openFirstHowTo());
  }

  void _openFirstHowTo() {
    if (!mounted || _askedHowTo) return;
    if (AppScope.read(context).settings.onboardingDone) return;
    _askedHowTo = true;
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        fullscreenDialog: true,
        builder: (_) => const HowToPlayScreen(firstRun: true),
      ),
    );
  }

  Future<void> _twoPlayers() async {
    await AppScope.read(context).audio.play();
    if (!mounted) return;
    await Navigator.of(context).push(
      MaterialPageRoute<void>(builder: (_) => const MatchScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const Spacer(),
                    Text(
                      l10n.appTitle,
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.displaySmall?.copyWith(
                        color: AppColors.white,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 32),
                    _MenuButton(
                      label: l10n.onePlayer,
                      filled: true,
                      color: AppColors.blue,
                      onColor: AppColors.blueInk,
                      onPressed: () {
                        Navigator.of(context).push(
                          MaterialPageRoute<void>(builder: (_) => const DifficultyScreen()),
                        );
                      },
                    ),
                    const SizedBox(height: 8),
                    _MenuButton(
                      label: l10n.twoPlayers,
                      filled: true,
                      color: AppColors.red,
                      onColor: AppColors.redInk,
                      onPressed: _twoPlayers,
                    ),
                    const SizedBox(height: 8),
                    _MenuButton(
                      label: l10n.settings,
                      onPressed: () {
                        Navigator.of(context).push(
                          MaterialPageRoute<void>(builder: (_) => const SettingsScreen()),
                        );
                      },
                    ),
                    const SizedBox(height: 8),
                    _MenuButton(
                      label: l10n.about,
                      onPressed: () {
                        Navigator.of(context).push(
                          MaterialPageRoute<void>(builder: (_) => const AboutScreen()),
                        );
                      },
                    ),
                    const Spacer(),
                  ],
                ),
              ),
            ),
            const BannerSlot(),
          ],
        ),
      ),
    );
  }
}

class _MenuButton extends StatelessWidget {
  const _MenuButton({
    required this.label,
    required this.onPressed,
    this.filled = false,
    this.color = AppColors.white,
    this.onColor = AppColors.ink,
  });

  final String label;
  final VoidCallback onPressed;
  final bool filled;
  final Color color;
  final Color onColor;

  @override
  Widget build(BuildContext context) {
    if (filled) {
      return FilledButton(
        style: FilledButton.styleFrom(
          backgroundColor: color,
          foregroundColor: onColor,
          minimumSize: const Size.fromHeight(52),
        ),
        onPressed: onPressed,
        child: Text(label),
      );
    }
    return OutlinedButton(
      style: OutlinedButton.styleFrom(
        foregroundColor: AppColors.white,
        side: const BorderSide(color: AppColors.white),
        minimumSize: const Size.fromHeight(52),
      ),
      onPressed: onPressed,
      child: Text(label),
    );
  }
}
