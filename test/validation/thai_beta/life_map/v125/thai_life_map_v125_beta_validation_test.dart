import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:knowme/features/thai_beta/application/memory_thai_life_map_beta_feedback_store.dart';
import 'package:knowme/features/thai_beta/application/thai_beta_evidence_badge_audience.dart';
import 'package:knowme/features/thai_beta/application/thai_beta_invited_tester_registry.dart';
import 'package:knowme/features/thai_beta/application/thai_evidence_badge_activation.dart';
import 'package:knowme/features/thai_beta/application/thai_life_map_beta_feedback_summary.dart';
import 'package:knowme/features/thai_beta/domain/thai_life_map_beta_feedback.dart';
import 'package:knowme/features/thai_beta/application/thai_evidence_badge_feature_flag.dart';
import 'package:knowme/features/thai_beta/presentation/pages/thai_beta_report_page.dart';
import 'package:knowme/features/thai_beta/presentation/widgets/thai_life_map_beta_feedback_panel.dart';

import '../../narrative/thai_beta_narrative_fixtures.dart';

void main() {
  setUp(ThaiBetaInvitedTesterRegistry.reset);
  tearDown(ThaiBetaInvitedTesterRegistry.reset);

  group('domain validation', () {
    test('rejects scores outside 1–5', () {
      final err = ThaiLifeMapBetaFeedback.validate(
        scores: const ThaiLifeMapBetaScores(
          lifeFit: 0,
          clarity: 5,
          trust: 5,
          usefulness: 5,
        ),
        lifeMapRef: 'abc',
        viewportClass: 'mobile',
        buildVersion: '1.0.0+1',
      );
      expect(err, isNotNull);
    });

    test('rejects overlong comment', () {
      final err = ThaiLifeMapBetaFeedback.validate(
        scores: const ThaiLifeMapBetaScores(
          lifeFit: 4,
          clarity: 4,
          trust: 4,
          usefulness: 4,
        ),
        lifeMapRef: 'abc',
        viewportClass: 'desktop',
        buildVersion: '1.0.0+1',
        optionalComment: 'x' * 501,
      );
      expect(err, isNotNull);
    });

    test('accepts complete valid payload', () {
      final err = ThaiLifeMapBetaFeedback.validate(
        scores: const ThaiLifeMapBetaScores(
          lifeFit: 4,
          clarity: 5,
          trust: 4,
          usefulness: 5,
        ),
        lifeMapRef: 'hash123',
        viewportClass: 'mobile',
        buildVersion: '1.0.0+1',
      );
      expect(err, isNull);
    });
  });

  group('memory store behavior', () {
    test(
      'upsert overall is idempotent for same uid (no duplicate docs)',
      () async {
        final store = MemoryThaiLifeMapBetaFeedbackStore(uid: 'u1');
        final feedback = ThaiLifeMapBetaFeedback(
          userId: 'u1',
          scores: const ThaiLifeMapBetaScores(
            lifeFit: 4,
            clarity: 5,
            trust: 4,
            usefulness: 5,
          ),
          lifeMapRef: 'ref',
          viewportClass: 'mobile',
          buildVersion: '1.0.0+1',
          feedbackSchemaVersion: 1,
          sourcePath: 'test',
          isQaTest: true,
        );
        expect((await store.upsertOverall(feedback)).success, isTrue);
        expect(
          (await store.upsertOverall(
            ThaiLifeMapBetaFeedback(
              userId: 'u1',
              scores: const ThaiLifeMapBetaScores(
                lifeFit: 5,
                clarity: 5,
                trust: 5,
                usefulness: 5,
              ),
              lifeMapRef: 'ref',
              viewportClass: 'mobile',
              buildVersion: '1.0.0+1',
              feedbackSchemaVersion: 1,
              sourcePath: 'test',
              isQaTest: true,
            ),
          )).success,
          isTrue,
        );
        expect(store.overallByUid.length, 1);
        expect(store.overallByUid['u1']!.scores.lifeFit, 5);
      },
    );

    test('period feedback keyed by period index prevents duplicates', () async {
      final store = MemoryThaiLifeMapBetaFeedbackStore(uid: 'u1');
      await store.upsertPeriodFeedback(
        feedback: const ThaiLifeMapPeriodFeedback(
          periodIndex: 2,
          category: ThaiLifeMapPeriodFeedbackCategory.exact,
        ),
      );
      await store.upsertPeriodFeedback(
        feedback: const ThaiLifeMapPeriodFeedback(
          periodIndex: 2,
          category: ThaiLifeMapPeriodFeedbackCategory.mismatch,
        ),
      );
      final periods = await store.loadOwnPeriodFeedback();
      expect(periods.length, 1);
      expect(
        periods.first.category,
        ThaiLifeMapPeriodFeedbackCategory.mismatch,
      );
    });

    test('cannot write as another user id', () async {
      final store = MemoryThaiLifeMapBetaFeedbackStore(uid: 'u1');
      final result = await store.upsertOverall(
        ThaiLifeMapBetaFeedback(
          userId: 'u2',
          scores: const ThaiLifeMapBetaScores(
            lifeFit: 4,
            clarity: 4,
            trust: 4,
            usefulness: 4,
          ),
          lifeMapRef: 'ref',
          viewportClass: 'mobile',
          buildVersion: '1.0.0+1',
          feedbackSchemaVersion: 1,
          sourcePath: 'test',
          isQaTest: true,
        ),
      );
      expect(result.success, isFalse);
      expect(store.overallByUid, isEmpty);
    });
  });

  group('summary + validation phase', () {
    test('QA submissions excluded from realUserCount', () {
      final summary = ThaiLifeMapBetaFeedbackSummary.from(
        overall: [
          _fb(uid: 'qa1', qa: true, scores: [5, 5, 5, 5]),
          _fb(uid: 'r1', qa: false, scores: [4, 4, 4, 4]),
        ],
        periods: const [],
      );
      expect(summary.realUserCount, 1);
      expect(summary.qaSubmissionCount, 1);
      expect(
        ThaiLifeMapValidationStatus.evaluate(summary),
        ThaiLifeMapValidationPhase.collectingEvidence,
      );
    });

    test('zero real users => Ready for Validation', () {
      final summary = ThaiLifeMapBetaFeedbackSummary.from(
        overall: const [],
        periods: const [],
      );
      expect(
        ThaiLifeMapValidationStatus.evaluate(summary),
        ThaiLifeMapValidationPhase.readyForValidation,
      );
    });

    test('five real users meeting bars => Passed', () {
      final overall = [
        for (var i = 0; i < 5; i++)
          _fb(uid: 'u$i', qa: false, scores: [4, 4, 4, 4]),
      ];
      final summary = ThaiLifeMapBetaFeedbackSummary.from(
        overall: overall,
        periods: const [],
      );
      expect(
        ThaiLifeMapValidationStatus.evaluate(summary),
        ThaiLifeMapValidationPhase.validationPassed,
      );
    });
  });

  group('UI gating', () {
    testWidgets('invited user sees feedback panel', (tester) async {
      ThaiBetaInvitedTesterRegistry.invite('invited-1');
      final store = MemoryThaiLifeMapBetaFeedbackStore(uid: 'invited-1');
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ThaiLifeMapBetaFeedbackPanel(
              userId: 'invited-1',
              lifeMapRef: 'ref',
              viewportClass: 'desktop',
              buildVersion: '1.0.0+1',
              store: store,
              isQaTest: true,
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(
        find.byKey(const Key('thai_life_map_beta_feedback_panel')),
        findsOneWidget,
      );
    });

    testWidgets('submitting scores persists via store', (tester) async {
      final store = MemoryThaiLifeMapBetaFeedbackStore(uid: 'invited-1');
      await tester.binding.setSurfaceSize(const Size(800, 1600));
      addTearDown(() => tester.binding.setSurfaceSize(null));
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SingleChildScrollView(
              child: ThaiLifeMapBetaFeedbackPanel(
                userId: 'invited-1',
                lifeMapRef: 'ref',
                viewportClass: 'mobile',
                buildVersion: '1.0.0+1',
                store: store,
                isQaTest: true,
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      await tester.tap(find.text('ช่วยประเมินแผนที่ชีวิต (Invited Beta)'));
      await tester.pumpAndSettle();

      for (final label in [
        'ความตรงกับชีวิต',
        'ความเข้าใจง่าย',
        'ความน่าเชื่อถือ',
        'ประโยชน์ที่ได้รับ',
      ]) {
        final star = find.byKey(Key('score_${label}_4'));
        await tester.ensureVisible(star);
        await tester.tap(star);
        await tester.pump();
      }
      final submit = find.byKey(
        const Key('thai_life_map_beta_feedback_submit_scores'),
      );
      await tester.ensureVisible(submit);
      await tester.tap(submit);
      await tester.pumpAndSettle();
      expect(store.overallByUid['invited-1']?.scores.clarity, 4);
    });
    testWidgets('report page shows panel only for invited signed-in user', (
      tester,
    ) async {
      final analysis = ThaiBetaNarrativeFixtures.fixtureA();
      await tester.binding.setSurfaceSize(const Size(390, 3200));
      addTearDown(() => tester.binding.setSurfaceSize(null));

      await tester.pumpWidget(
        MaterialApp(
          home: ThaiBetaReportPage(
            analysis: analysis,
            audienceOverride: const ThaiBetaEvidenceBadgeAudience.anonymous(),
            featureFlagOverride: ThaiEvidenceBadgeFeatureFlagState.invitedBeta,
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(
        find.byKey(const Key('thai_life_map_beta_feedback_panel')),
        findsNothing,
      );

      await tester.pumpWidget(
        MaterialApp(
          home: ThaiBetaReportPage(
            analysis: analysis,
            audienceOverride:
                const ThaiBetaEvidenceBadgeAudience.invitedBetaTester(),
            userIdOverride: 'invited-1',
            featureFlagOverride: ThaiEvidenceBadgeFeatureFlagState.invitedBeta,
          ),
        ),
      );
      // Allow panel load timeout path without waiting forever.
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 900));
      expect(
        find.byKey(const Key('thai_life_map_beta_feedback_panel')),
        findsOneWidget,
      );

      // Admin alone (not invited) must not see user feedback panel.
      await tester.pumpWidget(
        MaterialApp(
          home: ThaiBetaReportPage(
            analysis: analysis,
            audienceOverride:
                const ThaiBetaEvidenceBadgeAudience.internalTester(),
            userIdOverride: 'admin-1',
            featureFlagOverride: ThaiEvidenceBadgeFeatureFlagState.invitedBeta,
          ),
        ),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 200));
      expect(
        find.byKey(const Key('thai_life_map_beta_feedback_panel')),
        findsNothing,
      );
    });
  });

  group('Evidence Badge activation unchanged', () {
    test('configuredState remains invited_beta', () {
      expect(ThaiEvidenceBadgeActivation.configuredState, 'invited_beta');
    });

    test('anonymous audience is not invited', () {
      const audience = ThaiBetaEvidenceBadgeAudience.anonymous();
      expect(audience.isInvitedBetaTester, isFalse);
    });
  });

  group('firestore.rules contract', () {
    test(
      'rules declare invited_beta_testers and life map feedback collection',
      () {
        final rules = File('firestore.rules').readAsStringSync();
        expect(rules.contains('invited_beta_testers'), isTrue);
        expect(rules.contains('thai_life_map_beta_feedback'), isTrue);
        expect(rules.contains('isInvitedBetaTester()'), isTrue);
        expect(rules.contains('allow write: if false'), isTrue);
      },
    );
  });
}

ThaiLifeMapBetaFeedback _fb({
  required String uid,
  required bool qa,
  required List<int> scores,
}) {
  return ThaiLifeMapBetaFeedback(
    userId: uid,
    scores: ThaiLifeMapBetaScores(
      lifeFit: scores[0],
      clarity: scores[1],
      trust: scores[2],
      usefulness: scores[3],
    ),
    lifeMapRef: 'ref',
    viewportClass: 'mobile',
    buildVersion: '1.0.0+1',
    feedbackSchemaVersion: 1,
    sourcePath: 'test',
    isQaTest: qa,
    updatedAt: DateTime.utc(2026, 7, 23),
  );
}
