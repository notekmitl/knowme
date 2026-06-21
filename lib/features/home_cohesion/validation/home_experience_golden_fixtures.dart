import '../application/home_experience_builder.dart';
import '../domain/home_experience_blueprint.dart';
import '../domain/home_presentation_model.dart';
import 'home_experience_golden_scenario.dart';
import 'home_presentation_golden_fixtures.dart';
import 'home_presentation_golden_scenario.dart';

/// Golden fixtures for Home Experience Blueprint (HX-F0).
abstract final class HomeExperienceGoldenFixtures {
  static HomeExperienceBlueprint build(HomeExperienceGoldenScenario scenario) {
    final presentation = HomePresentationGoldenFixtures.build(
      _presentationScenario(scenario),
    );
    return HomeExperienceBuilder.build(presentation);
  }

  static HomePresentationGoldenScenario _presentationScenario(
    HomeExperienceGoldenScenario scenario,
  ) {
    return switch (scenario) {
      HomeExperienceGoldenScenario.emptyUser =>
        HomePresentationGoldenScenario.emptyHome,
      HomeExperienceGoldenScenario.journeyOnly =>
        HomePresentationGoldenScenario.overviewOnly,
      HomeExperienceGoldenScenario.reflectionsOnly =>
        HomePresentationGoldenScenario.fusionReady,
      HomeExperienceGoldenScenario.exploreOnly =>
        HomePresentationGoldenScenario.discoveryOnly,
      HomeExperienceGoldenScenario.everythingReady =>
        HomePresentationGoldenScenario.everythingReady,
    };
  }
}

/// Expected invariants per Home Experience golden scenario.
abstract final class HomeExperienceGoldenExpectations {
  static List<String> verify(
    HomeExperienceGoldenScenario scenario,
    HomeExperienceBlueprint blueprint,
  ) {
    final issues = <String>[];

    if (blueprint.version != HomeExperienceBlueprint.versionId) {
      issues.add('expected version ${HomeExperienceBlueprint.versionId}');
    }

    if (blueprint.sections.length != HomeExperienceSectionOrder.types.length) {
      issues.add(
        'expected ${HomeExperienceSectionOrder.types.length} experience sections',
      );
    }

    if (blueprint.visibilityRules.length != blueprint.sections.length) {
      issues.add('visibility rules must match section count');
    }

    for (var i = 0; i < HomeExperienceSectionOrder.types.length; i++) {
      if (i >= blueprint.sections.length) break;
      final section = blueprint.sections[i];
      if (section.type != HomeExperienceSectionOrder.types[i]) {
        issues.add(
          'section order mismatch at $i: expected '
          '${HomeExperienceSectionOrder.types[i]} got ${section.type}',
        );
      }
      if (section.order != i + 1) {
        issues.add('section ${section.type} expected order ${i + 1}');
      }
    }

    _assertPriorityModel(blueprint, issues);
    _assertVisibilityRulesMatchSections(blueprint, issues);

    switch (scenario) {
      case HomeExperienceGoldenScenario.emptyUser:
        _expectSectionVisible(
          blueprint,
          HomeExperienceSectionType.journey,
          true,
          issues,
        );
        _expectSectionVisible(
          blueprint,
          HomeExperienceSectionType.reflections,
          false,
          issues,
        );
        _expectSectionVisible(
          blueprint,
          HomeExperienceSectionType.explore,
          true,
          issues,
        );
      case HomeExperienceGoldenScenario.journeyOnly:
        _expectSectionVisible(
          blueprint,
          HomeExperienceSectionType.journey,
          true,
          issues,
        );
        _expectSectionVisible(
          blueprint,
          HomeExperienceSectionType.reflections,
          false,
          issues,
        );
      case HomeExperienceGoldenScenario.reflectionsOnly:
        _expectSectionVisible(
          blueprint,
          HomeExperienceSectionType.reflections,
          true,
          issues,
        );
        _expectSectionVisible(
          blueprint,
          HomeExperienceSectionType.journey,
          true,
          issues,
        );
      case HomeExperienceGoldenScenario.exploreOnly:
        _expectSectionVisible(
          blueprint,
          HomeExperienceSectionType.explore,
          true,
          issues,
        );
        _expectSectionVisible(
          blueprint,
          HomeExperienceSectionType.reflections,
          false,
          issues,
        );
      case HomeExperienceGoldenScenario.everythingReady:
        for (final type in HomeExperienceSectionOrder.types) {
          _expectSectionVisible(blueprint, type, true, issues);
        }
        _expectVisibleSectionCount(blueprint, 3, issues);
    }

    return issues;
  }

  static void _assertPriorityModel(
    HomeExperienceBlueprint blueprint,
    List<String> issues,
  ) {
    final journey = blueprint.section(HomeExperienceSectionType.journey);
    final reflections = blueprint.section(HomeExperienceSectionType.reflections);
    final explore = blueprint.section(HomeExperienceSectionType.explore);

    if (journey.priority != HomeExperienceSectionPriority.primary) {
      issues.add('journey expected primary priority');
    }
    if (reflections.priority != HomeExperienceSectionPriority.secondary) {
      issues.add('reflections expected secondary priority');
    }
    if (explore.priority != HomeExperienceSectionPriority.tertiary) {
      issues.add('explore expected tertiary priority');
    }
  }

  static void _assertVisibilityRulesMatchSections(
    HomeExperienceBlueprint blueprint,
    List<String> issues,
  ) {
    for (final type in HomeExperienceSectionOrder.types) {
      final section = blueprint.section(type);
      final rule = blueprint.rule(type);
      if (section.visible != rule.visible) {
        issues.add('visibility rule mismatch for $type');
      }
    }
  }

  static void _expectSectionVisible(
    HomeExperienceBlueprint blueprint,
    HomeExperienceSectionType type,
    bool visible,
    List<String> issues,
  ) {
    final section = blueprint.section(type);
    if (section.visible != visible) {
      issues.add('section $type visible expected $visible got ${section.visible}');
    }
  }

  static void _expectVisibleSectionCount(
    HomeExperienceBlueprint blueprint,
    int count,
    List<String> issues,
  ) {
    if (blueprint.visibleSections.length != count) {
      issues.add(
        'expected $count visible sections got ${blueprint.visibleSections.length}',
      );
    }
  }
}
