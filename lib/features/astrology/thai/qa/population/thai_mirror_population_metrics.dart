import '../../mirror/models/thai_mirror_section_id.dart';
import 'thai_mirror_population_distribution.dart';
import 'thai_mirror_population_record.dart';
import 'thai_mirror_population_report.dart';

/// Aggregated metrics computed from population pipeline records.
extension ThaiMirrorPopulationRecordMetrics on List<ThaiMirrorPopulationRecord> {
  List<ThaiMirrorPopulationRecord> get succeeded =>
      where((record) => record.succeeded).toList(growable: false);

  List<ThaiMirrorPopulationRecord> get withBirthTime => where(
        (record) => record.profile.hasBirthTime,
      ).toList(growable: false);

  List<ThaiMirrorPopulationRecord> get withoutBirthTime => where(
        (record) => !record.profile.hasBirthTime,
      ).toList(growable: false);

  ThaiMirrorPopulationDistribution lagnaDistribution() {
    final counts = <String, int>{};
    for (final record in succeeded) {
      final key = record.lagnaKey ?? 'no_lagna';
      counts[key] = (counts[key] ?? 0) + 1;
    }
    return ThaiMirrorPopulationDistribution(
      label: 'Lagna Distribution',
      counts: counts,
      total: succeeded.length,
    );
  }

  ThaiMirrorPopulationDistribution topThemeDistribution({int rank = 0}) {
    final counts = <String, int>{};
    for (final record in succeeded) {
      if (record.topThemeIds.length <= rank) continue;
      final key = record.topThemeIds[rank];
      counts[key] = (counts[key] ?? 0) + 1;
    }
    return ThaiMirrorPopulationDistribution(
      label: 'Top Theme #${rank + 1} Distribution',
      counts: counts,
      total: succeeded.length,
    );
  }

  ThaiMirrorPopulationDistribution confidenceDistribution() {
    final counts = <String, int>{};
    for (final record in succeeded) {
      for (final level in record.topThemeConfidences) {
        counts[level] = (counts[level] ?? 0) + 1;
      }
    }
    final total = counts.values.fold<int>(0, (sum, value) => sum + value);
    return ThaiMirrorPopulationDistribution(
      label: 'Top Theme Confidence Distribution',
      counts: counts,
      total: total,
    );
  }

  ThaiMirrorPopulationDistribution evidenceLensDistribution() {
    final counts = <String, int>{};
    for (final record in succeeded) {
      for (final entry in record.evidenceByLens.entries) {
        counts[entry.key] = (counts[entry.key] ?? 0) + entry.value;
      }
    }
    final total = counts.values.fold<int>(0, (sum, value) => sum + value);
    return ThaiMirrorPopulationDistribution(
      label: 'Evidence by Lens',
      counts: counts,
      total: total,
    );
  }

  Map<ThaiMirrorSectionId, double> sectionCoverage() {
    if (succeeded.isEmpty) return {};

    final totals = <ThaiMirrorSectionId, int>{};
    for (final sectionId in ThaiMirrorSectionId.values) {
      if (!sectionId.isFusionSection) continue;
      totals[sectionId] = 0;
    }

    for (final record in succeeded) {
      final mirror = record.pipelineResult.mirrorResult!;
      for (final section in mirror.sections) {
        if (!section.id.isFusionSection) continue;
        if (section.supportingThemes.isNotEmpty) {
          totals[section.id] = (totals[section.id] ?? 0) + 1;
        }
      }
    }

    return totals.map(
      (sectionId, count) => MapEntry(sectionId, count / succeeded.length),
    );
  }

  NarrativeDiversityMetrics narrativeDiversity() {
    final allSummaries = <String>[];
    for (final record in succeeded) {
      allSummaries.addAll(record.summaries);
    }

    if (allSummaries.isEmpty) {
      return const NarrativeDiversityMetrics(
        totalSummaries: 0,
        uniqueSummaries: 0,
        uniquenessRatio: 0,
        duplicateSummaryRate: 0,
        mostRepeatedSummaryCount: 0,
      );
    }

    final frequency = <String, int>{};
    for (final summary in allSummaries) {
      frequency[summary] = (frequency[summary] ?? 0) + 1;
    }

    final unique = frequency.length;
    final mostRepeated = frequency.values.reduce((a, b) => a > b ? a : b);

    return NarrativeDiversityMetrics(
      totalSummaries: allSummaries.length,
      uniqueSummaries: unique,
      uniquenessRatio: unique / allSummaries.length,
      duplicateSummaryRate: 1 - (unique / allSummaries.length),
      mostRepeatedSummaryCount: mostRepeated,
    );
  }

  NoBirthTimeQualityMetrics noBirthTimeQuality() {
    final withTime = succeeded.withBirthTime;
    final withoutTime = succeeded.withoutBirthTime;

    double avgEvidence(List<ThaiMirrorPopulationRecord> subset) {
      if (subset.isEmpty) return 0;
      return subset
              .map((record) => record.evidenceCount)
              .reduce((a, b) => a + b) /
          subset.length;
    }

    double avgSectionsWithThemes(List<ThaiMirrorPopulationRecord> subset) {
      if (subset.isEmpty) return 0;
      return subset
              .map((record) => record.sectionsWithThemes)
              .reduce((a, b) => a + b) /
          subset.length;
    }

    double emptyTopThemeRate(List<ThaiMirrorPopulationRecord> subset) {
      if (subset.isEmpty) return 0;
      final empty =
          subset.where((record) => record.topThemeIds.isEmpty).length;
      return empty / subset.length;
    }

    return NoBirthTimeQualityMetrics(
      withBirthTimeCount: withTime.length,
      withoutBirthTimeCount: withoutTime.length,
      avgEvidenceWithBirthTime: avgEvidence(withTime),
      avgEvidenceWithoutBirthTime: avgEvidence(withoutTime),
      avgSectionsWithThemesWithBirthTime: avgSectionsWithThemes(withTime),
      avgSectionsWithThemesWithoutBirthTime: avgSectionsWithThemes(withoutTime),
      emptyTopThemeRateWithBirthTime: emptyTopThemeRate(withTime),
      emptyTopThemeRateWithoutBirthTime: emptyTopThemeRate(withoutTime),
      crashRateWithoutBirthTime: withoutBirthTime.isEmpty
          ? 0
          : withoutBirthTime.where((r) => !r.succeeded).length /
              withoutBirthTime.length,
    );
  }
}
