import 'package:cloud_firestore/cloud_firestore.dart';

import '../application/mbti_scorer.dart';
import '../domain/mbti_models.dart';

abstract class MbtiFirestoreRepository {
  Stream<MbtiMiniProgress?> watchProgress(String uid);

  Future<MbtiMiniSession?> loadSession(String uid);

  Future<void> saveProgress({
    required String uid,
    required int answeredCount,
    required int total,
    required Map<String, int> answers,
  });

  Future<void> markCompleted(String uid);

  Future<void> unmarkCompleted(String uid);

  Future<void> clearSession(String uid);

  Future<void> saveResult(String uid, MbtiResultSummary summary);

  Future<MbtiResultSummary?> loadLatestResult(String uid);
}

Map<String, double> _parseDimensionTotals(Map<String, dynamic> data) {
  return {
    for (final key in ['E', 'I', 'S', 'N', 'T', 'F', 'J', 'P'])
      key: (data[key] as num?)?.toDouble() ?? 0,
  };
}

/// Legacy docs: infer 16 / 40 / 80 from dimension score mass when field is absent.
int _inferScoredQuestionCount(Map<String, double> dimensions) {
  return MbtiScorer.inferScoredQuestionCountFromDimensions(dimensions);
}

Future<int> _resolveScoredQuestionCount({
  required DocumentReference<Map<String, dynamic>> resultRef,
  required Map<String, dynamic> data,
  required Map<String, double> dimensions,
}) async {
  final storedCount = (data['scoredQuestionCount'] as num?)?.toInt();
  if (storedCount != null) {
    return storedCount;
  }

  final inferred = _inferScoredQuestionCount(dimensions);
  await resultRef.set({
    'scoredQuestionCount': inferred,
  }, SetOptions(merge: true));
  return inferred;
}

class MbtiFirestoreRepositoryImpl implements MbtiFirestoreRepository {
  MbtiFirestoreRepositoryImpl({FirebaseFirestore? firestore})
    : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;

  DocumentReference<Map<String, dynamic>> _testRef(String uid) {
    return _firestore
        .collection('users')
        .doc(uid)
        .collection('tests')
        .doc(mbtiMiniTestId);
  }

  DocumentReference<Map<String, dynamic>> _resultRef(String uid) {
    return _firestore
        .collection('users')
        .doc(uid)
        .collection('results')
        .doc(mbtiMiniTestId);
  }

  @override
  Stream<MbtiMiniProgress?> watchProgress(String uid) {
    return _testRef(uid).snapshots().map((snap) {
      if (!snap.exists) return null;
      final data = snap.data();
      if (data == null) return null;

      return MbtiMiniProgress(
        answered: (data['answered'] as num?)?.toInt() ?? 0,
        total: (data['total'] as num?)?.toInt() ?? mbtiMiniQuestionCount,
        completed: data['completed'] == true,
      );
    });
  }

  @override
  Future<MbtiMiniSession?> loadSession(String uid) async {
    final doc = await _testRef(uid).get();
    if (!doc.exists) return null;

    final data = doc.data();
    if (data == null) return null;

    final rawAnswers = data['answers'];
    final answers = <String, int>{};
    if (rawAnswers is Map) {
      rawAnswers.forEach((key, value) {
        if (value is num) {
          answers['$key'] = value.toInt();
        }
      });
    }

    return MbtiMiniSession(
      answers: answers,
      answered: (data['answered'] as num?)?.toInt() ?? answers.length,
      total: (data['total'] as num?)?.toInt() ?? mbtiMiniQuestionCount,
      completed: data['completed'] == true,
    );
  }

  @override
  Future<void> saveProgress({
    required String uid,
    required int answeredCount,
    required int total,
    required Map<String, int> answers,
  }) async {
    await _testRef(uid).set({
      'module': mbtiMiniTestId,
      'answered': answeredCount,
      'total': total,
      'answers': answers,
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  @override
  Future<void> markCompleted(String uid) async {
    await _testRef(uid).set({
      'completed': true,
      'completedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  @override
  Future<void> unmarkCompleted(String uid) async {
    await _testRef(uid).set({
      'completed': false,
    }, SetOptions(merge: true));
  }

  @override
  Future<void> clearSession(String uid) async {
    await _testRef(uid).delete();
  }

  @override
  Future<void> saveResult(String uid, MbtiResultSummary summary) async {
    await _resultRef(uid).set({
      ...summary.dimensions,
      'type': summary.type,
      'testId': summary.testId,
      'scoredQuestionCount': summary.scoredQuestionCount,
      'scoringVersion': summary.scoringVersion,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  @override
  Future<MbtiResultSummary?> loadLatestResult(String uid) async {
    final doc = await _resultRef(uid).get();
    if (!doc.exists) return null;

    final data = doc.data();
    if (data == null) return null;

    final dimensions = _parseDimensionTotals(data);

    final storedType = data['type'] as String?;
    final type = storedType ?? MbtiScorer.typeFromDimensions(dimensions);

    final createdAt = data['createdAt'];
    final scoredAt = createdAt is Timestamp
        ? createdAt.toDate()
        : DateTime.now();

    final scoredQuestionCount = await _resolveScoredQuestionCount(
      resultRef: _resultRef(uid),
      data: data,
      dimensions: dimensions,
    );

    return MbtiResultSummary(
      testId: data['testId'] as String? ?? mbtiMiniTestId,
      type: type,
      dimensions: dimensions,
      scoredAt: scoredAt,
      scoringVersion:
          (data['scoringVersion'] as num?)?.toInt() ?? mbtiMiniScoringVersion,
      scoredQuestionCount: scoredQuestionCount,
    );
  }
}
