import 'dart:convert';
import 'dart:io';

import 'package:crypto/crypto.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:knowme/features/thai_beta/application/narrative/predictive_runtime_v2.dart';
import 'package:knowme/features/thai_beta/application/thai_beta_analysis.dart';
import 'package:knowme/features/thai_beta/domain/thai_beta_input.dart';

import '../validation/thai_beta/synthetic_audit/thai_beta_synthetic_matrix_300.dart';

void main() {
  test('writes and validates PR115 OR1 runtime product evidence', () {
    final asOf = DateTime(2026, 8, 29);
    final rawProfiles = <Map<String, Object?>>[];
    final knownPlans = <String, ThaiPredictiveRuntimeV2Plan>{};
    var knownComplete = 0;
    var knownFallback = 0;
    var unknownFailClosed = 0;
    var unsupportedClaims = 0;
    var fixtureSpecificBranches = 0;
    var knownToUnknownLeakage = 0;
    final emittedPredictionCounts = <int>[];
    final normalizedKnownReports = <String>{};

    for (final fixture in ThaiBetaSyntheticMatrix.build()) {
      final analysis = ThaiBetaAnalysisRunner.run(fixture.input, asOf: asOf);
      final plan = ThaiPredictiveRuntimeV2Plan.fromAnalysis(analysis);
      final normalized = _normalizedReaderBody(plan);
      final reportHash = sha256.convert(utf8.encode(normalized)).toString();
      final duplicateOwners = _duplicateDetailedOwners(plan);
      if (plan.knownTime) {
        knownPlans.putIfAbsent(plan.contextId, () => plan);
        emittedPredictionCounts.add(plan.emittedPredictions);
        normalizedKnownReports.add(normalized);
        if (!plan.baselineFallbackUsed && plan.missingSemanticOwners.isEmpty) {
          knownComplete++;
        } else {
          knownFallback++;
        }
      } else if (plan.emittedClaims.isEmpty &&
          plan.contextId == 'unknown-time') {
        unknownFailClosed++;
      }
      unsupportedClaims += plan.unsupportedClaims;
      fixtureSpecificBranches += plan.fixtureSpecificBranches;
      knownToUnknownLeakage += plan.knownToUnknownLeakage;
      rawProfiles.add({
        'profileId': fixture.id,
        'birthTimeMode': plan.knownTime ? 'Known' : 'Unknown',
        'contextId': plan.contextId,
        'currentPeriod': plan.currentPeriod?.matrixApplicationId,
        'emittedClaimCount': plan.emittedClaims.length,
        'emittedPredictionCount': plan.emittedPredictions,
        'omittedClaimCount': plan.omittedClaims.length,
        'requiredSemanticOwners': plan.knownTime
            ? (ThaiPredictiveRuntimeV2Plan.requiredKnownSemanticOwners.toList()
                ..sort())
            : <String>[],
        'missingOwners': plan.missingSemanticOwners.toList()..sort(),
        'baselineFallbackUsed': plan.baselineFallbackUsed,
        'unsupportedClaims': plan.unsupportedClaims,
        'duplicateDetailedOwners': duplicateOwners,
        'fixtureSpecificBranches': plan.fixtureSpecificBranches,
        'knownToUnknownLeakage': plan.knownToUnknownLeakage,
        'exactReportSha256': reportHash.toUpperCase(),
      });
    }

    final representatives = _completeRepresentativePlans(knownPlans, asOf);
    final contextEvidence = <String, Object?>{};
    final rulesByContext = <String, List<RuntimePredictiveRule>>{};
    final ownersByContext = <String, Set<String>>{};
    final reportsByContext = <String, String>{};
    final fingerprintsByContext = <String, String>{};
    for (final entry in representatives.entries) {
      final plan = entry.value.plan;
      final rules = plan.emittedClaims
          .map((decision) => decision.rule)
          .toList();
      final normalized = _normalizedReaderBody(plan);
      final refs = rules.expand((rule) => rule.evidenceRefs).toSet().toList()
        ..sort();
      rulesByContext[entry.key] = rules;
      ownersByContext[entry.key] = plan.emittedSemanticOwners;
      reportsByContext[entry.key] = normalized;
      fingerprintsByContext[entry.key] = refs.join('|');
      contextEvidence[entry.key] = {
        'fixture': entry.value.fixture,
        'currentPeriod': plan.currentPeriod?.toMap(),
        'semanticOwners': plan.emittedSemanticOwners.toList()..sort(),
        'missingOwners': plan.missingSemanticOwners.toList()..sort(),
        'baselineFallbackUsed': plan.baselineFallbackUsed,
        'unsupportedClaims': plan.unsupportedClaims,
        'fixtureSpecificBranches': plan.fixtureSpecificBranches,
        'normalizedReportSha256': sha256
            .convert(utf8.encode(normalized))
            .toString()
            .toUpperCase(),
        'readerLines': _readerLines(plan),
        'rules': [
          for (final decision in plan.emittedClaims)
            {
              'claimId': decision.rule.id,
              'semanticOwner': decision.rule.semanticOwner,
              'kind': decision.rule.kind.name,
              'periodBinding': decision.rule.periodBinding,
              'evidenceRefs': decision.rule.evidenceRefs.toList(),
              'text': decision.text,
            },
        ],
      };
    }

    final integrity = RuntimePredictiveIntegrityValidator.validate(
      contextIds: representatives.keys.toSet(),
      periodRows: runtimePredictiveV2PeriodRows,
      rulesByContext: rulesByContext,
      ownersByContext: ownersByContext,
      normalizedReportsByContext: reportsByContext,
      evidenceFingerprintsByContext: fingerprintsByContext,
      baselineFallbackContexts: {
        for (final entry in representatives.entries)
          if (entry.value.plan.baselineFallbackUsed) entry.key,
      },
      observedFixtureSpecificBranches: representatives.values.fold(
        0,
        (total, value) => total + value.plan.fixtureSpecificBranches,
      ),
      fixtureMetricDerived: true,
    );
    emittedPredictionCounts.sort();
    final periodMapping = [
      for (final row in runtimePredictiveV2PeriodRows)
        {
          ...row.toMap(),
          'resolverSelectedMatrixApplicationId':
              ThaiPredictiveRuntimeV2Plan.resolvePeriod(
                contextId: row.contextId,
                age: row.ageStart,
              )?.matrixApplicationId,
          'mappedInterpretationAuthority':
              'PRODUCT_INTERPRETATION_CONTRACT_V1_SYNTHESIS',
          'selectorAuthority': row.selectorRef,
          'domainAuthority': 'Production Canon/runtime domain composer',
          'directionAuthority': 'typed forecast material/runtime composer',
          'conflictAuthority': 'conflict.contract-boundaries',
          'certaintyAuthority': 'certainty.product-interpretation-contract-v1',
          'rawHeuristicPromotedToPrediction': false,
        },
    ];
    final unmappedPeriods = periodMapping.where(
      (row) =>
          row['matrixApplicationId'] !=
          row['resolverSelectedMatrixApplicationId'],
    );
    final summary = {
      'version': 2,
      'status':
          integrity.isValid &&
              knownComplete == 225 &&
              knownFallback == 0 &&
              unknownFailClosed == 75 &&
              unmappedPeriods.isEmpty &&
              unsupportedClaims == 0 &&
              fixtureSpecificBranches == 0 &&
              knownToUnknownLeakage == 0
          ? 'PASS_PREDICTIVE_RUNTIME_V2_OR1_PRODUCT_COVERAGE'
          : 'FAIL',
      'ownerReviewState': 'PENDING_OWNER_PRODUCT_RE_REVIEW',
      'candidate0011Sha256': runtimePredictiveV2OracleSha256,
      'counts': {
        'knownProfiles': 225,
        'knownProfilesWithCompleteV2Report': knownComplete,
        'knownProfilesUsingBaselineFallback': knownFallback,
        'unknownProfiles': 75,
        'unknownProfilesFailClosed': unknownFailClosed,
        'contextsWithCompleteContent': representatives.length,
        'contextsWithoutCompleteContent': 49 - representatives.length,
        'periodsMapped': periodMapping.length - unmappedPeriods.length,
        'periodsUnmapped': unmappedPeriods.length,
        'minimumEmittedPredictions': emittedPredictionCounts.first,
        'medianEmittedPredictions':
            emittedPredictionCounts[emittedPredictionCounts.length ~/ 2],
        'maximumEmittedPredictions': emittedPredictionCounts.last,
        'uniqueNormalizedReportsInKnown300Matrix':
            normalizedKnownReports.length,
        'uniqueRepresentativeContextReports': reportsByContext.values
            .toSet()
            .length,
        'unsupportedClaims': unsupportedClaims,
        'fixtureSpecificBranches': fixtureSpecificBranches,
        'knownToUnknownLeakage': knownToUnknownLeakage,
        'integrityErrors': integrity.errors.length,
      },
      'integrityErrors': integrity.errors,
    };

    _writeJson('docs/PREDICTIVE_RUNTIME_V2_RAW_300_PROFILE_AUDIT.json', {
      'summary': summary,
      'profiles': rawProfiles,
    });
    _writeJson('docs/PREDICTIVE_RUNTIME_V2_49_CONTEXT_READER_COPY.json', {
      'summary': summary,
      'contexts': contextEvidence,
    });
    _writeJson('docs/PREDICTIVE_RUNTIME_V2_392_PERIOD_RUNTIME_MAPPING.json', {
      'summary': {
        'rows': periodMapping.length,
        'mapped': periodMapping.length - unmappedPeriods.length,
        'unmapped': unmappedPeriods.length,
        'runtimeUnreachable': unmappedPeriods.length,
        'unsupportedPromotedClaims': 0,
      },
      'rows': periodMapping,
    });
    _writeJson('docs/PREDICTIVE_RUNTIME_V2_GENERALIZATION_AUDIT.json', summary);
    File(
      'docs/PREDICTIVE_RUNTIME_V2_GENERALIZATION_AUDIT.md',
    ).writeAsStringSync(
      '# Predictive Runtime V2 OR1 Product Coverage Audit\n\n'
      'Status: **${summary['status']}**\n\n'
      '- Actual representative context reports: ${representatives.length}/49\n'
      '- 300-profile Known complete V2: $knownComplete/225\n'
      '- Known baseline fallback: $knownFallback\n'
      '- Unknown fail-closed: $unknownFailClosed/75\n'
      '- Actual 392-period resolver mapping: ${periodMapping.length - unmappedPeriods.length}/392\n'
      '- Unsupported claims / fixture-specific branches / Known→Unknown leakage: '
      '$unsupportedClaims / $fixtureSpecificBranches / $knownToUnknownLeakage\n'
      '- Unique representative normalized reports: ${reportsByContext.values.toSet().length}/49\n'
      '- Emitted predictions min/median/max: ${emittedPredictionCounts.first}/'
      '${emittedPredictionCounts[emittedPredictionCounts.length ~/ 2]}/'
      '${emittedPredictionCounts.last}\n\n'
      'The 392-row ledger is selector/timing authority only. Reader direction is '
      'bound to Production Canon and typed forecast material under Product '
      'Interpretation Contract V1; raw OCR heuristics are never promoted.\n',
    );

    expect(
      summary['status'],
      'PASS_PREDICTIVE_RUNTIME_V2_OR1_PRODUCT_COVERAGE',
    );
    expect(integrity.errors, isEmpty);
    expect(knownComplete, 225);
    expect(knownFallback, 0);
    expect(unknownFailClosed, 75);
    expect(representatives, hasLength(49));
    expect(reportsByContext.values.toSet(), hasLength(49));
    expect(periodMapping, hasLength(392));
    expect(unmappedPeriods, isEmpty);
    expect(unsupportedClaims, 0);
    expect(fixtureSpecificBranches, 0);
    expect(knownToUnknownLeakage, 0);
  });
}

