import '../../mirror/models/thai_mirror_section_id.dart';
import 'thai_mirror_population_distribution.dart';
import 'thai_mirror_population_metrics.dart';
import 'thai_mirror_population_record.dart';

/// Narrative uniqueness metrics across the population.
class NarrativeDiversityMetrics {
  const NarrativeDiversityMetrics({
    required this.totalSummaries,
    required this.uniqueSummaries,
    required this.uniquenessRatio,
    required this.duplicateSummaryRate,
    required this.mostRepeatedSummaryCount,
  });

  final int totalSummaries;
  final int uniqueSummaries;
  final double uniquenessRatio;
  final double duplicateSummaryRate;
  final int mostRepeatedSummaryCount;
}

/// Quality comparison between birth-time and no-birth-time cohorts.
class NoBirthTimeQualityMetrics {
  const NoBirthTimeQualityMetrics({
    required this.withBirthTimeCount,
    required this.withoutBirthTimeCount,
    required this.avgEvidenceWithBirthTime,
    required this.avgEvidenceWithoutBirthTime,
    required this.avgSectionsWithThemesWithBirthTime,
    required this.avgSectionsWithThemesWithoutBirthTime,
    required this.emptyTopThemeRateWithBirthTime,
    required this.emptyTopThemeRateWithoutBirthTime,
    required this.crashRateWithoutBirthTime,
  });

  final int withBirthTimeCount;
  final int withoutBirthTimeCount;
  final double avgEvidenceWithBirthTime;
  final double avgEvidenceWithoutBirthTime;
  final double avgSectionsWithThemesWithBirthTime;
  final double avgSectionsWithThemesWithoutBirthTime;
  final double emptyTopThemeRateWithBirthTime;
  final double emptyTopThemeRateWithoutBirthTime;
  final double crashRateWithoutBirthTime;
}

/// One detected population-level finding.
class ThaiMirrorPopulationFinding {
  const ThaiMirrorPopulationFinding({
    required this.severity,
    required this.title,
    required this.detail,
  });

  final String severity;
  final String title;
  final String detail;
}

/// Potential statistical bias in mirror output.
class ThaiMirrorPopulationBias {
  const ThaiMirrorPopulationBias({
    required this.dimension,
    required this.description,
    required this.concentrationIndex,
    required this.isAbnormal,
  });

  final String dimension;
  final String description;
  final double concentrationIndex;
  final bool isAbnormal;
}

/// Aggregated Population QA report for Thai Mirror.
class ThaiMirrorPopulationReport {
  const ThaiMirrorPopulationReport({
    required this.profileCount,
    required this.successCount,
    required this.crashCount,
    required this.noBirthTimeCount,
    required this.noBirthTimeRatio,
    required this.lagnaDistribution,
    required this.topThemeDistribution,
    required this.confidenceDistribution,
    required this.evidenceDistribution,
    required this.sectionCoverage,
    required this.narrativeDiversity,
    required this.noBirthTimeQuality,
    required this.findings,
    required this.potentialBiases,
    required this.recommendations,
    required this.hasAbnormalConcentration,
  });

  final int profileCount;
  final int successCount;
  final int crashCount;
  final int noBirthTimeCount;
  final double noBirthTimeRatio;
  final ThaiMirrorPopulationDistribution lagnaDistribution;
  final ThaiMirrorPopulationDistribution topThemeDistribution;
  final ThaiMirrorPopulationDistribution confidenceDistribution;
  final ThaiMirrorPopulationDistribution evidenceDistribution;
  final Map<ThaiMirrorSectionId, double> sectionCoverage;
  final NarrativeDiversityMetrics narrativeDiversity;
  final NoBirthTimeQualityMetrics noBirthTimeQuality;
  final List<ThaiMirrorPopulationFinding> findings;
  final List<ThaiMirrorPopulationBias> potentialBiases;
  final List<String> recommendations;
  final bool hasAbnormalConcentration;

