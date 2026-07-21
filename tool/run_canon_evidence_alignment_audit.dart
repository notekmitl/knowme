// ignore_for_file: avoid_print

import 'package:flutter_test/flutter_test.dart';
import 'package:knowme/features/astrology/thai/knowledge/canon/integration/integration.dart';
import 'package:knowme/features/astrology/thai/knowledge/canon/integration/qa/thai_canon_evidence_alignment_classification.dart';
import 'package:knowme/features/astrology/thai/knowledge/canon/integration/qa/thai_canon_evidence_alignment_report.dart';
import 'package:knowme/features/astrology/thai/knowledge/canon/integration/qa/thai_canon_evidence_alignment_runner.dart';

Future<void> main() async {
  TestWidgetsFlutterBinding.ensureInitialized();
  final audit = await ThaiCanonEvidenceAlignmentRunner.run();
  print(ThaiCanonEvidenceAlignmentReport.toMarkdown(audit));
  print('---JSON---');
  print(ThaiCanonEvidenceAlignmentReport.toJson(audit));
  for (final e in audit.classificationCounts.entries) {
    if (e.value > 0) print('CLASS:${e.key.wire}=${e.value}');
  }
}
