import 'package:knowme/features/exploration_overview/application/discovery_grouping_builder.dart';
import 'package:knowme/features/exploration_overview/domain/discovery_grouping_model.dart';
import 'package:knowme/features/exploration_overview/domain/discovery_item.dart';

import '../domain/home_experience_blueprint.dart';
import '../domain/home_presentation_model.dart';
import '../domain/home_screen_contract.dart';
import '../domain/home_section.dart';
import '../domain/home_snapshot.dart';
import '../validation/home_cohesion_golden_fixtures.dart';
import '../validation/home_cohesion_golden_scenario.dart';
import '../validation/home_surface_golden_scenario.dart';
import 'home_experience_builder.dart';
import 'home_presentation_builder.dart';
import 'home_surface_builder.dart';
import '../presentation/home_mvp_copy.dart';
import '../presentation/home_screen_v1_models.dart';

/// Builds [HomeScreenV1Data] from the locked Home cohesion pipeline.
abstract final class HomeMvpAssembler {
  static HomeScreenV1Data fromSnapshot(HomeSnapshot snapshot) {
    final presentation = HomePresentationBuilder.build(snapshot);
    final experience = HomeExperienceBuilder.build(presentation);
    final contract = HomeSurfaceBuilder.build(experience);
    final grouping = DiscoveryGroupingBuilder.build(snapshot.discoveryItems);

    return _assemble(
      contract: contract,
      presentation: presentation,
      grouping: grouping,
    );
  }

  static HomeScreenV1Data fromGolden(HomeSurfaceGoldenScenario scenario) {
    final cohesionScenario = switch (scenario) {
      HomeSurfaceGoldenScenario.emptyUser => HomeCohesionGoldenScenario.emptyUser,
      HomeSurfaceGoldenScenario.partialUser =>
        HomeCohesionGoldenScenario.mirrorReady,
      HomeSurfaceGoldenScenario.advancedUser =>
        HomeCohesionGoldenScenario.everythingReady,
      HomeSurfaceGoldenScenario.everythingReady =>
        HomeCohesionGoldenScenario.everythingReady,
    };

    return fromSnapshot(HomeCohesionGoldenFixtures.build(cohesionScenario));
  }

  static HomeScreenV1Data _assemble({
    required HomeScreenContract contract,
    required HomePresentationModel presentation,
    required DiscoveryGroupingModel grouping,
  }) {
    final journeyContract =
        contract.contract(HomeExperienceSectionType.journey);
    final reflectionsContract =
        contract.contract(HomeExperienceSectionType.reflections);
    final exploreContract = contract.contract(HomeExperienceSectionType.explore);

    final reflectionTiles = <HomeReflectionTileData>[];
    if (reflectionsContract.visible) {
      for (final sectionId in HomeSectionIds.reflectionSectionOrder) {
        final section = presentation.section(sectionId);
        if (!section.visible) continue;

        reflectionTiles.add(
          HomeReflectionTileData(
            title: section.title,
            description: section.description,
            surfaceState: reflectionsContract.surfaceState,
          ),
        );

        if (reflectionTiles.length >= reflectionsContract.visibleChildCount) {
          break;
        }
      }
    }

    final exploreGroups = <HomeExploreGroupData>[];
    if (exploreContract.visible) {
      for (final group in grouping.groups) {
        final visibleItems = group.items
            .where((item) => item.availability != DiscoveryAvailability.locked)
            .map(
              (item) => HomeExploreItemData(
                title: item.title,
                description: item.description,
                availability: item.availability,
              ),
            )
            .toList();
        if (visibleItems.isEmpty) continue;

        exploreGroups.add(
          HomeExploreGroupData(
            title: group.title,
            description: group.description,
            items: visibleItems,
          ),
        );
      }
    }

    return HomeScreenV1Data(
      contract: contract,
      journey: HomeJourneySectionData(
        section: journeyContract,
        headline: HomeMvpCopy.journeyHeadline(contract.stateMode),
        body: HomeMvpCopy.journeyBody(contract.stateMode),
        hint: HomeMvpCopy.journeyHint(contract.stateMode),
      ),
      reflections: HomeReflectionsSectionData(
        section: reflectionsContract,
        tiles: reflectionTiles,
      ),
      explore: HomeExploreSectionData(
        section: exploreContract,
        groups: exploreGroups,
      ),
    );
  }
}
