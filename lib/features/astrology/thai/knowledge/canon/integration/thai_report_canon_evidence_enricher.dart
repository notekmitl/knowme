import 'package:knowme/features/astrology/thai/content/models/thai_content_key.dart';
import 'package:knowme/features/astrology/thai/core/life_period/life_period_status_metadata.dart';
import 'package:knowme/features/astrology/thai/knowledge/canon/atomic/atomic_knowledge_unit.dart';
import 'package:knowme/features/astrology/thai/knowledge/canon/atomic/atomic_relation.dart';
import 'package:knowme/features/astrology/thai/mirror/models/thai_mirror_lens_source.dart';
import 'package:knowme/features/astrology/thai/mirror/models/thai_mirror_section_id.dart';
import 'package:knowme/features/astrology/thai/mirror/runtime/thai_mirror_pipeline_result.dart';

import 'thai_canon_evidence_attachment.dart';
import 'thai_canon_evidence_mapper.dart';
import 'thai_canon_evidence_ref.dart';
import 'thai_canon_evidence_repository.dart';
import 'thai_canon_evidence_signal_scope.dart';
import 'thai_canon_evidence_trace.dart';
import 'thai_canon_evidence_type.dart';
import 'thai_canon_ontology_runtime_mapping.dart';
import 'thai_canon_period_status_discovery.dart';
import 'thai_canon_period_status_from_evidence.dart';
import 'thai_canon_period_status_runtime_mapping.dart';
import 'thai_mirror_canon_evidence_bundle.dart';

/// Attaches frozen Canon evidence to Thai Mirror pipeline output without
/// mutating user-facing report structures.
abstract final class ThaiReportCanonEvidenceEnricher {
  /// Structural fingerprint of user-visible pipeline fields (QA regression).
  static String userFacingFingerprint(ThaiMirrorPipelineResult result) {
    if (!result.isSuccess) return 'failure:${result.errorMessage}';
    final mirror = result.mirrorResult!;
    final view = result.viewState!;
    return [
      mirror.contractVersion,
      mirror.topThemes.map((t) => t.themeId).join(','),
      mirror.sections
          .map((s) => '${s.id.name}:${s.evidence.length}:${s.summary}')
          .join('|'),
      view.topThemes.map((t) => t.themeId).join(','),
      view.hero.reflectionSummary,
      view.hero.titleTh,
      view.sections.map((s) => '${s.id.name}:${s.titleTh}').join('|'),
      result.profile!.mahabhutaPositionKeys.join(','),
    ].join('::');
  }

