import '../../engine/knowme_mirror_engine.dart';
import '../fixtures/mirror_synthetic_bundle_factory.dart';
import '../models/mirror_confidence_validation_report.dart';

/// MV2.3 confidence monotonicity validation.
abstract final class MirrorConfidenceValidator {
  static MirrorConfidenceValidationReport validate({int caseCount = 30}) {
    final cases = <MirrorConfidenceCaseResult>[];

    for (var seed = 0; seed < caseCount; seed++) {
      final oneLens = KnowMeMirrorEngine.reflect(
        MirrorSyntheticBundleFactory.confidenceCaseOneLens(seed),
      );
      final twoLens = KnowMeMirrorEngine.reflect(
        MirrorSyntheticBundleFactory.confidenceCaseTwoLens(seed),
      );
      final threeLens = KnowMeMirrorEngine.reflect(
        MirrorSyntheticBundleFactory.confidenceCaseThreeLens(seed),
      );

      final one = oneLens.compositeConfidence;
      final two = twoLens.compositeConfidence;
      final three = threeLens.compositeConfidence;

      final issues = <String>[];

      if (two < one - 0.0001) {
        issues.add('two-lens confidence lower than one-lens: $two < $one');
      }
      if (three < two - 0.0001) {
        issues.add('three-lens confidence lower than two-lens: $three < $two');
      }

      final monotonic = issues.isEmpty;
      cases.add(
        MirrorConfidenceCaseResult(
          seed: seed,
          oneLensConfidence: one,
          twoLensConfidence: two,
          threeLensConfidence: three,
          monotonic: monotonic,
          issues: issues,
        ),
      );
    }

    final monotonicCases = cases.where((item) => item.monotonic).length;
    final violations = cases.length - monotonicCases;

    return MirrorConfidenceValidationReport(
      caseCount: cases.length,
      monotonicCases: monotonicCases,
      violations: violations,
      cases: cases,
      passed: violations == 0,
    );
  }
}
