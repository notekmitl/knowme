import 'package:flutter_test/flutter_test.dart';
import 'package:knowme/features/thai_beta/application/narrative/thai_beta_narrative_composer.dart';
import 'package:knowme/features/thai_beta/application/narrative/thai_beta_narrative_specificity.dart';

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
      final hero = ThaiBetaNarrativeComposer.compose(
        ThaiBetaNarrativeFixtures.fixtureB(),
      ).view.hero;
      expect(hero.summary, contains('ไม่มีเวลาเกิด'));
      expect(hero.summary, isNot(contains('จังหวะชีวิตรายชั่วโมงที่แม่นยำ')));
    });

    test('different fixtures produce meaningfully different openings', () {
      final a = ThaiBetaNarrativeComposer.compose(
        ThaiBetaNarrativeFixtures.fixtureA(),
      ).view.hero.headline;
      final b = ThaiBetaNarrativeComposer.compose(
        ThaiBetaNarrativeFixtures.fixtureB(),
      ).view.hero.headline;
      final e = ThaiBetaNarrativeComposer.compose(
        ThaiBetaNarrativeFixtures.fixtureE(),
      ).view.hero.headline;
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

    test('important sections trace trait, domain, and life period', () {
      final result = ThaiBetaNarrativeComposer.compose(
        ThaiBetaNarrativeFixtures.fixtureA(),
      );
      final entries = result.trace.entries;

      expect(entries.any((e) => e.sectionId == 'hero' && e.field == 'headline'),
          isTrue);
      expect(entries.any((e) => e.sectionId == 'hero' && e.field == 'summary'),
          isTrue);
      expect(
        entries.where((e) => e.sectionId.startsWith('dashboard_')).length,
        greaterThanOrEqualTo(5),
      );
      expect(
        entries.where((e) => e.sectionId.startsWith('narrative_')).length,
        greaterThanOrEqualTo(5),
      );

      final withDomain = entries.where((e) => e.domain != null);
      expect(withDomain, isNotEmpty);
      for (final entry in withDomain) {
        expect(entry.primaryTrait, isNotEmpty);
      }

      final withLifePeriod = entries.where((e) => e.lifePeriod?.isNotEmpty ?? false);
      expect(withLifePeriod, isNotEmpty);
    });
  });
}
