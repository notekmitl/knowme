import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:knowme/features/thai_beta/application/narrative/predictive_runtime_v2.dart';
import 'package:knowme/features/thai_beta/application/thai_beta_analysis.dart';
import 'package:knowme/features/thai_beta/application/thai_beta_report_export_document.dart';
import 'package:knowme/features/thai_beta/domain/thai_beta_input.dart';

import '../synthetic_audit/thai_beta_synthetic_matrix_300.dart';

void main() {
  group('Candidate 0029 reader copy on Candidate 0023 authority', () {
    test('00:35 binds Candidate 0029 to the accepted predictive authority', () {
      final plan = ThaiPredictiveRuntimeV2Plan.fromAnalysis(
        _acceptedAt(DateTime(2026, 9, 11), minute: 35),
      );
      expect(plan.contextId, 'mahabhut2537.rem0.saturday');
      expect(plan.emittedPredictions, 11);
      expect(plan.emittedClaims, hasLength(13));
      expect(plan.omittedClaims, isEmpty);
      expect(plan.unsupportedClaims, 0);
      expect(plan.fixtureSpecificBranches, 0);
      expect(plan.ownerAcceptedGoldenOverrideApplied, 0);
      expect(plan.unexpectedFixtureSpecificBranches, 0);
      expect(plan.fixtureReferenceLeakage, 0);
      final bindingErrors = RuntimePredictiveClaimBindingValidator.validate(
        plan,
      );
      expect(bindingErrors, isEmpty);
      expect(plan.monthlyTimelineAvailable, isFalse);
      final sectionTitles = plan.sections
          .map((section) => section.title)
          .toList(growable: false);
      const expectedHeadings = [
        'คำทำนายอดีต',
        'ตั้งแต่เกิดจนถึง 10 ปี · ดาวเสาร์เสวยอายุ',
        'อายุ 11–29 ปี · ดาวพฤหัสบดีเสวยอายุ',
        'อายุ 30–41 ปี · ดาวราหูเสวยอายุ',
        'คำทำนายปัจจุบัน — อายุ 44 ปี · ดาวศุกร์เสวยอายุ',
        'คำทำนาย 12 เดือนข้างหน้า',
        'คำแนะนำ',
        'ข้อจำกัด',
      ];
      expect(sectionTitles, containsAllInOrder(expectedHeadings));
      for (final heading in expectedHeadings) {
        expect(sectionTitles.where((title) => title == heading), hasLength(1));
      }
      expect(plan.usesCandidate0023Components, isTrue);
      expect(plan.usesCandidate0027ReaderCopy, isFalse);
      expect(plan.usesCandidate0028ReaderCopy, isFalse);
      expect(plan.usesCandidate0029ReaderCopy, isTrue);
    });

    test('00:35 renders the Candidate 0029 full reader sections exactly', () {
      final document = ThaiBetaReportExportDocument.candidate(
        _acceptedAt(DateTime(2026, 9, 11), minute: 35),
      );
      final expected = _candidate0029SectionPlainText();
      expect(document.sectionPlainText, expected);
      expect(document.predictiveRuntimeV2!.usesCandidate0023Components, isTrue);
      expect(
        document.predictiveRuntimeV2!.usesCandidate0027ReaderCopy,
        isFalse,
      );
      expect(
        document.predictiveRuntimeV2!.usesCandidate0028ReaderCopy,
        isFalse,
      );
      expect(document.predictiveRuntimeV2!.usesCandidate0029ReaderCopy, isTrue);
      expect(
        document.sections.map((section) => section.title),
        isNot(contains('ภาพรวมเส้นทางชีวิตที่ผ่านมา')),
      );
      final current = document.sections.singleWhere(
        (section) => section.id == 'report-body-predictive-v2-current',
      );
      expect(current.paragraphs, hasLength(6));
      const currentLeads = [
        'ปัจจุบันอายุ 44 ปี',
        'ด้านการงาน',
        'ด้านการเงิน',
        'ด้านความรักและความสัมพันธ์',
        'ด้านสุขภาพ',
        'ด้านโชคลาภและแรงสนับสนุน',
      ];
      for (var index = 0; index < currentLeads.length; index++) {
        expect(current.paragraphs[index], startsWith(currentLeads[index]));
      }
      expect(
        document.sections.where(
          (section) => const {
            'การงาน',
            'การเงิน',
            'ความรักและความสัมพันธ์',
            'สุขภาพ',
            'โชคลาภและแรงสนับสนุน',
          }.contains(section.title),
        ),
        isEmpty,
      );
      final titles = document.sections.map((section) => section.title).toList();
      expect(titles.last, 'ข้อจำกัด');
      expect(
        titles.indexOf('ข้อจำกัด'),
        greaterThan(titles.indexOf('ที่มาของผลวิเคราะห์')),
      );
    });

    test('rolling horizon uses asOf and never stays pinned to 2026-08-29', () {
      final plan = ThaiPredictiveRuntimeV2Plan.fromAnalysis(
        ThaiBetaAnalysisRunner.run(
          _acceptedInput(minute: 3),
          asOf: DateTime(2026, 8, 7),
        ),
      );
      final horizon = plan.claimForOwner('rolling12')!.text;
      expect(horizon, contains('7 สิงหาคม 2569 ถึง 6 สิงหาคม 2570'));
      expect(horizon, isNot(contains('29 สิงหาคม 2569')));
      expect(plan.ownerAcceptedGoldenOverrideApplied, 0);
      expect(plan.fixtureReferenceLeakage, 0);
    });

    test('00:03 and 00:35 share one predictive body for one signature', () {
      final three = ThaiPredictiveRuntimeV2Plan.fromAnalysis(_accepted());
      final thirtyFive = ThaiPredictiveRuntimeV2Plan.fromAnalysis(
        _accepted(minute: 35),
      );
      expect(three.contextId, thirtyFive.contextId);
      expect(three.predictiveSignature, thirtyFive.predictiveSignature);
      expect(
        _predictiveSectionProjection(three),
        _predictiveSectionProjection(thirtyFive),
      );
      expect(three.subtitle, contains('เวลา 00:03 น.'));
      expect(three.subtitle, contains('ลัคนาราศีกุมภ์ 9°24′'));
      expect(thirtyFive.subtitle, contains('เวลา 00:35 น.'));
      expect(thirtyFive.subtitle, contains('ลัคนาราศีกุมภ์ 19°19′'));
      for (final plan in [three, thirtyFive]) {
        expect(plan.emittedPredictions, 11);
        expect(plan.ownerAcceptedGoldenOverrideApplied, 0);
        expect(plan.fixtureReferenceLeakage, 0);
        expect(plan.evidenceBindingMismatches, 0);
        expect(plan.generationPath, contains('signature+392-selector'));
      }
    });

    test('00:03 and 00:35 infographic inventories use only bound Known claims', () {
      const hero = 'ขอบเขตงานจะกว้างขึ้น และรายรับจะเพิ่มขึ้น';
      const period = '29 ส.ค. 2569 – 28 ส.ค. 2570';
      const expectedByOwner = <String, String>{
        'work': 'งานมีเข้ามาต่อเนื่องและคุณยังรับผิดชอบงานหลักได้เต็มที่',
        'finance': 'คุณมีเงินใช้และมีโชคลาภ เรื่องเงินในช่วงนี้คล่องตัวขึ้น',
        'relationship':
            'คนมีคู่ใกล้ชิดกันขึ้น ส่วนคนโสดที่กำลังรู้จักใครจะเห็นความสัมพันธ์ชัดขึ้น',
        'health':
            'กำลังโดยรวมยังดี แต่ช่วงที่พักไม่พอ ร่างกายจะฟื้นช้าลงและทำกิจกรรมต่อเนื่องได้ลดลง',
        'support': 'ครู ผู้มีประสบการณ์ เพื่อน และคนในเครือข่ายจะเข้ามาช่วย',
        'advice':
            'กำหนดขอบเขตงานที่รับเพิ่ม ตรวจเงินคงเหลือหลังรายจ่ายจำเป็นก่อนขยายแผน และกันเวลาพักไว้ให้ร่างกายฟื้นแรง',
        'disclosure':
            'คำทำนายนี้เป็นการตีความตามหลักโหราศาสตร์และความเชื่อ ใช้ประกอบการพิจารณาร่วมกับข้อเท็จจริงก่อนตัดสินใจเรื่องสำคัญ',
      };
      final identities = <String>[];
      final predictiveBodies = <String>[];
      for (final minute in [3, 35]) {
        final analysis = _accepted(minute: minute);
        final plan = ThaiPredictiveRuntimeV2Plan.fromAnalysis(analysis);
        final document = ThaiBetaReportExportDocument.candidate(analysis);
        final infographic = document.infographic!;
        expect(infographic.periodLabel, period);
        expect(infographic.overview, period);
        expect(infographic.theme, hero);
        expect(infographic.categories.map((item) => item.title), [
          'การงาน',
          'การเงิน',
          'ความรัก',
          'สุขภาพ',
        ]);
        expect(infographic.categories.map((item) => item.summary), [
          expectedByOwner['work'],
          expectedByOwner['finance'],
          expectedByOwner['relationship'],
          expectedByOwner['health'],
        ]);
        expect(infographic.opportunity, expectedByOwner['support']);
        expect(infographic.caution, expectedByOwner['health']);
        expect(infographic.primaryAdvice, expectedByOwner['advice']);
        expect(infographic.disclaimer, expectedByOwner['disclosure']);

        final allText = <String>[
          infographic.overview,
          infographic.theme,
          ...infographic.categories.map((item) => item.summary),
          infographic.opportunity,
          infographic.caution,
          infographic.primaryAdvice,
          infographic.disclaimer,
        ];
        expect(allText.where((text) => text == hero), hasLength(1));
        for (final rejected in const [
          'เว้นหัวข้อที่ต้องใช้เวลาเกิด',
          'ไม่มีเวลาเกิด',
          'ข้อมูลไม่เพียงพอ',
        ]) {
          expect(allText.any((text) => text.contains(rejected)), isFalse);
        }
        final emittedIds = plan.emittedClaims
            .map((decision) => decision.rule.id)
            .toSet();
        expect(infographic.traceIds.every(emittedIds.contains), isTrue);
        expect(
          infographic.categories.every(
            (item) => item.traceIds.every(emittedIds.contains),
          ),
          isTrue,
        );
        expect(
          plan.emittedClaims.any(
            (decision) =>
                <String>[
                  decision.rule.id,
                  decision.rule.semanticOwner,
                  ...decision.rule.evidenceRefs,
                  ...decision.rule.sourceComponents,
                ].any(
                  (value) => RegExp(
                    r'unknown|omission|fallback',
                    caseSensitive: false,
                  ).hasMatch(value),
                ),
          ),
          isFalse,
        );
        for (final owner in expectedByOwner.keys) {
          final decision = plan.claimForOwner(owner)!;
          expect(decision.rule.hasCompletePredictiveChain, isTrue);
          expect(decision.infographicText, expectedByOwner[owner]);
        }
        expect(
          plan.claimForOwner('rolling12')!.infographicText,
          'ระหว่างวันที่ 29 สิงหาคม 2569 ถึง 28 สิงหาคม 2570 $hero',
        );
        identities.add(plan.subtitle);
        predictiveBodies.add(jsonEncode(_predictiveSectionProjection(plan)));
      }
      expect(identities[0], contains('ลัคนาราศีกุมภ์ 9°24′'));
      expect(identities[1], contains('ลัคนาราศีกุมภ์ 19°19′'));
      expect(predictiveBodies[0], predictiveBodies[1]);
    });

    test('Known infographic rejects a tainted Unknown omission reason', () {
      final plan = ThaiPredictiveRuntimeV2Plan.fromAnalysis(
        _accepted(minute: 35),
      );
      final tainted = ThaiPredictiveRuntimeV2Plan(
        contextId: plan.contextId,
        knownTime: plan.knownTime,
        currentAge: plan.currentAge,
        asOf: plan.asOf,
        title: plan.title,
        subtitle: plan.subtitle,
        decisions: plan.decisions,
        sections: plan.sections,
        omissionReason: 'ไม่มีเวลาเกิด — รายงานจึงเว้นหัวข้อที่ต้องใช้เวลาเกิด',
        currentPeriod: plan.currentPeriod,
        predictiveSignature: plan.predictiveSignature,
      );
      expect(
        ThaiBetaReportExportDocument.runtimeInfographicFromPlan(tainted),
        isNull,
      );
      expect(
        ThaiBetaReportExportDocument.runtimeInfographicFromPlan(plan),
        isNotNull,
      );
    });

    test('a different signature selects its own generalized rules', () {
      final active = ThaiPredictiveRuntimeV2Plan.fromAnalysis(
        _accepted(minute: 35),
      );
      final different = ThaiPredictiveRuntimeV2Plan.fromAnalysis(
        ThaiBetaAnalysisRunner.run(
          ThaiBetaInput(
            firstName: 'Different',
            lastName: 'Signature',
            birthDate: DateTime(1982, 6, 7),
            birthHour: 12,
            birthMinute: 0,
            birthTimeUnknown: false,
            province: 'เชียงใหม่',
            provinceKey: 'chiang mai',
            gender: 'ชาย',
          ),
          asOf: DateTime(2026, 8, 29),
        ),
      );
      expect(different.predictiveSignature, isNot(active.predictiveSignature));
      expect(
        _predictiveSectionProjection(different),
        isNot(_predictiveSectionProjection(active)),
      );
      expect(different.ownerAcceptedGoldenOverrideApplied, 0);
      expect(different.unexpectedFixtureSpecificBranches, 0);
      expect(different.fixtureReferenceLeakage, 0);
      expect(different.evidenceBindingMismatches, 0);
    });

    test('Candidate 0011 remains immutable historical evidence only', () {
      final oracle =
          jsonDecode(
                File(
                  'docs/CANDIDATE_0011_OWNER_ACCEPTED_ORACLE.json',
                ).readAsStringSync(),
              )
              as Map<String, dynamic>;
      final source = oracle['source'] as Map<String, dynamic>;
      expect(source['acceptedReaderFacingSha256'], _acceptedOracleSha256);
      expect(source['currentReaderFacingSha256'], _acceptedOracleSha256);
      expect(oracle['status'], contains('OWNER_ACCEPTED'));
    });
  });

  group('fail-closed selection and shared surfaces', () {
    test('Unknown emits no Known claim or time-dependent chart copy', () {
      final analysis = ThaiBetaAnalysisRunner.run(
        _acceptedInput(known: false),
        asOf: DateTime(2026, 8, 29),
      );
      final plan = ThaiPredictiveRuntimeV2Plan.fromAnalysis(analysis);
      final baseline = ThaiBetaReportExportDocument.fromAnalysis(
        analysis,
        applyReaderCopy: true,
      );
      final document = ThaiBetaReportExportDocument.candidate(analysis);
      expect(plan.contextId, 'unknown-time');
      expect(plan.emittedClaims, isEmpty);
      expect(plan.omittedClaims, isEmpty);
      expect(plan.knownToUnknownLeakage, 0);
      expect(plan.omissionReason, contains('แทนการเดาข้อมูลที่ไม่มี'));
      expect(document.predictiveRuntimeV2!.emittedClaims, isEmpty);
      expect(
        document.sections.where(
          (section) => section.id.contains('predictive-v2-'),
        ),
        isEmpty,
      );
      expect(document.fullPlainText, isNot(contains('ลัคนาราศีกุมภ์')));
      expect(
        document.fullPlainText,
        isNot(contains('วันทางโหราศาสตร์เป็นวันเสาร์')),
      );
      expect(document.infographic, isNull);
      expect(analysis.consumerViewState!.futurePrediction, isNull);
      expect(analysis.consumerViewState!.lifeTimeline, isNull);
      expect(plan.monthlyTimelineAvailable, isFalse);

      expect(document.sections, hasLength(baseline.sections.length));
      for (var index = 0; index < baseline.sections.length; index++) {
        final before = baseline.sections[index];
        final after = document.sections[index];
        expect(after.paragraphs, before.paragraphs, reason: before.id);
        expect(after.kind, before.kind, reason: before.id);
        expect(after.id, before.id, reason: before.id);
        expect(after.fieldSource, before.fieldSource, reason: before.id);
        expect(after.visibilityRule, before.visibilityRule, reason: before.id);
        expect(
          after.knownUnknownRule,
          before.knownUnknownRule,
          reason: before.id,
        );
        expect(after.traceIds, before.traceIds, reason: before.id);
      }

      final titles = document.sections
          .map((section) => section.title)
          .toList(growable: false);
      expect(titles.where((title) => title == 'คำทำนายอดีต'), isEmpty);
      expect(
        titles.where((title) => title == 'คำทำนายปัจจุบัน — อายุ 44 ปี'),
        isEmpty,
      );
      expect(titles.where((title) => title == 'ช่วงชีวิตถัดไป'), isEmpty);
      expect(titles, [
        'ส่วนที่ 1 · พื้นดวงของคุณ',
        'ส่วนที่ 2 · จังหวะชีวิตที่ผ่านมาและปัจจุบัน',
        'ส่วนที่ 3 · แนวโน้มข้างหน้า',
        'ส่วนที่ 4 · ที่มาและข้อจำกัด',
      ]);
      expect(titles, isNot(contains('อดีตของคุณ')));
      expect(titles, isNot(contains('ช่วงปัจจุบัน')));
      expect(titles, isNot(contains('จังหวะชีวิตระยะต่อไป')));
      expect(titles, isNot(contains('เรื่องสำคัญของช่วงนี้')));
      expect(titles.where((title) => title.trim().isEmpty), isEmpty);
      expect(
        titles.indexOf('ส่วนที่ 1 · พื้นดวงของคุณ'),
        lessThan(titles.indexOf('ส่วนที่ 2 · จังหวะชีวิตที่ผ่านมาและปัจจุบัน')),
      );
      expect(
        titles.indexOf('ส่วนที่ 2 · จังหวะชีวิตที่ผ่านมาและปัจจุบัน'),
        lessThan(titles.indexOf('ส่วนที่ 3 · แนวโน้มข้างหน้า')),
      );
    });

    test('Unknown V2 adapter leaves Known candidate bytes unchanged', () {
      final before = ThaiBetaReportExportDocument.candidate(_accepted());
      final after = ThaiBetaReportExportDocument.candidate(_accepted());
      expect(after.fullPlainText, before.fullPlainText);
      expect(after.predictiveRuntimeV2!.usesCandidate0028ReaderCopy, isFalse);
      expect(after.predictiveRuntimeV2!.usesCandidate0029ReaderCopy, isTrue);
      expect(after.predictiveRuntimeV2!.ownerAcceptedGoldenOverrideApplied, 0);
    });

    test(
      'Web/PDF/print document projects one canonical plan and trace ids',
      () {
        final document = ThaiBetaReportExportDocument.candidate(_accepted());
        final plan = document.predictiveRuntimeV2!;
        final projected = document.sections
            .where((section) => section.id.contains('predictive-v2-'))
            .expand((section) => section.paragraphs)
            .toSet();
        for (final claim in plan.emittedClaims.where(
          (claim) => claim.rule.semanticOwner != 'overview',
        )) {
          for (final paragraph in claim.text.split(RegExp(r'\n\s*\n'))) {
            expect(projected, contains(paragraph), reason: claim.rule.id);
          }
        }
        expect(
          projected,
          isNot(contains(plan.claimForOwner('overview')!.text)),
          reason: 'The redundant overview remains internal evidence only',
        );
        expect(
          document.infographic!.traceIds.toSet(),
          plan.emittedClaims.map((claim) => claim.rule.id).toSet(),
        );
        expect(document.infographic!.monthlyTimelineAvailable, isFalse);
        expect(
          document.infographic!.periodLabel,
          '29 ส.ค. 2569 – 28 ส.ค. 2570',
        );
        expect(document.infographic!.categories, hasLength(4));
      },
    );
  });

  group('generalization accounting', () {
    test('selector reaches all 49 contexts without fixture branches', () {
      final ids = <String>{
        for (var remainder = 0; remainder < 7; remainder++)
          for (var weekday = 1; weekday <= 7; weekday++)
            ThaiPredictiveRuntimeV2Plan.contextIdForMetadata(
              remainder,
              weekday,
            ),
      };
      expect(ids, hasLength(49));
      expect(ids, contains('mahabhut2537.rem0.saturday'));
      expect(ids.every((id) => id.startsWith('mahabhut2537.rem')), isTrue);
    });

    test('all 392 rows pass through the actual period resolver', () {
      expect(runtimePredictiveV2PeriodRows, hasLength(392));
      for (final row in runtimePredictiveV2PeriodRows) {
        expect(
          ThaiPredictiveRuntimeV2Plan.resolveMatrixApplication(
            row.matrixApplicationId,
          ),
          same(row),
          reason: row.matrixApplicationId,
        );
        expect(
          ThaiPredictiveRuntimeV2Plan.resolvePeriod(
            contextId: row.contextId,
            age: row.ageStart,
          )?.matrixApplicationId,
          row.matrixApplicationId,
          reason: row.matrixApplicationId,
        );
      }
    });

    test('actual plans cover 49 contexts with complete distinct reports', () {
      final plans = _representativePlans49();
      expect(plans.keys.toSet(), runtimePredictiveV2ContextIds);
      final rulesByContext = <String, List<RuntimePredictiveRule>>{
        for (final entry in plans.entries)
          entry.key: entry.value.emittedClaims
              .map((decision) => decision.rule)
              .toList(growable: false),
      };
      final ownersByContext = <String, Set<String>>{
        for (final entry in plans.entries)
          entry.key: entry.value.emittedSemanticOwners,
      };
      final reports = <String, String>{
        for (final entry in plans.entries)
          entry.key: _normalizedReaderBody(entry.value),
      };
      final evidence = <String, String>{
        for (final entry in rulesByContext.entries)
          entry.key: entry.value
              .expand((rule) => rule.evidenceRefs)
              .toSet()
              .toList()
              .join('|'),
      };
      expect(reports.values.toSet(), hasLength(49));
      final result = RuntimePredictiveIntegrityValidator.validate(
        contextIds: plans.keys.toSet(),
        periodRows: runtimePredictiveV2PeriodRows,
        rulesByContext: rulesByContext,
        ownersByContext: ownersByContext,
        normalizedReportsByContext: reports,
        evidenceFingerprintsByContext: evidence,
        baselineFallbackContexts: {
          for (final entry in plans.entries)
            if (entry.value.baselineFallbackUsed) entry.key,
        },
        observedFixtureSpecificBranches: plans.values.fold(
          0,
          (total, plan) => total + plan.fixtureSpecificBranches,
        ),
        fixtureMetricDerived: true,
      );
      expect(result.errors, isEmpty);
    });

    test('49 rendered contexts obey predictive editorial ownership', () {
      final plans = _representativePlans49();
      expect(plans, hasLength(49));
      for (final entry in plans.entries) {
        final plan = entry.value;
        expect(
          RuntimePredictiveClaimBindingValidator.validate(plan),
          isEmpty,
          reason: entry.key,
        );
        expect(plan.ownerAcceptedGoldenOverrideApplied, 0, reason: entry.key);
        expect(plan.fixtureReferenceLeakage, 0, reason: entry.key);
        final seen = <String, String>{};
        for (final decision in plan.emittedClaims.where(
          (claim) => claim.rule.kind == RuntimePredictiveKind.prediction,
        )) {
          expect(
            _predictionQualityViolations(decision),
            isEmpty,
            reason: '${entry.key}:${decision.rule.id}',
          );
          final normalized = _normalizedParagraph(decision.text);
          final priorOwner = seen[normalized];
          expect(
            priorOwner == null || priorOwner == decision.rule.semanticOwner,
            isTrue,
            reason:
                '${entry.key}:$priorOwner↔${decision.rule.semanticOwner}:$normalized',
          );
          seen[normalized] = decision.rule.semanticOwner;
        }
        final current = plan.claimForOwner('current')!;
        final horizon = plan.claimForOwner('rolling12')!;
        expect(current.text, isNot(horizon.text), reason: entry.key);
        expect(
          _trigramSimilarity(current.text, horizon.text),
          lessThan(0.72),
          reason: entry.key,
        );
      }
    });

    test(
      'all rendered life-period headings identify their governing planet',
      () {
        final plans = _representativePlans49();
        expect(plans, hasLength(49));
        for (final entry in plans.entries) {
          final lifePeriods = entry.value.sections.where(
            (section) =>
                section.claims.isNotEmpty &&
                (section.id.startsWith('past-') ||
                    section.id == 'current' ||
                    section.id == 'next-life-period'),
          );
          expect(lifePeriods, isNotEmpty, reason: entry.key);
          for (final section in lifePeriods) {
            expect(
              section.title,
              matches(RegExp(r'ดาว.+เสวยอายุ')),
              reason: '${entry.key}:${section.id}',
            );
          }
        }
      },
    );

    test('coverage validator rejects every required negative control', () {
      const contextA = 'mahabhut2537.rem0.sunday';
      const contextB = 'mahabhut2537.rem1.monday';
      final completeOwners = <String>{
        ...ThaiPredictiveRuntimeV2Plan.requiredKnownSemanticOwners,
        'past-0-10',
      };
      final completeRule = RuntimePredictiveRule(
        id: 'complete',
        semanticOwner: 'overview',
        section: 'ภาพรวม',
        kind: RuntimePredictiveKind.prediction,
        textTemplate: 'ข้อความ',
        contextId: contextA,
        periodBinding: '0-10',
        domain: 'life_path',
        selectorRefs: const ['selector.mahabhut2537.rem0.sunday.sun.0_6'],
        domainRefs: const ['domain.runtime.life-period'],
        directionRefs: const ['direction.runtime.life-period'],
        timingRefs: const ['selector.mahabhut2537.rem0.sunday.sun.0_6'],
        conflictRefs: const ['conflict.contract-boundaries'],
        certaintyRefs: const ['certainty.product-interpretation-contract-v1'],
        selectorApplicationId: 'mahabhut2537.rem0.sunday.sun.0_6',
        horizon: 'current',
        materialFingerprint:
            'period=mahabhut2537.rem0.sunday.sun.0_6|status=dueng_khuen',
        evidenceKey: 'selector.mahabhut2537.rem0.sunday.sun.0_6',
        directionBand: 'dueng_khuen',
        sourceComponents: const ['selector.mahabhut2537.rem0.sunday.sun.0_6'],
        realizerId: 'life-period-editorial-v2',
      );
      final emptySummary = RuntimePredictiveRule(
        id: 'summary',
        semanticOwner: 'summary',
        section: 'สรุป',
        kind: RuntimePredictiveKind.summary,
        textTemplate: 'สรุป',
        contextId: contextA,
        periodBinding: '0-10',
        domain: 'life_path',
        selectorRefs: const [],
        domainRefs: const [],
        directionRefs: const [],
        timingRefs: const [],
        conflictRefs: const [],
        certaintyRefs: const [],
        horizon: 'summary',
        sourceComponents: const ['complete'],
        realizerId: 'summary-composition-v2',
      );
      RuntimePredictiveIntegrityResult validate({
        Set<String> contexts = const {contextA},
        Map<String, List<RuntimePredictiveRule>>? rules,
        Map<String, Set<String>>? owners,
        Map<String, String>? reports,
        Map<String, String>? evidence,
        Set<String> fallback = const {},
        int fixtureBranches = 0,
        bool metricDerived = true,
      }) => RuntimePredictiveIntegrityValidator.validate(
        contextIds: contexts,
        periodRows: runtimePredictiveV2PeriodRows,
        rulesByContext:
            rules ??
            {
              contextA: [completeRule],
            },
        ownersByContext: owners ?? {contextA: completeOwners},
        normalizedReportsByContext: reports ?? {contextA: 'A'},
        evidenceFingerprintsByContext: evidence ?? {contextA: 'EA'},
        baselineFallbackContexts: fallback,
        observedFixtureSpecificBranches: fixtureBranches,
        fixtureMetricDerived: metricDerived,
      );

      expect(validate().errors, contains('CONTEXT_COUNT_NOT_49'));
      expect(
        validate(fallback: const {contextA}).errors,
        contains('BASELINE_FALLBACK:1'),
      );
      expect(
        validate(metricDerived: false).errors,
        contains('FIXTURE_METRIC_NOT_DERIVED'),
      );
      expect(
        validate(
          rules: {
            contextA: [emptySummary],
          },
        ).errors,
        contains('INVALID_SUMMARY_COMPOSITION:summary'),
      );
      expect(
        validate(
          contexts: const {contextA, contextB},
          rules: {
            contextA: [completeRule],
            contextB: [completeRule],
          },
          owners: {contextA: completeOwners, contextB: completeOwners},
          reports: const {contextA: 'A', contextB: 'B'},
          evidence: const {contextA: 'EA', contextB: 'EB'},
        ).errors,
        contains('RULE_CONTEXT_MISMATCH:$contextB:complete'),
      );
      expect(
        validate(
          owners: {
            contextA: const {'overview'},
          },
        ).errors.any((error) => error.startsWith('MISSING_SEMANTIC_OWNER:')),
        isTrue,
      );
      expect(
        validate(
          contexts: const {contextA, contextB},
          rules: {
            contextA: [completeRule],
            contextB: [completeRule],
          },
          owners: {contextA: completeOwners, contextB: completeOwners},
          reports: const {contextA: 'same', contextB: 'same'},
          evidence: const {contextA: 'EA', contextB: 'EB'},
        ).errors.any(
          (error) =>
              error.startsWith('IDENTICAL_REPORT_WITH_DIFFERENT_EVIDENCE:'),
        ),
        isTrue,
      );
      expect(
        validate(
          rules: {
            contextA: [
              completeRule.copyWith(
                sourceComponents: const ['fixture.forbidden-control'],
              ),
            ],
          },
          fixtureBranches: 1,
        ).errors,
        containsAll([
          'FIXTURE_SPECIFIC_RULE:complete',
          'FIXTURE_SPECIFIC_BRANCHES:1',
        ]),
      );
    });

    test(
      '300 profiles are deterministic and omissions are reported honestly',
      () {
        final contexts = <String>{};
        var known = 0;
        var knownComplete = 0;
        var knownFallback = 0;
        var unknown = 0;
        var emitted = 0;
        var omitted = 0;
        var unsupported = 0;
        var unknownLeakage = 0;
        for (final fixture in ThaiBetaSyntheticMatrix.build()) {
          final analysis = ThaiBetaAnalysisRunner.run(
            fixture.input,
            asOf: DateTime(2026, 8, 29),
          );
          final first = ThaiPredictiveRuntimeV2Plan.fromAnalysis(analysis);
          final second = ThaiPredictiveRuntimeV2Plan.fromAnalysis(analysis);
          expect(second.toMap(), first.toMap(), reason: fixture.id);
          if (first.knownTime) {
            known++;
            contexts.add(first.contextId);
            if (first.missingSemanticOwners.isEmpty &&
                !first.baselineFallbackUsed) {
              knownComplete++;
            }
            if (first.baselineFallbackUsed) knownFallback++;
            expect(first.missingSemanticOwners, isEmpty, reason: fixture.id);
          } else {
            unknown++;
            expect(first.emittedClaims, isEmpty, reason: fixture.id);
          }
          emitted += first.emittedClaims.length;
          omitted += first.omittedClaims.length;
          unsupported += first.unsupportedClaims;
          unknownLeakage += first.knownToUnknownLeakage;
          expect(first.fixtureSpecificBranches, 0, reason: fixture.id);
          expect(first.monthlyTimelineAvailable, isFalse, reason: fixture.id);
        }
        expect(contexts, hasLength(48));
        expect(known, 225);
        expect(unknown, 75);
        expect(knownComplete, 225);
        expect(knownFallback, 0);
        expect(emitted, greaterThan(0));
        expect(omitted, 0);
        expect(unsupported, 0);
        expect(unknownLeakage, 0);
      },
    );
  });
}

