import 'package:flutter_test/flutter_test.dart';
import 'package:knowme/features/exploration_overview/application/discovery_grouping_builder.dart';
import 'package:knowme/features/exploration_overview/application/discovery_grouping_registry.dart';
import 'package:knowme/features/exploration_overview/domain/discovery_group.dart';
import 'package:knowme/features/exploration_overview/domain/discovery_grouping_model.dart';
import 'package:knowme/features/exploration_overview/domain/discovery_item.dart';
import 'package:knowme/features/exploration_overview/validation/discovery_golden_fixtures.dart';
import 'package:knowme/features/exploration_overview/validation/discovery_golden_scenario.dart';
import 'package:knowme/features/exploration_overview/validation/discovery_grouping_golden_fixtures.dart';
import 'package:knowme/features/exploration_overview/validation/discovery_grouping_golden_scenario.dart';
import 'package:knowme/features/exploration_overview/validation/discovery_grouping_validation_harness.dart';

void main() {
  group('DiscoveryGroup model', () {
    test('defines four group types', () {
      expect(DiscoveryGroupOrder.types.length, 4);
      expect(DiscoveryGroupOrder.types, contains(DiscoveryGroupType.personality));
      expect(DiscoveryGroupOrder.types, contains(DiscoveryGroupType.exploration));
    });

    test('registry defines titles for all group types', () {
      for (final type in DiscoveryGroupOrder.types) {
        expect(DiscoveryGroupingRegistry.groupTitle(type), isNotEmpty);
        expect(DiscoveryGroupingRegistry.groupDescription(type), isNotEmpty);
      }
    });
  });

  group('DiscoveryGroupingBuilder structure', () {
    test('groups all ten discovery items', () {
      final items = DiscoveryGoldenFixtures.build(
        DiscoveryGoldenScenario.everythingReady,
      );
      final model = DiscoveryGroupingBuilder.build(items);

      expect(model.totalItemCount, 10);
      expect(model.groupedItemCount, 10);
      expect(model.groups.length, 4);
    });

    test('preserves stable group order', () {
      final model = DiscoveryGroupingGoldenFixtures.build(
        DiscoveryGroupingGoldenScenario.empty,
      );

      expect(
        model.groups.map((group) => group.type).toList(),
        DiscoveryGroupOrder.types,
      );
    });

    test('personality group contains mbti eq and big five lenses', () {
      final model = DiscoveryGroupingGoldenFixtures.build(
        DiscoveryGroupingGoldenScenario.everything,
      );
      final group = model.group(DiscoveryGroupType.personality);
      final ids = group.items.map((item) => item.id).toSet();

      expect(ids, contains(DiscoveryCatalogIds.mbti));
      expect(ids, contains(DiscoveryCatalogIds.eq));
      expect(ids, contains(DiscoveryCatalogIds.bigFive));
      expect(ids, contains(DiscoveryCatalogIds.personalityMirror));
    });

    test('astrology group contains three lenses and mirror', () {
      final model = DiscoveryGroupingGoldenFixtures.build(
        DiscoveryGroupingGoldenScenario.everything,
      );
      final group = model.group(DiscoveryGroupType.astrology);
      final ids = group.items.map((item) => item.id).toSet();

      expect(ids, contains(DiscoveryCatalogIds.westernNatal));
      expect(ids, contains(DiscoveryCatalogIds.chineseBazi));
      expect(ids, contains(DiscoveryCatalogIds.thaiAstrology));
      expect(ids, contains(DiscoveryCatalogIds.astrologyMirror));
    });

    test('fusion group contains global fusion only', () {
      final model = DiscoveryGroupingGoldenFixtures.build(
        DiscoveryGroupingGoldenScenario.fusionOnly,
      );
      final group = model.group(DiscoveryGroupType.fusion);

      expect(group.itemCount, 1);
      expect(group.items.single.id, DiscoveryCatalogIds.globalFusion);
    });

    test('exploration group contains overview only', () {
      final model = DiscoveryGroupingGoldenFixtures.build(
        DiscoveryGroupingGoldenScenario.empty,
      );
      final group = model.group(DiscoveryGroupType.exploration);

      expect(group.itemCount, 1);
      expect(group.items.single.id, DiscoveryCatalogIds.explorationOverview);
    });
  });

  group('DiscoveryGroupingBuilder ordering', () {
    test('items within group follow catalog order', () {
      final model = DiscoveryGroupingGoldenFixtures.build(
        DiscoveryGroupingGoldenScenario.everything,
      );
      final personality = model.group(DiscoveryGroupType.personality);

      final indices = personality.items
          .map((item) => DiscoveryCatalogIds.catalogOrder.indexOf(item.id))
          .toList();
      expect(indices, orderedEquals(indices.toList()..sort()));
    });

    test('does not reorder input list', () {
      final items = DiscoveryGoldenFixtures.build(
        DiscoveryGoldenScenario.profileOnly,
      );
      final model = DiscoveryGroupingBuilder.build(items);

      expect(model.allItems.length, items.length);
      for (var i = 0; i < items.length; i++) {
        expect(model.allItems[i].id, items[i].id);
      }
    });
  });

  group('DiscoveryGroupingBuilder visibility', () {
    test('empty scenario exposes personality lenses', () {
      final model = DiscoveryGroupingGoldenFixtures.build(
        DiscoveryGroupingGoldenScenario.empty,
      );

      expect(
        model.group(DiscoveryGroupType.personality).visibleItemCount,
        greaterThan(0),
      );
      expect(
        model.group(DiscoveryGroupType.astrology).visibleItemCount,
        0,
      );
    });

    test('personality only marks mbti completed', () {
      final model = DiscoveryGroupingGoldenFixtures.build(
        DiscoveryGroupingGoldenScenario.personalityOnly,
      );
      final mbti = model.group(DiscoveryGroupType.personality).items.firstWhere(
            (item) => item.id == DiscoveryCatalogIds.mbti,
          );

      expect(mbti.availability, DiscoveryAvailability.completed);
    });

    test('astrology only exposes astrology group surfaces', () {
      final model = DiscoveryGroupingGoldenFixtures.build(
        DiscoveryGroupingGoldenScenario.astrologyOnly,
      );

      expect(
        model.group(DiscoveryGroupType.astrology).visibleItemCount,
        greaterThan(0),
      );
    });

    test('fusion only marks global fusion completed', () {
      final model = DiscoveryGroupingGoldenFixtures.build(
        DiscoveryGroupingGoldenScenario.fusionOnly,
      );
      final fusion = model.group(DiscoveryGroupType.fusion).items.single;

      expect(fusion.availability, DiscoveryAvailability.completed);
    });
  });

  group('DiscoveryGroupingModel', () {
    test('version id is discovery_grouping.v1', () {
      final model = DiscoveryGroupingGoldenFixtures.build(
        DiscoveryGroupingGoldenScenario.empty,
      );
      expect(model.version, DiscoveryGroupingModel.versionId);
    });

    test('group lookup returns correct cluster', () {
      final model = DiscoveryGroupingGoldenFixtures.build(
        DiscoveryGroupingGoldenScenario.everything,
      );

      expect(
        model.group(DiscoveryGroupType.fusion).type,
        DiscoveryGroupType.fusion,
      );
    });
  });

  group('DiscoveryGroupingValidationHarness', () {
    for (final scenario in DiscoveryGroupingGoldenScenario.values) {
      test('${scenario.name} passes golden expectations', () {
        final model = DiscoveryGroupingValidationHarness.run(scenario);
        final issues = DiscoveryGroupingGoldenExpectations.verify(
          scenario,
          model,
        );
        expect(issues, isEmpty, reason: issues.join('\n'));
      });
    }

    test('runAllPassing returns true', () {
      expect(DiscoveryGroupingValidationHarness.runAllPassing(), isTrue);
    });
  });
}
