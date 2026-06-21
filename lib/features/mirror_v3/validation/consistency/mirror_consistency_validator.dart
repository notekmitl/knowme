import '../../engine/knowme_mirror_engine.dart';
import '../../engine/models/knowme_mirror_engine_input.dart';
import '../constants/mirror_validation_constants.dart';
import '../fixtures/mirror_synthetic_bundle_factory.dart';
import '../models/mirror_consistency_validation_report.dart';
import '../support/mirror_engine_result_fingerprint.dart';

/// MV2.2 deterministic consistency validation.
abstract final class MirrorConsistencyValidator {
  static MirrorConsistencyValidationReport validate({
    int caseCount = 50,
    int runsPerCase = MirrorConsistencyRules.repeatRuns,
  }) {
    final cases = MirrorSyntheticBundleFactory.buildCases(caseCount);
    final mismatches = <String>[];

    for (var caseIndex = 0; caseIndex < cases.length; caseIndex++) {
      final input = cases[caseIndex];
      final baseline = _fingerprint(input);

      for (var run = 1; run < runsPerCase; run++) {
        final current = _fingerprint(input);
        if (!MirrorEngineResultFingerprint.equals(baseline, current)) {
          mismatches.add('case $caseIndex run $run diverged from baseline');
        }
      }
    }

    return MirrorConsistencyValidationReport(
      caseCount: cases.length,
      runsPerCase: runsPerCase,
      allDeterministic: mismatches.isEmpty,
      mismatches: mismatches,
      passed: mismatches.isEmpty,
    );
  }

  static Map<String, dynamic> _fingerprint(KnowMeMirrorEngineInput input) {
    return MirrorEngineResultFingerprint.fromResult(
      KnowMeMirrorEngine.reflect(input),
    );
  }
}
