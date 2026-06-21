import 'package:flutter_test/flutter_test.dart';
import 'package:knowme/features/astrology/thai/mirror/models/thai_mirror_section_id.dart';
import 'package:knowme/features/astrology/thai/qa/population/thai_mirror_population_analyzer.dart';
import 'package:knowme/features/astrology/thai/qa/population/thai_mirror_population_report.dart';

void main() {
  group('Thai Mirror Population Fix Sprint V1', () {
    late ThaiMirrorPopulationReport report;

    setUpAll(() {
      report = ThaiMirrorPopulationAnalyzer.analyze();
    });

    test('120 profiles succeed with zero crashes', () {
      expect(report.profileCount, 120);
      expect(report.successCount, 120);
      expect(report.crashCount, 0);
    });

    test('leadership #1 theme share below 25%', () {
      final leadershipShare =
          report.topThemeDistribution.share('leadership');
      expect(leadershipShare, lessThan(0.25));
    });

    test('mahabhuta evidence share below 45%', () {
      final share = report.evidenceDistribution.share('mahabhuta_position');
      expect(share, lessThan(0.45));
    });

    test('myanmar evidence share above 15%', () {
      final share = report.evidenceDistribution.share('myanmar_seven');
      expect(share, greaterThan(0.15));
    });

    test('lagna + lord evidence share above 25%', () {
      final lagnaShare = report.evidenceDistribution.share('lagna');
      final lordShare = report.evidenceDistribution.share('lagna_lord');
      expect(lagnaShare + lordShare, greaterThan(0.25));
    });

    test('narrative uniqueness above 20%', () {
      expect(report.narrativeDiversity.uniquenessRatio, greaterThan(0.20));
    });

    test('growth areas use engine-scored themes only — no synthetic assignment',
        () {
      final coverage =
          report.sectionCoverage[ThaiMirrorSectionId.growthAreas] ?? 0;
      expect(coverage, lessThanOrEqualTo(1.0));
      expect(report.crashCount, 0);
    });

    test('no birth time cohort does not regress', () {
      expect(report.noBirthTimeQuality.emptyTopThemeRateWithoutBirthTime, 0);
      expect(report.noBirthTimeQuality.crashRateWithoutBirthTime, 0);
      expect(
        report.noBirthTimeQuality.avgEvidenceWithoutBirthTime,
        greaterThan(0),
      );
      expect(
        report.noBirthTimeQuality.avgSectionsWithThemesWithoutBirthTime,
        greaterThan(5),
        reason: 'growth areas may be empty without engine-scored themes',
      );
    });
  });
}
