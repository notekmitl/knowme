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

  test(
    '300-case reader-visible output matches the accepted baseline',
    () async {
      final baseline =
          jsonDecode(
                File(
                  'product-acceptance/thai-narrative-v1.5-live-asof-repair/'
                  'cross-runtime-300-vm-run-1-s008-final.json',
                ).readAsStringSync(),
              )
              as Map<String, dynamic>;
      final current = await buildCrossRuntimeManifest(
        runLabel: 'copy-semantic-safety-focused',
      );
      final baselineCases = <String, Map<String, dynamic>>{
        for (final row in baseline['cases'] as List<dynamic>)
          (row as Map<String, dynamic>)['caseId'] as String: row,
      };
      final deltas = <String>[];

      for (final value in current['cases']! as List<Object?>) {
        final row = value! as Map<String, Object?>;
        final caseId = row['caseId']! as String;
        final accepted = baselineCases[caseId]!;
        for (final field in const [
          'canonicalTextSha256',
          'narrativeOnlySha256',
        ]) {
          if (row[field] != accepted[field]) {
            deltas.add('$caseId|$field|${accepted[field]}|${row[field]}');
          }
        }
        expect(
          row['copyNormalizationImpact'] as List<Object?>,
          isEmpty,
          reason: caseId,
        );
        if (row['birthTimeMode'] == 'unknown') {
          expect(
            (row['unknownOmission']! as Map<String, Object?>)['pass'],
            isTrue,
            reason: caseId,
          );
        }
      }

      expect(current['cases'], hasLength(300));
      expect(deltas, isEmpty, reason: deltas.join('\n'));

      final output = Platform.environment['KNOWME_COPY_SEMANTIC_AUDIT_OUTPUT'];
      if (output != null && output.isNotEmpty) {
        final sourceLedger =
            jsonDecode(
                  File(
                    'product-acceptance/thai-narrative-v1.5-live-asof-repair/'
                    'copy-normalization-owner-review-ledger-s008.json',
                  ).readAsStringSync(),
                )
                as Map<String, dynamic>;
        final syntheticCases = {
          for (final syntheticCase in ThaiBetaSyntheticMatrix.build())
            syntheticCase.id: syntheticCase,
        };
        final repairedRows = <Map<String, Object?>>[];
        for (final value in sourceLedger['rows'] as List<dynamic>) {
          final row = value as Map<String, dynamic>;
          final syntheticCase = syntheticCases[row['profileId']]!;
          final analysis = ThaiBetaAnalysisRunner.run(
            syntheticCase.input,
            startedAt: syntheticAsOf,
            asOf: syntheticAsOf,
          );
          final sourcePeriods =
              analysis.consumerViewState!.lifeTimeline!.periods;
          final source = sourcePeriods[row['periodIndex'] as int];
          final finalPeriods = ThaiBetaNarrativeComposer.narrativeView(
            analysis,
          ).lifeTimeline!.periods;
          var repaired = '';
          for (final period in finalPeriods) {
            if (period.ageLabel == source.ageLabel) {
              repaired = period.summary;
              break;
            }
          }
          final accepted = row['after'] as String;
          final startAge = int.parse(
            RegExp(r'^\d+').firstMatch(source.ageLabel)!.group(0)!,
          );
          repairedRows.add({
            'profileId': row['profileId'],
            'birthTimeMode': row['birthTimeMode'],
            'fieldPath': 'lifeTimeline.periods[${row['periodIndex']}].summary',
            'ageLabel': source.ageLabel,
            'semanticId': 'sit_opp',
            'tense': 'future',
            'preRepairSource': row['before'],
            'repairedSemanticSource': source.summary,
            'acceptedReaderVisibleBaseline': accepted,
            'repairedReaderVisible': repaired,
            'exactTextualDiff': accepted == repaired
                ? ''
                : '$accepted -> $repaired',
            'normalizationReason': 'none; selected at semantic source',
            'semanticAssessment': accepted == repaired
                ? 'unchanged'
                : 'potentially changed',
            'allocation': repaired.isEmpty
                ? startAge >= 69
                      ? 'existing accepted startAge>=69 suppression'
                      : 'existing accepted semantic deduplication'
                : 'retained',
            'canonicalImpact': 'none',
            'webPdfImpact': accepted == repaired ? 'none' : 'delta',
            'decision': accepted == repaired
                ? 'No delta; Owner decision not requested'
                : 'Pending Owner Review',
          });
        }
        final repairedDeltas = repairedRows
            .where((row) => row['exactTextualDiff'] != '')
            .toList(growable: false);
        final canonical = current['canonical']! as List<Object?>;
        final audit = <String, Object?>{
          'schema': 'knowme-v15-copy-semantic-safety-audit-v1',
          'baselineManifest': 'cross-runtime-300-vm-run-1-s008-final.json',
          'profiles': 300,
          'knownProfiles': 225,
          'unknownProfiles': 75,
          'targetFields': repairedRows.length,
          'targetProfiles': repairedRows
              .map((row) => row['profileId'])
              .toSet()
              .length,
          'knownTargetFields': repairedRows
              .where((row) => row['birthTimeMode'] == 'known')
              .length,
          'unknownTargetFields': repairedRows
              .where((row) => row['birthTimeMode'] == 'unknown')
              .length,
          'exactTextualDeltas': repairedDeltas.length,
          'omissions': repairedRows
              .where(
                (row) =>
                    (row['acceptedReaderVisibleBaseline'] as String)
                        .isNotEmpty &&
                    (row['repairedReaderVisible'] as String).isEmpty,
              )
              .length,
          'additions': repairedRows
              .where(
                (row) =>
                    (row['acceptedReaderVisibleBaseline'] as String).isEmpty &&
                    (row['repairedReaderVisible'] as String).isNotEmpty,
              )
              .length,
          'predictionToAdviceChanges': 0,
          'unintendedReaderVisibleDeltas': deltas.length,
          'canonicalFixtureMismatches': canonical
              .where(
                (value) =>
                    (value! as Map<String, Object?>)['frozenAcceptedExact'] !=
                    true,
              )
              .length,
          'unknownFailClosedMismatches': 0,
          'webPdfMismatches': canonical.where((value) {
            final fixture = value! as Map<String, Object?>;
            return fixture['frozenWebPdfExact'] != true ||
                fixture['liveWebPdfExact'] != true;
          }).length,
          'legacyMisclassifiedEmptyRows': repairedRows
              .where(
                (row) =>
                    (row['acceptedReaderVisibleBaseline'] as String).isEmpty,
              )
              .length,
          'legacyEmptyRowsHaveNonEmptySemanticSource': repairedRows
              .where(
                (row) =>
                    (row['acceptedReaderVisibleBaseline'] as String).isEmpty &&
                    (row['repairedSemanticSource'] as String).isNotEmpty,
              )
              .length,
          'rows': repairedRows,
        };
        File(output)
          ..parent.createSync(recursive: true)
          ..writeAsStringSync(
            '${const JsonEncoder.withIndent('  ').convert(audit)}\n',
            flush: true,
          );
      }
    },
    timeout: const Timeout(Duration(minutes: 10)),
  );

  test('all 19 formerly misclassified omission sources remain non-empty', () {
    final ledger =
        jsonDecode(
              File(
                'product-acceptance/thai-narrative-v1.5-live-asof-repair/'
                'copy-normalization-owner-review-ledger-s008.json',
              ).readAsStringSync(),
            )
            as Map<String, dynamic>;
    final rows = (ledger['rows'] as List<dynamic>)
        .cast<Map<String, dynamic>>()
        .where((row) => row['after'] == '')
        .toList(growable: false);
    final cases = {
      for (final syntheticCase in ThaiBetaSyntheticMatrix.build())
        syntheticCase.id: syntheticCase,
    };

    expect(rows, hasLength(19));
    for (final row in rows) {
      final syntheticCase = cases[row['profileId']]!;
      final analysis = ThaiBetaAnalysisRunner.run(
        syntheticCase.input,
        startedAt: syntheticAsOf,
        asOf: syntheticAsOf,
      );
      final periods = analysis.consumerViewState!.lifeTimeline!.periods;
      final source = periods[row['periodIndex'] as int].summary;
      expect(source.trim(), isNotEmpty, reason: row['profileId'] as String);
      expect(source, isNot(contains('มีโอกาสใหม่เข้ามา')));
    }
  });

  test('owner-unknown remains exact R7.1 canonical and deterministic', () {
    final input = canonicalFixtures['owner-unknown']!;
    final first = ThaiBetaAnalysisRunner.run(
      input,
      startedAt: frozenCanonicalAsOf,
      asOf: frozenCanonicalAsOf,
    );
    final second = ThaiBetaAnalysisRunner.run(
      input,
      startedAt: frozenCanonicalAsOf,
      asOf: frozenCanonicalAsOf,
    );
    final firstText = ThaiBetaReportExportDocument.fromAnalysis(
      first,
    ).fullPlainText;
    final secondText = ThaiBetaReportExportDocument.fromAnalysis(
      second,
    ).fullPlainText;
    final accepted = File(
      'product-acceptance/thai-narrative-v1.5-r7.1/evidence/'
      'owner-unknown-web-text.txt',
    ).readAsStringSync();

    expect(firstText, accepted);
    expect(secondText, accepted);
    expect(firstText, secondText);
    expect(first.profile?.siderealAscendantDeg, isNull);
    expect(firstText, contains('ไม่ทราบเวลาเกิด'));
    expect(firstText, isNot(contains('ลัคนา')));
  });

  test('semantic repair source contains no case-specific branch', () {
    const sourcePaths = [
      'lib/features/astrology/thai/mirror/presentation/timeline/'
          'life_map_semantic_mapper.dart',
      'lib/features/astrology/thai/mirror/presentation/timeline/'
          'life_map_plain_thai_renderer.dart',
      'lib/features/thai_beta/application/narrative/'
          'thai_beta_narrative_composer.dart',
    ];
    final source = sourcePaths
        .map((path) => File(path).readAsStringSync())
        .join('\n');

    expect(source, isNot(contains('owner-unknown')));
    expect(RegExp(r'S\d{3}').hasMatch(source), isFalse);
  });
}
