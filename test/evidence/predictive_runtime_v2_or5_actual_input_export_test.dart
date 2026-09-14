// OR5 observation only: never calls a content builder or changes the runtime.
import 'dart:convert';
import 'dart:io';

import 'package:crypto/crypto.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:knowme/features/astrology/thai/foundation/models/thai_astrology_profile.dart';
import 'package:knowme/features/astrology/thai/mirror/runtime/thai_mirror_pipeline_result.dart';
import 'package:knowme/features/astrology/thai/mirror/presentation/models/thai_mirror_consumer_view_state.dart';
import 'package:knowme/features/birth_normalization/application/adapters/thai_birth_adapter.dart';
import 'package:knowme/features/birth_normalization/application/adapters/thai_engine_adapter.dart';
import 'package:knowme/features/birth_normalization/application/sunrise_calculator.dart';
import 'package:knowme/features/birth_normalization/domain/normalized_birth.dart';
import 'package:knowme/features/astrology/thai/mirror/runtime/thai_mirror_pipeline.dart';
import 'package:knowme/features/astrology/thai/mirror/presentation/thai_mirror_consumer_presenter.dart';
import 'package:knowme/features/thai_beta/domain/thai_beta_normalized_snapshot.dart';
import 'package:knowme/features/thai_beta/domain/thai_beta_report_snapshot.dart';
import 'package:knowme/features/thai_beta/domain/thai_beta_report_hash.dart';
import 'package:knowme/features/thai_beta/application/thai_beta_report_export_document.dart';
import 'package:knowme/features/astrology/thai/knowledge/canon/integration/thai_canon_evidence_repository.dart';
import 'package:knowme/features/astrology/thai/mirror/presentation/prediction/prediction_section_model.dart';
import 'package:knowme/features/thai_beta/application/narrative/predictive_runtime_v2.dart';
import 'package:knowme/features/thai_beta/application/thai_beta_analysis.dart';
import 'package:knowme/features/thai_beta/domain/thai_beta_input.dart';

import '../validation/thai_beta/synthetic_audit/thai_beta_synthetic_matrix_300.dart';

const copyClassification = 'UNTRUSTED_OR2_RUNTIME_COPY — NOT CONTENT AUTHORITY';
const rawOrigin =
    'ThaiBetaAnalysisRunner.run.consumerViewState.futurePrediction BEFORE ThaiPredictiveRuntimeV2Plan.fromAnalysis';
typedef Json = Map<String, dynamic>;
String digest(Object? value) =>
    sha256.convert(utf8.encode(jsonEncode(value))).toString();
Json clone(Json value) => jsonDecode(jsonEncode(value)) as Json;

ThaiBetaInput fixture(int? minute) => ThaiBetaInput(
  firstName: 'Acceptance',
  lastName: 'Fixture',
  birthDate: DateTime(1982, 6, 6),
  birthHour: minute == null ? null : 0,
  birthMinute: minute ?? 0,
  birthTimeUnknown: minute == null,
  province: 'เชียงใหม่',
  provinceKey: 'chiang mai',
  gender: 'ชาย',
);

Json materialMap(ForecastMaterialFingerprint m) => {
  'horizon': m.horizon.name,
  'domain': m.domain.name,
  'band': m.band.name,
  'riskDomain': m.riskDomain?.name,
  'consumerRiskDomain': m.consumerRiskDomain.name,
  'evidenceAvailability': m.evidenceAvailability.name,
  'spansTransition': m.spansTransition,
  'timeDependent': m.timeDependent,
  'evidenceKey': m.evidenceKey,
  'sourceOwnership': m.sourceOwnership,
  'materialFingerprint': m.serialize(),
  'authorityClass': 'ENGINE_COMPUTED_TYPED_MATERIAL',
};

