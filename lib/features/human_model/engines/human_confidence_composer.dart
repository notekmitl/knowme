import '../catalog/human_dimension_catalog.dart';
import '../domain/human_confidence.dart';
import '../domain/human_coverage.dart';
import '../domain/human_dimension.dart';
import '../domain/human_dimension_activation.dart';
import '../domain/human_pattern.dart';
import '../domain/human_profile.dart';
import 'package:knowme/features/global_fusion/foundation/domain/global_fusion_snapshot.dart';

/// HM5 — composes human confidence without passthrough of fusion composite.
abstract final class HumanConfidenceComposer {
  static const _fusionWeight = 0.30;
  static const _coverageWeight = 0.25;
  static const _diversityWeight = 0.25;
  static const _patternWeight = 0.20;

  static HumanConfidence compose({
    required GlobalFusionSnapshot fusionSnapshot,
    required HumanCoverage coverage,
    required List<HumanPattern> patterns,
    required List<HumanEvidenceRow> evidenceRows,
  }) {
    final fusionInfluence = _fusionInfluence(fusionSnapshot);
    final coverageScore = coverage.weightedCoverage.clamp(0.0, 1.0);
    final diversityScore = _evidenceDiversity(evidenceRows);
    final patternStrength = patterns.isEmpty
        ? 0.0
        : patterns.map((item) => item.patternStrength).reduce((a, b) => a > b ? a : b);

    final composite = (
      fusionInfluence * _fusionWeight +
      coverageScore * _coverageWeight +
      diversityScore * _diversityWeight +
      patternStrength * _patternWeight
    ).clamp(0.0, 1.0);

    return HumanConfidence(
      composite: composite,
      fusionInfluenceScore: fusionInfluence,
      coverageScore: coverageScore,
      evidenceDiversityScore: diversityScore,
      patternStrengthScore: patternStrength,
    );
  }

  static double _fusionInfluence(GlobalFusionSnapshot fusionSnapshot) {
    final fusion = fusionSnapshot.confidence;
    return (
      fusion.mirrorDiversityScore * 0.35 +
      fusion.agreementStrengthScore * 0.35 +
      fusion.evidenceDepthScore * 0.30 -
      fusion.tensionPenalty * 0.5
    ).clamp(0.0, 1.0);
  }

  static double _evidenceDiversity(List<HumanEvidenceRow> rows) {
    if (rows.isEmpty) return 0.0;
    final systems = rows.map((row) => row.systemId).toSet();
    final mirrors = rows.map((row) => row.mirrorRoleId).toSet();
    final themes = rows.map((row) => row.sourceThemeId).toSet();
    final score = (systems.length / 4) * 0.4 +
        (mirrors.length / 3) * 0.3 +
        (themes.length / 6) * 0.3;
    return score.clamp(0.0, 1.0);
  }

  static HumanCoverage buildCoverage({
    required List<HumanPattern> patterns,
    required List<HumanDimension> dimensions,
  }) {
    final activated = dimensions.where((item) => item.activation > 0).toList();
    final activatedKeys = activated.map((item) => item.dimensionKey).toList()
      ..sort();

    final weighted = HumanDimensionCatalog.dimensions.isEmpty
        ? 0.0
        : activated.length / HumanDimensionCatalog.dimensions.length;

    return HumanCoverage(
      dimensionCount: HumanDimensionCatalog.dimensions.length,
      activatedDimensionCount: activated.length,
      patternCount: patterns.length,
      weightedCoverage: weighted.clamp(0.0, 1.0),
      activatedDimensionKeys: activatedKeys,
    );
  }

  static List<HumanDimension> buildDimensionActivations(
    List<HumanPattern> patterns,
  ) {
    final activations = <String, _DimensionAccumulator>{};

    for (final dimension in HumanDimensionCatalog.allDimensions()) {
      activations[dimension.key] = _DimensionAccumulator(dimension);
    }

    for (final pattern in patterns) {
      activations[pattern.primaryDimension.key]?.add(pattern);
      for (final secondary in pattern.secondaryDimensions) {
        activations[secondary.key]?.add(pattern, weight: 0.5);
      }
    }

    return activations.values
        .map((item) => item.toActivation())
        .toList()
      ..sort((a, b) => a.dimensionKey.compareTo(b.dimensionKey));
  }

  static HumanProfile buildProfile({
    required List<HumanPattern> patterns,
    required List<HumanDimension> dimensions,
  }) {
    final activeKeys = patterns.map((item) => item.patternKey).toSet().toList()
      ..sort();
    return HumanProfile(
      dimensions: List.unmodifiable(dimensions),
      patterns: List.unmodifiable(patterns),
      activePatternKeys: activeKeys,
    );
  }
}

class _DimensionAccumulator {
  _DimensionAccumulator(this.dimension);

  final HumanDimensionId dimension;
  final List<String> patternIds = [];
  var activationSum = 0.0;

  void add(HumanPattern pattern, {double weight = 1.0}) {
    patternIds.add(pattern.id);
    activationSum += pattern.patternStrength * weight;
  }

  HumanDimension toActivation() {
    final activation = patternIds.isEmpty
        ? 0.0
        : (activationSum / patternIds.length).clamp(0.0, 1.0);
    return HumanDimension(
      dimensionId: dimension,
      dimensionKey: dimension.key,
      activation: activation,
      patternIds: patternIds.toList()..sort(),
    );
  }
}

/// Internal evidence row shape for confidence diversity scoring.
class HumanEvidenceRow {
  const HumanEvidenceRow({
    required this.systemId,
    required this.mirrorRoleId,
    required this.sourceThemeId,
  });

  final String systemId;
  final String mirrorRoleId;
  final String sourceThemeId;
}
