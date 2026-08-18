import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:knowme/features/thai_beta/application/thai_beta_analysis.dart';
import 'package:knowme/features/thai_beta/application/thai_beta_report_export_document.dart';
import 'package:knowme/features/thai_beta/application/thai_beta_report_pdf_exporter.dart';
import 'package:knowme/features/thai_beta/domain/thai_beta_input.dart';

import 'thai_beta_canonical_text_contract.dart';

const _acceptedRoot = 'product-acceptance/thai-narrative-v1.5-r7.1/evidence';
final _frozenAsOf = DateTime(2026, 8, 7);
final _liveAsOf = DateTime(2026, 8, 16, 16, 19, 44, 454, 535);

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('frozen and live-date oracle parity are exact 5/5', () async {
    final outputPath = Platform.environment['KNOWME_LIVE_ORACLE_OUTPUT'];
    final output = outputPath == null ? null : Directory(outputPath);
    output?.createSync(recursive: true);
    final summary = <Map<String, Object?>>[];

    for (final entry in _fixtures.entries) {
      final frozen = ThaiBetaAnalysisRunner.run(
        entry.value,
        startedAt: _frozenAsOf,
        asOf: _frozenAsOf,
      );
      final frozenDocument = ThaiBetaReportExportDocument.fromAnalysis(frozen);
      final frozenPdf = await ThaiBetaReportPdfExporter.build(frozenDocument);
      expectCanonicalFixtureText(
        pipelineText: frozenDocument.fullPlainText,
        fixturePath: '$_acceptedRoot/${entry.key}-web-text.txt',
        reason: '${entry.key} frozen Web',
      );
      expectCanonicalFixtureText(
        pipelineText: frozenPdf.plainText,
        fixturePath: '$_acceptedRoot/${entry.key}-pdf-text.txt',
        reason: '${entry.key} frozen PDF',
      );

      final liveFirst = ThaiBetaAnalysisRunner.run(
        entry.value,
        startedAt: DateTime(2026, 8, 16, 16, 15),
        asOf: _liveAsOf,
      );
      final liveSecond = ThaiBetaAnalysisRunner.run(
        entry.value,
        startedAt: DateTime(2026, 8, 16, 15),
        asOf: _liveAsOf,
      );
      final liveDocument = ThaiBetaReportExportDocument.fromAnalysis(liveFirst);
      final livePdf = await ThaiBetaReportPdfExporter.build(liveDocument);
      final repeatedDocument = ThaiBetaReportExportDocument.fromAnalysis(
        liveSecond,
      );

      expect(liveFirst.reportHash, liveSecond.reportHash);
      expect(liveDocument.fullPlainText, repeatedDocument.fullPlainText);
      expect(liveDocument.fullPlainText, livePdf.plainText);
      expect(liveFirst.asOf, _liveAsOf);
      expect(liveSecond.asOf, _liveAsOf);

      if (output != null) {
        File(
          '${output.path}/${entry.key}-report.pdf',
        ).writeAsBytesSync(livePdf.bytes, flush: true);
        File(
          '${output.path}/${entry.key}-web-text.txt',
        ).writeAsStringSync(liveDocument.fullPlainText, flush: true);
        File(
          '${output.path}/${entry.key}-pdf-text.txt',
        ).writeAsStringSync(livePdf.plainText, flush: true);
      }

      summary.add({
        'fixture': entry.key,
        'frozenAsOf': _frozenAsOf.toIso8601String(),
        'liveAsOf': _liveAsOf.toIso8601String(),
        'frozenExactWeb': true,
        'frozenExactPdf': true,
        'liveWebPdfExact': true,
        'liveRepeatExact': true,
        'reportHash': liveFirst.reportHash,
        'pageCount': livePdf.pageCount,
      });
    }

    final owner = ThaiBetaAnalysisRunner.run(
      _fixtures['owner-known-0035']!,
      startedAt: _liveAsOf,
      asOf: _liveAsOf,
    );
    final regression = ThaiBetaAnalysisRunner.run(
      _fixtures['regression-known-0003']!,
      startedAt: _liveAsOf,
      asOf: _liveAsOf,
    );
    expect(_lagnaDegree(owner), '19°19′');
    expect(_lagnaDegree(regression), '9°24′');
    expect(
      ThaiBetaReportExportDocument.fromAnalysis(
        ThaiBetaAnalysisRunner.run(
          _fixtures['owner-unknown']!,
          startedAt: _liveAsOf,
          asOf: _liveAsOf,
        ),
      ).fullPlainText,
      contains('ไม่ทราบเวลาเกิด'),
    );

    if (output != null) {
      File('${output.path}/live-oracle-summary.json').writeAsStringSync(
        '${const JsonEncoder.withIndent('  ').convert({'fixtures': summary})}\n',
        flush: true,
      );
    }
  });
}

String _lagnaDegree(ThaiBetaAnalysis analysis) {
  final withinSign = analysis.profile!.siderealAscendantDeg! % 30;
  final minutes = (withinSign * 60).round();
  return '${minutes ~/ 60}°${(minutes % 60).toString().padLeft(2, '0')}′';
}

final _fixtures = <String, ThaiBetaInput>{
  'owner-known-0035': _owner(known: true, minute: 35),
  'owner-unknown': _owner(known: false),
  'regression-known-0003': _owner(known: true, minute: 3),
  'comparison-known-bangkok': ThaiBetaInput(
    firstName: 'Comparison',
    lastName: 'Fixture',
    birthDate: DateTime(1991, 11, 18),
    birthHour: 14,
    birthMinute: 20,
    province: 'กรุงเทพมหานคร',
    provinceKey: 'bangkok',
  ),
  'comparison-known-khon-kaen': ThaiBetaInput(
    firstName: 'Comparison',
    lastName: 'Fixture',
    birthDate: DateTime(1974, 2, 27),
    birthHour: 6,
    birthMinute: 45,
    province: 'ขอนแก่น',
    provinceKey: 'khon_kaen',
  ),
};

ThaiBetaInput _owner({required bool known, int minute = 0}) => ThaiBetaInput(
  firstName: 'Acceptance',
  lastName: 'Fixture',
  birthDate: DateTime(1982, 6, 6),
  birthHour: known ? 0 : null,
  birthMinute: known ? minute : 0,
  birthTimeUnknown: !known,
  province: 'เชียงใหม่',
  provinceKey: 'chiang_mai',
);
