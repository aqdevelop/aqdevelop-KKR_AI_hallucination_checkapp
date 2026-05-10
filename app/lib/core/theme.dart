import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

ThemeData buildTheme() {
  final scheme = ColorScheme.fromSeed(
    seedColor: const Color(0xFF6366F1),
    brightness: Brightness.light,
    surface: const Color(0xFFFAFAFB),
  );

  final korean = GoogleFonts.notoSansKrTextTheme();
  final headline = GoogleFonts.notoSansKr(fontWeight: FontWeight.w800);

  return ThemeData(
    useMaterial3: true,
    colorScheme: scheme,
    scaffoldBackgroundColor: scheme.surface,
    textTheme: korean.copyWith(
      headlineSmall: headline.copyWith(fontSize: 22, height: 1.3),
      titleLarge: headline.copyWith(fontSize: 18),
      titleMedium: GoogleFonts.notoSansKr(fontWeight: FontWeight.w700, fontSize: 15),
      bodyLarge: GoogleFonts.notoSansKr(fontSize: 16, height: 1.7, color: const Color(0xFF1F2937)),
      bodyMedium: GoogleFonts.notoSansKr(fontSize: 14, height: 1.55, color: const Color(0xFF374151)),
      labelLarge: GoogleFonts.notoSansKr(fontWeight: FontWeight.w600, fontSize: 14),
    ),
    appBarTheme: AppBarTheme(
      backgroundColor: scheme.surface,
      foregroundColor: scheme.onSurface,
      surfaceTintColor: Colors.transparent,
      centerTitle: false,
      elevation: 0,
      titleTextStyle: GoogleFonts.notoSansKr(
        fontSize: 18,
        fontWeight: FontWeight.w700,
        color: scheme.onSurface,
      ),
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        minimumSize: const Size.fromHeight(54),
        backgroundColor: scheme.primary,
        foregroundColor: Colors.white,
        textStyle: GoogleFonts.notoSansKr(fontSize: 16, fontWeight: FontWeight.w700),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      hintStyle: GoogleFonts.notoSansKr(color: const Color(0xFF9CA3AF), fontSize: 15),
    ),
    dividerTheme: const DividerThemeData(color: Color(0xFFE5E7EB), thickness: 1),
  );
}

class VerdictColors {
  // softer, more refined palette than pure red/green/yellow
  static const supported = Color(0xFF059669);    // emerald-600
  static const refuted = Color(0xFFE11D48);      // rose-600
  static const unverifiable = Color(0xFFD97706); // amber-600

  static const _supportedBg = Color(0xFFD1FAE5); // emerald-100
  static const _refutedBg = Color(0xFFFEE2E2);   // rose-100
  static const _unverifiableBg = Color(0xFFFEF3C7); // amber-100

  static Color background(String verdict) {
    switch (verdict) {
      case 'supported':
        return _supportedBg;
      case 'refuted':
        return _refutedBg;
      case 'unverifiable':
        return _unverifiableBg;
      default:
        return Colors.transparent;
    }
  }

  static Color foreground(String verdict) {
    switch (verdict) {
      case 'supported':
        return supported;
      case 'refuted':
        return refuted;
      case 'unverifiable':
        return unverifiable;
      default:
        return const Color(0xFF1F2937);
    }
  }

  static String label(String verdict) {
    switch (verdict) {
      case 'supported':
        return '확인됨';
      case 'refuted':
        return '의심';
      case 'unverifiable':
        return '불확실';
      default:
        return verdict;
    }
  }
}