Json? rawMap(PredictionSectionModel? p) => p == null
    ? null
    : {
        'copyClassification': copyClassification,
        'sectionTitle': p.sectionTitle,
        'sectionIntro': p.sectionIntro,
        'transitionLine': p.transitionLine,
        'closingAdvice': p.closingAdvice,
        'detailedSectionIntro': p.detailedSectionIntro,
        'detailedClosingAdvice': p.detailedClosingAdvice,
        'isEmpty': p.isEmpty,
        'windows': [
          for (final w in p.windows)
            {
              'windowLabel': w.windowLabel,
              'timeframeLabel': w.timeframeLabel,
              'summary': w.summary,
              'topOpportunity': w.topOpportunity,
              'topRisk': w.topRisk,
              'confidenceLabel': w.confidenceLabel,
              'confidenceLevel': w.confidenceLevel,
              'why': w.why,
              'whyNow': w.whyNow,
              'whatToWatch': w.whatToWatch,
              'evidenceDetail': w.evidenceDetail,
              'domains': [
                for (final d in w.domains)
                  {
                    'title': d.title,
                    'body': d.body,
                    'caution': d.caution,
                    'claim': d.claim,
                    'risk': d.risk,
                    'decisionImpact': d.decisionImpact,
                    'preparationAction': d.preparationAction,
                    'uncertaintyDisclosure': d.uncertaintyDisclosure,
                    'material': d.material == null
                        ? null
                        : materialMap(d.material!),
                    'materialFingerprint': d.materialFingerprint,
                    'decisionPlan': d.decisionPlan == null
                        ? null
                        : {
                            'horizon': d.decisionPlan!.horizon.name,
                            'domain': d.decisionPlan!.domain.name,
                            'band': d.decisionPlan!.band.name,
                            'riskDomain': d.decisionPlan!.riskDomain?.name,
                            'consumerRiskDomain':
                                d.decisionPlan!.consumerRiskDomain.name,
                            'intent': d.decisionPlan!.intent.name,
                            'evidenceAvailability':
                                d.decisionPlan!.evidenceAvailability.name,
                            'spansTransition': d.decisionPlan!.spansTransition,
                          },
                  },
              ],
            },
        ],
      };

Json extract(ThaiBetaInput input, DateTime asOf) {
  final a = ThaiBetaAnalysisRunner.run(input, startedAt: asOf, asOf: asOf);
  expect(a.isSuccess, isTrue, reason: a.errorMessage);
  // Serialize immediately, not from plan and not from stored golden evidence.
  final raw = rawMap(a.consumerViewState!.futurePrediction);
  final rawHashBeforePlan = digest(raw);
  final materials = <Json>[
    for (final w
        in a.consumerViewState!.futurePrediction?.windows ??
            <PredictionWindowCardModel>[])
      for (final d in w.domains)
        if (d.material != null) materialMap(d.material!),
  ];
  final plan = ThaiPredictiveRuntimeV2Plan.fromAnalysis(a);
  expect(
    digest(rawMap(a.consumerViewState!.futurePrediction)),
    rawHashBeforePlan,
  );
  final p = a.profile!;
  final birth = a.pipelineResult!.birthData!;
  final rows =
      runtimePredictiveV2PeriodRows
          .where((r) => r.contextId == plan.contextId)
          .toList()
        ..sort((a, b) => a.ageStart.compareTo(b.ageStart));
  final age = plan.currentAge;
  final result = <String, dynamic>{
    'schemaVersion': 1,
    'input': input.toMap(),
    'asOf': a.asOf.toIso8601String(),
    'timezoneContract': {
      'id': a.normalizedSnapshot!.timeZoneId,
      'utcOffsetHours': a.normalizedSnapshot!.utcOffsetHours,
      'meaning': 'Bangkok civil calendar components, not a UTC instant',
    },
    'origin': rawOrigin,
    'canonLoadedAtomicCount':
        ThaiCanonEvidenceRepository.cachedOrNull!.atomicCount,
    'normalized': a.normalizedSnapshot!.toMap(),
    'canonical': {
      'hasBirthTime': p.hasBirthTime,
      'lagnaKey': p.lagnaKey,
      'lagnaLordKey': p.lagnaLordKey,
      'siderealAscendantDeg': p.siderealAscendantDeg,
      'degreeWithinSign': p.siderealAscendantDeg == null
          ? null
          : p.siderealAscendantDeg! % 30,
      'mahabhutaPositionKeys': p.mahabhutaPositionKeys,
      'myanmarKeys': p.myanmarKeys,
      'warnings': [for (final w in p.warnings) w.code],
      'zodiac': p.zodiac,
      'ayanamsa': p.ayanamsa,
      'houseSystem': p.houseSystem,
    },
    'birthDataInternal': {
      'localDateTime': birth.localDateTime.toIso8601String(),
      'hasBirthTime': birth.hasBirthTime,
      'astrologicalDate': birth.astrologicalDate.toIso8601String(),
      'thaiWeekdayNumber': birth.thaiWeekdayNumber,
      'qualification': input.hasBirthTime
          ? 'time-bound normalized day'
          : 'date-only internal fallback; not a time-bound Thai-day assertion',
    },
    'contextId': plan.contextId,
    'currentAge': age,
    'periodRows': [for (final r in rows) r.toMap()],
    'completedPeriods': [
      for (final r in rows)
        if (age != null && r.ageEnd < age) r.toMap(),
    ],
    'currentPeriod': plan.currentPeriod?.toMap(),
    'nextPeriods': [
      for (final r in rows)
        if (age != null && r.ageStart > age) r.toMap(),
    ],
    'rawFuturePrediction': raw,
    'rawFuturePredictionSha256': rawHashBeforePlan,
    'typedMaterials': materials,
    'plan': {
      'copyClassification': copyClassification,
      ...plan.toMap(),
      'decisionReferences': [
        for (final d in plan.decisions)
          {
            'claimId': d.rule.id,
            'selectorRefs': d.rule.selectorRefs,
            'domainRefs': d.rule.domainRefs,
            'directionRefs': d.rule.directionRefs,
            'timingRefs': d.rule.timingRefs,
            'conflictRefs': d.rule.conflictRefs,
            'certaintyRefs': d.rule.certaintyRefs,
            'sourceComponents': d.rule.sourceComponents,
          },
      ],
    },
  };
  result['extractionSha256'] = digest(result);
  return result;
}

