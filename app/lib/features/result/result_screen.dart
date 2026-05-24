import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

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
        const SizedBox(height: 20),
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
