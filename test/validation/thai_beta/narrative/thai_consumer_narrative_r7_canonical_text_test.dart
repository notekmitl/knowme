import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:knowme/features/thai_beta/application/thai_beta_analysis.dart';
import 'package:knowme/features/thai_beta/application/thai_beta_report_export_document.dart';
import 'package:knowme/features/thai_beta/domain/thai_beta_input.dart';

void main() {
  final outputPath = Platform.environment['KNOWME_R7_CANONICAL_OUTPUT'];

  test('writes deterministic R7 canonical Web text without creating PDFs', () {
    if (outputPath == null || outputPath.isEmpty) return;
    final output = Directory(outputPath)..createSync(recursive: true);
    final fixtures = <String, ThaiBetaAnalysis>{
      'owner-known-0035': _owner(known: true, minute: 35),
      'owner-unknown': _owner(known: false),
      'regression-known-0003': _owner(known: true, minute: 3),
      'comparison-known-bangkok': _run(
        ThaiBetaInput(
          firstName: 'Comparison',
          lastName: 'Fixture',
          birthDate: DateTime(1991, 11, 18),
          birthHour: 14,
          birthMinute: 20,
          province: 'กรุงเทพมหานคร',
          provinceKey: 'bangkok',
        ),
      ),
      'comparison-known-khon-kaen': _run(
        ThaiBetaInput(
          firstName: 'Comparison',
          lastName: 'Fixture',
          birthDate: DateTime(1974, 2, 27),
          birthHour: 6,
          birthMinute: 45,
          province: 'ขอนแก่น',
          provinceKey: 'khon_kaen',
        ),
      ),
    };
    for (final entry in fixtures.entries) {
      final first = ThaiBetaReportExportDocument.fromAnalysis(
        entry.value,
      ).fullPlainText;
      final second = ThaiBetaReportExportDocument.fromAnalysis(
        entry.value,
      ).fullPlainText;
      expect(second, first, reason: entry.key);
      File(
        '${output.path}/${entry.key}-web-text.txt',
      ).writeAsStringSync(first, flush: true);
    }
  });
}

ThaiBetaAnalysis _owner({required bool known, int minute = 0}) => _run(
  ThaiBetaInput(
    firstName: 'Acceptance',
    lastName: 'Fixture',
    birthDate: DateTime(1982, 6, 6),
    birthHour: known ? 0 : null,
    birthMinute: known ? minute : 0,
    birthTimeUnknown: !known,
    province: 'เชียงใหม่',
    provinceKey: 'chiang_mai',
  ),
);

ThaiBetaAnalysis _run(ThaiBetaInput input) =>
    ThaiBetaAnalysisRunner.run(input, startedAt: DateTime(2026, 8, 7));
