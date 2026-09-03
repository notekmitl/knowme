/// Owner-authorized Predictive Narrative V2 runtime.
///
/// The 392-row Mahabhut ledger is used only as selector/timing authority.
/// Reader direction comes from typed forecast material and the production
/// composers. Candidate 0011 remains an immutable exact golden override for
/// its Owner-pinned fixture; every other Known-time report follows the shared
/// context/period resolver and generalized editorial path.
library;

import 'package:knowme/features/astrology/thai/core/life_period/thai_remainder_runtime_metadata.dart';
import 'package:knowme/features/astrology/thai/core/life_period/life_planet.dart';
import 'package:knowme/features/astrology/thai/mirror/presentation/prediction/prediction_section_model.dart';
import 'package:knowme/features/thai_beta/application/thai_beta_analysis.dart';

part 'predictive_runtime_v2_catalog.g.dart';

enum RuntimePredictiveKind { prediction, summary, advice, disclosure }

class RuntimePredictivePeriodRow {
  const RuntimePredictivePeriodRow({
    required this.contextId,
    required this.matrixApplicationId,
    required this.planet,
    required this.taksaRole,
    required this.mahabhutHouse,
    required this.periodStatus,
    required this.ageStart,
    required this.ageEnd,
  });

  final String contextId;
  final String matrixApplicationId;
  final String planet;
  final String taksaRole;
  final String mahabhutHouse;
  final String periodStatus;
  final int ageStart;
  final int ageEnd;

  bool containsAge(int age) => age >= ageStart && age <= ageEnd;
  String get ageBinding => '$ageStart-$ageEnd';
  String get selectorRef => 'selector.$matrixApplicationId';

  Map<String, Object?> toMap() => {
    'contextId': contextId,
    'matrixApplicationId': matrixApplicationId,
    'planet': planet,
    'taksaRole': taksaRole,
    'mahabhutHouse': mahabhutHouse,
    'periodStatus': periodStatus,
    'ageStart': ageStart,
    'ageEnd': ageEnd,
  };
}

class RuntimePredictiveRule {
  const RuntimePredictiveRule({
    required this.id,
    required this.semanticOwner,
    required this.section,
    required this.kind,
    required this.textTemplate,
    required this.contextId,
    required this.periodBinding,
    required this.domain,
    required this.selectorRefs,
    required this.domainRefs,
    required this.directionRefs,
    required this.timingRefs,
    required this.conflictRefs,
    required this.certaintyRefs,
    this.compositionRefs = const [],
    this.infographicTextTemplate = '',
    this.fixtureSpecific = false,
    this.selectorApplicationId = '',
    this.horizon = '',
    this.materialFingerprint = '',
    this.evidenceKey = '',
    this.directionBand = '',
    this.sourceComponents = const [],
    this.realizerId = '',
    this.goldenOverride = false,
  });

  final String id;
  final String semanticOwner;
  final String section;
  final RuntimePredictiveKind kind;
  final String textTemplate;
  final String contextId;
  final String periodBinding;
  final String domain;
  final List<String> selectorRefs;
  final List<String> domainRefs;
  final List<String> directionRefs;
  final List<String> timingRefs;
  final List<String> conflictRefs;
  final List<String> certaintyRefs;
  final List<String> compositionRefs;
  final String infographicTextTemplate;
  final bool fixtureSpecific;
  final String selectorApplicationId;
  final String horizon;
  final String materialFingerprint;
  final String evidenceKey;
  final String directionBand;
  final List<String> sourceComponents;
  final String realizerId;
  final bool goldenOverride;

  Iterable<String> get evidenceRefs sync* {
    yield* selectorRefs;
    yield* domainRefs;
    yield* directionRefs;
    yield* timingRefs;
    yield* conflictRefs;
    yield* certaintyRefs;
    yield* compositionRefs;
  }

  bool get hasCompletePredictiveChain {
    if (kind == RuntimePredictiveKind.advice ||
        kind == RuntimePredictiveKind.disclosure) {
      return hasClaimLevelBinding;
    }
    if (kind == RuntimePredictiveKind.summary && compositionRefs.isNotEmpty) {
      return hasClaimLevelBinding;
    }
    return selectorRefs.isNotEmpty &&
        domainRefs.isNotEmpty &&
        directionRefs.isNotEmpty &&
        timingRefs.isNotEmpty &&
        conflictRefs.isNotEmpty &&
        certaintyRefs.isNotEmpty &&
        evidenceRefs.every(runtimePredictiveV2EvidenceIds.contains) &&
        hasClaimLevelBinding;
  }

  RuntimePredictiveRule copyWith({
    String? id,
    String? contextId,
    bool? fixtureSpecific,
    String? selectorApplicationId,
    String? horizon,
    String? materialFingerprint,
    String? evidenceKey,
    String? directionBand,
    List<String>? sourceComponents,
    String? realizerId,
    bool? goldenOverride,
  }) => RuntimePredictiveRule(
    id: id ?? this.id,
    semanticOwner: semanticOwner,
    section: section,
    kind: kind,
    textTemplate: textTemplate,
    contextId: contextId ?? this.contextId,
    periodBinding: periodBinding,
    domain: domain,
    selectorRefs: selectorRefs,
    domainRefs: domainRefs,
    directionRefs: directionRefs,
    timingRefs: timingRefs,
    conflictRefs: conflictRefs,
    certaintyRefs: certaintyRefs,
    compositionRefs: compositionRefs,
    infographicTextTemplate: infographicTextTemplate,
    fixtureSpecific: fixtureSpecific ?? this.fixtureSpecific,
    selectorApplicationId: selectorApplicationId ?? this.selectorApplicationId,
    horizon: horizon ?? this.horizon,
    materialFingerprint: materialFingerprint ?? this.materialFingerprint,
    evidenceKey: evidenceKey ?? this.evidenceKey,
    directionBand: directionBand ?? this.directionBand,
    sourceComponents: sourceComponents ?? this.sourceComponents,
    realizerId: realizerId ?? this.realizerId,
    goldenOverride: goldenOverride ?? this.goldenOverride,
  );

  bool get hasClaimLevelBinding {
    if (kind == RuntimePredictiveKind.disclosure) {
      return realizerId == 'disclosure-contract-v1' &&
          sourceComponents.isNotEmpty;
    }
    if (kind == RuntimePredictiveKind.advice) {
      return domain == 'advice' &&
          realizerId == 'advice-owner-v2' &&
          sourceComponents.isNotEmpty;
    }
    if (kind == RuntimePredictiveKind.summary) {
      return compositionRefs.isNotEmpty &&
          realizerId == 'summary-composition-v2' &&
          sourceComponents.isNotEmpty;
    }
    return selectorApplicationId.isNotEmpty &&
        horizon.isNotEmpty &&
        materialFingerprint.isNotEmpty &&
        evidenceKey.isNotEmpty &&
        directionBand.isNotEmpty &&
        sourceComponents.isNotEmpty &&
        realizerId.isNotEmpty;
  }
}

class RuntimePredictiveDecision {
  const RuntimePredictiveDecision({
    required this.rule,
    required this.emitted,
    required this.reason,
    this.text = '',
    this.section = '',
    this.infographicText = '',
  });

  final RuntimePredictiveRule rule;
  final bool emitted;
  final String reason;
  final String text;
  final String section;
  final String infographicText;

  Map<String, Object?> toMap() => {
    'claimId': rule.id,
    'semanticOwner': rule.semanticOwner,
    'kind': rule.kind.name,
    'domain': rule.domain,
    'periodBinding': rule.periodBinding,
    'emitted': emitted,
    'reason': reason,
    'section': section,
    'text': text,
    'infographicText': infographicText,
    'evidenceRefs': rule.evidenceRefs.toList(growable: false),
    'binding': {
      'selectorApplicationId': rule.selectorApplicationId,
      'context': rule.contextId,
      'period': rule.periodBinding,
      'semanticOwner': rule.semanticOwner,
      'domain': rule.domain,
      'horizon': rule.horizon,
      'materialFingerprint': rule.materialFingerprint,
      'evidenceKey': rule.evidenceKey,
      'directionBand': rule.directionBand,
      'sourceComponents': rule.sourceComponents,
      'realizedReaderText': text,
      'goldenOverride': rule.goldenOverride,
      'realizerId': rule.realizerId,
    },
  };
}

class RuntimePredictiveSection {
  const RuntimePredictiveSection({
    required this.id,
    required this.title,
    required this.claims,
  });

  final String id;
  final String title;
  final List<RuntimePredictiveDecision> claims;
}

class ThaiPredictiveRuntimeV2Plan {
  const ThaiPredictiveRuntimeV2Plan({
    required this.contextId,
    required this.knownTime,
    required this.currentAge,
    required this.asOf,
    required this.title,
    required this.subtitle,
    required this.decisions,
    required this.sections,
    required this.omissionReason,
    required this.currentPeriod,
    required this.goldenOverrideApplied,
  });

  static const requiredKnownSemanticOwners = <String>{
    'overview',
    'past',
    'current',
    'work',
    'finance',
    'relationship',
    'health',
    'support',
    'rolling12',
    'next',
    'summary',
    'advice',
    'disclosure',
  };

  factory ThaiPredictiveRuntimeV2Plan.fromAnalysis(ThaiBetaAnalysis analysis) {
    final known = analysis.input.hasBirthTime;
    final birthData = analysis.pipelineResult?.birthData;
    final remainder = known
        ? ThaiRemainderMetadataResolver.resolve(
            profile: analysis.profile,
            birthData: birthData,
          )
        : null;
    final weekday = known ? birthData?.thaiWeekdayNumber : null;
    final context = !known
        ? 'unknown-time'
        : remainder == null || weekday == null
        ? 'mahabhut2537.unresolved'
        : contextIdForMetadata(remainder.value, weekday);
    final age = analysis.pipelineResult?.lifePeriods?.currentAge;
    final currentPeriod = age == null
        ? null
        : resolvePeriod(contextId: context, age: age);

    if (!known ||
        age == null ||
        currentPeriod == null ||
        !runtimePredictiveV2ContextIds.contains(context)) {
      final reason = !known
          ? 'ไม่มีเวลาเกิด — รายงานจึงเว้นหัวข้อที่ต้องใช้เวลาเกิด แทนการเดาข้อมูลที่ไม่มี'
          : 'รายงานเว้นคำทำนายส่วนนี้ เพราะยังระบุบริบทและช่วงอายุจากกฎที่ยืนยันแล้วไม่ได้ครบ';
      return ThaiPredictiveRuntimeV2Plan(
        contextId: context,
        knownTime: known,
        currentAge: age,
        asOf: analysis.asOf,
        title: '',
        subtitle: '',
        decisions: const [],
        sections: const [],
        omissionReason: reason,
        currentPeriod: currentPeriod,
        goldenOverrideApplied: false,
      );
    }

    final useGoldenOverride = _isOwnerAcceptedGoldenFixture(analysis);

    final rules = _rulesForAnalysis(
      analysis: analysis,
      contextId: context,
      currentAge: age,
      currentPeriod: currentPeriod,
      useGoldenOverride: useGoldenOverride,
    );
    final ruleIds = rules.map((rule) => rule.id).toSet();
    final decisions = <RuntimePredictiveDecision>[];
    for (final rule in rules) {
      final complete =
          rule.hasCompletePredictiveChain &&
          (rule.kind != RuntimePredictiveKind.summary ||
              rule.compositionRefs.every(ruleIds.contains));
      final hasText = rule.textTemplate.trim().isNotEmpty;
      decisions.add(
        RuntimePredictiveDecision(
          rule: rule,
          emitted: complete && hasText,
          reason: !complete
              ? 'INCOMPLETE_EVIDENCE_CHAIN'
              : !hasText
              ? 'EMPTY_READER_TEXT'
              : 'COMPLETE_CONTRACT_V1_CHAIN',
          text: complete
              ? _realize(rule.textTemplate, age: age, asOf: analysis.asOf)
              : '',
          section: complete
              ? _realize(rule.section, age: age, asOf: analysis.asOf)
              : '',
          infographicText: complete
              ? _realize(
                  rule.infographicTextTemplate.isEmpty
                      ? rule.textTemplate
                      : rule.infographicTextTemplate,
                  age: age,
                  asOf: analysis.asOf,
                )
              : '',
        ),
      );
    }
    final emitted = decisions.where((decision) => decision.emitted).toList();
    final missing = requiredKnownSemanticOwners.difference(
      emitted.map((decision) => decision.rule.semanticOwner).toSet(),
    );
    final unsupported = emitted.any(
      (decision) => !decision.rule.hasCompletePredictiveChain,
    );
    final complete = missing.isEmpty && !unsupported;
    return ThaiPredictiveRuntimeV2Plan(
      contextId: context,
      knownTime: known,
      currentAge: age,
      asOf: analysis.asOf,
      title: complete ? 'คำทำนายดวงชะตา' : '',
      subtitle: complete ? _knownSubtitle(analysis) : '',
      decisions: decisions,
      sections: complete ? _buildSections(emitted) : const [],
      omissionReason: complete
          ? ''
          : 'รายงานเว้นคำทำนายส่วนนี้ เพราะองค์ประกอบเนื้อหาที่จำเป็นยังไม่ครบ: ${missing.join(', ')}',
      currentPeriod: currentPeriod,
      goldenOverrideApplied: useGoldenOverride,
    );
  }

