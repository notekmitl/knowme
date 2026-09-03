import 'dart:convert';
import 'dart:io';

import 'package:crypto/crypto.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:knowme/features/thai_beta/application/narrative/predictive_runtime_v2.dart';
import 'package:knowme/features/thai_beta/application/thai_beta_analysis.dart';
import 'package:knowme/features/thai_beta/domain/thai_beta_input.dart';

import '../validation/thai_beta/synthetic_audit/thai_beta_synthetic_matrix_300.dart';

void main() {
  test('writes and validates PR115 OR2 generalized predictive evidence', () {
    final asOf = DateTime(2026, 8, 29);
    final rawProfiles = <Map<String, Object?>>[];
    final knownPlans = <String, ThaiPredictiveRuntimeV2Plan>{};
    final contentCounters = _emptyContentCounters();
    var knownComplete = 0;
    var knownFallback = 0;
    var unknownFailClosed = 0;
    var unsupportedClaims = 0;
    var ownerAcceptedGoldenOverrideApplied = 0;
    var unexpectedFixtureSpecificBranches = 0;
    var fixtureReferenceLeakage = 0;
    var evidenceBindingMismatches = 0;
    var knownToUnknownLeakage = 0;
    final emittedPredictionCounts = <int>[];

    for (final fixture in ThaiBetaSyntheticMatrix.build()) {
      final analysis = ThaiBetaAnalysisRunner.run(fixture.input, asOf: asOf);
      final plan = ThaiPredictiveRuntimeV2Plan.fromAnalysis(analysis);
      final normalized = _normalizedReaderBody(plan);
      final reportHash = sha256.convert(utf8.encode(normalized)).toString();
      final profileAudit = _auditPlanContent(plan);
      _mergeCounters(contentCounters, profileAudit);
      if (plan.knownTime) {
        knownPlans.putIfAbsent(plan.contextId, () => plan);
        emittedPredictionCounts.add(plan.emittedPredictions);
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
      ownerAcceptedGoldenOverrideApplied +=
          plan.ownerAcceptedGoldenOverrideApplied;
      unexpectedFixtureSpecificBranches +=
          plan.unexpectedFixtureSpecificBranches;
      fixtureReferenceLeakage += plan.fixtureReferenceLeakage;
      evidenceBindingMismatches += plan.evidenceBindingMismatches;
      knownToUnknownLeakage += plan.knownToUnknownLeakage;
      rawProfiles.add({
        'profileId': fixture.id,
        'birthTimeMode': plan.knownTime ? 'Known' : 'Unknown',
        'contextId': plan.contextId,
        'currentPeriod': plan.currentPeriod?.matrixApplicationId,
        'generationPath': plan.generationPath,
        'emittedClaimCount': plan.emittedClaims.length,
        'emittedPredictionCount': plan.emittedPredictions,
        'omittedClaimCount': plan.omittedClaims.length,
        'missingOwners': plan.missingSemanticOwners.toList()..sort(),
        'baselineFallbackUsed': plan.baselineFallbackUsed,
        'unsupportedClaims': plan.unsupportedClaims,
        'ownerAcceptedGoldenOverrideApplied':
            plan.ownerAcceptedGoldenOverrideApplied,
        'unexpectedFixtureSpecificBranches':
            plan.unexpectedFixtureSpecificBranches,
        'fixtureReferenceLeakage': plan.fixtureReferenceLeakage,
        'evidenceBindingMismatches': plan.evidenceBindingMismatches,
        'knownToUnknownLeakage': plan.knownToUnknownLeakage,
        'contentQualityCounters': profileAudit,
        'exactReportSha256': reportHash.toUpperCase(),
      });
    }

    final representatives = _completeRepresentativePlans(knownPlans, asOf);
    final contextEvidence = <String, Object?>{};
    final claimBindings = <Map<String, Object?>>[];
    final humanReview = <Map<String, Object?>>[];
    final rulesByContext = <String, List<RuntimePredictiveRule>>{};
    final ownersByContext = <String, Set<String>>{};
    final reportsByContext = <String, String>{};
    final fingerprintsByContext = <String, String>{};
    final reuse = <String, Map<String, _ReuseRecord>>{};
    final representativeBindingErrors = <String>[];

    for (final entry in representatives.entries) {
      final plan = entry.value.plan;
      final rules = plan.emittedClaims
          .map((decision) => decision.rule)
          .toList(growable: false);
      final normalized = _normalizedReaderBody(plan);
      final refs = rules.expand((rule) => rule.evidenceRefs).toSet().toList()
        ..sort();
      final quality = _auditPlanContent(plan);
      representativeBindingErrors.addAll(
        RuntimePredictiveClaimBindingValidator.validate(plan),
      );
      _mergeCounters(contentCounters, quality);
      rulesByContext[entry.key] = rules;
      ownersByContext[entry.key] = plan.emittedSemanticOwners;
      reportsByContext[entry.key] = normalized;
      fingerprintsByContext[entry.key] = refs.join('|');
      for (final decision in plan.emittedClaims) {
        final binding = Map<String, Object?>.from(
          decision.toMap()['binding']! as Map,
        );
        claimBindings.add({
          'contextId': entry.key,
          'claimId': decision.rule.id,
          'kind': decision.rule.kind.name,
          ...binding,
        });
        final normalizedParagraph = _normalizeParagraph(decision.text);
        final record = reuse
            .putIfAbsent(
              decision.rule.semanticOwner,
              () => <String, _ReuseRecord>{},
            )
            .putIfAbsent(
              normalizedParagraph,
              () => _ReuseRecord(text: decision.text),
            );
        record.count++;
        record.contexts.add(entry.key);
        record.evidenceFingerprints.add(decision.rule.materialFingerprint);
        record.evidenceKeys.add(decision.rule.evidenceKey);
      }
      final owners = plan.emittedClaims
          .map((claim) => claim.rule.semanticOwner)
          .toList(growable: false);
      final orderOk = _ownersInRequiredOrder(owners);
      humanReview.add({
        'contextId': entry.key,
        'fixture': entry.value.fixture,
        'round1SequenceReview': {
          'status':
              orderOk &&
                  quality['exact_cross_section_duplicates'] == 0 &&
                  quality['current_to_12_month_duplicate'] == 0
              ? 'PASS'
              : 'FAIL',
          'owners': owners,
          'exactCrossSectionDuplicates':
              quality['exact_cross_section_duplicates'],
          'currentTo12MonthDuplicate': quality['current_to_12_month_duplicate'],
        },
        'round2VoiceReview': {
          'status': quality.values.every((value) => value == 0)
              ? 'PASS'
              : 'FAIL',
          'counters': quality,
        },
        'readerLines': _readerLines(plan),
      });
      contextEvidence[entry.key] = {
        'fixture': entry.value.fixture,
        'currentPeriod': plan.currentPeriod?.toMap(),
        'semanticOwners': plan.emittedSemanticOwners.toList()..sort(),
        'missingOwners': plan.missingSemanticOwners.toList()..sort(),
        'generationPath': plan.generationPath,
        'ownerAcceptedGoldenOverrideApplied':
            plan.ownerAcceptedGoldenOverrideApplied,
        'unexpectedFixtureSpecificBranches':
            plan.unexpectedFixtureSpecificBranches,
        'fixtureReferenceLeakage': plan.fixtureReferenceLeakage,
        'evidenceBindingMismatches': plan.evidenceBindingMismatches,
        'contentQualityCounters': quality,
        'normalizedReportSha256': sha256
            .convert(utf8.encode(normalized))
            .toString()
            .toUpperCase(),
        'readerLines': _readerLines(plan),
        'claims': plan.emittedClaims
            .map((decision) => decision.toMap())
            .toList(),
      };
    }

    final reuseAudit = _buildReuseAudit(reuse);
    final missingBindings = representativeBindingErrors
        .where((error) => error.startsWith('MISSING_BINDING:'))
        .length;
    final unboundManualReaderText = representativeBindingErrors
        .where((error) => error.startsWith('UNBOUND_MANUAL_READER_TEXT:'))
        .length;
    final representativeBindingMismatches =
        representativeBindingErrors.length -
        missingBindings -
        unboundManualReaderText;
    final evidenceMismatchedReuse = reuseAudit.values.fold<int>(
      0,
      (total, owner) => total + (owner['mismatchedEvidenceReuseCount']! as int),
    );
    contentCounters['evidence_mismatched_reuse'] = evidenceMismatchedReuse;

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
        (total, value) => total + value.plan.unexpectedFixtureSpecificBranches,
      ),
      fixtureMetricDerived: true,
    );

    final goldenComparison = _goldenNeighborComparison(asOf);
    final periodMapping = [
      for (final row in runtimePredictiveV2PeriodRows)
        {
          ...row.toMap(),
          'resolverSelectedMatrixApplicationId':
              ThaiPredictiveRuntimeV2Plan.resolvePeriod(
                contextId: row.contextId,
                age: row.ageStart,
              )?.matrixApplicationId,
          'selectorAuthority': row.selectorRef,
          'rawHeuristicPromotedToPrediction': false,
        },
    ];
    final unmappedPeriods = periodMapping.where(
      (row) =>
          row['matrixApplicationId'] !=
          row['resolverSelectedMatrixApplicationId'],
    );
    emittedPredictionCounts.sort();
    final allContentCountersZero = contentCounters.values.every(
      (value) => value == 0,
    );
    final allHumanReviewsPass = humanReview.every(
      (review) =>
          (review['round1SequenceReview']! as Map)['status'] == 'PASS' &&
          (review['round2VoiceReview']! as Map)['status'] == 'PASS',
    );
    final summary = {
      'version': 3,
      'status':
          integrity.isValid &&
              knownComplete == 225 &&
              knownFallback == 0 &&
              unknownFailClosed == 75 &&
              representatives.length == 49 &&
              unmappedPeriods.isEmpty &&
              unsupportedClaims == 0 &&
              ownerAcceptedGoldenOverrideApplied == 0 &&
              unexpectedFixtureSpecificBranches == 0 &&
              fixtureReferenceLeakage == 0 &&
              evidenceBindingMismatches == 0 &&
              knownToUnknownLeakage == 0 &&
              allContentCountersZero &&
              allHumanReviewsPass &&
              goldenComparison['status'] == 'PASS'
          ? 'PASS_PREDICTIVE_RUNTIME_V2_OR2_EDITORIAL_AND_EVIDENCE'
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
        'periodsMapped': periodMapping.length - unmappedPeriods.length,
        'periodsUnmapped': unmappedPeriods.length,
        'minimumEmittedPredictions': emittedPredictionCounts.first,
        'medianEmittedPredictions':
            emittedPredictionCounts[emittedPredictionCounts.length ~/ 2],
        'maximumEmittedPredictions': emittedPredictionCounts.last,
        'unsupportedClaims': unsupportedClaims,
        'ownerAcceptedGoldenOverrideAppliedIn300Profiles':
            ownerAcceptedGoldenOverrideApplied,
        'unexpectedFixtureSpecificBranches': unexpectedFixtureSpecificBranches,
        'fixtureReferenceLeakage': fixtureReferenceLeakage,
        'evidenceBindingMismatches': evidenceBindingMismatches,
        'knownToUnknownLeakage': knownToUnknownLeakage,
        'claimLevelBindings': claimBindings.length,
        'integrityErrors': integrity.errors.length,
      },
      'contentQualityCounters': contentCounters,
      'humanReviewContexts': humanReview.length,
      'humanReviewFailures': humanReview
          .where(
            (review) =>
                (review['round1SequenceReview']! as Map)['status'] != 'PASS' ||
                (review['round2VoiceReview']! as Map)['status'] != 'PASS',
          )
          .length,
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
    _writeJson('docs/PREDICTIVE_RUNTIME_V2_CLAIM_LEVEL_BINDINGS.json', {
      'summary': {
        'entries': claimBindings.length,
        'missing': missingBindings,
        'mismatch': representativeBindingMismatches,
        'manualAssertionWithoutBinding': unboundManualReaderText,
        'fixtureReferenceLeakage': fixtureReferenceLeakage,
      },
      'bindings': claimBindings,
    });
    _writeJson('docs/PREDICTIVE_RUNTIME_V2_CONTENT_QUALITY_AUDIT.json', {
      'summary': summary,
      'counters': contentCounters,
      'contexts': humanReview,
    });
    _writeJson('docs/PREDICTIVE_RUNTIME_V2_OWNER_REUSE_AUDIT.json', {
      'summary': {
        'semanticOwners': reuseAudit.length,
        'evidenceMismatchedReuse': evidenceMismatchedReuse,
      },
      'owners': reuseAudit,
    });
    _writeJson(
      'docs/PREDICTIVE_RUNTIME_V2_GOLDEN_NEIGHBOR_COMPARISON.json',
      goldenComparison,
    );
    _writeJson('docs/PREDICTIVE_RUNTIME_V2_GENERALIZATION_AUDIT.json', summary);
    File(
      'docs/PREDICTIVE_RUNTIME_V2_HUMAN_REVIEW_49_CONTEXTS.md',
    ).writeAsStringSync(_humanReviewMarkdown(humanReview));
    File(
      'docs/PREDICTIVE_RUNTIME_V2_GENERALIZATION_AUDIT.md',
    ).writeAsStringSync(_summaryMarkdown(summary));

    expect(
      summary['status'],
      'PASS_PREDICTIVE_RUNTIME_V2_OR2_EDITORIAL_AND_EVIDENCE',
    );
    expect(integrity.errors, isEmpty);
    expect(knownComplete, 225);
    expect(knownFallback, 0);
    expect(unknownFailClosed, 75);
    expect(representatives, hasLength(49));
    expect(periodMapping, hasLength(392));
    expect(unmappedPeriods, isEmpty);
    expect(contentCounters.values, everyElement(0));
    expect(evidenceBindingMismatches, 0);
    expect(representativeBindingErrors, isEmpty);
    expect(unexpectedFixtureSpecificBranches, 0);
    expect(fixtureReferenceLeakage, 0);
    expect(knownToUnknownLeakage, 0);
    expect(goldenComparison['status'], 'PASS');
  });
}

