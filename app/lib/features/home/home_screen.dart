import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme.dart';
import '../../data/check_history_repository.dart';
import '../../state/auth_providers.dart';
import '../../state/providers.dart';
import '../history/history_screen.dart';
import '../input/input_screen.dart';
import '../result/result_screen.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authStateProvider).valueOrNull;
    final scheme = Theme.of(context).colorScheme;
    final stats = ref.watch(checkStatsProvider).valueOrNull ?? CheckStats.empty;
    final history = ref.watch(checkHistoryProvider).valueOrNull ?? const [];
    final displayName = (user?.displayName?.trim().isNotEmpty ?? false)
        ? user!.displayName!
        : (user?.email?.split('@').first ?? '게스트');

    return Scaffold(
      appBar: AppBar(
        title: const Text('FactLens'),
        actions: [
          IconButton(
            tooltip: '검사 기록',
            icon: const Icon(Icons.history),
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const HistoryScreen()),
            ),
          ),
          PopupMenuButton<String>(
            tooltip: '계정',
            position: PopupMenuPosition.under,
            onSelected: (v) async {
              if (v == 'signout') {
                await ref.read(authControllerProvider).signOut();
              }
            },
            itemBuilder: (_) => [
              PopupMenuItem(
                enabled: false,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if ((user?.displayName?.trim().isNotEmpty ?? false))
                      Text(
                        user!.displayName!,
                        style: const TextStyle(
                          color: Color(0xFF111827),
                          fontWeight: FontWeight.w700,
                          fontSize: 14,
                        ),
                      ),
                    Text(
                      user?.email ?? '',
                      style: const TextStyle(
                        color: Color(0xFF6B7280),
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              const PopupMenuDivider(),
              const PopupMenuItem(
                value: 'signout',
                child: Row(
                  children: [
                    Icon(Icons.logout, size: 18),
                    SizedBox(width: 8),
                    Text('로그아웃'),
                  ],
                ),
              ),
            ],
            child: Padding(
              padding: const EdgeInsets.only(right: 12),
              child: Icon(
                Icons.account_circle,
                size: 32,
                color: scheme.primary.withValues(alpha: 0.85),
              ),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 4, 20, 28),
          children: [
            _Greeting(name: displayName),
            const SizedBox(height: 16),
            _StatsRow(stats: stats),
            const SizedBox(height: 16),
            _StartCard(
              onTap: () => Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const InputScreen()),
              ),
            ),
            const SizedBox(height: 24),
            _SectionHeader(
              title: '최근 검사',
              actionLabel: history.length > 4 ? '더보기 →' : null,
              onAction: history.length > 4
                  ? () => Navigator.of(context).push(
                        MaterialPageRoute(builder: (_) => const HistoryScreen()),
                      )
                  : null,
            ),
            const SizedBox(height: 10),
            if (history.isEmpty)
              const _RecentEmpty()
            else
              ...[
                for (var i = 0; i < history.length && i < 4; i++) ...[
                  _RecentCard(
                    item: history[i],
                    onTap: () => _openRecent(context, ref, history[i]),
                  ),
                  if (i < (history.length > 4 ? 3 : history.length - 1))
                    const SizedBox(height: 10),
                ],
              ],
          ],
        ),
      ),
    );
  }

  Future<void> _openRecent(
      BuildContext context, WidgetRef ref, CheckHistoryItem item) async {
    final user = ref.read(authStateProvider).valueOrNull;
    if (user == null) return;
    final messenger = ScaffoldMessenger.of(context);
    final navigator = Navigator.of(context);
    try {
      final result =
          await ref.read(checkHistoryRepoProvider).load(user.uid, item.id);
      ref.read(checkControllerProvider.notifier).setResult(result);
      if (!navigator.mounted) return;
      navigator.push(MaterialPageRoute(builder: (_) => const ResultScreen()));
    } catch (e) {
      messenger.showSnackBar(SnackBar(content: Text('불러오기 실패: $e')));
    }
  }
}

class _Greeting extends StatelessWidget {
  const _Greeting({required this.name});
  final String name;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '안녕하세요, $name 님 👋',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  color: const Color(0xFF111827),
                ),
          ),
          const SizedBox(height: 4),
          Text(
            '오늘은 어떤 글을 검증해볼까요?',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: const Color(0xFF6B7280),
                ),
          ),
        ],
      ),
    );
  }
}

