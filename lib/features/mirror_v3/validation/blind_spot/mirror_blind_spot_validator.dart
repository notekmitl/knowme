import '../../engine/knowme_mirror_engine.dart';
import '../constants/mirror_validation_constants.dart';
import '../fixtures/mirror_synthetic_bundle_factory.dart';
import '../models/mirror_blind_spot_validation_report.dart';

/// MV2.4 blind spot distribution validation.
abstract final class MirrorBlindSpotValidator {
  static MirrorBlindSpotValidationReport validate({
    required int caseCount,
  }) {
    final cases = MirrorSyntheticBundleFactory.buildCases(caseCount);

    var noBlindSpotCases = 0;
    var singleBlindSpotCases = 0;
    var multipleBlindSpotCases = 0;

    for (final input in cases) {
      final count = KnowMeMirrorEngine.reflect(input).blindSpots.length;
      if (count == 0) {
        noBlindSpotCases++;
      } else if (count == 1) {
        singleBlindSpotCases++;
      } else {
        multipleBlindSpotCases++;
      }
    }

    final total = cases.length;
    final distribution = [
      MirrorBlindSpotDistributionBucket(
        label: 'none',
        caseCount: noBlindSpotCases,
        rate: noBlindSpotCases / total,
      ),
      MirrorBlindSpotDistributionBucket(
        label: 'single',
        caseCount: singleBlindSpotCases,
        rate: singleBlindSpotCases / total,
      ),
      MirrorBlindSpotDistributionBucket(
        label: 'multiple',
        caseCount: multipleBlindSpotCases,
        rate: multipleBlindSpotCases / total,
      ),
    ];

    final anomalies = <String>[];

    final multipleRate = multipleBlindSpotCases / total;
    if (multipleRate > MirrorBlindSpotThresholds.maxBlindSpotExplosionRate) {
      anomalies.add(
        'blind spot explosion: multiple blind spots in '
        '${multipleRate.toStringAsFixed(3)} of cases',
      );
    }

    return MirrorBlindSpotValidationReport(
      totalCases: total,
      noBlindSpotCases: noBlindSpotCases,
      singleBlindSpotCases: singleBlindSpotCases,
      multipleBlindSpotCases: multipleBlindSpotCases,
      distribution: distribution,
      anomalies: anomalies,
      passed: anomalies.isEmpty,
    );
  }
}
