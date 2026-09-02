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
        expect(plan.contextId, runtimePredictiveV2AcceptedContext);
        expect(plan.emittedPredictions, 22);
        expect(plan.emittedClaims, hasLength(25));
        expect(plan.omittedClaims, isEmpty);
        expect(plan.unsupportedClaims, 0);
        expect(plan.fixtureSpecificBranches, 0);
        expect(plan.monthlyTimelineAvailable, isFalse);
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
      final document = ThaiBetaReportExportDocument.candidate(analysis);
      expect(plan.contextId, 'unknown-time');
      expect(plan.emittedClaims, isEmpty);
      expect(plan.omittedClaims, hasLength(25));
      expect(plan.knownToUnknownLeakage, 0);
      expect(plan.omissionReason, contains('แทนการเดาข้อมูลที่ไม่มี'));
      expect(document.predictiveRuntimeV2!.emittedClaims, isEmpty);
      expect(
        document.sections.where(
          (section) => section.id.startsWith('predictive-v2-'),
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
    });

    test(
      'Web/PDF/print document projects one canonical plan and trace ids',
      () {
        final document = ThaiBetaReportExportDocument.candidate(_accepted());
        final plan = document.predictiveRuntimeV2!;
        final projected = document.sections
            .where((section) => section.id.startsWith('predictive-v2-'))
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
      expect(ids, contains(runtimePredictiveV2AcceptedContext));
      expect(ids.every((id) => id.startsWith('mahabhut2537.rem')), isTrue);
    });

    test(
      '300 profiles are deterministic and omissions are reported honestly',
      () {
        final contexts = <String>{};
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
          if (first.knownTime) contexts.add(first.contextId);
          emitted += first.emittedClaims.length;
          omitted += first.omittedClaims.length;
          unsupported += first.unsupportedClaims;
          unknownLeakage += first.knownToUnknownLeakage;
          expect(first.fixtureSpecificBranches, 0, reason: fixture.id);
          expect(first.monthlyTimelineAvailable, isFalse, reason: fixture.id);
        }
        expect(contexts.length, greaterThanOrEqualTo(45));
        expect(emitted + omitted, 300 * 25);
        expect(unsupported, 0);
        expect(unknownLeakage, 0);
      },
    );
  });
}

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
