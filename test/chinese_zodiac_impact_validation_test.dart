import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

import 'validation/chinese_zodiac_impact/chinese_zodiac_impact_profiles.dart';
import 'validation/chinese_zodiac_impact/chinese_zodiac_impact_report.dart';
import 'validation/chinese_zodiac_impact/chinese_zodiac_impact_runner.dart';

void main() {
  group('Chinese Zodiac Impact Validation V1', () {
    late List<ChineseZodiacProfileComparison> comparisons;
    late ChineseZodiacImpactAudit audit;

    setUpAll(() {
      comparisons = ChineseZodiacImpactRunner.runAll();
      audit = ChineseZodiacImpactReport.build(comparisons);

      ChineseZodiacImpactReport.writeArtifacts(
        audit: audit,
        jsonPath: 'test/validation/chinese_zodiac_impact/output/results.json',
        markdownPath: 'docs/CHINESE_ZODIAC_IMPACT_VALIDATION_V1.md',
      );
    });

    test('uses at least 12 profiles covering all zodiac animals', () {
      expect(comparisons.length, greaterThanOrEqualTo(12));

      final animals = comparisons.map((item) => item.profile.animalKey).toSet();
      expect(animals.length, 12);
    });

    test('preferred 24 profiles with mixed day masters and elements', () {
      expect(comparisons.length, 24);

      final profiles = ChineseZodiacImpactProfiles.all();
      final variants = profiles.map((item) => item.variant).toSet();
      expect(variants, contains('A'));
      expect(variants, contains('B'));

      final dayMasters = profiles.map((item) => item.dayMasterLabel).toSet();
      expect(dayMasters.length, greaterThanOrEqualTo(2));
    });

    test('zodiac arm increases fusion theme count vs core-only', () {
      final increased = comparisons
          .where((item) => item.themeCountDelta > 0)
          .length;
      expect(increased, greaterThanOrEqualTo(12));
    });

    test('every profile receives qualitative tier classification', () {
      for (final comparison in comparisons) {
        expect(
          ChineseZodiacQualitativeTier.values,
          contains(comparison.qualitative.tier),
        );
        expect(comparison.qualitative.notes, isNotEmpty);
      }
    });

    test('produces audit artifacts with aggregate before/after metrics', () {
      expect(audit.aggregateBefore['themeCountAvg'], isNotNull);
      expect(audit.aggregateAfter['themeCountAvg'], isNotNull);
      expect(
        audit.aggregateAfter['themeCountAvg']!,
        greaterThan(audit.aggregateBefore['themeCountAvg']!),
      );

      expect(
        File('test/validation/chinese_zodiac_impact/output/results.json')
            .existsSync(),
        isTrue,
      );
      expect(
        File('docs/CHINESE_ZODIAC_IMPACT_VALIDATION_V1.md').existsSync(),
        isTrue,
      );
    });

    test('identifies high-value and low-value animals', () {
      expect(audit.highValueAnimals, isNotEmpty);
      expect(audit.recommendation, isNotEmpty);
      expect(audit.narrativeImpactSummary, isNotEmpty);
      expect(audit.duplicationAnalysis, isNotEmpty);
    });
  });
}
