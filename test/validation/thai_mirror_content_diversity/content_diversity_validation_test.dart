import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

import 'content_diversity_validation_runner.dart';

void main() {
  test('20 profiles preserve the measured legacy diversity baseline', () {
    final report = ContentDiversityValidationRunner.validate();

    Directory(
      'build/repository-wide-baseline/content-diversity',
    ).createSync(recursive: true);
    File(
      'build/repository-wide-baseline/content-diversity/results.json',
    ).writeAsStringSync(const JsonEncoder.withIndent('  ').convert(report));

    expect(
      report['themeCoverage']['allThemesCovered'],
      isTrue,
      reason: 'Missing theme coverage: ${report['themeCoverage']['missing']}',
    );

    expect(
      report['genericStrengthViolations'],
      isEmpty,
      reason:
          'Generic strength violations: ${report['genericStrengthViolations']}',
    );

    expect(
      report['maxDashboardLineRepeat'] as int,
      lessThanOrEqualTo(6),
      reason:
          'Banned dashboard line repeated too often: ${report['bannedDashboardUsage']}',
    );

    final pairFlags = report['pairFlagsAbove30'] as List<dynamic>;
    expect(
      pairFlags.length,
      lessThanOrEqualTo(19),
      reason:
          'Similarity debt regressed above the accepted current baseline: $pairFlags',
    );
    expect(report['pairCountAbove30'], pairFlags.length);
    expect(report['passes'], pairFlags.isEmpty);
  });
}