typedef _Representative = ({
  ThaiPredictiveRuntimeV2Plan plan,
  Map<String, Object?> fixture,
});

class _ReuseRecord {
  _ReuseRecord({required this.text});

  final String text;
  int count = 0;
  final Set<String> contexts = {};
  final Set<String> evidenceFingerprints = {};
  final Set<String> evidenceKeys = {};
}

Map<String, int> _emptyContentCounters() => {
  'hedge_hits_in_prediction': 0,
  'personality_hits_in_prediction': 0,
  'past_reflection_or_question_hits': 0,
  'advice_leakage_into_prediction': 0,
  'methodology_leakage': 0,
  'stale_phrase_hits': 0,
  'exact_cross_section_duplicates': 0,
  'near_semantic_cross_section_duplicates': 0,
  'current_to_12_month_duplicate': 0,
  'evidence_mismatched_reuse': 0,
  'fixture_reference_leakage': 0,
  'unsupported_claims': 0,
  'known_to_unknown_leakage': 0,
};

Map<String, int> _auditPlanContent(ThaiPredictiveRuntimeV2Plan plan) {
  final counters = _emptyContentCounters();
  counters['fixture_reference_leakage'] = plan.fixtureReferenceLeakage;
  counters['unsupported_claims'] = plan.unsupportedClaims;
  counters['known_to_unknown_leakage'] = plan.knownToUnknownLeakage;
  final predictions = plan.emittedClaims
      .where((claim) => claim.rule.kind == RuntimePredictiveKind.prediction)
      .toList(growable: false);
  for (final claim in predictions) {
    final text = claim.text;
    counters['hedge_hits_in_prediction'] =
        counters['hedge_hits_in_prediction']! +
        _countPhrases(text, const [
          'มีแนวโน้ม',
          'อาจ',
          'มีโอกาส',
          'น่าจะ',
          'เป็นไปได้ว่า',
        ]);
    counters['personality_hits_in_prediction'] =
        counters['personality_hits_in_prediction']! +
        _countPhrases(text, const ['คุณคาดหวัง', 'คุณมัก', 'นิสัย', 'เป็นคน']);
    if (claim.rule.semanticOwner == 'past' &&
        (text.contains('?') ||
            text.contains('ลอง') ||
            text.contains('ทบทวน') ||
            text.contains('บทเรียนติดตัว'))) {
      counters['past_reflection_or_question_hits'] =
          counters['past_reflection_or_question_hits']! + 1;
    }
    for (final sentence in text.split(RegExp(r'[.!?]\s*'))) {
      if (RegExp(
        r'^(หาก|ถ้า|ควร|ให้|ลอง|ทบทวน)(\s|คุณ)',
      ).hasMatch(sentence.trim())) {
        counters['advice_leakage_into_prediction'] =
            counters['advice_leakage_into_prediction']! + 1;
      }
    }
    counters['methodology_leakage'] =
        counters['methodology_leakage']! +
        _countPhrases(text, const [
          'มหาภูต',
          'ทักษา',
          'selector',
          'evidence',
          'ดาว',
          'เรือน',
        ]);
    counters['stale_phrase_hits'] =
        counters['stale_phrase_hits']! +
        _countPhrases(text, const [
          'ช่วงนี้ งานมีแนวโน้ม',
          'ช่วงนี้ รายได้มีโอกาส',
          'คุณคาดหวังเงียบ ๆ',
          'ถ้ารักษาเวลานอน',
          'ให้ประเมินโอกาสจากหลักฐาน',
          'งานและหน้าที่บังคับให้คุณ',
        ]);
  }
  for (var left = 0; left < predictions.length; left++) {
    for (var right = left + 1; right < predictions.length; right++) {
      if (predictions[left].rule.semanticOwner ==
          predictions[right].rule.semanticOwner) {
        continue;
      }
      final a = _normalizeParagraph(predictions[left].text);
      final b = _normalizeParagraph(predictions[right].text);
      if (a == b) {
        counters['exact_cross_section_duplicates'] =
            counters['exact_cross_section_duplicates']! + 1;
      } else if (_trigramSimilarity(a, b) >= 0.82) {
        counters['near_semantic_cross_section_duplicates'] =
            counters['near_semantic_cross_section_duplicates']! + 1;
      }
    }
  }
  final current = plan.claimForOwner('current');
  final horizon = plan.claimForOwner('rolling12');
  if (current != null &&
      horizon != null &&
      (_normalizeParagraph(current.text) == _normalizeParagraph(horizon.text) ||
          _trigramSimilarity(current.text, horizon.text) >= 0.72)) {
    counters['current_to_12_month_duplicate'] = 1;
  }
  return counters;
}

