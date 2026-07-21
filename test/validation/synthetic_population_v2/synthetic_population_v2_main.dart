import 'dart:io';

import 'synthetic_population_v2_report.dart';
import 'synthetic_population_v2_runner.dart';

void main() {
  stdout.writeln('Synthetic Population V2 — running 1000-human validation...');
  final started = DateTime.now();
  final audit = SyntheticPopulationV2Runner.runAll();
  final elapsed = DateTime.now().difference(started);

  SyntheticPopulationV2Report.writeArtifacts(
    audit: audit,
    jsonPath: 'test/validation/synthetic_population_v2/output/results.json',
    markdownPath: 'docs/SYNTHETIC_POPULATION_V2_1000_REPORT.md',
  );

  stdout.writeln('Completed in ${elapsed.inSeconds}s');
  stdout.writeln('Report: docs/SYNTHETIC_POPULATION_V2_1000_REPORT.md');
  stdout.writeln(
    'Final decision: ${audit.decisionGate['finalDecision']}',
  );
}