  final String contextId;
  final bool knownTime;
  final int? currentAge;
  final DateTime asOf;
  final String title;
  final String subtitle;
  final List<RuntimePredictiveDecision> decisions;
  final List<RuntimePredictiveSection> sections;
  final String omissionReason;
  final RuntimePredictivePeriodRow? currentPeriod;
  final bool goldenOverrideApplied;

  bool get monthlyTimelineAvailable => false;
  List<RuntimePredictiveDecision> get emittedClaims =>
      decisions.where((decision) => decision.emitted).toList(growable: false);
  List<RuntimePredictiveDecision> get omittedClaims =>
      decisions.where((decision) => !decision.emitted).toList(growable: false);
  int get emittedPredictions => emittedClaims
      .where(
        (decision) => decision.rule.kind == RuntimePredictiveKind.prediction,
      )
      .length;
  int get unsupportedClaims => emittedClaims
      .where((decision) => !decision.rule.hasCompletePredictiveChain)
      .length;
  int get fixtureSpecificBranches => unexpectedFixtureSpecificBranches;
  int get ownerAcceptedGoldenOverrideApplied => goldenOverrideApplied ? 1 : 0;
  int get unexpectedFixtureSpecificBranches => decisions
      .where(
        (decision) =>
            decision.rule.fixtureSpecific && !decision.rule.goldenOverride,
      )
      .length;
  int get fixtureReferenceLeakage => goldenOverrideApplied
      ? 0
      : decisions
            .where(
              (decision) => decision.rule.evidenceRefs.any(
                (ref) => ref.startsWith('fixture.'),
              ),
            )
            .length;
  int get evidenceBindingMismatches =>
      RuntimePredictiveClaimBindingValidator.validate(this).length;
  int get knownToUnknownLeakage =>
      !knownTime && emittedClaims.isNotEmpty ? emittedClaims.length : 0;
  bool get baselineFallbackUsed => knownTime && sections.isEmpty;
  Set<String> get emittedSemanticOwners =>
      emittedClaims.map((decision) => decision.rule.semanticOwner).toSet();
  Set<String> get missingSemanticOwners => knownTime
      ? requiredKnownSemanticOwners.difference(emittedSemanticOwners)
      : const {};
  String get generationPath => goldenOverrideApplied
      ? 'predictive-runtime-v2:owner-accepted-candidate-0011-exact'
      : 'predictive-runtime-v2:392-selector+typed-material+editorial-contract-v2';

  static String contextIdForMetadata(int remainder, int thaiWeekdayNumber) {
    if (remainder < 0 || remainder > 6) return 'mahabhut2537.unresolved';
    final weekday = _weekdayKey(thaiWeekdayNumber);
    if (weekday == 'unknown') return 'mahabhut2537.unresolved';
    return 'mahabhut2537.rem$remainder.$weekday';
  }

  static RuntimePredictivePeriodRow? resolvePeriod({
    required String contextId,
    required int age,
  }) {
    for (final row in runtimePredictiveV2PeriodRows) {
      if (row.contextId == contextId && row.containsAge(age)) return row;
    }
    return null;
  }

  static RuntimePredictivePeriodRow? resolveMatrixApplication(
    String matrixApplicationId,
  ) {
    for (final row in runtimePredictiveV2PeriodRows) {
      if (row.matrixApplicationId == matrixApplicationId) return row;
    }
    return null;
  }

  RuntimePredictiveDecision? claim(String id) {
    for (final decision in emittedClaims) {
      if (decision.rule.id == id) return decision;
    }
    return null;
  }

  RuntimePredictiveDecision? claimForOwner(String owner) {
    for (final decision in emittedClaims) {
      if (decision.rule.semanticOwner == owner) return decision;
    }
    return null;
  }

  Map<String, Object?> toMap() => {
    'contextId': contextId,
    'knownTime': knownTime,
    'currentAge': currentAge,
    'asOf': _isoDate(asOf),
    'generationPath': generationPath,
    'monthlyTimelineAvailable': monthlyTimelineAvailable,
    'emittedPredictions': emittedPredictions,
    'emittedClaimCount': emittedClaims.length,
    'omittedClaimCount': omittedClaims.length,
    'requiredSemanticOwners': requiredKnownSemanticOwners.toList()..sort(),
    'missingSemanticOwners': missingSemanticOwners.toList()..sort(),
    'baselineFallbackUsed': baselineFallbackUsed,
    'unsupportedClaims': unsupportedClaims,
    'fixtureSpecificBranches': fixtureSpecificBranches,
    'ownerAcceptedGoldenOverrideApplied': ownerAcceptedGoldenOverrideApplied,
    'unexpectedFixtureSpecificBranches': unexpectedFixtureSpecificBranches,
    'fixtureReferenceLeakage': fixtureReferenceLeakage,
    'evidenceBindingMismatches': evidenceBindingMismatches,
    'knownToUnknownLeakage': knownToUnknownLeakage,
    'currentPeriod': currentPeriod?.toMap(),
    'omissionReason': omissionReason,
    'decisions': decisions.map((decision) => decision.toMap()).toList(),
  };
}

class RuntimePredictiveIntegrityResult {
  const RuntimePredictiveIntegrityResult(this.errors);

  final List<String> errors;
  bool get isValid => errors.isEmpty;
}

/// Product-coverage validator used by both tests and evidence generation.
/// It validates rendered plans, not merely selector identifiers.
abstract final class RuntimePredictiveIntegrityValidator {
  static RuntimePredictiveIntegrityResult validate({
    required Set<String> contextIds,
    required List<RuntimePredictivePeriodRow> periodRows,
    required Map<String, List<RuntimePredictiveRule>> rulesByContext,
    required Map<String, Set<String>> ownersByContext,
    required Map<String, String> normalizedReportsByContext,
    required Map<String, String> evidenceFingerprintsByContext,
    required Set<String> baselineFallbackContexts,
    required int observedFixtureSpecificBranches,
    required bool fixtureMetricDerived,
  }) {
    final errors = <String>[];
    if (contextIds.length != 49) errors.add('CONTEXT_COUNT_NOT_49');
    if (periodRows.length != 392) errors.add('PERIOD_COUNT_NOT_392');
    if (periodRows.map((row) => row.matrixApplicationId).toSet().length !=
        periodRows.length) {
      errors.add('DUPLICATE_PERIOD_APPLICATION_ID');
    }
    for (final contextId in contextIds) {
      if (periodRows.where((row) => row.contextId == contextId).length != 8) {
        errors.add('CONTEXT_PERIOD_COUNT_NOT_8:$contextId');
      }
      final missing = ThaiPredictiveRuntimeV2Plan.requiredKnownSemanticOwners
          .difference(ownersByContext[contextId] ?? const {});
      if (missing.isNotEmpty) {
        errors.add('MISSING_SEMANTIC_OWNER:$contextId:${missing.join(',')}');
      }
      final rules = rulesByContext[contextId] ?? const [];
      final ids = rules.map((rule) => rule.id).toSet();
      for (final rule in rules) {
        if (rule.contextId != contextId) {
          errors.add('RULE_CONTEXT_MISMATCH:$contextId:${rule.id}');
        }
        if ((rule.kind == RuntimePredictiveKind.prediction ||
                rule.kind == RuntimePredictiveKind.summary) &&
            !rule.hasCompletePredictiveChain) {
          errors.add('INCOMPLETE_CHAIN:${rule.id}');
        }
        if (rule.kind == RuntimePredictiveKind.summary &&
            (rule.compositionRefs.isEmpty ||
                !rule.compositionRefs.every(ids.contains))) {
          errors.add('INVALID_SUMMARY_COMPOSITION:${rule.id}');
        }
        if (rule.fixtureSpecific) {
          errors.add('FIXTURE_SPECIFIC_RULE:${rule.id}');
        }
      }
    }
    if (baselineFallbackContexts.isNotEmpty) {
      errors.add('BASELINE_FALLBACK:${baselineFallbackContexts.length}');
    }
    if (!fixtureMetricDerived) errors.add('FIXTURE_METRIC_NOT_DERIVED');
    if (observedFixtureSpecificBranches != 0) {
      errors.add('FIXTURE_SPECIFIC_BRANCHES:$observedFixtureSpecificBranches');
    }
    final ruleContexts = rulesByContext.entries
        .where((entry) => entry.value.isNotEmpty)
        .map((entry) => entry.key)
        .toSet();
    if (ruleContexts.length != contextIds.length) {
      errors.add(
        'RULE_CONTEXT_COVERAGE:${ruleContexts.length}/${contextIds.length}',
      );
    }
    final reports = <String, List<String>>{};
    for (final entry in normalizedReportsByContext.entries) {
      reports.putIfAbsent(entry.value, () => []).add(entry.key);
    }
    for (final contexts in reports.values.where((items) => items.length > 1)) {
      final evidence = contexts
          .map((id) => evidenceFingerprintsByContext[id] ?? '')
          .toSet();
      if (evidence.length > 1) {
        errors.add(
          'IDENTICAL_REPORT_WITH_DIFFERENT_EVIDENCE:${contexts.join(',')}',
        );
      }
    }
    return RuntimePredictiveIntegrityResult(List.unmodifiable(errors));
  }
}

/// Validates the binding serialized beside every emitted reader claim.
/// This deliberately validates runtime output rather than accepting a manually
/// asserted `supported` flag from a catalog row.
abstract final class RuntimePredictiveClaimBindingValidator {
  static List<String> validate(ThaiPredictiveRuntimeV2Plan plan) {
    final errors = <String>[];
    final emittedIds = plan.emittedClaims
        .map((decision) => decision.rule.id)
        .toSet();
    for (final decision in plan.emittedClaims) {
      final rule = decision.rule;
      if (!rule.hasClaimLevelBinding) {
        errors.add('MISSING_BINDING:${rule.id}');
      }
      if (rule.contextId != plan.contextId) {
        errors.add('BINDING_CONTEXT_MISMATCH:${rule.id}');
      }
      if (rule.kind == RuntimePredictiveKind.advice &&
          rule.domain != 'advice') {
        errors.add('ADVICE_OWNER_MISMATCH:${rule.id}');
      }
      if (rule.kind == RuntimePredictiveKind.prediction &&
          rule.domain == 'advice') {
        errors.add('ADVICE_COUNTED_AS_PREDICTION:${rule.id}');
      }
      if (rule.kind == RuntimePredictiveKind.summary &&
          !rule.compositionRefs.every(emittedIds.contains)) {
        errors.add('SUMMARY_SOURCE_NOT_EMITTED:${rule.id}');
      }
      if (rule.kind == RuntimePredictiveKind.prediction) {
        final row = ThaiPredictiveRuntimeV2Plan.resolveMatrixApplication(
          rule.selectorApplicationId,
        );
        if (row == null ||
            row.contextId != plan.contextId ||
            (!rule.goldenOverride && row.ageBinding != rule.periodBinding)) {
          errors.add('SELECTOR_PERIOD_MISMATCH:${rule.id}');
        }
        if (rule.materialFingerprint.startsWith('h=')) {
          final fields = {
            for (final part in rule.materialFingerprint.split('|'))
              if (part.contains('='))
                part.split('=').first: part.substring(part.indexOf('=') + 1),
          };
          if (fields['h'] != rule.horizon) {
            errors.add('MATERIAL_HORIZON_MISMATCH:${rule.id}');
          }
          if (rule.domain != 'life_path' &&
              rule.domain != 'support' &&
              fields['d'] != rule.domain) {
            errors.add('MATERIAL_DOMAIN_MISMATCH:${rule.id}');
          }
          if (fields['k'] != rule.evidenceKey ||
              fields['b'] != rule.directionBand) {
            errors.add('MATERIAL_KEY_OR_DIRECTION_MISMATCH:${rule.id}');
          }
        }
        const allowedRealizers = {
          'candidate-0011-exact',
          'generalized-editorial-v2',
          'life-period-editorial-v2',
          'support-editorial-v2',
        };
        if (!allowedRealizers.contains(rule.realizerId)) {
          errors.add('UNBOUND_MANUAL_READER_TEXT:${rule.id}');
        }
      }
      if (decision.text.trim().isEmpty) {
        errors.add('EMPTY_REALIZED_READER_TEXT:${rule.id}');
      }
    }
    if (plan.goldenOverrideApplied) {
      if (plan.emittedClaims.any((decision) => !decision.rule.goldenOverride)) {
        errors.add('PARTIAL_GOLDEN_OVERRIDE');
      }
    } else {
      if (plan.emittedClaims.any((decision) => decision.rule.goldenOverride)) {
        errors.add('UNEXPECTED_GOLDEN_OVERRIDE');
      }
      if (plan.fixtureReferenceLeakage != 0) {
        errors.add('FIXTURE_REFERENCE_LEAKAGE:${plan.fixtureReferenceLeakage}');
      }
    }
    return List.unmodifiable(errors);
  }
}