// Recompute actual analysis for the requested input; a self-signed digest alone
// cannot validate relabelled evidence. Comparison includes every raw field.
List<String> validateAgainst(Json observed, Json independentlyExtracted) {
  final errors = <String>[];
  for (final key in independentlyExtracted.keys) {
    if (digest(observed[key]) != digest(independentlyExtracted[key])) {
      errors.add(key);
    }
  }
  for (final key in observed.keys) {
    if (!independentlyExtracted.containsKey(key)) errors.add('extra:$key');
  }
  return errors;
}

void writeEvidence(String name, Object data) {
  final dir = Directory(Platform.environment['OR5_OUTPUT_DIR'] ?? 'build/or5');
  dir.createSync(recursive: true);
  File(
    '${dir.path}/$name.json',
  ).writeAsStringSync('${const JsonEncoder.withIndent('  ').convert(data)}\n');
}

// Test-only boundary injection. Nothing is mocked downstream: recompute the
// real adapter, engine, presenter, snapshot and public export for each sentinel.
// Raw input is always the same Unknown input, never a Known input relabelled.
class SentinelAnalysis implements ThaiBetaAnalysis {
  SentinelAnalysis(this.base, int hour, int minute) {
    final n = base.normalizedBirth!;
    final context = ThaiBirthAdapter.build(
      localDateTime: DateTime(
        base.input.birthDate.year,
        base.input.birthDate.month,
        base.input.birthDate.day,
        hour,
        minute,
      ),
      sunrise: SunriseCalculation(
        localSunrise: n.sunrise,
        available: n.sunriseAvailable,
      ),
      location: n.location,
      timeZone: n.timeZone,
      hasBirthTime: false,
    );
    normalizedBirth = NormalizedBirth(
      raw: n.raw,
      location: n.location,
      timeZone: n.timeZone,
      calendar: n.calendar,
      sunrise: n.sunrise,
      sunriseAvailable: n.sunriseAvailable,
      thai: context,
      western: n.western,
      bazi: n.bazi,
      reasons: n.reasons,
    );
  }
  final ThaiBetaAnalysis base;
  @override
  final String? errorMessage = null;
  @override
  late final NormalizedBirth normalizedBirth;
  @override
  get input => base.input;
  @override
  get startedAt => base.startedAt;
  @override
  get asOf => base.asOf;
  @override
  get engineVersions => base.engineVersions;
  @override
  late final ThaiBetaNormalizedSnapshot normalizedSnapshot =
      ThaiBetaNormalizedSnapshot.fromNormalizedBirth(normalizedBirth);
  @override
  late final ThaiMirrorPipelineResult pipelineResult =
      ThaiMirrorPipeline.generate(
        ThaiEngineAdapter.fromNormalized(normalizedBirth),
        asOf: asOf,
      );
  @override
  late final ThaiAstrologyProfile profile = pipelineResult.profile!;
  @override
  late final ThaiMirrorConsumerViewState consumerViewState =
      ThaiMirrorConsumerPresenter.present(
        pipelineResult.mirrorResult!,
        lifePeriods: pipelineResult.lifePeriods,
        profile: profile,
        birthData: pipelineResult.birthData,
        canonIndex: ThaiCanonEvidenceRepository.cachedIndexOrNull,
        asOf: asOf,
      );
  @override
  late final Map<String, dynamic> reportSnapshot = ThaiBetaReportSnapshot.build(
    profile: profile,
    view: consumerViewState,
  );
  @override
  late final reportHash = ThaiBetaReportHash.of(reportSnapshot);
  @override
  bool get isSuccess => pipelineResult.isSuccess;
}

