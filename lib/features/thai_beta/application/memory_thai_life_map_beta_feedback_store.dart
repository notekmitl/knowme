import '../domain/thai_life_map_beta_feedback.dart';
import 'thai_life_map_beta_feedback_store.dart';

/// In-memory store for unit/widget tests (not production).
class MemoryThaiLifeMapBetaFeedbackStore extends ThaiLifeMapBetaFeedbackStore {
  MemoryThaiLifeMapBetaFeedbackStore({required this.uid});

  final String uid;
  final Map<String, ThaiLifeMapBetaFeedback> overallByUid = {};
  final Map<String, Map<int, ThaiLifeMapPeriodFeedback>> periodsByUid = {};

  @override
  String? get currentUid => uid;

  @override
  Future<ThaiLifeMapBetaFeedback?> loadOwn() async => overallByUid[uid];

  @override
  Future<ThaiLifeMapBetaFeedbackSaveResult> upsertOverall(
    ThaiLifeMapBetaFeedback feedback,
  ) async {
    if (feedback.userId != uid) {
      return const ThaiLifeMapBetaFeedbackSaveResult.failure(
        'ต้องเข้าสู่ระบบด้วยบัญชี invited beta',
      );
    }
    final err = ThaiLifeMapBetaFeedback.validate(
      scores: feedback.scores,
      lifeMapRef: feedback.lifeMapRef,
      viewportClass: feedback.viewportClass,
      buildVersion: feedback.buildVersion,
      optionalComment: feedback.optionalComment,
      uxIssues: feedback.uxIssues,
    );
    if (err != null) {
      return ThaiLifeMapBetaFeedbackSaveResult.failure(err);
    }
    final existing = overallByUid[uid];
    final now = DateTime.utc(2026, 7, 23);
    overallByUid[uid] = ThaiLifeMapBetaFeedback(
      userId: feedback.userId,
      scores: feedback.scores,
      lifeMapRef: feedback.lifeMapRef,
      viewportClass: feedback.viewportClass,
      buildVersion: feedback.buildVersion,
      feedbackSchemaVersion: feedback.feedbackSchemaVersion,
      sourcePath: feedback.sourcePath,
      isQaTest: feedback.isQaTest,
      optionalComment: feedback.optionalComment,
      uxIssues: feedback.uxIssues,
      createdAt: existing?.createdAt ?? now,
      updatedAt: now,
    );
    return const ThaiLifeMapBetaFeedbackSaveResult.ok();
  }

  @override
  Future<ThaiLifeMapBetaFeedbackSaveResult> upsertPeriodFeedback({
    required ThaiLifeMapPeriodFeedback feedback,
  }) async {
    final err = ThaiLifeMapPeriodFeedback.validate(
      periodIndex: feedback.periodIndex,
      category: feedback.category,
      optionalComment: feedback.optionalComment,
    );
    if (err != null) {
      return ThaiLifeMapBetaFeedbackSaveResult.failure(err);
    }
    final map = periodsByUid.putIfAbsent(uid, () => {});
    map[feedback.periodIndex] = feedback;
    return const ThaiLifeMapBetaFeedbackSaveResult.ok();
  }

  @override
  Future<List<ThaiLifeMapPeriodFeedback>> loadOwnPeriodFeedback() async {
    final map = periodsByUid[uid];
    if (map == null) return const [];
    return map.values.toList();
  }

  @override
  Future<List<ThaiLifeMapBetaFeedback>> listAllForAdmin({
    int limit = 300,
  }) async {
    return overallByUid.values.take(limit).toList();
  }

  @override
  Future<List<ThaiLifeMapPeriodFeedback>> listPeriodFeedbackForAdmin(
    String uid,
  ) async {
    final map = periodsByUid[uid];
    if (map == null) return const [];
    return map.values.toList();
  }
}
