/// Source-authorized Predictive Narrative V2 plan.
///
/// Reader predictions are selected from an immutable catalog generated from
/// the accepted Mahabhut JSON sources plus typed forecast material already
/// computed by the application. Placement facts are structural inputs only.
library;

import 'package:knowme/features/astrology/thai/core/life_period/life_period_engine.dart';
import 'package:knowme/features/astrology/thai/core/life_period/thai_remainder_runtime_metadata.dart';
import 'package:knowme/features/astrology/thai/mirror/presentation/prediction/prediction_section_model.dart';

import '../thai_beta_analysis.dart';

part 'predictive_authority_catalog.g.dart';

enum NarrativeSectionRole {
  overview,
  past,
  current,
  work,
  finance,
  relationship,
  health,
  support,
  horizon,
  nextLifePeriod,
  summary,
  advice,
  disclaimer,
  omission,
}

enum NarrativeAtomRole { prediction, summary, advice, disclosure, omission }

enum DomainScope {
  lifePath,
  supportAndFamily,
  educationAndSocial,
  work,
  workAndCommitment,
  finance,
  relationship,
  health,
  support,
  luck,
  financeAndRelationship,
  communication,
  foundation,
  advice,
  disclosure,
  omission,
}

enum KnownUnknownEligibility { knownOnly, unknownOnly, both }

enum PredictiveAuthorityType {
  placementFact,
  sourceGeneralRule,
  sourceDirect,
  generalRuleApplication,
  ownerAuthorizedProductInterpretation,
  ownerAuthorizedSynthesis,
  forecastMaterial,
  advice,
  disclosure,
  omission,
}

enum ClaimChronology { past, current, future, horizon, report, unavailable }

enum GenerationSource {
  sourceDirect,
  generalRuleApplication,
  ownerAuthorizedSynthesis,
  forecastMaterial,
  structuralSummary,
  advice,
  disclosure,
  omission,
  legacyFallback,
  fixtureSpecial,
}

class PredictiveClaimSpec {
  const PredictiveClaimSpec({
    required this.claimId,
    required this.semanticOwnerId,
    required this.meaningKey,
    required this.evidenceRefs,
    required this.contextSelector,
    required this.periodSelector,
    required this.domain,
    required this.role,
    required this.readerCopy,
    required this.compactCopy,
    required this.eligibility,
  });

  factory PredictiveClaimSpec.fromAtom(
    NarrativeAtom atom, {
    required String contextSelector,
  }) => PredictiveClaimSpec(
    claimId: atom.id,
    semanticOwnerId: atom.owner.id,
    meaningKey: atom.owner.meaningKey,
    evidenceRefs: atom.evidence.refs,
    contextSelector: contextSelector,
    periodSelector: atom.period.id,
    domain: atom.domain,
    role: atom.role,
    readerCopy: atom.readerText,
    compactCopy: atom.compactText,
    eligibility: atom.eligibility,
  );

  final String claimId;
  final String semanticOwnerId;
  final String meaningKey;
  final List<String> evidenceRefs;
  final String contextSelector;
  final String periodSelector;
  final DomainScope domain;
  final NarrativeAtomRole role;
  final String readerCopy;
  final String compactCopy;
  final KnownUnknownEligibility eligibility;

  Map<String, Object?> toMap() => {
    'claimId': claimId,
    'semanticOwnerId': semanticOwnerId,
    'meaningKey': meaningKey,
    'evidenceRefs': evidenceRefs,
    'contextSelector': contextSelector,
    'periodSelector': periodSelector,
    'domain': domain.name,
    'role': role.name,
    'readerCopy': readerCopy,
    'compactCopy': compactCopy,
    'eligibility': eligibility.name,
  };
}

class PredictiveAuthorityRecord {
  const PredictiveAuthorityRecord({
    required this.id,
    required this.claimType,
    this.contextId,
    this.periodBinding,
    this.domainKey,
    this.subject,
    this.movement,
    this.planet,
    this.taksaRole,
    this.mahabhutHouse,
    this.periodStatus,
    this.allowedConclusion,
    this.prohibitedEscalation = const [],
    this.conditionsSatisfied = const [],
    this.labelPolicy,
    this.evidenceRefs = const [],
    this.readerText,
    this.readerClaimId,
    this.semanticOwnerId,
    this.meaningKey,
    this.readerRole,
    this.sectionTitle,
    this.sectionId,
    this.sectionRole,
    this.sectionDisplayTitle,
    this.blockHeading,
    this.surface,
    this.templateId,
    this.acceptedCurrentAge,
    this.acceptedAsOf,
    this.sourceFile = '',
    this.predictionClaimStatus,
    this.sourceOwnership,
    this.sourceOrder,
  });

  factory PredictiveAuthorityRecord.fromMap(Map<String, Object?> map) =>
      PredictiveAuthorityRecord(
        id: map['id']! as String,
        claimType: _authorityType(map['claimType']! as String),
        contextId: map['contextId'] as String?,
        periodBinding: map['periodBinding'] as String?,
        domainKey: map['domain'] as String?,
        subject: map['subject'] as String?,
        movement: map['movement'] as String?,
        planet: map['planet'] as String?,
        taksaRole: map['taksaRole'] as String?,
        mahabhutHouse: map['mahabhutHouse'] as String?,
        periodStatus: map['periodStatus'] as String?,
        allowedConclusion: map['allowedConclusion'] as String?,
        prohibitedEscalation: _mapStringList(map['prohibitedEscalation']),
        conditionsSatisfied: _mapStringList(map['conditionsSatisfied']),
        labelPolicy: map['labelPolicy'] as String?,
        evidenceRefs: _mapStringList(map['evidenceRefs']),
        readerText: map['readerText'] as String?,
        readerClaimId: map['readerClaimId'] as String?,
        semanticOwnerId: map['semanticOwnerId'] as String?,
        meaningKey: map['meaningKey'] as String?,
        readerRole: map['readerRole'] as String?,
        sectionTitle: map['sectionTitle'] as String?,
        sectionId: map['sectionId'] as String?,
        sectionRole: map['sectionRole'] as String?,
        sectionDisplayTitle: map['sectionDisplayTitle'] as String?,
        blockHeading: map['blockHeading'] as String?,
        surface: map['surface'] as String?,
        templateId: map['templateId'] as String?,
        acceptedCurrentAge: map['acceptedCurrentAge'] as int?,
        acceptedAsOf: map['acceptedAsOf'] == null
            ? null
            : DateTime.parse(map['acceptedAsOf']! as String),
        sourceFile: map['sourceFile'] as String? ?? '',
        predictionClaimStatus: map['predictionClaimStatus'] as String?,
        sourceOwnership: map['sourceOwnership'] as String?,
        sourceOrder: map['sourceOrder'] as int?,
      );

  final String id;
  final PredictiveAuthorityType claimType;
  final String? contextId;
  final String? periodBinding;
  final String? domainKey;
  final String? subject;
  final String? movement;
  final String? planet;
  final String? taksaRole;
  final String? mahabhutHouse;
  final String? periodStatus;
  final String? allowedConclusion;
  final List<String> prohibitedEscalation;
  final List<String> conditionsSatisfied;
  final String? labelPolicy;
  final List<String> evidenceRefs;
  final String? readerText;
  final String? readerClaimId;
  final String? semanticOwnerId;
  final String? meaningKey;
  final String? readerRole;
  final String? sectionTitle;
  final String? sectionId;
  final String? sectionRole;
  final String? sectionDisplayTitle;
  final String? blockHeading;
  final String? surface;
  final String? templateId;
  final int? acceptedCurrentAge;
  final DateTime? acceptedAsOf;
  final String sourceFile;
  final String? predictionClaimStatus;
  final String? sourceOwnership;
  final int? sourceOrder;

  bool get isPredictionAuthority => switch (claimType) {
    PredictiveAuthorityType.sourceDirect ||
    PredictiveAuthorityType.generalRuleApplication ||
    PredictiveAuthorityType.ownerAuthorizedProductInterpretation ||
    PredictiveAuthorityType.ownerAuthorizedSynthesis ||
    PredictiveAuthorityType.forecastMaterial => true,
    _ => false,
  };

  bool acceptedContractMatches({required int age, required DateTime asOf}) {
    if (acceptedCurrentAge != null && acceptedCurrentAge != age) return false;
    if (acceptedAsOf != null && !_sameDate(acceptedAsOf!, asOf)) return false;
    return true;
  }