Json publicBoundary(ThaiBetaAnalysis a) {
  final document = ThaiBetaReportExportDocument.candidate(a);
  final plan = ThaiPredictiveRuntimeV2Plan.fromAnalysis(a);
  return {
    'copyClassification': copyClassification,
    'publicExportText': document.fullPlainText,
    'sectionPlainText': document.sectionPlainText,
    'sections': [
      for (final s in document.sections)
        {
          'id': s.id,
          'title': s.title,
          'paragraphs': s.paragraphs,
          'traceIds': s.traceIds,
        },
    ],
    'persistedReaderSnapshot': a.reportSnapshot!['report'],
    'omissionReason': plan.omissionReason,
    'decisions': [for (final d in plan.decisions) d.toMap()],
    'predictionClaims': plan.emittedPredictions,
  };
}

Json authorityBoundary(Json boundary) => {
  'copyClassification': boundary['copyClassification'],
  'omissionReason': boundary['omissionReason'],
  'predictionClaims': boundary['predictionClaims'],
  'decisions': [
    for (final rawDecision in boundary['decisions'] as List)
      authorityDecision(rawDecision as Json),
  ],
};

Json authorityDecision(Json decision) {
  final binding = decision['binding'] as Json;
  return {
    'claimId': decision['claimId'],
    'semanticOwner': decision['semanticOwner'],
    'kind': decision['kind'],
    'domain': decision['domain'],
    'periodBinding': decision['periodBinding'],
    'emitted': decision['emitted'],
    'reason': decision['reason'],
    'evidenceRefs': decision['evidenceRefs'],
    'binding': {
      'selectorApplicationId': binding['selectorApplicationId'],
      'context': binding['context'],
      'period': binding['period'],
      'semanticOwner': binding['semanticOwner'],
      'domain': binding['domain'],
      'horizon': binding['horizon'],
      'materialFingerprint': binding['materialFingerprint'],
      'evidenceKey': binding['evidenceKey'],
      'directionBand': binding['directionBand'],
      'sourceComponents': binding['sourceComponents'],
    },
  };
}

Json unknownBoundary(ThaiBetaAnalysis a) {
  final v = a.consumerViewState!;
  final document = ThaiBetaReportExportDocument.candidate(a);
  final legacyExport = ThaiBetaReportExportDocument.fromAnalysis(a);
  expect(v.lifeTimeline, isNull);
  expect(v.futurePrediction, isNull);
  expect(a.pipelineResult!.lifePeriods, isNull);
  expect(v.narrativeSections, isEmpty);
  expect(v.strengths.cards, isEmpty);
  expect(v.cautions.cards, isEmpty);
  expect(v.lifeDashboard, isEmpty);
  expect(document.infographic, isNull);
  expect(document.sections.map((s) => s.title).toList(), [
    'ส่วนที่ 1 · พื้นดวงของคุณ',
    'ส่วนที่ 2 · จังหวะชีวิตที่ผ่านมาและปัจจุบัน',
    'ส่วนที่ 3 · แนวโน้มข้างหน้า',
    'ส่วนที่ 4 · ที่มาและข้อจำกัด',
  ]);
  expect(
    a.normalizedSnapshot!.reasons,
    isNot(contains('bornBeforeLocalSunrise')),
  );
  expect(
    a.normalizedSnapshot!.reasons,
    isNot(contains('bornAfterLocalSunrise')),
  );
  expect(
    a.normalizedSnapshot!.reasons,
    contains('unknownTimeSentinelNonAuthoritative'),
  );
  return {
    ...publicBoundary(a),
    'reportSnapshot': a.reportSnapshot,
    'reportHash': a.reportHash,
    'exportDocument': legacyExport.fullPlainText,
    'infographic': null,
    'consumerView': {
      'hero': [
        v.hero.headline,
        v.hero.summary,
        v.hero.tags,
        v.hero.identityBadge,
        v.hero.identitySubtitle,
      ],
      'strengths': v.strengths.title,
      'cautions': v.cautions.title,
      'advice': [v.advice.title, v.advice.body],
      'signature': [
        v.signatureInsight.eyebrow,
        v.signatureInsight.body,
        v.signatureInsight.signature,
      ],
      'reflection': [
        v.reflectionSummary.title,
        v.reflectionSummary.intro,
        v.reflectionSummary.points,
      ],
      'closing': [
        v.closingMessage.eyebrow,
        v.closingMessage.message,
        v.closingMessage.signature,
      ],
      'sources': [
        v.sourceTransparency.dataUsed,
        v.sourceTransparency.calculation,
        v.sourceTransparency.meaning,
      ],
      'confidence': [
        v.birthDataConfidence.isComplete,
        v.birthDataConfidence.title,
        v.birthDataConfidence.body,
      ],
      'secretTip': v.secretTip,
      'disclaimers': v.disclaimers,
    },
  };
}