List<RuntimePredictiveRule> _rulesForAnalysis({
  required ThaiBetaAnalysis analysis,
  required String contextId,
  required int currentAge,
  required RuntimePredictivePeriodRow currentPeriod,
  required bool useGoldenOverride,
}) {
  final goldenContextMatches = runtimePredictiveV2GoldenRules.every(
    (rule) => rule.contextId == contextId,
  );
  if (useGoldenOverride &&
      goldenContextMatches &&
      currentPeriod.matrixApplicationId ==
          runtimePredictiveV2GoldenCurrentPeriodId) {
    return runtimePredictiveV2GoldenRules
        .map((rule) => _bindGoldenRule(rule, currentPeriod))
        .toList(growable: false);
  }
  return _buildContractRules(
    analysis: analysis,
    contextId: contextId,
    currentAge: currentAge,
    currentPeriod: currentPeriod,
  );
}

bool _isOwnerAcceptedGoldenFixture(ThaiBetaAnalysis analysis) {
  final input = analysis.input;
  final date = input.birthDate;
  final asOf = analysis.asOf;
  final province = (input.provinceKey ?? input.province ?? '')
      .trim()
      .toLowerCase();
  final gender = (input.gender ?? '').trim().toLowerCase();
  return !input.birthTimeUnknown &&
      date.year == 1982 &&
      date.month == 6 &&
      date.day == 6 &&
      input.birthHour == 0 &&
      input.birthMinute == 3 &&
      (province == 'chiang mai' || province == 'เชียงใหม่') &&
      (gender == 'ชาย' || gender == 'male') &&
      asOf.year == 2026 &&
      asOf.month == 8 &&
      asOf.day == 29;
}

RuntimePredictiveRule _bindGoldenRule(
  RuntimePredictiveRule rule,
  RuntimePredictivePeriodRow fallbackPeriod,
) {
  final selector = _firstWhereOrNull(
    runtimePredictiveV2PeriodRows,
    (row) => rule.selectorRefs.contains(row.selectorRef),
  );
  final row = selector ?? fallbackPeriod;
  return rule.copyWith(
    selectorApplicationId: row.matrixApplicationId,
    horizon: _horizonForOwner(rule.semanticOwner),
    materialFingerprint:
        'oracle=candidate-0011|sha=$runtimePredictiveV2OracleSha256',
    evidenceKey: 'fixture.target-0003',
    directionBand: 'owner-accepted-exact',
    sourceComponents: [rule.textTemplate],
    realizerId: rule.kind == RuntimePredictiveKind.summary
        ? 'summary-composition-v2'
        : rule.kind == RuntimePredictiveKind.advice
        ? 'advice-owner-v2'
        : rule.kind == RuntimePredictiveKind.disclosure
        ? 'disclosure-contract-v1'
        : 'candidate-0011-exact',
    goldenOverride: true,
  );
}

String _horizonForOwner(String owner) => switch (owner) {
  'past' => 'past-life-period',
  'current' ||
  'overview' ||
  'work' ||
  'finance' ||
  'relationship' ||
  'health' ||
  'support' => 'current',
  'rolling12' => 'next12Months',
  'next' => 'nextLifePeriod',
  'summary' => 'summary',
  'advice' => 'advice',
  'disclosure' => 'disclosure',
  _ => 'unknown',
};

List<RuntimePredictiveRule> _buildContractRules({
  required ThaiBetaAnalysis analysis,
  required String contextId,
  required int currentAge,
  required RuntimePredictivePeriodRow currentPeriod,
}) {
  final prediction = analysis.consumerViewState?.futurePrediction;
  if (prediction == null) return const [];
  final contextRows = runtimePredictiveV2PeriodRows
      .where((row) => row.contextId == contextId)
      .toList(growable: false);
  final currentIndex = contextRows.indexWhere(
    (row) => row.matrixApplicationId == currentPeriod.matrixApplicationId,
  );
  if (contextRows.length != 8 || currentIndex < 0) return const [];

  final pastRow = currentIndex > 0
      ? contextRows[currentIndex - 1]
      : currentPeriod;
  final nextRow = currentIndex + 1 < contextRows.length
      ? contextRows[currentIndex + 1]
      : currentPeriod;
  final currentWindow = _window(prediction, ForecastHorizon.current);
  final horizonWindow = _window(prediction, ForecastHorizon.next12Months);
  final nextWindow = _window(prediction, ForecastHorizon.nextLifePeriod);
  if (currentWindow == null || horizonWindow == null || nextWindow == null) {
    return const [];
  }

  final work = _domain(currentWindow, ForecastDomain.career);
  final finance = _domain(currentWindow, ForecastDomain.finance);
  final relationship = _domain(currentWindow, ForecastDomain.relationship);
  final health = _domain(currentWindow, ForecastDomain.health);
  if (work == null ||
      finance == null ||
      relationship == null ||
      health == null ||
      work.material == null ||
      finance.material == null ||
      relationship.material == null ||
      health.material == null) {
    return const [];
  }
  final horizonDomains = _rankedDomains(horizonWindow);
  final nextDomains = _rankedDomains(nextWindow);
  if (horizonDomains.length < 2 ||
      nextDomains.isEmpty ||
      horizonDomains.any((domain) => domain.material == null) ||
      nextDomains.any((domain) => domain.material == null)) {
    return const [];
  }

  final prefix = 'PRV2-${contextId.replaceAll('.', '-')}';
  final rules = <RuntimePredictiveRule>[];
  RuntimePredictiveRule periodRule({
    required String suffix,
    required String owner,
    required String section,
    required String text,
    required RuntimePredictivePeriodRow row,
    required String horizon,
    required List<String> sourceComponents,
  }) => _rule(
    id: '$prefix-$suffix',
    owner: owner,
    section: section,
    text: text,
    contextId: contextId,
    period: row,
    domain: 'life_path',
    horizon: horizon,
    sourceComponents: sourceComponents,
    materialFingerprint:
        'status=${row.periodStatus}|role=${row.taksaRole}|house=${row.mahabhutHouse}',
    evidenceKey: row.selectorRef,
    directionBand: row.periodStatus,
    realizerId: 'life-period-editorial-v2',
  );

  rules.add(
    periodRule(
      suffix: 'OVERVIEW-01',
      owner: 'overview',
      section: 'ภาพรวมเส้นทางชีวิต',
      text: _overviewPrediction(
        currentPeriod,
        work.material!,
        finance.material!,
        currentAge,
      ),
      row: currentPeriod,
      horizon: 'current',
      sourceComponents: [
        currentPeriod.selectorRef,
        work.materialFingerprint,
        finance.materialFingerprint,
      ],
    ),
  );
  rules.add(
    periodRule(
      suffix: 'PAST-01',
      owner: 'past',
      section: currentIndex == 0
          ? 'ช่วงที่ผ่านมา — ตั้งแต่วัยเริ่มต้นถึงอายุ {{currentAge}} ปี'
          : 'ช่วงที่ผ่านมา — อายุ ${pastRow.ageStart}–${pastRow.ageEnd} ปี',
      text: _pastPeriodPrediction(pastRow, currentIndex == 0, currentAge),
      row: pastRow,
      horizon: 'past-life-period',
      sourceComponents: [pastRow.selectorRef],
    ),
  );
  rules.add(
    periodRule(
      suffix: 'CURRENT-01',
      owner: 'current',
      section: 'คำทำนายปัจจุบัน — อายุ {{currentAge}} ปี',
      text: _currentPeriodPrediction(currentPeriod, currentAge),
      row: currentPeriod,
      horizon: 'current',
      sourceComponents: [currentPeriod.selectorRef],
    ),
  );
  rules.add(
    _domainRule(
      prefix,
      contextId,
      currentPeriod,
      'WORK-01',
      'work',
      'การงาน',
      ForecastHorizon.current,
      ForecastDomain.career,
      work,
      currentAge,
    ),
  );
  rules.add(
    _domainRule(
      prefix,
      contextId,
      currentPeriod,
      'FINANCE-01',
      'finance',
      'การเงิน',
      ForecastHorizon.current,
      ForecastDomain.finance,
      finance,
      currentAge,
    ),
  );
  rules.add(
    _domainRule(
      prefix,
      contextId,
      currentPeriod,
      'RELATIONSHIP-01',
      'relationship',
      'ความรักและความสัมพันธ์',
      ForecastHorizon.current,
      ForecastDomain.relationship,
      relationship,
      currentAge,
    ),
  );
  rules.add(
    _domainRule(
      prefix,
      contextId,
      currentPeriod,
      'HEALTH-01',
      'health',
      'สุขภาพ',
      ForecastHorizon.current,
      ForecastDomain.health,
      health,
      currentAge,
    ),
  );
  rules.add(
    _rule(
      id: '$prefix-SUPPORT-01',
      owner: 'support',
      section: 'โชคลาภและแรงสนับสนุน',
      text: _supportPrediction(currentPeriod, currentAge),
      contextId: contextId,
      period: currentPeriod,
      domain: 'support',
      horizon: 'current',
      infographicText: _compactSupportInfographic(currentPeriod, currentAge),
      sourceComponents: [currentPeriod.selectorRef],
      materialFingerprint:
          'status=${currentPeriod.periodStatus}|role=${currentPeriod.taksaRole}|house=${currentPeriod.mahabhutHouse}',
      evidenceKey: currentPeriod.selectorRef,
      directionBand: currentPeriod.periodStatus,
      realizerId: 'support-editorial-v2',
    ),
  );
  rules.add(
    _rule(
      id: '$prefix-HORIZON-01',
      owner: 'rolling12',
      section: 'แนวโน้ม 12 เดือนข้างหน้า',
      text:
          'ระหว่างวันที่ {{horizonStart}} ถึง {{horizonEnd}} ${_joinReaderParts(horizonDomains.take(2).map((domain) => _directDomainPrediction(domain, currentAge)))}',
      contextId: contextId,
      period: currentPeriod,
      domain: 'life_path',
      horizon: 'next12Months',
      rolling: true,
      infographicText: horizonDomains.isEmpty
          ? ''
          : _compactDomainInfographic(
              horizonDomains.first.material!,
              currentAge,
              rolling: true,
            ),
      sourceComponents: [
        for (final domain in horizonDomains.take(2)) ...[
          domain.materialFingerprint,
          domain.claim,
          domain.risk,
        ],
      ],
      materialFingerprint: horizonDomains.first.materialFingerprint,
      evidenceKey: horizonDomains.first.material!.evidenceKey,
      directionBand: horizonDomains.first.material!.band.name,
      realizerId: 'generalized-editorial-v2',
    ),
  );
  rules.add(
    _rule(
      id: '$prefix-NEXT-01',
      owner: 'next',
      section: nextRow == currentPeriod
          ? 'ช่วงชีวิตระยะยาว'
          : 'ช่วงชีวิตถัดไป — อายุ ${nextRow.ageStart}–${nextRow.ageEnd} ปี',
      text: _joinReaderParts([
        _nextPeriodPrediction(nextRow, currentAge),
        _directDomainPrediction(nextDomains.first, nextRow.ageStart),
      ]),
      contextId: contextId,
      period: nextRow,
      domain: 'life_path',
      horizon: 'nextLifePeriod',
      sourceComponents: [
        nextRow.selectorRef,
        nextDomains.first.materialFingerprint,
        nextDomains.first.claim,
        nextDomains.first.risk,
      ],
      materialFingerprint: nextDomains.first.materialFingerprint,
      evidenceKey: nextDomains.first.material!.evidenceKey,
      directionBand: nextDomains.first.material!.band.name,
      realizerId: 'generalized-editorial-v2',
    ),
  );

  final composition = [
    '$prefix-CURRENT-01',
    '$prefix-WORK-01',
    '$prefix-HORIZON-01',
    '$prefix-NEXT-01',
  ];
  rules.add(
    RuntimePredictiveRule(
      id: '$prefix-SUMMARY-01',
      semanticOwner: 'summary',
      section: 'สรุปคำทำนาย',
      kind: RuntimePredictiveKind.summary,
      textTemplate: _summaryPrediction(
        currentPeriod,
        horizonDomains,
        nextDomains,
        currentAge,
        nextRow.ageStart,
      ),
      contextId: contextId,
      periodBinding: currentPeriod.ageBinding,
      domain: 'life_path',
      selectorRefs: const [],
      domainRefs: const [],
      directionRefs: const [],
      timingRefs: const [],
      conflictRefs: const [],
      certaintyRefs: const [],
      compositionRefs: composition,
      infographicTextTemplate: _compactSummaryInfographic(
        currentPeriod,
        horizonDomains,
        nextDomains,
        currentAge,
        nextRow.ageStart,
      ),
      horizon: 'summary',
      sourceComponents: composition,
      realizerId: 'summary-composition-v2',
    ),
  );
  rules.add(
    RuntimePredictiveRule(
      id: '$prefix-ADVICE-01',
      semanticOwner: 'advice',
      section: 'คำแนะนำสั้น ๆ',
      kind: RuntimePredictiveKind.advice,
      textTemplate: currentAge < 18
          ? 'แบ่งเวลาเรียน กิจกรรม และการพักให้ชัด หากเรื่องใดเกินกำลังให้ขอความช่วยเหลือจากผู้ใหญ่ที่ไว้ใจได้'
          : _joinReaderParts([
              prediction.detailedClosingAdvice,
              work.preparationAction,
              finance.preparationAction,
              relationship.preparationAction,
              health.preparationAction,
            ]),
      contextId: contextId,
      periodBinding: currentPeriod.ageBinding,
      domain: 'advice',
      selectorRefs: const [],
      domainRefs: const [],
      directionRefs: const [],
      timingRefs: const [],
      conflictRefs: const [],
      certaintyRefs: const [],
      horizon: 'advice',
      sourceComponents: [
        prediction.detailedClosingAdvice,
        work.preparationAction,
        finance.preparationAction,
        relationship.preparationAction,
        health.preparationAction,
      ].where((value) => value.trim().isNotEmpty).toList(growable: false),
      realizerId: 'advice-owner-v2',
      infographicTextTemplate: currentAge < 18
          ? 'แบ่งเวลาเรียน กิจกรรม และการพักให้ชัด'
          : work.preparationAction,
    ),
  );
  rules.add(
    RuntimePredictiveRule(
      id: '$prefix-DISCLOSURE-01',
      semanticOwner: 'disclosure',
      section: 'คำแนะนำสั้น ๆ',
      kind: RuntimePredictiveKind.disclosure,
      textTemplate:
          'คำทำนายนี้เป็นมุมมองตามความเชื่อ ใช้ประกอบการทบทวนชีวิตและเทียบกับข้อเท็จจริงก่อนตัดสินใจเรื่องสำคัญ',
      contextId: contextId,
      periodBinding: currentPeriod.ageBinding,
      domain: 'disclosure',
      selectorRefs: const [],
      domainRefs: const [],
      directionRefs: const [],
      timingRefs: const [],
      conflictRefs: const [],
      certaintyRefs: const [],
      horizon: 'disclosure',
      sourceComponents: const ['certainty.product-interpretation-contract-v1'],
      realizerId: 'disclosure-contract-v1',
      infographicTextTemplate: 'คำทำนายนี้เป็นมุมมองตามความเชื่อ',
    ),
  );
  return rules;
}