  List<(int, int)> get ageRanges {
    final binding = periodBinding;
    if (binding == null) return const [];
    final result = <(int, int)>[];
    for (final part in binding.split('|')) {
      final normalized = part.trim();
      if (normalized.contains('/')) continue;
      final single = RegExp(r'^age(\d+)$').firstMatch(normalized);
      if (single != null) {
        final age = int.parse(single.group(1)!);
        result.add((age, age));
        continue;
      }
      final range = RegExp(r'^(\d+)-(\d+)$').firstMatch(normalized);
      if (range != null) {
        result.add((int.parse(range.group(1)!), int.parse(range.group(2)!)));
      }
    }
    return result;
  }

  bool containsAge(int age) =>
      ageRanges.any((range) => age >= range.$1 && age <= range.$2);

  ClaimChronology chronologyAt(int age) {
    if (periodBinding == 'REPORT') return ClaimChronology.report;
    if (periodBinding == 'UNAVAILABLE') return ClaimChronology.unavailable;
    if (periodBinding?.contains('/') ?? false) return ClaimChronology.horizon;
    final ranges = ageRanges;
    if (ranges.isEmpty) return ClaimChronology.report;
    if (ranges.any((range) => age >= range.$1 && age <= range.$2)) {
      return ClaimChronology.current;
    }
    if (ranges.every((range) => range.$2 < age)) return ClaimChronology.past;
    return ClaimChronology.future;
  }
}

class EvidenceResolutionResult {
  const EvidenceResolutionResult({
    required this.unresolvedRefs,
    required this.wrongClaimType,
    required this.contextMismatch,
    required this.periodMismatch,
    required this.domainMismatch,
    required this.placementPromotedToPrediction,
    required this.selfAttestedRef,
    required this.generalRuleConditionsMissing,
    required this.productInterpretationLabelMissing,
    required this.prohibitedEscalationViolation,
  });

  final List<String> unresolvedRefs;
  final bool wrongClaimType;
  final bool contextMismatch;
  final bool periodMismatch;
  final bool domainMismatch;
  final bool placementPromotedToPrediction;
  final bool selfAttestedRef;
  final bool generalRuleConditionsMissing;
  final bool productInterpretationLabelMissing;
  final bool prohibitedEscalationViolation;

  bool get isValid =>
      unresolvedRefs.isEmpty &&
      !wrongClaimType &&
      !contextMismatch &&
      !periodMismatch &&
      !domainMismatch &&
      !placementPromotedToPrediction &&
      !selfAttestedRef &&
      !generalRuleConditionsMissing &&
      !productInterpretationLabelMissing &&
      !prohibitedEscalationViolation;

  Map<String, Object?> toMap() => {
    'resolved': isValid,
    'unresolved_refs': unresolvedRefs,
    'wrong_claim_type': wrongClaimType,
    'context_mismatch': contextMismatch,
    'period_mismatch': periodMismatch,
    'domain_mismatch': domainMismatch,
    'placement_promoted_to_prediction': placementPromotedToPrediction,
    'self_attested_ref': selfAttestedRef,
    'general_rule_conditions_missing': generalRuleConditionsMissing,
    'product_interpretation_label_missing': productInterpretationLabelMissing,
    'prohibited_escalation_violation': prohibitedEscalationViolation,
  };
}

class PredictiveEvidenceCatalog {
  PredictiveEvidenceCatalog._(Map<String, PredictiveAuthorityRecord> records)
    : _records = Map.unmodifiable(records);

  factory PredictiveEvidenceCatalog.forAnalysis({
    required String contextId,
    required LifeTimeline timeline,
    required DateTime asOf,
    required List<ForecastMaterialFingerprint> materials,
  }) {
    final records = <String, PredictiveAuthorityRecord>{
      for (final record in _sourceRecords) record.id: record,
    };
    final placements =
        _sourceRecords
            .where(
              (record) =>
                  record.claimType == PredictiveAuthorityType.placementFact &&
                  record.contextId == contextId,
            )
            .toList(growable: false)
          ..sort(
            (left, right) =>
                left.ageRanges.first.$1.compareTo(right.ageRanges.first.$1),
          );
    final currentPlacement = placements
        .cast<PredictiveAuthorityRecord?>()
        .firstWhere(
          (record) => record!.containsAge(timeline.currentAge),
          orElse: () => null,
        );
    final nextPlacement = placements
        .cast<PredictiveAuthorityRecord?>()
        .firstWhere(
          (record) => record!.ageRanges.first.$1 > timeline.currentAge,
          orElse: () => null,
        );
    for (final material in materials) {
      final period = switch (material.horizon) {
        ForecastHorizon.current =>
          currentPlacement?.periodBinding ??
              '${timeline.current.startAge}-${timeline.current.endAge}',
        ForecastHorizon.next12Months =>
          '${_isoDate(asOf)}/${_isoDate(_longHorizonRange(asOf).$2)}|age${timeline.currentAge}-${timeline.currentAge + 1}',
        ForecastHorizon.nextLifePeriod =>
          nextPlacement?.periodBinding ?? 'UNAVAILABLE',
      };
      records[material.evidenceKey] = PredictiveAuthorityRecord(
        id: material.evidenceKey,
        claimType: PredictiveAuthorityType.forecastMaterial,
        contextId: contextId,
        periodBinding: period,
        domainKey: material.domain.name,
        subject: 'forecast_material',
        movement: material.band.name,
        allowedConclusion:
            'Typed forecast material bounded by domain, band, '
            'horizon and evidence availability.',
        templateId:
            'forecast-${material.horizon.name}-${material.domain.name}-${material.band.name}',
        sourceFile:
            'lib/features/astrology/thai/mirror/presentation/prediction/prediction_section_model.dart',
        sourceOwnership: material.sourceOwnership,
      );
    }
    return PredictiveEvidenceCatalog._(records);
  }

  factory PredictiveEvidenceCatalog.unknown() => PredictiveEvidenceCatalog._({
    for (final record in _sourceRecords) record.id: record,
  });

  static final List<PredictiveAuthorityRecord> _sourceRecords =
      List.unmodifiable(
        _generatedPredictiveAuthorityRecords.map(
          PredictiveAuthorityRecord.fromMap,
        ),
      );

  final Map<String, PredictiveAuthorityRecord> _records;

  Iterable<PredictiveAuthorityRecord> get records => _records.values;
  Iterable<String> get ids => _records.keys;
  PredictiveAuthorityRecord? operator [](String id) => _records[id];
  bool contains(String id) => _records.containsKey(id);

  PredictiveEvidenceCatalog without(Set<String> ids) =>
      PredictiveEvidenceCatalog._(
        Map.fromEntries(
          _records.entries.where((entry) => !ids.contains(entry.key)),
        ),
      );

  EvidenceResolutionResult validateReferences(Iterable<String> refs) =>
      EvidenceResolutionResult(
        unresolvedRefs: refs.where((ref) => !contains(ref)).toList(),
        wrongClaimType: false,
        contextMismatch: false,
        periodMismatch: false,
        domainMismatch: false,
        placementPromotedToPrediction: false,
        selfAttestedRef: false,
        generalRuleConditionsMissing: false,
        productInterpretationLabelMissing: false,
        prohibitedEscalationViolation: false,
      );

  EvidenceResolutionResult validateSelection({
    required PredictiveAuthorityRecord record,
    required String contextId,
    required int currentAge,
    required DateTime asOf,
    required DomainScope domain,
    required ClaimChronology chronology,
    String? proposedText,
  }) {
    final unresolved = record.evidenceRefs
        .where((ref) => !contains(ref))
        .toList(growable: false);
    final actualChronology = record.chronologyAt(currentAge);
    return EvidenceResolutionResult(
      unresolvedRefs: unresolved,
      wrongClaimType: !record.isPredictionAuthority,
      contextMismatch:
          record.contextId != null && record.contextId != contextId,
      periodMismatch:
          !record.acceptedContractMatches(age: currentAge, asOf: asOf) ||
          actualChronology != chronology,
      domainMismatch: !_domainKeysCompatible(record.domainKey, domain),
      placementPromotedToPrediction:
          record.claimType == PredictiveAuthorityType.placementFact,
      selfAttestedRef: record.evidenceRefs.contains(record.id),
      generalRuleConditionsMissing:
          record.claimType == PredictiveAuthorityType.generalRuleApplication &&
          record.conditionsSatisfied.isEmpty,
      productInterpretationLabelMissing:
          record.claimType ==
              PredictiveAuthorityType.ownerAuthorizedProductInterpretation &&
          record.labelPolicy !=
              'INTERNAL_PRODUCT_INTERPRETATION_NOT_SOURCE_QUOTE',
      prohibitedEscalationViolation:
          proposedText != null &&
          _prohibitedEscalationHits(record, proposedText).isNotEmpty,
    );
  }

