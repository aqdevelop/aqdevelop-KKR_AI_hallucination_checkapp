import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../core/tokens.dart';
import '../../data/models/models.dart';
import '../../state/providers.dart';
import '../../widgets/highlighted_text.dart';
import 'claim_detail_sheet.dart';
import 'edited_result.dart';

class ResultScreen extends ConsumerWidget {
  const ResultScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(checkControllerProvider);
    final edited = ref.watch(editedResultProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('검증 리포트'),
        actions: [
          if (edited != null)
            IconButton(
              tooltip: '교정본 복사',
              icon: const Icon(Icons.content_copy_outlined, size: 20),
              onPressed: () => _copy(context, edited.currentText),
            ),
        ],
      ),
      body: state.when(
        data: (result) {
          if (result == null || edited == null) {
            return const Center(child: Text('결과가 없습니다.'));
          }
          return _ResultBody(edited: edited);
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Text('오류가 발생했어요\n$e', textAlign: TextAlign.center),
          ),
        ),
      ),
    );
  }

  void _copy(BuildContext context, String text) {
    Clipboard.setData(ClipboardData(text: text));
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(const SnackBar(
        content: Text('교정본을 클립보드에 복사했어요'),
        duration: Duration(seconds: 2),
      ));
  }
}

class _ResultBody extends ConsumerWidget {
  const _ResultBody({required this.edited});
  final EditedResult edited;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(18, 12, 18, 32),
      children: [
        _ReportHeader(result: edited.base),
        const SizedBox(height: 12),
        _ExecutiveSummary(result: edited.base),
        if (edited.fixableCount > 0) ...[
          const SizedBox(height: 12),
          _FixActionBar(
            pending: edited.pendingFixCount,
            applied: edited.appliedCount,
            onApplyAll: () => _applyAll(context, ref),
            onUndoAll: () => _undoAll(context, ref),
          ),
        ],
        const SizedBox(height: 16),
        _OriginalPanel(
          text: edited.base.originalText,
          claims: edited.originalClaims,
          hasEdits: edited.hasAnyEdits,
          onTapClaim: (c) => _openClaim(context, ref, c),
        ),
        if (edited.hasAnyEdits) ...[
          const SizedBox(height: 14),
          _CorrectedPanel(
            text: edited.currentText,
            claims: edited.appliedClaimsInCurrent,
            appliedCount: edited.appliedCount,
            onTapClaim: (c) => _openClaim(context, ref, c),
            onCopy: () => _copyText(context, edited.currentText),
          ),
        ],
        if (edited.base.claims.isNotEmpty) ...[
          const SizedBox(height: 16),
          _ClaimBreakdown(
            claims: edited.base.claims,
            onTapClaim: (c) => _openClaim(context, ref, c),
          ),
        ],
        const SizedBox(height: 16),
        _SourceIndex(claims: edited.base.claims),
        const SizedBox(height: 16),
        _Methodology(result: edited.base),
        const SizedBox(height: 16),
        const _Disclaimer(),
      ],
    );
  }

  void _copyText(BuildContext context, String text) {
    Clipboard.setData(ClipboardData(text: text));
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(const SnackBar(
        content: Text('교정본을 클립보드에 복사했어요'),
        duration: Duration(seconds: 2),
      ));
  }

  void _openClaim(BuildContext context, WidgetRef ref, Claim claim) {
    final controller = ref.read(editedResultProvider.notifier);
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.paper,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (sheetCtx) => Consumer(builder: (_, sheetRef, __) {
        final live = sheetRef.watch(editedResultProvider);
        final fixed = live?.isFixed(claim.id) ?? false;
        return ClaimDetailSheet(
          claim: claim,
          isFixed: fixed,
          onApply: () {
            controller.applyFix(claim.id);
            _showApplied(context, ref, claim.id);
          },
          onUndo: () => controller.undoFix(claim.id),
        );
      }),
    );
  }

  void _showApplied(BuildContext context, WidgetRef ref, String claimId) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(
        content: const Text('교정이 적용됐어요'),
        duration: const Duration(seconds: 3),
        action: SnackBarAction(
          label: '되돌리기',
          onPressed: () => ref.read(editedResultProvider.notifier).undoFix(claimId),
        ),
      ));
  }

  void _applyAll(BuildContext context, WidgetRef ref) {
    final before = ref.read(editedResultProvider)?.appliedFixIds ?? const <String>{};
    ref.read(editedResultProvider.notifier).applyAll();
    final after = ref.read(editedResultProvider)?.appliedFixIds ?? const <String>{};
    final added = after.length - before.length;
    if (added <= 0) return;
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(
        content: Text('교정 $added건을 적용했어요'),
        duration: const Duration(seconds: 3),
        action: SnackBarAction(
          label: '모두 되돌리기',
          onPressed: () => ref.read(editedResultProvider.notifier).undoAll(),
        ),
      ));
  }

  void _undoAll(BuildContext context, WidgetRef ref) {
    ref.read(editedResultProvider.notifier).undoAll();
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(const SnackBar(
        content: Text('원문으로 되돌렸어요'),
        duration: Duration(seconds: 2),
      ));
  }
}

