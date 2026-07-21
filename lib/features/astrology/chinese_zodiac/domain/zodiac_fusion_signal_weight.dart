/// Tier-based signal weight for Fusion bridge (no numeric percentages).
enum ZodiacFusionSignalWeight {
  /// Primary calibration tier — dominant fusion contribution.
  full,

  /// Secondary calibration tier — supporting fusion contribution.
  reduced,

  /// Weak calibration tier — growth-area / growth-path signals only.
  growthOnly,
}

extension ZodiacFusionSignalWeightPriority on ZodiacFusionSignalWeight {
  int get priority => switch (this) {
        ZodiacFusionSignalWeight.full => 3,
        ZodiacFusionSignalWeight.reduced => 2,
        ZodiacFusionSignalWeight.growthOnly => 1,
      };
}

/// Whether [candidate] outranks [incumbent] for the same fusion theme id.
bool fusionWeightOutranks(
  ZodiacFusionSignalWeight candidate,
  ZodiacFusionSignalWeight incumbent,
) {
  return candidate.priority > incumbent.priority;
}
