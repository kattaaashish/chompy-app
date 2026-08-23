// Chompy v0 — theme
//
// Single source of truth for colour, type and shape. Keep it that way: no
// Color(0xFF...) or TextStyle(...) inline in widgets. Values match the design
// handoff README exactly.
//
// Requires: google_fonts (Caprasimo, Figtree)

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class ChompyColors {
  // Grounds — pick one and keep it. Default is warm white.
  static const ground = Color(0xFFF9F4ED);
  static const groundCream = Color(0xFFF5EAD8);
  static const groundSage = Color(0xFFF0FAE1);
  static const groundPeach = Color(0xFFFFF2EB);

  static const surface = Color(0xFFEBDDC5); // filled inputs, chips, steppers
  static const card = Color(0xFFF9F4ED); // item cards (with shadowSm)
  static const ink = Color(0xFF201E1D);

  // Terracotta — actions, active selection, the fun-fact field
  static const accent = Color(0xFFC67139);
  static const accentHover = Color(0xFFB2622D);
  static const accentPressed = Color(0xFF8C491A);
  static const accentTint = Color(0xFFFFF2EB); // error background
  static const accentDeep = Color(0xFF8C491A); // accent-coloured body text
  static const accentDeeper = Color(0xFF643312);
  static const accentDeepest = Color(0xFF402310);

  // Sage — progress, completion, unit toggles
  static const sage = Color(0xFF8FA073);
  static const sageDeep = Color(0xFF56633F);
  static const sageTint = Color(0xFFF0FAE1);
  static const sageTintStrong = Color(0xFFE1EECC);

  static const neutral200 = Color(0xFFEEE7DB); // empty progress wells
  static const neutral300 = Color(0xFFDCD3C4); // progress-bar track
  static const neutral600 = Color(0xFF82796A); // kickers
  static const neutral700 = Color(0xFF645C50); // secondary copy
  static const neutral800 = Color(0xFF474238);
  static const neutral900 = Color(0xFF2E2B25); // viewfinder fill
}

class ChompySpace {
  static const s1 = 4.4;
  static const s2 = 8.8;
  static const s3 = 13.2;
  static const s4 = 17.6;
  static const s6 = 26.4;
  static const s8 = 35.2;

  /// Horizontal screen padding — fluid between small and default widths.
  static double screenH(double width) => width.clamp(320.0, 402.0) / 402.0 * 24.0;
}

class ChompyShape {
  static const cardRadius = BorderRadius.all(Radius.circular(26));
  static const pill = BorderRadius.all(Radius.circular(999));

  /// Chompy's silhouette: an irregular blob, not a rounded square.
  /// CSS reference: border-radius: 52% 48% 46% 54% / 48% 52% 48% 52%.
  static BorderRadius blob(double size) => BorderRadius.only(
        topLeft: Radius.elliptical(size * 0.52, size * 0.48),
        topRight: Radius.elliptical(size * 0.48, size * 0.52),
        bottomRight: Radius.elliptical(size * 0.46, size * 0.48),
        bottomLeft: Radius.elliptical(size * 0.54, size * 0.52),
      );

  static const shadowSm = [
    BoxShadow(color: Color(0x242E2B25), blurRadius: 2, offset: Offset(0, 1)),
  ];
  static const shadowMd = [
    BoxShadow(color: Color(0x292E2B25), blurRadius: 10, offset: Offset(0, 3)),
  ];
  static const shadowLg = [
    BoxShadow(color: Color(0x382E2B25), blurRadius: 32, offset: Offset(0, 12)),
  ];

  /// Never below this — the primary user is 7 years old.
  static const minTouchTarget = 44.0;
}

class ChompyDurations {
  // These stand in for real network waits. Show a determinate bar, never a
  // spinner: a spinner reads as "stuck" to a child.
  static const sendOtp = Duration(milliseconds: 2000);
  static const verifyOtp = Duration(milliseconds: 1400);
  static const detectFood = Duration(milliseconds: 2200);
  static const saveMeal = Duration(milliseconds: 1500);

