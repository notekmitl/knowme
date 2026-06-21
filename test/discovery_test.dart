import 'package:flutter_test/flutter_test.dart';
import 'package:knowme/features/exploration_overview/application/discovery_builder.dart';
import 'package:knowme/features/exploration_overview/application/discovery_registry.dart';
import 'package:knowme/features/exploration_overview/application/exploration_overview_builder.dart';
import 'package:knowme/features/exploration_overview/domain/discovery_item.dart';
import 'package:knowme/features/exploration_overview/domain/exploration_lens_id.dart';
import 'package:knowme/features/exploration_overview/domain/exploration_overview.dart';
import 'package:knowme/features/exploration_overview/domain/exploration_profile_input.dart';
import 'package:knowme/features/exploration_overview/validation/discovery_golden_fixtures.dart';
import 'package:knowme/features/exploration_overview/validation/discovery_golden_scenario.dart';
import 'package:knowme/features/exploration_overview/validation/discovery_validation_harness.dart';
import 'package:knowme/features/exploration_overview/validation/exploration_overview_golden_fixtures.dart';
import 'package:knowme/features/exploration_overview/validation/exploration_overview_golden_scenario.dart';

void main() {
  group('DiscoveryItem model', () {
    test('catalog defines ten discovery surfaces', () {
      expect(DiscoveryCatalogIds.catalogOrder.length, 10);
    });

    test('registry defines copy for all six lenses', () {
      for (final lensId in ExplorationLensId.all) {
        expect(DiscoveryRegistry.lensTitle(lensId), isNotEmpty);
        expect(DiscoveryRegistry.lensDescription(lensId), isNotEmpty);
      }
    });

    test('registry copy avoids recommendation phrasing', () {
      for (final lensId in ExplorationLensId.all) {
        final description = DiscoveryRegistry.lensDescription(lensId);
        expect(description.contains('คุณควร'), isFalse);
        expect(description.contains('แนะนำให้'), isFalse);
      }
    });
  });

  group('DiscoveryBuilder availability', () {
    test('empty user locks astrology but opens personality lenses', () {
      final overview = ExplorationOverviewGoldenFixtures.build(
        ExplorationOverviewGoldenScenario.emptyUser,
      );
      final items = DiscoveryBuilder.build(overview: overview);

      expect(items.length, 10);

      final western = items.firstWhere(
        (item) => item.id == DiscoveryCatalogIds.westernNatal,
      );
      expect(western.availability, DiscoveryAvailability.locked);

      final mbti = items.firstWhere(
        (item) => item.id == DiscoveryCatalogIds.mbti,
      );
      expect(mbti.availability, DiscoveryAvailability.available);
    });

    test('profile only unlocks astrology lenses as available', () {
      final overview = ExplorationOverviewGoldenFixtures.build(
        ExplorationOverviewGoldenScenario.profileOnly,
      );
      final items = DiscoveryBuilder.build(overview: overview);

      final western = items.firstWhere(
        (item) => item.id == DiscoveryCatalogIds.westernNatal,
      );
      expect(western.availability, DiscoveryAvailability.available);
      expect(western.sourceType, DiscoverySourceType.lens);
      expect(western.category, DiscoveryCategory.astrology);
    });

    test('completed lens maps to completed availability', () {
      final pair = ExplorationOverviewGoldenFixtures.personalityOnly();
      final overview = ExplorationOverviewBuilder.build(
        profile: pair.profile,
        personalitySnapshot: pair.personalitySnapshot,
      );
      final items = DiscoveryBuilder.build(overview: overview);

      final mbti = items.firstWhere(
        (item) => item.id == DiscoveryCatalogIds.mbti,
      );
      expect(mbti.availability, DiscoveryAvailability.completed);
    });

    test('completed lens stays completed even when birth profile incomplete', () {
      final pair = ExplorationOverviewGoldenFixtures.mixedPartialState();
      final overview = ExplorationOverviewBuilder.build(
        profile: pair.profile,
        astrologySnapshot: pair.astrologySnapshot,
        personalitySnapshot: pair.personalitySnapshot,
      );
      final items = DiscoveryBuilder.build(overview: overview);

      final western = items.firstWhere(
        (item) => item.id == DiscoveryCatalogIds.westernNatal,
      );
      expect(western.availability, DiscoveryAvailability.completed);
    });

    test('partial mirror maps to available availability', () {
      final pair = ExplorationOverviewGoldenFixtures.astrologyOnly();
      final overview = ExplorationOverviewBuilder.build(
        profile: pair.profile,
        astrologySnapshot: pair.astrologySnapshot,
      );
      final items = DiscoveryBuilder.build(overview: overview);

      final mirror = items.firstWhere(
        (item) => item.id == DiscoveryCatalogIds.astrologyMirror,
      );
      expect(mirror.sourceType, DiscoverySourceType.mirror);
      expect(mirror.availability, DiscoveryAvailability.available);
    });

    test('ready mirror maps to completed availability', () {
      final pair = DiscoveryGoldenFixtures.everythingReady();
      final items = DiscoveryBuilder.build(
        overview: pair.overview,
        globalFusionSnapshot: pair.globalFusionSnapshot,
      );

      final mirror = items.firstWhere(
        (item) => item.id == DiscoveryCatalogIds.astrologyMirror,
      );
      expect(mirror.availability, DiscoveryAvailability.completed);
    });

    test('fusion limited maps to available', () {
      final pair = ExplorationOverviewGoldenFixtures.bothMirrors();
      final overview = ExplorationOverviewBuilder.build(
        profile: pair.profile,
        astrologySnapshot: pair.astrologySnapshot,
        personalitySnapshot: pair.personalitySnapshot,
      );
      final items = DiscoveryBuilder.build(overview: overview);

      final fusion = items.firstWhere(
        (item) => item.id == DiscoveryCatalogIds.globalFusion,
      );
      expect(fusion.sourceType, DiscoverySourceType.fusion);
      expect(fusion.category, DiscoveryCategory.fusion);
      expect(fusion.availability, DiscoveryAvailability.available);
    });

    test('fusion ready with snapshot maps to completed', () {
      final pair = DiscoveryGoldenFixtures.fusionReady();
      final items = DiscoveryBuilder.build(
        overview: pair.overview,
        globalFusionSnapshot: pair.globalFusionSnapshot,
      );

      final fusion = items.firstWhere(
        (item) => item.id == DiscoveryCatalogIds.globalFusion,
      );
      expect(fusion.availability, DiscoveryAvailability.completed);
    });

    test('overview item uses exploration category', () {
      final pair = DiscoveryGoldenFixtures.profileOnly();
      final items = DiscoveryBuilder.build(overview: pair.overview);

      final overviewItem = items.firstWhere(
        (item) => item.id == DiscoveryCatalogIds.explorationOverview,
      );
      expect(overviewItem.sourceType, DiscoverySourceType.overview);
      expect(overviewItem.category, DiscoveryCategory.exploration);
      expect(overviewItem.availability, DiscoveryAvailability.available);
    });
  });

  group('DiscoveryBuilder catalog order', () {
    test('returns stable catalog order without ranking metadata', () {
      final items = DiscoveryGoldenFixtures.build(
        DiscoveryGoldenScenario.fusionReady,
      );

      expect(
        items.map((item) => item.id).toList(),
        DiscoveryCatalogIds.catalogOrder,
      );

      for (final item in items) {
        expect(item.title, isNotEmpty);
        expect(item.description, isNotEmpty);
      }
    });

    test('includes all source types', () {
      final items = DiscoveryGoldenFixtures.build(
        DiscoveryGoldenScenario.everythingReady,
      );
      final sourceTypes = items.map((item) => item.sourceType).toSet();

      expect(sourceTypes, contains(DiscoverySourceType.lens));
      expect(sourceTypes, contains(DiscoverySourceType.mirror));
      expect(sourceTypes, contains(DiscoverySourceType.fusion));
      expect(sourceTypes, contains(DiscoverySourceType.overview));
    });

    test('includes all categories', () {
      final items = DiscoveryGoldenFixtures.build(
        DiscoveryGoldenScenario.everythingReady,
      );
      final categories = items.map((item) => item.category).toSet();

      expect(categories, contains(DiscoveryCategory.personality));
      expect(categories, contains(DiscoveryCategory.astrology));
      expect(categories, contains(DiscoveryCategory.fusion));
      expect(categories, contains(DiscoveryCategory.exploration));
    });
  });

  group('DiscoveryValidationHarness', () {
    for (final scenario in DiscoveryGoldenScenario.values) {
      test('${scenario.name} passes golden expectations', () {
        final items = DiscoveryValidationHarness.run(scenario);
        final issues = DiscoveryGoldenExpectations.verify(scenario, items);
        expect(issues, isEmpty, reason: issues.join('\n'));
      });
    }

    test('runAllPassing returns true', () {
      expect(DiscoveryValidationHarness.runAllPassing(), isTrue);
    });
  });
}
