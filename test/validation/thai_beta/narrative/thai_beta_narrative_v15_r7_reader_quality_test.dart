import 'package:flutter_test/flutter_test.dart';
import 'package:knowme/features/thai_beta/application/narrative/thai_beta_clause_repetition_audit.dart';
import 'package:knowme/features/thai_beta/application/narrative/thai_beta_narrative_composer.dart';
import 'package:knowme/features/thai_beta/application/narrative/thai_beta_narrative_context.dart';
import 'package:knowme/features/thai_beta/application/narrative/thai_beta_report_narrative_plan.dart';
import 'package:knowme/features/thai_beta/application/thai_beta_analysis.dart';
import 'package:knowme/features/thai_beta/application/thai_beta_report_export_document.dart';
import 'package:knowme/features/thai_beta/domain/thai_beta_input.dart';

void main() {
  late Map<String, ThaiBetaAnalysis> analyses;

  setUpAll(() {
    analyses = {
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
  });

  test('all R6 negative fixtures are detected', () {
    for (final phrase in ThaiBetaReaderQualityAudit.rejectedR6Phrases) {
      final failures = ThaiBetaReaderQualityAudit.validate(
        units: [
          ThaiBetaNarrativeAuditUnit(
            unitId: 'negative',
            section: 'fixture',
            text: phrase,
          ),
        ],
        motif: 'motif-not-present',
        phase: 'phase-not-present',
      );
      expect(
        failures.any((failure) => failure == 'R6_NEGATIVE:$phrase'),
        isTrue,
        reason: phrase,
      );
    }
  });

  test('grammar, domain, and encoding gates reject synthetic defects', () {
    final failures = ThaiBetaReaderQualityAudit.validate(
      units: const [
        ThaiBetaNarrativeAuditUnit(
          unitId: 'agent',
          section: 'forecast',
          text:
              'ความสามารถในการทำความคิดให้คนอื่นเข้าใจอ่านรอยต่อนี้ว่า งานจะเปลี่ยน',
        ),
        ThaiBetaNarrativeAuditUnit(
          unitId: 'if',
          section: 'forecast',
          text: 'หากรอบงานภายใต้แนวคิดเดิมอำนาจตัดสินใจไม่เพิ่มตาม',
        ),
        ThaiBetaNarrativeAuditUnit(
          unitId: 'adjacent',
          section: 'forecast',
          text: 'นัดทบทวนเมื่อการทบทวนข้อตกลงหลังเห็นพฤติกรรมซ้ำ',
        ),
        ThaiBetaNarrativeAuditUnit(
          unitId: 'leak',
          section: 'forecast',
          domain: 'health',
          text: 'รอบส่งมอบงานเป็นตัวกำหนดเวลานอน',
        ),
        ThaiBetaNarrativeAuditUnit(
          unitId: 'encoding',
          section: 'packet',
          text: 'ข้อความเสีย à¸ และ �\u0001',
        ),
      ],
      motif: 'motif-not-present',
      phase: 'phase-not-present',
    );
    expect(
      failures.any((value) => value.startsWith('ABSTRACT_NOUN_AGENT:')),
      isTrue,
    );
    expect(
      failures.any((value) => value.startsWith('MISSING_IF_CONJUNCTION:')),
      isTrue,
    );
    expect(
      failures.any((value) => value.startsWith('REPEATED_ADJACENT:')),
      isTrue,
    );
    expect(
      failures.any((value) => value.startsWith('DOMAIN_LEAKAGE:')),
      isTrue,
    );
    expect(
      failures.any((value) => value.startsWith('ENCODING_MOJIBAKE:')),
      isTrue,
    );
    expect(failures.any((value) => value.startsWith('ENCODING_C0:')), isTrue);
  });

  test('R7 reports pass literal, prose, domain, and encoding gates', () {
    for (final fixture in analyses.keys) {
      final analysis = analyses[fixture]!;
      final view = ThaiBetaNarrativeComposer.narrativeView(analysis);
      final plan = ThaiBetaReportNarrativePlan.fromPrediction(
        prediction: analysis.consumerViewState!.futurePrediction,
        context: ThaiBetaNarrativeContext.fromAnalysis(analysis),
      );
      final document = ThaiBetaReportExportDocument.fromAnalysis(analysis);
      final domainByBody = <String, String>{
        for (final window in view.futurePrediction!.windows)
          for (final domain in window.domains)
            domain.body: domain.material!.domain.name,
      };
      final prose = document.fullPlainText
          .split('\n')
          .map((line) => line.trim())
          .where((line) => line.isNotEmpty)
          .where((line) => !line.startsWith('${plan.lifePeriodLabel} · อายุ'))
          .toList(growable: false);
      final units = [
        for (var index = 0; index < prose.length; index++)
          ThaiBetaNarrativeAuditUnit(
            unitId: '$fixture:$index',
            section: 'consumer-report',
            domain: domainByBody[prose[index]] ?? '',
            text: prose[index],
          ),
      ];
      final failures = ThaiBetaReaderQualityAudit.validate(
        units: units,
        motif: ThaiBetaReportNarrativePlan.strengthLabel(plan.themeId),
        phase: plan.lifePeriodLabel,
      );
      expect(failures, isEmpty, reason: '$fixture\n${failures.join('\n')}');
    }
  });

  test('factual anchors stay fixed and Unknown remains fail closed', () {
    final known = ThaiBetaReportExportDocument.fromAnalysis(
      analyses['owner-known-0035']!,
    ).fullPlainText;
    final regression = ThaiBetaReportExportDocument.fromAnalysis(
      analyses['regression-known-0003']!,
    ).fullPlainText;
    final unknown = ThaiBetaReportExportDocument.fromAnalysis(
      analyses['owner-unknown']!,
    ).fullPlainText;
    expect(known, contains('ราศีกุมภ์ 19°19′'));
    expect(regression, contains('ราศีกุมภ์ 9°24′'));
    expect(unknown, isNot(contains('ลัคนา')));
    expect(unknown, isNot(contains('เรือน')));
    expect(unknown, isNot(contains('วันทางโหราศาสตร์')));
    expect(unknown, contains('ไม่มีเวลาเกิด'));
  });

  test('exact reuse is accepted only for the same material signature', () {
    final signaturesByText = <String, Set<String>>{};
    for (final analysis in analyses.values) {
      final prediction = ThaiBetaNarrativeComposer.narrativeView(
        analysis,
      ).futurePrediction!;
      for (final domain in prediction.windows.expand(
        (window) => window.domains,
      )) {
        signaturesByText
            .putIfAbsent(_exactKey(domain.body), () => <String>{})
            .add(domain.material!.serialize());
      }
    }
    final conflicting = signaturesByText.entries.where(
      (entry) => entry.value.length > 1,
    );
    expect(
      conflicting,
      isEmpty,
      reason: conflicting
          .map((entry) => '${entry.key}: ${entry.value.join(' / ')}')
          .join('\n'),
    );
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

ThaiBetaAnalysis _run(ThaiBetaInput input) => ThaiBetaAnalysisRunner.run(
  input,
  startedAt: DateTime(2026, 8, 7),
  asOf: DateTime(2026, 8, 7),
);

String _exactKey(String value) => value
    .replaceAll(RegExp(r'\s+'), '')
    .replaceAll(RegExp(r'''[\-–—:;,.!?()“”"'•·]+'''), '')
    .toLowerCase();
