import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

import '../core/theme.dart';
import '../data/models/models.dart';
import '../features/result/edited_result.dart';

class HighlightedText extends StatelessWidget {
  const HighlightedText({
    super.key,
    required this.text,
    required this.claims,
    required this.onTapClaim,
  });

  final String text;
  final List<RenderedClaim> claims;
  final ValueChanged<Claim> onTapClaim;

  @override
  Widget build(BuildContext context) {
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
      spans.add(_buildClaimSpan(text.substring(start, end), rc));
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

  TextSpan _buildClaimSpan(String content, RenderedClaim rc) {
    final claim = rc.original;
    final verdict = rc.fixed ? 'supported' : claim.verdict;
    final fg = VerdictColors.foreground(verdict);
    final bg = VerdictColors.background(verdict);
    return TextSpan(
      text: content,
      style: TextStyle(
        backgroundColor: bg,
        color: fg,
        fontWeight: FontWeight.w700,
        decoration: TextDecoration.underline,
        decorationStyle: rc.fixed
            ? TextDecorationStyle.solid
            : (claim.verdict == 'refuted'
                ? TextDecorationStyle.wavy
                : TextDecorationStyle.solid),
        decorationColor: fg.withValues(alpha: 0.6),
        decorationThickness: 1.5,
      ),
      recognizer: TapGestureRecognizer()..onTap = () => onTapClaim(claim),
    );
  }
}
