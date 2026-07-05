/// Internal life-period rise/fall metadata — evidence layer only.
///
/// [LifePeriodEngine] produces [LifeTimeline] / [PeriodState] with planet
/// sequence, ages, and progress. Per-period Mahabhut placement is not yet
/// computed — see [ThaiLifePeriodRiseFallFeasibility].
library;

import '../../foundation/models/thai_astrology_profile.dart';
import 'life_period_engine.dart';
import 'thai_life_period_position_metadata.dart';
export 'thai_archetype_context_metadata.dart'
    show
        ArchetypeChartContextMetadata,
        ArchetypeContextMetadataBlocker,
        ArchetypeContextMetadataFeasibilityResult,
        ArchetypeContextMetadataFeasibilityResultWire,
        ThaiArchetypeContextMetadataFeasibility,
        ThaiArchetypeContextMetadataFeasibilityAudit,
        ThaiArchetypeContextMetadataResolver,
        ThaiArchetypeContextP19Rules;
export 'thai_life_period_position_metadata.dart'
    show
        LifePeriodMahabhutPositionMetadata,
        LifePeriodPositionMetadataBlocker,
        LifePeriodPositionMetadataFeasibilityResult,
        LifePeriodPositionMetadataFeasibilityResultWire,
        ThaiLifePeriodPositionMetadataFeasibility,
        ThaiLifePeriodPositionMetadataFeasibilityAudit,
        ThaiLifePeriodPositionMetadataResolver;
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
        ThaiLifePeriodRiseFallResolver;
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
  }) {
    if (timeline == null) {
      final positionFeasibility =
          ThaiLifePeriodPositionMetadataFeasibility.audit(
        timeline: null,
        profile: profile,
      );
      final feasibility = ThaiLifePeriodRiseFallFeasibility.audit(
        timeline: null,
        profile: profile,
      );
      return LifePeriodStatusMetadataAudit.blocked(
        finding: LifePeriodStatusMetadataAuditFinding.absentOnRuntime,
        blocker: LifePeriodStatusMetadataBlocker.noLifeTimeline,
        feasibility: feasibility,
        positionFeasibility: positionFeasibility,
      );
    }

    final positionFeasibility = ThaiLifePeriodPositionMetadataFeasibility.audit(
      timeline: timeline,
      profile: profile,
    );

    final feasibility = ThaiLifePeriodRiseFallFeasibility.audit(
      timeline: timeline,
      profile: profile,
    );

    if (positionFeasibility.result !=
        LifePeriodPositionMetadataFeasibilityResult.readyToExposeMetadata) {
      return LifePeriodStatusMetadataAudit.blocked(
        finding: LifePeriodStatusMetadataAuditFinding.needsEnginePositionMetadata,
        blocker: positionFeasibility.metadataBlocker ??
            LifePeriodPositionMetadataBlocker.needsArchetypeContextMetadata,
        feasibility: feasibility,
        positionFeasibility: positionFeasibility,
        periodCount: timeline.periods.length,
      );
    }

    if (feasibility.result !=
        LifePeriodRiseFallFeasibilityResult.readyToExposeMetadata) {
      return LifePeriodStatusMetadataAudit.blocked(
        finding: LifePeriodStatusMetadataAuditFinding.needsEnginePositionMetadata,
        blocker: feasibility.metadataBlocker ??
            LifePeriodStatusMetadataBlocker.needsEnginePositionMetadata,
        feasibility: feasibility,
        positionFeasibility: positionFeasibility,
        periodCount: timeline.periods.length,
      );
    }

    return LifePeriodStatusMetadataAudit(
      finding: LifePeriodStatusMetadataAuditFinding.alreadyComputedNotExposed,
      blocker: null,
      periodCount: timeline.periods.length,
      feasibility: feasibility,
      positionFeasibility: positionFeasibility,
      byPeriodIndex: const {},
    );
  }

  static Map<int, String> canonIdsByPeriodIndex(
    LifeTimeline? timeline, {
    ThaiAstrologyProfile? profile,
  }) {
    final auditResult = audit(timeline, profile: profile);
    if (!auditResult.isAvailable) return const {};
    return Map<int, String>.unmodifiable(auditResult.byPeriodIndex);
  }
}