  static Future<ThaiMirrorCanonEvidenceBundle> enrich(
    ThaiMirrorPipelineResult pipelineResult, {
    ThaiCanonEvidenceRepository? repository,
    Map<int, String>? periodStatusLabelsByIndex,
  }) async {
    if (!pipelineResult.isSuccess) {
      return ThaiMirrorCanonEvidenceBundle(
        pipelineResult: pipelineResult,
        attachments: const [],
        trace: const ThaiCanonEvidenceTrace(),
      );
    }

    final repo = repository ?? await ThaiCanonEvidenceRepository.loadFromAsset();
    final mapper = repo.mapper;
    final attachments = <ThaiCanonEvidenceAttachment>[];
    final outOfCanonScope = <String>[];
    final inCanonScopeUnmapped = <String>[];
    final traceOnlyCandidates = <String>[];
    final runtimeUnmapped = <String>[];
    final canonCandidates = <String>[];
    final lifePeriodsWithoutRuntimeStatus = <String>[];
    final lifePeriodsWithCanonDerivedStatus = <String>[];
    final lifePeriodsWithoutCanonStatusMarker = <String>[];
    final lifePeriodsWithRuntimeStatus = <String>[];

    final periodStatusLabels = ThaiCanonPeriodStatusDiscovery.discover(
      pipelineResult,
      labelsByPeriodIndex: periodStatusLabelsByIndex,
    );
    final periodStatusAudit = periodStatusLabelsByIndex == null
        ? ThaiCanonPeriodStatusDiscovery.audit(pipelineResult)
        : null;
    final positionFeasibilityAudit =
        ThaiLifePeriodPositionMetadataFeasibility.audit(
      timeline: pipelineResult.lifePeriods,
      profile: pipelineResult.profile,
      birthData: pipelineResult.birthData,
      canonIndex: repo.index,
    );
    final archetypeFeasibilityAudit =
        ThaiArchetypeContextMetadataFeasibility.audit(
      profile: pipelineResult.profile,
      birthData: pipelineResult.birthData,
      canonIndex: repo.index,
    );
    final remainderFeasibilityAudit =
        ThaiRemainderRuntimeMetadataFeasibility.audit(
      profile: pipelineResult.profile,
      birthData: pipelineResult.birthData,
    );
    final calculationModelAudit =
        remainderFeasibilityAudit.calculationModelFeasibility;
    final remainderMetadata = ThaiRemainderMetadataResolver.resolve(
      profile: pipelineResult.profile,
      birthData: pipelineResult.birthData,
    );
    final archetypeResolution = ThaiArchetypeContextResolver.resolve(
      remainderMetadata: remainderMetadata,
      canonIndex: repo.index,
    );
    final archetypeMetadata = archetypeResolution.metadata;
    final profilesWithRemainderMetadata = <String>[];
    final profilesWithoutRemainderMetadata = <String>[];
    final profilesWithArchetypeContextMetadata = <String>[];
    final profilesWithoutArchetypeContextMetadata = <String>[];
    const profileAnchor = 'profile:remainder';
    const archetypeAnchor = 'profile:archetype';
    if (remainderMetadata != null) {
      profilesWithRemainderMetadata.add(profileAnchor);
    } else {
      profilesWithoutRemainderMetadata.add(profileAnchor);
    }
    if (archetypeMetadata != null) {
      profilesWithArchetypeContextMetadata.add(archetypeAnchor);
    } else {
      profilesWithoutArchetypeContextMetadata.add(archetypeAnchor);
    }

    final mirror = pipelineResult.mirrorResult!;

    for (final section in mirror.sections) {
      for (final evidence in section.evidence) {
        final signalId = '${section.id.name}:${evidence.contentKey}';
        _attachSectionEvidence(
          sectionId: section.id,
          signalId: signalId,
          lensSource: evidence.lensSource,
          contentKey: evidence.contentKey,
          mapper: mapper,
          attachments: attachments,
          outOfCanonScope: outOfCanonScope,
          inCanonScopeUnmapped: inCanonScopeUnmapped,
          traceOnlyCandidates: traceOnlyCandidates,
          runtimeUnmapped: runtimeUnmapped,
        );
      }
    }

    for (final contentKey in pipelineResult.profile!.mahabhutaPositionKeys) {
      final signalId = 'profile:mahabhuta_position:$contentKey';
      if (ThaiCanonEvidenceSignalScope.isOutOfCanonScope(contentKey)) {
        outOfCanonScope.add(signalId);
        continue;
      }
      final refs = mapper.evidenceForRuntimeContentKey(contentKey);
      if (refs.isEmpty) {
        inCanonScopeUnmapped.add(signalId);
        if (ThaiCanonEvidenceSignalScope.isInCanonScopeMahabhutKey(contentKey)) {
          runtimeUnmapped.add(contentKey);
        }
        continue;
      }
      attachments.add(
        ThaiCanonEvidenceAttachment(
          sectionId: null,
          signalId: signalId,
          evidenceType: ThaiCanonEvidenceType.mahabhutPosition,
          evidenceRefs: refs,
        ),
      );
    }

    final timeline = pipelineResult.lifePeriods;
    if (timeline != null) {
      for (final period in timeline.periods) {
        final planetId = 'planet.${period.planet.name}';
        final units = _lifePeriodStructuralUnits(repo, planetId);
        final signalId = 'life_period:${period.index}:$planetId';
        if (units.isEmpty) {
          inCanonScopeUnmapped.add(signalId);
        } else {
          attachments.add(
            ThaiCanonEvidenceAttachment(
              sectionId: 'lifeTimeline',
              signalId: signalId,
              evidenceType: ThaiCanonEvidenceType.lifePeriodStructural,
              evidenceRefs: mapper.refsForUnits(units),
              matchQuality: ThaiCanonEvidenceMatchQuality.structural,
            ),
          );
        }

        final structuralRefs = mapper.refsForUnits(units);

        final statusLabel = periodStatusLabels[period.index];
        if (statusLabel == null) {
          lifePeriodsWithoutRuntimeStatus.add(signalId);
          if (units.isNotEmpty) {
            final canonDerivedId =
                ThaiCanonPeriodStatusFromEvidence.canonIdFromLifePeriodRefs(
              structuralRefs,
            );
            if (canonDerivedId == null) {
              lifePeriodsWithoutCanonStatusMarker.add(signalId);
            } else {
              lifePeriodsWithCanonDerivedStatus.add(signalId);
              final statusRefs =
                  mapper.evidenceForPeriodStatusCanonId(canonDerivedId);
              if (statusRefs.isNotEmpty) {
                attachments.add(
                  ThaiCanonEvidenceAttachment(
                    sectionId: 'lifeTimeline',
                    signalId:
                        '$signalId:periodStatus:canonDerived:$canonDerivedId',
                    evidenceType: ThaiCanonEvidenceType.periodStatusStructural,
                    evidenceRefs: statusRefs,
                    matchQuality: ThaiCanonEvidenceMatchQuality.structural,
                  ),
                );
              }
            }
          }
          continue;
        }

        final canonStatusId =
            ThaiCanonPeriodStatusRuntimeMapping.canonIdForRuntimeLabel(
          statusLabel,
        );
        if (canonStatusId == null) continue;

        lifePeriodsWithRuntimeStatus.add(signalId);

        final statusRefs = mapper.evidenceForPeriodStatusCanonId(canonStatusId);
        if (statusRefs.isEmpty) {
          inCanonScopeUnmapped.add(
            '$signalId:periodStatus:$statusLabel',
          );
          continue;
        }

        attachments.add(
          ThaiCanonEvidenceAttachment(
            sectionId: 'lifeTimeline',
            signalId: '$signalId:periodStatus:$statusLabel',
            evidenceType: ThaiCanonEvidenceType.periodStatusStructural,
            evidenceRefs: statusRefs,
            matchQuality: ThaiCanonEvidenceMatchQuality.structural,
          ),
        );
      }
    }

    if (periodStatusLabels.isEmpty) {
      final predictionRefs = _predictionRuleRefs(repo);
      if (predictionRefs.isNotEmpty) {
        traceOnlyCandidates.add(
          'prediction:phase_e_rules (${predictionRefs.length} periodStatus refs; '
          'bulk internal metadata only — no runtime period status labels)',
        );
      }
    }
    for (final entry in ThaiCanonOntologyRuntimeMapping.taksaRoleMappings()) {
      if (!entry.isMapped) {
        canonCandidates.add(entry.canonEntityId);
      }
    }
    if (ThaiCanonOntologyRuntimeMapping.runtimePlanetKey('planet.ketu') == null) {
      canonCandidates.add('planet.ketu');
    }
    canonCandidates.add('mahabhutPosition.khumsap');

    final lookupCount = repo.index.units
        .where((u) => u.domain == KnowledgeDomain.lookupTables)
        .length;

    final trace = ThaiCanonEvidenceTrace(
      signalsWithoutCanonEvidence: _sortedUnique(inCanonScopeUnmapped),
      outOfCanonScopeSignals: _sortedUnique(outOfCanonScope),
      inCanonScopeUnmappedSignals: _sortedUnique(inCanonScopeUnmapped),
      traceOnlyEvidenceCandidates: _sortedUnique(traceOnlyCandidates),
      runtimeKeysWithoutCanonMapping: _sortedUnique(runtimeUnmapped),
      unmappedCanonEvidenceCandidates: _sortedUnique(canonCandidates),
      skippedRemedyEvidenceCount: mapper.evidenceForRemedyDomain().length,
      skippedTaksaEvidenceCount: repo.index.units
          .where((u) => u.object.startsWith('taksaRole.'))
          .length,
      skippedLookupTableEvidenceCount: lookupCount,
      skippedPeriodStatusNotes: const [],
      lifePeriodsWithoutRuntimeStatus:
          _sortedUnique(lifePeriodsWithoutRuntimeStatus),
      lifePeriodsWithCanonDerivedStatus:
          _sortedUnique(lifePeriodsWithCanonDerivedStatus),
      lifePeriodsWithoutCanonStatusMarker:
          _sortedUnique(lifePeriodsWithoutCanonStatusMarker),
      lifePeriodsWithRuntimeStatus:
          _sortedUnique(lifePeriodsWithRuntimeStatus),
      lifePeriodRiseFallFeasibilityResult:
          periodStatusAudit?.feasibility.result.wire,
      lifePeriodPositionFeasibilityResult:
          positionFeasibilityAudit.result.wire,
      lifePeriodPositionMetadataBlocker:
          positionFeasibilityAudit.metadataBlocker,
      lifePeriodArchetypeFeasibilityResult:
          archetypeFeasibilityAudit.result.wire,
      lifePeriodArchetypeMetadataBlocker:
          archetypeFeasibilityAudit.metadataBlocker,
      remainderFeasibilityResult: remainderFeasibilityAudit.result.wire,
      remainderCalculationFeasibilityResult: calculationModelAudit.result.wire,
      remainderMetadataBlocker: remainderFeasibilityAudit.metadataBlocker,
      remainderSourceField: remainderMetadata?.sourceField,
      remainderCanonId: remainderMetadata?.rotationIndexCanonId,
      profilesWithRemainderMetadata:
          _sortedUnique(profilesWithRemainderMetadata),
      profilesWithoutRemainderMetadata:
          _sortedUnique(profilesWithoutRemainderMetadata),
      profilesWithArchetypeContextMetadata:
          _sortedUnique(profilesWithArchetypeContextMetadata),
      profilesWithoutArchetypeContextMetadata:
          _sortedUnique(profilesWithoutArchetypeContextMetadata),
      archetypeMappingSource: archetypeMetadata?.source,
      archetypeContextMetadataBlocker:
          archetypeFeasibilityAudit.metadataBlocker,
      archetypeChartCanonId: archetypeMetadata?.archetypeChartCanonId,
      lifePeriodStatusMetadataBlocker: periodStatusAudit?.blocker,
    );

    attachments.sort((a, b) => a.signalId.compareTo(b.signalId));

    return ThaiMirrorCanonEvidenceBundle(
      pipelineResult: pipelineResult,
      attachments: List<ThaiCanonEvidenceAttachment>.unmodifiable(attachments),
      trace: trace,
    );
  }

