import '../application/home_experience_builder.dart';
import '../application/home_presentation_builder.dart';
import '../application/home_surface_builder.dart';
import '../domain/home_experience_blueprint.dart';
import '../domain/home_screen_contract.dart';
import '../application/home_surface_registry.dart';
import 'home_cohesion_golden_fixtures.dart';
import 'home_cohesion_golden_scenario.dart';
import 'home_experience_golden_fixtures.dart';
import 'home_experience_golden_scenario.dart';
import 'home_surface_golden_scenario.dart';

/// Golden fixtures for Home MVP Surface (HX-F1).
abstract final class HomeSurfaceGoldenFixtures {
  static HomeScreenContract build(HomeSurfaceGoldenScenario scenario) {
    final blueprint = _blueprintFor(scenario);
    return HomeSurfaceBuilder.build(blueprint);
  }

  static HomeExperienceBlueprint _blueprintFor(
    HomeSurfaceGoldenScenario scenario,
  ) {
    return switch (scenario) {
      HomeSurfaceGoldenScenario.partialUser => _partialUserBlueprint(),
      _ => HomeExperienceGoldenFixtures.build(_experienceScenario(scenario)),
    };
  }

  static HomeExperienceBlueprint _partialUserBlueprint() {
    final snapshot = HomeCohesionGoldenFixtures.build(
      HomeCohesionGoldenScenario.mirrorReady,
    );
    final presentation = HomePresentationBuilder.build(snapshot);
    return HomeExperienceBuilder.build(presentation);
  }

  static HomeExperienceGoldenScenario _experienceScenario(
    HomeSurfaceGoldenScenario scenario,
  ) {
    return switch (scenario) {
      HomeSurfaceGoldenScenario.emptyUser =>
        HomeExperienceGoldenScenario.emptyUser,
      HomeSurfaceGoldenScenario.partialUser =>
        HomeExperienceGoldenScenario.journeyOnly,
      HomeSurfaceGoldenScenario.advancedUser =>
        HomeExperienceGoldenScenario.everythingReady,
      HomeSurfaceGoldenScenario.everythingReady =>
        HomeExperienceGoldenScenario.everythingReady,
    };
  }
}

/// Expected invariants per Home Surface golden scenario.
abstract final class HomeSurfaceGoldenExpectations {
  static List<String> verify(
    HomeSurfaceGoldenScenario scenario,
    HomeScreenContract contract,
  ) {
    final issues = <String>[];

    if (contract.version != HomeScreenContract.versionId) {
      issues.add('expected version ${HomeScreenContract.versionId}');
    }

    if (contract.sectionContracts.length !=
        HomeExperienceSectionOrder.types.length) {
      issues.add('expected 3 section contracts');
    }

    _assertRegionPlacement(contract, issues);
    _assertNoRecommendationCopy(contract, issues);

    switch (scenario) {
      case HomeSurfaceGoldenScenario.emptyUser:
        _expectStateMode(contract, HomeUserStateMode.emptyUser, issues);
        _expectHidden(contract, HomeExperienceSectionType.reflections, issues);
        _expectVisible(contract, HomeExperienceSectionType.journey, issues);
        _expectVisible(contract, HomeExperienceSectionType.explore, issues);
        _expectAboveFold(contract, HomeExperienceSectionType.journey, issues);
        _expectBelowFold(contract, HomeExperienceSectionType.explore, issues);
      case HomeSurfaceGoldenScenario.partialUser:
        _expectStateMode(contract, HomeUserStateMode.partialUser, issues);
        _expectVisible(contract, HomeExperienceSectionType.reflections, issues);
        _expectSurfaceState(
          contract,
          HomeExperienceSectionType.reflections,
          HomeSectionSurfaceState.partial,
          issues,
        );
        _expectVisible(contract, HomeExperienceSectionType.journey, issues);
      case HomeSurfaceGoldenScenario.advancedUser:
        _expectStateMode(contract, HomeUserStateMode.advancedUser, issues);
        _expectVisibleSectionCount(contract, 3, issues);
        _expectSurfaceState(
          contract,
          HomeExperienceSectionType.explore,
          HomeSectionSurfaceState.ready,
          issues,
        );
      case HomeSurfaceGoldenScenario.everythingReady:
        _expectStateMode(contract, HomeUserStateMode.advancedUser, issues);
        for (final type in HomeExperienceSectionOrder.types) {
          _expectVisible(contract, type, issues);
        }
        _expectAboveFoldCount(contract, 2, issues);
        _expectBelowFoldCount(contract, 1, issues);
    }

    return issues;
  }