const _acceptedOracleSha256 =
    '6AA94C7A01555310C5189FAAF711597057C5DF2F102246A0DF3946DAB2B62A1E';
ThaiBetaAnalysis _accepted({int minute = 3}) => ThaiBetaAnalysisRunner.run(
  _acceptedInput(minute: minute),
  asOf: DateTime(2026, 8, 29),
);

ThaiBetaAnalysis _acceptedAt(DateTime asOf, {int minute = 3}) =>
    ThaiBetaAnalysisRunner.run(_acceptedInput(minute: minute), asOf: asOf);

ThaiBetaInput _acceptedInput({bool known = true, int minute = 3}) =>
    ThaiBetaInput(
      firstName: 'Runtime',
      lastName: 'Validation',
      birthDate: DateTime(1982, 6, 6),
      birthHour: known ? 0 : null,
      birthMinute: known ? minute : 0,
      birthTimeUnknown: !known,
      province: 'เชียงใหม่',
      provinceKey: 'chiang mai',
      gender: 'ชาย',
    );

List<List<String>> _candidate0029Sections() {
  final source = File(
    'docs/CANDIDATE_0029_ACTUAL_0035_FULL_READER_COPY.md',
  ).readAsStringSync().replaceAll('\r\n', '\n');
  final body = source
      .split('<!-- BEGIN CANDIDATE 0029 FULL READER COPY -->')
      .last
      .split('<!-- END CANDIDATE 0029 FULL READER COPY -->')
      .first;
  final sections = <List<String>>[];
  for (final rawLine in body.split('\n')) {
    final line = rawLine.trim();
    if (line.isEmpty || line.startsWith('# คำทำนายดวงชะตา')) continue;
    final heading = RegExp(r'^#{2,3}\s+(.+)$').firstMatch(line);
    if (heading != null) {
      sections.add([heading.group(1)!]);
      continue;
    }
    sections.last.add(line);
  }
  return sections;
}