Json sentinelContainment([ThaiBetaInput? input, bool writeOutput = true]) {
  final base = ThaiBetaAnalysisRunner.run(
    input ?? fixture(null),
    asOf: DateTime(2026, 8, 29),
  );
  final baseline = unknownBoundary(base);
  final observations = <Json>[];
  for (final time in [(0, 0), (12, 0), (23, 59)]) {
    final a = SentinelAnalysis(base, time.$1, time.$2);
    final public = unknownBoundary(a);
    final label =
        '${time.$1.toString().padLeft(2, '0')}:${time.$2.toString().padLeft(2, '0')}';
    final differences = [
      for (final key in baseline.keys)
        if (digest(public[key]) != digest(baseline[key])) key,
    ];
    observations.add({
      'placeholder': label,
      'internalAuditClassification': 'NON_AUTHORITATIVE_SENTINEL_METADATA',
      'rawBirthHour': a.input.toMap()['birthHour'],
      'hasBirthTimeAtBoundaries': [
        a.input.hasBirthTime,
        a.normalizedBirth.raw.hasBirthTime,
        a.normalizedBirth.thai.hasBirthTime,
        a.normalizedSnapshot.hasBirthTime,
        a.pipelineResult.birthData!.hasBirthTime,
        a.profile.hasBirthTime,
      ],
      'birthTimeForPersistence': a.normalizedSnapshot.birthTime,
      'internalAstrologicalDate': a.normalizedSnapshot.thaiAstrologicalDate,
      'internalThaiWeekday': a.pipelineResult.birthData!.thaiWeekdayNumber,
      'lagnaKey': a.profile.lagnaKey,
      'degree': a.profile.siderealAscendantDeg,
      'public': public,
      'publicSha256': digest(public),
      'mismatchedPublicFields': differences,
    });
  }
  final mismatches = observations
      .where((o) => (o['mismatchedPublicFields'] as List).isNotEmpty)
      .length;
  final result = <String, dynamic>{
    'beforeOwnerDecision': {
      'passed': 4,
      'failed': 1,
      'cause': 'Literal prohibition of internal noon sentinel',
    },
    'contract':
        'Sentinel permitted only when non-authoritative and contained; public output, omission and claims must be invariant.',
    'internal_unknown_time_sentinel_present': true,
    'sentinel_value': '12:00',
    'sentinel_treated_as_provided_birth_time': observations
        .where(
          (o) =>
              o['rawBirthHour'] != null ||
              (o['hasBirthTimeAtBoundaries'] as List).contains(true),
        )
        .length,
    'sentinel_persisted_or_exported_as_birth_time': observations
        .where(
          (o) =>
              o['birthTimeForPersistence'] != '' ||
              (o['public']['publicExportText'] as String).contains(
                o['placeholder'] as String,
              ),
        )
        .length,
    'placeholder_invariance_mismatch': mismatches,
    'unknown_prediction_leakage': observations.fold<int>(
      0,
      (n, o) => n + (o['public']['predictionClaims'] as int),
    ),
    'unknown_lagna_house_degree_leakage': observations
        .where((o) => o['lagnaKey'] != null || o['degree'] != null)
        .length,
    'sentinel_derived_authority_used': mismatches == 0 ? 0 : null,
    'unknown_time_dependent_material_leakage': 0,
    'unknown_astrological_day_assertion': 0,
    'unknown_life_timeline_emitted': 0,
    'unknown_future_prediction_emitted': 0,
    'unknown_legacy_prediction_section_emitted': 0,
    'counterQualification':
        'Zero material/timeline/legacy counters require exact Unknown-safe boundary assertions for every variant. Internal civil-date metadata is not an astrological-day assertion.',
    'baselinePublic': baseline,
    'observations': observations,
    'status': mismatches == 0
        ? 'UNKNOWN_SAFE_BOUNDARIES_AND_METAMORPHIC_COMPARISON_PASS'
        : 'RUNTIME_DEFECT_PUBLIC_PLACEHOLDER_DEPENDENCE',
  };
  if (writeOutput) writeEvidence('OR5_SENTINEL_CONTAINMENT', result);
  return result;
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  late Json three, thirtyFive, early, unknown;
  setUpAll(() async {
    await ThaiCanonEvidenceRepository.loadFromAsset();
    three = extract(fixture(3), DateTime(2026, 8, 29));
    thirtyFive = extract(fixture(35), DateTime(2026, 8, 29));
    early = extract(fixture(3), DateTime(2026, 8, 7));
    unknown = extract(fixture(null), DateTime(2026, 8, 29));
  });
  test(
    'OR10R extraction preserves input and one signature-based runtime path',
    () {
      final knownContracts = {
        for (final minute in [3, 35])
          '$minute': publicBoundary(
            ThaiBetaAnalysisRunner.run(
              fixture(minute),
              asOf: DateTime(2026, 8, 29),
            ),
          ),
      };
      final baselineFile = File(
        'test/evidence/fixtures/or5r_known_baseline.json',
      );
      if (Platform.environment['OR5R_CAPTURE_BASELINE'] == '1') {
        baselineFile.writeAsStringSync(
          const JsonEncoder.withIndent('  ').convert(knownContracts),
        );
      } else {
        expect(baselineFile.existsSync(), isTrue);
        expect(
          sha256.convert(baselineFile.readAsBytesSync()).toString(),
          '91b71e6689193ee8c5cbd2604f24f139d380b9994a94437f4135fd42019cd998',
          reason: 'The pre-repair OR5R reader baseline must remain immutable',
        );
        final historicalContracts =
            jsonDecode(baselineFile.readAsStringSync()) as Json;
        expect(
          {
            for (final entry in knownContracts.entries)
              entry.key: authorityBoundary(entry.value),
          },
          {
            for (final entry in historicalContracts.entries)
              entry.key: authorityBoundary(entry.value as Json),
          },
          reason:
              'Candidate reader revisions may change copy, but not the accepted selector/evidence authority boundary',
        );
      }
      expect(three['plan']['ownerAcceptedGoldenOverrideApplied'], 0);
      expect(thirtyFive['plan']['ownerAcceptedGoldenOverrideApplied'], 0);
      expect(
        three['plan']['predictiveSignature'],
        thirtyFive['plan']['predictiveSignature'],
      );
      expect(three['plan']['decisions'], thirtyFive['plan']['decisions']);
      expect(three['canonical']['lagnaKey'], 'lagna_aquarius');
      expect(thirtyFive['canonical']['lagnaKey'], 'lagna_aquarius');
      expect(
        three['canonical']['degreeWithinSign'],
        closeTo(9 + 24 / 60, 1 / 60),
      );
      expect(
        thirtyFive['canonical']['degreeWithinSign'],
        closeTo(19 + 19 / 60, 1 / 60),
      );
      for (final e in [three, thirtyFive, early]) {
        expect(e['origin'], rawOrigin);
        expect(e['typedMaterials'], isNotEmpty);
        expect(
          validateAgainst(
            e,
            extract(
              ThaiBetaInput.fromMap(e['input'] as Json),
              DateTime.parse(e['asOf'] as String),
            ),
          ),
          isEmpty,
        );
      }
      writeEvidence('OR5_ACTUAL_0035_RUNTIME_EVIDENCE', thirtyFive);
      writeEvidence('OR5_RAW_0003_20260829', three);
      writeEvidence('OR5_RAW_0003_20260807', early);
      writeEvidence('OR5_UNKNOWN_RUNTIME_EVIDENCE', unknown);
    },
  );
  test('OR5 Unknown omits time-dependent predictive inputs and claims', () {
    final containment = sentinelContainment();
    writeEvidence('OR5_UNKNOWN_CONTROL', containment);
    writeEvidence('OR5_UNKNOWN_CONTROL_BEFORE_OWNER_DECISION', {
      'internalNoonPlaceholderAbsent':
          !(unknown['birthDataInternal']['localDateTime'] as String).contains(
            'T12:',
          ),
      'inputHourAbsent': unknown['input']['birthHour'] == null,
      'normalizedBirthTimeAbsent': unknown['normalized']['birthTime'] == '',
      'ascendantAbsent': unknown['canonical']['siderealAscendantDeg'] == null,
      'timeDependentMaterials': (unknown['typedMaterials'] as List)
          .where((m) => m['timeDependent'] == true)
          .length,
      'predictionClaims': unknown['plan']['emittedPredictions'],
      'knownToUnknownLeakage': unknown['plan']['knownToUnknownLeakage'],
      'internalThaiDay': unknown['birthDataInternal']['thaiWeekdayNumber'],
      'predictiveContext': unknown['contextId'],
      'finding':
          'BirthNormalizer uses _assumedHour=12 internally with hasBirthTime=false. Literal no-noon-substitution gate FAILS; no assertion is weakened. Internal day is retained, not an authorized time-bound Thai-day claim.',
      'source':
          'lib/features/birth_normalization/application/birth_normalizer.dart',
    });
    expect(unknown['input']['birthHour'], isNull);
    expect(unknown['normalized']['birthTime'], '');
    expect(unknown['canonical']['hasBirthTime'], false);
    expect(unknown['canonical']['lagnaKey'], isNull);
    expect(unknown['canonical']['siderealAscendantDeg'], isNull);
    expect(unknown['birthDataInternal']['hasBirthTime'], false);
    expect(containment['sentinel_treated_as_provided_birth_time'], 0);
    expect(containment['sentinel_persisted_or_exported_as_birth_time'], 0);
    expect(unknown['contextId'], 'unknown-time');
    expect(unknown['currentPeriod'], isNull);
    expect(
      (unknown['typedMaterials'] as List).where(
        (m) => m['timeDependent'] == true,
      ),
      isEmpty,
    );
    expect(unknown['plan']['emittedPredictions'], 0);
    expect(unknown['plan']['knownToUnknownLeakage'], 0);
    final observations = containment['observations'] as List;
    for (final observation in observations) {
      expect(observation['hasBirthTimeAtBoundaries'], everyElement(false));
      expect(observation['rawBirthHour'], isNull);
      expect(observation['birthTimeForPersistence'], '');
      expect(observation['lagnaKey'], isNull);
      expect(observation['degree'], isNull);
      expect(observation['public']['decisions'], isEmpty);
    }
    expect(
      observations[1]['mismatchedPublicFields'],
      isEmpty,
      reason:
          'Injected 12:00 must reproduce the actual unmodified runner boundary',
    );
    expect(containment['placeholder_invariance_mismatch'], 0);
    final rows = <Json>[];
    for (final c in ThaiBetaSyntheticMatrix.build().where(
      (c) => !c.input.hasBirthTime,
    )) {
      final result = sentinelContainment(c.input, false);
      expect(result['placeholder_invariance_mismatch'], 0, reason: c.id);
      rows.add({'fixtureId': c.id, 'input': c.input.toMap(), 'result': result});
    }
    expect(rows, hasLength(75));
    writeEvidence('OR5R_UNKNOWN_75_PLACEHOLDERS', {
      'profiles': 75,
      'variants': 225,
      'mismatch': rows.fold<int>(
        0,
        (n, r) => n + (r['result']['placeholder_invariance_mismatch'] as int),
      ),
      'rows': rows,
    });
  });
  test('OR5 ten actual-input tampering controls are rejected', () {
    final cases = <String, ({Json altered, Json reference})>{};
    void add(
      String id,
      Json original,
      Json expected,
      void Function(Json) change,
    ) {
      final value = clone(original);
      change(value);
      value.remove('extractionSha256');
      value['extractionSha256'] = digest(value);
      cases[id] = (altered: value, reference: expected);
    }

    add(
      'relabel_0003_as_0035',
      three,
      thirtyFive,
      (v) => v['input'] = thirtyFive['input'],
    );
    add('relabel_asOf', early, three, (v) => v['asOf'] = three['asOf']);
    add(
      'missing_material',
      thirtyFive,
      thirtyFive,
      (v) => (v['typedMaterials'] as List).removeAt(0),
    );
    add(
      'wrong_domain',
      thirtyFive,
      thirtyFive,
      (v) => v['typedMaterials'][0]['domain'] = 'health',
    );
    add(
      'wrong_horizon',
      thirtyFive,
      thirtyFive,
      (v) => v['typedMaterials'][0]['horizon'] = 'past',
    );
    add(
      'wrong_direction',
      thirtyFive,
      thirtyFive,
      (v) => v['typedMaterials'][0]['band'] = 'UNSUPPORTED',
    );
    add(
      'wrong_current_period',
      thirtyFive,
      thirtyFive,
      (v) => v['currentPeriod']['ageStart'] = -1,
    );
    add(
      'golden_plan_as_raw',
      three,
      three,
      (v) => v['rawFuturePrediction'] = three['plan'],
    );
    add(
      'reader_text_as_authority',
      thirtyFive,
      thirtyFive,
      (v) => v['typedMaterials'][0]['authorityClass'] = 'EDITORIAL_TEXT_ONLY',
    );
    add(
      'Known_into_Unknown',
      thirtyFive,
      unknown,
      (v) => v['input'] = unknown['input'],
    );
    final results = <Json>[];
    for (final item in cases.entries) {
      final errors = validateAgainst(item.value.altered, item.value.reference);
      expect(errors, isNotEmpty, reason: item.key);
      results.add({
        'control': item.key,
        'rejected': errors.isNotEmpty,
        'mismatchedFields': errors,
      });
    }
    writeEvidence('OR5_NEGATIVE_CONTROLS', {
      'controls': results,
      'rejected': results.length,
    });
  });
  test(
    'OR5 300 profiles and 49 reachable contexts are extracted twice exactly',
    () {
      final profiles = <Json>[];
      final contexts = <String, Json>{};
      final bodyBySignature = <String, String>{};
      final signatures = <String>{};
      final predictiveBodies = <String>{};
      var deterministic = 0;
      for (final c in ThaiBetaSyntheticMatrix.build()) {
        final first = extract(c.input, DateTime(2026, 8, 29));
        final second = extract(c.input, DateTime(2026, 8, 29));
        expect(validateAgainst(first, second), isEmpty, reason: c.id);
        deterministic++;
        final record = {'fixtureId': c.id, 'evidence': first};
        profiles.add(record);
        if (c.input.hasBirthTime &&
            runtimePredictiveV2ContextIds.contains(first['contextId'])) {
          final plan = first['plan'] as Json;
          final signature = plan['predictiveSignature'] as String;
          final body = digest([
            for (final decision in (plan['decisions'] as List))
              if (decision['emitted'] == true)
                {
                  'semanticOwner': decision['semanticOwner'],
                  'section': decision['section'],
                  'text': decision['text'],
                },
          ]);
          final priorBody = bodyBySignature[signature];
          expect(
            priorBody == null || priorBody == body,
            isTrue,
            reason: 'same signature must have one body: ${c.id}',
          );
          bodyBySignature[signature] = body;
          signatures.add(signature);
          predictiveBodies.add(body);
          contexts.putIfAbsent(first['contextId'] as String, () => record);
        }
      }
      var date = DateTime(1975, 1, 1);
      while (contexts.length < 49 && date.isBefore(DateTime(1985))) {
        final input = ThaiBetaInput(
          firstName: 'Context',
          lastName: 'Coverage',
          birthDate: date,
          birthHour: 12,
          province: 'เชียงใหม่',
          provinceKey: 'chiang mai',
          gender: 'ชาย',
        );
        final first = extract(input, DateTime(2026, 8, 29));
        final context = first['contextId'] as String;
        if (runtimePredictiveV2ContextIds.contains(context) &&
            !contexts.containsKey(context)) {
          expect(
            validateAgainst(first, extract(input, DateTime(2026, 8, 29))),
            isEmpty,
          );
          deterministic++;
          contexts[context] = {
            'fixtureId':
                'bounded-search-${date.toIso8601String().substring(0, 10)}',
            'evidence': first,
          };
        }
        date = date.add(const Duration(days: 1));
      }
      expect(profiles, hasLength(300));
      expect(contexts, hasLength(49));
      expect(contexts.keys.toSet(), runtimePredictiveV2ContextIds.toSet());
      final keys = contexts.keys.toList()..sort();
      writeEvidence('OR5_INPUT_BOUND_MATERIALS_49', {
        'count': contexts.length,
        'profiles': [for (final k in keys) contexts[k]],
      });
      writeEvidence('OR5_INPUT_BOUND_MATERIAL_DISTRIBUTION_300', {
        'count': profiles.length,
        'profiles': profiles,
      });
      writeEvidence('OR5_DETERMINISM', {
        'independentPairsCompared': deterministic,
        'runsPerInput': 2,
        'mismatchCount': 0,
        'uniquePredictiveSignatures': signatures.length,
        'uniqueGeneratedPredictiveBodies': predictiveBodies.length,
        'sameSignatureBodyMismatch': 0,
        'profile300Sha256': digest(profiles),
        'context49Sha256': digest([for (final k in keys) contexts[k]]),
      });
    },
    timeout: const Timeout(Duration(minutes: 10)),
  );
  test('OR5 accepted Candidate0011 reader bytes remain immutable', () {
    final content = File(
      'docs/THAI_REPORT_PREDICTIVE_NARRATIVE_V2_TARGET_CANDIDATE_0011.md',
    ).readAsStringSync().replaceAll('\r\n', '\n');
    final reader = content
        .split('Reader-facing candidate begins below.')[1]
        .split('Reader-facing candidate ends above.')[0]
        .trim();
    expect(
      sha256.convert(utf8.encode(reader)).toString().toUpperCase(),
      '6AA94C7A01555310C5189FAAF711597057C5DF2F102246A0DF3946DAB2B62A1E',
    );
  });
}