  PredictiveAuthorityRecord? placementFor({
    required String contextId,
    required PredictiveAuthorityRecord claim,
    required int currentAge,
  }) {
    for (final ref in claim.evidenceRefs) {
      final candidate = this[ref];
      if (candidate?.claimType == PredictiveAuthorityType.placementFact) {
        return candidate;
      }
    }
    final claimRanges = claim.ageRanges;
    return records.cast<PredictiveAuthorityRecord?>().firstWhere(
      (record) =>
          record?.claimType == PredictiveAuthorityType.placementFact &&
          record?.contextId == contextId &&
          (claimRanges.isEmpty
              ? record!.containsAge(currentAge)
              : _rangesOverlap(record!.ageRanges, claimRanges)),
      orElse: () => null,
    );
  }

  List<PredictiveAuthorityRecord> placementTimeline(String contextId) {
    final placements =
        records
            .where(
              (record) =>
                  record.claimType == PredictiveAuthorityType.placementFact &&
                  record.contextId == contextId,
            )
            .toList(growable: false)
          ..sort(
            (left, right) =>
                left.ageRanges.first.$1.compareTo(right.ageRanges.first.$1),
          );
    return placements;
  }

  PredictiveAuthorityRecord? nextPlacement(String contextId, int currentAge) =>
      placementTimeline(
        contextId,
      ).cast<PredictiveAuthorityRecord?>().firstWhere(
        (record) => record!.ageRanges.first.$1 > currentAge,
        orElse: () => null,
      );
}

class GenerationProvenance {
  const GenerationProvenance({
    required this.atomId,
    required this.selectedClaimId,
    required this.selectionReason,
    required this.source,
    required this.claimType,
    required this.applicabilityResult,
    required this.templateId,
    required this.evidenceResolution,
    this.omissionReason,
    this.compressedReference = false,
  });

  final String atomId;
  final String selectedClaimId;
  final String selectionReason;
  final GenerationSource source;
  final PredictiveAuthorityType claimType;
  final String applicabilityResult;
  final String templateId;
  final EvidenceResolutionResult evidenceResolution;
  final String? omissionReason;
  final bool compressedReference;

  Map<String, Object?> toMap() => {
    'atom_id': atomId,
    'selected_claim': selectedClaimId,
    'selection_reason': selectionReason,
    'source': source.name,
    'source_claim_type': claimType.name,
    'applicability_result': applicabilityResult,
    'template_id': templateId,
    'evidence_resolution': evidenceResolution.toMap(),
    if (omissionReason != null) 'omission_reason': omissionReason,
    'compressed_reference': compressedReference,
  };
}

class PeriodScope {
  const PeriodScope(this.id, {this.start, this.end});

  final String id;
  final DateTime? start;
  final DateTime? end;

  Map<String, Object?> toMap() => {
    'id': id,
    if (start != null) 'start': _isoDate(start!),
    if (end != null) 'end': _isoDate(end!),
  };
}

class EvidenceTrace {
  const EvidenceTrace(this.refs);
  final List<String> refs;
  Map<String, Object?> toMap() => {'refs': refs};
}

class SemanticOwner {
  const SemanticOwner({required this.id, required this.meaningKey});
  final String id;
  final String meaningKey;
  Map<String, Object?> toMap() => {'id': id, 'meaningKey': meaningKey};
}

abstract class NarrativeAtom {
  const NarrativeAtom({
    required this.id,
    required this.role,
    required this.readerText,
    required this.compactText,
    required this.owner,
    required this.evidence,
    required this.period,
    required this.domain,
    required this.eligibility,
  });

  final String id;
  final NarrativeAtomRole role;
  final String readerText;
  final String compactText;
  final SemanticOwner owner;
  final EvidenceTrace evidence;
  final PeriodScope period;
  final DomainScope domain;
  final KnownUnknownEligibility eligibility;

  Map<String, Object?> toMap() => {
    'id': id,
    'role': role.name,
    'readerText': readerText,
    'compactText': compactText,
    'semanticOwner': owner.toMap(),
    'evidence': evidence.toMap(),
    'period': period.toMap(),
    'domain': domain.name,
    'eligibility': eligibility.name,
  };
}

class PredictionAtom extends NarrativeAtom {
  const PredictionAtom({
    required super.id,
    required super.readerText,
    required super.compactText,
    required super.owner,
    required super.evidence,
    required super.period,
    required super.domain,
    super.eligibility = KnownUnknownEligibility.knownOnly,
  }) : super(role: NarrativeAtomRole.prediction);
}

class SummaryAtom extends NarrativeAtom {
  const SummaryAtom({
    required super.id,
    required super.readerText,
    required super.compactText,
    required super.owner,
    required super.evidence,
    required super.period,
    required super.domain,
    super.eligibility = KnownUnknownEligibility.knownOnly,
  }) : super(role: NarrativeAtomRole.summary);
}

class AdviceAtom extends NarrativeAtom {
  const AdviceAtom({
    required super.id,
    required super.readerText,
    required super.compactText,
    required super.owner,
    required super.evidence,
    required super.period,
    required super.domain,
    super.eligibility = KnownUnknownEligibility.knownOnly,
  }) : super(role: NarrativeAtomRole.advice);
}

class DisclosureAtom extends NarrativeAtom {
  const DisclosureAtom({
    required super.id,
    required super.readerText,
    required super.compactText,
    required super.owner,
    required super.evidence,
    required super.period,
    required super.domain,
    required super.eligibility,
  }) : super(role: NarrativeAtomRole.disclosure);
}

class OmissionAtom extends NarrativeAtom {
  const OmissionAtom({
    required super.id,
    required super.readerText,
    required super.compactText,
    required super.owner,
    required super.evidence,
    required super.period,
    required super.domain,
  }) : super(
         role: NarrativeAtomRole.omission,
         eligibility: KnownUnknownEligibility.unknownOnly,
       );
}

class NarrativeBlock {
  const NarrativeBlock({this.heading, required this.atoms});
  final String? heading;
  final List<NarrativeAtom> atoms;
  Map<String, Object?> toMap() => {
    if (heading != null) 'heading': heading,
    'atoms': atoms.map((atom) => atom.toMap()).toList(growable: false),
  };
}

class NarrativeSection {
  const NarrativeSection({
    required this.id,
    required this.role,
    required this.title,
    required this.blocks,
  });
  final String id;
  final NarrativeSectionRole role;
  final String title;
  final List<NarrativeBlock> blocks;
  List<NarrativeAtom> get atoms =>
      blocks.expand((block) => block.atoms).toList(growable: false);
  Map<String, Object?> toMap() => {
    'id': id,
    'role': role.name,
    'title': title,
    'blocks': blocks.map((block) => block.toMap()).toList(growable: false),
  };
}

class PredictiveNarrativePlan {
  const PredictiveNarrativePlan({
    required this.contextId,
    required this.isKnownTime,
    required this.title,
    required this.subtitle,
    required this.sections,
    required this.evidenceCatalog,
    required this.provenance,
    this.monthlyTimelineAvailable = false,
  });

  factory PredictiveNarrativePlan.fromAnalysis(ThaiBetaAnalysis analysis) {
    if (!analysis.input.hasBirthTime) return _unknownPlan(analysis);
    final birthData = analysis.pipelineResult?.birthData;
    final timeline = analysis.pipelineResult?.lifePeriods;
    if (timeline == null) {
      throw StateError(
        'Known-time narrative requires a computed life timeline.',
      );
    }
    final remainder = ThaiRemainderMetadataResolver.resolve(
      profile: analysis.profile,
      birthData: birthData,
    );
    final weekday = birthData?.thaiWeekdayNumber;
    final contextId = remainder == null || weekday == null
        ? 'mahabhut2537.unresolved'
        : 'mahabhut2537.rem${remainder.value}.${_weekdayKey(weekday)}';
    return _sourceAuthorizedKnownPlan(
      analysis,
      contextId: contextId,
      timeline: timeline,
    );
  }

  final String contextId;
  final bool isKnownTime;
  final String title;
  final String subtitle;
  final List<NarrativeSection> sections;
  final PredictiveEvidenceCatalog evidenceCatalog;
  final List<GenerationProvenance> provenance;
  final bool monthlyTimelineAvailable;

