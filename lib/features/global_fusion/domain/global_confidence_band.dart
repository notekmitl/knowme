/// Confidence band for Global Fusion v1 (GF-F2).
enum GlobalConfidenceBand {
  low,
  medium,
  high,
}

extension GlobalConfidenceBandIds on GlobalConfidenceBand {
  String get id {
    return switch (this) {
      GlobalConfidenceBand.low => 'low',
      GlobalConfidenceBand.medium => 'medium',
      GlobalConfidenceBand.high => 'high',
    };
  }
}