// ─────────────────────────────────────────────────────────────────────────
// Report header
// ─────────────────────────────────────────────────────────────────────────

class _ReportHeader extends StatelessWidget {
  const _ReportHeader({required this.result});
  final FactCheckResult result;

  @override
  Widget build(BuildContext context) {
    final s = result.summary;
    final reportId =
        result.originalText.hashCode.toUnsigned(32).toRadixString(16).toUpperCase().padLeft(8, '0');
    final now = DateTime.now();
    final date =
        '${now.year}.${now.month.toString().padLeft(2, '0')}.${now.day.toString().padLeft(2, '0')}';
    final meta =
        'RPT-$reportId · $date · 주장 ${s.total}건 · ${result.cached ? '캐시' : '실시간'}';

    return Container(
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(AppRadius.card),
        border: Border.all(color: AppColors.ink200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(18, 16, 18, 14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text('VERIFICATION REPORT', style: AppText.overline(color: AppColors.accent)),
                    const Spacer(),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                      decoration: BoxDecoration(
                        color: AppColors.verifiedSoft,
                        borderRadius: BorderRadius.circular(AppRadius.small),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            width: 5,
                            height: 5,
                            decoration: const BoxDecoration(
                                color: AppColors.verified, shape: BoxShape.circle),
                          ),
                          const SizedBox(width: 5),
                          Text('분석 완료',
                              style: AppText.mono(
                                  size: 10, color: AppColors.verified, weight: FontWeight.w600)),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Text('사실성 검증 결과',
                    style: Theme.of(context).textTheme.headlineSmall),
                const SizedBox(height: 8),
                Text(meta, style: AppText.mono()),
              ],
            ),
          ),
          const Divider(height: 1),
          Padding(
            padding: const EdgeInsets.fromLTRB(18, 16, 18, 18),
            child: Column(
              children: [
                _TrustMeter(score: s.trustScore),
                const SizedBox(height: 16),
                _VerdictBar(summary: s),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                        child: _VerdictStat(
                            count: s.supported, label: '확인', color: AppColors.verified)),
                    _statDivider(),
                    Expanded(
                        child: _VerdictStat(
                            count: s.refuted, label: '반박', color: AppColors.disputed)),
                    _statDivider(),
                    Expanded(
                        child: _VerdictStat(
                            count: s.unverifiable, label: '검증불가', color: AppColors.unverifiable)),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _statDivider() =>
      Container(width: 1, height: 30, color: AppColors.ink200);
}

class _TrustMeter extends StatelessWidget {
  const _TrustMeter({required this.score});
  final double score;

  @override
  Widget build(BuildContext context) {
    final v = score.clamp(0, 100).toDouble();
    final color = v >= 70
        ? AppColors.verified
        : v >= 40
            ? AppColors.unverifiable
            : AppColors.disputed;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.baseline,
          textBaseline: TextBaseline.alphabetic,
          children: [
            Text('신뢰도 지수', style: AppText.sans(size: 13, color: AppColors.ink600, weight: FontWeight.w600)),
            const Spacer(),
            Text(v.toStringAsFixed(0),
                style: AppText.serif(size: 28, weight: FontWeight.w800, color: color, height: 1)),
            const SizedBox(width: 2),
            Padding(
              padding: const EdgeInsets.only(bottom: 3),
              child: Text('/100', style: AppText.mono(size: 11, color: AppColors.ink400)),
            ),
          ],
        ),
        const SizedBox(height: 8),
        ClipRRect(
          borderRadius: BorderRadius.circular(2),
          child: Stack(
            children: [
              Container(height: 6, color: AppColors.ink100),
              FractionallySizedBox(
                widthFactor: v / 100,
                child: Container(height: 6, color: color),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _VerdictBar extends StatelessWidget {
  const _VerdictBar({required this.summary});
  final Summary summary;

  @override
  Widget build(BuildContext context) {
    final segments = <(int, Color)>[
      (summary.supported, AppColors.verified),
      (summary.unverifiable, AppColors.unverifiable),
      (summary.refuted, AppColors.disputed),
    ];
    return ClipRRect(
      borderRadius: BorderRadius.circular(2),
      child: Row(
        children: [
          for (final (count, color) in segments)
            if (count > 0)
              Expanded(
                flex: count,
                child: Container(height: 8, color: color),
              ),
          if (summary.total == 0)
            Expanded(child: Container(height: 8, color: AppColors.ink200)),
        ],
      ),
    );
  }
}

class _VerdictStat extends StatelessWidget {
  const _VerdictStat({required this.count, required this.label, required this.color});
  final int count;
  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text('$count',
            style: AppText.serif(size: 22, weight: FontWeight.w800, color: color, height: 1)),
        const SizedBox(height: 4),
        Text(label, style: AppText.sans(size: 11, color: AppColors.ink500, weight: FontWeight.w600)),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────
// Fix action bar
// ─────────────────────────────────────────────────────────────────────────

class _FixActionBar extends StatelessWidget {
  const _FixActionBar({
    required this.pending,
    required this.applied,
    required this.onApplyAll,
    required this.onUndoAll,
  });

  final int pending;
  final int applied;
  final VoidCallback onApplyAll;
  final VoidCallback onUndoAll;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(14, 11, 10, 11),
      decoration: BoxDecoration(
        color: AppColors.accentSoft,
        borderRadius: BorderRadius.circular(AppRadius.card),
        border: Border.all(color: AppColors.accent.withValues(alpha: 0.20)),
      ),
      child: Row(
        children: [
          const Icon(Icons.auto_fix_high, size: 16, color: AppColors.accent),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              applied > 0
                  ? '교정 $applied건 적용됨${pending > 0 ? ' · 남은 제안 $pending건' : ''}'
                  : 'AI 교정 제안 $pending건',
              style: AppText.sans(size: 12.5, color: AppColors.accent, weight: FontWeight.w700),
            ),
          ),
          if (applied > 0)
            TextButton(
              onPressed: onUndoAll,
              style: TextButton.styleFrom(
                minimumSize: Size.zero,
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                foregroundColor: AppColors.ink500,
              ),
              child: Text('원문', style: AppText.sans(size: 12, weight: FontWeight.w700, color: AppColors.ink500)),
            ),
          if (pending > 0) ...[
            const SizedBox(width: 4),
            FilledButton(
              onPressed: onApplyAll,
              style: FilledButton.styleFrom(
                minimumSize: Size.zero,
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.button)),
                textStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700),
              ),
              child: const Text('모두 적용'),
            ),
          ],
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────
// Text panels
// ─────────────────────────────────────────────────────────────────────────

class _OriginalPanel extends StatelessWidget {
  const _OriginalPanel({
    required this.text,
    required this.claims,
    required this.hasEdits,
    required this.onTapClaim,
  });

  final String text;
  final List<RenderedClaim> claims;
  final bool hasEdits;
  final ValueChanged<Claim> onTapClaim;

  @override
  Widget build(BuildContext context) {
    return _DocPanel(
      label: '원문',
      labelEn: 'SUBMITTED TEXT',
      accent: AppColors.ink400,
      note: hasEdits ? '교정본 아래 참조' : null,
      child: HighlightedText(
        text: text,
        claims: claims,
        onTapClaim: onTapClaim,
        mode: HighlightMode.original,
      ),
    );
  }
}

class _CorrectedPanel extends StatelessWidget {
  const _CorrectedPanel({
    required this.text,
    required this.claims,
    required this.appliedCount,
    required this.onTapClaim,
    required this.onCopy,
  });

  final String text;
  final List<RenderedClaim> claims;
  final int appliedCount;
  final ValueChanged<Claim> onTapClaim;
  final VoidCallback onCopy;

  @override
  Widget build(BuildContext context) {
    return _DocPanel(
      label: '교정본',
      labelEn: 'REVISED TEXT',
      accent: AppColors.accent,
      emphasized: true,
      note: '$appliedCount건 반영',
      trailing: IconButton(
        tooltip: '복사',
        icon: const Icon(Icons.content_copy_outlined, size: 17),
        color: AppColors.accent,
        visualDensity: VisualDensity.compact,
        onPressed: onCopy,
      ),
      child: HighlightedText(
        text: text,
        claims: claims,
        onTapClaim: onTapClaim,
        mode: HighlightMode.corrected,
      ),
    );
  }
}

class _DocPanel extends StatelessWidget {
  const _DocPanel({
    required this.label,
    required this.labelEn,
    required this.accent,
    required this.child,
    this.note,
    this.trailing,
    this.emphasized = false,
  });

  final String label;
  final String labelEn;
  final Color accent;
  final Widget child;
  final String? note;
  final Widget? trailing;
  final bool emphasized;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(AppRadius.card),
        border: Border.all(
          color: emphasized ? accent.withValues(alpha: 0.40) : AppColors.ink200,
          width: emphasized ? 1.4 : 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            padding: EdgeInsets.fromLTRB(16, 11, trailing != null ? 6 : 16, 11),
            decoration: BoxDecoration(
              color: emphasized ? accent.withValues(alpha: 0.05) : AppColors.ink50,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(AppRadius.card),
                topRight: Radius.circular(AppRadius.card),
              ),
              border: const Border(bottom: BorderSide(color: AppColors.ink200)),
            ),
            child: Row(
              children: [
                Container(width: 3, height: 14, color: accent),
                const SizedBox(width: 8),
                Text(label, style: AppText.sans(size: 13, weight: FontWeight.w800, color: AppColors.ink900)),
                const SizedBox(width: 8),
                Text(labelEn, style: AppText.overline(color: AppColors.ink400)),
                const Spacer(),
                if (note != null)
                  Text(note!, style: AppText.mono(size: 10, color: accent, weight: FontWeight.w600)),
                if (trailing != null) trailing!,
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(18, 16, 18, 18),
            child: child,
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────
// Executive summary
// ─────────────────────────────────────────────────────────────────────────

class _ExecutiveSummary extends StatelessWidget {
  const _ExecutiveSummary({required this.result});
  final FactCheckResult result;

  ({String label, Color color}) get _risk {
    final s = result.summary;
    if (s.refuted > 0) return (label: '높음', color: AppColors.disputed);
    if (s.unverifiable > s.supported) {
      return (label: '중간', color: AppColors.unverifiable);
    }
    return (label: '낮음', color: AppColors.verified);
  }

  String _summaryText() {
    final s = result.summary;
    if (s.total == 0) return '분석할 사실 주장을 찾지 못했습니다.';
    final buf = StringBuffer('총 ${s.total}개의 사실 주장을 분석했습니다. ');
    if (s.refuted > 0) {
      buf.write('이 중 ${s.refuted}개가 근거와 충돌해 반박됐습니다. ');
      final refuted = result.claims.where((c) => c.verdict == 'refuted').toList()
        ..sort((a, b) => b.confidence.compareTo(a.confidence));
      if (refuted.isNotEmpty) {
        buf.write('특히 "${_shorten(refuted.first.text)}" 부분을 우선 재검토하세요.');
      }
    } else if (s.unverifiable > 0) {
      buf.write('명백한 오류는 발견되지 않았으나 ${s.unverifiable}개 주장은 '
          '충분한 근거를 찾지 못해 검증되지 않았습니다.');
    } else {
      buf.write('분석된 주요 주장이 모두 근거와 일치하는 것으로 확인됐습니다.');
    }
    return buf.toString();
  }

  @override
  Widget build(BuildContext context) {
    final risk = _risk;
    return Container(
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(AppRadius.card),
        border: Border.all(color: AppColors.ink200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 12),
            child: Row(
              children: [
                Text('SUMMARY', style: AppText.overline(color: AppColors.ink400)),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: risk.color.withValues(alpha: 0.10),
                    borderRadius: BorderRadius.circular(AppRadius.small),
                    border: Border.all(color: risk.color.withValues(alpha: 0.30)),
                  ),
                  child: Text('위험도 ${risk.label}',
                      style: AppText.mono(size: 10, color: risk.color, weight: FontWeight.w700)),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: Text(
              _summaryText(),
              style: AppText.sans(size: 14, color: AppColors.ink800, height: 1.65, weight: FontWeight.w500),
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────
// Claim-by-claim breakdown
// ─────────────────────────────────────────────────────────────────────────

class _ClaimBreakdown extends StatelessWidget {
  const _ClaimBreakdown({required this.claims, required this.onTapClaim});
  final List<Claim> claims;
  final ValueChanged<Claim> onTapClaim;

  @override
  Widget build(BuildContext context) {
    final ordered = [...claims]..sort((a, b) => a.span.start.compareTo(b.span.start));
    return _Section(
      label: '주장별 분석',
      labelEn: 'CLAIM BREAKDOWN',
      trailing: Text('${claims.length}건', style: AppText.mono(size: 10, color: AppColors.ink400)),
      child: Column(
        children: [
          for (var i = 0; i < ordered.length; i++) ...[
            if (i > 0) const Divider(height: 1),
            _ClaimRow(index: i + 1, claim: ordered[i], onTap: () => onTapClaim(ordered[i])),
          ],
        ],
      ),
    );
  }
}

class _ClaimRow extends StatelessWidget {
  const _ClaimRow({required this.index, required this.claim, required this.onTap});
  final int index;
  final Claim claim;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final fg = Verdict.fg(claim.verdict);
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 22,
              height: 22,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: Verdict.bg(claim.verdict),
                borderRadius: BorderRadius.circular(AppRadius.small),
              ),
              child: Text(Verdict.marker(claim.verdict),
                  style: AppText.mono(size: 11, color: fg, weight: FontWeight.w700)),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(Verdict.label(claim.verdict),
                          style: AppText.sans(size: 12, weight: FontWeight.w700, color: fg)),
                      const SizedBox(width: 8),
                      Text('신뢰도 ${(claim.confidence * 100).toStringAsFixed(0)}%',
                          style: AppText.mono(size: 10, color: AppColors.ink400)),
                      const Spacer(),
                      if (claim.sources.isNotEmpty)
                        Text('출처 ${claim.sources.length}',
                            style: AppText.mono(size: 10, color: AppColors.ink400)),
                    ],
                  ),
                  const SizedBox(height: 5),
                  Text(claim.text,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: AppText.sans(size: 13, color: AppColors.ink800, height: 1.4)),
                  const SizedBox(height: 7),
                  _ConfidenceBar(value: claim.confidence, color: fg),
                ],
              ),
            ),
            const SizedBox(width: 6),
            const Icon(Icons.chevron_right, size: 18, color: AppColors.ink300),
          ],
        ),
      ),
    );
  }
}

class _ConfidenceBar extends StatelessWidget {
  const _ConfidenceBar({required this.value, required this.color});
  final double value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(2),
      child: Stack(
        children: [
          Container(height: 3, color: AppColors.ink100),
          FractionallySizedBox(
            widthFactor: value.clamp(0, 1).toDouble(),
            child: Container(height: 3, color: color.withValues(alpha: 0.7)),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────
// Source index (consolidated references)
// ─────────────────────────────────────────────────────────────────────────

class _SourceIndex extends StatelessWidget {
  const _SourceIndex({required this.claims});
  final List<Claim> claims;

  List<Source> get _unique {
    final byUrl = <String, Source>{};
    for (final c in claims) {
      for (final s in c.sources) {
        final existing = byUrl[s.url];
        if (existing == null || s.trust > existing.trust) byUrl[s.url] = s;
      }
    }
    final list = byUrl.values.toList()..sort((a, b) => b.trust.compareTo(a.trust));
    return list;
  }

  @override
  Widget build(BuildContext context) {
    final sources = _unique;
    return _Section(
      label: '참고 출처',
      labelEn: 'SOURCE INDEX',
      trailing: Text('${sources.length}건', style: AppText.mono(size: 10, color: AppColors.ink400)),
      child: sources.isEmpty
          ? Padding(
              padding: const EdgeInsets.all(16),
              child: Text('인용된 출처가 없습니다.',
                  style: AppText.sans(size: 13, color: AppColors.ink400)),
            )
          : Column(
              children: [
                for (var i = 0; i < sources.length; i++) ...[
                  if (i > 0) const Divider(height: 1),
                  _SourceRow(index: i + 1, source: sources[i]),
                ],
              ],
            ),
    );
  }
}

class _SourceRow extends StatelessWidget {
  const _SourceRow({required this.index, required this.source});
  final int index;
  final Source source;

  @override
  Widget build(BuildContext context) {
    final pct = (source.trust * 100).round();
    final tColor = source.trust >= 0.7
        ? AppColors.verified
        : source.trust >= 0.4
            ? AppColors.unverifiable
            : AppColors.ink400;
    return InkWell(
      onTap: () => launchUrl(Uri.parse(source.url), mode: LaunchMode.externalApplication),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('[$index]', style: AppText.mono(size: 11, color: AppColors.accent, weight: FontWeight.w700)),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(source.title,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: AppText.sans(size: 13, weight: FontWeight.w700, color: AppColors.ink900)),
                      ),
                      const SizedBox(width: 8),
                      Text('신뢰 $pct',
                          style: AppText.mono(size: 10, color: tColor, weight: FontWeight.w700)),
                    ],
                  ),
                  if (source.snippet.isNotEmpty) ...[
                    const SizedBox(height: 3),
                    Text(source.snippet,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: AppText.sans(size: 12, color: AppColors.ink500, height: 1.45)),
                  ],
                  const SizedBox(height: 4),
                  Text(source.url,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppText.mono(size: 10, color: AppColors.accent)),
                ],
              ),
            ),
            const SizedBox(width: 6),
            const Icon(Icons.open_in_new, size: 14, color: AppColors.ink300),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────
// Methodology
// ─────────────────────────────────────────────────────────────────────────

class _Methodology extends StatelessWidget {
  const _Methodology({required this.result});
  final FactCheckResult result;

  @override
  Widget build(BuildContext context) {
    final steps = [
      ('주장 추출', '입력 텍스트를 검증 가능한 개별 사실 주장 단위로 분리합니다.'),
      ('교차 검색', '주장마다 검색어를 생성해 웹의 여러 출처에서 근거를 수집합니다.'),
      ('대조 판정', '수집된 근거와 대조해 확인·반박·검증불가로 판정하고 신뢰도를 매깁니다.'),
    ];
    final sourceCount = result.claims.fold<int>(0, (sum, c) => sum + c.sources.length);
    return _Section(
      label: '검증 방법',
      labelEn: 'METHODOLOGY',
      child: Padding(
        padding: const EdgeInsets.fromLTRB(14, 12, 14, 14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            for (var i = 0; i < steps.length; i++) ...[
              if (i > 0) const SizedBox(height: 12),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 22,
                    height: 22,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: AppColors.accentSoft,
                      borderRadius: BorderRadius.circular(AppRadius.small),
                    ),
                    child: Text('${i + 1}',
                        style: AppText.mono(size: 11, color: AppColors.accent, weight: FontWeight.w700)),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(steps[i].$1,
                            style: AppText.sans(size: 13, weight: FontWeight.w700, color: AppColors.ink900)),
                        const SizedBox(height: 2),
                        Text(steps[i].$2,
                            style: AppText.sans(size: 12, color: AppColors.ink500, height: 1.45)),
                      ],
                    ),
                  ),
                ],
              ),
            ],
            const SizedBox(height: 14),
            const Divider(height: 1),
            const SizedBox(height: 12),
            Text(
              '분석 정보: 주장 ${result.summary.total}건 · 수집 출처 $sourceCount건 · '
              '${result.cached ? '캐시된 결과' : '실시간 분석'}',
              style: AppText.mono(size: 10, color: AppColors.ink400),
            ),
          ],
        ),
      ),
    );
  }
}

