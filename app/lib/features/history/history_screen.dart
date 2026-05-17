import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme.dart';
import '../../data/check_history_repository.dart';
import '../../state/auth_providers.dart';
import '../../state/providers.dart';
import '../result/result_screen.dart';

class HistoryScreen extends ConsumerWidget {
  const HistoryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final history = ref.watch(checkHistoryProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('검사 기록')),
      body: history.when(
        data: (items) {
          if (items.isEmpty) return const _Empty();
          return ListView.separated(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
            itemCount: items.length,
            separatorBuilder: (_, __) => const SizedBox(height: 10),
            itemBuilder: (_, i) => _HistoryCard(
              item: items[i],
              onTap: () => _open(context, ref, items[i]),
              onDelete: () => _confirmDelete(context, ref, items[i]),
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Text('기록을 불러오지 못했어요\n$e', textAlign: TextAlign.center),
          ),
        ),
      ),
    );
  }

  Future<void> _open(BuildContext context, WidgetRef ref, CheckHistoryItem item) async {
    final user = ref.read(authStateProvider).valueOrNull;
    if (user == null) return;
    final messenger = ScaffoldMessenger.of(context);
    final navigator = Navigator.of(context);
    try {
      final result = await ref.read(checkHistoryRepoProvider).load(user.uid, item.id);
      ref.read(checkControllerProvider.notifier).setResult(result);
      if (!navigator.mounted) return;
      navigator.push(MaterialPageRoute(builder: (_) => const ResultScreen()));
    } catch (e) {
      messenger.showSnackBar(SnackBar(content: Text('불러오기 실패: $e')));
    }
  }

  Future<void> _confirmDelete(BuildContext context, WidgetRef ref, CheckHistoryItem item) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('이 기록을 삭제할까요?'),
        content: Text(item.preview, maxLines: 3, overflow: TextOverflow.ellipsis),
        actions: [
          TextButton(onPressed: () => Navigator.pop(_, false), child: const Text('취소')),
          TextButton(
            onPressed: () => Navigator.pop(_, true),
            child: const Text('삭제', style: TextStyle(color: Color(0xFFE11D48))),
          ),
        ],
      ),
    );
    if (ok != true) return;
    final user = ref.read(authStateProvider).valueOrNull;
    if (user == null) return;
    await ref.read(checkHistoryRepoProvider).delete(user.uid, item.id);
  }
}

class _HistoryCard extends StatelessWidget {
  const _HistoryCard({required this.item, required this.onTap, required this.onDelete});

  final CheckHistoryItem item;
  final VoidCallback onTap;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.fromLTRB(16, 14, 12, 14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFFE5E7EB)),
        ),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: scheme.primary.withValues(alpha: 0.10),
              ),
              child: Text(
                item.summary.trustScore.toStringAsFixed(0),
                style: TextStyle(
                  color: scheme.primary,
                  fontWeight: FontWeight.w800,
                  fontSize: 15,
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.preview,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: const Color(0xFF111827),
                        ),
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      _Mini(count: item.summary.supported, color: VerdictColors.supported),
                      const SizedBox(width: 6),
                      _Mini(count: item.summary.refuted, color: VerdictColors.refuted),
                      const SizedBox(width: 6),
                      _Mini(count: item.summary.unverifiable, color: VerdictColors.unverifiable),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          _relativeTime(item.createdAt),
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                color: const Color(0xFF9CA3AF),
                                fontSize: 12,
                              ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            IconButton(
              tooltip: '삭제',
              icon: const Icon(Icons.delete_outline, size: 20),
              color: const Color(0xFF9CA3AF),
              onPressed: onDelete,
            ),
          ],
        ),
      ),
    );
  }
}

class _Mini extends StatelessWidget {
  const _Mini({required this.count, required this.color});
  final int count;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 6,
          height: 6,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 3),
        Text(
          '$count',
          style: TextStyle(color: color, fontWeight: FontWeight.w700, fontSize: 11),
        ),
      ],
    );
  }
}

class _Empty extends StatelessWidget {
  const _Empty();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.history, size: 48, color: const Color(0xFFD1D5DB)),
            const SizedBox(height: 12),
            Text(
              '아직 검사 기록이 없어요',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: const Color(0xFF6B7280),
                  ),
            ),
            const SizedBox(height: 6),
            Text(
              '대본을 검사하면 여기에 자동으로 쌓여요.',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: const Color(0xFF9CA3AF),
                  ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

String _relativeTime(DateTime t) {
  final diff = DateTime.now().difference(t);
  if (diff.inSeconds < 60) return '방금';
  if (diff.inMinutes < 60) return '${diff.inMinutes}분 전';
  if (diff.inHours < 24) return '${diff.inHours}시간 전';
  if (diff.inDays < 7) return '${diff.inDays}일 전';
  return '${t.year}.${t.month.toString().padLeft(2, '0')}.${t.day.toString().padLeft(2, '0')}';
}
