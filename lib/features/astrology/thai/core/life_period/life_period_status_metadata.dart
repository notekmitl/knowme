/// Internal life-period rise/fall metadata — evidence layer only.
///
/// [LifePeriodEngine] today produces [LifeTimeline] / [PeriodState] with planet
/// sequence, ages, and progress only. It does **not** compute ดวงขึ้น / ดวงตก.
/// Frozen Canon stores rise/fall in `life_period` context tokens, but no runtime
/// engine resolves per-person mahabhut placement or period status yet.
library;

import 'life_period_engine.dart';

/// Blocker codes when period-status metadata cannot be exposed.
abstract final class LifePeriodStatusMetadataBlocker {
  static const blockedByRuntimeStatusAbsence =
      'BLOCKED_BY_RUNTIME_STATUS_ABSENCE';

  static const noLifeTimeline = 'NO_LIFE_TIMELINE';
}

/// Allowed Canon ids for internal period-status metadata (when available).
abstract final class LifePeriodStatusMetadataValues {
  static const duengKhuen = 'periodStatus.duengKhuen';
  static const duengTok = 'periodStatus.duengTok';

  static const allowedCanonIds = {duengKhuen, duengTok};
}

/// Audit finding from the life-period status metadata layer.
enum LifePeriodStatusMetadataAuditFinding {
  /// Status already computed on engine models (not present today).
  alreadyComputedNotExposed,

  /// Status appears only as narrative / Canon context text (not on runtime models).
  labelInCanonContextOnly,

  /// Would require new rise/fall calculation from placement (forbidden this phase).
  derivableOnlyByNewCalculation,

  /// No deterministic status source on runtime output (current production state).
  absentOnRuntime,
}

/// Result of auditing [LifeTimeline] for period-status metadata sources.
class LifePeriodStatusMetadataAudit {
  const LifePeriodStatusMetadataAudit({
    required this.finding,
    required this.blocker,
    required this.periodCount,
    this.byPeriodIndex = const {},
  });

  const LifePeriodStatusMetadataAudit.blocked({
    required LifePeriodStatusMetadataAuditFinding finding,
    required String blocker,
    this.periodCount = 0,
  }) : byPeriodIndex = const {},
       finding = finding,
       blocker = blocker;

  final LifePeriodStatusMetadataAuditFinding finding;
  final String? blocker;
  final int periodCount;

  /// Period index → Canon id (`periodStatus.duengKhuen` / `.duengTok`).
  final Map<int, String> byPeriodIndex;

  bool get isAvailable => blocker == null && byPeriodIndex.isNotEmpty;
}

/// Resolves internal period-status metadata from existing engine output only.
abstract final class LifePeriodStatusMetadataResolver {
  static LifePeriodStatusMetadataAudit audit(LifeTimeline? timeline) {
    if (timeline == null) {
      return const LifePeriodStatusMetadataAudit.blocked(
        finding: LifePeriodStatusMetadataAuditFinding.absentOnRuntime,
        blocker: LifePeriodStatusMetadataBlocker.noLifeTimeline,
      );
    }

    for (final period in timeline.periods) {
      // PeriodState exposes planet/age/progress only — no status field today.
      assert(period.index >= 0);
    }

    return LifePeriodStatusMetadataAudit.blocked(
      finding: LifePeriodStatusMetadataAuditFinding.absentOnRuntime,
      blocker: LifePeriodStatusMetadataBlocker.blockedByRuntimeStatusAbsence,
      periodCount: timeline.periods.length,
    );
  }

  static Map<int, String> canonIdsByPeriodIndex(LifeTimeline? timeline) {
    final auditResult = audit(timeline);
    if (!auditResult.isAvailable) return const {};
    return Map<int, String>.unmodifiable(auditResult.byPeriodIndex);
  }
}