void _mergeCounters(Map<String, int> target, Map<String, int> source) {
  for (final entry in source.entries) {
    target[entry.key] = target[entry.key]! + entry.value;
  }
}

int _countPhrases(String text, List<String> phrases) =>
    phrases.where(text.contains).length;

Map<String, Map<String, Object?>> _buildReuseAudit(
  Map<String, Map<String, _ReuseRecord>> reuse,
) {
  final result = <String, Map<String, Object?>>{};
  for (final ownerEntry in reuse.entries) {
    final rows = ownerEntry.value.values.toList()
      ..sort((a, b) => b.count.compareTo(a.count));
    final mismatched = rows
        .where((row) => row.evidenceFingerprints.length > 1)
        .toList(growable: false);
    result[ownerEntry.key] = {
      'distinctParagraphCount': rows.length,
      'mostReusedParagraph': rows.isEmpty ? '' : rows.first.text,
      'reuseCount': rows.isEmpty ? 0 : rows.first.count,
      'contexts': rows.isEmpty
          ? <String>[]
          : (rows.first.contexts.toList()..sort()),
      'evidenceFingerprints': rows.isEmpty
          ? <String>[]
          : (rows.first.evidenceFingerprints.toList()..sort()),
      'mismatchedEvidenceReuseCount': mismatched.length,
      'mismatchedEvidenceReuse': [
        for (final row in mismatched)
          {
            'text': row.text,
            'contexts': row.contexts.toList()..sort(),
            'evidenceFingerprints': row.evidenceFingerprints.toList()..sort(),
            'evidenceKeys': row.evidenceKeys.toList()..sort(),
          },
      ],
      'paragraphs': [
        for (final row in rows)
          {
            'text': row.text,
            'reuseCount': row.count,
            'contexts': row.contexts.toList()..sort(),
            'evidenceFingerprints': row.evidenceFingerprints.toList()..sort(),
            'evidenceKeys': row.evidenceKeys.toList()..sort(),
          },
      ],
    };
  }
  return result;
}

