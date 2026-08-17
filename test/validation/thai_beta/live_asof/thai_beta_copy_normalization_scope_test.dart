import 'package:flutter_test/flutter_test.dart';
import 'package:knowme/features/thai_beta/application/thai_beta_analysis.dart';

import '../synthetic_audit/thai_beta_synthetic_matrix_300.dart';
import 'thai_beta_cross_runtime_manifest.dart';

void main() {
  test(
    'opportunity normalization scope is fixed and fully enumerated',
    () {
      final impactedCases = <String>{};
      final impacts = <Map<String, Object?>>[];
      for (final syntheticCase in ThaiBetaSyntheticMatrix.build()) {
        final analysis = ThaiBetaAnalysisRunner.run(
          syntheticCase.input,
          startedAt: syntheticAsOf,
          asOf: syntheticAsOf,
        );
        final caseImpact = crossRuntimeCopyNormalizationImpact(analysis);
        if (caseImpact.isNotEmpty) impactedCases.add(syntheticCase.id);
        impacts.addAll(caseImpact);
      }

      expect(impactedCases, hasLength(93));
      expect(impacts, hasLength(112));
      expect(impacts.map((impact) => impact['field']).toSet(), {'summary'});
      expect(
        impacts.every(
          (impact) => (impact['before']! as String).contains(
            'ต่อไปมีโอกาสใหม่เข้ามาจากงานหรือคนรู้จัก',
          ),
        ),
        isTrue,
      );
    },
    timeout: const Timeout(Duration(minutes: 10)),
  );

  test('Owner Unknown normalization is copy-only and remains cautious', () {
    final input = canonicalFixtures['owner-unknown']!;
    final analysis = ThaiBetaAnalysisRunner.run(
      input,
      startedAt: frozenCanonicalAsOf,
      asOf: frozenCanonicalAsOf,
    );
    final impact = crossRuntimeCopyNormalizationImpact(analysis);

    expect(impact, isNotEmpty);
    expect(impact.every((row) => row['field'] == 'summary'), isTrue);
    expect(
      impact.every(
        (row) => (row['after']! as String).contains(
          'ดูจากผลที่เกิดขึ้นจริงว่าอะไรควรทำต่อ',
        ),
      ),
      isTrue,
    );
  });
}
