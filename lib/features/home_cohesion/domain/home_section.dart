/// Semantic Home section types (HC-F1 — meaning only, not UI widgets).
enum HomeSectionType {
  overview,
  discovery,
  mirror,
  fusion,
}

/// Semantic Home section groups (HC-F1 — meaning only, not UI layout).
enum HomeSectionGroupId {
  yourJourney,
  yourReflections,
  exploreMore,
}

/// Stable group ordering for Home IA.
abstract final class HomeSectionGroupOrder {
  static const ids = <HomeSectionGroupId>[
    HomeSectionGroupId.yourJourney,
    HomeSectionGroupId.yourReflections,
    HomeSectionGroupId.exploreMore,
  ];
}

/// Stable section identifiers within Home IA.
abstract final class HomeSectionIds {
  static const overview = 'section_overview';
  static const astrologyMirror = 'section_mirror_astrology';
  static const personalityMirror = 'section_mirror_personality';
  static const globalFusion = 'section_fusion_global';

  static const lensWesternNatal = 'section_discovery_western_natal';
  static const lensChineseBazi = 'section_discovery_chinese_bazi';
  static const lensThaiAstrology = 'section_discovery_thai_astrology';
  static const lensMbti = 'section_discovery_mbti';
  static const lensEq = 'section_discovery_eq';
  static const lensBigFive = 'section_discovery_big_five';

  static const reflectionSectionOrder = <String>[
    astrologyMirror,
    personalityMirror,
    globalFusion,
  ];

  static const discoveryLensSectionOrder = <String>[
    lensWesternNatal,
    lensChineseBazi,
    lensThaiAstrology,
    lensMbti,
    lensEq,
    lensBigFive,
  ];
}

/// One logical Home section slot (HC-F1).
class HomeSection {
  const HomeSection({
    required this.id,
    required this.type,
    required this.groupId,
    required this.title,
    required this.description,
    required this.referenceId,
    required this.visible,
  });

  final String id;
  final HomeSectionType type;
  final HomeSectionGroupId groupId;
  final String title;
  final String description;
  final String referenceId;
  final bool visible;
}