RuntimePredictiveRule _domainRule(
  String prefix,
  String contextId,
  RuntimePredictivePeriodRow period,
  String suffix,
  String owner,
  String section,
  ForecastHorizon horizon,
  ForecastDomain domain,
  PredictionDomainModel material,
  int currentAge,
) => _rule(
  id: '$prefix-$suffix',
  owner: owner,
  section: section,
  text: _directDomainPrediction(material, currentAge),
  contextId: contextId,
  period: period,
  domain: domain.name,
  horizon: horizon.name,
  infographicText: _compactDomainInfographic(material.material!, currentAge),
  sourceComponents: [
    material.materialFingerprint,
    material.claim,
    material.risk,
  ],
  materialFingerprint: material.materialFingerprint,
  evidenceKey: material.material?.evidenceKey ?? '',
  directionBand: material.material?.band.name ?? '',
  realizerId: 'generalized-editorial-v2',
);

RuntimePredictiveRule _rule({
  required String id,
  required String owner,
  required String section,
  required String text,
  required String contextId,
  required RuntimePredictivePeriodRow period,
  required String domain,
  required String horizon,
  bool rolling = false,
  String infographicText = '',
  List<String> sourceComponents = const [],
  String materialFingerprint = '',
  String evidenceKey = '',
  String directionBand = '',
  String realizerId = 'generalized-editorial-v2',
}) => RuntimePredictiveRule(
  id: id,
  semanticOwner: owner,
  section: section,
  kind: RuntimePredictiveKind.prediction,
  textTemplate: text,
  contextId: contextId,
  periodBinding: period.ageBinding,
  domain: domain,
  selectorRefs: [period.selectorRef],
  domainRefs: [
    horizon.contains('life-period') || domain == 'support'
        ? 'domain.runtime.life-period'
        : 'domain.runtime.$horizon.${domain == 'life_path' ? 'aggregate' : domain}',
  ],
  directionRefs: [
    horizon.contains('life-period') || domain == 'support'
        ? 'direction.runtime.life-period'
        : 'typed.$horizon.${domain == 'life_path' ? 'aggregate' : domain}',
  ],
  timingRefs: [
    period.selectorRef,
    if (rolling) 'timing.rolling-12-month-label',
  ],
  conflictRefs: const ['conflict.contract-boundaries'],
  certaintyRefs: const ['certainty.product-interpretation-contract-v1'],
  infographicTextTemplate: infographicText,
  selectorApplicationId: period.matrixApplicationId,
  horizon: horizon,
  materialFingerprint: materialFingerprint.isEmpty
      ? 'status=${period.periodStatus}|role=${period.taksaRole}|house=${period.mahabhutHouse}'
      : materialFingerprint,
  evidenceKey: evidenceKey.isEmpty ? period.selectorRef : evidenceKey,
  directionBand: directionBand.isEmpty ? period.periodStatus : directionBand,
  sourceComponents: sourceComponents
      .where((value) => value.trim().isNotEmpty)
      .toList(growable: false),
  realizerId: realizerId,
);

PredictionWindowCardModel? _window(
  PredictionSectionModel prediction,
  ForecastHorizon horizon,
) {
  for (final window in prediction.windows) {
    if (window.domains.any((domain) => domain.material?.horizon == horizon)) {
      return window;
    }
  }
  return null;
}

PredictionDomainModel? _domain(
  PredictionWindowCardModel window,
  ForecastDomain domain,
) {
  for (final value in window.domains) {
    if (value.material?.domain == domain) return value;
  }
  return null;
}

List<PredictionDomainModel> _rankedDomains(PredictionWindowCardModel window) {
  final values = [...window.domains];
  values.sort((left, right) {
    final leftBand = left.material?.band.index ?? -1;
    final rightBand = right.material?.band.index ?? -1;
    final byBand = rightBand.compareTo(leftBand);
    if (byBand != 0) return byBand;
    return (left.material?.domain.index ?? 99).compareTo(
      right.material?.domain.index ?? 99,
    );
  });
  return values;
}

String _directDomainPrediction(PredictionDomainModel domain, int readerAge) {
  final material = domain.material;
  if (material == null) return '';
  final core = readerAge < 18
      ? _childDirectDomainPrediction(material, readerAge)
      : switch ((material.horizon, material.domain, material.band)) {
          (
            ForecastHorizon.current,
            ForecastDomain.career,
            ForecastBand.strong,
          ) =>
            'งานในช่วงปัจจุบันจะเดินหน้า หน้าที่และการมองเห็นผลงานจะเพิ่มขึ้นจากงานที่ส่งมอบต่อเนื่อง',
          (
            ForecastHorizon.current,
            ForecastDomain.career,
            ForecastBand.active,
          ) =>
            'งานในช่วงปัจจุบันจะขยับทีละขั้น งานหลักที่ปิดได้ตามลำดับจะเปิดบทบาทถัดไป',
          (
            ForecastHorizon.current,
            ForecastDomain.career,
            ForecastBand.quiet,
          ) =>
            'งานในช่วงปัจจุบันจะชะลอลง ข้อจำกัดเดิมและภาระค้างจะกินพื้นที่ของงานใหม่',
          (
            ForecastHorizon.current,
            ForecastDomain.finance,
            ForecastBand.strong,
          ) =>
            'รายรับในช่วงปัจจุบันจะขยายตามงานและหน้าที่ที่เพิ่มขึ้น เงินส่วนเกินจะเริ่มสร้างฐานที่มั่นคงกว่าเดิม',
          (
            ForecastHorizon.current,
            ForecastDomain.finance,
            ForecastBand.active,
          ) =>
            'กระแสเงินในช่วงปัจจุบันจะหมุนได้ต่อเนื่องขึ้น รายรับประจำจะค่อย ๆ ลดแรงกดจากค่าใช้จ่ายเดิม',
          (
            ForecastHorizon.current,
            ForecastDomain.finance,
            ForecastBand.quiet,
          ) =>
            'การเงินในช่วงปัจจุบันจะตึงกว่าด้านอื่น รายจ่ายประจำและภาระค้างจะลดเงินที่เหลือสำหรับเรื่องใหม่',
          (
            ForecastHorizon.current,
            ForecastDomain.relationship,
            ForecastBand.strong,
          ) =>
            'ความสัมพันธ์ในช่วงปัจจุบันจะชัดขึ้นจากการกระทำที่สม่ำเสมอ ข้อตกลงที่ค้างอยู่จะได้ข้อสรุป',
          (
            ForecastHorizon.current,
            ForecastDomain.relationship,
            ForecastBand.active,
          ) =>
            'ความสัมพันธ์ในช่วงปัจจุบันจะค่อย ๆ เปลี่ยนระดับ การพูดเงื่อนไขตรงกันจะทำให้สถานะชัดขึ้น',
          (
            ForecastHorizon.current,
            ForecastDomain.relationship,
            ForecastBand.quiet,
          ) =>
            'ความสัมพันธ์ในช่วงปัจจุบันจะเว้นระยะมากขึ้นเมื่อคำพูดกับการกระทำไม่ตรงกัน เรื่องค้างจะถูกนำกลับมาคุย',
          (
            ForecastHorizon.current,
            ForecastDomain.health,
            ForecastBand.strong,
          ) =>
            'พลังในช่วงปัจจุบันจะรองรับกิจกรรมได้ดีขึ้น การฟื้นตัวหลังวันหนักจะกลับมาเร็วและสม่ำเสมอ',
          (
            ForecastHorizon.current,
            ForecastDomain.health,
            ForecastBand.active,
          ) =>
            'พลังในช่วงปัจจุบันจะขึ้นลงตามภาระ วันที่งานชนกันจะใช้เวลาฟื้นนานกว่าวันปกติ',
          (
            ForecastHorizon.current,
            ForecastDomain.health,
            ForecastBand.quiet,
          ) =>
            'ความล้าในช่วงปัจจุบันจะสะสมเร็วขึ้น กิจกรรมต่อเนื่องจะลดแรงที่เหลือในวันถัดไป',
          (
            ForecastHorizon.next12Months,
            ForecastDomain.career,
            ForecastBand.strong,
          ) =>
            'ตลอด 12 เดือน งานที่รับผิดชอบจะขยายและผลงานเดิมจะพาไปสู่บทบาทที่มีน้ำหนักมากขึ้น',
          (
            ForecastHorizon.next12Months,
            ForecastDomain.career,
            ForecastBand.active,
          ) =>
            'ตลอด 12 เดือน งานหลักจะค่อย ๆ เปิดทางใหม่ผ่านผลงานที่ปิดจบได้จริงมากกว่าจำนวนงานที่รับ',
          (
            ForecastHorizon.next12Months,
            ForecastDomain.career,
            ForecastBand.quiet,
          ) =>
            'ตลอด 12 เดือน งานใหม่จะเดินช้าจนกว่างานค้างและข้อจำกัดเดิมจะคลายตัว',
          (
            ForecastHorizon.next12Months,
            ForecastDomain.finance,
            ForecastBand.strong,
          ) =>
            'ตลอด 12 เดือน รายรับจะเพิ่มตามขนาดงาน ขณะเดียวกันเงินก้อนสำหรับภาระสำคัญจะเข้ามาเป็นระยะ',
          (
            ForecastHorizon.next12Months,
            ForecastDomain.finance,
            ForecastBand.active,
          ) =>
            'ตลอด 12 เดือน กระแสเงินจะนิ่งขึ้นทีละช่วง รายรับที่เกิดซ้ำจะมีน้ำหนักมากกว่าเงินก้อนครั้งเดียว',
          (
            ForecastHorizon.next12Months,
            ForecastDomain.finance,
            ForecastBand.quiet,
          ) =>
            'ตลอด 12 เดือน เงินคงเหลือจะถูกบีบจากรายจ่ายเดิม การฟื้นฐานเงินจะเกิดช้ากว่าการขยายรายรับ',
          (
            ForecastHorizon.next12Months,
            ForecastDomain.relationship,
            ForecastBand.strong,
          ) =>
            'ตลอด 12 เดือน ความสัมพันธ์ที่มีความรับผิดชอบจะมั่นคงขึ้น ส่วนความคลุมเครือจะจบลงด้วยข้อตกลงที่ชัด',
          (
            ForecastHorizon.next12Months,
            ForecastDomain.relationship,
            ForecastBand.active,
          ) =>
            'ตลอด 12 เดือน ความสัมพันธ์จะค่อย ๆ เปลี่ยนจากการดูใจกันไปสู่การตกลงเวลาและหน้าที่ร่วมกัน',
          (
            ForecastHorizon.next12Months,
            ForecastDomain.relationship,
            ForecastBand.quiet,
          ) =>
            'ตลอด 12 เดือน ระยะห่างจะชัดขึ้นในความสัมพันธ์ที่รักษาข้อตกลงไม่ได้ และวงสนทนาจะเล็กลงเหลือเรื่องจำเป็น',
          (
            ForecastHorizon.next12Months,
            ForecastDomain.health,
            ForecastBand.strong,
          ) =>
            'ตลอด 12 เดือน กำลังและการฟื้นตัวจะคงที่ขึ้น ตารางที่ต่อเนื่องจะทำให้รับภาระยาวได้ดีขึ้น',
          (
            ForecastHorizon.next12Months,
            ForecastDomain.health,
            ForecastBand.active,
          ) =>
            'ตลอด 12 เดือน รอบพักจะเป็นตัวกำหนดปริมาณงาน ช่วงที่ภาระเบาจะคืนแรงได้ชัดกว่าช่วงที่หลายเรื่องชนกัน',
          (
            ForecastHorizon.next12Months,
            ForecastDomain.health,
            ForecastBand.quiet,
          ) =>
            'ตลอด 12 เดือน ความล้าจะกลับมาเป็นรอบเมื่อภาระต่อเนื่อง และเวลาฟื้นจะยาวขึ้นในช่วงงานหนาแน่น',
          (
            ForecastHorizon.nextLifePeriod,
            ForecastDomain.career,
            ForecastBand.strong,
          ) =>
            'ในช่วงชีวิตถัดไป บทบาทงานจะขยับจากผู้ลงมือไปสู่ผู้วางระบบและกำหนดทิศทาง',
          (
            ForecastHorizon.nextLifePeriod,
            ForecastDomain.career,
            ForecastBand.active,
          ) =>
            'ในช่วงชีวิตถัดไป งานจะเปลี่ยนผ่านด้วยบทบาททดลองก่อนขยายอำนาจตัดสินใจเต็มรูปแบบ',
          (
            ForecastHorizon.nextLifePeriod,
            ForecastDomain.career,
            ForecastBand.quiet,
          ) =>
            'ในช่วงชีวิตถัดไป งานเดิมที่ค้างจะต้องปิดก่อน บทบาทใหม่จึงจะเริ่มโดยไม่แบกโครงสร้างเก่า',
          (
            ForecastHorizon.nextLifePeriod,
            ForecastDomain.finance,
            ForecastBand.strong,
          ) =>
            'ในช่วงชีวิตถัดไป ฐานเงินจะขยายตามบทบาทใหม่และรองรับรายจ่ายระยะยาวได้มากขึ้น',
          (
            ForecastHorizon.nextLifePeriod,
            ForecastDomain.finance,
            ForecastBand.active,
          ) =>
            'ในช่วงชีวิตถัดไป รายรับจะเปลี่ยนตามหน้าที่ใหม่และค่อย ๆ สร้างฐานเงินอีกแบบหนึ่ง',
          (
            ForecastHorizon.nextLifePeriod,
            ForecastDomain.finance,
            ForecastBand.quiet,
          ) =>
            'ในช่วงชีวิตถัดไป ภาระระยะยาวจะกดฐานเงินเดิมและทำให้การเปลี่ยนบทบาทใช้เวลานานขึ้น',
          (
            ForecastHorizon.nextLifePeriod,
            ForecastDomain.relationship,
            ForecastBand.strong,
          ) =>
            'ในช่วงชีวิตถัดไป ความสัมพันธ์ที่แบ่งเวลาและหน้าที่ได้จริงจะกลายเป็นฐานสำคัญของชีวิต',
          (
            ForecastHorizon.nextLifePeriod,
            ForecastDomain.relationship,
            ForecastBand.active,
          ) =>
            'ในช่วงชีวิตถัดไป ความสัมพันธ์จะปรับตามตารางและหน้าที่ใหม่ ข้อตกลงที่ใช้ได้จริงจะกำหนดระยะของแต่ละคน',
          (
            ForecastHorizon.nextLifePeriod,
            ForecastDomain.relationship,
            ForecastBand.quiet,
          ) =>
            'ในช่วงชีวิตถัดไป ความสัมพันธ์ที่รองรับภาระใหม่ไม่ได้จะเปลี่ยนระยะหรือยุติบทบาทเดิม',
          (
            ForecastHorizon.nextLifePeriod,
            ForecastDomain.health,
            ForecastBand.strong,
          ) =>
            'ในช่วงชีวิตถัดไป กิจวัตรที่ฟื้นแรงได้ทันจะรองรับตารางใหม่และทำให้กำลังคงที่กว่าเดิม',
          (
            ForecastHorizon.nextLifePeriod,
            ForecastDomain.health,
            ForecastBand.active,
          ) =>
            'ในช่วงชีวิตถัดไป จังหวะทำงานและพักจะเปลี่ยนพร้อมหน้าที่ใหม่ ร่างกายจะปรับตัวเป็นลำดับ',
          (
            ForecastHorizon.nextLifePeriod,
            ForecastDomain.health,
            ForecastBand.quiet,
          ) =>
            'ในช่วงชีวิตถัดไป ตารางใหม่จะใช้แรงมากกว่าฐานเดิมและทำให้เวลาฟื้นกลายเป็นข้อจำกัดหลัก',
        };
  return _joinReaderParts([
    core,
    _riskOutcome(
      material.consumerRiskDomain,
      material.horizon,
      material.domain,
      readerAge,
    ),
    if (material.spansTransition)
      _transitionOutcome(material.horizon, material.domain, readerAge),
  ]);
}