String _candidate0029SectionPlainText() =>
    _candidate0029Sections().map((section) => section.join('\n')).join('\n\n');

List<Map<String, Object?>> _predictiveSectionProjection(
  ThaiPredictiveRuntimeV2Plan plan,
) => [
  for (final section in plan.sections)
    {
      'id': section.id,
      'title': section.title,
      'claims': [
        for (final claim in section.claims)
          {'id': claim.rule.id, 'text': claim.text},
      ],
    },
];

Map<String, ThaiPredictiveRuntimeV2Plan> _representativePlans49() {
  final plans = <String, ThaiPredictiveRuntimeV2Plan>{};
  for (final fixture in ThaiBetaSyntheticMatrix.build()) {
    if (fixture.input.birthTimeUnknown) {
      continue;
    }
    final plan = ThaiPredictiveRuntimeV2Plan.fromAnalysis(
      ThaiBetaAnalysisRunner.run(fixture.input, asOf: DateTime(2026, 8, 29)),
    );
    if (!plan.baselineFallbackUsed) {
      plans.putIfAbsent(plan.contextId, () => plan);
    }
  }
  var date = DateTime(1975, 1, 1);
  final end = DateTime(1985, 1, 1);
  while (plans.length < 49 && date.isBefore(end)) {
    final analysis = ThaiBetaAnalysisRunner.run(
      ThaiBetaInput(
        firstName: 'Context',
        lastName: 'Coverage',
        birthDate: date,
        birthHour: 12,
        birthMinute: 0,
        birthTimeUnknown: false,
        province: 'เชียงใหม่',
        provinceKey: 'chiang mai',
        gender: 'ชาย',
      ),
      asOf: DateTime(2026, 8, 29),
    );
    final plan = ThaiPredictiveRuntimeV2Plan.fromAnalysis(analysis);
    if (!plan.baselineFallbackUsed) {
      plans.putIfAbsent(plan.contextId, () => plan);
    }
    date = date.add(const Duration(days: 1));
  }
  return plans;
}

