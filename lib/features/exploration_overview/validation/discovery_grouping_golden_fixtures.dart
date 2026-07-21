import '../application/discovery_grouping_builder.dart';
import '../domain/discovery_group.dart';
import '../domain/discovery_grouping_model.dart';
import '../domain/discovery_item.dart';
import 'discovery_golden_fixtures.dart';
import 'discovery_golden_scenario.dart';
import 'discovery_grouping_golden_scenario.dart';

/// Golden fixtures for Discovery Grouping (HC-F1.5).
abstract final class DiscoveryGroupingGoldenFixtures {
  static DiscoveryGroupingModel build(DiscoveryGroupingGoldenScenario scenario) {
    final items = _itemsFor(scenario);
    return DiscoveryGroupingBuilder.build(items);
  }

  static List<DiscoveryItem> _itemsFor(DiscoveryGroupingGoldenScenario scenario) {
    final discoveryScenario = switch (scenario) {
      DiscoveryGroupingGoldenScenario.empty => DiscoveryGoldenScenario.emptyUser,
      DiscoveryGroupingGoldenScenario.personalityOnly =>
        DiscoveryGoldenScenario.personalityReady,
      DiscoveryGroupingGoldenScenario.astrologyOnly =>
        DiscoveryGoldenScenario.astrologyReady,
      DiscoveryGroupingGoldenScenario.fusionOnly =>
        DiscoveryGoldenScenario.fusionReady,
      DiscoveryGroupingGoldenScenario.everything =>
        DiscoveryGoldenScenario.everythingReady,
    };

    return DiscoveryGoldenFixtures.build(discoveryScenario);
  }
}

/// Expected invariants per grouping golden scenario.
abstract final class DiscoveryGroupingGoldenExpectations {
  static List<String> verify(
    DiscoveryGroupingGoldenScenario scenario,
    DiscoveryGroupingModel model,
  ) {
    final issues = <String>[];

    if (model.version != DiscoveryGroupingModel.versionId) {
      issues.add('expected version ${DiscoveryGroupingModel.versionId}');
    }

    if (model.groups.length != DiscoveryGroupOrder.types.length) {
      issues.add('expected ${DiscoveryGroupOrder.types.length} groups');
    }

    for (var i = 0; i < DiscoveryGroupOrder.types.length; i++) {
      if (i >= model.groups.length) break;
      if (model.groups[i].type != DiscoveryGroupOrder.types[i]) {
        issues.add(
          'group order mismatch at $i: expected '
          '${DiscoveryGroupOrder.types[i]} got ${model.groups[i].type}',
        );
      }
    }

    if (model.groupedItemCount != model.totalItemCount) {
      issues.add(
        'grouped item count ${model.groupedItemCount} != '
        'total ${model.totalItemCount}',
      );
    }

    if (model.totalItemCount != 10) {
      issues.add('expected 10 discovery items got ${model.totalItemCount}');
    }

    _assertNoRecommendationCopy(model, issues);
    _assertGroupMembership(model, issues);

    switch (scenario) {
      case DiscoveryGroupingGoldenScenario.empty:
        _expectGroupItemCount(model, DiscoveryGroupType.personality, 4, issues);
        _expectGroupItemCount(model, DiscoveryGroupType.astrology, 4, issues);
        _expectGroupItemCount(model, DiscoveryGroupType.fusion, 1, issues);
        _expectGroupItemCount(model, DiscoveryGroupType.exploration, 1, issues);
        _expectVisibleInGroup(model, DiscoveryGroupType.personality, greaterThan: 0, issues: issues);
      case DiscoveryGroupingGoldenScenario.personalityOnly:
        _expectItemInGroup(
          model,
          DiscoveryGroupType.personality,
          DiscoveryCatalogIds.mbti,
          issues,
        );
        _expectItemAvailability(
          model,
          DiscoveryCatalogIds.mbti,
          DiscoveryAvailability.completed,
          issues,
        );
        _expectGroupVisibleCount(
          model,
          DiscoveryGroupType.personality,
          greaterThan: 0,
          issues: issues,
        );
      case DiscoveryGroupingGoldenScenario.astrologyOnly:
        _expectItemInGroup(
          model,
          DiscoveryGroupType.astrology,
          DiscoveryCatalogIds.westernNatal,
          issues,
        );
        _expectGroupVisibleCount(
          model,
          DiscoveryGroupType.astrology,
          greaterThan: 0,
          issues: issues,
        );
        _expectItemAvailability(
          model,
          DiscoveryCatalogIds.personalityMirror,
          DiscoveryAvailability.locked,
          issues,
        );
      case DiscoveryGroupingGoldenScenario.fusionOnly:
        _expectItemInGroup(
          model,
          DiscoveryGroupType.fusion,
          DiscoveryCatalogIds.globalFusion,
          issues,
        );
        _expectItemAvailability(
          model,
          DiscoveryCatalogIds.globalFusion,
          DiscoveryAvailability.completed,
          issues,
        );
        _expectGroupItemCount(model, DiscoveryGroupType.fusion, 1, issues);
      case DiscoveryGroupingGoldenScenario.everything:
        _expectGroupVisibleCount(
          model,
          DiscoveryGroupType.personality,
          greaterThan: 2,
          issues: issues,
        );
        _expectGroupVisibleCount(
          model,
          DiscoveryGroupType.astrology,
          greaterThan: 2,
          issues: issues,
        );
        _expectItemAvailability(
          model,
          DiscoveryCatalogIds.globalFusion,
          DiscoveryAvailability.completed,
          issues,
        );
    }

    return issues;
  }