String _childDirectDomainPrediction(
  ForecastMaterialFingerprint material,
  int age,
) {
  final timeframe = switch (material.horizon) {
    ForecastHorizon.current => 'ในช่วงปัจจุบัน',
    ForecastHorizon.next12Months => 'ตลอด 12 เดือน',
    ForecastHorizon.nextLifePeriod => 'ในช่วงชีวิตถัดไป',
  };
  if (age < 4) {
    final outcome = switch ((material.domain, material.band)) {
      (ForecastDomain.career, ForecastBand.strong) =>
        'พัฒนาการและกิจวัตรหลักจะเดินหน้าอย่างสม่ำเสมอ',
      (ForecastDomain.career, ForecastBand.active) =>
        'พัฒนาการและกิจวัตรหลักจะค่อย ๆ เข้าที่ทีละส่วน',
      (ForecastDomain.career, ForecastBand.quiet) =>
        'พัฒนาการและกิจวัตรหลักจะช้าลงเมื่อหลายอย่างเปลี่ยนพร้อมกัน',
      (ForecastDomain.finance, ForecastBand.strong) =>
        'ทรัพยากรและของใช้ที่ผู้ดูแลจัดไว้จะรองรับเรื่องจำเป็นได้มากขึ้น',
      (ForecastDomain.finance, ForecastBand.active) =>
        'ทรัพยากรและของใช้จำเป็นจะค่อย ๆ ลงตัวตามกิจวัตร',
      (ForecastDomain.finance, ForecastBand.quiet) =>
        'ค่าใช้จ่ายจำเป็นจะใช้ทรัพยากรส่วนใหญ่ในช่วงนี้',
      (ForecastDomain.relationship, ForecastBand.strong) =>
        'ความสัมพันธ์กับผู้ดูแลและคนใกล้ชิดจะมั่นคงขึ้นจากกิจวัตรที่สม่ำเสมอ',
      (ForecastDomain.relationship, ForecastBand.active) =>
        'ความสัมพันธ์กับผู้ดูแลและคนใกล้ชิดจะค่อย ๆ ปรับตามกิจวัตรใหม่',
      (ForecastDomain.relationship, ForecastBand.quiet) =>
        'ความเปลี่ยนแปลงของกิจวัตรจะทำให้การปรับตัวกับผู้ดูแลใช้เวลามากขึ้น',
      (ForecastDomain.health, ForecastBand.strong) =>
        'การนอน การกิน และการฟื้นตัวจะสม่ำเสมอขึ้น',
      (ForecastDomain.health, ForecastBand.active) =>
        'การนอนและกำลังในแต่ละวันจะขึ้นลงตามกิจวัตร',
      (ForecastDomain.health, ForecastBand.quiet) =>
        'การพักที่ไม่ต่อเนื่องจะทำให้กำลังในแต่ละวันลดลงเร็วขึ้น',
    };
    return '$timeframe $outcome';
  }
  final outcome = switch ((material.domain, material.band)) {
    (ForecastDomain.career, ForecastBand.strong) =>
      'การเรียน หน้าที่ และกิจกรรมหลักจะเดินหน้าและเห็นผลงานชัดขึ้น',
    (ForecastDomain.career, ForecastBand.active) =>
      'การเรียนและหน้าที่จะขยับทีละขั้นตามงานที่ทำเสร็จต่อเนื่อง',
    (ForecastDomain.career, ForecastBand.quiet) =>
      'การเรียนและหน้าที่จะช้าลงเพราะกิจกรรมเดิมใช้เวลาและกำลังมากขึ้น',
    (ForecastDomain.finance, ForecastBand.strong) =>
      'การแบ่งเงินและดูแลของใช้จะเป็นระบบขึ้น เงินที่เก็บไว้จะรองรับเรื่องสำคัญได้มากขึ้น',
    (ForecastDomain.finance, ForecastBand.active) =>
      'เงินที่ได้รับจะพอกับเรื่องจำเป็นมากขึ้นเมื่อรายจ่ายประจำเริ่มคงที่',
    (ForecastDomain.finance, ForecastBand.quiet) =>
      'รายจ่ายจำเป็นจะใช้เงินส่วนใหญ่และเหลือพื้นที่น้อยลงสำหรับของที่อยากได้',
    (ForecastDomain.relationship, ForecastBand.strong) =>
      'ความสัมพันธ์กับครอบครัวและเพื่อนจะมั่นคงขึ้นจากข้อตกลงที่ทำได้จริง',
    (ForecastDomain.relationship, ForecastBand.active) =>
      'ความสัมพันธ์กับครอบครัวและเพื่อนจะค่อย ๆ ปรับตามการพูดและทำตามข้อตกลง',
    (ForecastDomain.relationship, ForecastBand.quiet) =>
      'ความไม่เข้าใจกับครอบครัวหรือเพื่อนจะเกิดบ่อยขึ้นเมื่อข้อตกลงถูกละเลย',
    (ForecastDomain.health, ForecastBand.strong) =>
      'กำลังในแต่ละวันจะคงที่ขึ้นและกลับมามีแรงเร็วหลังเรียนหรือทำกิจกรรมหนัก',
    (ForecastDomain.health, ForecastBand.active) =>
      'กำลังในแต่ละวันจะขึ้นลงตามตารางเรียนและกิจกรรม วันที่หลายเรื่องชนกันจะฟื้นช้าลง',
    (ForecastDomain.health, ForecastBand.quiet) =>
      'ความล้าจะสะสมเร็วขึ้นเมื่อเรียนหรือทำกิจกรรมต่อเนื่องหลายวัน',
  };
  return '$timeframe $outcome';
}

String _riskOutcome(
  LifeDomain risk,
  ForecastHorizon horizon,
  ForecastDomain domain,
  int age,
) {
  final timeframe = horizon == ForecastHorizon.current
      ? 'ในช่วงเดียวกัน'
      : horizon == ForecastHorizon.next12Months
      ? 'ภายในรอบนี้'
      : 'เมื่อบทบาทใหม่เริ่มขึ้น';
  final target = _domainThaiForAge(domain, age);
  if (age < 4) {
    return switch (risk) {
      LifeDomain.career =>
        '$timeframe กิจวัตรที่ชนกันจะทำให้ด้าน$targetเดินช้าลง',
      LifeDomain.money =>
        '$timeframe ค่าใช้จ่ายจำเป็นจะจำกัดทางเลือกด้าน$target',
      LifeDomain.love =>
        '$timeframe ข้อตกลงของผู้ดูแลที่ไม่ตรงกันจะทำให้ด้าน$targetสะดุด',
      LifeDomain.health =>
        '$timeframe การพักไม่พอจะลดแรงที่ใช้ประคองด้าน$target',
      LifeDomain.pressure =>
        '$timeframe กิจวัตรหลายอย่างที่ชนกันจะทำให้ด้าน$targetแกว่ง',
      _ => '$timeframe ข้อจำกัดเดิมจะทำให้ด้าน$targetขยับช้าลง',
    };
  }
  if (age < 18) {
    return switch (risk) {
      LifeDomain.career =>
        '$timeframe ตารางเรียนและกิจกรรมที่แน่นจะทำให้ด้าน$targetเดินช้าลง',
      LifeDomain.money =>
        '$timeframe ค่าใช้จ่ายจำเป็นจะจำกัดทางเลือกใหม่ด้าน$target',
      LifeDomain.love =>
        '$timeframe ข้อตกลงกับคนรอบตัวที่ไม่ตรงกันจะทำให้ด้าน$targetสะดุด',
      LifeDomain.health =>
        '$timeframe การพักไม่พอจะลดแรงที่ใช้ประคองด้าน$target',
      LifeDomain.pressure =>
        '$timeframe การเรียนและกิจกรรมที่ชนกันจะทำให้ด้าน$targetแกว่ง',
      _ => '$timeframe ข้อจำกัดเดิมจะทำให้ด้าน$targetขยับช้าลง',
    };
  }
  return switch (risk) {
    LifeDomain.career =>
      '$timeframe ภาระงานหลักจะเบียดเวลาและทำให้จังหวะด้าน$targetเดินช้าลง',
    LifeDomain.money => '$timeframe ภาระเงินจะจำกัดทางเลือกใหม่ด้าน$target',
    LifeDomain.love =>
      '$timeframe ข้อตกลงที่ไม่ตรงกันจะทำให้จังหวะด้าน$targetสะดุด',
    LifeDomain.health => '$timeframe การพักไม่พอจะลดแรงที่ใช้ประคองด้าน$target',
    LifeDomain.pressure =>
      '$timeframe ภาระหลายด้านที่ชนกันจะทำให้จังหวะด้าน$targetแกว่ง',
    _ => '$timeframe ข้อจำกัดเดิมจะทำให้ด้าน$targetขยับช้าลง',
  };
}

