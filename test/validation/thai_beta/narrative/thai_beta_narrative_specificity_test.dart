import 'package:flutter_test/flutter_test.dart';
import 'package:knowme/features/thai_beta/application/core_reading/thai_birth_profile_core_reading.dart';
import 'package:knowme/features/thai_beta/application/narrative/thai_beta_narrative_composer.dart';
import 'package:knowme/features/thai_beta/application/narrative/thai_beta_narrative_specificity.dart';
import 'package:knowme/features/thai_beta/application/thai_beta_analysis.dart';

import 'thai_beta_narrative_fixtures.dart';

void main() {
  group('Specificity', () {
    test('hero combines primary and secondary signals when available', () {
      final result = ThaiBetaNarrativeComposer.compose(
        ThaiBetaNarrativeFixtures.fixtureA(),
      );
      expect(result.trace.entries.any((e) => e.sectionId == 'hero'), isTrue);
      expect(result.view.hero.summary.split('\n\n').length, greaterThanOrEqualTo(3));
    });

    test('hero contrast requires two supported signals', () {
      final ctx = ThaiBetaNarrativeFixtures.fixtureC();
      final themeIds = ctx.pipelineResult!.mirrorResult!.topThemes
          .map((t) => t.themeId)
          .toList();
      final contrast = ThaiBetaNarrativeSpecificity.composeContrast(
        orderedThemeIds: themeIds,
        seed: 42,
      );
      if (themeIds.length >= 2) {
        expect(contrast, isNotNull);
        expect(contrast!.trim().isNotEmpty, isTrue);
      }
    });

    test('no-time fixture does not claim time-dependent depth', () {
      final analysis = ThaiBetaNarrativeFixtures.fixtureB();
      final view = ThaiBetaNarrativeComposer.narrativeView(analysis);
      final core = ThaiBirthProfileCoreReading.fromAnalysis(
        analysis,
        consumerView: view,
      );
      expect(core.subtitle, contains('ไม่มีเวลาเกิด'));
      expect(core.subtitle, isNot(contains('จังหวะชีวิตรายชั่วโมงที่แม่นยำ')));
    });

    test('different fixtures produce meaningfully different openings', () {
      String opening(ThaiBetaAnalysis analysis) {
        final view = ThaiBetaNarrativeComposer.narrativeView(analysis);
        return ThaiBirthProfileCoreReading.fromAnalysis(
          analysis,
          consumerView: view,
        ).sections.first.publicParagraphs.join(' ');
      }

      final a = opening(ThaiBetaNarrativeFixtures.fixtureA());
      final b = opening(ThaiBetaNarrativeFixtures.fixtureB());
      final e = opening(ThaiBetaNarrativeFixtures.fixtureE());
      expect(a, isNot(equals(b)));
      expect(a, isNot(equals(e)));
    });

    test('observable behavior remains traceable to an existing signal', () {
      final result = ThaiBetaNarrativeComposer.compose(
        ThaiBetaNarrativeFixtures.fixtureA(),
      );
      expect(result.trace.entries, isNotEmpty);
      expect(result.trace.entries.first.primaryTrait, isNotEmpty);
    });

    test('current Core claims trace exact evidence and retain life periods', () {
      final analysis = ThaiBetaNarrativeFixtures.fixtureA();
      final view = ThaiBetaNarrativeComposer.narrativeView(analysis);
      final core = ThaiBirthProfileCoreReading.fromAnalysis(
        analysis,
        consumerView: view,
      );
      final claims = core.sections.expand((section) => section.claims).toList();

      expect(claims, isNotEmpty);
      expect(claims.every((claim) => claim.evidenceKeys.isNotEmpty), isTrue);
      expect(view.lifeTimeline?.periods, isNotEmpty);
    });
  });
}