class _StatsRow extends StatelessWidget {
  const _StatsRow({required this.stats});
  final CheckStats stats;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _StatCard(
            label: '누적 검사',
            value: '${stats.totalChecks}',
            unit: '건',
            color: Theme.of(context).colorScheme.primary,
            icon: Icons.task_alt,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _StatCard(
            label: '의심 발견',
            value: '${stats.totalRefuted}',
            unit: '건',
            color: VerdictColors.refuted,
            icon: Icons.report_gmailerrorred,
          ),
        ),
      ],
    );
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard({
    required this.label,
    required this.value,
    required this.unit,
    required this.color,
    required this.icon,
  });

  final String label;
  final String value;
  final String unit;
  final Color color;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(12, 12, 12, 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 14, color: color),
              const SizedBox(width: 4),
              Expanded(
                child: Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: const Color(0xFF6B7280),
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                value,
                style: TextStyle(
                  color: color,
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                  height: 1,
                ),
              ),
              const SizedBox(width: 2),
              Padding(
                padding: const EdgeInsets.only(bottom: 2),
                child: Text(
                  unit,
                  style: const TextStyle(
                    color: Color(0xFF9CA3AF),
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _StartCard extends StatelessWidget {
  const _StartCard({required this.onTap});
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Ink(
        padding: const EdgeInsets.fromLTRB(20, 18, 16, 18),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              scheme.primary,
              scheme.primary.withValues(alpha: 0.78),
            ],
          ),
          boxShadow: [
            BoxShadow(
              color: scheme.primary.withValues(alpha: 0.25),
              blurRadius: 18,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    '검사 시작',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 17,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '붙여넣고 한 번에 사실 여부 확인',
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.85),
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.18),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.arrow_forward, color: Colors.white, size: 22),
            ),
          ],
        ),
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.title, this.actionLabel, this.onAction});

  final String title;
  final String? actionLabel;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(title, style: Theme.of(context).textTheme.titleMedium),
        const Spacer(),
        if (actionLabel != null)
          TextButton(
            onPressed: onAction,
            style: TextButton.styleFrom(
              minimumSize: Size.zero,
              padding: const EdgeInsets.symmetric(horizontal: 4),
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
            child: Text(actionLabel!,
                style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
          ),
      ],
    );
  }
}

class _RecentCard extends StatelessWidget {
  const _RecentCard({required this.item, required this.onTap});

  final CheckHistoryItem item;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final hasIssues = item.summary.refuted > 0;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.fromLTRB(14, 14, 12, 14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFFE5E7EB)),
        ),
        child: Row(
          children: [
            _StatusBadge(
              count: hasIssues ? item.summary.refuted : item.summary.supported,
              isRefuted: hasIssues,
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
                          fontSize: 13.5,
                          height: 1.45,
                        ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      if (item.category != null) ...[
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 7, vertical: 2),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF3F4F6),
                            borderRadius: BorderRadius.circular(999),
                          ),
                          child: Text(
                            item.category!,
                            style: const TextStyle(
                              color: Color(0xFF6B7280),
                              fontSize: 10,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                        const SizedBox(width: 6),
                      ],
                      _MiniDot(
                          count: item.summary.supported,
                          color: VerdictColors.supported),
                      const SizedBox(width: 6),
                      _MiniDot(
                          count: item.summary.refuted,
                          color: VerdictColors.refuted),
                      const SizedBox(width: 6),
                      _MiniDot(
                          count: item.summary.unverifiable,
                          color: VerdictColors.unverifiable),
                      const Spacer(),
                      Text(
                        _relativeTime(item.createdAt),
                        style: const TextStyle(
                          color: Color(0xFF9CA3AF),
                          fontSize: 11,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(width: 2),
            const Icon(Icons.chevron_right,
                color: Color(0xFFD1D5DB), size: 20),
          ],
        ),
      ),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  const _StatusBadge({required this.count, required this.isRefuted});
  final int count;
  final bool isRefuted;

  @override
  Widget build(BuildContext context) {
    final color =
        isRefuted ? VerdictColors.refuted : VerdictColors.supported;
    final label = isRefuted ? '의심' : '확인';
    return Container(
      width: 50,
      height: 54,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.25)),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            '$count',
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.w800,
              fontSize: 18,
              height: 1,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.w700,
              fontSize: 9,
            ),
          ),
        ],
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
  return '${t.month}.${t.day.toString().padLeft(2, '0')}';
}

class _MiniDot extends StatelessWidget {
  const _MiniDot({required this.count, required this.color});
  final int count;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 5,
          height: 5,
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

class _RecentEmpty extends StatelessWidget {
  const _RecentEmpty();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 24),
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: const Color(0xFFFAFAFB),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFEDEFF2), style: BorderStyle.solid),
      ),
      child: Column(
        children: [
          const Icon(Icons.history, color: Color(0xFFD1D5DB), size: 28),
          const SizedBox(height: 6),
          Text(
            '아직 검사 기록이 없어요',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: const Color(0xFF9CA3AF),
                ),
          ),
        ],
      ),
    );
  }
}