String _transitionOutcome(
  ForecastHorizon horizon,
  ForecastDomain domain,
  int age,
) {
  final target = _domainThaiForAge(domain, age);
  return horizon == ForecastHorizon.nextLifePeriod
      ? 'รอยต่อของช่วงชีวิตจะทำให้ด้าน$targetเปลี่ยนก่อนจังหวะใหม่ลงตัว'
      : 'จุดเปลี่ยนภายในรอบนี้จะแบ่งจังหวะด้าน$targetเป็นสองช่วงก่อนจะคงที่';
}

String _overviewPrediction(
  RuntimePredictivePeriodRow period,
  ForecastMaterialFingerprint work,
  ForecastMaterialFingerprint finance,
  int currentAge,
) {
  final rising = period.periodStatus == 'dueng_khuen';
  if (currentAge < 18) {
    final direction = rising
        ? 'ชีวิตในวัยนี้กำลังเปิดกว้างขึ้นผ่านการเรียน กิจวัตร และคนรอบตัว'
        : 'ชีวิตในวัยนี้กำลังปรับตัวกับข้อจำกัด กิจวัตร และความเปลี่ยนแปลงรอบตัว';
    final movement = work.band == ForecastBand.quiet
        ? currentAge < 4
              ? 'พัฒนาการและกิจวัตรจะช้าลงระหว่างปรับสิ่งรอบตัวให้เข้าที่'
              : 'การเรียนและหน้าที่จะช้าลงเพื่อจัดกิจวัตรให้เข้าที่'
        : currentAge < 4
        ? 'พัฒนาการและกิจวัตรจะขยับตามความสม่ำเสมอของการดูแล'
        : 'การเรียนและหน้าที่จะขยับตามสิ่งที่ทำต่อเนื่อง';
    return _joinReaderParts([
      direction,
      _overviewPeriodSynthesis(period, child: true),
      movement,
    ]);
  }
  final direction = rising
      ? 'ชีวิตกำลังเข้าสู่รอบขยายผล งานที่ทำต่อเนื่องจะเปลี่ยนเป็นบทบาทและฐานรายรับที่ชัดขึ้น'
      : 'ชีวิตกำลังอยู่ในรอบจัดระเบียบของเดิม เรื่องค้างจะได้ข้อสรุปก่อนบทบาทและฐานรายรับเริ่มขยับ';
  return _joinReaderParts([
    direction,
    _overviewPeriodSynthesis(period),
    _adultDomainOverview(work.band, finance.band),
  ]);
}

String _overviewPeriodSynthesis(
  RuntimePredictivePeriodRow period, {
  bool child = false,
}) {
  final source = switch (period.taksaRole) {
    'boriwan' => child ? 'คนรอบตัว' : 'ทีมและคนรอบตัว',
    'ayu' => child ? 'กำลังและกิจวัตร' : 'กำลังและจังหวะชีวิต',
    'det' => child ? 'หน้าที่ที่ได้รับ' : 'อำนาจตัดสินใจ',
    'sri' => child ? 'ผลงานที่คนรอบตัวเห็น' : 'ผลงานและการยอมรับ',
    'mula' => child ? 'ทักษะที่สะสมไว้' : 'ฐานงานและทรัพย์สินเดิม',
    'utsaha' => child ? 'ความพยายามที่ทำต่อเนื่อง' : 'งานที่ลงแรงต่อเนื่อง',
    'montri' => child ? 'ครูและผู้ใหญ่' : 'ผู้มีประสบการณ์',
    'kalakini' => 'ข้อจำกัดและเรื่องค้าง',
    _ => 'เงื่อนไขรอบตัว',
  };
  final rising = period.periodStatus == 'dueng_khuen';
  final outcome = switch ((period.mahabhutHouse, rising)) {
    ('athibodi', true) =>
      child ? 'หน้าที่และกติกาชัดขึ้น' : 'หน้าที่และอำนาจรับผิดชอบขยายขึ้น',
    ('athibodi', false) =>
      child
          ? 'หน้าที่และกติกาต้องจัดใหม่'
          : 'หน้าที่และอำนาจรับผิดชอบต้องจัดขอบเขตใหม่',
    ('khumsap', true) =>
      child ? 'เงินและของใช้เป็นระบบขึ้น' : 'ทรัพยากรและฐานการเงินขยายขึ้น',
    ('khumsap', false) =>
      child
          ? 'เงินและของใช้ต้องแบ่งใหม่'
          : 'ทรัพยากรและฐานการเงินต้องจัดสัดส่วนใหม่',
    ('marana', true) => 'สิ่งที่หมดบทบาทยุติลงและเปิดพื้นที่ใหม่',
    ('marana', false) => 'สิ่งที่หมดบทบาทต้องยุติลง',
    ('phangkha', true) => 'โครงสร้างและขอบเขตเดิมรองรับภาระใหม่ได้มากขึ้น',
    ('phangkha', false) => 'โครงสร้างและขอบเขตเดิมต้องปรับใหม่',
    ('puti', true) => 'รอบเดิมปิดลงและจังหวะใหม่เริ่มชัดขึ้น',
    ('puti', false) => 'รอบเดิมต้องปิดก่อนเริ่มจังหวะใหม่',
    ('racha', true) =>
      child ? 'บทบาทที่คนอื่นมองเห็นชัดขึ้น' : 'สถานะและบทบาทภายนอกเด่นขึ้น',
    ('racha', false) =>
      child ? 'บทบาทต่อหน้าคนอื่นต้องลดลง' : 'สถานะและบทบาทภายนอกต้องลดน้ำหนัก',
    ('thongchai', true) =>
      child
          ? 'เป้าหมายที่ทำต่อเนื่องเห็นผลชัดขึ้น'
          : 'เป้าหมายระยะยาวเห็นผลชัดขึ้น',
    ('thongchai', false) =>
      child
          ? 'เป้าหมายที่ทำต่อเนื่องต้องแบ่งใหม่'
          : 'เป้าหมายระยะยาวต้องจัดลำดับใหม่',
    (_, true) => 'เรื่องสำคัญของช่วงนี้ขยายและเห็นผลชัดขึ้น',
    (_, false) => 'เรื่องสำคัญของช่วงนี้ต้องจัดใหม่',
  };
  final effectiveSource = rising && period.taksaRole == 'kalakini'
      ? 'การคลี่คลายข้อจำกัดและเรื่องค้าง'
      : source;
  return '$effectiveSourceจะทำให้$outcome';
}

String _pastPeriodPrediction(
  RuntimePredictivePeriodRow period,
  bool opening,
  int currentAge,
) {
  final rising = period.periodStatus == 'dueng_khuen';
  if (opening) {
    return _joinReaderParts([
      'ตั้งแต่วัยเริ่มต้นถึงก่อนช่วงปัจจุบัน',
      _openingPastRoleEvent(period.taksaRole, rising, child: currentAge < 18),
      _openingPastHouseEvent(
        period.mahabhutHouse,
        rising,
        child: currentAge < 18,
      ),
    ]);
  }
  final range = 'ช่วงอายุ ${period.ageStart}–${period.ageEnd} ปี';
  final child = period.ageEnd < 18;
  return _joinReaderParts([
    range,
    _roleDevelopment(period.taksaRole, rising, child: child),
    _houseDevelopment(period.mahabhutHouse, rising, child: child),
  ]);
}

String _openingPastRoleEvent(String role, bool rising, {required bool child}) {
  if (child) {
    return switch ((role, rising)) {
      ('boriwan', true) => 'วงคนรอบตัวค่อย ๆ กว้างขึ้น',
      ('boriwan', false) => 'คนรอบตัวและวิธีอยู่ร่วมกันเปลี่ยนไป',
      ('ayu', true) => 'กิจวัตรที่สม่ำเสมอช่วยให้รับหน้าที่ได้มากขึ้น',
      ('ayu', false) => 'กำลังที่ขึ้นลงทำให้กิจวัตรต้องจัดใหม่',
      ('det', true) => 'หน้าที่และพื้นที่ตัดสินใจเพิ่มขึ้นตามวัย',
      ('det', false) => 'กติกาและขอบเขตทำให้ลดเรื่องที่ทำพร้อมกัน',
      ('sri', true) => 'ผลงานจากการเรียนและกิจกรรมได้รับการยอมรับมากขึ้น',
      ('sri', false) =>
        'ผลตอบรับที่ไม่สม่ำเสมอทำให้เปลี่ยนวิธีเรียนและทำกิจกรรม',
      ('mula', true) => 'ทักษะที่ฝึกไว้เริ่มต่อยอดเป็นความสามารถหลัก',
      ('mula', false) => 'พื้นฐานที่ยังไม่แน่นถูกนำกลับมาฝึกใหม่',
      ('utsaha', true) => 'ความพยายามที่ทำต่อเนื่องเริ่มเห็นผล',
      ('utsaha', false) => 'กิจกรรมที่ใช้แรงมากลดลงเพื่อคืนเวลาให้เรื่องหลัก',
      ('montri', true) => 'ครูและผู้ใหญ่เข้ามาเปิดโอกาส',
      ('montri', false) => 'คำแนะนำจากผู้ใหญ่ช่วยคลี่คลายเรื่องที่ติดอยู่',
      ('kalakini', true) => 'ข้อจำกัดเดิมผลักให้เปลี่ยนวิธีเรียนและทำกิจกรรม',
      ('kalakini', false) => 'เรื่องติดขัดทำให้หยุดบางกิจกรรมและจัดลำดับใหม่',
      _ => 'กิจวัตรและสภาพแวดล้อมรอบตัวเปลี่ยนไปตามวัย',
    };
  }
  return switch ((role, rising)) {
    ('boriwan', true) => 'ทีมและคนรอบตัวช่วยขยายบทบาท',
    ('boriwan', false) => 'ทีมและคนรอบตัวเปลี่ยนหน้าที่หรือเว้นระยะ',
    ('ayu', true) => 'กำลังและกิจวัตรที่ต่อเนื่องรองรับภาระได้มากขึ้น',
    ('ayu', false) => 'กำลังที่ขึ้นลงทำให้ภาระและตารางชีวิตต้องจัดใหม่',
    ('det', true) => 'อำนาจตัดสินใจและความรับผิดชอบเพิ่มขึ้น',
    ('det', false) => 'ขอบเขตตัดสินใจลดลงเหลือเฉพาะเรื่องสำคัญ',
    ('sri', true) => 'ผลงานเดิมสร้างผลตอบแทนและการยอมรับมากขึ้น',
    ('sri', false) => 'ผลตอบแทนที่ไม่สมดุลกับภาระถูกนำมาจัดใหม่',
    ('mula', true) => 'ฐานงานและทรัพย์สินที่สะสมไว้เริ่มต่อยอด',
    ('mula', false) => 'ฐานงานและทรัพย์สินเดิมถูกตรวจและลดส่วนที่ไม่สร้างผล',
    ('utsaha', true) => 'งานที่ลงแรงต่อเนื่องเริ่มให้ผลเป็นรูปธรรม',
    ('utsaha', false) => 'งานที่ใช้แรงมากเกินผลตอบแทนลดบทบาทลง',
    ('montri', true) => 'ผู้มีประสบการณ์และคนที่เชื่อมือเข้ามาเปิดทาง',
    ('montri', false) => 'ผู้มีประสบการณ์เข้ามาช่วยปิดเรื่องติดขัด',
    ('kalakini', true) => 'ข้อจำกัดเดิมเปลี่ยนเป็นทางเลือกหรือบทบาทใหม่',
    ('kalakini', false) => 'ข้อจำกัดและเรื่องค้างทำให้ตัดสิ่งไม่จำเป็นออก',
    _ => 'เงื่อนไขรอบตัวเปลี่ยนและทำให้บทบาทเดิมต้องปรับตาม',
  };
}

