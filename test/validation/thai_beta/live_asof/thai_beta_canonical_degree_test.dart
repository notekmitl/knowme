import 'package:flutter_test/flutter_test.dart';
import 'package:knowme/features/astrology/thai/foundation/astronomy/sidereal_ascendant.dart';
import 'package:knowme/features/thai_beta/application/thai_beta_analysis.dart';
import 'package:knowme/features/thai_beta/domain/thai_beta_canonical_degree.dart';
import 'package:knowme/features/thai_beta/domain/thai_beta_report_hash.dart';

import '../synthetic_audit/thai_beta_synthetic_matrix_300.dart';
import 'thai_beta_canonical_degree_vectors.dart';
import 'thai_beta_cross_runtime_manifest.dart';

void main() {
  test('fixed-point vectors are exact', () {
    for (final vector in canonicalDegreeVectors) {
      expect(
        ThaiBetaCanonicalDegree.fromDegrees(vector.input),
        vector.expected,
        reason: vector.label,
      );
    }
    expect(ThaiBetaCanonicalDegree.isJavaScriptSafe, isTrue);
    expect(
      ThaiBetaCanonicalDegree.unitsPerTurn,
      lessThan(ThaiBetaCanonicalDegree.maxJavaScriptSafeInteger),
    );
  });

  test('S008 and adjacent ULP material share one canonical value', () {
    final vm = ThaiBetaCanonicalDegree.fromDegrees(s008VmRawDegree);
    final chrome = ThaiBetaCanonicalDegree.fromDegrees(s008ChromeRawDegree);
    final lower = ThaiBetaCanonicalDegree.fromDegrees(102.39560244592321);
    final material = ThaiBetaCanonicalDegree.fromDegrees(102.395602447);
    expect(vm, 102395602446);
    expect(chrome, vm);
    expect(lower, vm);
    expect(material, isNot(vm));
    expect(ThaiBetaCanonicalDegree.fixedDecimal(vm!), '102.395602446');
  });

  test('finite normalization and invalid input contract are explicit', () {
    expect(ThaiBetaCanonicalDegree.fromDegrees(-1.25), 358750000000);
    expect(ThaiBetaCanonicalDegree.fromDegrees(360), 0);
    expect(ThaiBetaCanonicalDegree.fromDegrees(721.5), 1500000000);
    expect(
      () => ThaiBetaCanonicalDegree.fromDegrees(double.nan),
      throwsArgumentError,
    );
    expect(
      () => ThaiBetaCanonicalDegree.fromDegrees(double.infinity),
      throwsArgumentError,
    );
    expect(
      () => ThaiBetaCanonicalDegree.fromDegrees(double.negativeInfinity),
      throwsArgumentError,
    );
    expect(
      () => ThaiBetaCanonicalDegree.fromSnapshotValue(-1),
      throwsArgumentError,
    );
    expect(
      () => ThaiBetaCanonicalDegree.fromSnapshotValue(
        ThaiBetaCanonicalDegree.unitsPerTurn,
      ),
      throwsArgumentError,
    );
  });

  test('canonicalization does not participate in sign or house decisions', () {
    const below = 29.9999999996;
    const above = 30.0000000004;
    final belowSign = SiderealAscendant.wholeSignIndex(below);
    final aboveSign = SiderealAscendant.wholeSignIndex(above);
    expect(belowSign, 0);
    expect(aboveSign, 1);

    ThaiBetaCanonicalDegree.fromDegrees(below);
    ThaiBetaCanonicalDegree.fromDegrees(above);
    expect(SiderealAscendant.wholeSignIndex(below), belowSign);
    expect(SiderealAscendant.wholeSignIndex(above), aboveSign);
  });

  test(
    'S008 keeps raw engine value and hashes old/new snapshots identically',
    () {
      final syntheticCase = ThaiBetaSyntheticMatrix.build().singleWhere(
        (entry) => entry.id == 'S008',
      );
      final analysis = ThaiBetaAnalysisRunner.run(
        syntheticCase.input,
        startedAt: syntheticAsOf,
        asOf: syntheticAsOf,
      );
      expect(analysis.isSuccess, isTrue);
      expect(analysis.profile!.siderealAscendantDeg, s008VmRawDegree);

      final canonicalSnapshot = analysis.reportSnapshot!;
      final canonicalProfile = canonicalSnapshot['profile']! as Map;
      expect(canonicalProfile['siderealAscendantDeg'], 102395602446);

      final legacySnapshot = <String, dynamic>{
        ...canonicalSnapshot,
        'profile': <String, dynamic>{
          ...Map<String, dynamic>.from(canonicalProfile),
          'siderealAscendantDeg': s008VmRawDegree,
        },
      };
      expect(
        ThaiBetaReportHash.of(legacySnapshot),
        ThaiBetaReportHash.of(canonicalSnapshot),
      );
      expect(analysis.reportHash, ThaiBetaReportHash.of(canonicalSnapshot));
    },
  );
}
