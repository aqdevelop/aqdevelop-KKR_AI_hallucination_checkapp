import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'tokens.dart';

ThemeData buildTheme() {
  final scheme = ColorScheme.fromSeed(
    seedColor: AppColors.accent,
    brightness: Brightness.light,
    primary: AppColors.accent,
    surface: AppColors.paper,
    onSurface: AppColors.ink900,
  );

  final serifDisplay = GoogleFonts.notoSerifKr(
    fontWeight: FontWeight.w800,
    color: AppColors.ink950,
    letterSpacing: -0.4,
  );

  return ThemeData(
    useMaterial3: true,
    colorScheme: scheme,
    scaffoldBackgroundColor: AppColors.paper,
    textTheme: TextTheme(
      // Serif — display & headings (authority)
      displaySmall: serifDisplay.copyWith(fontSize: 30, height: 1.2),
      headlineMedium: serifDisplay.copyWith(fontSize: 26, height: 1.2),
      headlineSmall: serifDisplay.copyWith(fontSize: 22, height: 1.25),
      titleLarge: GoogleFonts.notoSerifKr(
        fontSize: 18,
        fontWeight: FontWeight.w700,
        color: AppColors.ink900,
        letterSpacing: -0.2,
      ),
      // Sans — UI & body (legibility)
      titleMedium: GoogleFonts.notoSansKr(
        fontWeight: FontWeight.w700,
        fontSize: 15,
        color: AppColors.ink900,
      ),
      bodyLarge: GoogleFonts.notoSansKr(
        fontSize: 16,
        height: 1.75,
        color: AppColors.ink800,
      ),
      bodyMedium: GoogleFonts.notoSansKr(
        fontSize: 14,
        height: 1.55,
        color: AppColors.ink700,
      ),
      labelLarge: GoogleFonts.notoSansKr(
        fontWeight: FontWeight.w600,
        fontSize: 14,
        color: AppColors.ink800,
      ),
    ),
    appBarTheme: AppBarTheme(
      backgroundColor: AppColors.paper,
      foregroundColor: AppColors.ink900,
      surfaceTintColor: Colors.transparent,
      centerTitle: false,
      elevation: 0,
      titleTextStyle: GoogleFonts.notoSerifKr(
        fontSize: 18,
        fontWeight: FontWeight.w700,
        color: AppColors.ink900,
        letterSpacing: -0.2,
      ),
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        minimumSize: const Size.fromHeight(52),
        backgroundColor: AppColors.accent,
        foregroundColor: Colors.white,
        textStyle: GoogleFonts.notoSansKr(fontSize: 15, fontWeight: FontWeight.w700),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.button)),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        minimumSize: const Size.fromHeight(50),
        foregroundColor: AppColors.ink800,
        side: const BorderSide(color: AppColors.ink300),
        textStyle: GoogleFonts.notoSansKr(fontSize: 15, fontWeight: FontWeight.w700),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.button)),
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: AppColors.accent,
        textStyle: GoogleFonts.notoSansKr(fontSize: 14, fontWeight: FontWeight.w600),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      hintStyle: GoogleFonts.notoSansKr(color: AppColors.ink400, fontSize: 15),
    ),
    dividerTheme: const DividerThemeData(color: AppColors.ink200, thickness: 1),
  );
}

/// Backwards-compatible verdict palette. Screens not yet migrated to the
/// new [Verdict] helper still reference this; values now point at the
/// muted Forensic tones.
class VerdictColors {
  static const supported = AppColors.verified;
  static const refuted = AppColors.disputed;
  static const unverifiable = AppColors.unverifiable;

  static Color background(String verdict) => Verdict.bg(verdict);
  static Color foreground(String verdict) => Verdict.fg(verdict);
  static String label(String verdict) => Verdict.label(verdict);
}