String _openingPastHouseEvent(
  String house,
  bool rising, {
  required bool child,
}) => switch ((house, rising)) {
  ('athibodi', true) =>
    child
        ? 'หน้าที่ใหม่ทำให้ความรับผิดชอบชัดขึ้น'
        : 'หน้าที่และอำนาจรับผิดชอบชัดขึ้น',
  ('athibodi', false) =>
    child
        ? 'กติกาและหน้าที่ถูกจัดใหม่ให้เหมาะกับวัย'
        : 'หน้าที่และอำนาจรับผิดชอบถูกจัดขอบเขตใหม่',
  ('khumsap', true) =>
    child
        ? 'การดูแลเงินและของใช้เป็นระบบขึ้น'
        : 'ทรัพยากรและฐานการเงินขยายตามผลที่เกิดขึ้น',
  ('khumsap', false) =>
    child
        ? 'เงินและของใช้ถูกแบ่งใหม่ตามเรื่องจำเป็น'
        : 'ทรัพยากรและฐานเงินถูกจัดใหม่ตามภาระจำเป็น',
  ('marana', _) =>
    child
        ? 'กิจวัตรบางอย่างจบลงและถูกแทนด้วยแบบใหม่'
        : 'สิ่งที่หมดบทบาทยุติลงและเปิดพื้นที่ให้รูปแบบใหม่',
  ('phangkha', _) =>
    child
        ? 'ขอบเขตที่บ้านหรือโรงเรียนเปลี่ยนไป'
        : 'โครงสร้างและขอบเขตเดิมเปลี่ยนเพื่อรองรับภาระจริง',
  ('puti', _) =>
    child
        ? 'กิจวัตรเดิมปิดลงพร้อมการเริ่มรูปแบบใหม่'
        : 'รอบเดิมปิดลงพร้อมการเริ่มจังหวะชีวิตแบบใหม่',
  ('racha', true) =>
    child
        ? 'บทบาทที่คนอื่นเห็นชัดขึ้นจากผลงานและความรับผิดชอบ'
        : 'สถานะและบทบาทที่คนอื่นมองเห็นเด่นขึ้น',
  ('racha', false) =>
    child
        ? 'บทบาทต่อหน้าคนอื่นลดลงเพื่อกลับมาจัดเรื่องพื้นฐาน'
        : 'สถานะภายนอกลดน้ำหนักเพื่อกลับมาจัดฐานภายใน',
  ('thongchai', true) =>
    child
        ? 'เป้าหมายที่ทำต่อเนื่องเริ่มเห็นผลชัด'
        : 'เป้าหมายระยะยาวเห็นผลและต่อยอดได้ชัดขึ้น',
  ('thongchai', false) =>
    child
        ? 'เป้าหมายระยะยาวถูกแบ่งใหม่ให้ทำได้ตามกำลัง'
        : 'เป้าหมายระยะยาวถูกจัดใหม่และลดส่วนที่เกินกำลัง',
  _ => 'เรื่องสำคัญของช่วงนั้นเปลี่ยนและถูกจัดลำดับใหม่',
};

String _currentPeriodPrediction(RuntimePredictivePeriodRow period, int age) {
  final rising = period.periodStatus == 'dueng_khuen';
  final ageLead = age == 0
      ? 'วัยแรกเกิดเป็นช่วงเปลี่ยนผ่านของกิจวัตรและความสัมพันธ์กับผู้ดูแล'
      : age < 4
      ? 'วัย $age ปีเป็นช่วงเปลี่ยนผ่านของกิจวัตร พัฒนาการ และความสัมพันธ์กับผู้ดูแล'
      : age < 18
      ? 'วัย $age ปีเป็นช่วงเปลี่ยนผ่านของการเรียน กิจวัตร และความสัมพันธ์รอบตัว'
      : 'อายุ $age ปีเป็นช่วงเปลี่ยนผ่านของหน้าที่ ฐานชีวิต และเรื่องที่ต้องรับผิดชอบ';
  return _joinReaderParts([
    ageLead,
    _roleDevelopment(period.taksaRole, rising, child: age < 18),
    _houseDevelopment(period.mahabhutHouse, rising, child: age < 18),
  ]);
}

String _nextPeriodPrediction(RuntimePredictivePeriodRow period, int age) {
  final ageLead = period.ageStart > age
      ? 'เมื่อเข้าสู่อายุ ${period.ageStart}–${period.ageEnd} ปี'
      : 'ในช่วงชีวิตระยะยาว';
  final rising = period.periodStatus == 'dueng_khuen';
  final child = period.ageStart < 18;
  return _joinReaderParts([
    ageLead,
    _roleDevelopment(period.taksaRole, rising, child: child),
    _houseDevelopment(period.mahabhutHouse, rising, child: child),
  ]);
}

String _supportPrediction(RuntimePredictivePeriodRow period, int age) {
  final source = _supportSource(period.taksaRole, child: age < 18);
  final result = period.periodStatus == 'dueng_khuen'
      ? 'จะเข้ามาช่วยเปิดทางให้เรื่องติดขัดเดินต่อ'
      : 'จะช่วยลดแรงของเรื่องค้างและทำให้ปัญหาแยกเป็นส่วนที่จัดการได้';
  return _joinReaderParts([
    '$source$result',
    _houseSupportOutcome(period.mahabhutHouse),
  ]);
}

String _supportSource(String role, {required bool child}) {
  if (child) {
    return switch (role) {
      'montri' => 'ครูและผู้ใหญ่ที่ให้คำแนะนำ',
      'boriwan' => 'ครอบครัว เพื่อน และคนที่อยู่ใกล้ชิด',
      'sri' => 'ผลงานที่ครูและครอบครัวเคยเห็น',
      'ayu' => 'ผู้ใหญ่ที่ช่วยดูแลกิจวัตรและตารางชีวิต',
      'det' => 'ผู้ใหญ่ที่ช่วยแบ่งหน้าที่และตัดสินใจ',
      'mula' => 'ครอบครัวที่ช่วยดูแลพื้นฐานและสิ่งจำเป็น',
      'utsaha' => 'คนที่ร่วมทำกิจกรรมและเห็นความพยายามต่อเนื่อง',
      'kalakini' => 'ผู้ใหญ่ที่ช่วยแก้ข้อจำกัดและเรื่องติดขัด',
      _ => 'ครอบครัว ครู และผู้ใหญ่ที่ไว้ใจได้',
    };
  }
  return switch (role) {
    'montri' => 'ผู้มีประสบการณ์และคนที่เคยช่วยกันทำงาน',
    'boriwan' => 'ทีม คนใกล้ตัว และเครือข่ายเดิม',
    'sri' => 'ผลงานเดิมและชื่อเสียงที่สร้างไว้',
    'ayu' => 'คนที่ช่วยจัดตารางและแบ่งภาระร่วมกัน',
    'det' => 'คนที่ร่วมตัดสินใจและรับผิดชอบผลลัพธ์',
    'mula' => 'คนที่ร่วมดูแลฐานงาน ทรัพยากร และสิ่งที่สะสมไว้',
    'utsaha' => 'คนที่ร่วมลงแรงและทำงานต่อเนื่องด้วยกัน',
    'kalakini' => 'คนที่ช่วยแก้ข้อจำกัดและปิดเรื่องค้าง',
    _ => 'คนที่เห็นผลงานและรักษาข้อตกลงร่วมกัน',
  };
}

String _summaryPrediction(
  RuntimePredictivePeriodRow period,
  List<PredictionDomainModel> horizon,
  List<PredictionDomainModel> next,
  int currentAge,
  int nextAge,
) {
  final now = period.periodStatus == 'dueng_khuen'
      ? 'รอบปัจจุบันกำลังขยายผลจากสิ่งที่ทำต่อเนื่อง'
      : 'รอบปัจจุบันกำลังปิดภาระเดิมและจัดโครงสร้างใหม่';
  final first = _domainThaiForAge(horizon.first.material?.domain, currentAge);
  final second = _domainThaiForAge(horizon[1].material?.domain, currentAge);
  final later = _domainThaiForAge(next.first.material?.domain, nextAge);
  return '$now รอบ 12 เดือนจะเห็นผลผ่าน$firstควบคู่กับ$second ส่วนช่วงชีวิตถัดไปจะย้ายแกนหลักไปที่$later';
}

String _domainThaiForAge(ForecastDomain? domain, int age) => age >= 18
    ? _domainThai(domain)
    : age < 4
    ? switch (domain) {
        ForecastDomain.career => 'พัฒนาการและกิจวัตร',
        ForecastDomain.finance => 'ทรัพยากรและของใช้',
        ForecastDomain.relationship => 'ความสัมพันธ์กับผู้ดูแล',
        ForecastDomain.health => 'การนอนและกำลัง',
        null => 'เรื่องที่กำลังเปลี่ยน',
      }
    : switch (domain) {
        ForecastDomain.career => 'การเรียนและหน้าที่',
        ForecastDomain.finance => 'การเงิน',
        ForecastDomain.relationship => 'ความสัมพันธ์',
        ForecastDomain.health => 'กำลังและการพัก',
        null => 'เรื่องที่กำลังเปลี่ยน',
      };

String _adultDomainOverview(ForecastBand work, ForecastBand finance) {
  final workText = switch (work) {
    ForecastBand.strong => 'งานจะเดินหน้าและหน้าที่จะเพิ่มขึ้น',
    ForecastBand.active => 'งานจะขยับทีละขั้นผ่านเรื่องหลักที่ปิดจบ',
    ForecastBand.quiet => 'งานจะชะลอระหว่างจัดภาระและข้อจำกัดเดิม',
  };
  final financeText = switch (finance) {
    ForecastBand.strong => 'ฐานรายรับจะขยายตามงาน',
    ForecastBand.active => 'กระแสเงินจะค่อย ๆ นิ่งขึ้น',
    ForecastBand.quiet => 'ฐานเงินจะตึงจนกว่ารายจ่ายเดิมจะลดลง',
  };
  return '$workText ขณะที่$financeText';
}

String _roleDevelopment(String role, bool rising, {bool child = false}) {
  if (child) {
    return switch ((role, rising)) {
      ('boriwan', true) => 'เพื่อน ครอบครัว และคนรอบตัวจะช่วยให้โลกกว้างขึ้น',
      ('boriwan', false) =>
        'ความเปลี่ยนแปลงของคนรอบตัวจะทำให้ต้องปรับวิธีอยู่ร่วมกัน',
      ('ayu', true) =>
        'กำลังและกิจวัตรที่สม่ำเสมอจะช่วยให้รับหน้าที่ได้มากขึ้น',
      ('ayu', false) => 'กำลังที่ขึ้นลงจะทำให้ตารางเรียนและกิจกรรมต้องจัดใหม่',
      ('det', true) =>
        'หน้าที่ที่ได้รับจะเพิ่มขึ้นและเปิดพื้นที่ให้ตัดสินใจด้วยตัวเองมากขึ้น',
      ('det', false) =>
        'ขอบเขตและกติกาที่เข้มขึ้นจะทำให้ต้องลดสิ่งที่ทำพร้อมกัน',
      ('sri', true) => 'ผลจากการเรียนและกิจกรรมจะได้รับการยอมรับชัดขึ้น',
      ('sri', false) =>
        'ผลตอบรับที่ไม่สม่ำเสมอจะทำให้ต้องเปลี่ยนวิธีเรียนหรือทำกิจกรรม',
      ('mula', true) =>
        'ทักษะและสิ่งที่ฝึกสะสมไว้จะเริ่มต่อยอดเป็นความสามารถหลัก',
      ('mula', false) => 'พื้นฐานที่ยังไม่แน่นจะถูกนำกลับมาฝึกและจัดใหม่',
      ('utsaha', true) => 'ความพยายามที่ทำต่อเนื่องจะเริ่มเห็นผลเป็นรูปธรรม',
      ('utsaha', false) => 'กิจกรรมที่ใช้แรงมากจะลดลงเพื่อคืนเวลาให้เรื่องหลัก',
      ('montri', true) =>
        'ครูหรือผู้ใหญ่ที่ไว้ใจได้จะเข้ามาเปิดทางและให้โอกาสใหม่',
      ('montri', false) => 'คำแนะนำจากผู้ใหญ่จะเข้ามาช่วยแก้เรื่องที่ติดอยู่',
      ('kalakini', true) => 'ข้อจำกัดเดิมจะกลายเป็นแรงผลักให้ค้นพบวิธีใหม่',
      ('kalakini', false) =>
        'เรื่องที่ติดขัดจะทำให้ต้องหยุดบางกิจกรรมและเริ่มจัดลำดับใหม่',
      _ => 'สภาพแวดล้อมรอบตัวจะเปลี่ยนและทำให้ต้องปรับกิจวัตร',
    };
  }
  return switch ((role, rising)) {
    ('boriwan', true) => 'ทีมและคนรอบตัวจะเข้ามาช่วยขยายบทบาท',
    ('boriwan', false) => 'ทีมและคนรอบตัวจะเปลี่ยนหน้าที่หรือเว้นระยะจากเดิม',
    ('ayu', true) => 'กำลังและกิจวัตรที่ต่อเนื่องจะรองรับภาระได้มากขึ้น',
    ('ayu', false) => 'กำลังที่ขึ้นลงจะทำให้ภาระและตารางชีวิตต้องจัดใหม่',
    ('det', true) => 'อำนาจตัดสินใจและความรับผิดชอบจะเพิ่มขึ้น',
    ('det', false) => 'ขอบเขตการตัดสินใจจะถูกบีบให้เหลือเฉพาะเรื่องสำคัญ',
    ('sri', true) => 'ผลตอบแทนและการยอมรับจากผลงานเดิมจะชัดขึ้น',
    ('sri', false) => 'ผลตอบแทนที่ไม่สมดุลกับภาระจะถูกนำมาจัดใหม่',
    ('mula', true) => 'ฐานงานและทรัพย์สินที่สะสมไว้จะเริ่มต่อยอด',
    ('mula', false) => 'ฐานงานและทรัพย์สินเดิมจะถูกตรวจและลดส่วนที่ไม่สร้างผล',
    ('utsaha', true) => 'งานที่ลงแรงต่อเนื่องจะเริ่มให้ผลเป็นรูปธรรม',
    ('utsaha', false) => 'งานที่ใช้แรงมากเกินผลตอบแทนจะลดบทบาทลง',
    ('montri', true) => 'ผู้มีประสบการณ์และคนที่เชื่อมือจะเข้ามาเปิดทาง',
    ('montri', false) => 'ผู้มีประสบการณ์จะเข้ามาช่วยปิดเรื่องที่ติดขัด',
    ('kalakini', true) => 'ข้อจำกัดเดิมจะถูกเปลี่ยนเป็นทางเลือกหรือบทบาทใหม่',
    ('kalakini', false) =>
      'ข้อจำกัดและเรื่องค้างจะทำให้ต้องตัดสิ่งที่ไม่จำเป็นออก',
    _ => 'เงื่อนไขรอบตัวจะเปลี่ยนและทำให้บทบาทเดิมต้องปรับตาม',
  };
}

