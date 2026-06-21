import 'package:flutter_test/flutter_test.dart';
import 'package:knowme/features/home_cohesion/application/home_experience_builder.dart';
import 'package:knowme/features/home_cohesion/application/home_presentation_builder.dart';
import 'package:knowme/features/home_cohesion/application/home_surface_builder.dart';
import 'package:knowme/features/home_cohesion/application/home_surface_registry.dart';
import 'package:knowme/features/home_cohesion/domain/home_experience_blueprint.dart';
import 'package:knowme/features/home_cohesion/domain/home_screen_contract.dart';
import 'package:knowme/features/home_cohesion/validation/home_cohesion_golden_fixtures.dart';
import 'package:knowme/features/home_cohesion/validation/home_cohesion_golden_scenario.dart';
import 'package:knowme/features/home_cohesion/validation/home_surface_golden_fixtures.dart';
import 'package:knowme/features/home_cohesion/validation/home_surface_golden_scenario.dart';
import 'package:knowme/features/home_cohesion/validation/home_surface_validation_harness.dart';

void main() {
  group('HomeScreenContract model', () {
    test('defines three user state modes', () {
      expect(HomeUserStateMode.values.length, 3);
    });

    test('defines two screen regions', () {
      expect(HomeScreenRegion.values.length, 2);
      expect(HomeScreenRegion.values, contains(HomeScreenRegion.aboveFold));
      expect(HomeScreenRegion.values, contains(HomeScreenRegion.belowFold));
    });

    test('defines four section surface states', () {
      expect(HomeSectionSurfaceState.values.length, 4);
    });

    test('version id is home_screen_contract.v1', () {
      final contract = HomeSurfaceGoldenFixtures.build(
        HomeSurfaceGoldenScenario.emptyUser,
      );
      expect(contract.version, HomeScreenContract.versionId);
    });
  });

  group('HomeSurfaceRegistry', () {
    test('journey and reflections are above fold', () {
      expect(
        HomeSurfaceRegistry.regionFor(HomeExperienceSectionType.journey),
        HomeScreenRegion.aboveFold,
      );
      expect(
        HomeSurfaceRegistry.regionFor(HomeExperienceSectionType.reflections),
        HomeScreenRegion.aboveFold,
      );
    });

    test('explore is below fold', () {
      expect(
        HomeSurfaceRegistry.regionFor(HomeExperienceSectionType.explore),
        HomeScreenRegion.belowFold,
      );
    });

    test('section contracts define purpose and required data', () {
      for (final type in HomeExperienceSectionOrder.types) {
        expect(HomeSurfaceRegistry.sectionPurpose(type), isNotEmpty);
        expect(HomeSurfaceRegistry.requiredData(type), isNotEmpty);
      }
    });
  });

  group('HomeSurfaceBuilder state modes', () {
    test('empty user mode hides reflections', () {
      final contract = HomeSurfaceGoldenFixtures.build(
        HomeSurfaceGoldenScenario.emptyUser,
      );

      expect(contract.stateMode, HomeUserStateMode.emptyUser);
      expect(
        contract.hiddenSectionTypes,
        contains(HomeExperienceSectionType.reflections),
      );
    });

    test('partial user mode keeps reflections partial', () {
      final contract = HomeSurfaceGoldenFixtures.build(
        HomeSurfaceGoldenScenario.partialUser,
      );

      expect(contract.stateMode, HomeUserStateMode.partialUser);
      expect(
        contract.contract(HomeExperienceSectionType.reflections).surfaceState,
        HomeSectionSurfaceState.partial,
      );
    });

    test('advanced user mode shows all sections', () {
      final contract = HomeSurfaceGoldenFixtures.build(
        HomeSurfaceGoldenScenario.advancedUser,
      );

      expect(contract.stateMode, HomeUserStateMode.advancedUser);
      expect(contract.visibleSectionTypes.length, 3);
    });

    test('everything ready matches advanced user mode', () {
      final contract = HomeSurfaceGoldenFixtures.build(
        HomeSurfaceGoldenScenario.everythingReady,
      );

      expect(contract.stateMode, HomeUserStateMode.advancedUser);
    });
  });

  group('HomeSurfaceBuilder regions', () {
    test('empty user places journey above fold and explore below fold', () {
      final contract = HomeSurfaceGoldenFixtures.build(
        HomeSurfaceGoldenScenario.emptyUser,
      );

      expect(
        contract.aboveFoldSections,
        contains(HomeExperienceSectionType.journey),
      );
      expect(
        contract.belowFoldSections,
        contains(HomeExperienceSectionType.explore),
      );
      expect(
        contract.aboveFoldSections,
        isNot(contains(HomeExperienceSectionType.explore)),
      );
    });

    test('everything ready has two above fold and one below fold', () {
      final contract = HomeSurfaceGoldenFixtures.build(
        HomeSurfaceGoldenScenario.everythingReady,
      );

      expect(contract.aboveFoldSections.length, 2);
      expect(contract.belowFoldSections.length, 1);
      expect(
        contract.belowFoldSections.single,
        HomeExperienceSectionType.explore,
      );
    });
  });

  group('HomeSurfaceBuilder section contracts', () {
    test('journey contract references experience section id', () {
      final snapshot = HomeCohesionGoldenFixtures.build(
        HomeCohesionGoldenScenario.overviewOnly,
      );
      final blueprint = HomeExperienceBuilder.build(
        HomePresentationBuilder.build(snapshot),
      );
      final contract = HomeSurfaceBuilder.build(blueprint);

      expect(
        contract.contract(HomeExperienceSectionType.journey).experienceSectionId,
        HomeExperienceSectionOrder.sectionId(HomeExperienceSectionType.journey),
      );
    });

    test('hidden section uses hidden surface state', () {
      final contract = HomeSurfaceGoldenFixtures.build(
        HomeSurfaceGoldenScenario.emptyUser,
      );

      expect(
        contract.contract(HomeExperienceSectionType.reflections).surfaceState,
        HomeSectionSurfaceState.hidden,
      );
    });

    test('ready explore section on everything ready', () {
      final contract = HomeSurfaceGoldenFixtures.build(
        HomeSurfaceGoldenScenario.everythingReady,
      );

      expect(
        contract.contract(HomeExperienceSectionType.explore).surfaceState,
        HomeSectionSurfaceState.ready,
      );
    });
  });

  group('HomeSurfaceValidationHarness', () {
    for (final scenario in HomeSurfaceGoldenScenario.values) {
      test('${scenario.name} passes golden expectations', () {
        final contract = HomeSurfaceValidationHarness.run(scenario);
        final issues = HomeSurfaceGoldenExpectations.verify(scenario, contract);
        expect(issues, isEmpty, reason: issues.join('\n'));
      });
    }

    test('runAllPassing returns true', () {
      expect(HomeSurfaceValidationHarness.runAllPassing(), isTrue);
    });
  });
}