Map<String, Object?> _goldenNeighborComparison(DateTime asOf) {
  ThaiPredictiveRuntimeV2Plan plan({
    required int minute,
    required String gender,
    bool known = true,
  }) => ThaiPredictiveRuntimeV2Plan.fromAnalysis(
    ThaiBetaAnalysisRunner.run(
      ThaiBetaInput(
        firstName: 'OR2',
        lastName: 'Comparison',
        birthDate: DateTime(1982, 6, 6),
        birthHour: known ? 0 : null,
        birthMinute: known ? minute : 0,
        birthTimeUnknown: !known,
        province: 'เชียงใหม่',
        provinceKey: 'chiang mai',
        gender: gender,
      ),
      asOf: asOf,
    ),
  );

  final exact = plan(minute: 3, gender: 'ชาย');
  final minute35 = plan(minute: 35, gender: 'ชาย');
  final neighbor = plan(minute: 3, gender: 'หญิง');
  final unknown = plan(minute: 0, gender: 'ชาย', known: false);
  Map<String, Object?> item(ThaiPredictiveRuntimeV2Plan value) => {
    'contextId': value.contextId,
    'currentPeriod': value.currentPeriod?.matrixApplicationId,
    'generationPath': value.generationPath,
    'ownerAcceptedGoldenOverrideApplied':
        value.ownerAcceptedGoldenOverrideApplied,
    'unexpectedFixtureSpecificBranches':
        value.unexpectedFixtureSpecificBranches,
    'fixtureReferenceLeakage': value.fixtureReferenceLeakage,
    'evidenceBindingMismatches': value.evidenceBindingMismatches,
    'readerLines': _readerLines(value),
  };

  final pass =
      exact.ownerAcceptedGoldenOverrideApplied == 1 &&
      exact.emittedPredictions == 22 &&
      minute35.ownerAcceptedGoldenOverrideApplied == 0 &&
      neighbor.ownerAcceptedGoldenOverrideApplied == 0 &&
      minute35.fixtureReferenceLeakage == 0 &&
      neighbor.fixtureReferenceLeakage == 0 &&
      unknown.emittedClaims.isEmpty;
  return {
    'status': pass ? 'PASS' : 'FAIL',
    'candidate0011Sha256': runtimePredictiveV2OracleSha256,
    'exactTarget00_03': item(exact),
    'generalized00_35': item(minute35),
    'sameContextPeriodNeighbor': item(neighbor),
    'unknownFailClosed': item(unknown),
  };
}

