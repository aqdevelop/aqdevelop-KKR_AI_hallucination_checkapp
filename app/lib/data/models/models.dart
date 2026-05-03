class Span {
  final int start;
  final int end;
  const Span({required this.start, required this.end});

  factory Span.fromJson(Map<String, dynamic> json) =>
      Span(start: json['start'] as int, end: json['end'] as int);
}

class Source {
  final String url;
  final String title;
  final String snippet;
  final double trust;

  const Source({
    required this.url,
    required this.title,
    required this.snippet,
    required this.trust,
  });

  factory Source.fromJson(Map<String, dynamic> json) => Source(
        url: json['url'] as String,
        title: json['title'] as String? ?? '',
        snippet: json['snippet'] as String? ?? '',
        trust: (json['trust'] as num?)?.toDouble() ?? 0.0,
      );
}

class Claim {
  final String id;
  final String text;
  final Span span;
  final String verdict; // supported | refuted | unverifiable
  final double confidence;
  final List<Source> sources;
  final String? suggestion;

  const Claim({
    required this.id,
    required this.text,
    required this.span,
    required this.verdict,
    required this.confidence,
    required this.sources,
    this.suggestion,
  });

  factory Claim.fromJson(Map<String, dynamic> json) => Claim(
        id: json['id'] as String,
        text: json['text'] as String,
        span: Span.fromJson(json['span'] as Map<String, dynamic>),
        verdict: json['verdict'] as String,
        confidence: (json['confidence'] as num?)?.toDouble() ?? 0.0,
        sources: ((json['sources'] as List?) ?? [])
            .map((e) => Source.fromJson(e as Map<String, dynamic>))
            .toList(),
        suggestion: json['suggestion'] as String?,
      );
}

class Summary {
  final int total;
  final int supported;
  final int refuted;
  final int unverifiable;
  final double trustScore;

  const Summary({
    required this.total,
    required this.supported,
    required this.refuted,
    required this.unverifiable,
    required this.trustScore,
  });

  factory Summary.fromJson(Map<String, dynamic> json) => Summary(
        total: json['total'] as int,
        supported: json['supported'] as int,
        refuted: json['refuted'] as int,
        unverifiable: json['unverifiable'] as int,
        trustScore: (json['trust_score'] as num?)?.toDouble() ?? 0.0,
      );
}

class FactCheckResult {
  final String originalText;
  final List<Claim> claims;
  final Summary summary;
  final bool cached;

  const FactCheckResult({
    required this.originalText,
    required this.claims,
    required this.summary,
    required this.cached,
  });

  factory FactCheckResult.fromJson(String originalText, Map<String, dynamic> json) =>
      FactCheckResult(
        originalText: originalText,
        claims: ((json['claims'] as List?) ?? [])
            .map((e) => Claim.fromJson(e as Map<String, dynamic>))
            .toList(),
        summary: Summary.fromJson(json['summary'] as Map<String, dynamic>),
        cached: json['cached'] as bool? ?? false,
      );
}
