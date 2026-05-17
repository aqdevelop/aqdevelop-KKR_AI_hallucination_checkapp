import '../../data/models/models.dart';

class RenderedClaim {
  final Claim original;
  final int start;
  final int end;
  final bool fixed;

  const RenderedClaim({
    required this.original,
    required this.start,
    required this.end,
    required this.fixed,
  });

  String get id => original.id;
}

class EditedResult {
  final FactCheckResult base;
  final Set<String> appliedFixIds;
  final String currentText;
  final List<RenderedClaim> currentClaims;

  EditedResult._(
    this.base,
    this.appliedFixIds,
    this.currentText,
    this.currentClaims,
  );

  factory EditedResult(FactCheckResult base, [Set<String>? applied]) {
    final ids = applied ?? const <String>{};
    final (text, claims) = _compute(base, ids);
    return EditedResult._(base, ids, text, claims);
  }

  EditedResult applyFix(String claimId) {
    if (appliedFixIds.contains(claimId)) return this;
    return EditedResult(base, {...appliedFixIds, claimId});
  }

  EditedResult undoFix(String claimId) {
    if (!appliedFixIds.contains(claimId)) return this;
    final next = appliedFixIds.where((id) => id != claimId).toSet();
    return EditedResult(base, next);
  }

  EditedResult applyAll() {
    final ids = base.claims
        .where(_isFixable)
        .map((c) => c.id);
    return EditedResult(base, {...appliedFixIds, ...ids});
  }

  EditedResult undoAll() => EditedResult(base, const {});

  bool isFixed(String claimId) => appliedFixIds.contains(claimId);

  int get appliedCount => appliedFixIds.length;

  int get fixableCount => base.claims.where(_isFixable).length;

  int get pendingFixCount =>
      base.claims.where((c) => _isFixable(c) && !appliedFixIds.contains(c.id)).length;

  bool get hasAnyEdits => appliedFixIds.isNotEmpty;

  static bool canApply(Claim c) =>
      c.suggestion != null &&
      c.suggestion!.trim().isNotEmpty &&
      c.verdict != 'supported';

  static bool _isFixable(Claim c) => canApply(c);

  static (String, List<RenderedClaim>) _compute(
    FactCheckResult base,
    Set<String> appliedIds,
  ) {
    final text = base.originalText;
    final sorted = [...base.claims]..sort((a, b) => a.span.start.compareTo(b.span.start));

    final buffer = StringBuffer();
    final rendered = <RenderedClaim>[];
    var origCursor = 0;
    var newCursor = 0;

    for (final claim in sorted) {
      final start = claim.span.start.clamp(0, text.length);
      final end = claim.span.end.clamp(0, text.length);
      if (start < origCursor || end <= start) continue;

      if (start > origCursor) {
        final between = text.substring(origCursor, start);
        buffer.write(between);
        newCursor += between.length;
      }

      final shouldApply =
          appliedIds.contains(claim.id) && canApply(claim);
      final content = shouldApply
          ? claim.suggestion!
          : text.substring(start, end);
      buffer.write(content);
      rendered.add(RenderedClaim(
        original: claim,
        start: newCursor,
        end: newCursor + content.length,
        fixed: shouldApply,
      ));
      newCursor += content.length;
      origCursor = end;
    }

    if (origCursor < text.length) {
      buffer.write(text.substring(origCursor));
    }

    return (buffer.toString(), rendered);
  }
}
