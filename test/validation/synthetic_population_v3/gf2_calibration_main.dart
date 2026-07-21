import 'dart:convert';
import 'dart:io';

import 'gf2_calibration_runner.dart';

void main() {
  stdout.writeln('GF2 Pre-Implementation Calibration — running...');
  final started = DateTime.now();
  final audit = Gf2CalibrationRunner.runAll();
  final elapsed = DateTime.now().difference(started);

  const calibrationJson =
      'test/validation/synthetic_population_v3/output/calibration_results.json';
  const lifeReportJson =
      'test/validation/synthetic_population_v3/output/life_direction_coverage_report.json';

  final payload = {
    'version': 'gf2_pre_implementation_calibration_v3',
    'generatedAt': DateTime.now().toUtc().toIso8601String(),
    'populationQuality': audit.populationQuality,
    'lifeDirectionCoverage': audit.lifeDirectionCoverage,
    'deadZoneRevalidation': audit.deadZoneRevalidation,
    'v2Simulation': audit.v2Simulation,
    'patternRecovery': audit.patternRecovery,
    'vg006Calibration': audit.vg006Calibration,
    'validationGates': audit.validationGates,
    'finalDecision': audit.finalDecision,
  };

  File(calibrationJson)
    ..parent.createSync(recursive: true)
    ..writeAsStringSync(const JsonEncoder.withIndent('  ').convert(payload));

  File(lifeReportJson)
    ..parent.createSync(recursive: true)
    ..writeAsStringSync(
      const JsonEncoder.withIndent('  ').convert(audit.lifeDirectionCoverage),
    );

  stdout.writeln('Completed in ${elapsed.inSeconds}s');
  stdout.writeln('Life Direction Coverage: $lifeReportJson');
  stdout.writeln('Calibration results: $calibrationJson');
  stdout.writeln('Final recommendation: ${audit.finalDecision['recommendation']}');
}
