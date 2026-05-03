import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../core/theme.dart';
import '../../data/models/models.dart';

class ClaimDetailSheet extends StatelessWidget {
  const ClaimDetailSheet({super.key, required this.claim});
  final Claim claim;

  @override
  Widget build(BuildContext context) {
    final fg = VerdictColors.foreground(claim.verdict);

    return DraggableScrollableSheet(
      expand: false,
      initialChildSize: 0.6,
      maxChildSize: 0.95,
      builder: (_, controller) => ListView(
        controller: controller,
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
        children: [
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: fg.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(
                  _verdictLabel(claim.verdict),
                  style: TextStyle(color: fg, fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(width: 8),
              Text('신뢰도 ${(claim.confidence * 100).toStringAsFixed(0)}%',
                  style: TextStyle(color: Colors.grey.shade700, fontSize: 12)),
            ],
          ),
          const SizedBox(height: 16),
          const Text('주장', style: TextStyle(fontSize: 12, color: Colors.grey)),
          const SizedBox(height: 4),
          Text(claim.text,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
          if (claim.suggestion != null) ...[
            const SizedBox(height: 20),
            const Text('추천 대체 문장',
                style: TextStyle(fontSize: 12, color: Colors.grey)),
            const SizedBox(height: 4),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: VerdictColors.supported.withValues(alpha: 0.10),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(claim.suggestion!, style: const TextStyle(fontSize: 15)),
            ),
          ],
          const SizedBox(height: 24),
          const Text('근거 출처',
              style: TextStyle(fontSize: 12, color: Colors.grey)),
          const SizedBox(height: 8),
          if (claim.sources.isEmpty)
            const Text('출처를 찾지 못했습니다.', style: TextStyle(color: Colors.grey))
          else
            ...claim.sources.asMap().entries.map((e) => _SourceTile(
                  index: e.key + 1,
                  source: e.value,
                )),
        ],
      ),
    );
  }

  String _verdictLabel(String v) => switch (v) {
        'supported' => '확인됨',
        'refuted' => '의심',
        'unverifiable' => '불확실',
        _ => v,
      };
}

class _SourceTile extends StatelessWidget {
  const _SourceTile({required this.index, required this.source});
  final int index;
  final Source source;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => launchUrl(Uri.parse(source.url),
          mode: LaunchMode.externalApplication),
      borderRadius: BorderRadius.circular(10),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text('[$index] ',
                    style: const TextStyle(fontWeight: FontWeight.bold)),
                Expanded(
                  child: Text(
                    source.title,
                    style: const TextStyle(fontWeight: FontWeight.w600),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Text('신뢰 ${(source.trust * 100).toStringAsFixed(0)}',
                    style: const TextStyle(fontSize: 11, color: Colors.grey)),
              ],
            ),
            const SizedBox(height: 4),
            Text(source.snippet,
                style: TextStyle(color: Colors.grey.shade700, fontSize: 13),
                maxLines: 3,
                overflow: TextOverflow.ellipsis),
            const SizedBox(height: 4),
            Text(source.url,
                style: TextStyle(
                    color: Theme.of(context).colorScheme.primary, fontSize: 12),
                maxLines: 1,
                overflow: TextOverflow.ellipsis),
          ],
        ),
      ),
    );
  }
}