  static ThaiMirrorPopulationReport fromRecords(
    List<ThaiMirrorPopulationRecord> records,
  ) {
    final succeeded = records.where((r) => r.succeeded).toList();
    final lagna = records.lagnaDistribution();
    final topThemes = records.topThemeDistribution();
    final confidence = records.confidenceDistribution();
    final evidence = records.evidenceLensDistribution();
    final sections = records.sectionCoverage();
    final narrative = records.narrativeDiversity();
    final noBirth = records.noBirthTimeQuality();

    final biases = _detectBiases(
      lagna: lagna,
      topThemes: topThemes,
      evidence: evidence,
      narrative: narrative,
      sections: sections,
    );

    final findings = _buildFindings(
      records: records,
      lagna: lagna,
      topThemes: topThemes,
      narrative: narrative,
      noBirth: noBirth,
      biases: biases,
    );

    final recommendations = _buildRecommendations(
      biases: biases,
      narrative: narrative,
      noBirth: noBirth,
      sections: sections,
    );

    final withoutBirthTime =
        records.where((r) => !r.profile.hasBirthTime).length;

    return ThaiMirrorPopulationReport(
      profileCount: records.length,
      successCount: succeeded.length,
      crashCount: records.length - succeeded.length,
      noBirthTimeCount: withoutBirthTime,
      noBirthTimeRatio: records.isEmpty ? 0 : withoutBirthTime / records.length,
      lagnaDistribution: lagna,
      topThemeDistribution: topThemes,
      confidenceDistribution: confidence,
      evidenceDistribution: evidence,
      sectionCoverage: sections,
      narrativeDiversity: narrative,
      noBirthTimeQuality: noBirth,
      findings: findings,
      potentialBiases: biases,
      recommendations: recommendations,
      hasAbnormalConcentration: biases.any((bias) => bias.isAbnormal),
    );
  }

  static List<ThaiMirrorPopulationBias> _detectBiases({
    required ThaiMirrorPopulationDistribution lagna,
    required ThaiMirrorPopulationDistribution topThemes,
    required ThaiMirrorPopulationDistribution evidence,
    required NarrativeDiversityMetrics narrative,
    required Map<ThaiMirrorSectionId, double> sections,
  }) {
    final biases = <ThaiMirrorPopulationBias>[];

  final lagnaWithTime = Map<String, int>.from(lagna.counts)
      ..remove('no_lagna');
    final lagnaAmongTimed = ThaiMirrorPopulationDistribution(
      counts: lagnaWithTime,
      total: lagnaWithTime.values.fold(0, (a, b) => a + b),
      label: 'Lagna (with birth time)',
    );

    final expectedLagnaShare = lagnaAmongTimed.total > 0 ? 1 / 12 : 0;
    final lagnaDominant = lagnaAmongTimed.dominantShare ?? 0;
    biases.add(
      ThaiMirrorPopulationBias(
        dimension: 'Lagna',
        description: lagnaAmongTimed.dominantKey == null
            ? 'No lagna distribution (all profiles missing birth time).'
            : 'Dominant lagna ${lagnaAmongTimed.dominantKey} at '
                '${(lagnaDominant * 100).toStringAsFixed(1)}% '
                '(expected ~${(expectedLagnaShare * 100).toStringAsFixed(1)}% uniform).',
        concentrationIndex: lagnaAmongTimed.concentrationIndex,
        isAbnormal: lagnaDominant > 0.15 || lagnaAmongTimed.concentrationIndex > 0.12,
      ),
    );

    final topDominant = topThemes.dominantShare ?? 0;
    biases.add(
      ThaiMirrorPopulationBias(
        dimension: 'Top Theme #1',
        description: topThemes.dominantKey == null
            ? 'No top themes resolved.'
            : 'Theme "${topThemes.dominantKey}" leads '
                '${(topDominant * 100).toStringAsFixed(1)}% of profiles.',
        concentrationIndex: topThemes.concentrationIndex,
        isAbnormal: topDominant > 0.25 || topThemes.concentrationIndex > 0.15,
      ),
    );

    final myanmarShare = evidence.share(ThaiMirrorLensSourceIds.myanmarSeven);
    final mahabhutaShare =
        evidence.share(ThaiMirrorLensSourceIds.mahabhutaPosition);
    final lagnaShare = evidence.share(ThaiMirrorLensSourceIds.lagna);
    biases.add(
      ThaiMirrorPopulationBias(
        dimension: 'Evidence Lens',
        description: 'Lens mix — Myanmar ${(myanmarShare * 100).toStringAsFixed(1)}%, '
            'Mahabhuta ${(mahabhutaShare * 100).toStringAsFixed(1)}%, '
            'Lagna ${(lagnaShare * 100).toStringAsFixed(1)}%.',
        concentrationIndex: evidence.concentrationIndex,
        isAbnormal: evidence.concentrationIndex > 0.35,
      ),
    );

    biases.add(
      ThaiMirrorPopulationBias(
        dimension: 'Narrative Diversity',
        description: 'Summary uniqueness '
            '${(narrative.uniquenessRatio * 100).toStringAsFixed(1)}% '
            '(most repeated ${narrative.mostRepeatedSummaryCount}×).',
        concentrationIndex: 1 - narrative.uniquenessRatio,
        isAbnormal: narrative.uniquenessRatio < 0.55 ||
            narrative.mostRepeatedSummaryCount > 15,
      ),
    );

    final minSectionCoverage = sections.values.isEmpty
        ? 1.0
        : sections.values.reduce((a, b) => a < b ? a : b);
    biases.add(
      ThaiMirrorPopulationBias(
        dimension: 'Section Coverage',
        description: 'Lowest section theme coverage '
            '${(minSectionCoverage * 100).toStringAsFixed(1)}%.',
        concentrationIndex: minSectionCoverage,
        isAbnormal: minSectionCoverage < 0.75,
      ),
    );

    return biases;
  }