// Shared section shell with KO + EN labels and an accent spine.
class _Section extends StatelessWidget {
  const _Section({
    required this.label,
    required this.labelEn,
    required this.child,
    this.trailing,
  });

  final String label;
  final String labelEn;
  final Widget child;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(AppRadius.card),
        border: Border.all(color: AppColors.ink200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            padding: const EdgeInsets.fromLTRB(14, 11, 14, 11),
            decoration: const BoxDecoration(
              color: AppColors.ink50,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(AppRadius.card),
                topRight: Radius.circular(AppRadius.card),
              ),
              border: Border(bottom: BorderSide(color: AppColors.ink200)),
            ),
            child: Row(
              children: [
                Container(width: 3, height: 14, color: AppColors.accent),
                const SizedBox(width: 8),
                Text(label, style: AppText.sans(size: 13, weight: FontWeight.w800, color: AppColors.ink900)),
                const SizedBox(width: 8),
                Text(labelEn, style: AppText.overline(color: AppColors.ink400)),
                const Spacer(),
                if (trailing != null) trailing!,
              ],
            ),
          ),
          child,
        ],
      ),
    );
  }
}

String _shorten(String text, [int max = 24]) =>
    text.length <= max ? text : '${text.substring(0, max)}…';

class _Disclaimer extends StatelessWidget {
  const _Disclaimer();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.ink50,
        borderRadius: BorderRadius.circular(AppRadius.small),
        border: Border.all(color: AppColors.ink200),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.info_outline, size: 14, color: AppColors.ink400),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              '본 리포트는 AI가 자동 생성한 참고 자료이며 법적 효력이 없습니다. '
              '중요한 사안은 반드시 원출처를 직접 확인하시기 바랍니다.',
              style: AppText.sans(size: 11, color: AppColors.ink500, height: 1.5),
            ),
          ),
        ],
      ),
    );
  }
}
