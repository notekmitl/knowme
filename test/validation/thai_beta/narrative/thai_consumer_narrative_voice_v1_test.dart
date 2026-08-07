import 'package:flutter_test/flutter_test.dart';
import 'package:knowme/features/thai_beta/application/core_reading/thai_birth_profile_core_reading.dart';
import 'package:knowme/features/thai_beta/application/narrative/thai_beta_narrative_composer.dart';
import 'package:knowme/features/thai_beta/application/thai_beta_analysis.dart';
import 'package:knowme/features/thai_beta/application/thai_beta_report_export_document.dart';
import 'package:knowme/features/thai_beta/domain/thai_beta_input.dart';

void main() {
  final analysis = ThaiBetaAnalysisRunner.run(
    ThaiBetaInput(
      firstName: 'Fixture',
      lastName: 'Voice',
      birthDate: DateTime(1982, 6, 6),
      birthHour: 0,
      birthMinute: 3,
      province: 'เชียงใหม่',
      provinceKey: 'chiang_mai',
    ),
    startedAt: DateTime(2026, 8, 7),
  );

  test('consumer copy removes report-like and repeated system phrases', () {
    final view = ThaiBetaNarrativeComposer.narrativeView(analysis);
    final core = ThaiBirthProfileCoreReading.fromAnalysis(
      analysis,
      consumerView: view,
    );
    final text = [
      ...core.sections.expand((section) => section.publicParagraphs),
      ...?view.lifeTimeline?.periods.expand(
        (period) => period.lifeDomains.map((domain) => domain.body),
      ),
      ...?view.futurePrediction?.windows.expand(
        (window) => [
          window.summary,
          window.confidenceLabel,
          window.evidenceDetail,
          ...window.domains.expand((domain) => [domain.body, domain.caution]),
        ],
      ),
    ].join('\n');

    for (final forbidden in [
      'สรุปตรง ๆ พื้นดวงนี้',
      'พื้นดวงให้น้ำหนักกับ',
      'จึงปรากฏเป็นแนวโน้มด้าน',
      'ความสัมพันธ์กับพื้นฐานวันเกิดของคุณ',
      'พอเห็นแนวโน้มได้ค่อนข้างชัด',
      'เมื่อดูจังหวะนี้ร่วมกัน',
      'ตัวฉุดสำคัญคือ',
      'ทางใช้จุดเด่นนี้ให้เกิดผลคือ',
    ]) {
      expect(text, isNot(contains(forbidden)), reason: forbidden);
    }
  });

  test('current and next-12-month domain paragraphs are not duplicates', () {
    final windows = ThaiBetaNarrativeComposer.narrativeView(
      analysis,
    ).futurePrediction!.windows;
    final current = windows[0];
    final nextYear = windows[1];
    for (var i = 0; i < current.domains.length; i++) {
      expect(
        _meaningKey(current.domains[i].body),
        isNot(_meaningKey(nextYear.domains[i].body)),
      );
      expect(current.domains[i].caution, isNot(nextYear.domains[i].caution));
    }
  });

  test('early-childhood and late-life periods avoid adult template claims', () {
    final periods = ThaiBetaNarrativeComposer.narrativeView(
      analysis,
    ).lifeTimeline!.periods;
    final early = periods.firstWhere((period) => period.ageLabel == '1–10');
    final late = periods
        .where((period) {
          final start = int.tryParse(period.ageLabel.split('–').first) ?? 0;
          return start >= 84;
        })
        .expand((period) => period.lifeDomains.map((domain) => domain.body));

    final earlyText = early.lifeDomains.map((domain) => domain.body).join('\n');
    expect(earlyText, isNot(contains('รายได้')));
    expect(earlyText, isNot(contains('รับภาระก้อนใหญ่')));
    final lateText = late.join('\n');
    expect(lateText, isNot(contains('บทบาทใหม่เข้ามา')));
    expect(lateText, isNot(contains('งานมีแนวโน้มขยายตัว')));
  });

  test('Web narrative and PDF use the same polished document content', () {
    final view = ThaiBetaNarrativeComposer.narrativeView(analysis);
    final core = ThaiBirthProfileCoreReading.fromAnalysis(
      analysis,
      consumerView: view,
    );
    final pdf = ThaiBetaReportExportDocument.fromAnalysis(analysis);
    for (final paragraph in core.sections.expand(
      (section) => section.publicParagraphs,
    )) {
      expect(pdf.fullPlainText, contains(paragraph));
    }
  });
}

String _meaningKey(String value) => value
    .replaceAll(RegExp(r'ช่วงนี้|ใน 12 เดือนข้างหน้า|ในราว 1 ปีข้างหน้า'), '')
    .replaceAll(RegExp(r'\s+'), '')
    .trim();