  static void _assertNoRecommendationCopy(
    DiscoveryGroupingModel model,
    List<String> issues,
  ) {
    for (final group in model.groups) {
      for (final phrase in const ['คุณควร', 'แนะนำให้', 'Next Action']) {
        if (group.title.contains(phrase) ||
            group.description.contains(phrase)) {
          issues.add('forbidden recommendation copy in ${group.id}');
        }
      }
    }
  }

  static void _assertGroupMembership(
    DiscoveryGroupingModel model,
    List<String> issues,
  ) {
    const personalityIds = {
      DiscoveryCatalogIds.mbti,
      DiscoveryCatalogIds.eq,
      DiscoveryCatalogIds.bigFive,
      DiscoveryCatalogIds.personalityMirror,
    };
    const astrologyIds = {
      DiscoveryCatalogIds.westernNatal,
      DiscoveryCatalogIds.chineseBazi,
      DiscoveryCatalogIds.thaiAstrology,
      DiscoveryCatalogIds.astrologyMirror,
    };

    for (final id in personalityIds) {
      if (!_groupContains(model, DiscoveryGroupType.personality, id)) {
        issues.add('personality group missing $id');
      }
    }
    for (final id in astrologyIds) {
      if (!_groupContains(model, DiscoveryGroupType.astrology, id)) {
        issues.add('astrology group missing $id');
      }
    }
    if (!_groupContains(
      model,
      DiscoveryGroupType.fusion,
      DiscoveryCatalogIds.globalFusion,
    )) {
      issues.add('fusion group missing global fusion');
    }
    if (!_groupContains(
      model,
      DiscoveryGroupType.exploration,
      DiscoveryCatalogIds.explorationOverview,
    )) {
      issues.add('exploration group missing overview');
    }
  }

  static bool _groupContains(
    DiscoveryGroupingModel model,
    DiscoveryGroupType type,
    String itemId,
  ) {
    return model.group(type).items.any((item) => item.id == itemId);
  }

  static void _expectGroupItemCount(
    DiscoveryGroupingModel model,
    DiscoveryGroupType type,
    int count,
    List<String> issues,
  ) {
    if (model.group(type).itemCount != count) {
      issues.add('group $type expected $count items got ${model.group(type).itemCount}');
    }
  }

  static void _expectItemInGroup(
    DiscoveryGroupingModel model,
    DiscoveryGroupType type,
    String itemId,
    List<String> issues,
  ) {
    if (!_groupContains(model, type, itemId)) {
      issues.add('expected $itemId in group $type');
    }
  }

  static void _expectItemAvailability(
    DiscoveryGroupingModel model,
    String itemId,
    DiscoveryAvailability expected,
    List<String> issues,
  ) {
    DiscoveryItem? item;
    for (final entry in model.allItems) {
      if (entry.id == itemId) {
        item = entry;
        break;
      }
    }
    if (item == null) {
      issues.add('missing discovery item $itemId');
      return;
    }
    if (item.availability != expected) {
      issues.add('$itemId expected $expected got ${item.availability}');
    }
  }

  static void _expectVisibleInGroup(
    DiscoveryGroupingModel model,
    DiscoveryGroupType type, {
    required int greaterThan,
    required List<String> issues,
  }) {
    if (model.group(type).visibleItemCount <= greaterThan) {
      issues.add(
        'group $type visible count expected > $greaterThan '
        'got ${model.group(type).visibleItemCount}',
      );
    }
  }

  static void _expectGroupVisibleCount(
    DiscoveryGroupingModel model,
    DiscoveryGroupType type, {
    int? count,
    int? greaterThan,
    required List<String> issues,
  }) {
    final visible = model.group(type).visibleItemCount;
    if (count != null && visible != count) {
      issues.add('group $type visible count expected $count got $visible');
    }
    if (greaterThan != null && visible <= greaterThan) {
      issues.add(
        'group $type visible count expected > $greaterThan got $visible',
      );
    }
  }
}