  static List<ThaiMirrorPopulationFinding> _buildFindings({
    required List<ThaiMirrorPopulationRecord> records,
    required ThaiMirrorPopulationDistribution lagna,
    required ThaiMirrorPopulationDistribution topThemes,
    required NarrativeDiversityMetrics narrative,
    required NoBirthTimeQualityMetrics noBirth,
    required List<ThaiMirrorPopulationBias> biases,
  }) {
    final findings = <ThaiMirrorPopulationFinding>[];

    findings.add(
      ThaiMirrorPopulationFinding(
        severity: 'info',
        title: 'Population run complete',
        detail: '${records.length} profiles · ${records.where((r) => r.succeeded).length} succeeded · '
            '${records.length - records.where((r) => r.succeeded).length} failed',
      ),
    );

    if (noBirth.withoutBirthTimeCount > 0) {
      findings.add(
        ThaiMirrorPopulationFinding(
          severity: noBirth.emptyTopThemeRateWithoutBirthTime > 0
              ? 'warning'
              : 'info',
          title: 'No birth time cohort',
          detail: '${noBirth.withoutBirthTimeCount} profiles (${(noBirth.withoutBirthTimeCount / records.length * 100).toStringAsFixed(0)}%) · '
              'avg evidence ${noBirth.avgEvidenceWithoutBirthTime.toStringAsFixed(1)} vs '
              '${noBirth.avgEvidenceWithBirthTime.toStringAsFixed(1)} with birth time',
        ),
      );
    }

    final abnormal = biases.where((b) => b.isAbnormal).toList();
    if (abnormal.isEmpty) {
      findings.add(
        const ThaiMirrorPopulationFinding(
          severity: 'pass',
          title: 'No abnormal concentration detected',
          detail: 'Lagna, top themes, evidence lens mix, and narrative diversity '
              'fall within expected population variance for 120 synthetic profiles.',
        ),
      );
    } else {
      for (final bias in abnormal) {
        findings.add(
          ThaiMirrorPopulationFinding(
            severity: 'warning',
            title: 'Potential bias: ${bias.dimension}',
            detail: bias.description,
          ),
        );
      }
    }

    if (topThemes.dominantKey != null) {
      findings.add(
        ThaiMirrorPopulationFinding(
          severity: 'info',
          title: 'Most common #1 theme',
          detail: '${topThemes.dominantKey} appears in '
              '${((topThemes.dominantShare ?? 0) * 100).toStringAsFixed(1)}% of profiles',
        ),
      );
    }

    if (lagna.dominantKey != null && lagna.dominantKey != 'no_lagna') {
      findings.add(
        ThaiMirrorPopulationFinding(
          severity: 'info',
          title: 'Most common lagna',
          detail: '${lagna.dominantKey} in '
              '${((lagna.dominantShare ?? 0) * 100).toStringAsFixed(1)}% of successful profiles',
        ),
      );
    }

    findings.add(
      ThaiMirrorPopulationFinding(
        severity: narrative.uniquenessRatio >= 0.6 ? 'info' : 'warning',
        title: 'Narrative diversity',
        detail: '${narrative.uniqueSummaries} unique summaries from '
            '${narrative.totalSummaries} total '
            '(${(narrative.uniquenessRatio * 100).toStringAsFixed(1)}% unique)',
      ),
    );

    return findings;
  }

