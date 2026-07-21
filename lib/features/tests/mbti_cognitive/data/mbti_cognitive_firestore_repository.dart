import 'package:cloud_firestore/cloud_firestore.dart';

import '../application/mbti_cognitive_scorer.dart';
import '../domain/mbti_cognitive_models.dart';

abstract class MbtiCognitiveFirestoreRepository {
  Future<MbtiCognitiveSession?> loadSession(String uid);

  Future<void> saveProgress({
    required String uid,
    required int answeredCount,
    required int total,
    required Map<String, int> answers,
  });

  Future<void> markCompleted(String uid);

  Future<void> unmarkCompleted(String uid);

  Future<void> clearSession(String uid);

  Future<void> saveResult(String uid, MbtiCognitiveResultSummary summary);

  Future<MbtiCognitiveResultSummary?> loadLatestResult(String uid);
}

class MbtiCognitiveFirestoreRepositoryImpl
    implements MbtiCognitiveFirestoreRepository {
  MbtiCognitiveFirestoreRepositoryImpl({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;

  DocumentReference<Map<String, dynamic>> _testRef(String uid) {
    return _firestore
        .collection('users')
        .doc(uid)
        .collection('tests')
        .doc(mbtiCognitiveTestId);
  }

  DocumentReference<Map<String, dynamic>> _resultRef(String uid) {
    return _firestore
        .collection('users')
        .doc(uid)
        .collection('results')
        .doc(mbtiCognitiveTestId);
  }

  @override
  Future<MbtiCognitiveSession?> loadSession(String uid) async {
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

    return MbtiCognitiveSession(
      answers: answers,
      answered: (data['answered'] as num?)?.toInt() ?? answers.length,
      total: (data['total'] as num?)?.toInt() ?? mbtiCognitiveAccurateCheckpoint,
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
      'module': mbtiCognitiveTestId,
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
  Future<void> saveResult(String uid, MbtiCognitiveResultSummary summary) async {
    await _resultRef(uid).set({
      'testId': summary.testId,
      'scores': summary.scores,
      'topFunctions': summary.topFunctions,
      'stackTypeHints': summary.stackTypeHints,
      'scoredQuestionCount': summary.scoredQuestionCount,
      'scoringVersion': summary.scoringVersion,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  @override
  Future<MbtiCognitiveResultSummary?> loadLatestResult(String uid) async {
    final doc = await _resultRef(uid).get();
    if (!doc.exists) return null;

    final data = doc.data();
    if (data == null) return null;

    final rawScores = data['scores'];
    final scores = <String, double>{
      for (final fn in mbtiCognitiveFunctions) fn: 0,
    };
    if (rawScores is Map) {
      rawScores.forEach((key, value) {
        if (value is num) {
          scores['$key'] = value.toDouble();
        }
      });
    }

    final rawTop = data['topFunctions'];
    final topFunctions = <String>[];
    if (rawTop is List) {
      for (final item in rawTop) {
        if (item is String) topFunctions.add(item);
      }
    }
    if (topFunctions.isEmpty) {
      topFunctions.addAll(MbtiCognitiveScorer.orderedFunctionsFromScores(scores));
    }

    final rawHints = data['stackTypeHints'];
    final stackTypeHints = <String>[];
    if (rawHints is List) {
      for (final item in rawHints) {
        if (item is String) stackTypeHints.add(item);
      }
    }

    final createdAt = data['createdAt'];
    final scoredAt = createdAt is Timestamp
        ? createdAt.toDate()
        : DateTime.now();

    return MbtiCognitiveResultSummary(
      testId: data['testId'] as String? ?? mbtiCognitiveTestId,
      scores: scores,
      topFunctions: topFunctions.isNotEmpty
          ? topFunctions
          : MbtiCognitiveScorer.orderedFunctionsFromScores(scores),
      scoredAt: scoredAt,
      scoringVersion: (data['scoringVersion'] as num?)?.toInt() ??
          mbtiCognitiveScoringVersion,
      stackTypeHints: stackTypeHints,
      scoredQuestionCount: (data['scoredQuestionCount'] as num?)?.toInt() ??
          mbtiCognitiveMiniCheckpoint,
    );
  }
}
