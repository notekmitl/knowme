import 'package:flutter_test/flutter_test.dart';
import 'package:knowme/features/thai_beta/application/narrative/thai_beta_clause_repetition_audit.dart';
import 'package:knowme/features/thai_beta/application/thai_beta_analysis.dart';
import 'package:knowme/features/thai_beta/application/thai_beta_report_export_document.dart';
import 'package:knowme/features/thai_beta/domain/thai_beta_input.dart';
import 'or5r_unknown_contract.dart';

void main() {
  test(
    'OR5R absent phase is not a repeated empty substring; safety still runs',
    () {
      List<String> audit(String text, {String phase = ''}) =>
          ThaiBetaReaderQualityAudit.validate(
            units: [
              ThaiBetaNarrativeAuditUnit(
                unitId: 'omission',
                section: 'limits',
                domain: '',
                text: text,
              ),
            ],
            motif: '',
            phase: phase,
          );
      expect(audit(or5rOmission), isEmpty);
      expect(
        audit('ช่วงหนึ่ง ช่วงหนึ่ง ช่วงหนึ่ง ช่วงหนึ่ง', phase: 'ช่วงหนึ่ง'),
        contains('PHASE_FREQUENCY:4>3:ช่วงหนึ่ง'),
      );
      expect(audit('$or5rOmission\u0001'), contains('ENCODING_C0:U+0001'));
      expect(
        audit('ขอบเขตตรวจของช่วงเก็บเกี่ยวความสุขคือ'),
        contains('R6_NEGATIVE:ขอบเขตตรวจของช่วงเก็บเกี่ยวความสุขคือ'),
      );
    },
  );
  final input = ThaiBetaInput(
    firstName: 'Civil',
    lastName: 'Only',
    birthDate: DateTime(1990, 6, 15),
    birthTimeUnknown: true,
    province: 'กรุงเทพมหานคร',
    provinceKey: 'bangkok',
  );
  final a = ThaiBetaAnalysisRunner.run(
    input,
    startedAt: DateTime(2026, 8, 29),
    asOf: DateTime(2026, 8, 29),
  );
  test('OR5R explicit disclosure is valid, not a computed lagna assertion', () {
    expectUnknownContract(a);
  });
  test(
    'OR5R exact oracle rejects claims appended to disclosure and metadata loss',
    () {
      final doc = ThaiBetaReportExportDocument.candidate(a);
      final first = doc.sections.first;
      for (final mutation in [
        [...first.paragraphs, 'ลัคนา: ราศีกุมภ์ 19°19′'],
        [...first.paragraphs, 'วันทางโหราศาสตร์: วันเสาร์'],
        [...first.paragraphs, 'เวลาเกิด 12:00'],
        [...first.paragraphs, 'การงานช่วงนี้กำลังเติบโต'],
        [...first.paragraphs, or5rOmission],
        first.paragraphs.sublist(1),
      ]) {
        final invalid = ThaiBetaReportExportDocument(
          title: doc.title,
          subtitle: doc.subtitle,
          filenameStem: doc.filenameStem,
          sections: [
            ThaiBetaReportExportSection(
              title: first.title,
              paragraphs: mutation,
              id: first.id,
              kind: first.kind,
              fieldSource: first.fieldSource,
              knownUnknownRule: first.knownUnknownRule,
              traceIds: first.traceIds,
            ),
            ...doc.sections.skip(1),
          ],
        );
        expect(
          () => expectUnknownDocument(input, invalid),
          throwsA(isA<TestFailure>()),
        );
      }
      final badKind = ThaiBetaReportExportDocument(
        title: doc.title,
        subtitle: doc.subtitle,
        filenameStem: doc.filenameStem,
        sections: [
          ThaiBetaReportExportSection(
            title: first.title,
            paragraphs: first.paragraphs,
            id: first.id,
            fieldSource: first.fieldSource,
            knownUnknownRule: first.knownUnknownRule,
            traceIds: first.traceIds,
          ),
          ...doc.sections.skip(1),
        ],
      );
      expect(
        () => expectUnknownDocument(input, badKind),
        throwsA(isA<TestFailure>()),
      );
    },
  );
}
