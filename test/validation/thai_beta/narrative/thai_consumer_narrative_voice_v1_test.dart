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
      'หากความล้าสะสม ข้อความนี้ไม่ใช่คำวินิจฉัยทางการแพทย์เกิดซ้ำ',
      'เตรียมรับมือเรื่องความล้าสะสม ข้อความนี้ไม่ใช่คำวินิจฉัยทางการแพทย์',
      'กดดูรายละเอียด',
      'เนื้อหาจากรายงานที่มีอยู่แล้ว ไม่สร้างคำทำนายใหม่',
      'โดยไม่นำชื่อหมวดภายใน',
      'แรงกดดัน',
      'เรื่องงานหมายถึงการเลือกบทบาทและกิจกรรมที่ยังมีความหมาย',
      'เรื่องเงินเน้นการดูแลสิ่งที่มี',
      'ให้ความสำคัญกับการดูแลกัน การบอกความต้องการ',
      'เน้นการจัดกิจวัตรและการพักให้เหมาะกับแรงที่มี',
      'สรุปตรง ๆ พื้นดวงนี้',
      'พื้นดวงให้น้ำหนักกับ',
      'จึงปรากฏเป็นแนวโน้มด้าน',
      'ความสัมพันธ์กับพื้นฐานวันเกิดของคุณ',
      'พอเห็นแนวโน้มได้ค่อนข้างชัด',
      'เมื่อดูจังหวะนี้ร่วมกัน',
      'ตัวฉุดสำคัญคือ',
      'ทางใช้จุดเด่นนี้ให้เกิดผลคือ',
      'บริบทเฉพาะของช่วงนี้คือ',
      'ภาพของช่วงนี้คือต่อไปงานและหน้าที่บังคับ',
      'ลองการ',
      'สังเกตสัญญาณนี้จากสิ่งที่เกิดขึ้นในแต่ละวัน',
      'กำหนดจุดทบทวนไว้ล่วงหน้า ไม่รอให้ปัญหาสะสม',
      'ใช้เป็นเรื่องที่ควรเตรียมตัว ไม่ใช่ข้อสรุปล่วงหน้า',
      'เรื่องพลังชีวิตและการพักผ่อนเปลี่ยนชัดขึ้นและมีผลต่อชีวิตประจำวัน',
      'ร่างกายและใจถูกใช้จนสุดแรง',
      'คุณต้องแบกงานหลายเรื่องจนเวลาและพลังไม่พอ',
      'คุณเริ่มรู้ว่าต้องรักษาแรงไว้ ไม่ใช่ผลักทุกเรื่องพร้อมกัน',
      'แรงกดดันหลักในช่วงหน้าคือเรื่อง',
    ]) {
      expect(text, isNot(contains(forbidden)), reason: forbidden);
    }
    expect(
      RegExp('ข้อความนี้เป็นแนวโน้มตามศาสตร์ความเชื่อ').allMatches(text).length,
      1,
      reason: 'medical guidance belongs with the current-period context only',
    );
    expect(view.lifeTimeline?.futurePreview?.challengesLine, isEmpty);
  });

  test('life-period position wording agrees at every boundary', () {
    final cases = <({double progress, String expected, int remaining})>[
      (progress: 0, expected: 'ช่วงต้น', remaining: 20),
      (progress: 0.2, expected: 'ช่วงต้น', remaining: 16),
      (progress: 0.5, expected: 'ช่วงกลาง', remaining: 10),
      (progress: 0.8, expected: 'ช่วงปลาย', remaining: 4),
      (progress: 1, expected: 'ช่วงปลาย', remaining: 0),
    ];
    for (final c in cases) {
      final text = ThaiBetaNarrativeComposer.stageIntroForProgress(
        age: 44,
        phase: 'ช่วงทดสอบ',
        remaining: c.remaining,
        progress: c.progress,
      );
      expect(text, contains(c.expected));
      for (final other in ['ช่วงต้น', 'ช่วงกลาง', 'ช่วงปลาย']) {
        if (other != c.expected) expect(text, isNot(contains(other)));
      }
      if (c.remaining == 0) {
        expect(text, contains('จุดเปลี่ยน'));
        expect(text, isNot(contains('0 ปี')));
      } else {
        expect(text, contains('${c.remaining} ปี'));
      }
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

  test('forecast windows keep distinct semantic roles and isolated risk', () {
    final windows = ThaiBetaNarrativeComposer.narrativeView(
      analysis,
    ).futurePrediction!.windows;
    expect(windows, hasLength(greaterThanOrEqualTo(3)));
    final current = windows[0];
    final nextYear = windows[1];
    final nextPeriod = windows[2];

    for (final domain in current.domains) {
      expect(domain.body, startsWith('สำหรับตอนนี้'));
      expect(domain.caution, isNot(contains('ไม่ใช่คำวินิจฉัยทางการแพทย์')));
    }
    for (final domain in nextYear.domains) {
      expect(domain.body, startsWith('ในปีข้างหน้า'));
      expect(domain.caution, startsWith('ทบทวนเมื่อ'));
    }
    for (final domain in nextPeriod.domains) {
      expect(domain.body, startsWith('เมื่อเข้าสู่ช่วงชีวิตถัดไป'));
      expect(domain.caution, startsWith('เตรียม'));
      final matchingCurrent = current.domains.where(
        (candidate) => candidate.title == domain.title,
      );
      if (matchingCurrent.isNotEmpty) {
        expect(
          _meaningKey(domain.body),
          isNot(_meaningKey(matchingCurrent.single.body)),
        );
      }
    }
  });

  test('late-life domains fail closed without age-specific evidence', () {
    final periods = ThaiBetaNarrativeComposer.narrativeView(
      analysis,
    ).lifeTimeline!.periods;
    final latePeriods = periods
        .where((period) {
          final start = int.parse(period.ageLabel.split('–').first);
          return start >= 69;
        })
        .toList(growable: false);

    expect(latePeriods.map((period) => period.ageLabel), [
      '69–83',
      '84–91',
      '92–108',
    ]);
    for (final period in latePeriods) {
      expect(
        period.lifeDomains,
        isEmpty,
        reason: '${period.ageLabel} must omit generic synonym templates',
      );
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
    expect(lateText, isNot(contains('รายได้เพิ่มตามงาน')));
    expect(lateText, isNot(contains('บังคับให้คุณจัดลำดับชีวิตใหม่')));
  });

  test('all eight periods use age-aware consumer language', () {
    final periods = ThaiBetaNarrativeComposer.narrativeView(
      analysis,
    ).lifeTimeline!.periods;
    expect(periods, hasLength(8));
    for (final period in periods) {
      final start = int.parse(period.ageLabel.split('–').first);
      final text = period.lifeDomains.map((domain) => domain.body).join('\n');
      expect(text, isNot(contains('บริบทเฉพาะของช่วงนี้คือ')));
      if (start < 30) {
        expect(text, isNot(contains('งานประจำ')));
      }
      if (start >= 69) {
        expect(text, isNot(contains('รายได้เพิ่ม')));
        expect(text, isNot(contains('งานมีแนวโน้มขยายตัว')));
      }
    }
  });

  test('within each early-life period every domain has distinct meaning', () {
    final periods = ThaiBetaNarrativeComposer.narrativeView(analysis)
        .lifeTimeline!
        .periods
        .where((period) {
          final end = int.parse(period.ageLabel.split('–').last);
          return end <= 21;
        });
    for (final period in periods) {
      final bodies = period.lifeDomains.map((domain) => domain.body).toList();
      for (var i = 0; i < bodies.length; i++) {
        for (var j = i + 1; j < bodies.length; j++) {
          expect(
            _semanticSimilarity(bodies[i], bodies[j]),
            lessThan(0.72),
            reason: '${period.ageLabel}: ${bodies[i]} / ${bodies[j]}',
          );
        }
      }
      expect(bodies.join('\n'), isNot(contains('หมดไฟ')));
      expect(bodies.join('\n'), isNot(contains('แบกงาน')));
    }
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

double _semanticSimilarity(String left, String right) {
  Set<String> grams(String value) {
    final key = _meaningKey(value);
    if (key.length < 3) return {key};
    return {for (var i = 0; i <= key.length - 3; i++) key.substring(i, i + 3)};
  }

  final a = grams(left);
  final b = grams(right);
  return a.intersection(b).length / a.union(b).length;
}
