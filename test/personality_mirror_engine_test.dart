import 'package:flutter_test/flutter_test.dart';
import 'package:knowme/data/questions/mbti/mbti_progressive_questions.dart';
import 'package:knowme/features/astrology/fusion/domain/entities/fusion_category.dart';
import 'package:knowme/features/astrology/fusion/domain/entities/theme_family.dart';
import 'package:knowme/features/personality_mirror/application/adapters/big_five_personality_lens_adapter.dart';
import 'package:knowme/features/personality_mirror/application/adapters/mbti_personality_lens_adapter.dart';
import 'package:knowme/features/personality_mirror/application/mirror/personality_agreement_engine.dart';
import 'package:knowme/features/personality_mirror/application/mirror/personality_confidence_composer.dart';
import 'package:knowme/features/personality_mirror/application/mirror/personality_mirror_engine.dart';
import 'package:knowme/features/personality_mirror/application/mirror/personality_mirror_theme_signal.dart';
import 'package:knowme/features/personality_mirror/application/mirror/personality_tension_engine.dart';
import 'package:knowme/features/personality_mirror/application/personality_lens_load_result.dart';
import 'package:knowme/features/personality_mirror/application/personality_lens_loader.dart';
import 'package:knowme/features/personality_mirror/domain/personality_agreement.dart';
import 'package:knowme/features/personality_mirror/domain/personality_agreement_kind.dart';
import 'package:knowme/features/personality_mirror/domain/personality_agreement_lens_id.dart';
import 'package:knowme/features/personality_mirror/domain/personality_core_themes.dart';
import 'package:knowme/features/personality_mirror/domain/personality_coverage.dart';
import 'package:knowme/features/personality_mirror/domain/personality_lens_id.dart';
import 'package:knowme/features/personality_mirror/domain/personality_lens_snapshot.dart';
import 'package:knowme/features/personality_mirror/domain/personality_mirror_constants.dart';
import 'package:knowme/features/personality_mirror/domain/personality_mirror_snapshot.dart';
import 'package:knowme/features/tests/big_five/application/big_five_scorer.dart';
import 'package:knowme/features/tests/big_five/data/big_five_firestore_repository.dart';
import 'package:knowme/features/tests/big_five/data/modules/big_five_progressive_questions.dart';
import 'package:knowme/features/tests/big_five/domain/big_five_depth_tier.dart';
import 'package:knowme/features/tests/big_five/domain/big_five_models.dart';
import 'package:knowme/features/tests/eq/data/eq_firestore_repository.dart';
import 'package:knowme/features/tests/eq/domain/eq_models.dart';
import 'package:knowme/features/tests/mbti/application/mbti_scorer.dart';
import 'package:knowme/features/tests/mbti/data/mbti_firestore_repository.dart';
import 'package:knowme/features/tests/mbti/domain/mbti_models.dart';

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

PersonalityMirrorThemeSignal _signal({
  required PersonalityAgreementLensId agreementLens,
  required PersonalityLensId sourceLensId,
  required String themeId,
  required FusionCategory category,
  required ThemeFamily family,
  double confidence = 0.7,
}) {
  return PersonalityMirrorThemeSignal(
    agreementLens: agreementLens,
    sourceLensId: sourceLensId,
    themeId: themeId,
    category: category,
    family: family,
    confidence: confidence,
  );
}