  static const mascotPulse = Duration(milliseconds: 1100);
  static const mascotBlink = Duration(milliseconds: 1400);
}

/// Display type is fluid. Bounds come from the handoff type table; interpolate
/// on screen width between 320 and 402 (and hold at the max above that).
double fluid(double width, double min, double max) {
  final t = ((width - 320) / (402 - 320)).clamp(0.0, 1.0);
  return min + (max - min) * t;
}

ThemeData chompyTheme() {
  final display = GoogleFonts.caprasimo();
  final body = GoogleFonts.figtree();

  return ThemeData(
    useMaterial3: true,
    scaffoldBackgroundColor: ChompyColors.ground,
    colorScheme: const ColorScheme.light(
      primary: ChompyColors.accent,
      onPrimary: ChompyColors.ground,
      secondary: ChompyColors.sage,
      onSecondary: ChompyColors.ground,
      surface: ChompyColors.surface,
      onSurface: ChompyColors.ink,
      error: ChompyColors.accentDeep,
      onError: ChompyColors.ground,
    ),
    textTheme: TextTheme(
      // Caprasimo — display. Sizes here are the upper bound; scale down with
      // fluid() on narrow screens.
      displayLarge: display.copyWith(fontSize: 44, height: 1.02, color: ChompyColors.ink),
      displayMedium: display.copyWith(fontSize: 38, height: 1.04, color: ChompyColors.ink),
      headlineLarge: display.copyWith(fontSize: 34, height: 1.12, color: ChompyColors.ink),
      headlineMedium: display.copyWith(fontSize: 28, height: 1.12, color: ChompyColors.ink),
      titleLarge: display.copyWith(fontSize: 20, height: 1.2, color: ChompyColors.ink),
      titleMedium: display.copyWith(fontSize: 19, height: 1.1, color: ChompyColors.ink),
      // Figtree — body
      bodyLarge: body.copyWith(fontSize: 17, height: 1.4, color: ChompyColors.ink),
      bodyMedium: body.copyWith(fontSize: 15, height: 1.5, color: ChompyColors.ink),
      bodySmall: body.copyWith(fontSize: 13, height: 1.45, color: ChompyColors.neutral700),
      // Kicker / eyebrow: uppercase, letter-spaced, muted
      labelSmall: body.copyWith(
        fontSize: 11,
        letterSpacing: 1.32,
        fontWeight: FontWeight.w600,
        color: ChompyColors.neutral600,
      ),
    ),
    // Primary action: full width, left-aligned label, pill.
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        backgroundColor: ChompyColors.accent,
        foregroundColor: ChompyColors.ground,
        minimumSize: const Size.fromHeight(60),
        alignment: Alignment.centerLeft,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        shape: const RoundedRectangleBorder(borderRadius: ChompyShape.pill),
        textStyle: display.copyWith(fontSize: 19),
      ),
    ),
    // Secondary: soft fill, no outline. Nothing in this app is a bordered box.
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        backgroundColor: ChompyColors.surface,
        foregroundColor: ChompyColors.ink,
        side: BorderSide.none,
        minimumSize: const Size.fromHeight(56),
        alignment: Alignment.centerLeft,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        shape: const RoundedRectangleBorder(borderRadius: ChompyShape.pill),
        textStyle: display.copyWith(fontSize: 16),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: ChompyColors.surface,
      contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
      border: const OutlineInputBorder(
        borderRadius: ChompyShape.pill,
        borderSide: BorderSide.none,
      ),
      hintStyle: body.copyWith(fontSize: 17, color: ChompyColors.neutral600),
      labelStyle: body.copyWith(fontSize: 12, color: ChompyColors.neutral700),
    ),
    cardTheme: CardThemeData(
      color: ChompyColors.card,
      elevation: 0,
      shape: const RoundedRectangleBorder(borderRadius: ChompyShape.cardRadius),
      margin: EdgeInsets.zero,
    ),
    dividerTheme: const DividerThemeData(
      // Section breaks inside the phone are whitespace, not rules.
      thickness: 0,
      space: 10,
      color: Colors.transparent,
    ),
  );
}