  static void _assertRegionPlacement(
    HomeScreenContract contract,
    List<String> issues,
  ) {
    for (final section in contract.sectionContracts) {
      if (!section.visible) continue;

      final expected = HomeSurfaceRegistry.regionFor(section.type);
      if (section.region != expected) {
        issues.add('section ${section.type} expected region $expected');
      }

      if (expected == HomeScreenRegion.aboveFold &&
          !contract.aboveFoldSections.contains(section.type)) {
        issues.add('section ${section.type} missing from above fold list');
      }
      if (expected == HomeScreenRegion.belowFold &&
          !contract.belowFoldSections.contains(section.type)) {
        issues.add('section ${section.type} missing from below fold list');
      }
    }
  }

  static void _assertNoRecommendationCopy(
    HomeScreenContract contract,
    List<String> issues,
  ) {
    for (final section in contract.sectionContracts) {
      for (final phrase in const ['คุณควร', 'แนะนำให้', 'Next Best Action']) {
        if (section.purpose.contains(phrase)) {
          issues.add('forbidden recommendation copy in ${section.type}');
        }
      }
    }
  }

  static void _expectStateMode(
    HomeScreenContract contract,
    HomeUserStateMode expected,
    List<String> issues,
  ) {
    if (contract.stateMode != expected) {
      issues.add('stateMode expected $expected got ${contract.stateMode}');
    }
  }

  static void _expectVisible(
    HomeScreenContract contract,
    HomeExperienceSectionType type,
    List<String> issues,
  ) {
    if (!contract.visibleSectionTypes.contains(type)) {
      issues.add('expected visible section $type');
    }
    if (!contract.contract(type).visible) {
      issues.add('contract $type expected visible');
    }
  }

  static void _expectHidden(
    HomeScreenContract contract,
    HomeExperienceSectionType type,
    List<String> issues,
  ) {
    if (!contract.hiddenSectionTypes.contains(type)) {
      issues.add('expected hidden section $type');
    }
    if (contract.contract(type).surfaceState != HomeSectionSurfaceState.hidden) {
      issues.add('contract $type expected hidden surface state');
    }
  }

  static void _expectAboveFold(
    HomeScreenContract contract,
    HomeExperienceSectionType type,
    List<String> issues,
  ) {
    if (!contract.aboveFoldSections.contains(type)) {
      issues.add('expected $type above fold');
    }
  }

  static void _expectBelowFold(
    HomeScreenContract contract,
    HomeExperienceSectionType type,
    List<String> issues,
  ) {
    if (!contract.belowFoldSections.contains(type)) {
      issues.add('expected $type below fold');
    }
  }

  static void _expectSurfaceState(
    HomeScreenContract contract,
    HomeExperienceSectionType type,
    HomeSectionSurfaceState expected,
    List<String> issues,
  ) {
    if (contract.contract(type).surfaceState != expected) {
      issues.add(
        'section $type surfaceState expected $expected '
        'got ${contract.contract(type).surfaceState}',
      );
    }
  }

  static void _expectVisibleSectionCount(
    HomeScreenContract contract,
    int count,
    List<String> issues,
  ) {
    if (contract.visibleSectionTypes.length != count) {
      issues.add(
        'expected $count visible sections got ${contract.visibleSectionTypes.length}',
      );
    }
  }

  static void _expectAboveFoldCount(
    HomeScreenContract contract,
    int count,
    List<String> issues,
  ) {
    if (contract.aboveFoldSections.length != count) {
      issues.add(
        'expected $count above fold sections got ${contract.aboveFoldSections.length}',
      );
    }
  }

  static void _expectBelowFoldCount(
    HomeScreenContract contract,
    int count,
    List<String> issues,
  ) {
    if (contract.belowFoldSections.length != count) {
      issues.add(
        'expected $count below fold sections got ${contract.belowFoldSections.length}',
      );
    }
  }
}
