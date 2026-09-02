import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:knowme/features/thai_beta/application/narrative/predictive_runtime_v2.dart';
import 'package:knowme/features/thai_beta/application/thai_beta_analysis.dart';
import 'package:knowme/features/thai_beta/application/thai_beta_report_export_document.dart';
import 'package:knowme/features/thai_beta/domain/thai_beta_input.dart';

import '../synthetic_audit/thai_beta_synthetic_matrix_300.dart';

void main() {
  group('Candidate 0011 exact golden runtime', () {
    test(
      'pinned fixture renders the complete accepted reader block exactly',
      () {
        final plan = ThaiPredictiveRuntimeV2Plan.fromAnalysis(_accepted());
        expect(
          runtimePredictiveV2OracleSha256,
          '6AA94C7A01555310C5189FAAF711597057C5DF2F102246A0DF3946DAB2B62A1E',
        );
        expect(plan.contextId, runtimePredictiveV2GoldenOracleContextId);
        expect(plan.emittedPredictions, 22);
        expect(plan.emittedClaims, hasLength(25));
        expect(plan.omittedClaims, isEmpty);
        expect(plan.unsupportedClaims, 0);
        expect(plan.fixtureSpecificBranches, 0);
        expect(plan.monthlyTimelineAvailable, isFalse);
        final sectionTitles = plan.sections
            .map((section) => section.title)
            .toList(growable: false);
        const acceptedHeadings = [
          'คำทำนายอดีต',
          'อายุ 1–10 ปี',
          'อายุ 11–29 ปี',
          'อายุ 30–41 ปี',
          'คำทำนายปัจจุบัน — อายุ 44 ปี',
          'คำทำนาย 12 เดือนข้างหน้า',
          'ช่วงชีวิตถัดไป — อายุ 63–79 ปี',
        ];
        expect(sectionTitles, containsAllInOrder(acceptedHeadings));
        for (final heading in acceptedHeadings) {
          expect(
            sectionTitles.where((title) => title == heading),
            hasLength(1),
          );
        }
        expect(_planLines(plan), _acceptedReaderLines());
      },
    );

    test('rolling horizon uses asOf and never stays pinned to 2026-08-29', () {
      final plan = ThaiPredictiveRuntimeV2Plan.fromAnalysis(
        ThaiBetaAnalysisRunner.run(
          _acceptedInput(minute: 3),
          asOf: DateTime(2026, 8, 7),
        ),
      );
      final horizon = plan.claim('RC11-K-HORIZON-01')!.text;
      expect(horizon, contains('7 สิงหาคม 2569 ถึง 6 สิงหาคม 2570'));
      expect(horizon, isNot(contains('29 สิงหาคม 2569')));
    });

    test('00:03 and 00:35 share rules but retain distinct ascendants', () {
      final first = ThaiPredictiveRuntimeV2Plan.fromAnalysis(_accepted());
      final second = ThaiPredictiveRuntimeV2Plan.fromAnalysis(
        _accepted(minute: 35),
      );
      expect(first.contextId, second.contextId);
      expect(first.emittedPredictions, 22);
      expect(second.emittedPredictions, 22);
      expect(first.subtitle, contains('ลัคนาราศีกุมภ์ 9°24′'));
      expect(second.subtitle, contains('ลัคนาราศีกุมภ์ 19°19′'));
      expect(
        first.emittedClaims.map((claim) => claim.text),
        second.emittedClaims.map((claim) => claim.text),
      );
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
      expect(document.infographic, isNotNull);
      expect(document.infographic!.categories, hasLength(4));
      expect(document.infographic!.monthlyTimelineAvailable, isFalse);

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
      expect(titles.where((title) => title == 'คำทำนายอดีต'), hasLength(1));
      expect(
        titles.where((title) => title == 'คำทำนายปัจจุบัน — อายุ 44 ปี'),
        hasLength(1),
      );
      expect(titles.where((title) => title == 'ช่วงชีวิตถัดไป'), hasLength(1));
      expect(titles, isNot(contains('อดีตของคุณ')));
      expect(titles, isNot(contains('ช่วงปัจจุบัน')));
      expect(titles, isNot(contains('จังหวะชีวิตระยะต่อไป')));
      expect(titles, isNot(contains('เรื่องสำคัญของช่วงนี้')));
      expect(titles.where((title) => title.trim().isEmpty), isEmpty);
      expect(
        titles.indexOf('คำทำนายอดีต'),
        lessThan(titles.indexOf('คำทำนายปัจจุบัน — อายุ 44 ปี')),
      );
      expect(
        titles.indexOf('คำทำนายปัจจุบัน — อายุ 44 ปี'),
        lessThan(titles.indexOf('ช่วงชีวิตถัดไป')),
      );
    });

    test('Unknown V2 adapter leaves Known candidate bytes unchanged', () {
      final before = ThaiBetaReportExportDocument.candidate(_accepted());
      final after = ThaiBetaReportExportDocument.candidate(_accepted());
      expect(after.fullPlainText, before.fullPlainText);
      expect(_planLines(after.predictiveRuntimeV2!), _acceptedReaderLines());
      expect(runtimePredictiveV2OracleSha256, _acceptedOracleSha256);
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
        for (final claim in plan.emittedClaims) {
          expect(projected, contains(claim.text), reason: claim.rule.id);
        }
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
      expect(ids, contains(runtimePredictiveV2GoldenOracleContextId));
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

    test('coverage validator rejects every required negative control', () {
      const contextA = 'mahabhut2537.rem0.sunday';
      const contextB = 'mahabhut2537.rem1.monday';
      const completeOwners =
          ThaiPredictiveRuntimeV2Plan.requiredKnownSemanticOwners;
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
            contextA: [completeRule.copyWith(fixtureSpecific: true)],
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

List<String> _planLines(ThaiPredictiveRuntimeV2Plan plan) => [
  plan.title,
  ...plan.subtitle.split('\n'),
  for (final section in plan.sections) ...[
    section.title,
    ...section.claims.map((claim) => claim.text),
  ],
].where((line) => line.trim().isNotEmpty).toList(growable: false);

List<String> _acceptedReaderLines() {
  final source = File(
    'docs/THAI_REPORT_PREDICTIVE_NARRATIVE_V2_TARGET_CANDIDATE_0011.md',
  ).readAsStringSync().replaceAll('\r\n', '\n');
  final start = source.indexOf('Reader-facing candidate begins below.');
  final end = source.indexOf('Reader-facing candidate ends above.');
  return source
      .substring(start, end)
      .split('\n')
      .map((line) => line.trim())
      .where(
        (line) =>
            line.isNotEmpty &&
            line != 'Reader-facing candidate begins below.' &&
            !line.startsWith('<!--'),
      )
      .map((line) => line.replaceFirst(RegExp(r'^#{1,6}\s+'), ''))
      .map((line) => line.replaceAll('<br>', ''))
      .toList(growable: false);
}

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
