import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:knowme/features/astrology/thai/mirror/thai_mirror_stable_hash.dart';
import 'package:knowme/features/thai_beta/application/narrative/thai_beta_narrative_context.dart';
import 'package:knowme/features/thai_beta/application/thai_beta_analysis.dart';
import 'package:knowme/features/thai_beta/application/thai_beta_analysis_clock.dart';
import 'package:knowme/features/thai_beta/application/thai_beta_report_export_document.dart';
import 'package:knowme/features/thai_beta/application/thai_beta_report_pdf_exporter.dart';
import 'package:knowme/features/thai_beta/domain/thai_beta_input.dart';
import 'package:knowme/features/thai_beta/presentation/pages/thai_beta_input_page.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('V1.5 date-aware release contract', () {
    test('Bangkok civil conversion is deterministic across midnight', () {
      expect(
        ThaiBetaAnalysisClock.asBangkokCivil(
          DateTime.utc(2026, 8, 16, 16, 59, 59, 999),
        ),
        DateTime(2026, 8, 16, 23, 59, 59, 999),
      );
      expect(
        ThaiBetaAnalysisClock.asBangkokCivil(DateTime.utc(2026, 8, 16, 17)),
        DateTime(2026, 8, 17),
      );
    });

    test('analysis stores explicit asOf separately from session start', () {
      final startedAt = DateTime.utc(2026, 8, 16, 16, 59, 50);
      final asOf = DateTime(2026, 8, 17, 0, 0, 10);
      final analysis = ThaiBetaAnalysisRunner.run(
        _ownerKnown0035,
        startedAt: startedAt,
        asOf: asOf,
      );

      expect(analysis.isSuccess, isTrue);
      expect(analysis.startedAt, startedAt);
      expect(analysis.asOf, asOf);
      expect(
        ThaiBetaNarrativeContext.fromAnalysis(analysis).referenceDate,
        asOf,
      );
    });

    test('different session starts with one asOf produce identical report', () {
      final asOf = DateTime(2026, 8, 17, 0, 0, 10);
      final beforeMidnight = ThaiBetaAnalysisRunner.run(
        _ownerKnown0035,
        startedAt: DateTime.utc(2026, 8, 16, 16, 59, 50),
        asOf: asOf,
      );
      final afterMidnight = ThaiBetaAnalysisRunner.run(
        _ownerKnown0035,
        startedAt: DateTime.utc(2026, 8, 16, 17, 0, 5),
        asOf: asOf,
      );

      expect(beforeMidnight.reportHash, afterMidnight.reportHash);
      expect(
        ThaiBetaReportExportDocument.fromAnalysis(beforeMidnight).fullPlainText,
        ThaiBetaReportExportDocument.fromAnalysis(afterMidnight).fullPlainText,
      );
    });

    test('same session start changes only date-aware result at a boundary', () {
      final input = ThaiBetaInput(
        firstName: 'Boundary',
        lastName: 'Fixture',
        birthDate: DateTime(2000, 8, 17),
        birthTimeUnknown: true,
        province: 'กรุงเทพมหานคร',
        provinceKey: 'bangkok',
      );
      final startedAt = DateTime.utc(2026, 8, 16, 12);
      final beforeBirthday = ThaiBetaAnalysisRunner.run(
        input,
        startedAt: startedAt,
        asOf: DateTime(2026, 8, 16, 23, 59, 59),
      );
      final onBirthday = ThaiBetaAnalysisRunner.run(
        input,
        startedAt: startedAt,
        asOf: DateTime(2026, 8, 17),
      );

      expect(beforeBirthday.startedAt, onBirthday.startedAt);
      expect(
        beforeBirthday.normalizedSnapshot!.toMap(),
        onBirthday.normalizedSnapshot!.toMap(),
      );
      expect(beforeBirthday.profile!.lagnaKey, onBirthday.profile!.lagnaKey);
      expect(
        beforeBirthday.pipelineResult!.lifePeriods!.currentAge,
        onBirthday.pipelineResult!.lifePeriods!.currentAge - 1,
      );
      expect(
        ThaiBetaReportExportDocument.fromAnalysis(beforeBirthday).fullPlainText,
        isNot(
          ThaiBetaReportExportDocument.fromAnalysis(onBirthday).fullPlainText,
        ),
      );
    });

    test('Web and PDF export reuse one resolved asOf without rerun', () async {
      final asOf = DateTime(2026, 8, 16, 16, 19, 44, 454, 535);
      final analysis = ThaiBetaAnalysisRunner.run(
        _ownerKnown0035,
        startedAt: DateTime(2026, 8, 16, 16, 15),
        asOf: asOf,
      );
      final document = ThaiBetaReportExportDocument.fromAnalysis(analysis);
      final pdf = await ThaiBetaReportPdfExporter.build(document);

      expect(analysis.asOf, asOf);
      expect(pdf.plainText, document.fullPlainText);
      expect(
        ThaiBetaReportExportDocument.fromAnalysis(analysis).fullPlainText,
        document.fullPlainText,
      );
    });

    test('legacy-compatible stable hash preserves accepted VM identity', () {
      expect(ThaiMirrorStableHash.string('persistence'), 961841110);
      expect(ThaiMirrorStableHash.string('builder'), 504794108);
      expect(ThaiMirrorStableHash.string('lagna_aquarius'), 804501464);
    });

    testWidgets('form opened earlier uses the one submit instant as asOf', (
      tester,
    ) async {
      final openedAt = DateTime.utc(2026, 8, 16, 16, 59, 50);
      final submittedAt = DateTime.utc(2026, 8, 16, 17, 0, 10);
      final clockValues = <DateTime>[openedAt, submittedAt];
      DateTime? capturedStartedAt;
      DateTime? capturedAsOf;

      await tester.pumpWidget(
        MaterialApp(
          home: ThaiBetaInputPage(
            clock: () => clockValues.removeAt(0),
            analysisExecutor:
                (input, {required startedAt, required asOf}) async {
                  capturedStartedAt = startedAt;
                  capturedAsOf = asOf;
                  return ThaiBetaAnalysis.failedForTest(
                    input: input,
                    startedAt: startedAt,
                    asOf: asOf,
                  );
                },
          ),
        ),
      );

      await tester.enterText(find.byType(TextFormField).at(0), 'Clock');
      await tester.enterText(find.byType(TextFormField).at(1), 'Boundary');
      await tester.tap(find.text('เลือกวันเกิด'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('15').last);
      await tester.tap(find.text('OK'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('ฉันไม่ทราบเวลาเกิด'));
      await tester.pumpAndSettle();
      await tester.ensureVisible(find.text('เริ่มวิเคราะห์'));
      await tester.tap(find.text('เริ่มวิเคราะห์'));
      await tester.pumpAndSettle();

      expect(capturedStartedAt, openedAt);
      expect(capturedAsOf, DateTime(2026, 8, 17, 0, 0, 10));
      expect(clockValues, isEmpty);
    });
  });
}

final _ownerKnown0035 = ThaiBetaInput(
  firstName: 'Acceptance',
  lastName: 'Fixture',
  birthDate: DateTime(1982, 6, 6),
  birthHour: 0,
  birthMinute: 35,
  province: 'เชียงใหม่',
  provinceKey: 'chiang_mai',
);
