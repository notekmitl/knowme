import 'package:cloud_firestore/cloud_firestore.dart';

import '../domain/eq_models.dart';

abstract class EqFirestoreRepository {
  Future<EqTestSession?> loadSession(String uid, String testId);

  Future<void> saveProgress({
    required String uid,
    required String testId,
    required int answeredCount,
    required int index,
    required int total,
    required Map<String, int> answers,
  });

  Future<void> markCompleted(String uid, String testId);

  Future<void> clearSession(String uid, String testId);

  Future<void> saveResult(String uid, EqResultSummary summary);

  Future<EqResultSummary?> loadLatestResult(String uid, String testId);
}

class EqFirestoreRepositoryImpl implements EqFirestoreRepository {
  EqFirestoreRepositoryImpl({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;

  DocumentReference<Map<String, dynamic>> _testRef(String uid, String testId) {
    return _firestore
        .collection('users')
        .doc(uid)
        .collection('tests')
        .doc(testId);
  }

  DocumentReference<Map<String, dynamic>> _resultRef(String uid, String testId) {
    return _firestore
        .collection('users')
        .doc(uid)
        .collection('results')
        .doc(testId);
  }

  @override
  Future<EqTestSession?> loadSession(String uid, String testId) async {
    final doc = await _testRef(uid, testId).get();
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

    final answered =
        (data['answered'] as num?)?.toInt() ?? answers.length;
    final total = (data['total'] as num?)?.toInt() ?? answered;

    return EqTestSession(
      answers: answers,
      answered: answered,
      index: (data['index'] as num?)?.toInt() ?? answered,
      total: total,
      completed: data['completed'] == true,
    );
  }

  @override
  Future<void> saveProgress({
    required String uid,
    required String testId,
    required int answeredCount,
    required int index,
    required int total,
    required Map<String, int> answers,
  }) async {
    await _testRef(uid, testId).set({
      'module': testId,
      'answered': answeredCount,
      'index': index,
      'total': total,
      'completed': false,
      'answers': answers,
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  @override
  Future<void> markCompleted(String uid, String testId) async {
    await _testRef(uid, testId).set({
      'completed': true,
      'completedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  /// Clears working state only (`tests/*`). Keeps `results/*` snapshot.
  @override
  Future<void> clearSession(String uid, String testId) async {
    await _testRef(uid, testId).delete();
  }

  @override
  Future<void> saveResult(String uid, EqResultSummary summary) async {
    await _resultRef(uid, summary.testId).set({
      'testId': summary.testId,
      'averageScore': summary.averageScore,
      'level': summary.level,
      'scoredQuestionCount': summary.scoredQuestionCount,
      'scoringVersion': summary.scoringVersion,
      'completedAt': FieldValue.serverTimestamp(),
    });
  }

  @override
  Future<EqResultSummary?> loadLatestResult(String uid, String testId) async {
    final doc = await _resultRef(uid, testId).get();
    if (!doc.exists) return null;

    final data = doc.data();
    if (data == null) return null;

    DateTime? completedAt;
    final rawCompleted = data['completedAt'];
    if (rawCompleted is Timestamp) {
      completedAt = rawCompleted.toDate();
    } else if (rawCompleted is DateTime) {
      completedAt = rawCompleted;
    }

    return EqResultSummary(
      testId: (data['testId'] as String?) ?? testId,
      averageScore: (data['averageScore'] as num?)?.toDouble() ?? 0,
      level: (data['level'] as String?) ?? EqLevelIds.moderate,
      scoredQuestionCount: (data['scoredQuestionCount'] as num?)?.toInt() ?? 0,
      scoringVersion:
          (data['scoringVersion'] as num?)?.toInt() ?? eqScoringVersion,
      completedAt: completedAt,
    );
  }
}
