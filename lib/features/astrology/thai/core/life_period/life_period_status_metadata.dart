/// Internal life-period rise/fall metadata — evidence layer only.
///
/// [LifePeriodEngine] produces [LifeTimeline] / [PeriodState] with planet
/// sequence, ages, and progress. Per-period Mahabhut placement is not yet
/// computed — see [ThaiLifePeriodRiseFallFeasibility].
library;

import '../../foundation/models/thai_birth_data.dart';
import '../../foundation/models/thai_astrology_profile.dart';
import '../../knowledge/canon/integration/thai_canon_evidence_index.dart';
import 'life_period_engine.dart';
import 'thai_archetype_context_metadata.dart';
import 'thai_life_period_context_metadata.dart';
import 'thai_life_period_position_metadata.dart';
import 'thai_remainder_runtime_metadata.dart';
export 'thai_remainder_calculation_model.dart'
    show
        RemainderCalculationModelBlocker,
        RemainderCalculationModelFeasibilityResult,
        RemainderCalculationModelFeasibilityResultWire,
        ThaiMahabhutRemainderCalculationResult,
        ThaiMahabhutRemainderCalculator,
        ThaiRemainderCalculationModelFeasibility,
        ThaiRemainderCalculationModelFeasibilityAudit,
        ThaiRemainderCalculationModelSourceFacts;
export 'thai_remainder_runtime_metadata.dart'
    show
        RemainderRuntimeMetadataBlocker,
        RemainderRuntimeMetadataFeasibilityResult,
        RemainderRuntimeMetadataFeasibilityResultWire,
        ThaiRemainderMetadata,
        ThaiRemainderMetadataResolver,
        ThaiRemainderRuntimeMetadataFeasibility,
        ThaiRemainderRuntimeMetadataFeasibilityAudit;
export 'thai_archetype_context_metadata.dart'
    show
        ArchetypeChartContextMetadata,
        ArchetypeContextMappingFeasibilityResult,
        ArchetypeContextMappingFeasibilityResultWire,
        ArchetypeContextMetadataBlocker,
        ArchetypeContextMetadataFeasibilityResult,
        ArchetypeContextMetadataFeasibilityResultWire,
        ThaiArchetypeContextMappingAudit,
        ThaiArchetypeContextMappingRegistry,
        ThaiArchetypeContextMetadata,
        ThaiArchetypeContextMetadataFeasibility,
        ThaiArchetypeContextMetadataFeasibilityAudit,
        ThaiArchetypeContextMetadataResolver,
        ThaiArchetypeContextP19Rules,
        ThaiArchetypeContextPostFreezePatch001,
        ThaiArchetypeContextResolution,
        ThaiArchetypeContextResolver;
export 'thai_life_period_context_metadata.dart'
    show
        PeriodContextMappingFeasibilityResult,
        PeriodContextMappingFeasibilityResultWire,
        PeriodContextMatchMethod,
        PeriodContextMetadataBlocker,
        ThaiArchetypeChartCanonPageIndex,
        ThaiArchetypeChartLifePeriodPageRanges,
        ThaiCanonLifePeriodContextNormalizer,
        ThaiCanonLifePeriodLabelParse,
        ThaiLifePeriodContextFeasibility,
        ThaiLifePeriodContextFeasibilityAudit,
        ThaiLifePeriodContextMetadata,
        ThaiLifePeriodContextResolution,
        ThaiLifePeriodContextResolver;
export 'thai_life_period_position_metadata.dart'
    show
        LifePeriodMahabhutPositionMetadata,
        LifePeriodPositionMetadataBlocker,
        LifePeriodPositionMetadataFeasibilityResult,
        LifePeriodPositionMetadataFeasibilityResultWire,
        ThaiLifePeriodPositionMetadata,
        ThaiLifePeriodPositionMetadataFeasibility,
        ThaiLifePeriodPositionMetadataFeasibilityAudit,
        ThaiLifePeriodPositionMetadataResolver,
        ThaiLifePeriodPositionResolution;
export 'thai_life_period_rise_fall_metadata.dart'
    show
        LifePeriodRiseFallFeasibilityResult,
        LifePeriodRiseFallFeasibilityResultWire,
        LifePeriodRiseFallStatus,
        LifePeriodStatusMetadataBlocker,
        LifePeriodStatusMetadataValues,
        ThaiLifePeriodRiseFallFeasibility,
        ThaiLifePeriodRiseFallFeasibilityAudit,
        ThaiLifePeriodRiseFallP17Rules,
        ThaiLifePeriodRiseFallResolution,
        ThaiLifePeriodRiseFallResolver,
        ThaiLifePeriodRiseFallRuntimeMetadata;
