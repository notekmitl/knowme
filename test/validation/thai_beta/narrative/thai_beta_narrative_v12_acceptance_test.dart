import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:knowme/features/astrology/thai/knowledge/canon/integration/presentation/thai_beta_evidence_badge_panel.dart';
import 'package:knowme/features/astrology/thai/knowledge/canon/integration/presentation/thai_public_evidence_badge_beta_gate.dart';
import 'package:knowme/features/birth_normalization/birth_normalization.dart';
import 'package:knowme/features/thai_beta/application/narrative/thai_beta_narrative_composer.dart';
import 'package:knowme/features/thai_beta/application/narrative/thai_beta_narrative_confidence.dart';
import 'package:knowme/features/thai_beta/application/narrative/thai_beta_narrative_forbidden.dart';
import 'package:knowme/features/thai_beta/application/narrative/thai_beta_narrative_v12.dart';
import 'package:knowme/features/thai_beta/application/thai_beta_analysis.dart';
import 'package:knowme/features/thai_beta/application/thai_beta_evidence_badge_audience.dart';
import 'package:knowme/features/thai_beta/application/thai_evidence_badge_activation.dart';
import 'package:knowme/features/thai_beta/application/thai_evidence_badge_feature_flag.dart';
import 'package:knowme/features/thai_beta/presentation/pages/thai_beta_report_page.dart';

import 'thai_beta_narrative_fixtures.dart';

