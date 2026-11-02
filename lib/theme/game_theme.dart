/// Look of the whole game. Screens and painters read every color, outline
/// width, shadow offset and font from a [GameTheme], never from literals, so
/// a new look is just a new [GameTheme] value.
///
/// TODO(theme): Ayarlardan 3 tema (Arcade, Neon, Candy) arasında geçiş.
/// Today only Arcade (comic) exists and it is the default. To add Neon and
/// Candy: add their ids to [GameThemeId], add a [GameTheme] for each to
/// [GameThemes.all], store the choice in settings, and add a picker to the
/// settings screen. The mockups for both are in the design folder.
library;

import 'package:flutter/material.dart';

import '../engine/table.dart';

enum GameThemeId { arcade }

@immutable
class GameTheme {
  const GameTheme({
    required this.id,
    required this.ink,
    required this.backgroundTop,
    required this.background,
    required this.backgroundDot,
    required this.rink,
    required this.rinkDot,
    required this.line,
    required this.blue,
    required this.blueLight,
    required this.blueText,
    required this.red,
    required this.redLight,
    required this.redText,
    required this.puck,
    required this.primary,
    required this.card,
    required this.surface,
    required this.subtle,
    required this.dim,
    required this.gold,
    required this.confetti,
    required this.displayFont,
    required this.bodyFont,
    this.outline = 3,
    this.shadow = 4,
    this.radius = 16,
  });

  final GameThemeId id;

  /// Outlines, hard shadows and dark text.
  final Color ink;
  final Color backgroundTop;
  final Color background;
  final Color backgroundDot;
  final Color rink;
  final Color rinkDot;
  final Color line;
  final Color blue;
  final Color blueLight;
  final Color blueText;
  final Color red;
  final Color redLight;
  final Color redText;
  final Color puck;

  /// Main "go on" action (Resume).
  final Color primary;
  final Color card;
  final Color surface;
  final Color subtle;
  final Color dim;
  final Color gold;
  final List<Color> confetti;
  final String displayFont;
  final String bodyFont;

  /// Base outline width in logical pixels.
  final double outline;

  /// Base hard-shadow offset in logical pixels.
  final double shadow;
  final double radius;

  Color side(Side side) => side == Side.blue ? blue : red;
  Color sideLight(Side side) => side == Side.blue ? blueLight : redLight;
  Color sideText(Side side) => side == Side.blue ? blueText : redText;

  /// Chunky headline text. [shadow] adds a hard drop shadow under it.
  TextStyle display(double size, {Color? color, bool shadow = false}) {
    return TextStyle(
      fontFamily: displayFont,
      fontWeight: FontWeight.w800,
      fontSize: size,
      height: 1.05,
      color: color ?? ink,
      shadows: shadow
          ? [Shadow(color: ink, offset: Offset(0, size * 0.07))]
          : null,
    );
  }

  TextStyle body(
    double size, {
    Color? color,
    FontWeight weight = FontWeight.w700,
  }) {
    return TextStyle(
      fontFamily: bodyFont,
      fontWeight: weight,
      fontSize: size,
      height: 1.2,
      color: color ?? ink,
    );
  }
}

abstract final class GameThemes {
  /// C · Comic Arcade. Thick ink outlines, hard offset shadows, warm yellow.
  static const GameTheme arcade = GameTheme(
    id: GameThemeId.arcade,
    ink: Color(0xFF2B1D12),
    backgroundTop: Color(0xFFFFE066),
    background: Color(0xFFFFC93C),
    backgroundDot: Color(0x292B1D12),
    rink: Color(0xFFFFF7E0),
    rinkDot: Color(0x29FF8C28),
    line: Color(0xFFFF7A1A),
    blue: Color(0xFF3A8DFF),
    blueLight: Color(0xFF7AB6FF),
    blueText: Color(0xFF2A74E8),
    red: Color(0xFFFF4B4B),
    redLight: Color(0xFFFF8B8B),
    redText: Color(0xFFE83B3B),
    puck: Color(0xFFFFD23A),
    primary: Color(0xFF38C25A),
    card: Color(0xFFFFF7E0),
    surface: Color(0xFFFFFFFF),
    subtle: Color(0xFF6A4A2A),
    dim: Color(0x732B1D12),
    gold: Color(0xFFFFD84A),
    confetti: [
      Color(0xFFFF4B4B),
      Color(0xFF3A8DFF),
      Color(0xFFFFD23A),
      Color(0xFF38C25A),
      Color(0xFFFF7A1A),
      Color(0xFFB18CFF),
    ],
    displayFont: 'Baloo2',
    bodyFont: 'Nunito',
  );

  static const GameTheme fallback = arcade;

  static GameTheme byId(GameThemeId id) => switch (id) {
    GameThemeId.arcade => arcade,
  };
}

/// Hands the active [GameTheme] down the tree.
class GameThemeScope extends InheritedWidget {
  const GameThemeScope({required this.theme, required super.child, super.key});

  final GameTheme theme;

  static GameTheme of(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<GameThemeScope>()?.theme ??
      GameThemes.fallback;

  @override
  bool updateShouldNotify(GameThemeScope oldWidget) => oldWidget.theme != theme;
}
