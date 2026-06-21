import '../domain/home_experience_blueprint.dart';
import '../domain/home_presentation_model.dart';
import '../domain/home_section.dart';
import 'home_experience_registry.dart';

/// Builds [HomeExperienceBlueprint] from [HomePresentationModel] (HX-F0).
abstract final class HomeExperienceBuilder {
  static HomeExperienceBlueprint build(HomePresentationModel presentation) {
    final sections = <HomeExperienceSection>[];
    final rules = <HomeExperienceVisibilityRule>[];

    for (final type in HomeExperienceSectionOrder.types) {
      final groupId = HomeExperienceSectionOrder.toGroup(type);
      final group = presentation.group(groupId);
      final visibleChildCount =
          group.sections.where((section) => section.visible).length;
      final visible = _isSectionVisible(type, visibleChildCount);

      sections.add(
        HomeExperienceSection(
          type: type,
          id: HomeExperienceSectionOrder.sectionId(type),
          order: HomeExperienceSectionOrder.orderFor(type),
          priority: HomeExperienceSectionOrder.priorityFor(type),
          visible: visible,
          title: HomeExperienceRegistry.sectionTitle(type),
          description: HomeExperienceRegistry.sectionDescription(type),
          sourceGroupId: groupId,
          visibleChildCount: visibleChildCount,
        ),
      );

      rules.add(
        HomeExperienceVisibilityRule(
          type: type,
          ruleId: HomeExperienceRegistry.visibilityRuleId(type),
          description: HomeExperienceRegistry.visibilityRuleDescription(
            type,
            visible: visible,
          ),
          visible: visible,
        ),
      );
    }

    return HomeExperienceBlueprint(
      version: HomeExperienceBlueprint.versionId,
      sections: List.unmodifiable(sections),
      visibilityRules: List.unmodifiable(rules),
    );
  }

  static bool _isSectionVisible(
    HomeExperienceSectionType type,
    int visibleChildCount,
  ) {
    return switch (type) {
      HomeExperienceSectionType.journey => visibleChildCount > 0,
      HomeExperienceSectionType.reflections => visibleChildCount > 0,
      HomeExperienceSectionType.explore => visibleChildCount > 0,
    };
  }
}
