import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:knowme/features/thai_beta/application/thai_beta_report_export_document.dart';

import 'thai_beta_narrative_fixtures.dart';

/// Writes sample exports to build/ (local QA artifact — not committed).
void main() {
  test('write fixture A/B sample exports', () {
    final outDir = Directory('build/thai_beta_narrative_samples');
    outDir.createSync(recursive: true);

    for (final entry in [
      ('fixture_a_with_time', ThaiBetaNarrativeFixtures.fixtureA),
      ('fixture_b_no_time', ThaiBetaNarrativeFixtures.fixtureB),
    ]) {
      final doc = ThaiBetaReportExportDocument.fromAnalysis(entry.$2());
      File('${outDir.path}/${entry.$1}.txt').writeAsStringSync(doc.fullPlainText);
    }
    expect(outDir.existsSync(), isTrue);
  });
}
