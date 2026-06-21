import 'audits/fusion_distribution_audit.dart';
import 'audits/narrative_duplication_audit.dart';
import 'audits/pattern_distribution_audit.dart';
import 'audits/population_coverage_audit.dart';
import 'audits/population_diversity_audit.dart';
import 'factory/synthetic_human_profile_factory.dart';
import 'pipeline/synthetic_human_pipeline_runner.dart';
import 'pipeline/synthetic_human_run_record.dart';

/// Runs the full synthetic population through the frozen KnowMe pipeline.
class SyntheticPopulationAudit {
  const SyntheticPopulationAudit({
    required this.records,
    required this.diversity,
    required this.coverage,
    required this.narrativeDuplication,
    required this.patternDistribution,
    required this.fusionDistribution,
    required this.recommendations,
  });

  final List<SyntheticHumanRunRecord> records;
  final PopulationDiversityAudit diversity;
  final PopulationCoverageAudit coverage;
  final NarrativeDuplicationAudit narrativeDuplication;
  final PatternDistributionAudit patternDistribution;
  final FusionDistributionAudit fusionDistribution;
  final List<String> recommendations;
}

abstract final class SyntheticPopulationRunner {
  static SyntheticPopulationAudit runAll() {
    final profiles = SyntheticHumanProfileFactory.buildAll();
    final records = <SyntheticHumanRunRecord>[];

    for (var index = 0; index < profiles.length; index++) {
      records.add(
        SyntheticHumanPipelineRunner.run(
          profiles[index],
          generatedAt: DateTime.utc(2026, 6, 21, index % 24),
        ),
      );
    }

    final diversity = PopulationDiversityAudit.analyze(records);
    final coverage = PopulationCoverageAudit.analyze(records);
    final narrative = NarrativeDuplicationAudit.analyze(records);
    final patterns = PatternDistributionAudit.analyze(records);
    final fusion = FusionDistributionAudit.analyze(records);
    final recommendations = _recommendations(
      diversity: diversity,
      coverage: coverage,
      narrative: narrative,
      patterns: patterns,
      fusion: fusion,
    );

    return SyntheticPopulationAudit(
      records: records,
      diversity: diversity,
      coverage: coverage,
      narrativeDuplication: narrative,
      patternDistribution: patterns,
      fusionDistribution: fusion,
      recommendations: recommendations,
    );
  }

  static List<String> _recommendations({
    required PopulationDiversityAudit diversity,
    required PopulationCoverageAudit coverage,
    required NarrativeDuplicationAudit narrative,
    required PatternDistributionAudit patterns,
    required FusionDistributionAudit fusion,
  }) {
    final items = <String>[];

    if (coverage.dominantSystems.isNotEmpty) {
      items.add(
        'Dominant mirror contributors: ${coverage.dominantSystems.join(', ')} '
        '— review whether downstream fusion/pattern layers over-index these signals.',
      );
    }
    if (coverage.weakSystems.isNotEmpty) {
      items.add(
        'Weak mirror contributors: ${coverage.weakSystems.join(', ')} '
        '— validate mapping coverage or increase theme differentiation.',
      );
    }
    if (diversity.narrativeDiversityRatio < 0.5) {
      items.add(
        'Narrative diversity ratio ${diversity.narrativeDiversityRatio.toStringAsFixed(2)} '
        'indicates narrative collapse risk across realistic humans.',
      );
    }
    if (narrative.collapseZones.isNotEmpty) {
      items.add(
        '${narrative.collapseZones.length} narrative collapse zones detected '
        '(clusters of ≥3 identical narratives).',
      );
    }
    if (patterns.deadZonePatternIds.isNotEmpty) {
      items.add(
        '${patterns.deadZonePatternIds.length} human patterns never activated '
        'across ${patterns.populationSize} profiles.',
      );
    }
    if (fusion.fusionDeadZones.isNotEmpty) {
      items.add(
        '${fusion.fusionDeadZones.length} mirror keys present in inputs but '
        'never surfaced in fusion findings.',
      );
    }
    if (diversity.fusionDiversityRatio < 0.3) {
      items.add(
        'Fusion diversity ratio ${diversity.fusionDiversityRatio.toStringAsFixed(2)} '
        'suggests fusion structural hashing may be collapsing distinct humans.',
      );
    }

    if (items.isEmpty) {
      items.add(
        'Population stress test completed with acceptable diversity across layers.',
      );
    }

    return items;
  }
}
