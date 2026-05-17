import 'package:cloud_firestore/cloud_firestore.dart';

import 'models/models.dart';

const checkCategories = <String>['뉴스', '리뷰', '광고', 'SNS/숏츠', '기타'];

class CheckHistoryItem {
  final String id;
  final String preview;
  final DateTime createdAt;
  final Summary summary;
  final String? category;

  const CheckHistoryItem({
    required this.id,
    required this.preview,
    required this.createdAt,
    required this.summary,
    this.category,
  });
}

class CheckStats {
  final int totalChecks;
  final int totalRefuted;
  final double avgTrustScore;

  const CheckStats({
    required this.totalChecks,
    required this.totalRefuted,
    required this.avgTrustScore,
  });

  static const empty = CheckStats(totalChecks: 0, totalRefuted: 0, avgTrustScore: 0);
}

class CheckHistoryRepository {
  CheckHistoryRepository(this._firestore);

  final FirebaseFirestore _firestore;

  DocumentReference<Map<String, dynamic>> _userDoc(String uid) =>
      _firestore.collection('users').doc(uid);

  CollectionReference<Map<String, dynamic>> _checksOf(String uid) =>
      _userDoc(uid).collection('checks');

  Future<String> save(String uid, FactCheckResult result, {String? category}) async {
    final preview = result.originalText.length > 80
        ? '${result.originalText.substring(0, 80)}…'
        : result.originalText;
    final batch = _firestore.batch();
    final newDoc = _checksOf(uid).doc();
    batch.set(newDoc, {
      'preview': preview,
      'originalText': result.originalText,
      'summary': result.summary.toJson(),
      'claims': result.claims.map((c) => c.toJson()).toList(),
      'cached': result.cached,
      if (category != null) 'category': category,
      'createdAt': FieldValue.serverTimestamp(),
    });
    batch.set(_userDoc(uid), {
      'stats': {
        'totalChecks': FieldValue.increment(1),
        'totalRefuted': FieldValue.increment(result.summary.refuted),
        'trustScoreSum': FieldValue.increment(result.summary.trustScore),
      },
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
    await batch.commit();
    return newDoc.id;
  }

  Stream<List<CheckHistoryItem>> watch(String uid) {
    return _checksOf(uid)
        .orderBy('createdAt', descending: true)
        .limit(50)
        .snapshots()
        .map((snap) => snap.docs.map(_toItem).toList());
  }

  Stream<CheckStats> watchStats(String uid) {
    return _userDoc(uid).snapshots().map((snap) {
      final data = snap.data();
      if (data == null) return CheckStats.empty;
      final s = data['stats'] as Map<String, dynamic>?;
      if (s == null) return CheckStats.empty;
      final total = (s['totalChecks'] as num?)?.toInt() ?? 0;
      final refuted = (s['totalRefuted'] as num?)?.toInt() ?? 0;
      final trustSum = (s['trustScoreSum'] as num?)?.toDouble() ?? 0.0;
      return CheckStats(
        totalChecks: total,
        totalRefuted: refuted,
        avgTrustScore: total == 0 ? 0 : trustSum / total,
      );
    });
  }

  Future<FactCheckResult> load(String uid, String docId) async {
    final snap = await _checksOf(uid).doc(docId).get();
    final data = snap.data();
    if (data == null) {
      throw StateError('Check not found: $docId');
    }
    return FactCheckResult(
      originalText: data['originalText'] as String? ?? '',
      summary: Summary.fromJson(data['summary'] as Map<String, dynamic>),
      claims: ((data['claims'] as List?) ?? [])
          .map((e) => Claim.fromJson(e as Map<String, dynamic>))
          .toList(),
      cached: data['cached'] as bool? ?? false,
    );
  }

  Future<void> delete(String uid, String docId) async {
    await _checksOf(uid).doc(docId).delete();
  }

  CheckHistoryItem _toItem(QueryDocumentSnapshot<Map<String, dynamic>> doc) {
    final d = doc.data();
    final ts = d['createdAt'];
    return CheckHistoryItem(
      id: doc.id,
      preview: d['preview'] as String? ?? '',
      createdAt: ts is Timestamp ? ts.toDate() : DateTime.now(),
      summary: Summary.fromJson(d['summary'] as Map<String, dynamic>),
      category: d['category'] as String?,
    );
  }
}
