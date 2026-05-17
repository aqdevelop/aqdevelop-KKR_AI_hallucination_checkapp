import 'package:cloud_firestore/cloud_firestore.dart';

import 'models/models.dart';

class CheckHistoryItem {
  final String id;
  final String preview;
  final DateTime createdAt;
  final Summary summary;

  const CheckHistoryItem({
    required this.id,
    required this.preview,
    required this.createdAt,
    required this.summary,
  });
}

class CheckHistoryRepository {
  CheckHistoryRepository(this._firestore);

  final FirebaseFirestore _firestore;

  CollectionReference<Map<String, dynamic>> _checksOf(String uid) =>
      _firestore.collection('users').doc(uid).collection('checks');

  Future<String> save(String uid, FactCheckResult result) async {
    final preview = result.originalText.length > 80
        ? '${result.originalText.substring(0, 80)}…'
        : result.originalText;
    final doc = await _checksOf(uid).add({
      'preview': preview,
      'originalText': result.originalText,
      'summary': result.summary.toJson(),
      'claims': result.claims.map((c) => c.toJson()).toList(),
      'cached': result.cached,
      'createdAt': FieldValue.serverTimestamp(),
    });
    return doc.id;
  }

  Stream<List<CheckHistoryItem>> watch(String uid) {
    return _checksOf(uid)
        .orderBy('createdAt', descending: true)
        .limit(50)
        .snapshots()
        .map((snap) => snap.docs.map(_toItem).toList());
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
    );
  }
}
