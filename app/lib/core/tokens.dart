import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// FactLens "Forensic" design tokens.
///
/// Monochrome ink scale + a single deep-navy accent. Serif for display
/// (authority), sans for body (legibility), mono for forensic metadata
/// (document ids, timestamps, model versions).
class AppColors {
  AppColors._();

  // Monochrome ink scale
  static const ink950 = Color(0xFF0A0A0B);
  static const ink900 = Color(0xFF18181B);
  static const ink800 = Color(0xFF27272A);
  static const ink700 = Color(0xFF3F3F46);
  static const ink600 = Color(0xFF52525B);
  static const ink500 = Color(0xFF71717A);
  static const ink400 = Color(0xFFA1A1AA);
  static const ink300 = Color(0xFFD4D4D8);
  static const ink200 = Color(0xFFE4E4E7);
  static const ink100 = Color(0xFFF4F4F5);
  static const ink50 = Color(0xFFFAFAFA);
  static const white = Color(0xFFFFFFFF);
  static const paper = Color(0xFFF7F7F5); // warm off-white page

  // Single accent — deep authoritative navy
  static const accent = Color(0xFF1D3557);
  static const accentBright = Color(0xFF2B4E7E);
  static const accentSoft = Color(0xFFEDF1F7);

  // Verdict semantics — muted "-700" tones read more serious than brights
  static const verified = Color(0xFF15803D);
  static const verifiedSoft = Color(0xFFEAF3EC);
  static const disputed = Color(0xFFB91C1C);
  static const disputedSoft = Color(0xFFFAEBEB);
  static const unverifiable = Color(0xFFA16207);
  static const unverifiableSoft = Color(0xFFF8F1E3);
}

class AppRadius {
  AppRadius._();
  static const card = 10.0;
  static const button = 8.0;
  static const chip = 6.0;
  static const small = 4.0;
}

class AppText {
  AppText._();

  static TextStyle serif({
    double size = 16,
    FontWeight weight = FontWeight.w700,
    Color color = AppColors.ink900,
    double height = 1.3,
    double letterSpacing = -0.2,
  }) =>
      GoogleFonts.notoSerifKr(
        fontSize: size,
        fontWeight: weight,
        color: color,
        height: height,
        letterSpacing: letterSpacing,
      );

  static TextStyle sans({
    double size = 14,
    FontWeight weight = FontWeight.w400,
    Color color = AppColors.ink700,
    double height = 1.5,
    double letterSpacing = 0,
  }) =>
      GoogleFonts.notoSansKr(
        fontSize: size,
        fontWeight: weight,
        color: color,
        height: height,
        letterSpacing: letterSpacing,
      );

  /// Forensic metadata: document ids, timestamps, model versions, counts.
  static TextStyle mono({
    double size = 11,
    FontWeight weight = FontWeight.w500,
    Color color = AppColors.ink500,
    double letterSpacing = 0.2,
  }) =>
      GoogleFonts.robotoMono(
        fontSize: size,
        fontWeight: weight,
        color: color,
        letterSpacing: letterSpacing,
      );

  /// Small uppercase label, e.g. section eyebrows in a report.
  static TextStyle overline({Color color = AppColors.ink500}) =>
      GoogleFonts.robotoMono(
        fontSize: 10.5,
        fontWeight: FontWeight.w600,
        color: color,
        letterSpacing: 1.4,
      );
}

/// Verdict helpers used across the result/report views.
class Verdict {
  Verdict._();

  static Color fg(String verdict) {
    switch (verdict) {
      case 'supported':
        return AppColors.verified;
      case 'refuted':
        return AppColors.disputed;
      case 'unverifiable':
        return AppColors.unverifiable;
      default:
        return AppColors.ink700;
    }
  }

  static Color bg(String verdict) {
    switch (verdict) {
      case 'supported':
        return AppColors.verifiedSoft;
      case 'refuted':
        return AppColors.disputedSoft;
      case 'unverifiable':
        return AppColors.unverifiableSoft;
      default:
        return AppColors.ink100;
    }
  }

  static String label(String verdict) {
    switch (verdict) {
      case 'supported':
        return '확인됨';
      case 'refuted':
        return '반박됨';
      case 'unverifiable':
        return '검증불가';
      default:
        return verdict;
    }
  }

  /// Single-letter forensic marker, e.g. [V] / [D] / [U].
  static String marker(String verdict) {
    switch (verdict) {
      case 'supported':
        return 'V';
      case 'refuted':
        return 'D';
      case 'unverifiable':
        return 'U';
      default:
        return '?';
    }
  }
}