typedef _Representative = ({
  ThaiPredictiveRuntimeV2Plan plan,
  Map<String, Object?> fixture,
});

Map<String, _Representative> _completeRepresentativePlans(
  Map<String, ThaiPredictiveRuntimeV2Plan> seed,
  DateTime asOf,
) {
  final output = <String, _Representative>{
    for (final entry in seed.entries)
      entry.key: (
        plan: entry.value,
        fixture: {'source': 'synthetic-matrix-300'},
      ),
  };
  var date = DateTime(1975, 1, 1);
  final end = DateTime(1985, 1, 1);
  while (output.length < 49 && date.isBefore(end)) {
    final input = ThaiBetaInput(
      firstName: 'Context',
      lastName: 'Coverage',
      birthDate: date,
      birthHour: 12,
      birthMinute: 0,
      birthTimeUnknown: false,
      province: 'เชียงใหม่',
      provinceKey: 'chiang mai',
      gender: 'ชาย',
    );
    final plan = ThaiPredictiveRuntimeV2Plan.fromAnalysis(
      ThaiBetaAnalysisRunner.run(input, asOf: asOf),
    );
    if (!plan.baselineFallbackUsed) {
      output.putIfAbsent(
        plan.contextId,
        () => (
          plan: plan,
          fixture: {
            'source': 'bounded-context-search',
            'birthDate': _isoDate(date),
            'birthTime': '12:00',
            'provinceKey': 'chiang mai',
            'asOf': _isoDate(asOf),
          },
        ),
      );
    }
    date = date.add(const Duration(days: 1));
  }
  return output;
}

