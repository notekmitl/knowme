import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:knowme/features/thai_beta/application/narrative/thai_beta_narrative_composer.dart';
import 'package:knowme/features/thai_beta/application/thai_beta_analysis.dart';
import 'package:knowme/features/thai_beta/application/thai_beta_report_export_document.dart';

import '../synthetic_audit/thai_beta_synthetic_matrix_300.dart';
import 'thai_beta_cross_runtime_manifest.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late Map<String, dynamic> acceptedBaseline;
  late Map<String, Object?> current;

  setUpAll(() async {
    acceptedBaseline =
        jsonDecode(
              File(
                'product-acceptance/thai-narrative-v1.5-live-asof-repair/'
                'cross-runtime-300-vm-run-1-s008-final.json',
              ).readAsStringSync(),
            )
            as Map<String, dynamic>;
    current = await buildCrossRuntimeManifest(
      runLabel: 'copy-semantic-contract-migration',
    );
  });

  test(
    'reader-visible summaries have no broad normalization or semantic delta',
    () {
      // The former 93-profile/112-field expectation is intentionally retired:
      // it encoded 93 semantic changes and 19 apparent omissions as accepted
      // normalization behavior. The replacement checks the real pipeline
      // against the accepted reader-visible baseline without an allowlist.
      final baselineCases = <String, Map<String, dynamic>>{
        for (final value in acceptedBaseline['cases'] as List<dynamic>)
          (value as Map<String, dynamic>)['caseId'] as String: value,
      };
      final syntheticCases = {
        for (final value in ThaiBetaSyntheticMatrix.build()) value.id: value,
      };
      final ownerReview =
          jsonDecode(
                File(
                  'product-acceptance/thai-narrative-v1.5-live-asof-repair/'
                  'copy-normalization-owner-review-ledger-s008.json',
                ).readAsStringSync(),
              )
              as Map<String, dynamic>;
      var known = 0;
      var unknown = 0;
      var exactTextualDeltas = 0;
      var omissions = 0;
      var additions = 0;
      var predictionToAdviceChanges = 0;

      for (final value in current['cases']! as List<Object?>) {
        final row = value! as Map<String, Object?>;
        final caseId = row['caseId']! as String;
        final accepted = baselineCases[caseId]!;
        if (row['birthTimeMode'] == 'known') {
          known++;
        } else {
          unknown++;
        }
        expect(
          row['copyNormalizationImpact'] as List<Object?>,
          isEmpty,
          reason: caseId,
        );
        expect(
          row['canonicalTextSha256'],
          accepted['canonicalTextSha256'],
          reason: '$caseId canonical reader text',
        );
        expect(
          row['narrativeOnlySha256'],
          accepted['narrativeOnlySha256'],
          reason: '$caseId narrative reader text',
        );
      }

      for (final value in ownerReview['rows'] as List<dynamic>) {
        final ledgerRow = value as Map<String, dynamic>;
        final syntheticCase = syntheticCases[ledgerRow['profileId']]!;
        final analysis = ThaiBetaAnalysisRunner.run(
          syntheticCase.input,
          startedAt: syntheticAsOf,
          asOf: syntheticAsOf,
        );
        final source = analysis
            .consumerViewState!
            .lifeTimeline!
            .periods[ledgerRow['periodIndex'] as int];
        final renderedPeriods = ThaiBetaNarrativeComposer.narrativeView(
          analysis,
        ).lifeTimeline!.periods;
        final rendered = renderedPeriods
            .where((period) => period.ageLabel == source.ageLabel)
            .map((period) => period.summary)
            .firstOrNull;
        final accepted = ledgerRow['after'] as String;
        final actual = rendered ?? '';
        if (actual != accepted) exactTextualDeltas++;
        if (accepted.isNotEmpty && actual.isEmpty) omissions++;
        if (accepted.isEmpty && actual.isNotEmpty) additions++;
        if (source.summary.contains('ต่อไปมีโอกาสใหม่เข้ามา') &&
            actual.contains('ดูจากผลที่เกิดขึ้นจริงว่าอะไรควรทำต่อ')) {
          predictionToAdviceChanges++;
        }
      }

      expect(current['cases'], hasLength(300));
      expect(known, 225);
      expect(unknown, 75);
      expect(exactTextualDeltas, 0);
      expect(omissions, 0);
      expect(additions, 0);
      expect(predictionToAdviceChanges, 0);
    },
    timeout: const Timeout(Duration(minutes: 10)),
  );

  test('canonical, fail-closed, Web/PDF, and S008 contracts stay exact', () {
    final canonical = (current['canonical']! as List<Object?>)
        .cast<Map<String, Object?>>();
    expect(canonical, hasLength(5));
    for (final fixture in canonical) {
      expect(fixture['frozenAcceptedExact'], isTrue);
      expect(fixture['frozenWebPdfExact'], isTrue);
      expect(fixture['liveWebPdfExact'], isTrue);
      expect(fixture['liveRepeatExact'], isTrue);
      expect(fixture['reportHashRepeatExact'], isTrue);
      expect(fixture['unknownFailClosed'], isTrue);
    }

    final input = canonicalFixtures['owner-unknown']!;
    final analysis = ThaiBetaAnalysisRunner.run(
      input,
      startedAt: frozenCanonicalAsOf,
      asOf: frozenCanonicalAsOf,
    );
    final ownerUnknownText = ThaiBetaReportExportDocument.fromAnalysis(
      analysis,
    ).fullPlainText;
    final acceptedOwnerUnknown = File(
      'product-acceptance/thai-narrative-v1.5-r7.1/evidence/'
      'owner-unknown-web-text.txt',
    ).readAsStringSync();
    expect(ownerUnknownText, acceptedOwnerUnknown);
    expect(analysis.profile?.siderealAscendantDeg, isNull);
    expect(ownerUnknownText, contains('ไม่ทราบเวลาเกิด'));
    expect(ownerUnknownText, isNot(contains('ลัคนา')));

    final vm = _caseFromEvidence(
      'cross-runtime-300-vm-run-1-copy-semantic.json',
      'S008',
    );
    final chrome = _caseFromEvidence(
      'cross-runtime-300-chrome-run-1-copy-semantic.json',
      'S008',
    );
    final vmRaw = vm['rawNumericAudit']! as Map<String, dynamic>;
    final chromeRaw = chrome['rawNumericAudit']! as Map<String, dynamic>;
    expect(
      vmRaw['siderealAscendantDeg'],
      isNot(chromeRaw['siderealAscendantDeg']),
    );
    expect(
      vmRaw['canonicalSiderealAscendantUnits'],
      chromeRaw['canonicalSiderealAscendantUnits'],
    );
    expect(vm['canonicalTextSha256'], chrome['canonicalTextSha256']);
    expect(vm['reportHash'], chrome['reportHash']);
    expect(vm['narrativeOnlySha256'], chrome['narrativeOnlySha256']);
  });
}

Map<String, dynamic> _caseFromEvidence(String filename, String caseId) {
  final manifest =
      jsonDecode(
            File(
              'product-acceptance/thai-narrative-v1.5-live-asof-repair/'
              '$filename',
            ).readAsStringSync(),
          )
          as Map<String, dynamic>;
  return (manifest['cases'] as List<dynamic>)
      .cast<Map<String, dynamic>>()
      .singleWhere((row) => row['caseId'] == caseId);
}