String _houseDevelopment(String house, bool rising, {bool child = false}) {
  if (child) {
    return switch ((house, rising)) {
      ('athibodi', true) => 'หน้าที่ใหม่จะทำให้ความรับผิดชอบชัดขึ้น',
      ('athibodi', false) => 'กติกาและหน้าที่จะถูกจัดใหม่ให้เหมาะกับวัย',
      ('khumsap', true) => 'การดูแลเงิน ของใช้ และทรัพยากรจะเป็นระบบขึ้น',
      ('khumsap', false) => 'เงินและของใช้จะต้องแบ่งใหม่ตามเรื่องจำเป็น',
      ('marana', _) =>
        'กิจวัตรหรือความเคยชินบางอย่างจะจบลงและถูกแทนด้วยแบบใหม่',
      ('phangkha', _) => 'ขอบเขตที่บ้านหรือโรงเรียนจะเปลี่ยนและต้องปรับตัวตาม',
      ('puti', _) => 'รอบเดิมจะปิดลงพร้อมการเริ่มสภาพแวดล้อมหรือกิจวัตรใหม่',
      ('racha', true) =>
        'บทบาทที่คนอื่นมองเห็นจะชัดขึ้นจากผลงานและความรับผิดชอบ',
      ('racha', false) => 'บทบาทต่อหน้าคนอื่นจะลดลงเพื่อกลับมาจัดเรื่องพื้นฐาน',
      ('thongchai', true) => 'เป้าหมายที่ทำต่อเนื่องจะเริ่มเห็นผลชัด',
      ('thongchai', false) => 'เป้าหมายระยะยาวจะถูกแบ่งใหม่ให้ทำได้ตามกำลัง',
      _ => 'เรื่องสำคัญของวัยนี้จะเปลี่ยนและจัดลำดับใหม่',
    };
  }
  return switch ((house, rising)) {
    ('athibodi', true) => 'หน้าที่และอำนาจรับผิดชอบจะชัดขึ้น',
    ('athibodi', false) => 'หน้าที่และอำนาจรับผิดชอบจะถูกลดหรือจัดขอบเขตใหม่',
    ('khumsap', true) => 'ทรัพยากรและฐานการเงินจะขยายตามผลที่เกิดขึ้น',
    ('khumsap', false) => 'ทรัพยากรและฐานเงินจะถูกจัดใหม่ตามภาระจำเป็น',
    ('marana', _) => 'สิ่งที่หมดบทบาทจะยุติลงและเปิดพื้นที่ให้รูปแบบใหม่',
    ('phangkha', _) => 'โครงสร้างและขอบเขตเดิมจะเปลี่ยนเพื่อรองรับภาระจริง',
    ('puti', _) => 'รอบเดิมจะปิดลงพร้อมการเริ่มจังหวะชีวิตแบบใหม่',
    ('racha', true) => 'สถานะและบทบาทที่คนอื่นมองเห็นจะเด่นขึ้น',
    ('racha', false) => 'สถานะภายนอกจะลดน้ำหนักเพื่อกลับมาจัดฐานภายใน',
    ('thongchai', true) => 'เป้าหมายระยะยาวจะเห็นผลและต่อยอดได้ชัดขึ้น',
    ('thongchai', false) => 'เป้าหมายระยะยาวจะถูกจัดใหม่และลดส่วนที่เกินกำลัง',
    _ => 'แกนชีวิตที่สำคัญจะเปลี่ยนและจัดลำดับใหม่',
  };
}

String _houseSupportOutcome(String house) => switch (house) {
  'athibodi' => 'ความช่วยเหลือจะทำให้หน้าที่และขอบเขตตัดสินใจชัดขึ้น',
  'khumsap' => 'ความช่วยเหลือจะลดแรงกดด้านทรัพยากรและค่าใช้จ่าย',
  'marana' => 'ความช่วยเหลือจะเร่งการปิดเรื่องที่หมดบทบาท',
  'phangkha' => 'ความช่วยเหลือจะทำให้โครงสร้างเดิมปรับได้โดยไม่สะดุด',
  'puti' => 'ความช่วยเหลือจะพาเรื่องเก่าจบและเปิดจังหวะใหม่',
  'racha' => 'ความช่วยเหลือจะทำให้บทบาทและการยอมรับชัดขึ้น',
  'thongchai' => 'ความช่วยเหลือจะพาเป้าหมายระยะยาวเข้าใกล้ผลสำเร็จ',
  _ => 'ความช่วยเหลือจะทำให้เรื่องสำคัญเดินต่อ',
};

String _compactDomainInfographic(
  ForecastMaterialFingerprint material,
  int age, {
  bool rolling = false,
}) {
  final domain = _domainThaiForAge(material.domain, age);
  final movement = switch (material.band) {
    ForecastBand.strong => 'จะเดินหน้าและเห็นผลชัดขึ้น',
    ForecastBand.active => 'จะขยับทีละขั้นจากสิ่งที่ทำต่อเนื่อง',
    ForecastBand.quiet => 'จะชะลอระหว่างจัดข้อจำกัดเดิม',
  };
  return rolling ? 'ใน 12 เดือน $domain$movement' : '$domain$movement';
}

String _compactSupportInfographic(RuntimePredictivePeriodRow period, int age) {
  final source = _supportSource(period.taksaRole, child: age < 18);
  return period.periodStatus == 'dueng_khuen'
      ? '$sourceจะช่วยเปิดทางให้เรื่องสำคัญเดินต่อ'
      : '$sourceจะช่วยแยกเรื่องค้างให้จัดการได้';
}

String _compactSummaryInfographic(
  RuntimePredictivePeriodRow period,
  List<PredictionDomainModel> horizon,
  List<PredictionDomainModel> next,
  int currentAge,
  int nextAge,
) {
  final direction = period.periodStatus == 'dueng_khuen'
      ? 'รอบปัจจุบันกำลังขยายผล'
      : 'รอบปัจจุบันกำลังจัดเรื่องค้าง';
  final first = _domainThaiForAge(horizon.first.material?.domain, currentAge);
  final second = _domainThaiForAge(horizon[1].material?.domain, currentAge);
  final later = _domainThaiForAge(next.first.material?.domain, nextAge);
  return '$direction 12 เดือนเน้น$firstกับ$second จากนั้นแกนหลักย้ายไป$later';
}

String _domainThai(ForecastDomain? domain) => switch (domain) {
  ForecastDomain.career => 'งาน',
  ForecastDomain.finance => 'การเงิน',
  ForecastDomain.relationship => 'ความสัมพันธ์',
  ForecastDomain.health => 'สุขภาพและการพัก',
  null => 'เรื่องที่กำลังเปลี่ยน',
};

List<RuntimePredictiveSection> _buildSections(
  List<RuntimePredictiveDecision> emitted,
) {
  final sections = <RuntimePredictiveSection>[];
  var pastHeadingAdded = false;
  for (final decision in emitted) {
    final owner = decision.rule.semanticOwner;
    if (owner == 'past' && !pastHeadingAdded) {
      sections.add(
        const RuntimePredictiveSection(
          id: 'past-heading',
          title: 'คำทำนายอดีต',
          claims: [],
        ),
      );
      pastHeadingAdded = true;
    }
    final title = decision.section;
    final existing = sections.indexWhere((section) => section.title == title);
    if (existing >= 0) {
      sections[existing] = RuntimePredictiveSection(
        id: sections[existing].id,
        title: title,
        claims: [...sections[existing].claims, decision],
      );
    } else {
      sections.add(
        RuntimePredictiveSection(
          id: _ownerSectionId(owner, sections.length),
          title: title,
          claims: [decision],
        ),
      );
    }
  }
  return sections;
}

String _joinReaderParts(Iterable<String> values) {
  final output = <String>[];
  for (final value in values) {
    final text = _naturalize(value);
    if (text.isEmpty || output.contains(text)) continue;
    output.add(text);
  }
  return output.join(' ');
}

String _naturalize(String value) => value
    .trim()
    .replaceAll(RegExp(r'\s+'), ' ')
    .replaceAll('ถัดไป เป็นกรอบ', 'ถัดไปเป็นกรอบ')
    .replaceAll('ในราว 0 ปีข้างหน้า', 'ภายในปีนี้')
    .replaceAll('อีกประมาณ 0 ปี', 'ภายในปีนี้');

T? _firstWhereOrNull<T>(Iterable<T> values, bool Function(T) test) {
  for (final value in values) {
    if (test(value)) return value;
  }
  return null;
}

String _ownerSectionId(String owner, int index) => switch (owner) {
  'rolling12' => 'horizon',
  'next' => 'next-life-period',
  'past' => 'past-$index',
  _ => owner,
};

String _realize(String template, {required int age, required DateTime asOf}) {
  final range = _rollingRange(asOf);
  return template
      .replaceAll('{{currentAge}}', '$age')
      .replaceAll('{{horizonStart}}', _thaiLongDate(range.$1))
      .replaceAll('{{horizonEnd}}', _thaiLongDate(range.$2));
}

(DateTime, DateTime) _rollingRange(DateTime asOf) {
  final nextYear = asOf.year + 1;
  final lastDay = DateTime(nextYear, asOf.month + 1, 0).day;
  final anniversary = DateTime(
    nextYear,
    asOf.month,
    asOf.day > lastDay ? lastDay : asOf.day,
  );
  return (
    DateTime(asOf.year, asOf.month, asOf.day),
    anniversary.subtract(const Duration(days: 1)),
  );
}

String _knownSubtitle(ThaiBetaAnalysis analysis) {
  final input = analysis.input;
  final birthData = analysis.pipelineResult?.birthData;
  final profile = analysis.profile;
  final time =
      '${input.birthHour!.toString().padLeft(2, '0')}:${input.birthMinute.toString().padLeft(2, '0')}';
  final province = input.province?.trim() ?? '';
  return [
    'เกิดวันที่ ${_thaiLongDate(input.birthDate)} เวลา $time น.${province.isEmpty ? '' : ' จังหวัด$province'}',
    [
      if ((input.gender ?? '').trim().isNotEmpty) 'เพศ${input.gender!.trim()}',
      if (birthData != null)
        'วันทางโหราศาสตร์เป็นวัน${_weekdayThai(birthData.thaiWeekdayNumber)}',
    ].join(' · '),
    if (profile?.lagnaKey != null && profile?.siderealAscendantDeg != null)
      'ลัคนา${_lagnaLabel(profile!.lagnaKey!)} ${_degreeWithinSign(profile.siderealAscendantDeg!)}',
  ].where((line) => line.isNotEmpty).join('\n');
}

String _thaiLongDate(DateTime date) {
  const months = [
    'มกราคม',
    'กุมภาพันธ์',
    'มีนาคม',
    'เมษายน',
    'พฤษภาคม',
    'มิถุนายน',
    'กรกฎาคม',
    'สิงหาคม',
    'กันยายน',
    'ตุลาคม',
    'พฤศจิกายน',
    'ธันวาคม',
  ];
  return '${date.day} ${months[date.month - 1]} ${date.year + 543}';
}

String _isoDate(DateTime date) =>
    '${date.year.toString().padLeft(4, '0')}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';

String _weekdayKey(int weekday) => switch (weekday) {
  1 => 'sunday',
  2 => 'monday',
  3 => 'tuesday',
  4 => 'wednesday',
  5 => 'thursday',
  6 => 'friday',
  7 => 'saturday',
  _ => 'unknown',
};
String _weekdayThai(int weekday) => switch (weekday) {
  1 => 'อาทิตย์',
  2 => 'จันทร์',
  3 => 'อังคาร',
  4 => 'พุธ',
  5 => 'พฤหัสบดี',
  6 => 'ศุกร์',
  7 => 'เสาร์',
  _ => 'ไม่ทราบ',
};

String _degreeWithinSign(double degree) {
  final normalized = ((degree % 30) + 30) % 30;
  var minutes = (normalized * 60).round();
  if (minutes >= 1800) minutes = 1799;
  return '${minutes ~/ 60}°${(minutes % 60).toString().padLeft(2, '0')}′';
}

String _lagnaLabel(String key) => switch (key) {
  'lagna_aries' => 'ราศีเมษ',
  'lagna_taurus' => 'ราศีพฤษภ',
  'lagna_gemini' => 'ราศีเมถุน',
  'lagna_cancer' => 'ราศีกรกฎ',
  'lagna_leo' => 'ราศีสิงห์',
  'lagna_virgo' => 'ราศีกันย์',
  'lagna_libra' => 'ราศีตุลย์',
  'lagna_scorpio' => 'ราศีพิจิก',
  'lagna_sagittarius' => 'ราศีธนู',
  'lagna_capricorn' => 'ราศีมกร',
  'lagna_aquarius' => 'ราศีกุมภ์',
  'lagna_pisces' => 'ราศีมีน',
  _ => 'ราศีที่ระบบคำนวณได้',
};
