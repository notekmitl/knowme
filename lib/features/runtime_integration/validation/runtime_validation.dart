import 'package:knowme/features/human_model/lineage/human_lineage_trace.dart';
import 'package:knowme/features/human_pattern/lineage/pattern_lineage_trace.dart';

import '../pipeline/knowme_runtime_pipeline.dart';

class RuntimeValidationReport {
  const RuntimeValidationReport({
    required this.passed,
    required this.pipelineIntegrityPassed,
    required this.patternActivationPassed,
    required this.issues,
    required this.snapshotsCreated,
    required this.lineageContinuous,
    required this.confidencePropagated,
    required this.patternsActivated,
  });

  final bool passed;
  final bool pipelineIntegrityPassed;
  final bool patternActivationPassed;
  final List<String> issues;
  final bool snapshotsCreated;
  final bool lineageContinuous;
  final bool confidencePropagated;
  final bool patternsActivated;
}

/// RT3 — validates runtime pipeline integrity.
abstract final class RuntimeValidation {
  static RuntimeValidationReport validate(KnowMeRuntimePipelineResult result) {
    final issues = <String>[];

    final snapshotsCreated = _validateSnapshots(result, issues);
    final lineageContinuous = _validateLineage(result, issues);
    final confidencePropagated = _validateConfidence(result, issues);
    final patternsActivated = _validatePatternActivation(result, issues);

    final pipelineIntegrityPassed = snapshotsCreated &&
        lineageContinuous &&
        confidencePropagated;

    final patternActivationPassed = patternsActivated;

    return RuntimeValidationReport(
      passed: pipelineIntegrityPassed && patternActivationPassed,
      pipelineIntegrityPassed: pipelineIntegrityPassed,
      patternActivationPassed: patternActivationPassed,
      issues: issues,
      snapshotsCreated: snapshotsCreated,
      lineageContinuous: lineageContinuous,
      confidencePropagated: confidencePropagated,
      patternsActivated: patternsActivated,
    );
  }

  static bool _validateSnapshots(
    KnowMeRuntimePipelineResult result,
    List<String> issues,
  ) {
    var ok = true;

    if (result.astrologyMirrorSnapshot.snapshotId.isEmpty) {
      ok = false;
      issues.add('astrology mirror snapshot not created');
    }
    if (result.personalityMirrorSnapshot.snapshotId.isEmpty) {
      ok = false;
      issues.add('personality mirror snapshot not created');
    }
    if (result.globalFusionSnapshot.snapshotId.isEmpty) {
      ok = false;
      issues.add('global fusion snapshot not created');
    }
    if (result.humanModelSnapshot.snapshotId.isEmpty) {
      ok = false;
      issues.add('human model snapshot not created');
    }
    if (result.humanPatternSnapshot.snapshotId.isEmpty) {
      ok = false;
      issues.add('human pattern snapshot not created');
    }

    return ok;
  }

  static bool _validateLineage(
    KnowMeRuntimePipelineResult result,
    List<String> issues,
  ) {
    final humanOk =
        HumanLineageTrace.hasCompleteLineage(result.humanModelSnapshot);
    final patternOk =
        PatternLineageTrace.hasCompleteLineage(result.humanPatternSnapshot);

    if (!humanOk) {
      issues.add('human model lineage incomplete');
    }
    if (!patternOk && result.humanPatternSnapshot.activations.isNotEmpty) {
      issues.add('human pattern lineage incomplete');
    }

    if (result.globalFusionSnapshot.lineage.sourceMirrorSnapshotIds.length < 2) {
      issues.add('fusion lineage missing mirror snapshot ids');
      return false;
    }

    return humanOk && (patternOk || result.humanPatternSnapshot.activations.isEmpty);
  }

  static bool _validateConfidence(
    KnowMeRuntimePipelineResult result,
    List<String> issues,
  ) {
    final fusion = result.globalFusionSnapshot.confidence.composite;
    final human = result.humanModelSnapshot.confidence.composite;
    final pattern = result.humanPatternSnapshot.confidence.composite;

    if (fusion <= 0) {
      issues.add('fusion confidence not propagated');
      return false;
    }
    if (human <= 0) {
      issues.add('human confidence not propagated');
      return false;
    }
    if (result.humanPatternSnapshot.activations.isNotEmpty && pattern <= 0) {
      issues.add('pattern confidence not propagated');
      return false;
    }

    return true;
  }

  static bool _validatePatternActivation(
    KnowMeRuntimePipelineResult result,
    List<String> issues,
  ) {
    if (result.globalFusionSnapshot.agreements.isEmpty) {
      issues.add(
        'ARCH_FUSION_NO_CROSS_MIRROR_AGREEMENTS: '
        'real astrology mirror has no agreements to fuse with personality',
      );
    }
    if (result.humanPatternSnapshot.activations.isEmpty) {
      issues.add('no human patterns activated from real runtime data');
      return false;
    }
    return true;
  }
}
