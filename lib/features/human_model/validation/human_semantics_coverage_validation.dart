import 'package:knowme/features/human_model/domain/human_model_snapshot.dart';
import 'package:knowme/features/human_pattern/domain/human_pattern_snapshot.dart';

/// HS5 — validates semantic expansion coverage using runtime pipeline (read-only).
class HumanSemanticsCoverageReport {
  const HumanSemanticsCoverageReport({
    required this.activationRate,
    required this.activatedPatternCount,
    required this.registryPatternCount,
    required this.meaningCoverageRate,
    required this.humanModelPatternCount,
    required this.fusionFindingCount,
    required this.passed,
    required this.issues,
  });

  final double activationRate;
  final int activatedPatternCount;
  final int registryPatternCount;
  final double meaningCoverageRate;
  final int humanModelPatternCount;
  final int fusionFindingCount;
  final bool passed;
  final List<String> issues;
}

abstract final class HumanSemanticsCoverageValidation {
  static HumanSemanticsCoverageReport validate({
    required HumanModelSnapshot humanModelSnapshot,
    required HumanPatternSnapshot humanPatternSnapshot,
    required double meaningCoverageRate,
    required int fusionFindingCount,
  }) {
    final issues = <String>[];
    final registryCount = humanPatternSnapshot.coverage.registryPatternCount;
    final activatedCount = humanPatternSnapshot.activations.length;
    final activationRate =
        registryCount == 0 ? 0.0 : activatedCount / registryCount;

    if (humanModelSnapshot.patterns.isEmpty && fusionFindingCount > 0) {
      issues.add('human model produced no patterns despite fusion findings');
    }
    if (activatedCount == 0 && fusionFindingCount > 0) {
      issues.add('no registry patterns activated from real semantic mapping');
    }
    if (activationRate <= 0 && fusionFindingCount > 0) {
      issues.add('activation rate must exceed 0% when fusion findings exist');
    }
    if (meaningCoverageRate < 1.0 && fusionFindingCount > 0) {
      issues.add(
        'meaning coverage incomplete: '
        '${(meaningCoverageRate * 100).toStringAsFixed(1)}%',
      );
    }

    return HumanSemanticsCoverageReport(
      activationRate: activationRate,
      activatedPatternCount: activatedCount,
      registryPatternCount: registryCount,
      meaningCoverageRate: meaningCoverageRate,
      humanModelPatternCount: humanModelSnapshot.patterns.length,
      fusionFindingCount: fusionFindingCount,
      passed: issues.isEmpty,
      issues: issues,
    );
  }
}
