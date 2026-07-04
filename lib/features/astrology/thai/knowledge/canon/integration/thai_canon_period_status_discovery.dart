import 'package:knowme/features/astrology/thai/mirror/runtime/thai_mirror_pipeline_result.dart';

import 'thai_canon_period_status_runtime_mapping.dart';

/// Discovers exact period-status labels already present on runtime/report output.
///
/// Does not infer rise/fall from planet, position, or prediction copy.
abstract final class ThaiCanonPeriodStatusDiscovery {
  /// Period index → exact Thai label (`ดวงขึ้น` or `ดวงตก`).
  static Map<int, String> discover(
    ThaiMirrorPipelineResult pipelineResult, {
    Map<int, String>? labelsByPeriodIndex,
  }) {
    if (labelsByPeriodIndex != null) {
      return _validated(labelsByPeriodIndex);
    }
    return _discoverFromPipeline(pipelineResult);
  }

  /// Production discovery path.
  ///
  /// **Current state (blocked):** [LifeTimeline] / [PeriodState] and
  /// [ThaiMirrorPipelineResult] do not yet expose deterministic rise/fall
  /// metadata. Returns empty until report/timeline surfaces exact labels.
  static Map<int, String> _discoverFromPipeline(
    ThaiMirrorPipelineResult pipelineResult,
  ) {
    if (!pipelineResult.isSuccess || pipelineResult.lifePeriods == null) {
      return const {};
    }
    return const {};
  }

  static Map<int, String> _validated(Map<int, String> labels) {
    final out = <int, String>{};
    for (final entry in labels.entries) {
      if (ThaiCanonPeriodStatusRuntimeMapping.isAllowedRuntimeLabel(entry.value)) {
        out[entry.key] = entry.value;
      }
    }
    return out;
  }
}