  List<NarrativeAtom> get atoms =>
      sections.expand((section) => section.atoms).toList(growable: false);
  List<PredictiveClaimSpec> get claimSpecs => atoms
      .map(
        (atom) =>
            PredictiveClaimSpec.fromAtom(atom, contextSelector: contextId),
      )
      .toList(growable: false);
  List<String> get unresolvedEvidenceRefs => atoms
      .expand((atom) => atom.evidence.refs)
      .where((ref) => !evidenceCatalog.contains(ref))
      .toSet()
      .toList(growable: false);
  List<String> get resolvedEvidenceRefs =>
      evidenceCatalog.ids.toList(growable: false);
  bool resolvesEvidenceRef(String ref) => evidenceCatalog.contains(ref);
  int get legacyFallbackInvocations => provenance
      .where((entry) => entry.source == GenerationSource.legacyFallback)
      .length;
  int get fixtureSpecialInvocations => provenance
      .where((entry) => entry.source == GenerationSource.fixtureSpecial)
      .length;
  String get generationPath {
    final sources =
        provenance
            .map((entry) => entry.source.name)
            .toSet()
            .toList(growable: false)
          ..sort();
    return 'source-authorized-catalog-v1:${sources.join('+')}';
  }

  Map<String, Object?> toMap() => {
    'contextId': contextId,
    'isKnownTime': isKnownTime,
    'generationPath': generationPath,
    'legacyFallbackInvocations': legacyFallbackInvocations,
    'fixtureSpecialInvocations': fixtureSpecialInvocations,
    'title': title,
    'subtitle': subtitle,
    'monthlyTimelineAvailable': monthlyTimelineAvailable,
    'sections': sections.map((section) => section.toMap()).toList(),
    'generationProvenance': provenance.map((entry) => entry.toMap()).toList(),
  };
}

class _RealizedClaim {
  const _RealizedClaim({
    required this.record,
    required this.atom,
    required this.provenance,
    required this.sectionId,
    required this.sectionRole,
    required this.sectionTitle,
    required this.chronology,
    required this.motifKey,
    this.blockHeading,
  });
  final PredictiveAuthorityRecord record;
  final NarrativeAtom atom;
  final GenerationProvenance provenance;
  final String sectionId;
  final NarrativeSectionRole sectionRole;
  final String sectionTitle;
  final ClaimChronology chronology;
  final String motifKey;
  final String? blockHeading;
}

class SynthesisTemplateCatalog {
  static String templateId({
    required PredictiveAuthorityRecord claim,
    required PredictiveAuthorityRecord? placement,
    required ClaimChronology chronology,
  }) => [
    claim.claimType.name,
    claim.domainKey ?? 'none',
    claim.movement ?? 'none',
    placement?.periodStatus ?? 'no-status',
    placement?.taksaRole ?? 'no-role',
    placement?.mahabhutHouse ?? 'no-house',
    chronology.name,
  ].map(_templateToken).join('.');

  static String realize({
    required PredictiveAuthorityRecord claim,
    required PredictiveAuthorityRecord? placement,
    required ClaimChronology chronology,
    required ForecastMaterialFingerprint? material,
    required DateTime asOf,
    required int horizonIndex,
  }) {
    if (claim.readerText != null) return claim.readerText!;
    if (claim.claimType == PredictiveAuthorityType.forecastMaterial) {
      if (material == null) {
        throw StateError('Forecast authority ${claim.id} has no material.');
      }
      final body = _forecastReaderCopy(material, includeHorizonLead: false);
      if (chronology != ClaimChronology.horizon) return body;
      final range = _longHorizonRange(asOf);
      final lead = horizonIndex == 0
          ? 'ระหว่างวันที่ ${_thaiLongDate(range.$1)} ถึง ${_thaiLongDate(range.$2)} '
          : 'ในช่วงเดียวกัน ';
      return '$lead$body';
    }
    final period = _thaiPeriodLabel(claim.periodBinding);
    final lead = switch (chronology) {
      ClaimChronology.past => 'ในช่วงอายุ $period ',
      ClaimChronology.current => 'ช่วงอายุ $period ',
      ClaimChronology.future => 'เมื่อเข้าสู่ช่วงอายุ $period ',
      _ => '',
    };
    if (claim.claimType == PredictiveAuthorityType.sourceDirect) {
      final body = switch (claim.subject) {
        'supporting_people' =>
          'คนที่เกี่ยวข้องกับงานช่วยให้เรื่องสำคัญเดินต่อได้กว้างขึ้น',
        'work_access' =>
          'งานเดินหน้าได้คล่องขึ้น และโอกาสจากงานที่มีอยู่เปิดกว้างกว่าเดิม',
        'available_money' =>
          'เงินที่ใช้หมุนคล่องขึ้น โดยยังไม่สรุปเป็นจำนวนหรือโชคลาภก้อนใหญ่',
        'action_communication_thought' =>
          'การทำงาน การสื่อสาร และการตัดสินใจเดินหน้าได้ราบรื่นขึ้น',
        'temporary_gain' => 'ผลได้เกิดขึ้นชั่วคราวตามขอบเขตที่แหล่งข้อมูลระบุ',
        'gain_then_loss' =>
          'เงินที่เข้ามาบางส่วนออกไปกับภาระต่อเนื่อง จึงไม่อยู่ครบทั้งช่วง',
        'speech' => 'คำพูดและการตกลงมีผลต่อเรื่องที่กำลังเดินหน้าอย่างชัดเจน',
        _ => _broadDomainCopy(claim.domainKey, placement?.periodStatus),
      };
      return '$lead$body';
    }
    return '$lead${_broadDomainCopy(claim.domainKey, placement?.periodStatus)}';
  }
}

PredictiveNarrativePlan _unknownPlan(ThaiBetaAnalysis analysis) {
  const omissionText =
      'ไม่มีเวลาเกิด — รายงานจึงเว้นคำทำนายช่วงชีวิตที่ต้องใช้เวลาเกิด แทนการเดาข้อมูลที่ไม่มี';
  const disclosureText =
      'คำทำนายเป็นมุมมองตามความเชื่อ และควรเทียบกับข้อเท็จจริงก่อนตัดสินใจเรื่องสำคัญ';
  final catalog = PredictiveEvidenceCatalog.unknown();
  return PredictiveNarrativePlan(
    contextId: 'unknown-time',
    isKnownTime: false,
    title: 'รายงานฉบับย่อ',
    subtitle: _unknownSubtitle(analysis),
    evidenceCatalog: catalog,
    provenance: [
      GenerationProvenance(
        atomId: 'RC11-U-OMISSION-01',
        selectedClaimId: 'RC11-U-OMISSION-01',
        selectionReason: 'unknown-time fail-closed policy',
        source: GenerationSource.omission,
        claimType: PredictiveAuthorityType.omission,
        applicabilityResult: 'unknown-time',
        templateId: 'candidate-0011-exact',
        evidenceResolution: catalog.validateReferences(['OMISSION-U-01']),
        omissionReason: 'birth time unavailable',
      ),
      GenerationProvenance(
        atomId: 'RC11-U-DISCLOSURE-01',
        selectedClaimId: 'RC11-U-DISCLOSURE-01',
        selectionReason: 'single accepted belief disclosure',
        source: GenerationSource.disclosure,
        claimType: PredictiveAuthorityType.disclosure,
        applicabilityResult: 'report',
        templateId: 'candidate-0011-exact',
        evidenceResolution: catalog.validateReferences(['DISCLOSURE-U-01']),
      ),
    ],
    sections: const [
      NarrativeSection(
        id: 'report-short',
        role: NarrativeSectionRole.omission,
        title: '',
        blocks: [
          NarrativeBlock(
            atoms: [
              OmissionAtom(
                id: 'RC11-U-OMISSION-01',
                readerText: omissionText,
                compactText: 'เว้นหัวข้อที่ต้องใช้เวลาเกิด แทนการเดาข้อมูล',
                owner: SemanticOwner(
                  id: 'OMISSION-U-01',
                  meaningKey: 'unknown-time-fail-closed',
                ),
                evidence: EvidenceTrace(['OMISSION-U-01']),
                period: PeriodScope('UNAVAILABLE'),
                domain: DomainScope.omission,
              ),
            ],
          ),
        ],
      ),
      NarrativeSection(
        id: 'disclaimer',
        role: NarrativeSectionRole.disclaimer,
        title: '',
        blocks: [
          NarrativeBlock(
            atoms: [
              DisclosureAtom(
                id: 'RC11-U-DISCLOSURE-01',
                readerText: disclosureText,
                compactText: 'เทียบคำอ่านกับข้อเท็จจริงก่อนตัดสินใจ',
                owner: SemanticOwner(
                  id: 'DISCLOSURE-U-01',
                  meaningKey: 'belief-disclosure',
                ),
                evidence: EvidenceTrace(['DISCLOSURE-U-01']),
                period: PeriodScope('REPORT'),
                domain: DomainScope.disclosure,
                eligibility: KnownUnknownEligibility.unknownOnly,
              ),
            ],
          ),
        ],
      ),
    ],
  );
}

