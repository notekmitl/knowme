import 'dart:convert';
import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:knowme/features/thai_beta/application/thai_beta_analysis.dart';
import 'package:knowme/features/thai_beta/application/thai_beta_report_export_document.dart';
import 'package:knowme/features/thai_beta/application/thai_beta_report_pdf_exporter.dart';
import 'package:knowme/features/thai_beta/domain/thai_beta_input.dart';

String dependency(String variable, String suffix) {
  final configured = Platform.environment[variable];
  if (configured != null && File(configured).existsSync()) return configured;
  final bundled =
      '${Platform.environment['USERPROFILE']}/.cache/codex-runtimes/codex-primary-runtime/dependencies/$suffix';
  if (File(bundled).existsSync()) return bundled;
  throw StateError(
    'Set $variable to the required real-PDF dependency; this test cannot skip.',
  );
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  test(
    'title-only ordinary and timeline sections produce exactly one real semantic unit',
    () {
      for (final kind in [
        ThaiBetaReportExportSectionKind.body,
        ThaiBetaReportExportSectionKind.timeline,
      ]) {
        final section = ThaiBetaReportExportSection(
          id: 'independent-title',
          title: 'หัวข้อที่มีเพียงชื่อ',
          paragraphs: const [],
          kind: kind,
          traceIds: const ['trace-original'],
        );
        expect(ThaiBetaReportPdfExporter.debugPaginationUnitsForTest(section), [
          'หัวข้อที่มีเพียงชื่อ',
        ]);
        expect(section.paragraphs, isEmpty);
        expect(section.id, 'independent-title');
        expect(section.kind, kind);
        expect(section.traceIds, ['trace-original']);
      }
    },
  );
  test('empty title and empty paragraphs produce zero units', () {
    expect(
      ThaiBetaReportPdfExporter.debugPaginationUnitsForTest(
        const ThaiBetaReportExportSection(title: '', paragraphs: []),
      ),
      isEmpty,
    );
    expect(
      ThaiBetaReportPdfExporter.debugPaginationUnitsForTest(
        const ThaiBetaReportExportSection(title: '  ', paragraphs: []),
      ),
      isEmpty,
    );
  });
  test('ordinary sections with paragraphs preserve exact semantic units', () {
    expect(
      ThaiBetaReportPdfExporter.debugPaginationUnitsForTest(
        const ThaiBetaReportExportSection(
          title: 'หัวข้อเดิม',
          paragraphs: ['ย่อหน้าเดิม', 'การงาน', 'รายละเอียดงานเดิม'],
        ),
      ),
      ['หัวข้อเดิม\nย่อหน้าเดิม', 'การงาน\nรายละเอียดงานเดิม'],
    );
  });
  test(
    'actual 00:35 PDF streams retain every canonical field and reject missing painted title',
    () async {
      final input = ThaiBetaInput(
        firstName: 'Acceptance',
        lastName: 'Fixture',
        birthDate: DateTime(1982, 6, 6),
        birthHour: 0,
        birthMinute: 35,
        province: 'เชียงใหม่',
        provinceKey: 'chiang mai',
        gender: 'ชาย',
      );
      final asOf = DateTime(2026, 8, 29);
      final doc = ThaiBetaReportExportDocument.candidate(
        ThaiBetaAnalysisRunner.run(input, startedAt: asOf, asOf: asOf),
      );
      final baseline = jsonDecode(
        File(
          'test/evidence/fixtures/or5r_known_baseline.json',
        ).readAsStringSync(),
      )['35'];
      expect([
        for (final s in doc.sections)
          {
            'id': s.id,
            'title': s.title,
            'paragraphs': s.paragraphs,
            'traceIds': s.traceIds,
          },
      ], baseline['sections']);
      final output = Directory(
        Platform.environment['OR5R_PDF_TEST_OUTPUT'] ??
            'build/or5r-title-only-regression',
      )..createSync(recursive: true);
      final pdf = File('${output.path}/actual-known-0035.pdf');
      pdf.writeAsBytesSync(await ThaiBetaReportPdfExporter.buildBytes(doc));
      final inventory = File('${output.path}/expected-sections.json')
        ..writeAsStringSync(
          jsonEncode({
            'title': doc.title,
            'subtitle': doc.subtitle,
            'sections': [
              for (final s in doc.sections)
                {'id': s.id, 'title': s.title, 'paragraphs': s.paragraphs},
            ],
          }),
        );
      final python = dependency('KNOWME_PDF_PYTHON', 'python/python.exe');
      final poppler = dependency(
        'KNOWME_PDFTOPPM',
        'native/poppler/Library/bin/pdftoppm.exe',
      );
      for (final negative in [false, true]) {
        final result = await Process.run(python, [
          'tool/or5r_actual_pdf_gate.py',
          pdf.path,
          inventory.path,
          '${output.path}/${negative ? 'negative' : 'positive'}.json',
          '--required',
          'คำทำนายอดีต',
          '--pdftoppm',
          poppler,
          if (negative) '--negative-control',
        ]);
        expect(
          result.exitCode,
          0,
          reason:
              'Real PDF ${negative ? 'negative control' : 'parity'} failed: ${result.stdout}\n${result.stderr}',
        );
        final report = jsonDecode(
          File(
            '${output.path}/${negative ? 'negative' : 'positive'}.json',
          ).readAsStringSync(),
        );
        if (negative) {
          expect(report['negativeControlRejected'], isTrue);
          expect(report['requiredHeadingCount'], 0);
        } else {
          expect(report['requiredHeadingCount'], 1);
          expect(
            report['normalizedFullPdfEqualsCompleteExpectedInventory'],
            isTrue,
          );
          for (final key in [
            'missingHeadings',
            'extraHeadings',
            'duplicateHeadings',
            'sectionOrderMismatch',
            'paragraphMismatch',
          ]) {
            expect(report[key], 0, reason: key);
          }
        }
        expect(report['rasterExitCode'], 0);
        expect(report['rastersCreated'], report['pages']);
      }
    },
  );
}
