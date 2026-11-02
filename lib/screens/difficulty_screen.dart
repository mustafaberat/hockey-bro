import 'package:flutter/material.dart';

import '../app_scope.dart';
import '../config/tokens.dart';
import '../engine/robot.dart';
import '../l10n/app_localizations.dart';
import 'match_screen.dart';

class DifficultyScreen extends StatefulWidget {
  const DifficultyScreen({super.key});

  @override
  State<DifficultyScreen> createState() => _DifficultyScreenState();
}

class _DifficultyScreenState extends State<DifficultyScreen> {
  Difficulty _level = Difficulty.normal;

  Future<void> _start() async {
    await AppScope.read(context).audio.play();
    if (!mounted) return;
    await Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => MatchScreen(difficulty: _level),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(title: Text(l10n.difficulty)),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _LevelButton(
                label: l10n.easy,
                selected: _level == Difficulty.easy,
                onPressed: () => setState(() => _level = Difficulty.easy),
              ),
              const SizedBox(height: 8),
              _LevelButton(
                label: l10n.normal,
                selected: _level == Difficulty.normal,
                onPressed: () => setState(() => _level = Difficulty.normal),
              ),
              const SizedBox(height: 8),
              _LevelButton(
                label: l10n.hard,
                selected: _level == Difficulty.hard,
                onPressed: () => setState(() => _level = Difficulty.hard),
              ),
              const Spacer(),
              FilledButton(
                style: FilledButton.styleFrom(minimumSize: const Size.fromHeight(52)),
                onPressed: _start,
                child: Text(l10n.start),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _LevelButton extends StatelessWidget {
  const _LevelButton({
    required this.label,
    required this.selected,
    required this.onPressed,
  });

  final String label;
  final bool selected;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final style = selected
        ? FilledButton.styleFrom(
            backgroundColor: AppColors.blue,
            foregroundColor: AppColors.blueInk,
            minimumSize: const Size.fromHeight(52),
          )
        : OutlinedButton.styleFrom(
            foregroundColor: AppColors.white,
            side: const BorderSide(color: AppColors.white),
            minimumSize: const Size.fromHeight(52),
          );
    final button = selected
        ? FilledButton(style: style, onPressed: onPressed, child: Text(label))
        : OutlinedButton(style: style, onPressed: onPressed, child: Text(label));
    return button;
  }
}
