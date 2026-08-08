import 'package:flutter_test/flutter_test.dart';
import 'package:knowme/features/astrology/thai/mirror/presentation/prediction/prediction_section_model.dart';
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
      expect(domain.body, startsWith('แนวโน้ม: สำหรับตอนนี้'));
      expect(domain.body, contains('\nผลต่อการตัดสินใจ:'));
      expect(domain.caution, contains('ความเสี่ยง:'));
      expect(domain.caution, contains('\nแนวทางเตรียมตัว:'));
      expect(domain.caution, isNot(contains('ไม่ใช่คำวินิจฉัยทางการแพทย์')));
      expect(domain.claim, startsWith('สำหรับตอนนี้'));
      expect(domain.preparationAction, startsWith('ตอนนี้'));
      expect(domain.preparationAction, isNot(contains('ระยะยาว')));
      expect(domain.materialFingerprint, isNotEmpty);
    }
    for (final domain in nextYear.domains) {
      expect(domain.body, startsWith('แนวโน้ม: ใน 12 เดือนข้างหน้า'));
      expect(domain.preparationAction, contains('12 เดือน'));
      expect(domain.preparationAction, contains('ทบทวน'));
    }
    for (final domain in nextPeriod.domains) {
      expect(domain.body, startsWith('แนวโน้ม: เมื่อเข้าสู่ช่วงชีวิตถัดไป'));
      expect(domain.preparationAction, startsWith('ก่อนเปลี่ยนช่วงชีวิต'));
      expect(domain.preparationAction, contains('ระยะยาว'));
      final matchingCurrent = current.domains.where(
        (candidate) => candidate.title == domain.title,
      );
      if (matchingCurrent.isNotEmpty) {
        expect(
          _meaningKey(domain.body),
          isNot(_meaningKey(matchingCurrent.single.body)),
        );
        expect(
          domain.preparationAction,
          isNot(matchingCurrent.single.preparationAction),
        );
      }
    }
  });

  test('future claims respond to known-time versus unknown-time evidence', () {
    ThaiBetaAnalysis run({required bool unknown, int? hour, int? minute}) {
      final input = unknown
          ? ThaiBetaInput(
              firstName: 'Fixture',
              lastName: 'Unknown',
              birthDate: DateTime(1982, 6, 6),
              birthTimeUnknown: true,
              province: 'เชียงใหม่',
              provinceKey: 'chiang_mai',
            )
          : ThaiBetaInput(
              firstName: 'Fixture',
              lastName: 'Known',
              birthDate: DateTime(1982, 6, 6),
              birthHour: hour!,
              birthMinute: minute!,
              province: 'เชียงใหม่',
              provinceKey: 'chiang_mai',
            );
      return ThaiBetaAnalysisRunner.run(input, startedAt: DateTime(2026, 8, 7));
    }

    List<PredictionDomainModel> predictiveBlocks(ThaiBetaAnalysis analysis) =>
        ThaiBetaNarrativeComposer.narrativeView(analysis)
            .futurePrediction!
            .windows
            .expand((window) => window.domains)
            .toList(growable: false);

    final fixtures = [
      (
        known: run(unknown: false, hour: 0, minute: 3),
        unknown: run(unknown: true),
      ),
      (
        known: run(unknown: false, hour: 0, minute: 35),
        unknown: run(unknown: true),
      ),
    ];
    for (final fixture in fixtures) {
      final known = predictiveBlocks(fixture.known);
      final unknown = predictiveBlocks(fixture.unknown);
      expect(known, hasLength(unknown.length));
      final violations = <String>[];
      for (var i = 0; i < known.length; i++) {
        violations.addAll(_crossModeViolations(known[i], unknown[i]));
      }
      expect(violations, isEmpty, reason: violations.join('\n'));
    }
  });

  test('cross-mode gate rejects a matrix that differs in only one block', () {
    const known = PredictionDomainModel(
      title: 'การงาน',
      body: '',
      caution: '',
      claim: 'งานเดินหน้า',
      risk: 'รับงานเกินเวลา',
      decisionImpact: 'ต้องเลือกงานหลัก',
      preparationAction: 'จำกัดงานเพิ่ม',
      materialFingerprint: 'h=current|d=career|b=strong|r=workload|e=supported',
    );
    const invalidUnknown = PredictionDomainModel(
      title: 'การงาน',
      body: '',
      caution: '',
      claim: 'งานช้าลง',
      risk: 'รับงานเกินเวลา',
      decisionImpact: 'ต้องเลือกงานหลัก',
      preparationAction: 'จำกัดงานเพิ่ม',
      materialFingerprint: 'h=current|d=career|b=quiet|r=conflict|e=supported',
    );
    final violations = _crossModeViolations(known, invalidUnknown);
    expect(violations, hasLength(greaterThanOrEqualTo(3)));
  });

  test('future opportunity taxonomy omits generic opportunity labels', () {
    final line =
        ThaiBetaNarrativeComposer.narrativeView(
          analysis,
        ).lifeTimeline?.futurePreview?.opportunitiesLine ??
        '';
    expect(line, isNot(contains(' · โอกาส')));
    expect(line, isNot(endsWith('โอกาส')));
    if (line.isNotEmpty) {
      expect(
        [
          'การงาน',
          'การเงิน',
          'ความรัก',
          'สุขภาพ',
          'การเติบโต',
        ].any(line.contains),
        isTrue,
      );
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

List<String> _crossModeViolations(
  PredictionDomainModel known,
  PredictionDomainModel unknown,
) {
  final violations = <String>[];
  final fields = <({String name, String left, String right, Set<String> keys})>[
    (
      name: 'claim',
      left: known.claim,
      right: unknown.claim,
      keys: {'h', 'd', 'b', 'e', 'p'},
    ),
    (
      name: 'risk',
      left: known.risk,
      right: unknown.risk,
      keys: {'h', 'd', 'r', 'e'},
    ),
    (
      name: 'decisionImpact',
      left: known.decisionImpact,
      right: unknown.decisionImpact,
      keys: {'h', 'd', 'b', 'r', 'e', 'p'},
    ),
    (
      name: 'action',
      left: known.preparationAction,
      right: unknown.preparationAction,
      keys: {'h', 'd', 'b', 'r', 'e', 'p'},
    ),
  ];
  for (final field in fields) {
    final leftFingerprint = _fingerprintProjection(
      known.materialFingerprint,
      field.keys,
    );
    final rightFingerprint = _fingerprintProjection(
      unknown.materialFingerprint,
      field.keys,
    );
    if (leftFingerprint == rightFingerprint) continue;
    final exact = field.left == field.right;
    final leftKey = _meaningKey(field.left);
    final rightKey = _meaningKey(field.right);
    final contained = leftKey.contains(rightKey) || rightKey.contains(leftKey);
    final similar = _semanticSimilarity(field.left, field.right) >= 0.72;
    if (exact || contained || similar) {
      violations.add(
        '${known.title}/${field.name}: different material fingerprints '
        'retained equal/contained/similar output '
        '[$leftFingerprint] vs [$rightFingerprint] '
        '"${field.left}" vs "${field.right}"',
      );
    }
  }
  return violations;
}

String _fingerprintProjection(String value, Set<String> keys) => value
    .split('|')
    .where((part) => keys.contains(part.split('=').first))
    .join('|');