  static List<String> _buildRecommendations({
    required List<ThaiMirrorPopulationBias> biases,
    required NarrativeDiversityMetrics narrative,
    required NoBirthTimeQualityMetrics noBirth,
    required Map<ThaiMirrorSectionId, double> sections,
  }) {
    final recs = <String>[];

    if (biases.any((b) => b.dimension == 'Top Theme #1' && b.isAbnormal)) {
      recs.add(
        'Review theme scoring weights — #1 theme concentration may indicate '
        'over-dominant Myanmar/Mahabhuta or enrichment fallback patterns.',
      );
    }

    if (biases.any((b) => b.dimension == 'Lagna' && b.isAbnormal)) {
      recs.add(
        'Lagna distribution skew may reflect birth-hour clustering in synthetic '
        'data; validate with real user birth times before adjusting engine.',
      );
    }

    if (narrative.uniquenessRatio < 0.6) {
      recs.add(
        'Increase narrative template variety — duplicate summary rate is high '
        'for population-scale output.',
      );
    }

    if (noBirth.avgEvidenceWithoutBirthTime <
        noBirth.avgEvidenceWithBirthTime * 0.7) {
      recs.add(
        'No-birth-time cohort has materially lower evidence — confirm '
        'enrichment fallback is sufficient for User QA.',
      );
    }

    final lowSections = sections.entries
        .where((entry) => entry.value < 0.85)
        .map((entry) => entry.key.titleTh)
        .toList();
    if (lowSections.isNotEmpty) {
      recs.add(
        'Sections with <85% theme coverage: ${lowSections.join(', ')} — '
        'review section distribution mappings.',
      );
    }

    if (recs.isEmpty) {
      recs.add(
        'Population metrics look healthy for Limited User QA. '
        'Proceed with real-user sampling to validate synthetic findings.',
      );
    }

    return recs;
  }

