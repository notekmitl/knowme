import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:knowme/features/astrology/thai/core/life_period/life_period_engine.dart';
import 'package:knowme/features/astrology/thai/mirror/presentation/timeline/life_map_plain_thai_renderer.dart';
import 'package:knowme/features/astrology/thai/mirror/presentation/timeline/life_map_verdict_semantics.dart';
import 'package:knowme/features/astrology/thai/mirror/presentation/timeline/thai_mirror_life_timeline_state.dart';
import 'package:knowme/features/astrology/thai/mirror/presentation/timeline/timeline_presenter.dart';
import 'package:knowme/features/astrology/thai/mirror/presentation/ui/widgets/thai_mirror_birth_data_confidence_banner.dart';
import 'package:knowme/features/thai_beta/application/narrative/thai_beta_narrative_composer.dart';
import 'package:knowme/features/thai_beta/application/thai_beta_evidence_badge_audience.dart';
import 'package:knowme/features/thai_beta/application/thai_evidence_badge_feature_flag.dart';
import 'package:knowme/features/thai_beta/presentation/pages/thai_beta_report_page.dart';

import '../../narrative/thai_beta_narrative_fixtures.dart';

/// V1.3.2 — Product copy + information hierarchy correction.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  ThaiMirrorLifeTimelineState buildAt({
    required int weekday,
    required int age,
    int seed = 17,
  }) {
    final timeline = LifePeriodEngine.build(
      birthWeekday: weekday,
      currentAge: age,
    );
    return TimelinePresenter.build(
      lifePeriods: timeline,
      lagnaLordKey: 'sun',
      orderedThemeIds: const ['structure'],
      topThemeTags: const ['มั่นคง'],
      profileSeed: seed,
    )!;
  }

  String cardText(ThaiMirrorLifePeriodState p) => [
    p.summary,
    p.whatChanges,
    p.harder,
    p.advice,
  ].where((s) => s.trim().isNotEmpty).join('\n');

  group('Life Map V1.3.2 hierarchy and language', () {
    test('opening report has one personality card — no separate core card', () {
      final view = ThaiBetaNarrativeComposer.compose(
        ThaiBetaNarrativeFixtures.fixtureA(),
      ).view;
      expect(view.hero.identityBadge, 'ดวงไทยของคุณ');
      expect(view.hero.summary, isNotEmpty);
      expect(view.hero.tags, isNotEmpty);
      expect(view.signatureInsight.isEmpty, isTrue);
      final blob = [
        view.hero.headline,
        view.hero.summary,
        view.signatureInsight.eyebrow,
        view.signatureInsight.body,
        view.signatureInsight.signature,
      ].join('\n');
      expect(blob, isNot(contains('แก่นที่พอเห็นได้จากข้อมูลที่มี')));
      expect(blob, isNot(contains('แก่นที่เห็นชัดจากข้อมูลของคุณ')));
      // Merged card must not simply dump a confidence quote filler.
      expect(
        view.hero.summary,
        isNot(contains('ใช้สังเกตตัวเอง ไม่ใช่คำฟันธง')),
      );
    });

    test('complete birth data is silent — no success banner copy', () {
      final view = ThaiBetaNarrativeComposer.compose(
        ThaiBetaNarrativeFixtures.fixtureA(),
      ).view;
      expect(view.birthDataConfidence.isComplete, isTrue);
      expect(view.birthDataConfidence.title, isEmpty);
      expect(view.birthDataConfidence.body, isEmpty);
      expect(view.hero.summary, isNot(contains('ข้อมูลวันเกิดครบถ้วน')));
      expect(view.hero.identitySubtitle, isNot(contains('น่าเชื่อถือมากขึ้น')));
    });

    test('incomplete birth data limitation lives on hero metadata', () {
      final view = ThaiBetaNarrativeComposer.compose(
        ThaiBetaNarrativeFixtures.fixtureB(),
      ).view;
      expect(view.birthDataConfidence.isComplete, isFalse);
      expect(view.birthDataConfidence.title, isEmpty);
      expect(view.hero.identitySubtitle, contains('ไม่มีเวลาเกิด'));
      expect(view.hero.identitySubtitle, contains('ภาพรวม'));
      expect(view.hero.summary, isNot(contains('ข้อมูลวันเกิดครบถ้วน')));
    });

    testWidgets('report UI: single hero, no core card, no complete banner', (
      tester,
    ) async {
      final analysis = ThaiBetaNarrativeFixtures.fixtureA();
      await tester.binding.setSurfaceSize(const Size(390, 844));
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
      expect(find.byKey(const Key('thai_consumer_hero')), findsOneWidget);
      expect(
        find.byKey(const Key('thai_consumer_signature_insight')),
        findsNothing,
      );
      expect(find.text('แก่นที่พอเห็นได้จากข้อมูลที่มี'), findsNothing);
      expect(find.text('ข้อมูลวันเกิดครบถ้วน'), findsNothing);
      expect(find.byType(ThaiMirrorBirthDataConfidenceBanner), findsNothing);
    });

    test('Past has no ในช่วงนั้น / soft opener fillers', () {
      for (final weekday in [
        DateTime.sunday,
        DateTime.monday,
        DateTime.wednesday,
        DateTime.friday,
      ]) {
        for (final age in [12, 25, 39, 55, 72]) {
          final state = buildAt(
            weekday: weekday,
            age: age,
            seed: weekday + age,
          );
          for (final p in state.periods.where((p) => p.isPast)) {
            final text = p.summary;
            expect(
              LifeMapPlainThaiRenderer.hasPastSoftOpener(text),
              isFalse,
              reason: text,
            );
            expect(text.contains('ในช่วงนั้น'), isFalse, reason: text);
            expect(text.contains('ณ ช่วงเวลานั้น'), isFalse, reason: text);
            expect(
              LifeMapPlainThaiRenderer.countMarker(text, 'ช่วงนั้น'),
              equals(0),
              reason: text,
            );
            expect(LifeMapVerdictCopy.violatesPrimaryBody(text), isFalse);
          }
        }
      }
    });

    test('Current has no vague relationship form-change jargon', () {
      for (final weekday in [
        DateTime.sunday,
        DateTime.monday,
        DateTime.tuesday,
        DateTime.wednesday,
        DateTime.thursday,
        DateTime.friday,
        DateTime.saturday,
      ]) {
        for (final age in [18, 30, 39, 48, 60]) {
          final state = buildAt(
            weekday: weekday,
            age: age,
            seed: weekday * 3 + age,
          );
          for (final p in state.periods) {
            final text = cardText(p);
            expect(
              LifeMapPlainThaiRenderer.hasVagueRelationshipForm(text),
              isFalse,
              reason: text,
            );
            expect(text.contains('รูปแบบความรักเปลี่ยน'), isFalse);
            expect(text.contains('รูปแบบความใกล้ชิดเปลี่ยน'), isFalse);
            expect(text.contains('ตั้งขอบเขตใหม่'), isFalse);
            expect(LifeMapPlainThaiRenderer.hasAbstractDuel(text), isFalse);
            expect(LifeMapVerdictCopy.violatesPrimaryBody(text), isFalse);
          }
        }
      }
    });

    test('Past/Current/Future remain distinct and deterministic', () {
      final a = buildAt(weekday: DateTime.thursday, age: 38, seed: 21);
      final b = buildAt(weekday: DateTime.thursday, age: 38, seed: 21);
      expect(
        a.periods.map(cardText).toList(),
        b.periods.map(cardText).toList(),
      );
      expect(a.periods.where((p) => p.isPast), isNotEmpty);
      expect(a.periods.where((p) => p.isCurrent), hasLength(1));
      expect(a.periods.where((p) => !p.isPast && !p.isCurrent), isNotEmpty);
      final current = a.periods.singleWhere((p) => p.isCurrent);
      expect(current.summary, isNot(equals(current.harder)));
    });
  });
}