import 'thai_life_period_rise_fall_metadata.dart';

/// Audit finding from the life-period status metadata layer.
enum LifePeriodStatusMetadataAuditFinding {
  alreadyComputedNotExposed,
  labelInCanonContextOnly,
  derivableOnlyByNewCalculation,
  absentOnRuntime,
  needsEnginePositionMetadata,
}

/// Result of auditing [LifeTimeline] for period-status metadata sources.
class LifePeriodStatusMetadataAudit {
  const LifePeriodStatusMetadataAudit({
    required this.finding,
    required this.blocker,
    required this.periodCount,
    required this.feasibility,
    required this.positionFeasibility,
    this.byPeriodIndex = const {},
  });

  const LifePeriodStatusMetadataAudit.blocked({
    required LifePeriodStatusMetadataAuditFinding finding,
    required String blocker,
    required ThaiLifePeriodRiseFallFeasibilityAudit feasibility,
    required ThaiLifePeriodPositionMetadataFeasibilityAudit positionFeasibility,
    this.periodCount = 0,
  }) : byPeriodIndex = const {},
       finding = finding,
       blocker = blocker,
       feasibility = feasibility,
       positionFeasibility = positionFeasibility;

  final LifePeriodStatusMetadataAuditFinding finding;
  final String? blocker;
  final int periodCount;
  final ThaiLifePeriodRiseFallFeasibilityAudit feasibility;
  final ThaiLifePeriodPositionMetadataFeasibilityAudit positionFeasibility;

  /// Period index → Canon id (`periodStatus.duengKhuen` / `.duengTok`).
  final Map<int, String> byPeriodIndex;

  bool get isAvailable => blocker == null && byPeriodIndex.isNotEmpty;
}

/// Resolves internal period-status metadata from existing engine output only.
abstract final class LifePeriodStatusMetadataResolver {
  static LifePeriodStatusMetadataAudit audit(
    LifeTimeline? timeline, {
    ThaiAstrologyProfile? profile,
    ThaiBirthData? birthData,
    ThaiCanonEvidenceIndex? canonIndex,
  }) {
    if (timeline == null) {
      final positionFeasibility =
          ThaiLifePeriodPositionMetadataFeasibility.audit(
        timeline: null,
        profile: profile,
        birthData: birthData,
        canonIndex: canonIndex,
      );
      final feasibility = ThaiLifePeriodRiseFallFeasibility.audit(
        timeline: null,
        profile: profile,
        birthData: birthData,
        canonIndex: canonIndex,
      );
      return LifePeriodStatusMetadataAudit.blocked(
        finding: LifePeriodStatusMetadataAuditFinding.absentOnRuntime,
        blocker: LifePeriodStatusMetadataBlocker.noLifeTimeline,
        feasibility: feasibility,
        positionFeasibility: positionFeasibility,
      );
    }

    final resolved = _resolveAll(
      timeline: timeline,
      profile: profile,
      birthData: birthData,
      canonIndex: canonIndex,
    );

    final positionFeasibility = ThaiLifePeriodPositionMetadataFeasibility.audit(
      timeline: timeline,
      profile: profile,
      birthData: birthData,
      canonIndex: canonIndex,
    );

    final feasibility = ThaiLifePeriodRiseFallFeasibility.audit(
      timeline: timeline,
      profile: profile,
      birthData: birthData,
      canonIndex: canonIndex,
      periodsWithRuntimeStatus: resolved.byPeriodIndex.length,
    );

    if (resolved.byPeriodIndex.isEmpty) {
      return LifePeriodStatusMetadataAudit.blocked(
        finding: LifePeriodStatusMetadataAuditFinding.needsEnginePositionMetadata,
        blocker: feasibility.metadataBlocker ??
            positionFeasibility.metadataBlocker ??
            LifePeriodStatusMetadataBlocker.needsEnginePositionMetadata,
        feasibility: feasibility,
        positionFeasibility: positionFeasibility,
        periodCount: timeline.periods.length,
      );
    }

    return LifePeriodStatusMetadataAudit(
      finding: LifePeriodStatusMetadataAuditFinding.alreadyComputedNotExposed,
      blocker: _statusMetadataBlocker(
        periodsWithRuntime: resolved.byPeriodIndex.length,
        periodCount: timeline.periods.length,
        feasibility: feasibility,
      ),
      periodCount: timeline.periods.length,
      feasibility: feasibility,
      positionFeasibility: positionFeasibility,
      byPeriodIndex: Map<int, String>.unmodifiable(resolved.byPeriodIndex),
    );
  }