  static void _attachSectionEvidence({
    required ThaiMirrorSectionId sectionId,
    required String signalId,
    required ThaiMirrorLensSource lensSource,
    required String contentKey,
    required ThaiCanonEvidenceMapper mapper,
    required List<ThaiCanonEvidenceAttachment> attachments,
    required List<String> outOfCanonScope,
    required List<String> inCanonScopeUnmapped,
    required List<String> traceOnlyCandidates,
    required List<String> runtimeUnmapped,
  }) {
    if (ThaiCanonEvidenceSignalScope.isOutOfCanonScopeLens(lensSource) ||
        ThaiCanonEvidenceSignalScope.isOutOfCanonScope(contentKey)) {
      outOfCanonScope.add(signalId);
      return;
    }

    switch (lensSource) {
      case ThaiMirrorLensSource.mahabhutaPosition:
        final refs = mapper.evidenceForRuntimeContentKey(contentKey);
        if (refs.isEmpty) {
          inCanonScopeUnmapped.add(signalId);
          if (ThaiCanonEvidenceSignalScope.isInCanonScopeMahabhutKey(contentKey)) {
            runtimeUnmapped.add(contentKey);
          }
          return;
        }
        attachments.add(
          ThaiCanonEvidenceAttachment(
            sectionId: sectionId.name,
            signalId: signalId,
            evidenceType: ThaiCanonEvidenceType.mahabhutPosition,
            evidenceRefs: refs,
          ),
        );
      case ThaiMirrorLensSource.lagnaLord:
        final planetId = _planetIdFromLagnaLordKey(contentKey);
        if (planetId == null) {
          inCanonScopeUnmapped.add(signalId);
          return;
        }
        final attachResult = _planetSignificationAttachmentRefs(mapper, planetId);
        if (attachResult.attachRefs.isEmpty) {
          if (attachResult.attributeOnlyCandidate) {
            traceOnlyCandidates.add(
              '$signalId (planet attribute evidence only — trace-only)',
            );
          } else {
            inCanonScopeUnmapped.add(signalId);
          }
          return;
        }
        attachments.add(
          ThaiCanonEvidenceAttachment(
            sectionId: sectionId.name,
            signalId: signalId,
            evidenceType: ThaiCanonEvidenceType.planetSignification,
            evidenceRefs: attachResult.attachRefs,
            matchQuality: ThaiCanonEvidenceMatchQuality.structural,
          ),
        );
      case ThaiMirrorLensSource.lagna:
      case ThaiMirrorLensSource.myanmarSeven:
        outOfCanonScope.add(signalId);
    }
  }