  String toMarkdown() {
    final buffer = StringBuffer()
      ..writeln('# Thai Mirror Population QA V1')
      ..writeln()
      ..writeln('## Population Summary')
      ..writeln()
      ..writeln('| Metric | Value |')
      ..writeln('|--------|-------|')
      ..writeln('| Profiles | $profileCount |')
      ..writeln('| Pipeline success | $successCount |')
      ..writeln('| Crashes | $crashCount |')
      ..writeln(
        '| No birth time | $noBirthTimeCount (${(noBirthTimeRatio * 100).toStringAsFixed(1)}%) |',
      )
      ..writeln(
        '| Abnormal concentration | ${hasAbnormalConcentration ? 'YES' : 'NO'} |',
      )
      ..writeln();

    buffer.writeln('## Top Findings');
    buffer.writeln();
    for (final finding in findings) {
      buffer.writeln('- **[${finding.severity}]** ${finding.title}: ${finding.detail}');
    }
    buffer.writeln();

    buffer.writeln('## Potential Biases');
    buffer.writeln();
    buffer.writeln('| Dimension | HHI / Index | Abnormal | Detail |');
    buffer.writeln('|-----------|-------------|----------|--------|');
    for (final bias in potentialBiases) {
      buffer.writeln(
        '| ${bias.dimension} | ${bias.concentrationIndex.toStringAsFixed(3)} | '
        '${bias.isAbnormal ? '⚠️' : '✓'} | ${bias.description} |',
      );
    }
    buffer.writeln();

    buffer.writeln('## Distribution Charts');
    buffer.writeln();
    _writeDistributionTable(buffer, lagnaDistribution);
    _writeDistributionTable(buffer, topThemeDistribution);
    _writeDistributionTable(buffer, confidenceDistribution);
    _writeDistributionTable(buffer, evidenceDistribution);

    buffer.writeln('### Section Coverage');
    buffer.writeln();
    buffer.writeln('| Section | Coverage |');
    buffer.writeln('|---------|----------|');
    for (final entry in sectionCoverage.entries) {
      buffer.writeln(
        '| ${entry.key.titleTh} | ${(entry.value * 100).toStringAsFixed(1)}% |',
      );
    }
    buffer.writeln();

    buffer.writeln('### Narrative Diversity');
    buffer.writeln();
    buffer.writeln('| Metric | Value |');
    buffer.writeln('|--------|-------|');
    buffer.writeln('| Total summaries | ${narrativeDiversity.totalSummaries} |');
    buffer.writeln('| Unique summaries | ${narrativeDiversity.uniqueSummaries} |');
    buffer.writeln(
      '| Uniqueness ratio | ${(narrativeDiversity.uniquenessRatio * 100).toStringAsFixed(1)}% |',
    );
    buffer.writeln(
      '| Most repeated count | ${narrativeDiversity.mostRepeatedSummaryCount} |',
    );
    buffer.writeln();

    buffer.writeln('### No Birth Time Quality');
    buffer.writeln();
    buffer.writeln('| Metric | With time | Without time |');
    buffer.writeln('|--------|-----------|--------------|');
    buffer.writeln(
      '| Avg evidence | ${noBirthTimeQuality.avgEvidenceWithBirthTime.toStringAsFixed(1)} | '
      '${noBirthTimeQuality.avgEvidenceWithoutBirthTime.toStringAsFixed(1)} |',
    );
    buffer.writeln(
      '| Avg sections w/ themes | ${noBirthTimeQuality.avgSectionsWithThemesWithBirthTime.toStringAsFixed(1)} | '
      '${noBirthTimeQuality.avgSectionsWithThemesWithoutBirthTime.toStringAsFixed(1)} |',
    );
    buffer.writeln(
      '| Empty top themes rate | ${(noBirthTimeQuality.emptyTopThemeRateWithBirthTime * 100).toStringAsFixed(1)}% | '
      '${(noBirthTimeQuality.emptyTopThemeRateWithoutBirthTime * 100).toStringAsFixed(1)}% |',
    );
    buffer.writeln();

    buffer.writeln('## Recommendations');
    buffer.writeln();
    for (final rec in recommendations) {
      buffer.writeln('- $rec');
    }

    return buffer.toString();
  }

  void _writeDistributionTable(
    StringBuffer buffer,
    ThaiMirrorPopulationDistribution distribution,
  ) {
    buffer.writeln('### ${distribution.label}');
    buffer.writeln();
    if (distribution.total == 0) {
      buffer.writeln('_No data_');
      buffer.writeln();
      return;
    }

    buffer.writeln('| Key | Count | Share | Bar |');
    buffer.writeln('|-----|-------|-------|-----|');
    for (final entry in distribution.sortedEntries.take(15)) {
      final pct = distribution.share(entry.key) * 100;
      final barLength = (pct / 5).round().clamp(0, 20);
      final bar = '█' * barLength;
      buffer.writeln(
        '| ${entry.key} | ${entry.value} | ${pct.toStringAsFixed(1)}% | $bar |',
      );
    }
    buffer.writeln(
      '_HHI: ${distribution.concentrationIndex.toStringAsFixed(3)} · n=${distribution.total}_',
    );
    buffer.writeln();
  }
}

/// Lens id strings for distribution keys (avoids enum import in report).
abstract final class ThaiMirrorLensSourceIds {
  static const lagna = 'lagna';
  static const lagnaLord = 'lagna_lord';
  static const myanmarSeven = 'myanmar_seven';
  static const mahabhutaPosition = 'mahabhuta_position';
}