  static Map<int, String> runtimeLabelsByPeriodIndex(
    LifeTimeline? timeline, {
    ThaiAstrologyProfile? profile,
    ThaiBirthData? birthData,
    ThaiCanonEvidenceIndex? canonIndex,
  }) {
    if (timeline == null) return const {};

    final labels = <int, String>{};
    for (final entry in _resolveAll(
      timeline: timeline,
      profile: profile,
      birthData: birthData,
      canonIndex: canonIndex,
    ).runtimeMetadataByPeriodIndex.entries) {
      labels[entry.key] = entry.value.periodStatusLabel;
    }
    return Map<int, String>.unmodifiable(labels);
  }

  static Map<int, String> canonIdsByPeriodIndex(
    LifeTimeline? timeline, {
    ThaiAstrologyProfile? profile,
    ThaiBirthData? birthData,
    ThaiCanonEvidenceIndex? canonIndex,
  }) {
    final auditResult = audit(
      timeline,
      profile: profile,
      birthData: birthData,
      canonIndex: canonIndex,
    );
    return Map<int, String>.unmodifiable(auditResult.byPeriodIndex);
  }

  static _LifePeriodStatusResolution _resolveAll({
    required LifeTimeline timeline,
    ThaiAstrologyProfile? profile,
    ThaiBirthData? birthData,
    ThaiCanonEvidenceIndex? canonIndex,
  }) {
    if (canonIndex == null) {
      return const _LifePeriodStatusResolution();
    }

    final archetypeMetadata = ThaiArchetypeContextResolver.resolve(
      remainderMetadata: ThaiRemainderMetadataResolver.resolve(
        profile: profile,
        birthData: birthData,
      ),
      canonIndex: canonIndex,
    ).metadata;

    final contextByPeriod = ThaiLifePeriodContextResolver.resolveAll(
      timeline: timeline,
      archetypeMetadata: archetypeMetadata,
      canonIndex: canonIndex,
    );
    final positionByPeriod = ThaiLifePeriodPositionMetadataResolver.resolveAll(
      timeline: timeline,
      archetypeMetadata: archetypeMetadata,
      contextByPeriod: contextByPeriod,
      canonIndex: canonIndex,
    );

    final byPeriodIndex = <int, String>{};
    final runtimeMetadataByPeriodIndex =
        <int, ThaiLifePeriodRiseFallRuntimeMetadata>{};

    for (final period in timeline.periods) {
      final positionMetadata = positionByPeriod[period.index];
      final resolution = ThaiLifePeriodRiseFallResolver.resolveDetailed(
        period: period,
        positionMetadata: positionMetadata,
        canonIndex: canonIndex,
      );
      final metadata = resolution.metadata;
      if (metadata == null) continue;
      byPeriodIndex[period.index] = metadata.periodStatusCanonId;
      runtimeMetadataByPeriodIndex[period.index] = metadata;
    }

    return _LifePeriodStatusResolution(
      byPeriodIndex: byPeriodIndex,
      runtimeMetadataByPeriodIndex: runtimeMetadataByPeriodIndex,
    );
  }

  static String? _statusMetadataBlocker({
    required int periodsWithRuntime,
    required int periodCount,
    required ThaiLifePeriodRiseFallFeasibilityAudit feasibility,
  }) {
    if (periodsWithRuntime == periodCount && periodCount > 0) {
      return null;
    }
    if (periodsWithRuntime > 0) {
      return LifePeriodStatusMetadataBlocker.partialRuntimeStatusMetadata;
    }
    return feasibility.metadataBlocker;
  }
}

class _LifePeriodStatusResolution {
  const _LifePeriodStatusResolution({
    this.byPeriodIndex = const {},
    this.runtimeMetadataByPeriodIndex = const {},
  });

  final Map<int, String> byPeriodIndex;
  final Map<int, ThaiLifePeriodRiseFallRuntimeMetadata>
      runtimeMetadataByPeriodIndex;
}