void main() {
  group('PersonalityAgreementEngine', () {
    test('detects theme agreement across mbti and big five', () {
      final agreements = PersonalityAgreementEngine.detect([
        _signal(
          agreementLens: PersonalityAgreementLensId.mbti,
          sourceLensId: PersonalityLensId.mbti,
          themeId: PersonalityCoreThemeIds.structured,
          category: FusionCategory.thinkingStyle,
          family: ThemeFamily.structure,
        ),
        _signal(
          agreementLens: PersonalityAgreementLensId.bigFive,
          sourceLensId: PersonalityLensId.bigFive,
          themeId: PersonalityCoreThemeIds.structured,
          category: FusionCategory.thinkingStyle,
          family: ThemeFamily.structure,
        ),
      ]);

      final themeAgreement = agreements.firstWhere(
        (a) => a.kind == PersonalityAgreementKind.theme,
      );
      expect(themeAgreement.themeId, PersonalityCoreThemeIds.structured);
      expect(
        themeAgreement.supportingAgreementLenses,
        containsAll([
          PersonalityAgreementLensId.mbti,
          PersonalityAgreementLensId.bigFive,
        ]),
      );
    });

    test('does not treat two EQ modules as two agreement lenses', () {
      final agreements = PersonalityAgreementEngine.detect([
        _signal(
          agreementLens: PersonalityAgreementLensId.eq,
          sourceLensId: PersonalityLensId.eqAwareness,
          themeId: PersonalityCoreThemeIds.responsive,
          category: FusionCategory.emotionalWorld,
          family: ThemeFamily.expression,
        ),
        _signal(
          agreementLens: PersonalityAgreementLensId.eq,
          sourceLensId: PersonalityLensId.eqEmpathy,
          themeId: PersonalityCoreThemeIds.responsive,
          category: FusionCategory.emotionalWorld,
          family: ThemeFamily.expression,
        ),
      ]);

      expect(
        agreements.where((a) => a.kind == PersonalityAgreementKind.theme),
        isEmpty,
      );
    });
  });

  group('PersonalityTensionEngine', () {
    test('detects expression vs reflection in same category', () {
      final tensions = PersonalityTensionEngine.detect([
        _signal(
          agreementLens: PersonalityAgreementLensId.mbti,
          sourceLensId: PersonalityLensId.mbti,
          themeId: PersonalityCoreThemeIds.reserved,
          category: FusionCategory.coreSelf,
          family: ThemeFamily.reflection,
        ),
        _signal(
          agreementLens: PersonalityAgreementLensId.bigFive,
          sourceLensId: PersonalityLensId.bigFive,
          themeId: PersonalityCoreThemeIds.expressive,
          category: FusionCategory.coreSelf,
          family: ThemeFamily.expression,
        ),
      ]);

      expect(tensions, isNotEmpty);
      expect(tensions.first.reasonCode, contains('opposing_families'));
      expect(
        tensions.first.agreementLensIds,
        containsAll([
          PersonalityAgreementLensId.mbti,
          PersonalityAgreementLensId.bigFive,
        ]),
      );
    });
  });

  group('PersonalityConfidenceComposer', () {
    test('applies agreement boost and tension penalty', () async {
      final mbtiQuestions = mbtiMiniQuestions;
      final mbtiSummary = const MbtiScorer().score(
        questions: mbtiQuestions,
        answers: <String, int>{for (final q in mbtiQuestions) q.id: 4},
      );
      final loader = PersonalityLensLoader(
        mbtiRepository: _FakeMbtiRepo(mbtiSummary),
        bigFiveRepository: _FakeBigFiveRepo(null),
        eqRepository: _FakeEqRepo(const {}),
      );

      final load = await loader.loadAll('u1');
      final baseOnly = PersonalityConfidenceComposer.compose(
        load: load,
        agreements: const [],
        tensions: const [],
      );

      final withBoost = PersonalityConfidenceComposer.compose(
        load: load,
        agreements: [
          const PersonalityAgreement(
            kind: PersonalityAgreementKind.theme,
            themeId: PersonalityCoreThemeIds.structured,
            supportingAgreementLenses: [
              PersonalityAgreementLensId.mbti,
              PersonalityAgreementLensId.bigFive,
            ],
            confidence: 0.7,
            sourceThemeIds: [PersonalityCoreThemeIds.structured],
          ),
        ],
        tensions: const [],
      );

      expect(withBoost, greaterThan(baseOnly));
    });
  });

  group('PersonalityMirrorEngine', () {
    test('builds mirror snapshot from loader output', () async {
      final mbtiQuestions = mbtiMiniQuestions;
      final mbtiSummary = const MbtiScorer().score(
        questions: mbtiQuestions,
        answers: <String, int>{for (final q in mbtiQuestions) q.id: 5},
      );
      final bfQuestions =
          BigFiveProgressiveQuestions.forTargetTotal(bigFiveQuickCheckpoint);
      final bfSummary = const BigFiveScorer().score(
        questions: bfQuestions,
        answers: <String, int>{for (final q in bfQuestions) q.id: 5},
      );

      final loader = PersonalityLensLoader(
        mbtiRepository: _FakeMbtiRepo(mbtiSummary),
        bigFiveRepository: _FakeBigFiveRepo(bfSummary),
        eqRepository: _FakeEqRepo({
          'eq_awareness': const EqResultSummary(
            testId: 'eq_awareness',
            averageScore: 4.5,
            level: EqLevelIds.strong,
            scoredQuestionCount: 20,
          ),
        }),
      );

      final load = await loader.loadAll('user-1');
      final mirror = PersonalityMirrorEngine.build(load);

      expect(mirror.version, PersonalityMirrorSnapshot.versionId);
      expect(mirror.lensSnapshots.length, PersonalityLensId.all.length);
      expect(mirror.compositeConfidence, greaterThan(0));
      expect(mirror.coverage.hasMbti, isTrue);
      expect(mirror.coverage.hasBigFive, isTrue);
      expect(mirror.coverage.eqModulesCompleted, 1);
    });

    test('end-to-end adapters produce non-empty mirror agreements', () {
      final mbtiSnapshot = MbtiPersonalityLensAdapter.map(
        MbtiResultSummary(
          testId: 'mbti_mini',
          type: 'ISTJ',
          dimensions: const {
            'E': 10,
            'I': 50,
            'S': 50,
            'N': 10,
            'T': 50,
            'F': 10,
            'J': 50,
            'P': 10,
          },
          scoredAt: DateTime(2026),
          scoredQuestionCount: 16,
        ),
      );
      final bfSnapshot = BigFivePersonalityLensAdapter.map(
        BigFiveResultSummary(
          testId: 'big_five',
          traitScoreFields: const {},
          traitBandFields: const {
            'extraversionBand': 'emerging',
            'opennessBand': 'moderate',
            'conscientiousnessBand': 'strong',
            'agreeablenessBand': 'moderate',
            'neuroticismBand': 'moderate',
          },
          depthTier: BigFiveDepthTier.quick,
          scoredQuestionCount: 10,
          scoredAt: DateTime(2026),
        ),
      );

      final load = PersonalityLensLoadResult(
        snapshots: {
          PersonalityLensId.mbti: mbtiSnapshot,
          PersonalityLensId.bigFive: bfSnapshot,
          for (final id in PersonalityLensId.eqLenses)
            id: PersonalityLensSnapshot.unavailable(id),
        },
        coverage: const PersonalityCoverage(
          availableLensIds: [
            PersonalityLensId.mbti,
            PersonalityLensId.bigFive,
          ],
          missingLensIds: PersonalityLensId.eqLenses,
          eqModulesCompleted: 0,
          eqModulesExpected: 6,
          weightedCoverage:
              PersonalityMirrorWeights.mbti + PersonalityMirrorWeights.bigFive,
        ),
      );

      final mirror = PersonalityMirrorEngine.build(load);
      expect(mirror.agreements, isNotEmpty);
    });
  });
}
