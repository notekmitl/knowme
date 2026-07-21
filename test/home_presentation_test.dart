import 'package:flutter_test/flutter_test.dart';
import 'package:knowme/features/exploration_overview/domain/discovery_item.dart';
import 'package:knowme/features/home_cohesion/application/home_presentation_builder.dart';
import 'package:knowme/features/home_cohesion/application/home_presentation_registry.dart';
import 'package:knowme/features/home_cohesion/domain/home_presentation_model.dart';
import 'package:knowme/features/home_cohesion/domain/home_section.dart';
import 'package:knowme/features/home_cohesion/validation/home_cohesion_golden_fixtures.dart';
import 'package:knowme/features/home_cohesion/validation/home_cohesion_golden_scenario.dart';
import 'package:knowme/features/home_cohesion/validation/home_presentation_golden_fixtures.dart';
import 'package:knowme/features/home_cohesion/validation/home_presentation_golden_scenario.dart';
import 'package:knowme/features/home_cohesion/validation/home_presentation_validation_harness.dart';

void main() {
  group('HomeSection types', () {
    test('defines four section types', () {
      expect(HomeSectionType.values.length, 4);
      expect(HomeSectionType.values, contains(HomeSectionType.overview));
      expect(HomeSectionType.values, contains(HomeSectionType.discovery));
      expect(HomeSectionType.values, contains(HomeSectionType.mirror));
      expect(HomeSectionType.values, contains(HomeSectionType.fusion));
    });

    test('defines three section groups', () {
      expect(HomeSectionGroupOrder.ids.length, 3);
      expect(HomeSectionGroupOrder.ids.first, HomeSectionGroupId.yourJourney);
      expect(HomeSectionGroupOrder.ids.last, HomeSectionGroupId.exploreMore);
    });
  });

  group('HomePresentationRegistry', () {
    test('group titles match IA spec', () {
      expect(HomePresentationRegistry.yourJourneyTitle, 'Your Journey');
      expect(HomePresentationRegistry.yourReflectionsTitle, 'Your Reflections');
      expect(HomePresentationRegistry.exploreMoreTitle, 'Explore More');
    });

    test('copy avoids recommendation phrasing', () {
      expect(
        HomePresentationRegistry.exploreMoreDescription.contains('คุณควร'),
        isFalse,
      );
      expect(
        HomePresentationRegistry.yourReflectionsDescription.contains('แนะนำให้'),
        isFalse,
      );
    });
  });

  group('HomePresentationBuilder IA mapping', () {
    test('overview maps to Your Journey group', () {
      final model = HomePresentationGoldenFixtures.build(
        HomePresentationGoldenScenario.overviewOnly,
      );
      final group = model.group(HomeSectionGroupId.yourJourney);

      expect(group.sections.length, 1);
      expect(group.sections.single.type, HomeSectionType.overview);
      expect(group.sections.single.id, HomeSectionIds.overview);
    });

    test('mirrors and fusion map to Your Reflections group', () {
      final model = HomePresentationGoldenFixtures.build(
        HomePresentationGoldenScenario.fusionReady,
      );
      final group = model.group(HomeSectionGroupId.yourReflections);

      expect(group.sections.length, 3);
      expect(
        group.sections.where((s) => s.type == HomeSectionType.mirror).length,
        2,
      );
      expect(
        group.sections.where((s) => s.type == HomeSectionType.fusion).length,
        1,
      );
    });

    test('lens discovery maps to Explore More group', () {
      final model = HomePresentationGoldenFixtures.build(
        HomePresentationGoldenScenario.discoveryOnly,
      );
      final group = model.group(HomeSectionGroupId.exploreMore);

      expect(group.sections.length, 6);
      expect(
        group.sections.every((s) => s.type == HomeSectionType.discovery),
        isTrue,
      );
    });

    test('preserves stable discovery lens order', () {
      final model = HomePresentationGoldenFixtures.build(
        HomePresentationGoldenScenario.everythingReady,
      );
      final group = model.group(HomeSectionGroupId.exploreMore);

      expect(
        group.sections.map((s) => s.id).toList(),
        HomeSectionIds.discoveryLensSectionOrder,
      );
    });
  });

  group('HomePresentationBuilder visibility', () {
    test('empty home hides reflection sections', () {
      final model = HomePresentationGoldenFixtures.build(
        HomePresentationGoldenScenario.emptyHome,
      );

      expect(model.section(HomeSectionIds.astrologyMirror).visible, isFalse);
      expect(model.section(HomeSectionIds.globalFusion).visible, isFalse);
    });

    test('empty home exposes personality discovery lenses', () {
      final model = HomePresentationGoldenFixtures.build(
        HomePresentationGoldenScenario.emptyHome,
      );
      final group = model.group(HomeSectionGroupId.exploreMore);
      final visible = group.sections.where((s) => s.visible).length;

      expect(visible, greaterThan(0));
    });

    test('fusion ready shows fusion section', () {
      final model = HomePresentationGoldenFixtures.build(
        HomePresentationGoldenScenario.fusionReady,
      );

      expect(model.section(HomeSectionIds.globalFusion).visible, isTrue);
    });

    test('overview only keeps fusion section hidden', () {
      final model = HomePresentationGoldenFixtures.build(
        HomePresentationGoldenScenario.overviewOnly,
      );

      expect(model.section(HomeSectionIds.globalFusion).visible, isFalse);
    });
  });

  group('HomePresentationModel structure', () {
    test('version id is home_presentation.v1', () {
      final model = HomePresentationGoldenFixtures.build(
        HomePresentationGoldenScenario.emptyHome,
      );
      expect(model.version, HomePresentationModel.versionId);
    });

    test('flat sections match grouped sections', () {
      final snapshot = HomeCohesionGoldenFixtures.build(
        HomeCohesionGoldenScenario.fusionReady,
      );
      final model = HomePresentationBuilder.build(snapshot);

      final groupedCount = model.groups
          .map((group) => group.sections.length)
          .fold<int>(0, (sum, count) => sum + count);

      expect(model.sections.length, groupedCount);
      expect(model.sections.length, 10);
    });

    test('sections reference discovery catalog ids', () {
      final model = HomePresentationGoldenFixtures.build(
        HomePresentationGoldenScenario.everythingReady,
      );

      expect(
        model.section(HomeSectionIds.lensMbti).referenceId,
        DiscoveryCatalogIds.mbti,
      );
      expect(
        model.section(HomeSectionIds.globalFusion).referenceId,
        DiscoveryCatalogIds.globalFusion,
      );
    });
  });

  group('HomePresentationValidationHarness', () {
    for (final scenario in HomePresentationGoldenScenario.values) {
      test('${scenario.name} passes golden expectations', () {
        final model = HomePresentationValidationHarness.run(scenario);
        final issues = HomePresentationGoldenExpectations.verify(scenario, model);
        expect(issues, isEmpty, reason: issues.join('\n'));
      });
    }

    test('runAllPassing returns true', () {
      expect(HomePresentationValidationHarness.runAllPassing(), isTrue);
    });
  });
}