PredictiveNarrativePlan _sourceAuthorizedKnownPlan(
  ThaiBetaAnalysis analysis, {
  required String contextId,
  required LifeTimeline timeline,
}) {
  final materials = _forecastMaterials(analysis);
  final catalog = PredictiveEvidenceCatalog.forAnalysis(
    contextId: contextId,
    timeline: timeline,
    asOf: analysis.asOf,
    materials: materials,
  );
  final acceptedReaderClaims =
      catalog.records
          .where(
            (record) =>
                record.surface == 'Known' &&
                record.readerText != null &&
                record.contextId == contextId &&
                record.acceptedContractMatches(
                  age: timeline.currentAge,
                  asOf: analysis.asOf,
                ),
          )
          .toList(growable: false)
        ..sort(
          (left, right) =>
              (left.sourceOrder ?? 999).compareTo(right.sourceOrder ?? 999),
        );
  if (acceptedReaderClaims.isNotEmpty) {
    return _assembleAcceptedReaderClaims(
      analysis,
      contextId: contextId,
      timeline: timeline,
      catalog: catalog,
      claims: acceptedReaderClaims,
    );
  }
  return _assembleSourceAuthorizedClaims(
    analysis,
    contextId: contextId,
    timeline: timeline,
    catalog: catalog,
    materials: materials,
  );
}

PredictiveNarrativePlan _assembleAcceptedReaderClaims(
  ThaiBetaAnalysis analysis, {
  required String contextId,
  required LifeTimeline timeline,
  required PredictiveEvidenceCatalog catalog,
  required List<PredictiveAuthorityRecord> claims,
}) {
  final realized = <_RealizedClaim>[];
  for (final record in claims.where(
    (item) => item.readerRole == 'PREDICTION',
  )) {
    final domain = _domainScope(record.domainKey);
    final chronology = record.chronologyAt(timeline.currentAge);
    final validation = catalog.validateSelection(
      record: record,
      contextId: contextId,
      currentAge: timeline.currentAge,
      asOf: analysis.asOf,
      domain: domain,
      chronology: chronology,
      proposedText: record.readerText,
    );
    if (!validation.isValid) {
      throw StateError(
        'Accepted claim ${record.id} failed evidence validation.',
      );
    }
    final atom = PredictionAtom(
      id: record.readerClaimId!,
      readerText: record.readerText!,
      compactText: _compact(record.readerText!),
      owner: SemanticOwner(
        id: record.semanticOwnerId!,
        meaningKey: record.meaningKey!,
      ),
      evidence: EvidenceTrace(record.evidenceRefs),
      period: PeriodScope(record.periodBinding!),
      domain: domain,
    );
    realized.add(
      _RealizedClaim(
        record: record,
        atom: atom,
        provenance: GenerationProvenance(
          atomId: atom.id,
          selectedClaimId: record.id,
          selectionReason:
              'catalog record matches context, accepted age and accepted asOf',
          source: GenerationSource.ownerAuthorizedSynthesis,
          claimType: record.claimType,
          applicabilityResult: chronology.name,
          templateId: record.templateId!,
          evidenceResolution: validation,
        ),
        sectionId: record.sectionId!,
        sectionRole: NarrativeSectionRole.values.byName(record.sectionRole!),
        sectionTitle: record.sectionDisplayTitle!,
        blockHeading: record.blockHeading,
        chronology: chronology,
        motifKey: _motifKey(record, chronology),
      ),
    );
  }
  final sections = _groupRealized(realized);
  final predictiveRefs = realized
      .expand((item) => item.atom.evidence.refs)
      .toSet()
      .toList(growable: false);
  const summaryText =
      'ชีวิตกำลังเปลี่ยนจากรอบที่ต้องรับมือหลายอย่างพร้อมกัน ไปสู่รอบที่เลือกได้ชัดขึ้นว่าอะไรควรอยู่ต่อ เมื่อจัดภาระลงตัวแล้ว เส้นทางข้างหน้าจะนิ่งและต่อยอดเป็นฐานระยะยาวได้';
  const summaryAtom = SummaryAtom(
    id: 'RC11-K-SUMMARY-01',
    readerText: summaryText,
    compactText: 'จัดภาระให้ลงตัว แล้วต่อยอดสิ่งที่ควรอยู่ต่อ',
    owner: SemanticOwner(
      id: 'SUMMARY-K-01',
      meaningKey: 'compressed-life-arc-summary',
    ),
    evidence: EvidenceTrace([]),
    period: PeriodScope('REPORT'),
    domain: DomainScope.lifePath,
  );
  final summary = SummaryAtom(
    id: summaryAtom.id,
    readerText: summaryAtom.readerText,
    compactText: summaryAtom.compactText,
    owner: summaryAtom.owner,
    evidence: EvidenceTrace(predictiveRefs),
    period: summaryAtom.period,
    domain: summaryAtom.domain,
  );
  sections.add(
    _section('summary', NarrativeSectionRole.summary, 'สรุปคำทำนาย', [summary]),
  );
  final provenance = realized.map((item) => item.provenance).toList();
  provenance.add(
    GenerationProvenance(
      atomId: summary.id,
      selectedClaimId: 'candidate-0011-compressed-summary',
      selectionReason: 'declared compressed reference to selected predictions',
      source: GenerationSource.structuralSummary,
      claimType: PredictiveAuthorityType.ownerAuthorizedSynthesis,
      applicabilityResult: 'report',
      templateId: 'candidate-0011-compressed-summary',
      evidenceResolution: catalog.validateReferences(predictiveRefs),
      compressedReference: true,
    ),
  );
  for (final record in claims.where(
    (item) => item.readerRole != 'PREDICTION',
  )) {
    final atom = _nonPredictionAtom(record);
    final role = NarrativeSectionRole.values.byName(record.sectionRole!);
    sections.add(
      _section(record.sectionId!, role, record.sectionDisplayTitle!, [atom]),
    );
    provenance.add(
      GenerationProvenance(
        atomId: atom.id,
        selectedClaimId: record.id,
        selectionReason: 'accepted non-prediction catalog record',
        source: record.readerRole == 'ADVICE'
            ? GenerationSource.advice
            : GenerationSource.disclosure,
        claimType: record.claimType,
        applicabilityResult: 'report',
        templateId: record.templateId!,
        evidenceResolution: catalog.validateReferences(record.evidenceRefs),
      ),
    );
  }
  return PredictiveNarrativePlan(
    contextId: contextId,
    isKnownTime: true,
    title: 'คำทำนายดวงชะตา',
    subtitle: _knownSubtitle(analysis),
    sections: List.unmodifiable(sections),
    evidenceCatalog: catalog,
    provenance: List.unmodifiable(provenance),
  );
}

