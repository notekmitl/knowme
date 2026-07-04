/// Internal life-period rise/fall metadata — evidence layer only.
///
/// [LifePeriodEngine] produces [LifeTimeline] / [PeriodState] with planet
/// sequence, ages, and progress. Per-period Mahabhut placement is not yet
/// computed — see [ThaiLifePeriodRiseFallFeasibility].
library;

import '../../foundation/models/thai_astrology_profile.dart';
import 'life_period_engine.dart';
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
    this.byPeriodIndex = const {},
  });

  const LifePeriodStatusMetadataAudit.blocked({
    required LifePeriodStatusMetadataAuditFinding finding,
    required String blocker,
    required ThaiLifePeriodRiseFallFeasibilityAudit feasibility,
    this.periodCount = 0,
  }) : byPeriodIndex = const {},
       finding = finding,
       blocker = blocker,
       feasibility = feasibility;

  final LifePeriodStatusMetadataAuditFinding finding;
  final String? blocker;
  final int periodCount;
  final ThaiLifePeriodRiseFallFeasibilityAudit feasibility;

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
      final feasibility = ThaiLifePeriodRiseFallFeasibility.audit(
        timeline: null,
        profile: profile,
      );
      return LifePeriodStatusMetadataAudit.blocked(
        finding: LifePeriodStatusMetadataAuditFinding.absentOnRuntime,
        blocker: LifePeriodStatusMetadataBlocker.noLifeTimeline,
        feasibility: feasibility,
      );
    }

    final feasibility = ThaiLifePeriodRiseFallFeasibility.audit(
      timeline: timeline,
      profile: profile,
    );

    if (feasibility.result !=
        LifePeriodRiseFallFeasibilityResult.readyToExposeMetadata) {
      return LifePeriodStatusMetadataAudit.blocked(
        finding: LifePeriodStatusMetadataAuditFinding.needsEnginePositionMetadata,
        blocker: feasibility.metadataBlocker ??
            LifePeriodStatusMetadataBlocker.needsEnginePositionMetadata,
        feasibility: feasibility,
        periodCount: timeline.periods.length,
      );
    }

    return LifePeriodStatusMetadataAudit(
      finding: LifePeriodStatusMetadataAuditFinding.alreadyComputedNotExposed,
      blocker: null,
      periodCount: timeline.periods.length,
      feasibility: feasibility,
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
