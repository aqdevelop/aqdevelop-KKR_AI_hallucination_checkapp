import '../models/models.dart';

class MockFactCheckApi {
  Future<FactCheckResult> check(String text, {String language = 'ko'}) async {
    await Future<void>.delayed(const Duration(milliseconds: 800));

    final sentences = _splitSentences(text);
    final claims = <Claim>[];
    var cursor = 0;
    for (var i = 0; i < sentences.length && i < 6; i++) {
      final s = sentences[i];
      final start = text.indexOf(s, cursor);
      final from = start < 0 ? cursor : start;
      final end = from + s.length;
      cursor = end;

      final verdict = switch (i % 4) {
        0 => 'supported',
        1 => 'supported',
        2 => 'refuted',
        _ => 'unverifiable',
      };
      claims.add(Claim(
        id: 'c${i + 1}',
        text: s,
        span: Span(start: from, end: end),
        verdict: verdict,
        confidence: verdict == 'refuted' ? 0.86 : 0.78,
        sources: [
          Source(
            url: 'https://ko.wikipedia.org/wiki/예시',
            title: '위키백과 — 예시 항목',
            snippet: '이 스니펫은 모의 데이터입니다. 실제 검색 결과로 교체됩니다.',
            trust: 0.85,
          ),
          Source(
            url: 'https://www.yna.co.kr/view/mock',
            title: '연합뉴스 — 관련 보도',
            snippet: '모의 뉴스 본문 일부.',
            trust: 0.85,
          ),
        ],
        suggestion: verdict == 'refuted'
            ? '(교정 예시) 이 문장은 출처에 따르면 다르게 서술됩니다. [1]'
            : null,
      ));
    }

    final supported = claims.where((c) => c.verdict == 'supported').length;
    final refuted = claims.where((c) => c.verdict == 'refuted').length;
    final unverifiable = claims.where((c) => c.verdict == 'unverifiable').length;
    final score = claims.isEmpty
        ? 0.0
        : (supported * 1.0 + unverifiable * 0.5) / claims.length * 100.0;

    return FactCheckResult(
      originalText: text,
      claims: claims,
      summary: Summary(
        total: claims.length,
        supported: supported,
        refuted: refuted,
        unverifiable: unverifiable,
        trustScore: double.parse(score.toStringAsFixed(1)),
      ),
      cached: false,
    );
  }

  List<String> _splitSentences(String text) {
    final raw = text.replaceAll('\n', ' ').split(RegExp(r'(?<=[.!?。])\s+'));
    return raw.map((s) => s.trim()).where((s) => s.length > 4).toList();
  }
}