PredictiveNarrativePlan _assembleSourceAuthorizedClaims(
  ThaiBetaAnalysis analysis, {
  required String contextId,
  required LifeTimeline timeline,
  required PredictiveEvidenceCatalog catalog,
  required List<ForecastMaterialFingerprint> materials,
}) {
  final materialById = {
    for (final material in materials) material.evidenceKey: material,
  };
  final nextPlacement = catalog.nextPlacement(contextId, timeline.currentAge);
  final candidates = catalog.records.where((record) {
    if (!record.isPredictionAuthority || record.readerText != null) {
      return false;
    }
    if (record.contextId != contextId) return false;
    if (!record.acceptedContractMatches(
      age: timeline.currentAge,
      asOf: analysis.asOf,
    )) {
      return false;
    }
    final chronology = record.chronologyAt(timeline.currentAge);
    if (chronology == ClaimChronology.unavailable ||
        chronology == ClaimChronology.report) {
      return false;
    }
    if (chronology == ClaimChronology.current &&
        record.ageRanges.isNotEmpty &&
        !record.containsAge(timeline.currentAge)) {
      return false;
    }
    if (chronology == ClaimChronology.future) {
      final nextRange = nextPlacement?.ageRanges.first;
      if (nextRange == null ||
          !_rangeEqualsAny(record.ageRanges, nextRange.$1, nextRange.$2)) {
        return false;
      }
    }
    return true;
  }).toList();

  final productKeys = candidates
      .where(
        (record) =>
            record.claimType ==
            PredictiveAuthorityType.ownerAuthorizedProductInterpretation,
      )
      .map((record) => '${record.domainKey}|${record.periodBinding}')
      .toSet();
  candidates.removeWhere(
    (record) =>
        record.claimType == PredictiveAuthorityType.generalRuleApplication &&
        productKeys.contains('${record.domainKey}|${record.periodBinding}'),
  );
  final nonForecastDomains = candidates
      .where(
        (record) =>
            record.claimType != PredictiveAuthorityType.forecastMaterial,
      )
      .map(
        (record) =>
            '${record.chronologyAt(timeline.currentAge).name}|${_domainScope(record.domainKey).name}',
      )
      .toSet();
  candidates.removeWhere(
    (record) =>
        record.claimType == PredictiveAuthorityType.forecastMaterial &&
        nonForecastDomains.contains(
          '${record.chronologyAt(timeline.currentAge).name}|${_domainScope(record.domainKey).name}',
        ),
  );
  candidates.sort((left, right) {
    final chronology = _chronologyRank(
      left.chronologyAt(timeline.currentAge),
    ).compareTo(_chronologyRank(right.chronologyAt(timeline.currentAge)));
    if (chronology != 0) return chronology;
    final domain = _domainScope(
      left.domainKey,
    ).index.compareTo(_domainScope(right.domainKey).index);
    return domain != 0 ? domain : left.id.compareTo(right.id);
  });

  final realized = <_RealizedClaim>[];
  var horizonIndex = 0;
  for (final record in candidates) {
    final chronology = record.chronologyAt(timeline.currentAge);
    final domain = _domainScope(record.domainKey);
    final placement = catalog.placementFor(
      contextId: contextId,
      claim: record,
      currentAge: timeline.currentAge,
    );
    final text = SynthesisTemplateCatalog.realize(
      claim: record,
      placement: placement,
      chronology: chronology,
      material: materialById[record.id],
      asOf: analysis.asOf,
      horizonIndex: chronology == ClaimChronology.horizon ? horizonIndex++ : 0,
    );
    final validation = catalog.validateSelection(
      record: record,
      contextId: contextId,
      currentAge: timeline.currentAge,
      asOf: analysis.asOf,
      domain: domain,
      chronology: chronology,
      proposedText: text,
    );
    if (!validation.isValid) continue;
    final section = _sectionBinding(
      record: record,
      chronology: chronology,
      currentAge: timeline.currentAge,
      next: nextPlacement,
    );
    final templateId = SynthesisTemplateCatalog.templateId(
      claim: record,
      placement: placement,
      chronology: chronology,
    );
    final atom = PredictionAtom(
      id: 'SRC-${record.id}',
      readerText: text,
      compactText: _compact(text),
      owner: SemanticOwner(
        id: 'OWNER-${record.id}',
        meaningKey: _motifKey(record, chronology),
      ),
      evidence: EvidenceTrace([record.id, ...record.evidenceRefs]),
      period: PeriodScope(record.periodBinding ?? 'REPORT'),
      domain: domain,
    );
    realized.add(
      _RealizedClaim(
        record: record,
        atom: atom,
        provenance: GenerationProvenance(
          atomId: atom.id,
          selectedClaimId: record.id,
          selectionReason:
              'claim type, context, chronology and domain are applicable',
          source: _generationSource(record.claimType),
          claimType: record.claimType,
          applicabilityResult: chronology.name,
          templateId: templateId,
          evidenceResolution: validation,
        ),
        sectionId: section.$1,
        sectionRole: section.$2,
        sectionTitle: section.$3,
        blockHeading: section.$4,
        chronology: chronology,
        motifKey: _motifKey(record, chronology),
      ),
    );
  }
  final sections = _groupRealized(realized);
  final provenance = realized.map((item) => item.provenance).toList();
  final predictions = realized.map((item) => item.atom).toList();
  if (predictions.isNotEmpty) {
    final first = predictions.first;
    final second = predictions.length > 1 ? predictions[1] : null;
    final summaryText = second == null
        ? 'ประเด็นหลักของรอบนี้คือ ${first.compactText}'
        : 'ประเด็นหลักของรอบนี้คือ ${first.compactText} ส่วนเรื่องถัดมาคือ ${second.compactText}';
    final refs = <String>{
      ...first.evidence.refs,
      if (second != null) ...second.evidence.refs,
    }.toList(growable: false);
    final summary = SummaryAtom(
      id: 'SRC-SUMMARY-${timeline.currentAge}',
      readerText: summaryText,
      compactText: _compact(summaryText),
      owner: SemanticOwner(
        id: 'SUMMARY-${first.owner.id}',
        meaningKey: 'compressed-reference-${first.owner.meaningKey}',
      ),
      evidence: EvidenceTrace(refs),
      period: const PeriodScope('REPORT'),
      domain: DomainScope.lifePath,
    );
    sections.add(
      _section('summary', NarrativeSectionRole.summary, 'สรุปคำทำนาย', [
        summary,
      ]),
    );
    provenance.add(
      GenerationProvenance(
        atomId: summary.id,
        selectedClaimId: 'compressed-selected-claims',
        selectionReason: 'declared compressed reference; no new outcome added',
        source: GenerationSource.structuralSummary,
        claimType: PredictiveAuthorityType.ownerAuthorizedSynthesis,
        applicabilityResult: 'report',
        templateId: 'compressed-reference-v1',
        evidenceResolution: catalog.validateReferences(refs),
        compressedReference: true,
      ),
    );
  }
  const disclosure = DisclosureAtom(
    id: 'SRC-DISCLOSURE-KNOWN',
    readerText:
        'คำทำนายนี้เป็นมุมมองตามความเชื่อ ใช้ประกอบการทบทวนชีวิตและเทียบกับข้อเท็จจริงก่อนตัดสินใจเรื่องสำคัญ',
    compactText: 'ใช้ประกอบการทบทวนและเทียบกับข้อเท็จจริง',
    owner: SemanticOwner(
      id: 'DISCLOSURE-K-01',
      meaningKey: 'belief-disclosure',
    ),
    evidence: EvidenceTrace(['DISCLOSURE-K-01']),
    period: PeriodScope('REPORT'),
    domain: DomainScope.disclosure,
    eligibility: KnownUnknownEligibility.knownOnly,
  );
  sections.add(
    _section('disclaimer', NarrativeSectionRole.disclaimer, '', [disclosure]),
  );
  provenance.add(
    GenerationProvenance(
      atomId: disclosure.id,
      selectedClaimId: 'DISCLOSURE-K-01',
      selectionReason: 'single accepted belief disclosure',
      source: GenerationSource.disclosure,
      claimType: PredictiveAuthorityType.disclosure,
      applicabilityResult: 'report',
      templateId: 'belief-disclosure-v1',
      evidenceResolution: catalog.validateReferences(['DISCLOSURE-K-01']),
    ),
  );
  return PredictiveNarrativePlan(
    contextId: contextId,
    isKnownTime: true,
    title: 'คำทำนายดวงชะตา',
    subtitle: _knownSubtitle(analysis),
    sections: List.unmodifiable(sections),
    evidenceCatalog: catalog,
    provenance: List.unmodifiable(provenance),
  );
}

List<NarrativeSection> _groupRealized(List<_RealizedClaim> realized) {
  final sections = <NarrativeSection>[];
  for (final role in NarrativeSectionRole.values) {
    final matching = realized
        .where((item) => item.sectionRole == role)
        .toList();
    if (matching.isEmpty) continue;
    final first = matching.first;
    if (role == NarrativeSectionRole.past) {
      final headings = <String>[];
      for (final item in matching) {
        final heading = item.blockHeading!;
        if (!headings.contains(heading)) headings.add(heading);
      }
      sections.add(
        NarrativeSection(
          id: first.sectionId,
          role: role,
          title: first.sectionTitle,
          blocks: [
            for (final heading in headings)
              NarrativeBlock(
                heading: heading,
                atoms: matching
                    .where((item) => item.blockHeading == heading)
                    .map((item) => item.atom)
                    .toList(growable: false),
              ),
          ],
        ),
      );
    } else {
      sections.add(
        NarrativeSection(
          id: first.sectionId,
          role: role,
          title: first.sectionTitle,
          blocks: [
            NarrativeBlock(
              atoms: matching.map((item) => item.atom).toList(growable: false),
            ),
          ],
        ),
      );
    }
  }
  return sections;
}

