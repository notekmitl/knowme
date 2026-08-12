import 'package:flutter_test/flutter_test.dart';
import 'package:knowme/features/astrology/thai/core/life_period/life_planet.dart';
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
      expect(
        current.domains[i].preparationAction,
        isNot(nextYear.domains[i].preparationAction),
      );
      expect(current.domains[i].caution, isEmpty);
      expect(nextYear.domains[i].caution, isEmpty);
    }
  });

  test('v1.1 deterministic repetition audit rejects template-shaped prose', () {
    final windows = ThaiBetaNarrativeComposer.narrativeView(
      analysis,
    ).futurePrediction!.windows;
    final domains = windows.expand((window) => window.domains).toList();
    final actions = domains
        .map((domain) => _meaningKey(domain.preparationAction))
        .toList();
    expect(actions.toSet(), hasLength(actions.length));

    const forbiddenLabels = [
      'ภาพที่เห็น:',
      'สิ่งที่ควรระวัง:',
      'เรื่องนี้มีผลกับคุณอย่างไร:',
      'สิ่งที่ทำได้ตอนนี้:',
    ];
    final sentences = <String>[];
    for (final domain in domains) {
      for (final label in forbiddenLabels) {
        expect(domain.body, isNot(contains(label)));
        expect(domain.caution, isNot(contains(label)));
      }
      sentences.addAll(
        domain.body
            .split(RegExp(r'[\n.!?]'))
            .map(_meaningKey)
            .where((sentence) => sentence.length >= 24),
      );
    }
    final duplicates = <String>{};
    final seen = <String>{};
    for (final sentence in sentences) {
      if (!seen.add(sentence)) duplicates.add(sentence);
    }
    expect(duplicates, isEmpty, reason: duplicates.join('\n'));

    for (
      var domainIndex = 0;
      domainIndex < windows.first.domains.length;
      domainIndex++
    ) {
      final bodies = [
        for (final window in windows) window.domains[domainIndex].body,
      ];
      final withoutHorizonLead = bodies
          .map(
            (body) => _meaningKey(
              body
                  .replaceFirst('ตลอดปีข้างหน้า', '')
                  .replaceFirst('เมื่อเข้าใกล้ช่วงชีวิตถัดไป', ''),
            ),
          )
          .toSet();
      expect(
        withoutHorizonLead,
        hasLength(bodies.length),
        reason: 'horizon prose must change by job, not by prefix alone',
      );
    }
  });

  test('v1.2 gate catches V1.1 clause reuse and enforces content budgets', () {
    const rejectedV11 =
        'รับบทบาทเพิ่มได้ โดยไม่แลกกับคุณภาพงานหลัก. '
        'เลือกงานหนึ่งเรื่อง โดยไม่แลกกับคุณภาพงานหลัก';
    expect(_duplicateClauses(rejectedV11), isNotEmpty);

    final unknownAnalysis = ThaiBetaAnalysisRunner.run(
      ThaiBetaInput(
        firstName: 'Fixture',
        lastName: 'Unknown',
        birthDate: DateTime(1982, 6, 6),
        province: 'เชียงใหม่',
        provinceKey: 'chiang_mai',
      ),
      startedAt: DateTime(2026, 8, 7),
    );
    for (final candidate in [analysis, unknownAnalysis]) {
      final windows = ThaiBetaNarrativeComposer.narrativeView(
        candidate,
      ).futurePrediction!.windows;
      final skeletons = <String>{};
      for (var windowIndex = 0; windowIndex < windows.length; windowIndex++) {
        for (final domain in windows[windowIndex].domains) {
          final paragraphs = domain.body
              .split('\n')
              .where((part) => part.trim().isNotEmpty)
              .toList();
          expect(
            paragraphs.length,
            lessThanOrEqualTo(windowIndex == 0 ? 2 : 1),
          );
          expect(_duplicateClauses(domain.body), isEmpty);
          for (final repeatedFamily in const [
            'ระหว่างนั้นให้สังเกตว่า',
            'โดยมีรอยต่อของช่วงชีวิตอยู่ในกรอบนี้',
            'กันเวลา เงิน หรือแรงไว้รับรอยต่อ',
            'ถ้าผลจริงไม่เป็นไปตามแผน',
          ]) {
            expect(domain.body, isNot(contains(repeatedFamily)));
          }
          expect(
            skeletons.add(_sentenceSkeleton(domain.body)),
            isTrue,
            reason: 'sentence skeleton reused: ${domain.body}',
          );
        }
      }
    }
  });

  test(
    'cross-horizon gate removes time boilerplate and compares each field',
    () {
      final windows = ThaiBetaNarrativeComposer.narrativeView(
        analysis,
      ).futurePrediction!.windows;
      final current = {
        for (final domain in windows[0].domains) domain.title: domain,
      };
      final nextYear = {
        for (final domain in windows[1].domains) domain.title: domain,
      };
      for (final entry in current.entries) {
        final next = nextYear[entry.key]!;
        for (final field in [ForecastField.claim, ForecastField.action]) {
          expect(
            _semanticCoreKey(_fieldText(entry.value, field)),
            isNot(_semanticCoreKey(_fieldText(next, field))),
            reason:
                '${entry.key}/${field.name} differs only by horizon wording',
          );
        }
        if (_semanticCoreKey(entry.value.risk) == _semanticCoreKey(next.risk)) {
          expect(
            entry.value.decisionPlan!.consumerRiskDomain,
            next.decisionPlan!.consumerRiskDomain,
            reason: '${entry.key}/risk shared output needs typed evidence',
          );
        }
      }
      expect(
        _semanticCoreKey('สำหรับตอนนี้ งานหลักต้องคงคุณภาพ'),
        _semanticCoreKey('ใน 12 เดือนข้างหน้า งานหลักต้องคงคุณภาพ'),
        reason: 'changing only a time lead must not evade the gate',
      );
    },
  );

  test('forecast windows keep distinct semantic roles and isolated risk', () {
    final windows = ThaiBetaNarrativeComposer.narrativeView(
      analysis,
    ).futurePrediction!.windows;
    expect(windows, hasLength(greaterThanOrEqualTo(3)));
    final current = windows[0];
    final nextYear = windows[1];
    final nextPeriod = windows[2];

    for (final domain in current.domains) {
      expect(domain.body, isNot(contains('ภาพที่เห็น:')));
      expect(domain.body, isNot(contains('เรื่องนี้มีผลกับคุณอย่างไร:')));
      expect(domain.body, contains('\n'));
      expect(domain.caution, isEmpty);
      expect(domain.caution, isNot(contains('ไม่ใช่คำวินิจฉัยทางการแพทย์')));
      expect(domain.claim, isNot(startsWith('สำหรับตอนนี้')));
      expect(domain.preparationAction, isNot(contains('ระยะยาว')));
      expect(domain.materialFingerprint, isNotEmpty);
    }
    for (final domain in nextYear.domains) {
      expect(domain.body, contains('ปีข้างหน้า'));
      expect(domain.preparationAction, isNotEmpty);
    }
    for (final domain in nextPeriod.domains) {
      expect(domain.body, startsWith('ช่วงชีวิตถัดไป'));
      expect(domain.preparationAction, isNotEmpty);
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

  test('V1.2 repeated past claims are allocated to one period only', () {
    final periods = ThaiBetaNarrativeComposer.narrativeView(
      analysis,
    ).lifeTimeline!.periods.where((period) => period.isPast);
    final corpus = periods
        .expand(
          (period) => [
            period.summary,
            period.whatChanges,
            period.easier,
            period.harder,
            period.comparison,
            period.evidenceLine,
            period.advice,
          ],
        )
        .where((value) => value.trim().isNotEmpty)
        .toList();
    for (final rejectedV12Claim in const [
      'คุณอยากใกล้ชิด แต่ก็ยังต้องการพื้นที่ส่วนตัว',
      'คุณเริ่มเลือกโอกาสที่สำคัญจริง ๆ แทนการรับทุกอย่าง',
    ]) {
      expect(
        corpus.where((value) => value.contains(rejectedV12Claim)),
        hasLength(1),
        reason: 'a personal past claim belongs to one period only',
      );
    }
  });

  test('future claims respond to known-time versus unknown-time evidence', () {
    ThaiBetaAnalysis run({
      required DateTime birthDate,
      required bool unknown,
      int? hour,
      int? minute,
    }) {
      final input = unknown
          ? ThaiBetaInput(
              firstName: 'Fixture',
              lastName: 'Unknown',
              birthDate: birthDate,
              birthTimeUnknown: true,
              province: 'เชียงใหม่',
              provinceKey: 'chiang_mai',
            )
          : ThaiBetaInput(
              firstName: 'Fixture',
              lastName: 'Known',
              birthDate: birthDate,
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

    final civilProfiles = [
      (birthDate: DateTime(1982, 6, 6), hour: 0, minute: 3),
      (birthDate: DateTime(1982, 6, 6), hour: 0, minute: 35),
      (birthDate: DateTime(1960, 1, 19), hour: 9, minute: 12),
      (birthDate: DateTime(1994, 11, 27), hour: 18, minute: 42),
      (birthDate: DateTime(2001, 3, 14), hour: 6, minute: 18),
    ];
    final fixtures = civilProfiles.indexed
        .map(
          (entry) => (
            profileCaseId: 'civil-case-${entry.$1 + 1}',
            known: run(
              birthDate: entry.$2.birthDate,
              unknown: false,
              hour: entry.$2.hour,
              minute: entry.$2.minute,
            ),
            unknown: run(birthDate: entry.$2.birthDate, unknown: true),
          ),
        )
        .toList();
    final known = fixtures
        .expand((fixture) => predictiveBlocks(fixture.known))
        .toList();
    final unknown = fixtures
        .expand((fixture) => predictiveBlocks(fixture.unknown))
        .toList();
    final report = _matrixReport(
      known,
      unknown,
      knownProfileCaseIds: fixtures
          .expand(
            (fixture) => List.filled(
              predictiveBlocks(fixture.known).length,
              fixture.profileCaseId,
            ),
          )
          .toList(),
      unknownProfileCaseIds: fixtures
          .expand(
            (fixture) => List.filled(
              predictiveBlocks(fixture.unknown).length,
              fixture.profileCaseId,
            ),
          )
          .toList(),
      productionGenerationSensitivity: _productionGenerationSensitivity(
        known.first,
      ),
      negativeGateDetectionCoverage: _negativeGateDetectionCoverage(
        known.first,
      ),
    );
    expect(report.totalComparedCells, 240);
    expect(report.differentFingerprintCells, greaterThan(0));
    expect(report.equalFingerprintCells, greaterThan(0));
    expect(report.violations, isEmpty, reason: report.violations.join('\n'));
    expect(report.isAcceptable, isTrue, reason: report.failures.join('\n'));
    expect(
      report.observedValueCoverage['band'],
      containsAll(ForecastBand.values),
    );
    expect(
      report.observedValueCoverage['risk']!.whereType<LifeDomain>().length,
      greaterThan(1),
    );
    expect(
      report.observedValueCoverage['availability'],
      containsAll(ForecastEvidenceAvailability.values),
    );
    expect(
      report.observedValueCoverage['transition'],
      containsAll({true, false}),
    );
    expect(
      report.actualDifferenceCoverage,
      containsAll({'band', 'risk', 'availability'}),
    );
    expect(
      report.productionGenerationSensitivity,
      containsAll({'band', 'risk', 'availability', 'transition'}),
    );
    expect(
      report.negativeGateDetectionCoverage,
      containsAll({'band', 'risk', 'availability', 'transition'}),
    );
  });

  test(
    'typed fingerprint uses real availability and one transition authority',
    () {
      final known = ThaiBetaNarrativeComposer.narrativeView(
        analysis,
      ).futurePrediction!.windows.expand((window) => window.domains).toList();
      final unknownAnalysis = ThaiBetaAnalysisRunner.run(
        ThaiBetaInput(
          firstName: 'Fixture',
          lastName: 'Unknown',
          birthDate: DateTime(1982, 6, 6),
          birthTimeUnknown: true,
          province: 'เชียงใหม่',
          provinceKey: 'chiang_mai',
        ),
        startedAt: DateTime(2026, 8, 7),
      );
      final unknown = ThaiBetaNarrativeComposer.narrativeView(
        unknownAnalysis,
      ).futurePrediction!.windows.expand((window) => window.domains).toList();
      expect(
        known.map((domain) => domain.material!.evidenceAvailability).toSet(),
        {ForecastEvidenceAvailability.full},
      );
      expect(
        unknown.map((domain) => domain.material!.evidenceAvailability).toSet(),
        {ForecastEvidenceAvailability.noLagna},
      );
      for (final domain in [...known, ...unknown]) {
        expect(domain.materialFingerprint, contains('|t='));
        expect(domain.materialFingerprint, contains('|k='));
        expect(domain.materialFingerprint, contains('|o='));
        expect(domain.materialFingerprint, contains('|td='));
        expect(domain.materialFingerprint, isNot(contains('|p=')));
      }
      expect(known.map((domain) => domain.material!.sourceOwnership).toSet(), {
        'lagna-house-and-life-period-score',
      });
      expect(
        unknown.map((domain) => domain.material!.sourceOwnership).toSet(),
        {'life-period-score-without-lagna'},
      );
      expect(known.every((domain) => domain.material!.timeDependent), isTrue);
      expect(
        unknown.every((domain) => !domain.material!.timeDependent),
        isTrue,
      );
      expect(
        known.map((domain) => domain.material!.spansTransition).toSet(),
        containsAll({true, false}),
      );
    },
  );

  test(
    'matrix rejects band risk availability transition and vacuous passes',
    () {
      const base = ForecastMaterialFingerprint(
        horizon: ForecastHorizon.nextLifePeriod,
        domain: ForecastDomain.career,
        band: ForecastBand.strong,
        riskDomain: LifeDomain.pressure,
        evidenceAvailability: ForecastEvidenceAvailability.full,
        spansTransition: true,
      );
      PredictionDomainModel model(ForecastMaterialFingerprint material) =>
          PredictionDomainModel(
            title: 'การงาน',
            body: '',
            caution: '',
            claim: 'ข้อความร่วม',
            risk: 'ความเสี่ยงร่วม',
            decisionImpact: 'ผลร่วม',
            preparationAction: 'การกระทำร่วม',
            material: material,
          );
      final mutations = [
        const ForecastMaterialFingerprint(
          horizon: ForecastHorizon.nextLifePeriod,
          domain: ForecastDomain.career,
          band: ForecastBand.quiet,
          riskDomain: LifeDomain.pressure,
          evidenceAvailability: ForecastEvidenceAvailability.full,
          spansTransition: true,
        ),
        const ForecastMaterialFingerprint(
          horizon: ForecastHorizon.nextLifePeriod,
          domain: ForecastDomain.career,
          band: ForecastBand.strong,
          riskDomain: LifeDomain.money,
          evidenceAvailability: ForecastEvidenceAvailability.full,
          spansTransition: true,
        ),
        const ForecastMaterialFingerprint(
          horizon: ForecastHorizon.nextLifePeriod,
          domain: ForecastDomain.career,
          band: ForecastBand.strong,
          riskDomain: LifeDomain.pressure,
          evidenceAvailability: ForecastEvidenceAvailability.noLagna,
          spansTransition: true,
        ),
        const ForecastMaterialFingerprint(
          horizon: ForecastHorizon.nextLifePeriod,
          domain: ForecastDomain.career,
          band: ForecastBand.strong,
          riskDomain: LifeDomain.pressure,
          evidenceAvailability: ForecastEvidenceAvailability.full,
          spansTransition: false,
        ),
      ];
      for (final mutation in mutations) {
        expect(_crossModeViolations(model(base), model(mutation)), isNotEmpty);
      }
      final vacuous = _matrixReport([model(base)], [model(base)]);
      expect(vacuous.differentFingerprintCells, 0);
      expect(vacuous.isAcceptable, isFalse);
    },
  );

  test('uncertainty disclosure is separate and cannot satisfy the gate', () {
    final unknownAnalysis = ThaiBetaAnalysisRunner.run(
      ThaiBetaInput(
        firstName: 'Fixture',
        lastName: 'Unknown',
        birthDate: DateTime(1982, 6, 6),
        birthTimeUnknown: true,
        province: 'เชียงใหม่',
        provinceKey: 'chiang_mai',
      ),
      startedAt: DateTime(2026, 8, 7),
    );
    final unknown = ThaiBetaNarrativeComposer.narrativeView(
      unknownAnalysis,
    ).futurePrediction!.windows.expand((window) => window.domains).toList();
    for (final domain in unknown) {
      expect(domain.uncertaintyDisclosure, contains('ไม่มีหลักฐานลัคนา'));
      expect(domain.preparationAction, isNot(contains('ไม่มีหลักฐานลัคนา')));
      expect(domain.claim, isNot(contains('ไม่มีหลักฐานลัคนา')));
      expect(domain.risk, isNot(contains('ไม่มีหลักฐานลัคนา')));
      expect(domain.decisionImpact, isNot(contains('ไม่มีหลักฐานลัคนา')));
    }

    const fullMaterial = ForecastMaterialFingerprint(
      horizon: ForecastHorizon.current,
      domain: ForecastDomain.career,
      band: ForecastBand.active,
      riskDomain: LifeDomain.pressure,
      evidenceAvailability: ForecastEvidenceAvailability.full,
      spansTransition: false,
    );
    const sharedAction = 'ตอนนี้เก็บผลจริงก่อนเพิ่มภาระ';
    PredictionDomainModel model(
      ForecastMaterialFingerprint material,
      String disclosure, [
      String action = sharedAction,
    ]) => PredictionDomainModel(
      title: 'การงาน',
      body: '',
      caution: '',
      claim: 'งานค่อย ๆ เดินหน้า',
      risk: 'ภาระอาจเกินกำลัง',
      decisionImpact: 'ควรกันเวลางานหลัก',
      preparationAction: action,
      uncertaintyDisclosure: disclosure,
      material: material,
    );
    final violations = _crossModeViolations(
      model(fullMaterial, ''),
      model(
        fullMaterial.copyWith(
          evidenceAvailability: ForecastEvidenceAvailability.noLagna,
        ),
        'คำอ่านนี้ไม่มีหลักฐานลัคนา',
      ),
    );
    expect(violations, isNotEmpty);
    final distinctOutputReport = _matrixReport(
      [model(fullMaterial, '', 'ตอนนี้กำหนดเพดานงานเพิ่ม')],
      [
        model(
          fullMaterial.copyWith(
            evidenceAvailability: ForecastEvidenceAvailability.noLagna,
          ),
          'คำอ่านนี้ไม่มีหลักฐานลัคนา',
          'ตอนนี้บันทึกผลจริงก่อนรับงานใหม่',
        ),
      ],
    );
    expect(distinctOutputReport.sharedOutputJustifications, isEmpty);
  });

  test(
    'profile-aware pairing is order independent and fails identity defects',
    () {
      PredictionDomainModel model(ForecastBand band, String marker) =>
          ThaiBetaNarrativeComposer.composeForecastForMaterial(
            title: 'การงาน',
            windowIndex: 0,
            sourceBody: 'งานมีข้อมูลให้ทบทวน $marker',
            sourceCaution: 'ภาระอาจเกินกำลัง $marker',
            material: ForecastMaterialFingerprint(
              horizon: ForecastHorizon.current,
              domain: ForecastDomain.career,
              band: band,
              riskDomain: LifeDomain.pressure,
              evidenceAvailability: ForecastEvidenceAvailability.full,
              spansTransition: false,
            ),
          );
      final known = [
        model(ForecastBand.strong, 'ก'),
        model(ForecastBand.quiet, 'ข'),
      ];
      final unknown = [
        model(ForecastBand.strong, 'ก'),
        model(ForecastBand.quiet, 'ข'),
      ];
      final ordered = _matrixReport(
        known,
        unknown,
        knownProfileCaseIds: const ['case-a', 'case-b'],
        unknownProfileCaseIds: const ['case-a', 'case-b'],
      );
      final shuffled = _matrixReport(
        known,
        [unknown[1], unknown[0]],
        knownProfileCaseIds: const ['case-a', 'case-b'],
        unknownProfileCaseIds: const ['case-b', 'case-a'],
      );
      expect(shuffled.totalComparedCells, ordered.totalComparedCells);
      expect(shuffled.equalFingerprintCells, ordered.equalFingerprintCells);
      expect(shuffled.violations, ordered.violations);

      final duplicate = _matrixReport(
        known,
        unknown,
        knownProfileCaseIds: const ['case-a', 'case-a'],
        unknownProfileCaseIds: const ['case-a', 'case-b'],
      );
      expect(duplicate.violations.join('\n'), contains('duplicate identity'));
      final missingUnexpected = _matrixReport(
        [known.first],
        [unknown.last],
        knownProfileCaseIds: const ['case-a'],
        unknownProfileCaseIds: const ['case-b'],
      );
      expect(
        missingUnexpected.violations.join('\n'),
        contains('missing identity'),
      );
      expect(
        missingUnexpected.violations.join('\n'),
        contains('unexpected identity'),
      );
    },
  );

  test(
    'selective action follows decision intent without appending every risk',
    () {
      const base = ForecastMaterialFingerprint(
        horizon: ForecastHorizon.current,
        domain: ForecastDomain.career,
        band: ForecastBand.active,
        riskDomain: LifeDomain.pressure,
        evidenceAvailability: ForecastEvidenceAvailability.full,
        spansTransition: false,
      );
      const claim = 'งานมีพื้นที่ขยับทีละขั้น';
      const risk = 'ภาระใหม่อาจเบียดเวลางานหลัก';
      const decision = 'บทบาทใหม่ต้องไม่ลดคุณภาพงานหลัก';
      PredictionDomainModel compose(
        ForecastMaterialFingerprint material, {
        ForecastDecisionIntent? intent,
      }) => ThaiBetaNarrativeComposer.composeForecastForMaterial(
        title: 'การงาน',
        windowIndex: 0,
        sourceBody: claim,
        sourceCaution: risk,
        material: material,
        decisionIntent: intent,
      );
      final pressure = compose(base);
      final money = compose(base.copyWith(riskDomain: LifeDomain.money));
      final liquidity = compose(
        base,
        intent: ForecastDecisionIntent.preserveLiquidity,
      );
      expect(pressure.preparationAction, money.preparationAction);
      expect(pressure.decisionImpact, isNot(liquidity.decisionImpact));
      expect(pressure.preparationAction, isNot(liquidity.preparationAction));
      expect(
        pressure.decisionPlan!.intent,
        ForecastDecisionIntent.protectCoreWork,
      );
      expect(
        liquidity.decisionPlan!.intent,
        ForecastDecisionIntent.preserveLiquidity,
      );
      for (final value in [
        pressure.preparationAction,
        money.preparationAction,
        liquidity.preparationAction,
      ]) {
        expect(value, isNot(contains(claim)));
        expect(value, isNot(contains(risk)));
        expect(value, isNot(contains(decision)));
        expect(value, isNot(contains('ใช้ผลต่อการตัดสินใจว่า')));
        expect(value, isNot(contains('ความเสี่ยงที่ตอบอยู่')));
      }
    },
  );

  test('typed coherence gate rejects foreign and generic risk responses', () {
    for (final domain in ForecastDomain.values) {
      final valid = ThaiBetaNarrativeComposer.composeForecastForMaterial(
        title: domain.name,
        windowIndex: 0,
        sourceBody: 'แนวโน้มที่มีหลักฐานรองรับ',
        sourceCaution: 'แรงกดดัน',
        material: ForecastMaterialFingerprint(
          horizon: ForecastHorizon.current,
          domain: domain,
          band: ForecastBand.active,
          riskDomain: LifeDomain.pressure,
          evidenceAvailability: ForecastEvidenceAvailability.full,
          spansTransition: false,
        ),
      );
      expect(_typedCoherenceViolations(valid), isEmpty, reason: domain.name);
      final foreign = PredictionDomainModel(
        title: valid.title,
        body: valid.body,
        caution: valid.caution,
        claim: valid.claim,
        risk: 'ภาระเกินกำลังอาจเบียดพื้นที่ตัดสินใจ',
        decisionImpact: valid.decisionImpact,
        preparationAction: 'ลดภาระทันทีเมื่อภาระเริ่มเกินกำลัง',
        material: valid.material,
        decisionPlan: valid.decisionPlan,
      );
      expect(
        _typedCoherenceViolations(foreign),
        isNotEmpty,
        reason: '${domain.name} must reject a generic pressure response',
      );
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
      material: ForecastMaterialFingerprint(
        horizon: ForecastHorizon.current,
        domain: ForecastDomain.career,
        band: ForecastBand.strong,
        riskDomain: LifeDomain.pressure,
        evidenceAvailability: ForecastEvidenceAvailability.full,
        spansTransition: false,
      ),
    );
    const invalidUnknown = PredictionDomainModel(
      title: 'การงาน',
      body: '',
      caution: '',
      claim: 'งานช้าลง',
      risk: 'รับงานเกินเวลา',
      decisionImpact: 'ต้องเลือกงานหลัก',
      preparationAction: 'จำกัดงานเพิ่ม',
      material: ForecastMaterialFingerprint(
        horizon: ForecastHorizon.current,
        domain: ForecastDomain.career,
        band: ForecastBand.quiet,
        riskDomain: LifeDomain.career,
        evidenceAvailability: ForecastEvidenceAvailability.noLagna,
        spansTransition: false,
      ),
    );
    final violations = _crossModeViolations(known, invalidUnknown);
    expect(violations, hasLength(greaterThanOrEqualTo(2)));
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

  test('late-life periods are omitted without age-specific evidence', () {
    final periods = ThaiBetaNarrativeComposer.narrativeView(
      analysis,
    ).lifeTimeline!.periods;
    final latePeriods = periods
        .where((period) {
          final start = int.parse(period.ageLabel.split('–').first);
          return start >= 69;
        })
        .toList(growable: false);

    expect(latePeriods, isEmpty);
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

  test('all retained periods contain age-aware consumer narrative', () {
    final periods = ThaiBetaNarrativeComposer.narrativeView(
      analysis,
    ).lifeTimeline!.periods;
    expect(periods, isNotEmpty);
    for (final period in periods) {
      final start = int.parse(period.ageLabel.split('–').first);
      final text = period.lifeDomains.map((domain) => domain.body).join('\n');
      expect(
        period.lifeDomains.isNotEmpty ||
            [
              period.summary,
              period.whatChanges,
              period.easier,
              period.harder,
              period.comparison,
              period.evidenceLine,
              period.advice,
            ].any((value) => value.trim().isNotEmpty),
        isTrue,
        reason: '${period.ageLabel} must not be a heading-only period',
      );
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

String _semanticCoreKey(String value) => value
    .replaceAll(
      RegExp(
        r'สำหรับตอนนี้|ใน 12 เดือนข้างหน้า|เมื่อเข้าสู่ช่วงชีวิตถัดไป|'
        r'ตอนนี้|ตั้งจุดทบทวนภายใน 12 เดือน|'
        r'ก่อนเปลี่ยนช่วงชีวิต เตรียมรับรอยต่อระยะยาวโดย|'
        r'ก่อนเปลี่ยนช่วงชีวิต เตรียมฐานระยะยาวโดย',
      ),
      '',
    )
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
  final fields = <({ForecastField field, String left, String right})>[
    (field: ForecastField.claim, left: known.claim, right: unknown.claim),
    (field: ForecastField.risk, left: known.risk, right: unknown.risk),
    (
      field: ForecastField.decisionImpact,
      left: known.decisionImpact,
      right: unknown.decisionImpact,
    ),
    (
      field: ForecastField.action,
      left: known.preparationAction,
      right: unknown.preparationAction,
    ),
  ];
  final leftPlan =
      known.decisionPlan ?? ForecastDecisionPlan.fromMaterial(known.material!);
  final rightPlan =
      unknown.decisionPlan ??
      ForecastDecisionPlan.fromMaterial(unknown.material!);
  for (final field in fields) {
    final leftFingerprint = _projectionKey(leftPlan.projection(field.field));
    final rightFingerprint = _projectionKey(rightPlan.projection(field.field));
    if (leftFingerprint == rightFingerprint) continue;
    final exact = field.left == field.right;
    final leftKey = _meaningKey(field.left);
    final rightKey = _meaningKey(field.right);
    final contained = leftKey.contains(rightKey) || rightKey.contains(leftKey);
    final similar = _semanticSimilarity(field.left, field.right) >= 0.72;
    if (exact || contained || similar) {
      violations.add(
        '${known.title}/${field.field.name}: different material fingerprints '
        'retained equal/contained/similar output '
        '[$leftFingerprint] vs [$rightFingerprint] '
        '"${field.left}" vs "${field.right}"',
      );
    }
  }
  return violations;
}

String _projectionKey(Map<String, Object?> value) {
  final keys = value.keys.toList()..sort();
  return keys.map((key) => '$key=${value[key]}').join('|');
}

_MatrixReport _matrixReport(
  List<PredictionDomainModel> known,
  List<PredictionDomainModel> unknown, {
  List<String>? knownProfileCaseIds,
  List<String>? unknownProfileCaseIds,
  Set<String> productionGenerationSensitivity = const {},
  Set<String> negativeGateDetectionCoverage = const {},
}) {
  final leftIds = knownProfileCaseIds ?? List.filled(known.length, 'case-1');
  final rightIds =
      unknownProfileCaseIds ?? List.filled(unknown.length, 'case-1');
  String identity(String profileCaseId, PredictionDomainModel model) =>
      '$profileCaseId/${model.material!.horizon.name}/${model.material!.domain.name}';
  final violations = <String>[];
  if (leftIds.length != known.length || rightIds.length != unknown.length) {
    violations.add('profile identity count mismatch');
  }
  final leftByIdentity = <String, PredictionDomainModel>{};
  final rightByIdentity = <String, PredictionDomainModel>{};
  for (var i = 0; i < known.length && i < leftIds.length; i++) {
    final key = identity(leftIds[i], known[i]);
    if (leftByIdentity.containsKey(key)) {
      violations.add('duplicate identity $key');
    }
    leftByIdentity[key] = known[i];
  }
  for (var i = 0; i < unknown.length && i < rightIds.length; i++) {
    final key = identity(rightIds[i], unknown[i]);
    if (rightByIdentity.containsKey(key)) {
      violations.add('duplicate identity $key');
    }
    rightByIdentity[key] = unknown[i];
  }
  var total = 0;
  var equal = 0;
  var different = 0;
  final observed = <String, Set<Object?>>{
    'band': {},
    'risk': {},
    'availability': {},
    'transition': {},
  };
  final differenceCoverage = <String>{};
  final fieldCoverage = <ForecastField>{};
  final sharedOutputs = <_SharedOutputJustification>[];
  for (final entry in leftByIdentity.entries) {
    final left = entry.value;
    final right = rightByIdentity.remove(entry.key);
    if (right == null) {
      violations.add('missing identity ${entry.key}');
      continue;
    }
    final leftMaterial = left.material!;
    final rightMaterial = right.material!;
    observed['band']!.addAll([leftMaterial.band, rightMaterial.band]);
    observed['risk']!.addAll([
      leftMaterial.riskDomain,
      rightMaterial.riskDomain,
    ]);
    observed['availability']!.addAll([
      leftMaterial.evidenceAvailability,
      rightMaterial.evidenceAvailability,
    ]);
    observed['transition']!.addAll([
      leftMaterial.spansTransition,
      rightMaterial.spansTransition,
    ]);
    if (leftMaterial.band != rightMaterial.band) {
      differenceCoverage.add('band');
    }
    if (leftMaterial.riskDomain != rightMaterial.riskDomain) {
      differenceCoverage.add('risk');
    }
    if (leftMaterial.evidenceAvailability !=
        rightMaterial.evidenceAvailability) {
      differenceCoverage.add('availability');
    }
    if (leftMaterial.spansTransition != rightMaterial.spansTransition) {
      differenceCoverage.add('transition');
    }
    for (final field in ForecastField.values) {
      fieldCoverage.add(field);
      total++;
      final a = _projectionKey(
        (left.decisionPlan ?? ForecastDecisionPlan.fromMaterial(leftMaterial))
            .projection(field),
      );
      final b = _projectionKey(
        (right.decisionPlan ?? ForecastDecisionPlan.fromMaterial(rightMaterial))
            .projection(field),
      );
      if (a == b) {
        equal++;
      } else {
        different++;
        final leftText = _fieldText(left, field);
        final rightText = _fieldText(right, field);
        final leftKey = _meaningKey(leftText);
        final rightKey = _meaningKey(rightText);
        if (leftText == rightText ||
            leftKey.contains(rightKey) ||
            rightKey.contains(leftKey) ||
            _semanticSimilarity(leftText, rightText) >= 0.72) {
          sharedOutputs.add(
            _SharedOutputJustification(
              identity: entry.key,
              field: field,
              leftProjection: a,
              rightProjection: b,
              normalizedPredictiveText: '$leftKey || $rightKey',
              evidenceBackedReason: '',
            ),
          );
        }
      }
    }
    violations.addAll(_crossModeViolations(left, right));
  }
  for (final entry in rightByIdentity.entries) {
    violations.add('unexpected identity ${entry.key}');
  }
  return _MatrixReport(
    totalComparedCells: total,
    equalFingerprintCells: equal,
    differentFingerprintCells: different,
    sharedOutputJustifications: sharedOutputs,
    violations: violations,
    observedValueCoverage: observed,
    actualDifferenceCoverage: differenceCoverage,
    productionGenerationSensitivity: productionGenerationSensitivity,
    negativeGateDetectionCoverage: negativeGateDetectionCoverage,
    fieldComparisonCoverage: fieldCoverage,
  );
}

String _fieldText(PredictionDomainModel model, ForecastField field) =>
    switch (field) {
      ForecastField.claim => model.claim,
      ForecastField.risk => model.risk,
      ForecastField.decisionImpact => model.decisionImpact,
      ForecastField.action => model.preparationAction,
    };

Set<String> _duplicateClauses(String text) {
  final clauses = text
      .split(
        RegExp(
          r'[\n.!?]|(?=โดยไม่)|(?=โดยมี)|(?=ระหว่างนั้น)|(?=ถ้า)|(?=และกัน)',
        ),
      )
      .map(_meaningKey)
      .where((clause) => clause.length >= 10)
      .toList();
  final seen = <String>{};
  return {
    for (final clause in clauses)
      if (!seen.add(clause)) clause,
  };
}

String _sentenceSkeleton(String text) => _meaningKey(text)
    .replaceAll(RegExp(r'ตลอดปีข้างหน้า|เมื่อเข้าใกล้ช่วงชีวิตถัดไป'), '')
    .replaceAll(
      RegExp(r'งาน|เงิน|ความสัมพันธ์|สุขภาพ|การพัก|บทบาท'),
      '<domain>',
    )
    .replaceAll(RegExp(r'\d+'), '<n>');

List<String> _typedCoherenceViolations(PredictionDomainModel model) {
  final plan = model.decisionPlan!;
  final tokens = switch (plan.consumerRiskDomain) {
    LifeDomain.career => (risk: 'งานหลัก', decision: 'งานหลัก'),
    LifeDomain.money => (risk: 'ภาระเงิน', decision: 'เงิน'),
    LifeDomain.love => (risk: 'ความคาดหวัง', decision: 'ความคาดหวัง'),
    LifeDomain.health => (risk: 'การพัก', decision: 'พัก'),
    _ => (risk: '', decision: ''),
  };
  final actionToken = switch (plan.intent) {
    ForecastDecisionIntent.protectCoreWork => 'งาน',
    ForecastDecisionIntent.preserveLiquidity => 'เงิน',
    ForecastDecisionIntent.clarifyCommitment => 'เงื่อนไข',
    ForecastDecisionIntent.preserveRecovery => 'กิจกรรม',
  };
  return [
    if (tokens.risk.isEmpty || !model.risk.contains(tokens.risk))
      'risk does not use the typed consumer risk',
    if (tokens.decision.isEmpty ||
        !model.decisionImpact.contains(tokens.decision))
      'decision does not answer the typed consumer risk',
    if (!model.preparationAction.contains(actionToken))
      'action does not follow the typed decision intent',
  ];
}

Set<String> _negativeGateDetectionCoverage(PredictionDomainModel derived) {
  final base = derived.material!.copyWith(
    horizon: ForecastHorizon.nextLifePeriod,
    spansTransition: true,
  );
  PredictionDomainModel model(ForecastMaterialFingerprint material) =>
      PredictionDomainModel(
        title: derived.title,
        body: '',
        caution: '',
        claim: derived.claim,
        risk: derived.risk,
        decisionImpact: derived.decisionImpact,
        preparationAction: derived.preparationAction,
        material: material,
      );
  final mutations = <String, ForecastMaterialFingerprint>{
    'band': base.copyWith(
      band: base.band == ForecastBand.quiet
          ? ForecastBand.strong
          : ForecastBand.quiet,
    ),
    'risk': base.copyWith(
      riskDomain: base.riskDomain == LifeDomain.money
          ? LifeDomain.pressure
          : LifeDomain.money,
    ),
    'availability': base.copyWith(
      evidenceAvailability:
          base.evidenceAvailability == ForecastEvidenceAvailability.full
          ? ForecastEvidenceAvailability.noLagna
          : ForecastEvidenceAvailability.full,
    ),
    'transition': base.copyWith(spansTransition: !base.spansTransition),
  };
  return {
    for (final entry in mutations.entries)
      if (_crossModeViolations(model(base), model(entry.value)).isNotEmpty)
        entry.key,
  };
}

Set<String> _productionGenerationSensitivity(PredictionDomainModel derived) {
  final base = derived.material!.copyWith(
    horizon: ForecastHorizon.nextLifePeriod,
    spansTransition: true,
  );
  PredictionDomainModel compose(ForecastMaterialFingerprint material) =>
      ThaiBetaNarrativeComposer.composeForecastForMaterial(
        title: derived.title,
        windowIndex: 2,
        sourceBody: 'ด้านนี้มีข้อมูลให้ทบทวนก่อนขยายภาระ',
        sourceCaution: 'ภาระอาจเกินกำลังที่มี',
        material: material,
      );
  final mutations = <String, ForecastMaterialFingerprint>{
    'band': base.copyWith(
      band: base.band == ForecastBand.quiet
          ? ForecastBand.strong
          : ForecastBand.quiet,
    ),
    'risk': base.copyWith(
      riskDomain: base.riskDomain == LifeDomain.money
          ? LifeDomain.health
          : LifeDomain.money,
    ),
    'availability': base.copyWith(
      evidenceAvailability:
          base.evidenceAvailability == ForecastEvidenceAvailability.full
          ? ForecastEvidenceAvailability.noLagna
          : ForecastEvidenceAvailability.full,
    ),
    'transition': base.copyWith(spansTransition: false),
  };
  final original = compose(base);
  return {
    for (final entry in mutations.entries)
      if (_projectedFieldsChanged(original, compose(entry.value))) entry.key,
  };
}

bool _projectedFieldsChanged(
  PredictionDomainModel left,
  PredictionDomainModel right,
) {
  final leftPlan = left.decisionPlan!;
  final rightPlan = right.decisionPlan!;
  var observedRelevantChange = false;
  for (final field in ForecastField.values) {
    final a = _projectionKey(leftPlan.projection(field));
    final b = _projectionKey(rightPlan.projection(field));
    if (a != b &&
        _meaningKey(_fieldText(left, field)) !=
            _meaningKey(_fieldText(right, field))) {
      observedRelevantChange = true;
    }
  }
  return observedRelevantChange;
}

class _MatrixReport {
  const _MatrixReport({
    required this.totalComparedCells,
    required this.equalFingerprintCells,
    required this.differentFingerprintCells,
    required this.sharedOutputJustifications,
    required this.violations,
    required this.observedValueCoverage,
    required this.actualDifferenceCoverage,
    required this.productionGenerationSensitivity,
    required this.negativeGateDetectionCoverage,
    required this.fieldComparisonCoverage,
  });

  final int totalComparedCells;
  final int equalFingerprintCells;
  final int differentFingerprintCells;
  final List<_SharedOutputJustification> sharedOutputJustifications;
  final List<String> violations;
  final Map<String, Set<Object?>> observedValueCoverage;
  final Set<String> actualDifferenceCoverage;
  final Set<String> productionGenerationSensitivity;
  final Set<String> negativeGateDetectionCoverage;
  final Set<ForecastField> fieldComparisonCoverage;

  List<String> get failures => [
    if (differentFingerprintCells == 0) 'vacuous matrix',
    ...violations,
    if (!observedValueCoverage['band']!.containsAll(ForecastBand.values))
      'missing observed band values',
    if (observedValueCoverage['risk']!.whereType<LifeDomain>().length < 2)
      'missing observed risk values',
    if (!observedValueCoverage['availability']!.containsAll(
      ForecastEvidenceAvailability.values,
    ))
      'missing observed availability values',
    if (!observedValueCoverage['transition']!.containsAll({true, false}))
      'missing observed transition values',
    if (!actualDifferenceCoverage.containsAll({'band', 'risk', 'availability'}))
      'missing actual cross-mode difference coverage',
    if (!productionGenerationSensitivity.containsAll({
      'band',
      'risk',
      'availability',
      'transition',
    }))
      'missing production generation sensitivity',
    if (!negativeGateDetectionCoverage.containsAll({
      'band',
      'risk',
      'availability',
      'transition',
    }))
      'missing negative gate detection coverage',
    if (!fieldComparisonCoverage.containsAll(ForecastField.values))
      'missing field comparison coverage',
    if (sharedOutputJustifications.any(
      (entry) => entry.evidenceBackedReason.isEmpty,
    ))
      'shared output lacks evidence-backed justification',
  ];

  bool get isAcceptable => failures.isEmpty;
}

class _SharedOutputJustification {
  const _SharedOutputJustification({
    required this.identity,
    required this.field,
    required this.leftProjection,
    required this.rightProjection,
    required this.normalizedPredictiveText,
    required this.evidenceBackedReason,
  });

  final String identity;
  final ForecastField field;
  final String leftProjection;
  final String rightProjection;
  final String normalizedPredictiveText;
  final String evidenceBackedReason;
}
