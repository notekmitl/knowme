/// What kind of exploration surface a discovery item represents (EO-F1).
enum DiscoverySourceType {
  lens,
  mirror,
  fusion,
  overview,
}

/// High-level grouping for Home / Discovery cohesion (EO-F1).
enum DiscoveryCategory {
  personality,
  astrology,
  fusion,
  exploration,
}

/// Derived availability — not a recommendation or rank (EO-F1).
enum DiscoveryAvailability {
  locked,
  available,
  completed,
}

/// Human-oriented discovery surface (EO-F1 — no UI, no ranking).
class DiscoveryItem {
  const DiscoveryItem({
    required this.id,
    required this.title,
    required this.description,
    required this.sourceType,
    required this.category,
    required this.availability,
  });

  final String id;
  final String title;
  final String description;
  final DiscoverySourceType sourceType;
  final DiscoveryCategory category;
  final DiscoveryAvailability availability;
}

/// Stable catalog identifiers for discovery surfaces.
abstract final class DiscoveryCatalogIds {
  static const westernNatal = 'lens_western_natal';
  static const chineseBazi = 'lens_chinese_bazi';
  static const thaiAstrology = 'lens_thai_astrology';
  static const mbti = 'lens_mbti';
  static const eq = 'lens_eq';
  static const bigFive = 'lens_big_five';
  static const astrologyMirror = 'mirror_astrology';
  static const personalityMirror = 'mirror_personality';
  static const globalFusion = 'fusion_global';
  static const explorationOverview = 'overview_exploration';

  static const catalogOrder = <String>[
    westernNatal,
    chineseBazi,
    thaiAstrology,
    mbti,
    eq,
    bigFive,
    astrologyMirror,
    personalityMirror,
    globalFusion,
    explorationOverview,
  ];
}
