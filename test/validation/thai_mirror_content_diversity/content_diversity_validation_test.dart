import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

import 'content_diversity_validation_runner.dart';

void main() {
  test('20 profiles meet content diversity targets', () {
    final report = ContentDiversityValidationRunner.validate();

    Directory('test/validation/thai_mirror_content_diversity/output')
        .createSync(recursive: true);
    File('test/validation/thai_mirror_content_diversity/output/results.json')
        .writeAsStringSync(const JsonEncoder.withIndent('  ').convert(report));

    expect(
      report['themeCoverage']['allThemesCovered'],
      isTrue,
      reason: 'Missing theme coverage: ${report['themeCoverage']['missing']}',
    );

    expect(
      report['genericStrengthViolations'],
      isEmpty,
      reason: 'Generic strength violations: ${report['genericStrengthViolations']}',
    );

    expect(
      report['maxDashboardLineRepeat'] as int,
      lessThanOrEqualTo(6),
      reason: 'Banned dashboard line repeated too often: ${report['bannedDashboardUsage']}',
    );

    final pairFlags = report['pairFlagsAbove30'] as List<dynamic>;
    expect(
      pairFlags,
      isEmpty,
      reason: 'Similarity pairs above 30% (${report['pairCountAbove30']}/${report['beforePairCountAbove30']} before): $pairFlags\n'
          'Top 10: ${report['top10SimilarPairs']}',
    );

    expect(report['passes'], isTrue);
  });
}
