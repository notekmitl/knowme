import 'package:knowme/features/human_pattern/domain/human_pattern_snapshot.dart';

/// HPC5 — activation density validation against coverage targets.
class ActivationDensityReport {
  const ActivationDensityReport({
    required this.activationRate,
    required this.activatedPatternCount,
    required this.registryPatternCount,
    required this.target30Reached,
    required this.target50Reached,
    required this.passed,
    required this.issues,
  });

  final double activationRate;
  final int activatedPatternCount;
  final int registryPatternCount;
  final bool target30Reached;
  final bool target50Reached;
  final bool passed;
  final List<String> issues;
}

abstract final class ActivationDensityValidation {
  static const target30 = 0.30;
  static const target50 = 0.50;

  static ActivationDensityReport validate(HumanPatternSnapshot snapshot) {
    final registryCount = snapshot.coverage.registryPatternCount;
    final activatedCount = snapshot.activations.length;
    final rate = registryCount == 0 ? 0.0 : activatedCount / registryCount;
    final issues = <String>[];

    if (activatedCount == 0) {
      issues.add('no registry patterns activated');
    }

    final target30Reached = rate >= target30;
    final target50Reached = rate >= target50;

    if (!target30Reached) {
      issues.add(
        'activation rate ${(rate * 100).toStringAsFixed(1)}% below 30% target',
      );
    }
    if (!target50Reached) {
      issues.add(
        'activation rate ${(rate * 100).toStringAsFixed(1)}% below 50% target',
      );
    }

    return ActivationDensityReport(
      activationRate: rate,
      activatedPatternCount: activatedCount,
      registryPatternCount: registryCount,
      target30Reached: target30Reached,
      target50Reached: target50Reached,
      passed: activatedCount > 0,
      issues: issues,
    );
  }
}
