/// Category of Canon evidence attached to a Thai report signal.
enum ThaiCanonEvidenceType {
  mahabhutPosition,
  planetSignification,
  lifePeriodStructural,
  periodStatusStructural,
  predictionRule,
  taksa,
  remedyInternal,
}

/// Deterministic quality of the Canon ↔ runtime signal match.
enum ThaiCanonEvidenceMatchQuality {
  exact,
  structural,
  unmappedCandidate,
}
