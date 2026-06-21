import 'package:cloud_firestore/cloud_firestore.dart';

import '../domain/big_five_depth_tier.dart';
import '../domain/big_five_models.dart';
import '../domain/big_five_trait_id.dart';

abstract class BigFiveFirestoreRepository {
  Stream<BigFiveProgress?> watchProgress(String uid);

  Future<BigFiveSession?> loadSession(String uid);

  Future<void> saveProgress({
    required String uid,
    required int answeredCount,
    required int index,
    required int total,
    required BigFiveDepthTier depthTier,
    required Map<String, int> answers,
  });

  Future<void> markCompleted(String uid);

  Future<void> unmarkCompleted(String uid);

  Future<void> clearSession(String uid);

  Future<void> saveResult(String uid, BigFiveResultSummary summary);

  Future<BigFiveResultSummary?> loadLatestResult(String uid);
}

class BigFiveFirestoreRepositoryImpl implements BigFiveFirestoreRepository {
  BigFiveFirestoreRepositoryImpl({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;

  DocumentReference<Map<String, dynamic>> _testRef(String uid) {
    return _firestore
        .collection('users')
        .doc(uid)
        .collection('tests')
        .doc(bigFiveTestId);
  }

  DocumentReference<Map<String, dynamic>> _resultRef(String uid) {
    return _firestore
        .collection('users')
        .doc(uid)
        .collection('results')
        .doc(bigFiveTestId);
  }

  @override
  Stream<BigFiveProgress?> watchProgress(String uid) {
    return _testRef(uid).snapshots().map((snap) {
      if (!snap.exists) return null;
      final data = snap.data();
      if (data == null) return null;

      final answered = (data['answered'] as num?)?.toInt() ?? 0;
      final total =
          (data['total'] as num?)?.toInt() ?? bigFiveQuickCheckpoint;
      final depthTier = BigFiveDepthTier.fromStorageKey(
            data['depthTier'] as String?,
          ) ??
          BigFiveDepthTier.forScoredQuestionCount(answered);

      return BigFiveProgress(
        answered: answered,
        total: total,
        depthTier: depthTier,
        completed: data['completed'] == true,
      );
    });
  }

  @override
  Future<BigFiveSession?> loadSession(String uid) async {
    final doc = await _testRef(uid).get();
    if (!doc.exists) return null;

    final data = doc.data();
    if (data == null) return null;

    final answers = _parseAnswers(data['answers']);
    final answered =
        (data['answered'] as num?)?.toInt() ?? answers.length;
    final total =
        (data['total'] as num?)?.toInt() ?? bigFiveQuickCheckpoint;
    final depthTier = BigFiveDepthTier.fromStorageKey(
          data['depthTier'] as String?,
        ) ??
        BigFiveDepthTier.forScoredQuestionCount(total);

    return BigFiveSession(
      answers: answers,
      answered: answered,
      index: (data['index'] as num?)?.toInt() ?? answered,
      total: total,
      depthTier: depthTier,
      completed: data['completed'] == true,
    );
  }

  @override
  Future<void> saveProgress({
    required String uid,
    required int answeredCount,
    required int index,
    required int total,
    required BigFiveDepthTier depthTier,
    required Map<String, int> answers,
  }) async {
    await _testRef(uid).set({
      'module': bigFiveTestId,
      'answered': answeredCount,
      'index': index,
      'total': total,
      'depthTier': depthTier.storageKey,
      'completed': false,
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
  Future<void> saveResult(String uid, BigFiveResultSummary summary) async {
    final payload = <String, dynamic>{
      'testId': summary.testId,
      'depthTier': summary.depthTier.storageKey,
      'scoredQuestionCount': summary.scoredQuestionCount,
      'scoringVersion': summary.scoringVersion,
      'completedAt': FieldValue.serverTimestamp(),
      ...summary.traitScoreFields,
      ...summary.traitBandFields,
    };

    await _resultRef(uid).set(payload);
  }

  @override
  Future<BigFiveResultSummary?> loadLatestResult(String uid) async {
    final doc = await _resultRef(uid).get();
    if (!doc.exists) return null;

    final data = doc.data();
    if (data == null) return null;

    final scoreFields = <String, double>{};
    final bandFields = <String, String>{};

    for (final trait in BigFiveTraitId.all) {
      final scoreKey = BigFiveTraitId.scoreField(trait);
      final bandKey = BigFiveTraitId.bandField(trait);
      scoreFields[scoreKey] =
          (data[scoreKey] as num?)?.toDouble() ??
          (data[trait] as num?)?.toDouble() ??
          0;
      bandFields[bandKey] =
          (data[bandKey] as String?) ??
          (data['${trait}Band'] as String?) ??
          BigFiveBandId.moderate;
    }

    final scoredQuestionCount =
        (data['scoredQuestionCount'] as num?)?.toInt() ?? bigFiveQuickCheckpoint;
    final depthTier = BigFiveDepthTier.fromStorageKey(
          data['depthTier'] as String?,
        ) ??
        BigFiveDepthTier.forScoredQuestionCount(scoredQuestionCount);

    final completedAt = data['completedAt'];
    final scoredAt = completedAt is Timestamp
        ? completedAt.toDate()
        : DateTime.now();

    return BigFiveResultSummary(
      testId: (data['testId'] as String?) ?? bigFiveTestId,
      traitScoreFields: normalizeTraitScoreFields(scoreFields),
      traitBandFields: normalizeTraitBandFields(bandFields),
      depthTier: depthTier,
      scoredQuestionCount: scoredQuestionCount,
      scoredAt: scoredAt,
      scoringVersion:
          (data['scoringVersion'] as num?)?.toInt() ?? bigFiveScoringVersion,
    );
  }

  Map<String, int> _parseAnswers(Object? rawAnswers) {
    final answers = <String, int>{};
    if (rawAnswers is Map) {
      rawAnswers.forEach((key, value) {
        if (value is num) {
          answers['$key'] = value.toInt();
        }
      });
    }
    return answers;
  }
}
