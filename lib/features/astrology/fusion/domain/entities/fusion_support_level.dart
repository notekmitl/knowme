/// Cross-lens support strength (tier only — no numeric precision).
enum FusionSupportLevel {
  low,
  medium,
  high,
}

extension FusionSupportLevelRank on FusionSupportLevel {
  int get rank {
    return switch (this) {
      FusionSupportLevel.low => 1,
      FusionSupportLevel.medium => 2,
      FusionSupportLevel.high => 3,
    };
  }
}

FusionSupportLevel maxFusionSupportLevel(
  FusionSupportLevel a,
  FusionSupportLevel b,
) {
  return a.rank >= b.rank ? a : b;
}

FusionSupportLevel fusionSupportLevelFromLensCount(int lensCount) {
  if (lensCount >= 3) return FusionSupportLevel.high;
  if (lensCount >= 2) return FusionSupportLevel.medium;
  return FusionSupportLevel.low;
}
