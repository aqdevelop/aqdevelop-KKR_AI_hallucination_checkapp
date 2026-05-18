import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

import '../core/theme.dart';
import '../data/models/models.dart';
import '../features/result/edited_result.dart';

enum HighlightMode {
  /// Original draft: refuted = red wavy, supported = green, etc.
  /// Fixed claims rendered with strikethrough + dim to signal
  /// "you replaced this — see corrected version below".
  original,

  /// Final corrected text: only fixed claims highlighted, in brand color
  /// to celebrate the edits. Non-fixed claims appear as plain text since
  /// the user is reading the finished version.
  corrected,
}

class HighlightedText extends StatelessWidget {
  const HighlightedText({
    super.key,
    required this.text,
    required this.claims,
    required this.onTapClaim,
    this.mode = HighlightMode.original,
  });

  final String text;
  final List<RenderedClaim> claims;
  final ValueChanged<Claim> onTapClaim;
  final HighlightMode mode;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final sorted = [...claims]..sort((a, b) => a.start.compareTo(b.start));

    final spans = <InlineSpan>[];
    var cursor = 0;
    for (final rc in sorted) {
      final start = rc.start.clamp(0, text.length);
      final end = rc.end.clamp(0, text.length);
      if (start < cursor || end <= start) continue;

      if (start > cursor) {
        spans.add(TextSpan(text: text.substring(cursor, start)));
      }
      spans.add(_buildClaimSpan(text.substring(start, end), rc, scheme));
      cursor = end;
    }
    if (cursor < text.length) {
      spans.add(TextSpan(text: text.substring(cursor)));
    }

    return SelectableText.rich(
      TextSpan(
        children: spans,
        style: const TextStyle(
          fontSize: 16,
          height: 1.85,
          color: Color(0xFF1F2937),
          fontWeight: FontWeight.w400,
        ),
      ),
    );
  }

  TextSpan _buildClaimSpan(
    String content,
    RenderedClaim rc,
    ColorScheme scheme,
  ) {
    final claim = rc.original;

    switch (mode) {
      case HighlightMode.original:
        if (rc.fixed) {
          // This span has been replaced in the corrected panel below —
          // dim it and strike it through so the user sees it's "done".
          return TextSpan(
            text: content,
            style: const TextStyle(
              color: Color(0xFF9CA3AF),
              fontWeight: FontWeight.w500,
              decoration: TextDecoration.lineThrough,
              decorationColor: Color(0xFF9CA3AF),
              decorationThickness: 1.4,
            ),
            recognizer: TapGestureRecognizer()..onTap = () => onTapClaim(claim),
          );
        }
        final fg = VerdictColors.foreground(claim.verdict);
        final bg = VerdictColors.background(claim.verdict);
        return TextSpan(
          text: content,
          style: TextStyle(
            backgroundColor: bg,
            color: fg,
            fontWeight: FontWeight.w700,
            decoration: TextDecoration.underline,
            decorationStyle: claim.verdict == 'refuted'
                ? TextDecorationStyle.wavy
                : TextDecorationStyle.solid,
            decorationColor: fg.withValues(alpha: 0.6),
            decorationThickness: 1.5,
          ),
          recognizer: TapGestureRecognizer()..onTap = () => onTapClaim(claim),
        );

      case HighlightMode.corrected:
        if (!rc.fixed) {
          // In the corrected view, unfixed claims are still here but we
          // don't draw attention to them — render as plain text.
          return TextSpan(text: content);
        }
        return TextSpan(
          text: content,
          style: TextStyle(
            backgroundColor: scheme.primary.withValues(alpha: 0.14),
            color: scheme.primary,
            fontWeight: FontWeight.w800,
            decoration: TextDecoration.underline,
            decorationStyle: TextDecorationStyle.solid,
            decorationColor: scheme.primary.withValues(alpha: 0.55),
            decorationThickness: 1.8,
          ),
          recognizer: TapGestureRecognizer()..onTap = () => onTapClaim(claim),
        );
    }
  }
}
