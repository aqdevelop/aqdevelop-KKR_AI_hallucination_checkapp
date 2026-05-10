import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

import '../core/theme.dart';
import '../data/models/models.dart';

class HighlightedText extends StatelessWidget {
  const HighlightedText({
    super.key,
    required this.text,
    required this.claims,
    required this.onTapClaim,
  });

  final String text;
  final List<Claim> claims;
  final ValueChanged<Claim> onTapClaim;

  @override
  Widget build(BuildContext context) {
    final sorted = [...claims]..sort((a, b) => a.span.start.compareTo(b.span.start));

    final spans = <InlineSpan>[];
    var cursor = 0;
    for (final claim in sorted) {
      final start = claim.span.start.clamp(0, text.length);
      final end = claim.span.end.clamp(0, text.length);
      if (start < cursor || end <= start) continue;

      if (start > cursor) {
        spans.add(TextSpan(text: text.substring(cursor, start)));
      }
      spans.add(_buildClaimSpan(text.substring(start, end), claim));
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

  TextSpan _buildClaimSpan(String content, Claim claim) {
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
  }
}
