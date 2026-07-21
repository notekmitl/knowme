import 'package:flutter_test/flutter_test.dart';
import 'package:knowme/features/personality_mirror/application/adapters/big_five_personality_lens_adapter.dart';
import 'package:knowme/features/personality_mirror/application/adapters/eq_personality_lens_adapter.dart';
import 'package:knowme/features/personality_mirror/application/adapters/mbti_personality_lens_adapter.dart';
import 'package:knowme/features/personality_mirror/application/personality_lens_loader.dart';
import 'package:knowme/features/personality_mirror/domain/personality_core_themes.dart';
import 'package:knowme/features/personality_mirror/domain/personality_lens_id.dart';
import 'package:knowme/features/personality_mirror/domain/personality_mirror_constants.dart';
import 'package:knowme/features/tests/big_five/application/big_five_scorer.dart';
import 'package:knowme/features/tests/big_five/data/big_five_firestore_repository.dart';
import 'package:knowme/features/tests/big_five/data/modules/big_five_progressive_questions.dart';
import 'package:knowme/features/tests/big_five/domain/big_five_depth_tier.dart';
import 'package:knowme/features/tests/big_five/domain/big_five_models.dart';
import 'package:knowme/features/tests/eq/data/eq_firestore_repository.dart';
import 'package:knowme/features/tests/eq/domain/eq_models.dart';
import 'package:knowme/features/tests/mbti/data/mbti_firestore_repository.dart';
import 'package:knowme/features/tests/mbti/application/mbti_scorer.dart';
import 'package:knowme/data/questions/mbti/mbti_progressive_questions.dart';
import 'package:knowme/features/tests/mbti/domain/mbti_models.dart';
import 'package:knowme/features/tests/big_five/domain/big_five_models.dart'
    show BigFiveProgress;

class _FakeMbtiRepo implements MbtiFirestoreRepository {
  _FakeMbtiRepo(this.result);

  final MbtiResultSummary? result;

  @override
  Future<void> clearSession(String uid) async {}

  @override
  Future<MbtiMiniSession?> loadSession(String uid) async => null;

  @override
  Future<MbtiResultSummary?> loadLatestResult(String uid) async => result;

  @override
  Future<void> markCompleted(String uid) async {}

  @override
  Future<void> saveProgress({
    required String uid,
    required int answeredCount,
    required int total,
    required Map<String, int> answers,
  }) async {}

  @override
  Future<void> saveResult(String uid, MbtiResultSummary summary) async {}

  @override
  Future<void> unmarkCompleted(String uid) async {}

  @override
  Stream<MbtiMiniProgress?> watchProgress(String uid) => const Stream.empty();
}

class _FakeBigFiveRepo implements BigFiveFirestoreRepository {
  _FakeBigFiveRepo(this.result);

  final BigFiveResultSummary? result;

  @override
  Future<void> clearSession(String uid) async {}

  @override
  Future<BigFiveSession?> loadSession(String uid) async => null;

  @override
  Future<BigFiveResultSummary?> loadLatestResult(String uid) async => result;

  @override
  Future<void> markCompleted(String uid) async {}

  @override
  Future<void> saveProgress({
    required String uid,
    required int answeredCount,
    required int index,
    required int total,
    required BigFiveDepthTier depthTier,
    required Map<String, int> answers,
  }) async {}

  @override
  Future<void> saveResult(String uid, BigFiveResultSummary summary) async {}

  @override
  Future<void> unmarkCompleted(String uid) async {}

  @override
  Stream<BigFiveProgress?> watchProgress(String uid) => const Stream.empty();
}

class _FakeEqRepo implements EqFirestoreRepository {
  _FakeEqRepo(this.results);

  final Map<String, EqResultSummary?> results;

  @override
  Future<void> clearSession(String uid, String testId) async {}

  @override
  Future<EqTestSession?> loadSession(String uid, String testId) async => null;

  @override
  Future<EqResultSummary?> loadLatestResult(String uid, String testId) async =>
      results[testId];

  @override
  Future<void> markCompleted(String uid, String testId) async {}

  @override
  Future<void> saveProgress({
    required String uid,
    required String testId,
    required int answeredCount,
    required int index,
    required int total,
    required Map<String, int> answers,
  }) async {}

  @override
  Future<void> saveResult(String uid, EqResultSummary summary) async {}
}

