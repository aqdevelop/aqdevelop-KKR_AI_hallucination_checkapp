import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme.dart';
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
        title: const Text('검사 결과'),
        actions: [
          if (edited != null)
            IconButton(
              tooltip: '수정본 복사',
              icon: const Icon(Icons.copy_all_outlined),
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
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('수정본을 클립보드에 복사했어요'),
        duration: Duration(seconds: 2),
      ),
    );
  }
}

class _ResultBody extends ConsumerWidget {
  const _ResultBody({required this.edited});
  final EditedResult edited;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Column(
      children: [
        _SummaryCard(summary: edited.base.summary),
        if (edited.fixableCount > 0)
          _FixActionBar(
            pending: edited.pendingFixCount,
            applied: edited.appliedCount,
            onApplyAll: () => _applyAll(context, ref),
            onUndoAll: () => _undoAll(context, ref),
          ),
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
            child: Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: const Color(0xFFE5E7EB)),
              ),
              child: HighlightedText(
                text: edited.currentText,
                claims: edited.currentClaims,
                onTapClaim: (claim) => _openClaim(context, ref, claim),
              ),
            ),
          ),
        ),
      ],
    );
  }

  void _openClaim(BuildContext context, WidgetRef ref, Claim claim) {
    final controller = ref.read(editedResultProvider.notifier);
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Theme.of(context).colorScheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
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
    final messenger = ScaffoldMessenger.of(context);
    messenger.hideCurrentSnackBar();
    messenger.showSnackBar(
      SnackBar(
        content: const Text('수정이 적용됐어요'),
        duration: const Duration(seconds: 3),
        action: SnackBarAction(
          label: '되돌리기',
          onPressed: () => ref.read(editedResultProvider.notifier).undoFix(claimId),
        ),
      ),
    );
  }

  void _applyAll(BuildContext context, WidgetRef ref) {
    final before = ref.read(editedResultProvider)?.appliedFixIds ?? const <String>{};
    ref.read(editedResultProvider.notifier).applyAll();
    final after = ref.read(editedResultProvider)?.appliedFixIds ?? const <String>{};
    final added = after.length - before.length;
    if (added <= 0) return;
    final messenger = ScaffoldMessenger.of(context);
    messenger.hideCurrentSnackBar();
    messenger.showSnackBar(
      SnackBar(
        content: Text('AI 추천 수정 $added건을 적용했어요'),
        duration: const Duration(seconds: 3),
        action: SnackBarAction(
          label: '모두 되돌리기',
          onPressed: () => ref.read(editedResultProvider.notifier).undoAll(),
        ),
      ),
    );
  }

  void _undoAll(BuildContext context, WidgetRef ref) {
    ref.read(editedResultProvider.notifier).undoAll();
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(const SnackBar(
        content: Text('원본으로 되돌렸어요'),
        duration: Duration(seconds: 2),
      ));
  }
}

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
    final scheme = Theme.of(context).colorScheme;
    return Container(
      margin: const EdgeInsets.fromLTRB(20, 0, 20, 4),
      padding: const EdgeInsets.fromLTRB(14, 10, 10, 10),
      decoration: BoxDecoration(
        color: scheme.primary.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: scheme.primary.withValues(alpha: 0.18)),
      ),
      child: Row(
        children: [
          Icon(Icons.auto_fix_high, size: 16, color: scheme.primary),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              applied > 0
                  ? '수정 $applied건 적용됨${pending > 0 ? ' · 남은 추천 $pending건' : ''}'
                  : 'AI 추천 수정 $pending건 있어요',
              style: TextStyle(
                color: scheme.primary,
                fontWeight: FontWeight.w700,
                fontSize: 12.5,
              ),
            ),
          ),
          if (applied > 0)
            TextButton(
              onPressed: onUndoAll,
              style: TextButton.styleFrom(
                minimumSize: Size.zero,
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                foregroundColor: const Color(0xFF6B7280),
                textStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700),
              ),
              child: const Text('원본'),
            ),
          if (pending > 0) ...[
            const SizedBox(width: 4),
            FilledButton(
              onPressed: onApplyAll,
              style: FilledButton.styleFrom(
                minimumSize: Size.zero,
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(999),
                ),
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

class _SummaryCard extends StatelessWidget {
  const _SummaryCard({required this.summary});
  final Summary summary;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      margin: const EdgeInsets.fromLTRB(20, 12, 20, 8),
      padding: const EdgeInsets.fromLTRB(20, 18, 20, 18),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            scheme.primary.withValues(alpha: 0.08),
            scheme.primary.withValues(alpha: 0.02),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: scheme.primary.withValues(alpha: 0.15)),
      ),
      child: Row(
        children: [
          _ScoreCircle(score: summary.trustScore),
          const SizedBox(width: 18),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '신뢰 점수',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: const Color(0xFF6B7280),
                        fontSize: 12,
                      ),
                ),
                const SizedBox(height: 2),
                Text(
                  '주장 ${summary.total}개 분석됨',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 10),
                Wrap(
                  spacing: 6,
                  runSpacing: 6,
                  children: [
                    _Pill(
                      count: summary.supported,
                      label: '확인',
                      color: VerdictColors.supported,
                    ),
                    _Pill(
                      count: summary.refuted,
                      label: '의심',
                      color: VerdictColors.refuted,
                    ),
                    _Pill(
                      count: summary.unverifiable,
                      label: '불확실',
                      color: VerdictColors.unverifiable,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ScoreCircle extends StatelessWidget {
  const _ScoreCircle({required this.score});
  final double score;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      width: 76,
      height: 76,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: scheme.primary,
        boxShadow: [
          BoxShadow(
            color: scheme.primary.withValues(alpha: 0.25),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            score.toStringAsFixed(0),
            style: const TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.w800,
              color: Colors.white,
              height: 1,
            ),
          ),
          const SizedBox(height: 2),
          const Text(
            '/ 100',
            style: TextStyle(fontSize: 10, color: Colors.white70),
          ),
        ],
      ),
    );
  }
}

class _Pill extends StatelessWidget {
  const _Pill({required this.count, required this.label, required this.color});
  final int count;
  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: color.withValues(alpha: 0.30)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 6,
            height: 6,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
          const SizedBox(width: 6),
          Text(
            '$label $count',
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.w700,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}