NarrativeAtom _nonPredictionAtom(PredictiveAuthorityRecord record) {
  final shared = (
    id: record.readerClaimId!,
    text: record.readerText!,
    compact: _compact(record.readerText!),
    owner: SemanticOwner(
      id: record.semanticOwnerId!,
      meaningKey: record.meaningKey!,
    ),
    evidence: EvidenceTrace(record.evidenceRefs),
    period: PeriodScope(record.periodBinding ?? 'REPORT'),
    domain: _domainScope(record.domainKey),
  );
  return switch (record.readerRole) {
    'ADVICE' => AdviceAtom(
      id: shared.id,
      readerText: shared.text,
      compactText: shared.compact,
      owner: shared.owner,
      evidence: shared.evidence,
      period: shared.period,
      domain: shared.domain,
    ),
    'DISCLOSURE' => DisclosureAtom(
      id: shared.id,
      readerText: shared.text,
      compactText: shared.compact,
      owner: shared.owner,
      evidence: shared.evidence,
      period: shared.period,
      domain: shared.domain,
      eligibility: KnownUnknownEligibility.knownOnly,
    ),
    'OMISSION' => OmissionAtom(
      id: shared.id,
      readerText: shared.text,
      compactText: shared.compact,
      owner: shared.owner,
      evidence: shared.evidence,
      period: shared.period,
      domain: shared.domain,
    ),
    _ => throw StateError(
      'Unsupported non-prediction role ${record.readerRole}',
    ),
  };
}

(String, NarrativeSectionRole, String, String?) _sectionBinding({
  required PredictiveAuthorityRecord record,
  required ClaimChronology chronology,
  required int currentAge,
  required PredictiveAuthorityRecord? next,
}) {
  if (chronology == ClaimChronology.past) {
    return (
      'past',
      NarrativeSectionRole.past,
      'คำทำนายอดีต',
      'อายุ ${_thaiPeriodLabel(record.periodBinding)} ปี',
    );
  }
  if (chronology == ClaimChronology.horizon) {
    return (
      'horizon',
      NarrativeSectionRole.horizon,
      'คำทำนาย 12 เดือนข้างหน้า',
      null,
    );
  }
  if (chronology == ClaimChronology.future) {
    final title = next == null
        ? 'ช่วงชีวิตถัดไป'
        : 'ช่วงชีวิตถัดไป — อายุ ${_thaiPeriodLabel(next.periodBinding)} ปี';
    return ('next', NarrativeSectionRole.nextLifePeriod, title, null);
  }
  final domain = _domainScope(record.domainKey);
  if (domain == DomainScope.lifePath || domain == DomainScope.foundation) {
    return (
      'current',
      NarrativeSectionRole.current,
      'คำทำนายปัจจุบัน — อายุ $currentAge ปี',
      null,
    );
  }
  return switch (domain) {
    DomainScope.finance => (
      'finance',
      NarrativeSectionRole.finance,
      'การเงิน',
      null,
    ),
    DomainScope.relationship || DomainScope.financeAndRelationship => (
      'relationship',
      NarrativeSectionRole.relationship,
      'ความรักและความสัมพันธ์',
      null,
    ),
    DomainScope.health => (
      'health',
      NarrativeSectionRole.health,
      'สุขภาพ',
      null,
    ),
    DomainScope.support || DomainScope.luck || DomainScope.supportAndFamily => (
      'support',
      NarrativeSectionRole.support,
      'โชคลาภและแรงสนับสนุน',
      null,
    ),
    _ => ('work', NarrativeSectionRole.work, 'การงาน', null),
  };
}

List<ForecastMaterialFingerprint> _forecastMaterials(
  ThaiBetaAnalysis analysis,
) {
  final materials =
      analysis.consumerViewState?.futurePrediction?.windows
          .expand((window) => window.domains)
          .map((domain) => domain.material)
          .whereType<ForecastMaterialFingerprint>()
          .where(
            (material) =>
                material.evidenceAvailability ==
                    ForecastEvidenceAvailability.full &&
                material.timeDependent &&
                material.evidenceKey.isNotEmpty,
          )
          .toList(growable: false) ??
      const <ForecastMaterialFingerprint>[];
  final byKey = <String, ForecastMaterialFingerprint>{};
  for (final material in materials) {
    byKey.putIfAbsent(material.evidenceKey, () => material);
  }
  return List.unmodifiable(byKey.values);
}

String _forecastReaderCopy(
  ForecastMaterialFingerprint material, {
  required bool includeHorizonLead,
}) {
  final horizon = includeHorizonLead
      ? switch (material.horizon) {
          ForecastHorizon.current => 'ช่วงนี้ ',
          ForecastHorizon.next12Months => 'ในรอบ 12 เดือนนี้ ',
          ForecastHorizon.nextLifePeriod => 'ในช่วงชีวิตถัดไป ',
        }
      : '';
  final strength = switch (material.band) {
    ForecastBand.strong => 'ขยับชัดและให้ผลจากสิ่งที่ทำต่อเนื่อง',
    ForecastBand.active => 'เดินหน้าทีละขั้นจากข้อตกลงที่ทำได้จริง',
    ForecastBand.quiet => 'ชะลอเพื่อจัดฐานเดิมและปิดเรื่องที่กินแรง',
  };
  final body = switch (material.domain) {
    ForecastDomain.career =>
      'งาน$strength บทบาทหลักชัดขึ้นเมื่อผลงานส่งมอบได้ตามขอบเขต',
    ForecastDomain.finance =>
      'การเงิน$strength ฐานเงินนิ่งขึ้นเมื่อกันรายการจำเป็นก่อนรับภาระเพิ่ม',
    ForecastDomain.relationship =>
      'ความสัมพันธ์$strength ระยะของแต่ละคนชัดจากการทำตามข้อตกลง',
    ForecastDomain.health =>
      'การพักและการฟื้นตัว$strength กำลังกลับมาเมื่อเวลานอนทำได้ต่อเนื่อง',
  };
  return '$horizon$body';
}

String _broadDomainCopy(String? domain, String? periodStatus) {
  final movement = periodStatus == 'dueng_tok'
      ? 'ต้องค่อย ๆ จัดฐาน'
      : 'เดินหน้าได้ดีขึ้น';
  return switch (domain) {
    'life_path' =>
      'ความรับผิดชอบพาไปสู่งานและเงินที่แข็งแรงขึ้น ก่อนต่อยอดเป็นฐานระยะยาว',
    'work' || 'career' || 'work_and_commitment' =>
      'งาน$movement และขอบเขตความรับผิดชอบชัดขึ้นตามสิ่งที่ทำสำเร็จ',
    'finance' =>
      'เงินและผลจากสิ่งที่ทำ$movement โดยไม่ขยายเป็นจำนวนหรือโชคลาภก้อนใหญ่',
    'foundation' => 'การสร้างฐานบ้าน ทรัพย์ และเงินระยะยาว$movement',
    'support' => 'แรงสนับสนุนจากคนที่เกี่ยวข้องช่วยให้เรื่องสำคัญ$movement',
    _ => 'เรื่องที่มีหลักฐานรองรับ$movementภายในขอบเขตของช่วงนี้',
  };
}

DomainScope _domainScope(String? key) => switch (key) {
  'life_path' => DomainScope.lifePath,
  'support_and_family' => DomainScope.supportAndFamily,
  'education_social' => DomainScope.educationAndSocial,
  'work' || 'career' => DomainScope.work,
  'work_and_commitment' => DomainScope.workAndCommitment,
  'finance' => DomainScope.finance,
  'relationship' => DomainScope.relationship,
  'health' => DomainScope.health,
  'support' => DomainScope.support,
  'luck' => DomainScope.luck,
  'finance_relationship' => DomainScope.financeAndRelationship,
  'communication' => DomainScope.communication,
  'foundation' => DomainScope.foundation,
  'advice' => DomainScope.advice,
  'disclosure' => DomainScope.disclosure,
  'omission' => DomainScope.omission,
  _ => DomainScope.lifePath,
};

GenerationSource _generationSource(PredictiveAuthorityType type) =>
    switch (type) {
      PredictiveAuthorityType.sourceDirect => GenerationSource.sourceDirect,
      PredictiveAuthorityType.generalRuleApplication =>
        GenerationSource.generalRuleApplication,
      PredictiveAuthorityType.ownerAuthorizedProductInterpretation ||
      PredictiveAuthorityType.ownerAuthorizedSynthesis =>
        GenerationSource.ownerAuthorizedSynthesis,
      PredictiveAuthorityType.forecastMaterial =>
        GenerationSource.forecastMaterial,
      _ => throw StateError(
        'Non-predictive authority cannot generate a prediction.',
      ),
    };

