/// Owner-authorized Predictive Narrative V2 runtime.
///
/// The 392-row Mahabhut ledger is used only as selector/timing authority.
/// Reader direction comes from typed forecast material and the production
/// composers. Candidate 0011 remains immutable catalog data selected through
/// the same context/period resolver as every other Known-time report.
library;

import 'package:knowme/features/astrology/thai/core/life_period/thai_remainder_runtime_metadata.dart';
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
      return true;
    }
    if (kind == RuntimePredictiveKind.summary && compositionRefs.isNotEmpty) {
      return true;
    }
    return selectorRefs.isNotEmpty &&
        domainRefs.isNotEmpty &&
        directionRefs.isNotEmpty &&
        timingRefs.isNotEmpty &&
        conflictRefs.isNotEmpty &&
        certaintyRefs.isNotEmpty &&
        evidenceRefs.every(runtimePredictiveV2EvidenceIds.contains);
  }

  RuntimePredictiveRule copyWith({
    String? id,
    String? contextId,
    bool? fixtureSpecific,
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
  );
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
      );
    }

    final rules = _rulesForAnalysis(
      analysis: analysis,
      contextId: context,
      currentAge: age,
      currentPeriod: currentPeriod,
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
  int get fixtureSpecificBranches =>
      decisions.where((decision) => decision.rule.fixtureSpecific).length;
  int get knownToUnknownLeakage =>
      !knownTime && emittedClaims.isNotEmpty ? emittedClaims.length : 0;
  bool get baselineFallbackUsed => knownTime && sections.isEmpty;
  Set<String> get emittedSemanticOwners =>
      emittedClaims.map((decision) => decision.rule.semanticOwner).toSet();
  Set<String> get missingSemanticOwners => knownTime
      ? requiredKnownSemanticOwners.difference(emittedSemanticOwners)
      : const {};
  String get generationPath =>
      'predictive-runtime-v2:392-selector+production-canon+typed-forecast';

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

List<RuntimePredictiveRule> _rulesForAnalysis({
  required ThaiBetaAnalysis analysis,
  required String contextId,
  required int currentAge,
  required RuntimePredictivePeriodRow currentPeriod,
}) {
  final goldenContextMatches = runtimePredictiveV2GoldenRules.every(
    (rule) => rule.contextId == contextId,
  );
  if (goldenContextMatches &&
      currentPeriod.matrixApplicationId ==
          runtimePredictiveV2GoldenCurrentPeriodId) {
    return runtimePredictiveV2GoldenRules;
  }
  return _buildContractRules(
    analysis: analysis,
    contextId: contextId,
    currentAge: currentAge,
    currentPeriod: currentPeriod,
  );
}

List<RuntimePredictiveRule> _buildContractRules({
  required ThaiBetaAnalysis analysis,
  required String contextId,
  required int currentAge,
  required RuntimePredictivePeriodRow currentPeriod,
}) {
  final timeline = analysis.consumerViewState?.lifeTimeline;
  final prediction = analysis.consumerViewState?.futurePrediction;
  if (timeline == null || prediction == null) return const [];
  final contextRows = runtimePredictiveV2PeriodRows
      .where((row) => row.contextId == contextId)
      .toList(growable: false);
  final currentIndex = contextRows.indexWhere(
    (row) => row.matrixApplicationId == currentPeriod.matrixApplicationId,
  );
  if (contextRows.length != 8 || currentIndex < 0 || timeline.periods.isEmpty) {
    return const [];
  }
  final timelineCurrent = _firstWhereOrNull(
    timeline.periods,
    (period) => period.isCurrent,
  );
  final pastTimeline =
      _lastWhereOrNull(timeline.periods, (period) => period.isPast) ??
      timelineCurrent;
  final nextTimeline = _firstWhereOrNull(
    timeline.periods.skipWhile((period) => !period.isCurrent).skip(1),
    (_) => true,
  );
  if (timelineCurrent == null || pastTimeline == null) return const [];

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
  final support = _firstWhereOrNull(
    timelineCurrent.lifeDomains,
    (block) => block.title == 'โชคลาภ',
  );
  if (work == null ||
      finance == null ||
      relationship == null ||
      health == null ||
      support == null) {
    return const [];
  }
  final horizonDomains = _rankedDomains(horizonWindow);
  final nextDomains = _rankedDomains(nextWindow);

  final prefix = 'PRV2-${contextId.replaceAll('.', '-')}';
  final rules = <RuntimePredictiveRule>[];
  RuntimePredictiveRule periodRule({
    required String suffix,
    required String owner,
    required String section,
    required String text,
    required RuntimePredictivePeriodRow row,
  }) => _rule(
    id: '$prefix-$suffix',
    owner: owner,
    section: section,
    text: text,
    contextId: contextId,
    period: row,
    domain: 'life_path',
    horizon: 'life-period',
  );

  rules.add(
    periodRule(
      suffix: 'OVERVIEW-01',
      owner: 'overview',
      section: 'ภาพรวมเส้นทางชีวิต',
      text: _joinReaderParts([
        timelineCurrent.summary,
        timelineCurrent.whatChanges,
        timeline.futurePreview?.intro ?? '',
      ]),
      row: currentPeriod,
    ),
  );
  rules.add(
    periodRule(
      suffix: 'PAST-01',
      owner: 'past',
      section: currentIndex == 0
          ? 'ช่วงที่ผ่านมา — ตั้งแต่วัยเริ่มต้นถึงอายุ {{currentAge}} ปี'
          : 'ช่วงที่ผ่านมา — อายุ ${pastRow.ageStart}–${pastRow.ageEnd} ปี',
      text: currentIndex == 0
          ? 'ตั้งแต่วัยเริ่มต้นถึงตอนนี้ ${_withoutNowLead(pastTimeline.summary)}'
          : _joinReaderParts([pastTimeline.summary, pastTimeline.whatChanges]),
      row: pastRow,
    ),
  );
  rules.add(
    periodRule(
      suffix: 'CURRENT-01',
      owner: 'current',
      section: 'คำทำนายปัจจุบัน — อายุ {{currentAge}} ปี',
      text: _joinReaderParts([
        timelineCurrent.summary,
        timelineCurrent.whatChanges,
      ]),
      row: currentPeriod,
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
      text: currentAge < 18
          ? _childSupportText(currentPeriod)
          : _joinReaderParts([_supportHeadline(currentPeriod), support.body]),
      contextId: contextId,
      period: currentPeriod,
      domain: 'support',
      horizon: 'current',
      infographicText: currentAge < 18
          ? _childSupportText(currentPeriod)
          : _supportHeadline(currentPeriod),
    ),
  );
  rules.add(
    _rule(
      id: '$prefix-HORIZON-01',
      owner: 'rolling12',
      section: 'แนวโน้ม 12 เดือนข้างหน้า',
      text: currentAge < 18
          ? _childHorizonText(currentPeriod)
          : 'ระหว่างวันที่ {{horizonStart}} ถึง {{horizonEnd}} ${_joinReaderParts(horizonDomains.take(2).map((domain) => _withoutHorizonLead(domain.body)))}',
      contextId: contextId,
      period: currentPeriod,
      domain: 'life_path',
      horizon: 'next12Months',
      rolling: true,
      infographicText: horizonDomains.isEmpty
          ? ''
          : _compactInfographicDomain(
              _withoutHorizonLead(
                horizonDomains.first.claim.isEmpty
                    ? horizonDomains.first.body
                    : horizonDomains.first.claim,
              ),
            ),
    ),
  );
  rules.add(
    periodRule(
      suffix: 'NEXT-01',
      owner: 'next',
      section: nextRow == currentPeriod
          ? 'ช่วงชีวิตระยะยาว'
          : 'ช่วงชีวิตถัดไป — อายุ ${nextRow.ageStart}–${nextRow.ageEnd} ปี',
      text: nextRow.ageStart < 18
          ? _childNextText(nextRow)
          : _joinReaderParts([
              nextTimeline?.summary ?? '',
              nextDomains.isEmpty
                  ? nextWindow.topOpportunity
                  : nextDomains.first.body,
              nextWindow.topRisk,
            ]),
      row: nextRow,
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
      textTemplate: _joinReaderParts([
        timelineCurrent.summary,
        _domainSummaryLine(horizonDomains, nextDomains),
      ]),
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
      infographicTextTemplate: timelineCurrent.summary,
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
  text: currentAge < 18
      ? _childDomainText(domain, period)
      : _joinReaderParts([material.claim, material.body, material.risk]),
  contextId: contextId,
  period: period,
  domain: domain.name,
  horizon: horizon.name,
  infographicText: _compactInfographicDomain(
    material.claim.isEmpty ? material.body : material.claim,
  ),
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
    horizon == 'life-period' || domain == 'support'
        ? 'domain.runtime.life-period'
        : 'domain.runtime.$horizon.${domain == 'life_path' ? 'aggregate' : domain}',
  ],
  directionRefs: [
    horizon == 'life-period' || domain == 'support'
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

String _childDomainText(
  ForecastDomain domain,
  RuntimePredictivePeriodRow period,
) {
  final rising = period.periodStatus == 'dueng_khuen';
  return switch (domain) {
    ForecastDomain.career =>
      rising
          ? 'เรื่องการเรียนและหน้าที่ที่ได้รับมอบหมายจะเดินหน้าได้ดีขึ้น เมื่อแบ่งงานเป็นขั้นและทำต่อเนื่อง'
          : 'เรื่องการเรียนและหน้าที่ประจำจะใช้แรงมากขึ้น ควรทำทีละส่วนและขอความช่วยเหลือเมื่อโจทย์เกินกำลัง',
    ForecastDomain.finance =>
      rising
          ? 'การฝึกแบ่งเงินและดูแลของใช้จะเริ่มเห็นผล เก็บส่วนหนึ่งไว้ก่อนใช้จะช่วยให้มีพอสำหรับเรื่องสำคัญ'
          : 'ช่วงนี้ต้องระวังการใช้เงินตามใจชั่วคราว แยกของที่จำเป็นออกจากของที่อยากได้ก่อนตัดสินใจ',
    ForecastDomain.relationship =>
      rising
          ? 'ความสัมพันธ์กับครอบครัว เพื่อน และคนรอบตัวจะดีขึ้นเมื่อพูดความต้องการตรง ๆ และรักษาข้อตกลง'
          : 'ความไม่เข้าใจกับครอบครัวหรือเพื่อนอาจเกิดง่ายขึ้น ควรหยุดฟังกันให้ครบก่อนตอบโต้',
    ForecastDomain.health =>
      rising
          ? 'พลังในแต่ละวันจะคงที่ขึ้นเมื่อได้นอนและพักเป็นเวลา ไม่ทำกิจกรรมหลายอย่างติดกันจนเกินไป'
          : 'พลังในแต่ละวันจะหมดเร็วขึ้นเมื่อเรียนหรือทำกิจกรรมต่อเนื่อง ควรมีช่วงพักและบอกผู้ใหญ่เมื่อรู้สึกไม่ไหว',
  };
}

String _childSupportText(RuntimePredictivePeriodRow period) =>
    period.periodStatus == 'dueng_khuen'
    ? 'แรงสนับสนุนในวัยนี้มาจากครอบครัว ครู และเพื่อนที่ไว้ใจได้ การขอคำแนะนำตรง ๆ จะช่วยให้เรื่องที่ติดอยู่เดินต่อ'
    : 'ช่วงนี้ควรพึ่งครอบครัว ครู หรือผู้ใหญ่ที่ไว้ใจได้เมื่อเจอเรื่องเกินกำลัง ไม่ต้องแก้ทุกอย่างเพียงลำพัง';

String _compactInfographicDomain(String value) => value
    .trim()
    .replaceFirst(RegExp(r'^ช่วงนี้[,.]?\s*'), '')
    .split(RegExp(r'(?: ผลงาน| ความมั่นคง| ความสม่ำเสมอ| ควร| แต่| โดย)'))
    .first
    .trim();

String _supportHeadline(RuntimePredictivePeriodRow period) =>
    period.periodStatus == 'dueng_khuen'
    ? 'แรงสนับสนุนจากคนรู้จักและผลงานเดิมจะช่วยเปิดทางให้เรื่องที่ติดอยู่เดินต่อ'
    : 'แรงสนับสนุนจะมาเมื่อขอความช่วยเหลือให้ตรงเรื่อง และไม่รับภาระทั้งหมดไว้คนเดียว';

String _childHorizonText(RuntimePredictivePeriodRow period) =>
    period.periodStatus == 'dueng_khuen'
    ? 'ระหว่างวันที่ {{horizonStart}} ถึง {{horizonEnd}} การเรียน หน้าที่ประจำ และความสัมพันธ์กับคนรอบตัวจะค่อย ๆ ลงตัวขึ้นเมื่อทำตามข้อตกลงสม่ำเสมอ'
    : 'ระหว่างวันที่ {{horizonStart}} ถึง {{horizonEnd}} ภาระจากการเรียนและกิจกรรมจะต้องจัดใหม่ การพักและขอความช่วยเหลือตรงเวลาจะทำให้ผ่านช่วงที่หนักได้';

String _childNextText(RuntimePredictivePeriodRow period) =>
    period.periodStatus == 'dueng_khuen'
    ? 'เมื่อเข้าสู่อายุ ${period.ageStart}–${period.ageEnd} ปี การเรียน หน้าที่ และความสัมพันธ์กับคนรอบตัวจะเปิดกว้างขึ้นตามประสบการณ์ที่เพิ่มขึ้น'
    : 'เมื่อเข้าสู่อายุ ${period.ageStart}–${period.ageEnd} ปี ภาระด้านการเรียนและหน้าที่จะชัดขึ้น ต้องแบ่งแรงและขอความช่วยเหลือให้ตรงเรื่อง';

String _withoutHorizonLead(String value) =>
    value.trim().replaceFirst(RegExp(r'^(ใน\s*)?12 เดือนข้างหน้า\s*'), '');

String _domainSummaryLine(
  List<PredictionDomainModel> horizon,
  List<PredictionDomainModel> next,
) {
  if (horizon.isEmpty || next.isEmpty) return '';
  final first = _domainThai(horizon.first.material?.domain);
  final second = horizon.length > 1
      ? _domainThai(horizon[1].material?.domain)
      : first;
  final later = _domainThai(next.first.material?.domain);
  return 'ในรอบ 12 เดือน เรื่อง$firstและ$secondเป็นแกนหลัก ส่วนช่วงชีวิตถัดไปให้น้ำหนักกับ$laterมากขึ้น';
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

String _withoutNowLead(String value) => value.trim().replaceFirst(
  RegExp(r'^(ตอนนี้|ช่วงนี้)\s*'),
  'สิ่งที่เห็นชัดคือ ',
);

String _naturalize(String value) => value
    .trim()
    .replaceAll(RegExp(r'\s+'), ' ')
    .replaceAll('ในราว 0 ปีข้างหน้า', 'ภายในปีนี้')
    .replaceAll('อีกประมาณ 0 ปี', 'ภายในปีนี้');

T? _firstWhereOrNull<T>(Iterable<T> values, bool Function(T) test) {
  for (final value in values) {
    if (test(value)) return value;
  }
  return null;
}

T? _lastWhereOrNull<T>(Iterable<T> values, bool Function(T) test) {
  T? result;
  for (final value in values) {
    if (test(value)) result = value;
  }
  return result;
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
