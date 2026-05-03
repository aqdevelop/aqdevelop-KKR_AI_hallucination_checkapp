import 'package:flutter/material.dart';

ThemeData buildTheme() {
  final scheme = ColorScheme.fromSeed(
    seedColor: const Color(0xFF4F46E5),
    brightness: Brightness.light,
  );
  return ThemeData(
    useMaterial3: true,
    colorScheme: scheme,
    scaffoldBackgroundColor: scheme.surface,
    appBarTheme: AppBarTheme(
      backgroundColor: scheme.surface,
      foregroundColor: scheme.onSurface,
      centerTitle: false,
      elevation: 0,
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        minimumSize: const Size.fromHeight(52),
        textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      ),
    ),
  );
}

class VerdictColors {
  static const supported = Color(0xFF16A34A);
  static const refuted = Color(0xFFDC2626);
  static const unverifiable = Color(0xFFCA8A04);

  static Color background(String verdict) {
    switch (verdict) {
      case 'supported':
        return supported.withValues(alpha: 0.12);
      case 'refuted':
        return refuted.withValues(alpha: 0.16);
      case 'unverifiable':
        return unverifiable.withValues(alpha: 0.16);
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
        return Colors.black87;
    }
  }
}
