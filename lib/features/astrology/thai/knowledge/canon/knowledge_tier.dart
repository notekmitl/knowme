/// Thai Astrology — **Canonical Knowledge** layer (Canon V1).
///
/// The Source Priority ladder. Every piece of Thai-astrology knowledge is
/// attributed to a tier; lower [priority] = higher authority. This encodes the
/// project rule:
///
/// - **Tier 0 — Calculation Engine / Swiss Ephemeris.** Computed astronomical
///   facts (day, lagna, bhava, planet positions). **Frozen.** The knowledge
///   layer never asserts or overrides these; they are ground truth.
/// - **Tier 1 — Canon (`หลักมหาภูต`, ส. หยกฟ้า).** The single canonical
///   interpretive source. When Canon speaks, Canon wins.
/// - **Tier 2 — Thai classical texts.** All other traditional Thai sources.
/// - **Tier 3 — Research.** Collected primary-source research (V3/V7).
/// - **Tier 4 — Internet.** Lowest-authority web material.
///
/// Boundary: pure knowledge layer — no dependency on the engine or the
/// `PlanetRelationshipMatrix`. The Tier-0 entry is a *label only*; this file
/// imports no engine code.
library;

/// The source-priority ladder (Tier 0 highest authority → Tier 4 lowest).
enum KnowledgeTier {
  /// Tier 0 — computed astronomical facts (Swiss Ephemeris). Frozen ground truth.
  calculationEngine,

  /// Tier 1 — the canonical interpretive source (`หลักมหาภูต`).
  canon,

  /// Tier 2 — traditional Thai texts (supporting).
  thaiClassical,

  /// Tier 3 — collected research (supporting).
  research,

  /// Tier 4 — internet / web material (supporting, lowest authority).
  internet,
}

extension KnowledgeTierAuthority on KnowledgeTier {
  /// 0 = highest authority, 4 = lowest. Used for ordering and conflict
  /// resolution.
  int get priority => switch (this) {
        KnowledgeTier.calculationEngine => 0,
        KnowledgeTier.canon => 1,
        KnowledgeTier.thaiClassical => 2,
        KnowledgeTier.research => 3,
        KnowledgeTier.internet => 4,
      };

  /// The canonical interpretive tier (Tier 1).
  bool get isCanon => this == KnowledgeTier.canon;

  /// Computed ground truth that knowledge must never assert or override.
  bool get isGroundTruth => this == KnowledgeTier.calculationEngine;

  /// Tiers 2–4 — used to add detail/examples/explanation, never to override Canon.
  bool get isSupporting =>
      this == KnowledgeTier.thaiClassical ||
      this == KnowledgeTier.research ||
      this == KnowledgeTier.internet;

  /// `true` if `this` outranks [other] (strictly more authoritative).
  bool outranks(KnowledgeTier other) => priority < other.priority;

  String get label => switch (this) {
        KnowledgeTier.calculationEngine =>
          'Tier 0 — Calculation Engine / Swiss Ephemeris (frozen)',
        KnowledgeTier.canon => 'Tier 1 — Canon (หลักมหาภูต, ส. หยกฟ้า)',
        KnowledgeTier.thaiClassical => 'Tier 2 — Thai classical texts',
        KnowledgeTier.research => 'Tier 3 — Research',
        KnowledgeTier.internet => 'Tier 4 — Internet',
      };

  /// Stable JSON key.
  String get key => switch (this) {
        KnowledgeTier.calculationEngine => 'tier0_calculation_engine',
        KnowledgeTier.canon => 'tier1_canon',
        KnowledgeTier.thaiClassical => 'tier2_thai_classical',
        KnowledgeTier.research => 'tier3_research',
        KnowledgeTier.internet => 'tier4_internet',
      };

  static KnowledgeTier? fromKey(String key) {
    for (final t in KnowledgeTier.values) {
      if (t.key == key) return t;
    }
    return null;
  }
}
