import 'home_section.dart';

/// Top-level Home experience section types (HX-F0).
enum HomeExperienceSectionType {
  journey,
  reflections,
  explore,
}

/// Experience importance — meaning only, not UI weight (HX-F0).
enum HomeExperienceSectionPriority {
  primary,
  secondary,
  tertiary,
}

/// Stable experience section ordering (HX-F0).
abstract final class HomeExperienceSectionOrder {
  static const types = <HomeExperienceSectionType>[
    HomeExperienceSectionType.journey,
    HomeExperienceSectionType.reflections,
    HomeExperienceSectionType.explore,
  ];

  static HomeExperienceSectionType fromGroup(HomeSectionGroupId groupId) {
    return switch (groupId) {
      HomeSectionGroupId.yourJourney => HomeExperienceSectionType.journey,
      HomeSectionGroupId.yourReflections =>
        HomeExperienceSectionType.reflections,
      HomeSectionGroupId.exploreMore => HomeExperienceSectionType.explore,
    };
  }

  static HomeSectionGroupId toGroup(HomeExperienceSectionType type) {
    return switch (type) {
      HomeExperienceSectionType.journey => HomeSectionGroupId.yourJourney,
      HomeExperienceSectionType.reflections =>
        HomeSectionGroupId.yourReflections,
      HomeExperienceSectionType.explore => HomeSectionGroupId.exploreMore,
    };
  }

  static String sectionId(HomeExperienceSectionType type) {
    return switch (type) {
      HomeExperienceSectionType.journey => 'experience_journey',
      HomeExperienceSectionType.reflections => 'experience_reflections',
      HomeExperienceSectionType.explore => 'experience_explore',
    };
  }

  static HomeExperienceSectionPriority priorityFor(
    HomeExperienceSectionType type,
  ) {
    return switch (type) {
      HomeExperienceSectionType.journey =>
        HomeExperienceSectionPriority.primary,
      HomeExperienceSectionType.reflections =>
        HomeExperienceSectionPriority.secondary,
      HomeExperienceSectionType.explore =>
        HomeExperienceSectionPriority.tertiary,
    };
  }

  static int orderFor(HomeExperienceSectionType type) {
    return types.indexOf(type) + 1;
  }
}

/// Deterministic visibility rule applied to an experience section (HX-F0).
class HomeExperienceVisibilityRule {
  const HomeExperienceVisibilityRule({
    required this.type,
    required this.ruleId,
    required this.description,
    required this.visible,
  });

  final HomeExperienceSectionType type;
  final String ruleId;
  final String description;
  final bool visible;
}

/// One Home experience section in encounter order (HX-F0 — not UI).
class HomeExperienceSection {
  const HomeExperienceSection({
    required this.type,
    required this.id,
    required this.order,
    required this.priority,
    required this.visible,
    required this.title,
    required this.description,
    required this.sourceGroupId,
    required this.visibleChildCount,
  });

  final HomeExperienceSectionType type;
  final String id;
  final int order;
  final HomeExperienceSectionPriority priority;
  final bool visible;
  final String title;
  final String description;
  final HomeSectionGroupId sourceGroupId;
  final int visibleChildCount;
}

/// Home experience contract — structure before UI (HX-F0).
class HomeExperienceBlueprint {
  const HomeExperienceBlueprint({
    required this.version,
    required this.sections,
    required this.visibilityRules,
  });

  static const String versionId = 'home_experience.v1';

  final String version;
  final List<HomeExperienceSection> sections;
  final List<HomeExperienceVisibilityRule> visibilityRules;

  List<HomeExperienceSection> get visibleSections =>
      sections.where((section) => section.visible).toList();

  HomeExperienceSection section(HomeExperienceSectionType type) {
    return sections.firstWhere((entry) => entry.type == type);
  }

  HomeExperienceVisibilityRule rule(HomeExperienceSectionType type) {
    return visibilityRules.firstWhere((entry) => entry.type == type);
  }
}