bool _ownersInRequiredOrder(List<String> owners) {
  const required = [
    'past',
    'current',
    'work',
    'finance',
    'relationship',
    'health',
    'rolling12',
    'next',
  ];
  var previous = -1;
  for (final owner in required) {
    final index = owners.indexOf(owner);
    if (index <= previous) return false;
    previous = index;
  }
  return true;
}

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

String _normalizeParagraph(String value) => value
    .replaceAll(RegExp(r'\s+'), '')
    .replaceAll(RegExp(r'[\p{P}\p{S}]', unicode: true), '')
    .toLowerCase();

double _trigramSimilarity(String left, String right) {
  Set<String> grams(String value) {
    final normalized = _normalizeParagraph(value);
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

String _humanReviewMarkdown(List<Map<String, Object?>> reviews) {
  final buffer = StringBuffer(
    '# Predictive Runtime V2 OR2 Human Review - 49 Contexts\n\n'
    'Each context records two complete reader-copy passes: sequence/duplication '
    'and conversational predictive voice/semantic ownership.\n\n',
  );
  for (final review in reviews) {
    final round1 = review['round1SequenceReview']! as Map;
    final round2 = review['round2VoiceReview']! as Map;
    buffer
      ..writeln('## ${review['contextId']}')
      ..writeln()
      ..writeln('- Round 1 sequence/duplication: ${round1['status']}')
      ..writeln('- Round 2 voice/ownership: ${round2['status']}')
      ..writeln('- Full reader copy:')
      ..writeln();
    for (final line in review['readerLines']! as List) {
      buffer.writeln('  - $line');
    }
    buffer.writeln();
  }
  return buffer.toString();
}

String _summaryMarkdown(Map<String, Object?> summary) {
  final counts = summary['counts']! as Map;
  final quality = summary['contentQualityCounters']! as Map;
  return '# Predictive Runtime V2 OR2 Editorial and Evidence Audit\n\n'
      'Status: **${summary['status']}**\n\n'
      '- Actual representative context reports: ${counts['contextsWithCompleteContent']}/49\n'
      '- 300-profile Known complete V2: ${counts['knownProfilesWithCompleteV2Report']}/225\n'
      '- Unknown fail-closed: ${counts['unknownProfilesFailClosed']}/75\n'
      '- Actual period resolver mapping: ${counts['periodsMapped']}/392\n'
      '- Claim-level bindings: ${counts['claimLevelBindings']}\n'
      '- Evidence binding mismatches: ${counts['evidenceBindingMismatches']}\n'
      '- Unexpected fixture branches / fixture leakage: '
      '${counts['unexpectedFixtureSpecificBranches']} / ${counts['fixtureReferenceLeakage']}\n'
      '- Human content reviews: ${summary['humanReviewContexts']}/49; failures ${summary['humanReviewFailures']}\n'
      '- Content-quality counters: ${jsonEncode(quality)}\n\n'
      'Candidate 0011 remains the exact accepted 00:03 oracle. Every other '
      'Known profile uses typed material plus Generalized Predictive Editorial '
      'Contract V2; Unknown remains fail-closed.\n';
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