/// Thai Beta Narrative V1.2 — Personal Relevance & Actionable Guidance.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('V1.2 Personal Relevance acceptance', () {
    test('V12-1 full time + coherent: personal core + linked SRA', () {
      final result =
          ThaiBetaNarrativeComposer.compose(ThaiBetaNarrativeFixtures.fixtureA());
      final view = result.view;
      expect(view.signatureInsight.isEmpty, isFalse);
      expect(view.signatureInsight.eyebrow, contains('แก่น'));
      expect(view.strengths.title, ThaiBetaNarrativeV12.strengthsSectionTitle);
      expect(view.cautions.title, ThaiBetaNarrativeV12.cautionsSectionTitle);
      expect(view.advice.title, ThaiBetaNarrativeV12.adviceSectionTitle);
      expect(view.strengths.cards.length, lessThanOrEqualTo(3));
      expect(view.cautions.cards.isNotEmpty, isTrue);
      expect(
        result.trace.entries.any((e) => e.sectionId == 'personal_core'),
        isTrue,
      );
      expect(
        result.trace.entries.any((e) => e.relationship?.contains('v12_linked_risk') == true),
        isTrue,
      );
      expect(ThaiBetaNarrativeForbidden.findForbidden(_publicText(result)), isEmpty);
    });

    test('V12-2 mixed/tension profile: no contradictory public copy', () {
      final result =
          ThaiBetaNarrativeComposer.compose(ThaiBetaNarrativeFixtures.fixtureC());
      expect(result.view.signatureInsight.isEmpty, isFalse);
      expect(ThaiBetaNarrativeForbidden.findForbidden(_publicText(result)), isEmpty);
      expect(
        ThaiBetaNarrativeV12.adviceConflictsWithCore(
          adviceText: result.view.advice.body,
          coreBody: result.view.signatureInsight.body,
        ),
        isFalse,
      );
    });

    test('V12-3 no birth time: limited core + no deep motive', () {
      final result =
          ThaiBetaNarrativeComposer.compose(ThaiBetaNarrativeFixtures.fixtureB());
      expect(result.view.birthDataConfidence.isComplete, isFalse);
      expect(
        result.view.signatureInsight.eyebrow,
        contains('ยังไม่ครบ'),
      );
      expect(
        ThaiBetaNarrativeForbidden.findNoBirthTimeViolations(_publicText(result)),
        isEmpty,
      );
      expect(
        result.trace.entries
            .where((e) => e.blockId != null && e.minimumConfidence != null)
            .every(
              (e) =>
                  e.minimumConfidence! <=
                  ThaiBetaNarrativeConfidence.withoutBirthTime,
            ),
        isTrue,
      );
    });

    test('V12-4 unknown birth-time flag matches no-time policy', () {
      final unknown = ThaiBetaNarrativeComposer.compose(
        ThaiBetaNarrativeFixtures.incompleteTimeUnknownFlag(),
      );
      final noTime = ThaiBetaNarrativeComposer.compose(
        ThaiBetaNarrativeFixtures.fixtureB(),
      );
      expect(unknown.view.signatureInsight.eyebrow, noTime.view.signatureInsight.eyebrow);
      expect(
        ThaiBetaNarrativeForbidden.findNoBirthTimeViolations(_publicText(unknown)),
        isEmpty,
      );
    });

    test('V12-5 limited evidence still composes without filler patterns', () {
      final result =
          ThaiBetaNarrativeComposer.compose(ThaiBetaNarrativeFixtures.fixtureD());
      final text = _publicText(result);
      expect(text.contains('TODO'), isFalse);
      expect(text.contains('placeholder'), isFalse);
      expect(ThaiBetaNarrativeForbidden.findForbidden(text), isEmpty);
    });

    test('V12-6 advice relates to primary strength evidence when possible', () {
      final result =
          ThaiBetaNarrativeComposer.compose(ThaiBetaNarrativeFixtures.fixtureA());
      final strengthIds = result.trace.entries
          .where((e) => e.sectionId.startsWith('strength_'))
          .map((e) => e.blockId)
          .whereType<String>()
          .toSet();
      final advice = result.trace.entries
          .where((e) => e.sectionId == 'advice')
          .map((e) => e.blockId)
          .whereType<String>()
          .toList();
      expect(advice, isNotEmpty);
      expect(strengthIds.intersection(advice.toSet()), isEmpty);
      expect(
        ThaiBetaNarrativeForbidden.isValidAdvicePhrase(result.view.advice.body),
        isTrue,
      );
    });

    test('V12-7 no duplicate caution text across linked cards', () {
      final result =
          ThaiBetaNarrativeComposer.compose(ThaiBetaNarrativeFixtures.fixtureA());
      final bodies = result.view.cautions.cards.map((c) => c.body).toList();
      expect(bodies.toSet().length, bodies.length);
    });

    test('V12-8 advice does not conflict with personal core', () {
      for (final load in [
        ThaiBetaNarrativeFixtures.fixtureA,
        ThaiBetaNarrativeFixtures.fixtureC,
        ThaiBetaNarrativeFixtures.wednesdayDaytime,
      ]) {
        final result = ThaiBetaNarrativeComposer.compose(load());
        expect(
          ThaiBetaNarrativeV12.adviceConflictsWithCore(
            adviceText: result.view.advice.body,
            coreBody: result.view.signatureInsight.body,
          ),
          isFalse,
        );
      }
    });

    test('V12-9 Wednesday daytime preserves Thai weekday พุธ', () {
      final analysis = ThaiBetaNarrativeFixtures.wednesdayDaytime();
      expect(analysis.isSuccess, isTrue);
      final snap = analysis.normalizedSnapshot!;
      expect(_thaiWeekdayNumber(snap.thaiAstrologicalDate), 4);
      final result = ThaiBetaNarrativeComposer.compose(analysis);
      expect(result.view.signatureInsight.isEmpty, isFalse);
    });

    test('V12-10 Wednesday pre-sunrise rolls to พุธ', () {
      final analysis = ThaiBetaNarrativeFixtures.wednesdayNightBeforeSunrise();
      final snap = analysis.normalizedSnapshot!;
      expect(snap.usedPreviousDay, isTrue);
      expect(_thaiWeekdayNumber(snap.thaiAstrologicalDate), 4);
      expect(
        ThaiBetaNarrativeComposer.compose(analysis).view.signatureInsight.isEmpty,
        isFalse,
      );
    });

    test('V12-11 sunrise boundary before/after', () {
      final civil = DateTime(1972, 4, 5);
      final noon = BirthNormalizer.normalize(
        RawBirthInput(
          birthDate: civil,
          birthHour: 12,
          province: 'bangkok',
          timeZoneId: 'Asia/Bangkok',
        ),
      ).birth!;
      expect(noon.sunriseAvailable, isTrue);
      final sunrise = noon.sunrise;
      final beforeHour =
          sunrise.minute == 0 ? sunrise.hour - 1 : sunrise.hour;
      final beforeMinute = sunrise.minute == 0 ? 59 : sunrise.minute - 1;
      final before = BirthNormalizer.normalize(
        RawBirthInput(
          birthDate: civil,
          birthHour: beforeHour,
          birthMinute: beforeMinute,
          province: 'bangkok',
          timeZoneId: 'Asia/Bangkok',
        ),
      ).birth!;
      expect(before.thai.bornBeforeSunrise, isTrue);
      expect(before.thai.astrologicalDate, DateTime(1972, 4, 4));
      final after = BirthNormalizer.normalize(
        RawBirthInput(
          birthDate: civil,
          birthHour: sunrise.hour,
          birthMinute: sunrise.minute + 1,
          province: 'bangkok',
          timeZoneId: 'Asia/Bangkok',
        ),
      ).birth!;
      expect(after.thai.bornBeforeSunrise, isFalse);
      expect(after.thai.astrologicalDate, DateTime(1972, 4, 5));
    });

    test('V12-12 determinism for same input', () {
      final a = ThaiBetaNarrativeFixtures.fixtureA();
      final first = ThaiBetaNarrativeComposer.compose(a);
      final second = ThaiBetaNarrativeComposer.compose(a);
      expect(first.view.signatureInsight.body, second.view.signatureInsight.body);
      expect(first.view.advice.body, second.view.advice.body);
      expect(
        first.trace.entries.map((e) => e.blockId).toList(),
        second.trace.entries.map((e) => e.blockId).toList(),
      );
    });

    test('V12-13 traceability for core / strength / risk / action', () {
      final result =
          ThaiBetaNarrativeComposer.compose(ThaiBetaNarrativeFixtures.fixtureA());
      expect(
        result.trace.entries.any(
          (e) => e.sectionId == 'personal_core' && e.blockId != null,
        ),
        isTrue,
      );
      expect(
        result.trace.entries.any(
          (e) => e.sectionId.startsWith('strength_') && e.blockId != null,
        ),
        isTrue,
      );
      expect(
        result.trace.entries.any(
          (e) => e.sectionId.startsWith('caution_') && e.blockId != null,
        ),
        isTrue,
      );
      expect(
        result.trace.entries.any(
          (e) => e.sectionId == 'advice' && e.blockId != null,
        ),
        isTrue,
      );
    });

    test('V12-17 Evidence Badge gate unchanged invited_beta', () {
      expect(ThaiEvidenceBadgeActivation.configuredState, 'invited_beta');
      expect(
        ThaiPublicEvidenceBadgeBetaGate.shouldRenderBadges(
          flag: ThaiEvidenceBadgeFeatureFlagState.invitedBeta,
          audience: const ThaiBetaEvidenceBadgeAudience.anonymous(),
        ),
        isFalse,
      );
    });
  });

  group('V1.2 report UI', () {
    late ThaiBetaAnalysis analysis;

    setUpAll(() {
      analysis = ThaiBetaNarrativeFixtures.fixtureA();
    });

    Future<void> pumpReport(WidgetTester tester, Size size) async {
      await tester.binding.setSurfaceSize(size);
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
    }

    testWidgets('V12-14 mobile: core + SRA hierarchy visible, no badge',
        (tester) async {
      await pumpReport(tester, const Size(390, 844));
      expect(find.byType(ThaiBetaReportPage), findsOneWidget);
      expect(find.byType(ThaiBetaEvidenceBadgePanel), findsNothing);
      expect(find.byKey(const Key('thai_consumer_signature_insight')), findsOneWidget);
      expect(find.text(ThaiBetaNarrativeV12.strengthsSectionTitle), findsOneWidget);
      expect(find.text(ThaiBetaNarrativeV12.cautionsSectionTitle), findsOneWidget);
      expect(find.text(ThaiBetaNarrativeV12.adviceSectionTitle), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('V12-15 desktop: core + SRA visible, no badge', (tester) async {
      await pumpReport(tester, const Size(1280, 800));
      expect(find.byType(ThaiBetaReportPage), findsOneWidget);
      expect(find.byType(ThaiBetaEvidenceBadgePanel), findsNothing);
      expect(find.byKey(const Key('thai_consumer_signature_insight')), findsOneWidget);
      expect(find.text(ThaiBetaNarrativeV12.strengthsSectionTitle), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    test('V12-16 public gate helpers still distinguish anonymous', () {
      expect(
        ThaiPublicEvidenceBadgeBetaGate.shouldRenderBadges(
          flag: ThaiEvidenceBadgeFeatureFlagState.invitedBeta,
          audience: const ThaiBetaEvidenceBadgeAudience.anonymous(),
        ),
        isFalse,
      );
    });
  });
}

String _publicText(ThaiBetaNarrativeResult result) {
  final view = result.view;
  final buf = StringBuffer()
    ..writeln(view.hero.headline)
    ..writeln(view.hero.summary)
    ..writeln(view.signatureInsight.eyebrow)
    ..writeln(view.signatureInsight.body)
    ..writeln(view.signatureInsight.signature)
    ..writeln(view.advice.title)
    ..writeln(view.advice.body);
  for (final card in view.strengths.cards) {
    buf
      ..writeln(card.title)
      ..writeln(card.body)
      ..writeln(card.expandedBody ?? '');
  }
  for (final card in view.cautions.cards) {
    buf
      ..writeln(card.title)
      ..writeln(card.body);
  }
  return buf.toString();
}

int _thaiWeekdayNumber(String ymd) {
  final parts = ymd.split('-');
  final d = DateTime(
    int.parse(parts[0]),
    int.parse(parts[1]),
    int.parse(parts[2]),
  );
  final w = d.weekday;
  return w == DateTime.sunday ? 1 : w + 1;
}
