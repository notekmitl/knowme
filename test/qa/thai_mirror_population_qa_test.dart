import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:knowme/features/astrology/thai/mirror/models/thai_mirror_section_id.dart';
import 'package:knowme/features/astrology/thai/qa/population/thai_mirror_population_analyzer.dart';
import 'package:knowme/features/astrology/thai/qa/population/thai_mirror_population_generator.dart';
import 'package:knowme/features/astrology/thai/qa/population/thai_mirror_population_profile.dart';
import 'package:knowme/features/astrology/thai/qa/population/thai_mirror_population_qa_routes.dart';
import 'package:knowme/features/astrology/thai/qa/population/thai_mirror_population_qa_screen.dart';
import 'package:knowme/features/astrology/thai/qa/population/thai_mirror_population_report.dart';

void main() {
  group('ThaiMirrorPopulationGenerator', () {
    test('generates 120 balanced profiles', () {
      final profiles = ThaiMirrorPopulationGenerator.generate();

      expect(profiles, hasLength(120));
      expect(profiles.first.id, 'POP-001');
      expect(profiles.last.id, 'POP-120');
    });

    test('no birth time is at least 35%', () {
      final profiles = ThaiMirrorPopulationGenerator.generate();
      final ratio = ThaiMirrorPopulationGenerator.noBirthTimeRatioFor(profiles);

      expect(ratio, greaterThanOrEqualTo(0.35));
      expect(
        profiles.where((profile) => !profile.hasBirthTime).length,
        42,
      );
    });

    test('gender distribution is balanced', () {
      final profiles = ThaiMirrorPopulationGenerator.generate();
      final male = profiles
          .where((p) => p.gender == ThaiMirrorPopulationGender.male)
          .length;
      final female = profiles
          .where((p) => p.gender == ThaiMirrorPopulationGender.female)
          .length;

      expect(male, 60);
      expect(female, 60);
    });

    test('months are evenly distributed', () {
      final profiles = ThaiMirrorPopulationGenerator.generate();
      final monthCounts = List<int>.filled(12, 0);

      for (final profile in profiles) {
        final month = profile.birthData.localDateTime.month;
        monthCounts[month - 1]++;
      }

      for (final count in monthCounts) {
        expect(count, 10);
      }
    });

    test('birth years span multiple decades', () {
      final profiles = ThaiMirrorPopulationGenerator.generate();
      final years = profiles
          .map((profile) => profile.birthData.localDateTime.year)
          .toSet();

      expect(years.length, greaterThanOrEqualTo(8));
      expect(years.reduce((a, b) => a < b ? a : b), lessThan(1970));
      expect(years.reduce((a, b) => a > b ? a : b), greaterThan(2010));
    });
  });

  group('ThaiMirrorPopulationAnalyzer', () {
    late ThaiMirrorPopulationReport report;

    setUpAll(() {
      report = ThaiMirrorPopulationAnalyzer.analyze();
    });

    test('runs 120 profiles without crash', () {
      expect(report.profileCount, 120);
      expect(report.successCount, 120);
      expect(report.crashCount, 0);
    });

    test('produces all analysis dimensions', () {
      expect(report.lagnaDistribution.total, greaterThan(0));
      expect(report.topThemeDistribution.total, 120);
      expect(report.confidenceDistribution.total, greaterThan(0));
      expect(report.evidenceDistribution.total, greaterThan(0));
      expect(report.sectionCoverage, isNotEmpty);
      expect(report.narrativeDiversity.totalSummaries, greaterThan(0));
      expect(report.noBirthTimeQuality.withoutBirthTimeCount, 42);
    });

    test('no birth time cohort has themes and evidence', () {
      expect(report.noBirthTimeQuality.emptyTopThemeRateWithoutBirthTime, 0);
      expect(
        report.noBirthTimeQuality.avgEvidenceWithoutBirthTime,
        greaterThan(0),
      );
      expect(report.noBirthTimeQuality.crashRateWithoutBirthTime, 0);
    });

    test('markdown report contains required sections', () {
      final markdown = report.toMarkdown();

      expect(markdown, contains('# Thai Mirror Population QA V1'));
      expect(markdown, contains('## Population Summary'));
      expect(markdown, contains('## Top Findings'));
      expect(markdown, contains('## Potential Biases'));
      expect(markdown, contains('## Distribution Charts'));
      expect(markdown, contains('## Recommendations'));
      expect(markdown, contains('Lagna Distribution'));
      expect(markdown, contains('Top Theme #1 Distribution'));
    });

    test('answers bias question with explicit flag', () {
      expect(report.potentialBiases, isNotEmpty);
      expect(report.findings, isNotEmpty);
      expect(report.recommendations, isNotEmpty);
    });
  });

  group('ThaiMirrorPopulationAnalyzer targets', () {
    test('meets population fix sprint thresholds', () {
      final report = ThaiMirrorPopulationAnalyzer.analyze();

      expect(report.topThemeDistribution.share('leadership'), lessThan(0.25));
      expect(
        report.evidenceDistribution.share('mahabhuta_position'),
        lessThan(0.45),
      );
      expect(
        report.evidenceDistribution.share('myanmar_seven'),
        greaterThan(0.15),
      );
      expect(report.narrativeDiversity.uniquenessRatio, greaterThan(0.20));
      expect(
        report.sectionCoverage[ThaiMirrorSectionId.growthAreas] ?? 0,
        lessThanOrEqualTo(1.0),
      );
    });
  });

  group('ThaiMirrorPopulationQaRoutes', () {
    testWidgets('route opens population QA screen', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          onGenerateRoute: ThaiMirrorPopulationQaRoutes.onGenerateRoute,
          initialRoute: ThaiMirrorPopulationQaRoutes.populationQaPath,
        ),
      );

      await tester.pump();
      expect(find.byType(ThaiMirrorPopulationQaScreen), findsOneWidget);
      expect(find.text('Thai Mirror Population QA'), findsOneWidget);
    });
  });
}
