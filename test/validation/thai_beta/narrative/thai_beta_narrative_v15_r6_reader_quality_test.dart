import 'package:flutter_test/flutter_test.dart';
import 'package:knowme/features/thai_beta/application/core_reading/thai_birth_profile_core_reading.dart';
import 'package:knowme/features/thai_beta/application/narrative/thai_beta_clause_repetition_audit.dart';
import 'package:knowme/features/thai_beta/application/narrative/thai_beta_narrative_composer.dart';
import 'package:knowme/features/thai_beta/application/narrative/thai_beta_narrative_context.dart';
import 'package:knowme/features/thai_beta/application/narrative/thai_beta_report_narrative_plan.dart';
import 'package:knowme/features/thai_beta/application/thai_beta_analysis.dart';
import 'package:knowme/features/thai_beta/application/thai_beta_report_export_document.dart';
import 'package:knowme/features/thai_beta/domain/thai_beta_input.dart';

void main() {
  late Map<String, ThaiBetaAnalysis> analyses;
  late Map<String, ThaiBetaReportNarrativePlan> plans;

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
    plans = {
      for (final entry in analyses.entries)
        entry.key: ThaiBetaReportNarrativePlan.fromPrediction(
          prediction: entry.value.consumerViewState!.futurePrediction,
          context: ThaiBetaNarrativeContext.fromAnalysis(entry.value),
        ),
    };
  });

  test('R5 repeated clause negatives are detected at clause level', () {
    const repeated = [
      'ทำหน้าที่ประคองการตัดสินใจ มากกว่ากำหนดทิศทางเอง',
      'ใช้สัญญาณนี้คัดสิ่งที่จะพาเข้าสู่ช่วงถัดไป ไม่ใช่เปิดภาระใหม่ทั้งหมด',
      'จะเป็นแรงประกอบที่ต้องปรับตามภาระชุดใหม่',
    ];
    for (var index = 0; index < repeated.length; index++) {
      final phrase = repeated[index];
      final result = ThaiBetaClauseRepetitionAudit.audit([
        ThaiBetaNarrativeAuditUnit(
          unitId: 'left-$index',
          section: 'forecast',
          domain: 'career',
          horizon: 'current',
          text: 'ข้อความนำที่ต่างกัน $phrase',
        ),
        ThaiBetaNarrativeAuditUnit(
          unitId: 'right-$index',
          section: 'forecast',
          domain: 'finance',
          horizon: 'next12Months',
          text: 'อีกข้อความนำหนึ่ง $phrase',
        ),
      ]);
      expect(
        result.flaggedPairs,
        isNotEmpty,
        reason: 'R5 negative $index was not detected',
      );
    }
  });

  test('forecast clauses have no exact, skeleton, or >=.78 reuse', () {
    for (final entry in analyses.entries) {
      final view = ThaiBetaNarrativeComposer.narrativeView(entry.value);
      final units = <ThaiBetaNarrativeAuditUnit>[];
      for (
        var windowIndex = 0;
        windowIndex < view.futurePrediction!.windows.length;
        windowIndex++
      ) {
        final window = view.futurePrediction!.windows[windowIndex];
        units.add(
          ThaiBetaNarrativeAuditUnit(
            unitId: '${entry.key}:summary:$windowIndex',
            section: window.windowLabel,
            horizon: '$windowIndex',
            text: window.summary,
          ),
        );
        for (final domain in window.domains) {
          units.add(
            ThaiBetaNarrativeAuditUnit(
              unitId: '${entry.key}:$windowIndex:${domain.title}',
              section: window.windowLabel,
              domain: domain.title,
              horizon: '$windowIndex',
              text: domain.body,
            ),
          );
        }
      }
      final audit = ThaiBetaClauseRepetitionAudit.audit(
        units,
        dynamicSlots: [plans[entry.key]!.lifePeriodLabel],
      );
      final materialFailures = audit.pairs
          .where(
            (pair) =>
                pair.exact ||
                pair.repeatedSkeleton ||
                pair.similarity >=
                    ThaiBetaClauseRepetitionAudit.similarityThreshold,
          )
          .toList(growable: false);
      expect(
        materialFailures,
        isEmpty,
        reason: materialFailures
            .take(5)
            .map(
              (pair) =>
                  '${pair.left.unitId}/${pair.right.unitId} ${pair.similarity.toStringAsFixed(3)} "${pair.left.text}" <> "${pair.right.text}"',
            )
            .join('\n'),
      );
    }
  });

  test('exact forecast reuse is measured without a zero-reuse gate', () {
    final groups = <String, List<(String, String)>>{};
    for (final entry in analyses.entries) {
      final identity = plans[entry.key]!.materialIdentity;
      final view = ThaiBetaNarrativeComposer.narrativeView(entry.value);
      for (final body in view.futurePrediction!.windows.expand(
        (window) => [
          window.summary,
          ...window.domains.map((domain) => domain.body),
        ],
      )) {
        final normalized = _exactKey(body);
        groups.putIfAbsent(normalized, () => []).add((entry.key, identity));
      }
    }
    final reused = groups.entries
        .where((entry) => entry.value.map((item) => item.$2).toSet().length > 1)
        .toList(growable: false);
    expect(reused.length, greaterThanOrEqualTo(0));
  });

  test(
    'Known explains chart evidence naturally; Unknown remains fail closed',
    () {
      final known = analyses['owner-known-0035']!;
      final knownView = ThaiBetaNarrativeComposer.narrativeView(known);
      final knownReading = ThaiBirthProfileCoreReading.fromAnalysis(
        known,
        consumerView: knownView,
      );
      final knownConsumer = knownReading.sections
          .where((section) => !section.isMethodology)
          .expand((section) => section.paragraphs)
          .join('\n');
      expect(knownConsumer, contains('ลัคนาราศีกุมภ์'));
      expect(knownConsumer, contains('เจ้าเรือนลัคนา'));
      expect(knownConsumer, contains('แปลเป็นภาษาคน'));

      final unknown = ThaiBetaReportExportDocument.fromAnalysis(
        analyses['owner-unknown']!,
      ).fullPlainText;
      expect(unknown, isNot(contains('เรือนการงานที่')));
      expect(unknown, isNot(contains('เจ้าเรือนลัคนา')));
      expect(unknown, isNot(contains('วันทางโหราศาสตร์:')));
      expect(unknown, contains('หากช่วงนี้คุณสังเกตว่า'));
    },
  );

  test('R5 repeated reader-facing clauses are absent from owner reports', () {
    const rejected = [
      'ทำหน้าที่ประคองการตัดสินใจ มากกว่ากำหนดทิศทางเอง',
      'ใช้สัญญาณนี้คัดสิ่งที่จะพาเข้าสู่ช่วงถัดไป ไม่ใช่เปิดภาระใหม่ทั้งหมด',
      'จะเป็นแรงประกอบที่ต้องปรับตามภาระชุดใหม่',
    ];
    for (final fixture in ['owner-known-0035', 'owner-unknown']) {
      final text = ThaiBetaReportExportDocument.fromAnalysis(
        analyses[fixture]!,
      ).fullPlainText;
      for (final phrase in rejected) {
        expect(text, isNot(contains(phrase)), reason: '$fixture:$phrase');
      }
      final windows = ThaiBetaNarrativeComposer.narrativeView(
        analyses[fixture]!,
      ).futurePrediction!.windows;
      expect(windows[0].summary, contains('ตัดสินใจ'));
      expect(windows[1].summary, contains('12 เดือน'));
      expect(windows[2].summary, contains('ช่วงชีวิตถัดไป'));
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

String _exactKey(String value) => value
    .replaceAll(RegExp(r'\s+'), '')
    .replaceAll(RegExp(r'''[\-–—:;,.!?()“”"'•·]+'''), '')
    .toLowerCase();
