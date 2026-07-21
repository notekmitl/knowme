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
import 'thai_canon_khumsap_runtime_mapping.dart';
import 'thai_canon_taksa_role_runtime_mapping.dart';
import 'thai_khumsap_runtime_metadata.dart';
import 'thai_mirror_canon_evidence_bundle.dart';
import 'thai_mahabhut_khumsap_runtime_key.dart';
import 'thai_taksa_role_runtime_key.dart';
import 'thai_taksa_role_runtime_metadata.dart';
import 'thai_taksa_rotation_metadata.dart';
import 'thai_taksa_rotation_resolver.dart';

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
    final lifePeriodsEligibleForRuntimeStatus = <String>[];
    final lifePeriodsIneligibleForRuntimeStatus = <String>[];
    final runtimeStatusMissingReasons = <String>{};
    final runtimeStatusLabelsByIndex = <int, String>{};
    final runtimeStatusFromExactLifePeriodContext = <String>[];
    final runtimeStatusFromUniqueArchetypePlanetPosition = <String>[];
    final runtimeStatusBlockedByAmbiguousPosition = <String>[];
    final runtimeStatusBlockedBySourceConflict = <String>[];
    final runtimeStatusBlockedByMissingPosition = <String>[];
    final runtimeStatusBlockedByNoP17Rule = <String>[];
    final runtimeStatusWithoutPositionBreakdown = <String>[];

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
    final periodContextFeasibilityAudit = ThaiLifePeriodContextFeasibility.audit(
      timeline: pipelineResult.lifePeriods,
      canonIndex: repo.index,
    );
    final lifePeriodsWithPeriodContextMetadata = <String>[];
    final lifePeriodsWithoutPeriodContextMetadata = <String>[];
    final periodContextMatchMethods = <String>{};
    final periodContextMissingReasons = <String>{};
    final periodContextRawMatches = <String>[];
    final periodContextNormalizedMatches = <String>[];
    final periodContextAmbiguousMatches = <String>[];
    final periodContextMissingRuntimeAgeRange = <String>[];
    final periodContextMissingCanonAgeRange = <String>{};
    final timelineForContext = pipelineResult.lifePeriods;
    final canonLifePeriodLabels = repo.index.units
        .where(
          (u) =>
              u.context?.type == AtomicContextType.lifePeriod &&
              u.relation == AtomicRelation.locatedIn &&
              u.object.startsWith('mahabhutPosition.'),
        )
        .map((u) => u.context!.value)
        .toSet();
    for (final label in canonLifePeriodLabels) {
      final key = ThaiLifePeriodContextNormalizer.fromCanonLabel(label);
      if (key.isAmbiguous) {
        periodContextMissingCanonAgeRange.add(label);
      }
    }
    final periodContextNormalizationAudit =
        ThaiLifePeriodContextNormalizationFeasibility.audit(
      timeline: timelineForContext,
      canonLifePeriodLabels: canonLifePeriodLabels,
    );
    final placementIndex = ThaiArchetypePlanetPlacementIndex.build(repo.index);
    final placementIndexAudit = placementIndex.audit();
    final lifePeriodsWithPositionMetadata = <String>[];
    final lifePeriodsWithoutPositionMetadata = <String>[];
    final positionMetadataMissingReasons = <String>{};
    final positionMetadataEligiblePeriods = <String>[];
    final positionMetadataIneligiblePeriods = <String>[];
    final positionMatchMethods = <String>[];
    final ambiguousArchetypePlanetPairs = <String>{};
    final missingArchetypePlanetPairs = <String>{};
    final conflictedArchetypePlanetPairs = <String>{};
    if (timelineForContext != null && archetypeMetadata != null) {
      for (final period in timelineForContext.periods) {
        final contextAnchor = 'life_period:${period.index}:period_context';
        final positionAnchor = 'life_period:${period.index}:position';
        final runtimeAnchor = 'life_period:${period.index}:runtime_status';
        positionMetadataEligiblePeriods.add(positionAnchor);
        final resolution = ThaiLifePeriodContextResolver.resolveDetailed(
          period: period,
          archetypeMetadata: archetypeMetadata,
          canonIndex: repo.index,
        );
        if (resolution.metadata != null) {
          lifePeriodsWithPeriodContextMetadata.add(contextAnchor);
          periodContextMatchMethods.add(resolution.metadata!.matchMethod);
          if (resolution.isRawMatch) {
            periodContextRawMatches.add(contextAnchor);
          }
          if (resolution.isNormalizedMatch) {
            periodContextNormalizedMatches.add(contextAnchor);
          }
        } else {
          lifePeriodsWithoutPeriodContextMetadata.add(contextAnchor);
          if (resolution.missingReason == 'MISSING_RUNTIME_AGE_RANGE') {
            periodContextMissingRuntimeAgeRange.add(contextAnchor);
          }
          if (resolution.missingReason != null &&
              resolution.missingReason!.contains('AMBIGUOUS')) {
            periodContextAmbiguousMatches.add(contextAnchor);
          }
          if (resolution.missingReason != null) {
            periodContextMissingReasons.add(
              '${period.index}:${resolution.missingReason}',
            );
          }
        }

        final positionMetadata =
            ThaiLifePeriodPositionMetadataResolver.resolveCombined(
          period: period,
          archetypeMetadata: archetypeMetadata,
          periodContextMetadata: resolution.metadata,
          canonIndex: repo.index,
          placementIndex: placementIndex,
        );

        if (positionMetadata != null) {
          lifePeriodsWithPositionMetadata.add(positionAnchor);
          positionMatchMethods.add(positionMetadata.matchMethod);
          lifePeriodsEligibleForRuntimeStatus.add(runtimeAnchor);

          final riseFallResolution =
              ThaiLifePeriodRiseFallResolver.resolveDetailed(
            period: period,
            positionMetadata: positionMetadata,
            canonIndex: repo.index,
          );
          if (riseFallResolution.metadata != null) {
            runtimeStatusLabelsByIndex[period.index] =
                riseFallResolution.metadata!.periodStatusLabel;
            if (positionMetadata.matchMethod ==
                PositionMatchMethod.exactLifePeriodContext) {
              runtimeStatusFromExactLifePeriodContext.add(runtimeAnchor);
            } else if (positionMetadata.matchMethod ==
                PositionMatchMethod.archetypePlanetUniquePosition) {
              runtimeStatusFromUniqueArchetypePlanetPosition.add(runtimeAnchor);
            }
          } else if (riseFallResolution.missingReason != null) {
            runtimeStatusMissingReasons.add(
              '${period.index}:${riseFallResolution.missingReason}',
            );
            if (riseFallResolution.missingReason == 'NO_P17_RULE_FOR_POSITION') {
              runtimeStatusBlockedByNoP17Rule.add(runtimeAnchor);
              runtimeStatusWithoutPositionBreakdown.add(
                '${period.index}:${RuntimeStatusBlockerReason.noP17Rule}',
              );
            }
          }
        } else {
          lifePeriodsWithoutPositionMetadata.add(positionAnchor);
          lifePeriodsIneligibleForRuntimeStatus.add(runtimeAnchor);

          final pairKey =
              '${archetypeMetadata.archetypeChartCanonId}:planet.${period.planet.name}';
          final placementEntry = placementIndex.entryFor(
            archetypeChartCanonId: archetypeMetadata.archetypeChartCanonId,
            planetCanonId: 'planet.${period.planet.name}',
          );
          switch (placementEntry?.classification) {
            case ArchetypePlanetPlacementClassification.ambiguousPosition:
              ambiguousArchetypePlanetPairs.add(pairKey);
            case ArchetypePlanetPlacementClassification.sourceConflict:
              conflictedArchetypePlanetPairs.add(pairKey);
            case ArchetypePlanetPlacementClassification.missingPosition:
            case null:
              missingArchetypePlanetPairs.add(pairKey);
            case ArchetypePlanetPlacementClassification.uniquePosition:
            case ArchetypePlanetPlacementClassification.ocrBlocked:
              break;
          }

          String? missingReason;
          if (resolution.metadata != null) {
            missingReason = ThaiLifePeriodPositionMetadataResolver.resolveDetailed(
              period: period,
              archetypeMetadata: archetypeMetadata,
              periodContextMetadata: resolution.metadata,
              canonIndex: repo.index,
            ).missingReason;
          }
          missingReason ??=
              ThaiLifePeriodArchetypePlanetPositionResolver.resolveDetailed(
            period: period,
            archetypeMetadata: archetypeMetadata,
            placementIndex: placementIndex,
            canonIndex: repo.index,
          ).missingReason;
          if (missingReason != null) {
            positionMetadataMissingReasons.add(
              '${period.index}:$missingReason',
            );
          }

          final runtimeBlocker = _runtimeStatusBlockerForPositionReason(
            missingReason: missingReason,
            hasPeriodContext: resolution.metadata != null,
          );
          runtimeStatusWithoutPositionBreakdown.add(
            '${period.index}:$runtimeBlocker',
          );
          switch (runtimeBlocker) {
            case RuntimeStatusBlockerReason.ambiguousPosition:
              runtimeStatusBlockedByAmbiguousPosition.add(runtimeAnchor);
            case RuntimeStatusBlockerReason.sourceConflict:
              runtimeStatusBlockedBySourceConflict.add(runtimeAnchor);
            case RuntimeStatusBlockerReason.missingPosition:
              runtimeStatusBlockedByMissingPosition.add(runtimeAnchor);
            case RuntimeStatusBlockerReason.missingPeriodContext:
              runtimeStatusBlockedByMissingPosition.add(runtimeAnchor);
            default:
              runtimeStatusBlockedByMissingPosition.add(runtimeAnchor);
          }
        }
      }
    }
    ambiguousArchetypePlanetPairs.addAll(
      placementIndex.pairsWithClassification(
        ArchetypePlanetPlacementClassification.ambiguousPosition,
      ),
    );
    conflictedArchetypePlanetPairs.addAll(
      placementIndex.pairsWithClassification(
        ArchetypePlanetPlacementClassification.sourceConflict,
      ),
    );

    final periodStatusLabels = periodStatusLabelsByIndex ??
        runtimeStatusLabelsByIndex;
    final periodStatusAudit = periodStatusLabelsByIndex == null
        ? ThaiCanonPeriodStatusDiscovery.audit(
            pipelineResult,
            canonIndex: repo.index,
          )
        : null;
    final riseFallFeasibilityAudit = ThaiLifePeriodRiseFallFeasibility.audit(
      timeline: pipelineResult.lifePeriods,
      profile: pipelineResult.profile,
      birthData: pipelineResult.birthData,
      canonIndex: repo.index,
      periodsWithRuntimeStatus: runtimeStatusLabelsByIndex.length,
    );

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
    final taksaRotationAudit = ThaiTaksaRotationFeasibilityAudit.audit(
      repository: repo,
    );
    final taksaRotationResult = ThaiTaksaRotationResolver.resolve(
      birthData: pipelineResult.birthData,
      repository: repo,
    );
    final taksaRotationMetadata = taksaRotationResult.metadata;
    final taksaFeasibilityAudit =
        ThaiTaksaRoleRuntimeMetadataFeasibilityAudit.audit(
      pipeline: pipelineResult,
    );
    final taksaRolesMapped = ThaiCanonTaksaRoleRuntimeMapping.runtimeMappings()
        .where((m) => m.isMapped)
        .map((m) => m.canonEntityId)
        .toList(growable: false);
    final taksaCanonUnits = repo.index.units
        .where(
          (u) => ThaiCanonTaksaRoleRuntimeMapping.unitReferencesTaksaRole(
            subject: u.subject,
            object: u.object,
          ),
        )
        .toList(growable: false);
    var taksaEvidenceAttachedCount = 0;
    var taksaEvidenceTraceOnlyCount = taksaCanonUnits.length;
    String? taksaSkippedReason;
    if (taksaRotationMetadata.hasAssignments) {
      for (final assignment in taksaRotationMetadata.assignments) {
        final unit = repo.index.unitById(assignment.sourceUnitId);
        if (unit == null) continue;
        final refs = mapper.refsForUnits([unit]);
        if (refs.isEmpty) continue;
        taksaEvidenceAttachedCount += refs.length;
        attachments.add(
          ThaiCanonEvidenceAttachment(
            sectionId: 'taksaInternal',
            signalId:
                'taksaRotation:${assignment.planetCanonId}:'
                '${assignment.taksaRoleCanonId}',
            evidenceType: ThaiCanonEvidenceType.taksa,
            evidenceRefs: refs,
            matchQuality: ThaiCanonEvidenceMatchQuality.structural,
            userFacingAllowed: false,
          ),
        );
      }
      taksaEvidenceTraceOnlyCount =
          taksaCanonUnits.length - taksaEvidenceAttachedCount;
      if (taksaEvidenceTraceOnlyCount > 0) {
        traceOnlyCandidates.add(
          'taksa:trace_only ($taksaEvidenceTraceOnlyCount non-rotation Canon '
          'units; rotation metadata present)',
        );
      }
    } else {
      taksaSkippedReason = taksaRotationMetadata.blocker ??
          TaksaRuntimeSkippedReason.noRuntimeTaksaSignal;
      if (taksaCanonUnits.isNotEmpty) {
        traceOnlyCandidates.add(
          'taksa:trace_only (${taksaCanonUnits.length} Canon units; '
          '$taksaSkippedReason)',
        );
      }
    }
    if (ThaiCanonOntologyRuntimeMapping.runtimePlanetKey('planet.ketu') == null) {
      canonCandidates.add('planet.ketu');
    }
    final khumsapFeasibilityAudit =
        ThaiKhumsapRuntimeMetadataFeasibilityAudit.audit();
    final khumsapCanonUnits = repo.index.units
        .where(
          (u) =>
              u.subject == ThaiCanonKhumsapRuntimeMapping.canonEntityId ||
              u.object == ThaiCanonKhumsapRuntimeMapping.canonEntityId,
        )
        .toList(growable: false);
    final khumsapEvidenceAttachedCount = attachments
        .where(
          (a) => a.evidenceRefs.any(
            (r) =>
                r.subject == ThaiCanonKhumsapRuntimeMapping.canonEntityId ||
                r.object == ThaiCanonKhumsapRuntimeMapping.canonEntityId,
          ),
        )
        .length;
    if (khumsapCanonUnits.isNotEmpty && khumsapEvidenceAttachedCount == 0) {
      traceOnlyCandidates.add(
        'khumsap:mapped_internal (${khumsapCanonUnits.length} Canon units; '
        'no ${ThaiMahabhutKhumsapRuntimeKey.khumsap} report signal)',
      );
    }

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
      skippedTaksaEvidenceCount: taksaEvidenceTraceOnlyCount,
      taksaRolesMapped: _sortedUnique(taksaRolesMapped),
      taksaCanonUnitsAvailable: taksaCanonUnits.length,
      taksaEvidenceAttachedCount: taksaEvidenceAttachedCount,
      taksaEvidenceTraceOnlyCount: taksaEvidenceTraceOnlyCount,
      taksaSkippedReason: taksaSkippedReason,
      taksaFeasibilityResult: taksaFeasibilityAudit.result.wire,
      taksaRotationFeasibilityResult: taksaRotationAudit.result.wire,
      taksaSupportedWeekdays: _sortedUnique(
        taksaRotationAudit.supportedWeekdayNumbers
            .map((w) => w.toString())
            .toList(),
      ),
      taksaPartialSourceReviewWeekdays: _sortedUnique(
        taksaRotationAudit.partialSourceReviewWeekdayNumbers
            .map((w) => w.toString())
            .toList(),
      ),
      taksaNotInSourceWeekdays: _sortedUnique(
        taksaRotationAudit.notInSourceWeekdayNumbers
            .map((w) => w.toString())
            .toList(),
      ),
      taksaWednesdayDaytimeStatus: taksaRotationAudit.wednesdayDaytimeStatus,
      taksaWednesdayNightRahuStatus: taksaRotationAudit.wednesdayNightRahuStatus,
      taksaProfileWeekdayNumber: taksaRotationMetadata.birthWeekdayNumber,
      taksaRotationAssignmentCount: taksaRotationMetadata.assignments.length,
      taksaRotationBlocker: taksaRotationMetadata.blocker,
      khumsapMapped: true,
      khumsapFeasibilityResult: khumsapFeasibilityAudit.result.wire,
      khumsapCanonUnitsAvailable: khumsapCanonUnits.length,
      khumsapEvidenceAttachedCount: khumsapEvidenceAttachedCount,
      khumsapEvidenceCandidateCount: khumsapCanonUnits.length,
      mahabhutaThayaOutOfCanonScope:
          khumsapFeasibilityAudit.mahabhutaThayaRemainsOutOfCanonScope,
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
      lifePeriodRiseFallFeasibilityResult: riseFallFeasibilityAudit.result.wire,
      lifePeriodPositionFeasibilityResult:
          positionFeasibilityAudit.result.wire,
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
      lifePeriodsWithPeriodContextMetadata:
          _sortedUnique(lifePeriodsWithPeriodContextMetadata),
      lifePeriodsWithoutPeriodContextMetadata:
          _sortedUnique(lifePeriodsWithoutPeriodContextMetadata),
      periodContextMetadataBlocker:
          _periodContextMetadataBlocker(
        feasibility: periodContextFeasibilityAudit,
        withContext: lifePeriodsWithPeriodContextMetadata.length,
        withoutContext: lifePeriodsWithoutPeriodContextMetadata.length,
      ),
      periodContextMatchMethods:
          _sortedUnique(periodContextMatchMethods.toList()),
      periodContextMissingReasons:
          _sortedUnique(periodContextMissingReasons.toList()),
      periodContextRawMatches: _sortedUnique(periodContextRawMatches),
      periodContextNormalizedMatches:
          _sortedUnique(periodContextNormalizedMatches),
      periodContextAmbiguousMatches: _sortedUnique(periodContextAmbiguousMatches),
      periodContextMissingRuntimeAgeRange:
          _sortedUnique(periodContextMissingRuntimeAgeRange),
      periodContextMissingCanonAgeRange:
          _sortedUnique(periodContextMissingCanonAgeRange.toList()),
      periodContextNormalizationFeasibilityResult:
          periodContextNormalizationAudit.result.wire,
      periodContextNormalizationBlocker: _periodContextNormalizationBlocker(
        normalizationAudit: periodContextNormalizationAudit,
        withContext: lifePeriodsWithPeriodContextMetadata.length,
        withoutContext: lifePeriodsWithoutPeriodContextMetadata.length,
        normalizedMatches: periodContextNormalizedMatches.length,
      ),
      lifePeriodsWithPositionMetadata:
          _sortedUnique(lifePeriodsWithPositionMetadata),
      lifePeriodsWithoutPositionMetadata:
          _sortedUnique(lifePeriodsWithoutPositionMetadata),
      positionMetadataMissingReasons:
          _sortedUnique(positionMetadataMissingReasons.toList()),
      positionMetadataEligiblePeriods:
          _sortedUnique(positionMetadataEligiblePeriods),
      positionMetadataIneligiblePeriods:
          _sortedUnique(positionMetadataIneligiblePeriods),
      positionMatchMethods: _sortedUnique(positionMatchMethods),
      ambiguousArchetypePlanetPairs:
          _sortedUnique(ambiguousArchetypePlanetPairs.toList()),
      missingArchetypePlanetPairs:
          _sortedUnique(missingArchetypePlanetPairs.toList()),
      conflictedArchetypePlanetPairs:
          _sortedUnique(conflictedArchetypePlanetPairs.toList()),
      archetypePlanetPositionStrategyFeasibilityResult:
          placementIndexAudit.result.wire,
      lifePeriodsEligibleForRuntimeStatus:
          _sortedUnique(lifePeriodsEligibleForRuntimeStatus),
      lifePeriodsIneligibleForRuntimeStatus:
          _sortedUnique(lifePeriodsIneligibleForRuntimeStatus),
      runtimeStatusMissingReasons:
          _sortedUnique(runtimeStatusMissingReasons.toList()),
      runtimeStatusFromExactLifePeriodContext:
          _sortedUnique(runtimeStatusFromExactLifePeriodContext),
      runtimeStatusFromUniqueArchetypePlanetPosition:
          _sortedUnique(runtimeStatusFromUniqueArchetypePlanetPosition),
      runtimeStatusBlockedByAmbiguousPosition:
          _sortedUnique(runtimeStatusBlockedByAmbiguousPosition),
      runtimeStatusBlockedBySourceConflict:
          _sortedUnique(runtimeStatusBlockedBySourceConflict),
      runtimeStatusBlockedByMissingPosition:
          _sortedUnique(runtimeStatusBlockedByMissingPosition),
      runtimeStatusBlockedByNoP17Rule:
          _sortedUnique(runtimeStatusBlockedByNoP17Rule),
      runtimeStatusWithoutPositionBreakdown:
          _sortedUnique(runtimeStatusWithoutPositionBreakdown),
      lifePeriodPositionMetadataBlocker: _positionMetadataBlocker(
        withPosition: lifePeriodsWithPositionMetadata.length,
        withoutPosition: lifePeriodsWithoutPositionMetadata.length,
        withoutContext: lifePeriodsWithoutPeriodContextMetadata.length,
        totalPeriods: timelineForContext?.periods.length ?? 0,
        feasibility: positionFeasibilityAudit,
      ),
      lifePeriodStatusMetadataBlocker: _lifePeriodStatusMetadataBlocker(
        periodStatusAudit: periodStatusAudit,
        riseFallFeasibility: riseFallFeasibilityAudit,
        periodsWithRuntime: runtimeStatusLabelsByIndex.length,
        totalPeriods: timelineForContext?.periods.length ?? 0,
        labelsInjected: periodStatusLabelsByIndex != null,
      ),
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

  static String _runtimeStatusBlockerForPositionReason({
    required String? missingReason,
    required bool hasPeriodContext,
  }) {
    if (missingReason == null) {
      return hasPeriodContext
          ? RuntimeStatusBlockerReason.missingPosition
          : RuntimeStatusBlockerReason.missingPeriodContext;
    }
    if (missingReason.contains('SOURCE_CONFLICT')) {
      return RuntimeStatusBlockerReason.sourceConflict;
    }
    if (missingReason.contains('AMBIGUOUS')) {
      return RuntimeStatusBlockerReason.ambiguousPosition;
    }
    if (missingReason.contains('MISSING')) {
      return RuntimeStatusBlockerReason.missingPosition;
    }
    if (missingReason == 'NO_PERIOD_CONTEXT_METADATA') {
      return RuntimeStatusBlockerReason.missingPeriodContext;
    }
    return RuntimeStatusBlockerReason.missingPosition;
  }

  static List<String> _sortedUnique(List<String> values) {
    return values.toSet().toList()..sort();
  }

  static String? _periodContextNormalizationBlocker({
    required ThaiLifePeriodContextNormalizationAudit normalizationAudit,
    required int withContext,
    required int withoutContext,
    required int normalizedMatches,
  }) {
    if (normalizationAudit.result !=
        PeriodContextNormalizationFeasibilityResult
            .readyToNormalizePeriodContext) {
      return normalizationAudit.result.wire;
    }
    if (withContext > 0 && withoutContext > 0) {
      return normalizedMatches > 0
          ? PeriodContextNormalizationBlocker.partialNormalization
          : PeriodContextMetadataBlocker.needsPeriodContextMapping;
    }
    if (withContext == 0) {
      return PeriodContextMetadataBlocker.needsPeriodContextMapping;
    }
    return null;
  }

  static String? _periodContextMetadataBlocker({
    required ThaiLifePeriodContextFeasibilityAudit feasibility,
    required int withContext,
    required int withoutContext,
  }) {
    if (feasibility.result !=
        PeriodContextMappingFeasibilityResult.readyToMapPeriodContext) {
      return feasibility.result.wire;
    }
    if (withoutContext > 0) {
      return PeriodContextMetadataBlocker.needsPeriodContextMapping;
    }
    if (withContext == 0) {
      return PeriodContextMetadataBlocker.needsPeriodContextMapping;
    }
    return null;
  }

  static String? _positionMetadataBlocker({
    required int withPosition,
    required int withoutPosition,
    required int withoutContext,
    required int totalPeriods,
    required ThaiLifePeriodPositionMetadataFeasibilityAudit feasibility,
  }) {
    if (feasibility.result ==
            LifePeriodPositionMetadataFeasibilityResult
                .needsArchetypeContextMetadata ||
        feasibility.result ==
            LifePeriodPositionMetadataFeasibilityResult.blockedByModelingGap ||
        feasibility.result ==
            LifePeriodPositionMetadataFeasibilityResult.blockedBySourceGap) {
      return feasibility.metadataBlocker;
    }
    if (withPosition > 0 &&
        (withoutPosition > 0 || withoutContext > 0) &&
        totalPeriods > 0) {
      return LifePeriodPositionMetadataBlocker.partialPositionMetadata;
    }
    if (withPosition == 0 && withoutContext > 0) {
      return LifePeriodPositionMetadataBlocker.needsPeriodContextMapping;
    }
    if (withPosition == totalPeriods && totalPeriods > 0) {
      return null;
    }
    return feasibility.metadataBlocker;
  }

  static String? _lifePeriodStatusMetadataBlocker({
    required LifePeriodStatusMetadataAudit? periodStatusAudit,
    required ThaiLifePeriodRiseFallFeasibilityAudit riseFallFeasibility,
    required int periodsWithRuntime,
    required int totalPeriods,
    required bool labelsInjected,
  }) {
    if (labelsInjected) {
      return null;
    }
    if (periodStatusAudit != null && periodStatusAudit.blocker != null) {
      return periodStatusAudit.blocker;
    }
    if (periodsWithRuntime == totalPeriods && totalPeriods > 0) {
      return null;
    }
    if (periodsWithRuntime > 0) {
      return LifePeriodStatusMetadataBlocker.partialRuntimeStatusMetadata;
    }
    return riseFallFeasibility.metadataBlocker;
  }
}
