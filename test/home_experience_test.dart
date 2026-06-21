import 'package:flutter_test/flutter_test.dart';
import 'package:knowme/features/home_cohesion/application/home_experience_builder.dart';
import 'package:knowme/features/home_cohesion/application/home_experience_registry.dart';
import 'package:knowme/features/home_cohesion/application/home_presentation_builder.dart';
import 'package:knowme/features/home_cohesion/domain/home_experience_blueprint.dart';
import 'package:knowme/features/home_cohesion/domain/home_section.dart';
import 'package:knowme/features/home_cohesion/validation/home_cohesion_golden_fixtures.dart';
import 'package:knowme/features/home_cohesion/validation/home_cohesion_golden_scenario.dart';
import 'package:knowme/features/home_cohesion/validation/home_experience_golden_fixtures.dart';
import 'package:knowme/features/home_cohesion/validation/home_experience_golden_scenario.dart';
import 'package:knowme/features/home_cohesion/validation/home_experience_validation_harness.dart';

void main() {
  group('HomeExperienceBlueprint model', () {
    test('defines three experience section types', () {
      expect(HomeExperienceSectionOrder.types.length, 3);
      expect(
        HomeExperienceSectionOrder.types,
        contains(HomeExperienceSectionType.journey),
      );
      expect(
        HomeExperienceSectionOrder.types,
        contains(HomeExperienceSectionType.reflections),
      );
      expect(
        HomeExperienceSectionOrder.types,
        contains(HomeExperienceSectionType.explore),
      );
    });

    test('maps HC-F1 groups to experience types', () {
      expect(
        HomeExperienceSectionOrder.fromGroup(HomeSectionGroupId.yourJourney),
        HomeExperienceSectionType.journey,
      );
      expect(
        HomeExperienceSectionOrder.fromGroup(
          HomeSectionGroupId.yourReflections,
        ),
        HomeExperienceSectionType.reflections,
      );
      expect(
        HomeExperienceSectionOrder.fromGroup(HomeSectionGroupId.exploreMore),
        HomeExperienceSectionType.explore,
      );
    });

    test('version id is home_experience.v1', () {
      final blueprint = HomeExperienceGoldenFixtures.build(
        HomeExperienceGoldenScenario.emptyUser,
      );
      expect(blueprint.version, HomeExperienceBlueprint.versionId);
    });
  });

  group('HomeExperienceSectionPriority', () {
    test('journey is primary', () {
      expect(
        HomeExperienceSectionOrder.priorityFor(
          HomeExperienceSectionType.journey,
        ),
        HomeExperienceSectionPriority.primary,
      );
    });

    test('reflections is secondary', () {
      expect(
        HomeExperienceSectionOrder.priorityFor(
          HomeExperienceSectionType.reflections,
        ),
        HomeExperienceSectionPriority.secondary,
      );
    });

    test('explore is tertiary', () {
      expect(
        HomeExperienceSectionOrder.priorityFor(
          HomeExperienceSectionType.explore,
        ),
        HomeExperienceSectionPriority.tertiary,
      );
    });
  });

  group('HomeExperienceBuilder structure', () {
    test('builds three experience sections in order', () {
      final snapshot = HomeCohesionGoldenFixtures.build(
        HomeCohesionGoldenScenario.fusionReady,
      );
      final presentation = HomePresentationBuilder.build(snapshot);
      final blueprint = HomeExperienceBuilder.build(presentation);

      expect(blueprint.sections.length, 3);
      expect(blueprint.sections[0].type, HomeExperienceSectionType.journey);
      expect(blueprint.sections[1].type, HomeExperienceSectionType.reflections);
      expect(blueprint.sections[2].type, HomeExperienceSectionType.explore);
    });

    test('each section includes visibility rule', () {
      final blueprint = HomeExperienceGoldenFixtures.build(
        HomeExperienceGoldenScenario.everythingReady,
      );

      expect(blueprint.visibilityRules.length, 3);
      for (final type in HomeExperienceSectionOrder.types) {
        expect(blueprint.rule(type).type, type);
        expect(blueprint.rule(type).ruleId, isNotEmpty);
      }
    });

    test('registry titles align with experience sections', () {
      for (final type in HomeExperienceSectionOrder.types) {
        expect(HomeExperienceRegistry.sectionTitle(type), isNotEmpty);
        expect(HomeExperienceRegistry.sectionDescription(type), isNotEmpty);
      }
    });
  });

  group('HomeExperienceBuilder visibility rules', () {
    test('empty user hides reflections section', () {
      final blueprint = HomeExperienceGoldenFixtures.build(
        HomeExperienceGoldenScenario.emptyUser,
      );

      expect(
        blueprint.section(HomeExperienceSectionType.reflections).visible,
        isFalse,
      );
      expect(
        blueprint.rule(HomeExperienceSectionType.reflections).visible,
        isFalse,
      );
    });

    test('empty user shows journey and explore sections', () {
      final blueprint = HomeExperienceGoldenFixtures.build(
        HomeExperienceGoldenScenario.emptyUser,
      );

      expect(
        blueprint.section(HomeExperienceSectionType.journey).visible,
        isTrue,
      );
      expect(
        blueprint.section(HomeExperienceSectionType.explore).visible,
        isTrue,
      );
    });

    test('journey only hides reflections', () {
      final blueprint = HomeExperienceGoldenFixtures.build(
        HomeExperienceGoldenScenario.journeyOnly,
      );

      expect(
        blueprint.section(HomeExperienceSectionType.journey).visible,
        isTrue,
      );
      expect(
        blueprint.section(HomeExperienceSectionType.reflections).visible,
        isFalse,
      );
    });

    test('reflections ready shows reflections section', () {
      final blueprint = HomeExperienceGoldenFixtures.build(
        HomeExperienceGoldenScenario.reflectionsOnly,
      );

      expect(
        blueprint.section(HomeExperienceSectionType.reflections).visible,
        isTrue,
      );
      expect(
        blueprint.section(HomeExperienceSectionType.reflections).visibleChildCount,
        greaterThan(0),
      );
    });

    test('explore only hides reflections', () {
      final blueprint = HomeExperienceGoldenFixtures.build(
        HomeExperienceGoldenScenario.exploreOnly,
      );

      expect(
        blueprint.section(HomeExperienceSectionType.explore).visible,
        isTrue,
      );
      expect(
        blueprint.section(HomeExperienceSectionType.reflections).visible,
        isFalse,
      );
    });

    test('everything ready shows all experience sections', () {
      final blueprint = HomeExperienceGoldenFixtures.build(
        HomeExperienceGoldenScenario.everythingReady,
      );

      expect(blueprint.visibleSections.length, 3);
    });
  });

  group('HomeExperienceBlueprint helpers', () {
    test('visibleSections filters hidden sections', () {
      final blueprint = HomeExperienceGoldenFixtures.build(
        HomeExperienceGoldenScenario.journeyOnly,
      );

      expect(blueprint.visibleSections, isNotEmpty);
      expect(
        blueprint.visibleSections.every((section) => section.visible),
        isTrue,
      );
    });

    test('section lookup returns experience section', () {
      final blueprint = HomeExperienceGoldenFixtures.build(
        HomeExperienceGoldenScenario.everythingReady,
      );

      expect(
        blueprint.section(HomeExperienceSectionType.explore).id,
        HomeExperienceSectionOrder.sectionId(HomeExperienceSectionType.explore),
      );
    });
  });

  group('HomeExperienceValidationHarness', () {
    for (final scenario in HomeExperienceGoldenScenario.values) {
      test('${scenario.name} passes golden expectations', () {
        final blueprint = HomeExperienceValidationHarness.run(scenario);
        final issues = HomeExperienceGoldenExpectations.verify(
          scenario,
          blueprint,
        );
        expect(issues, isEmpty, reason: issues.join('\n'));
      });
    }

    test('runAllPassing returns true', () {
      expect(HomeExperienceValidationHarness.runAllPassing(), isTrue);
    });
  });
}
