import '../domain/home_experience_blueprint.dart';
import '../domain/home_screen_contract.dart';
import 'home_surface_registry.dart';

/// Builds [HomeScreenContract] from [HomeExperienceBlueprint] (HX-F1).
abstract final class HomeSurfaceBuilder {
  static HomeScreenContract build(HomeExperienceBlueprint blueprint) {
    final contracts = [
      for (final type in HomeExperienceSectionOrder.types)
        _sectionContract(blueprint, type),
    ];

    final visible = <HomeExperienceSectionType>[];
    final hidden = <HomeExperienceSectionType>[];
    final aboveFold = <HomeExperienceSectionType>[];
    final belowFold = <HomeExperienceSectionType>[];

    for (final contract in contracts) {
      if (contract.visible) {
        visible.add(contract.type);
        if (contract.region == HomeScreenRegion.aboveFold) {
          aboveFold.add(contract.type);
        } else {
          belowFold.add(contract.type);
        }
      } else {
        hidden.add(contract.type);
      }
    }

    return HomeScreenContract(
      version: HomeScreenContract.versionId,
      stateMode: _deriveStateMode(blueprint),
      sectionContracts: List.unmodifiable(contracts),
      aboveFoldSections: List.unmodifiable(aboveFold),
      belowFoldSections: List.unmodifiable(belowFold),
      visibleSectionTypes: List.unmodifiable(visible),
      hiddenSectionTypes: List.unmodifiable(hidden),
    );
  }

  static HomeSectionSurfaceContract _sectionContract(
    HomeExperienceBlueprint blueprint,
    HomeExperienceSectionType type,
  ) {
    final experience = blueprint.section(type);

    return HomeSectionSurfaceContract(
      type: type,
      purpose: HomeSurfaceRegistry.sectionPurpose(type),
      requiredData: HomeSurfaceRegistry.requiredData(type),
      visible: experience.visible,
      surfaceState: _surfaceState(experience),
      region: HomeSurfaceRegistry.regionFor(type),
      priority: experience.priority,
      experienceSectionId: experience.id,
      visibleChildCount: experience.visibleChildCount,
    );
  }

  static HomeSectionSurfaceState _surfaceState(HomeExperienceSection section) {
    if (!section.visible) return HomeSectionSurfaceState.hidden;

    final expected = HomeSurfaceRegistry.expectedChildCount(section.type);
    if (section.visibleChildCount <= 0) {
      return HomeSectionSurfaceState.empty;
    }
    if (section.visibleChildCount >= expected) {
      return HomeSectionSurfaceState.ready;
    }
    return HomeSectionSurfaceState.partial;
  }

  static HomeUserStateMode _deriveStateMode(HomeExperienceBlueprint blueprint) {
    final journey = blueprint.section(HomeExperienceSectionType.journey);
    final reflections =
        blueprint.section(HomeExperienceSectionType.reflections);
    final explore = blueprint.section(HomeExperienceSectionType.explore);

    if (!reflections.visible && journey.visible && explore.visible) {
      return HomeUserStateMode.emptyUser;
    }

    final reflectionsReady =
        reflections.visible &&
            reflections.visibleChildCount >=
                HomeSurfaceRegistry.expectedChildCount(
                  HomeExperienceSectionType.reflections,
                );
    final exploreReady =
        explore.visible &&
            explore.visibleChildCount >=
                HomeSurfaceRegistry.expectedChildCount(
                  HomeExperienceSectionType.explore,
                );

    if (journey.visible && reflectionsReady && exploreReady) {
      return HomeUserStateMode.advancedUser;
    }

    return HomeUserStateMode.partialUser;
  }
}