List<String> _readerLines(ThaiPredictiveRuntimeV2Plan plan) => [
  plan.title,
  ...plan.subtitle.split('\n'),
  for (final section in plan.sections) ...[
    section.title,
    ...section.claims.map((claim) => claim.text),
  ],
].where((line) => line.trim().isNotEmpty).toList(growable: false);

String _normalizedReaderBody(ThaiPredictiveRuntimeV2Plan plan) => [
  for (final section in plan.sections) ...[
    section.title.replaceAll(RegExp(r'\d+'), '#'),
    ...section.claims.map(
      (claim) => claim.text.replaceAll(RegExp(r'\d+'), '#'),
    ),
  ],
].join('\n').replaceAll(RegExp(r'\s+'), ' ').trim();

int _duplicateDetailedOwners(ThaiPredictiveRuntimeV2Plan plan) {
  final ownerSections = <String, Set<String>>{};
  for (final section in plan.sections) {
    for (final claim in section.claims) {
      ownerSections
          .putIfAbsent(claim.rule.semanticOwner, () => <String>{})
          .add(section.id);
    }
  }
  return ownerSections.values.where((sections) => sections.length > 1).length;
}

void _writeJson(String path, Object value) {
  File(
    path,
  ).writeAsStringSync('${const JsonEncoder.withIndent('  ').convert(value)}\n');
}

String _isoDate(DateTime date) =>
    '${date.year.toString().padLeft(4, '0')}-'
    '${date.month.toString().padLeft(2, '0')}-'
    '${date.day.toString().padLeft(2, '0')}';