  static String? _planetIdFromLagnaLordKey(String contentKey) {
    const prefix = 'lagna_lord_';
    if (!contentKey.startsWith(prefix)) return null;
    final planet = contentKey.substring(prefix.length).trim();
    if (planet.isEmpty) return null;
    return 'planet.$planet';
  }

  static ({List<ThaiCanonEvidenceRef> attachRefs, bool attributeOnlyCandidate})
      _planetSignificationAttachmentRefs(
    ThaiCanonEvidenceMapper mapper,
    String planetId,
  ) {
    final ownsUnits = mapper.index.units.where(
      (u) => u.subject == planetId && u.relation == AtomicRelation.owns,
    );
    if (ownsUnits.isNotEmpty) {
      return (
        attachRefs: mapper.refsForUnits(ownsUnits),
        attributeOnlyCandidate: false,
      );
    }

    final attributeUnits = mapper.index.units.where(
      (u) =>
          u.subject == planetId &&
          u.relation == AtomicRelation.relatesTo &&
          u.object.startsWith('attribute.'),
    );
    if (attributeUnits.isNotEmpty) {
      return (attachRefs: const [], attributeOnlyCandidate: true);
    }

    return (attachRefs: const [], attributeOnlyCandidate: false);
  }

  static Iterable<AtomicKnowledgeUnit> _lifePeriodStructuralUnits(
    ThaiCanonEvidenceRepository repo,
    String planetId,
  ) {
    return repo.index.units.where(
      (u) =>
          u.subject == planetId &&
          u.relation == AtomicRelation.locatedIn &&
          u.context?.type == AtomicContextType.lifePeriod &&
          u.object.startsWith('mahabhutPosition.'),
    );
  }

  static List<ThaiCanonEvidenceRef> _predictionRuleRefs(
    ThaiCanonEvidenceRepository repo,
  ) {
    return repo.mapper.refsForUnits(
      repo.index.units.where(
        (u) =>
            u.subject.startsWith('periodStatus.') &&
            (u.relation == AtomicRelation.produces ||
                u.relation == AtomicRelation.opposes ||
                u.relation == AtomicRelation.relatesTo),
      ),
    );
  }

  static List<String> _sortedUnique(List<String> values) {
    return values.toSet().toList()..sort();
  }
}