PredictiveAuthorityType _authorityType(String raw) => switch (raw) {
  'SOURCE_PLACEMENT_FACT' => PredictiveAuthorityType.placementFact,
  'SOURCE_GENERAL_RULE' => PredictiveAuthorityType.sourceGeneralRule,
  'SOURCE_DIRECT_PREDICTION' => PredictiveAuthorityType.sourceDirect,
  'SOURCE_GENERAL_RULE_APPLICATION' =>
    PredictiveAuthorityType.generalRuleApplication,
  'OWNER_AUTHORIZED_PRODUCT_INTERPRETATION' =>
    PredictiveAuthorityType.ownerAuthorizedProductInterpretation,
  'OWNER_AUTHORIZED_ASTROLOGICAL_SYNTHESIS' =>
    PredictiveAuthorityType.ownerAuthorizedSynthesis,
  'FORECAST_MATERIAL' => PredictiveAuthorityType.forecastMaterial,
  'ADVICE' => PredictiveAuthorityType.advice,
  'DISCLOSURE' => PredictiveAuthorityType.disclosure,
  'OMISSION' => PredictiveAuthorityType.omission,
  _ => throw StateError('Unsupported predictive authority type: $raw'),
};

bool _domainKeysCompatible(String? key, DomainScope domain) {
  if (key == null || key.isEmpty) return true;
  return _domainScope(key) == domain;
}

List<String> _prohibitedEscalationHits(
  PredictiveAuthorityRecord record,
  String text,
) {
  if (record.prohibitedEscalation.isEmpty) return const [];
  final hits = <String>[];
  final prohibited = record.prohibitedEscalation.toSet();
  if (prohibited.any(
        (item) =>
            item.contains('specific month') || item.contains('specific date'),
      ) &&
      RegExp(
        r'(มกราคม|กุมภาพันธ์|มีนาคม|เมษายน|พฤษภาคม|มิถุนายน|กรกฎาคม|สิงหาคม|กันยายน|ตุลาคม|พฤศจิกายน|ธันวาคม)',
      ).hasMatch(text)) {
    hits.add('specific month or date');
  }
  if (prohibited.any(
        (item) =>
            item.contains('specific amount') ||
            item.contains('numeric threshold'),
      ) &&
      RegExp(r'\d[\d,]*(?:\s*)(บาท|เปอร์เซ็นต์|%)').hasMatch(text)) {
    hits.add('specific amount or numeric threshold');
  }
  if (prohibited.any((item) => item.contains('medical diagnosis')) &&
      RegExp(r'(วินิจฉัย|มะเร็ง|เบาหวาน|โรคหัวใจ|โรคไต)').hasMatch(text)) {
    hits.add('medical diagnosis');
  }
  if (prohibited.any((item) => item.contains('marriage or separation')) &&
      RegExp(r'(แต่งงาน|สมรส|หย่าร้าง|เลิกรา|เลิกกัน)').hasMatch(text)) {
    hits.add('marriage or separation');
  }
  if (prohibited.any((item) => item.contains('job transfer')) &&
      text.contains('ย้ายงาน')) {
    hits.add('job transfer');
  }
  if (prohibited.any((item) => item.contains('large windfall')) &&
      text.contains('ลาภก้อนใหญ่')) {
    hits.add('large windfall');
  }
  if (prohibited.any((item) => item.contains('specific promotion')) &&
      text.contains('เลื่อนตำแหน่ง')) {
    hits.add('specific promotion');
  }
  return hits;
}

bool _rangesOverlap(List<(int, int)> left, List<(int, int)> right) =>
    left.any((a) => right.any((b) => a.$1 <= b.$2 && b.$1 <= a.$2));

bool _rangeEqualsAny(List<(int, int)> ranges, int start, int end) =>
    ranges.any((range) => range.$1 == start && range.$2 == end);

int _chronologyRank(ClaimChronology chronology) => switch (chronology) {
  ClaimChronology.past => 0,
  ClaimChronology.current => 1,
  ClaimChronology.horizon => 2,
  ClaimChronology.future => 3,
  ClaimChronology.report => 4,
  ClaimChronology.unavailable => 5,
};

String _motifKey(
  PredictiveAuthorityRecord record,
  ClaimChronology chronology,
) => [
  record.domainKey ?? 'none',
  record.movement ?? 'none',
  record.periodBinding ?? 'none',
  record.subject ?? record.meaningKey ?? 'none',
  chronology.name,
].map(_templateToken).join('|');

String _templateToken(String value) => value
    .toLowerCase()
    .replaceAll(RegExp(r'[^a-z0-9]+'), '-')
    .replaceAll(RegExp(r'^-+|-+$'), '');

String _thaiPeriodLabel(String? binding) => (binding ?? 'ช่วงที่ระบุ')
    .replaceAll(RegExp(r'\|.*$'), '')
    .replaceAll('-', '–')
    .replaceFirst(RegExp(r'^0–'), '1–');

List<String> _mapStringList(Object? value) =>
    (value as List? ?? const []).whereType<String>().toList(growable: false);

NarrativeSection _section(
  String id,
  NarrativeSectionRole role,
  String title,
  List<NarrativeAtom> atoms,
) => NarrativeSection(
  id: id,
  role: role,
  title: title,
  blocks: [NarrativeBlock(atoms: atoms)],
);

String _compact(String value) {
  final normalized = value.trim();
  if (normalized.length <= 92) return normalized;
  final sentenceEnd = normalized.indexOf(RegExp(r'[.!?。]|[\u0E2F]'));
  if (sentenceEnd > 0 && sentenceEnd < 92) {
    return normalized.substring(0, sentenceEnd + 1);
  }
  final cut = normalized.lastIndexOf(' ', 92);
  // Thai words are not separated by spaces. If a complete first clause ends
  // before the old 48-character threshold, falling back to a raw UTF-16 cut
  // can leave a reader-facing fragment such as "รับภาระเพ". Prefer any useful
  // clause boundary and keep the full text when no safe boundary exists.
  if (cut > 24) return normalized.substring(0, cut).trim();
  return normalized;
}

String _knownSubtitle(ThaiBetaAnalysis analysis) {
  final input = analysis.input;
  final birthData = analysis.pipelineResult?.birthData;
  final profile = analysis.profile;
  final time =
      '${input.birthHour!.toString().padLeft(2, '0')}:${input.birthMinute.toString().padLeft(2, '0')}';
  final province = input.province?.trim() ?? '';
  final identity = [
    'เกิดวันที่ ${_thaiLongDate(input.birthDate)} เวลา $time น.${province.isEmpty ? '' : ' จังหวัด$province'}',
    [
      if ((input.gender ?? '').trim().isNotEmpty) 'เพศ${input.gender!.trim()}',
      if (birthData != null)
        'วันทางโหราศาสตร์เป็นวัน${_weekdayThai(birthData.thaiWeekdayNumber)}',
    ].join(' · '),
    if (profile?.lagnaKey != null && profile?.siderealAscendantDeg != null)
      'ลัคนา${_lagnaLabel(profile!.lagnaKey!)} ${_degreeWithinSign(profile.siderealAscendantDeg!)}',
  ].where((line) => line.trim().isNotEmpty).toList(growable: false);
  return identity.join('\n');
}

String _unknownSubtitle(ThaiBetaAnalysis analysis) {
  final province = analysis.input.province?.trim() ?? '';
  return 'เกิดวันที่ ${_thaiLongDate(analysis.input.birthDate)}${province.isEmpty ? '' : ' จังหวัด$province'} โดยไม่ทราบเวลาเกิด';
}

(DateTime, DateTime) _longHorizonRange(DateTime asOf) {
  final nextYear = asOf.year + 1;
  final lastDay = DateTime(nextYear, asOf.month + 1, 0).day;
  final anniversary = DateTime(
    nextYear,
    asOf.month,
    asOf.day > lastDay ? lastDay : asOf.day,
  );
  return (asOf, anniversary.subtract(const Duration(days: 1)));
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

bool _sameDate(DateTime left, DateTime right) =>
    left.year == right.year &&
    left.month == right.month &&
    left.day == right.day;

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

String _degreeWithinSign(double siderealDegree) {
  final normalized = ((siderealDegree % 30) + 30) % 30;
  var totalMinutes = (normalized * 60).round();
  if (totalMinutes >= 30 * 60) totalMinutes = (30 * 60) - 1;
  final degrees = totalMinutes ~/ 60;
  final minutes = (totalMinutes % 60).toString().padLeft(2, '0');
  return '$degrees°$minutes′';
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