void main() {
  group('PersonalityCoreThemeRegistry', () {
    test('defines 15 core themes', () {
      expect(PersonalityCoreThemeIds.all.length, 15);
      for (final id in PersonalityCoreThemeIds.all) {
        expect(PersonalityCoreThemeRegistry.contains(id), isTrue);
      }
    });
  });

  group('MbtiPersonalityLensAdapter', () {
    test('maps dominant dimensions to core themes', () {
      final questions = mbtiMiniQuestions;
      final answers = <String, int>{for (final q in questions) q.id: 5};
      final summary = const MbtiScorer().score(
        questions: questions,
        answers: answers,
      );

      final snapshot = MbtiPersonalityLensAdapter.map(summary);

      expect(snapshot.available, isTrue);
      expect(snapshot.lensId, PersonalityLensId.mbti);
      expect(snapshot.themes, isNotEmpty);
      for (final theme in snapshot.themes) {
        expect(PersonalityCoreThemeIds.all, contains(theme.themeId));
      }
    });

    test('returns unavailable when result is null', () {
      final snapshot = MbtiPersonalityLensAdapter.map(null);
      expect(snapshot.available, isFalse);
      expect(snapshot.themes, isEmpty);
    });
  });

  group('BigFivePersonalityLensAdapter', () {
    test('maps trait bands to core themes', () {
      final questions =
          BigFiveProgressiveQuestions.forTargetTotal(bigFiveQuickCheckpoint);
      final answers = {for (final q in questions) q.id: 5};
      final summary = const BigFiveScorer().score(
        questions: questions,
        answers: answers,
      );

      final snapshot = BigFivePersonalityLensAdapter.map(summary);

      expect(snapshot.available, isTrue);
      expect(snapshot.lensConfidence, 0.40);
      expect(snapshot.themes, isNotEmpty);
    });
  });

  group('EqPersonalityLensAdapter', () {
    test('maps strong awareness to responsive theme', () {
      const summary = EqResultSummary(
        testId: 'eq_awareness',
        averageScore: 4.5,
        level: EqLevelIds.strong,
        scoredQuestionCount: 20,
      );

      final snapshot = EqPersonalityLensAdapter.map(
        lensId: PersonalityLensId.eqAwareness,
        result: summary,
      );

      expect(snapshot.available, isTrue);
      expect(
        snapshot.themes.map((t) => t.themeId),
        contains(PersonalityCoreThemeIds.responsive),
      );
    });

    test('moderate level emits no themes', () {
      const summary = EqResultSummary(
        testId: 'eq_awareness',
        averageScore: 3.0,
        level: EqLevelIds.moderate,
        scoredQuestionCount: 20,
      );

      final snapshot = EqPersonalityLensAdapter.map(
        lensId: PersonalityLensId.eqAwareness,
        result: summary,
      );

      expect(snapshot.available, isTrue);
      expect(snapshot.themes, isEmpty);
    });
  });

  group('PersonalityLensLoader', () {
    test('loads snapshots and computes weighted coverage', () async {
      final mbtiQuestions = mbtiMiniQuestions;
      final mbtiSummary = const MbtiScorer().score(
        questions: mbtiQuestions,
        answers: <String, int>{for (final q in mbtiQuestions) q.id: 4},
      );

      final loader = PersonalityLensLoader(
        mbtiRepository: _FakeMbtiRepo(mbtiSummary),
        bigFiveRepository: _FakeBigFiveRepo(null),
        eqRepository: _FakeEqRepo({
          'eq_awareness': const EqResultSummary(
            testId: 'eq_awareness',
            averageScore: 4.2,
            level: EqLevelIds.strong,
            scoredQuestionCount: 20,
          ),
        }),
      );

      final result = await loader.loadAll('user-1');

      expect(result.snapshotFor(PersonalityLensId.mbti)!.available, isTrue);
      expect(result.snapshotFor(PersonalityLensId.bigFive)!.available, isFalse);
      expect(result.snapshotFor(PersonalityLensId.eqAwareness)!.available, isTrue);
      expect(result.coverage.hasMbti, isTrue);
      expect(result.coverage.hasBigFive, isFalse);
      expect(result.coverage.eqModulesCompleted, 1);
      expect(
        result.coverage.weightedCoverage,
        closeTo(
          PersonalityMirrorWeights.mbti + PersonalityMirrorWeights.eqModuleShare,
          0.001,
        ),
      );
    });
  });
}
