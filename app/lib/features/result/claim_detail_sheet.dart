import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../core/theme.dart';
import '../../data/models/models.dart';
import 'edited_result.dart';

class ClaimDetailSheet extends StatelessWidget {
  const ClaimDetailSheet({
    super.key,
    required this.claim,
    required this.isFixed,
    this.onApply,
    this.onUndo,
  });

  final Claim claim;
  final bool isFixed;
  final VoidCallback? onApply;
  final VoidCallback? onUndo;

  bool get _canApply => EditedResult.canApply(claim);

  @override
  Widget build(BuildContext context) {
    final fg = VerdictColors.foreground(claim.verdict);
    final bg = VerdictColors.background(claim.verdict);

    return DraggableScrollableSheet(
      expand: false,
      initialChildSize: 0.65,
      maxChildSize: 0.95,
      minChildSize: 0.4,
      builder: (_, controller) => Stack(
        children: [
          ListView(
            controller: controller,
            padding: EdgeInsets.fromLTRB(24, 12, 24, _canApply ? 110 : 32),
            children: [
              Center(
                child: Container(
                  width: 44,
                  height: 4,
                  decoration: BoxDecoration(
                    color: const Color(0xFFD1D5DB),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 18),
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: bg,
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 6,
                          height: 6,
                          decoration: BoxDecoration(color: fg, shape: BoxShape.circle),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          VerdictColors.label(claim.verdict),
                          style: TextStyle(
                            color: fg,
                            fontWeight: FontWeight.w700,
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 10),
                  Text(
                    '신뢰도 ${(claim.confidence * 100).toStringAsFixed(0)}%',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: const Color(0xFF6B7280),
                          fontSize: 12,
                        ),
                  ),
                  const Spacer(),
                  if (isFixed)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                      decoration: BoxDecoration(
                        color: VerdictColors.supported.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(999),
                        border: Border.all(
                          color: VerdictColors.supported.withValues(alpha: 0.35),
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.check_circle,
                              size: 14, color: VerdictColors.supported),
                          const SizedBox(width: 4),
                          Text(
                            '수정 적용됨',
                            style: TextStyle(
                              color: VerdictColors.supported,
                              fontWeight: FontWeight.w700,
                              fontSize: 11,
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 18),
              const _SectionLabel(text: '주장'),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: const Color(0xFFF9FAFB),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFFE5E7EB)),
                ),
                child: Text(
                  claim.text,
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        fontWeight: FontWeight.w600,
                        decoration: isFixed ? TextDecoration.lineThrough : null,
                        color: isFixed ? const Color(0xFF9CA3AF) : null,
                      ),
                ),
              ),
              if (claim.suggestion != null && claim.suggestion!.trim().isNotEmpty) ...[
                const SizedBox(height: 22),
                _SectionLabel(
                  text: isFixed ? '적용된 대체 문장' : '추천 대체 문장',
                  icon: Icons.auto_awesome,
                ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: VerdictColors.supported.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: VerdictColors.supported.withValues(alpha: 0.25),
                    ),
                  ),
                  child: Text(
                    claim.suggestion!,
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          color: const Color(0xFF065F46),
                        ),
                  ),
                ),
              ],
              const SizedBox(height: 24),
              Row(
                children: [
                  const _SectionLabel(text: '근거 출처'),
                  const SizedBox(width: 6),
                  Text(
                    '· ${claim.sources.length}개',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: const Color(0xFF9CA3AF),
                          fontSize: 12,
                        ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              if (claim.sources.isEmpty)
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF9FAFB),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Text(
                    '출처를 찾지 못했습니다.',
                    style: TextStyle(color: Color(0xFF9CA3AF)),
                  ),
                )
              else
                ...claim.sources.asMap().entries.map((e) => _SourceTile(
                      index: e.key + 1,
                      source: e.value,
                    )),
            ],
          ),
          if (_canApply)
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: _ActionBar(
                isFixed: isFixed,
                onApply: () {
                  Navigator.of(context).maybePop();
                  onApply?.call();
                },
                onUndo: () {
                  Navigator.of(context).maybePop();
                  onUndo?.call();
                },
              ),
            ),
        ],
      ),
    );
  }
}

class _ActionBar extends StatelessWidget {
  const _ActionBar({
    required this.isFixed,
    required this.onApply,
    required this.onUndo,
  });

  final bool isFixed;
  final VoidCallback onApply;
  final VoidCallback onUndo;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
      decoration: BoxDecoration(
        color: scheme.surface,
        border: const Border(
          top: BorderSide(color: Color(0xFFE5E7EB)),
        ),
      ),
      child: SafeArea(
        top: false,
        child: isFixed
            ? OutlinedButton.icon(
                onPressed: onUndo,
                icon: const Icon(Icons.undo, size: 18),
                label: const Text('원래 표현으로 되돌리기'),
                style: OutlinedButton.styleFrom(
                  minimumSize: const Size.fromHeight(50),
                  foregroundColor: const Color(0xFF374151),
                  side: const BorderSide(color: Color(0xFFD1D5DB)),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                  textStyle: const TextStyle(
                      fontSize: 15, fontWeight: FontWeight.w700),
                ),
              )
            : FilledButton.icon(
                onPressed: onApply,
                icon: const Icon(Icons.auto_fix_high, size: 18),
                label: const Text('이 표현으로 바꾸기'),
                style: FilledButton.styleFrom(
                  minimumSize: const Size.fromHeight(50),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
              ),
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  const _SectionLabel({required this.text, this.icon});
  final String text;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        if (icon != null) ...[
          Icon(icon, size: 14, color: const Color(0xFF6B7280)),
          const SizedBox(width: 4),
        ],
        Text(
          text,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: const Color(0xFF374151),
                fontSize: 13,
              ),
        ),
      ],
    );
  }
}

class _SourceTile extends StatelessWidget {
  const _SourceTile({required this.index, required this.source});
  final int index;
  final Source source;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Material(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        child: InkWell(
          onTap: () => launchUrl(
            Uri.parse(source.url),
            mode: LaunchMode.externalApplication,
          ),
          borderRadius: BorderRadius.circular(14),
          child: Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: const Color(0xFFE5E7EB)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 22,
                      height: 22,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: scheme.primary.withValues(alpha: 0.10),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        '$index',
                        style: TextStyle(
                          color: scheme.primary,
                          fontWeight: FontWeight.w700,
                          fontSize: 12,
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        source.title,
                        style: const TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 14,
                          color: Color(0xFF111827),
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 8),
                    _TrustBadge(trust: source.trust),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  source.snippet,
                  style: const TextStyle(
                    color: Color(0xFF4B5563),
                    fontSize: 13,
                    height: 1.5,
                  ),
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 6),
                Text(
                  source.url,
                  style: TextStyle(
                    color: scheme.primary,
                    fontSize: 11,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _TrustBadge extends StatelessWidget {
  const _TrustBadge({required this.trust});
  final double trust;

  @override
  Widget build(BuildContext context) {
    final pct = (trust * 100).round();
    final color = trust >= 0.7
        ? VerdictColors.supported
        : trust >= 0.4
            ? VerdictColors.unverifiable
            : const Color(0xFF9CA3AF);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        '신뢰 $pct',
        style: TextStyle(
          color: color,
          fontSize: 10,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}