String _normalizedReaderBody(ThaiPredictiveRuntimeV2Plan plan) => [
  for (final section in plan.sections) ...[
    section.title.replaceAll(RegExp(r'\d+'), '#'),
    ...section.claims.map(
      (claim) => claim.text.replaceAll(RegExp(r'\d+'), '#'),
    ),
  ],
].join('\n').replaceAll(RegExp(r'\s+'), ' ').trim();

List<String> _predictionQualityViolations(RuntimePredictiveDecision decision) {
  final text = decision.text.trim();
  final violations = <String>[];
  const hedgePhrases = ['มีแนวโน้ม', 'อาจ', 'มีโอกาส', 'น่าจะ', 'เป็นไปได้ว่า'];
  for (final phrase in hedgePhrases) {
    final isCandidate0029BoundWording = switch ((
      phrase,
      decision.rule.semanticOwner,
    )) {
      ('อาจ', 'past-0-10') => text.contains('การดูแลคุณอาจทำได้ไม่เต็มที่'),
      ('อาจ', 'support') => text.contains('ความช่วยเหลืออาจมาในรูป'),
      _ => false,
    };
    if (isCandidate0029BoundWording) {
      continue;
    }
    if (text.contains(phrase)) violations.add('hedge:$phrase');
  }
  const personalityPhrases = ['คุณคาดหวัง', 'คุณมัก', 'นิสัย', 'เป็นคน'];
  for (final phrase in personalityPhrases) {
    if (text.contains(phrase)) violations.add('personality:$phrase');
  }
  if (decision.rule.semanticOwner.startsWith('past-') &&
      (text.contains('?') ||
          text.contains('ลอง') ||
          text.contains('ทบทวน') ||
          text.contains('บทเรียนติดตัว'))) {
    violations.add('past-reflection');
  }
  for (final sentence in text.split(RegExp(r'[.!?]\s*'))) {
    if (RegExp(
      r'^(หาก|ถ้า|ควร|ให้|ลอง|ทบทวน)(\s|คุณ)',
    ).hasMatch(sentence.trim())) {
      violations.add('advice-leakage:${sentence.trim()}');
    }
  }
  const methodology = [
    'มหาภูต',
    'ทักษา',
    'selector',
    'evidence',
    'ดาว',
    'เรือน',
  ];
  for (final phrase in methodology) {
    if (text.contains(phrase)) violations.add('methodology:$phrase');
  }
  const stale = [
    'ช่วงนี้ งานมีแนวโน้ม',
    'ช่วงนี้ รายได้มีโอกาส',
    'คุณคาดหวังเงียบ ๆ',
    'ถ้ารักษาเวลานอน',
    'ให้ประเมินโอกาสจากหลักฐาน',
    'งานและหน้าที่บังคับให้คุณ',
  ];
  for (final phrase in stale) {
    if (text.contains(phrase)) violations.add('stale:$phrase');
  }
  return violations;
}

String _normalizedParagraph(String value) => value
    .replaceAll(RegExp(r'\s+'), '')
    .replaceAll(RegExp(r'[\p{P}\p{S}]', unicode: true), '')
    .toLowerCase();

double _trigramSimilarity(String left, String right) {
  Set<String> grams(String value) {
    final normalized = _normalizedParagraph(value);
    if (normalized.length < 3) return {normalized};
    return {
      for (var index = 0; index <= normalized.length - 3; index++)
        normalized.substring(index, index + 3),
    };
  }

  final a = grams(left);
  final b = grams(right);
  final union = a.union(b);
  return union.isEmpty ? 0 : a.intersection(b).length / union.length;
}
