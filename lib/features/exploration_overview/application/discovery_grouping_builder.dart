import '../domain/discovery_group.dart';
import '../domain/discovery_grouping_model.dart';
import '../domain/discovery_item.dart';
import 'discovery_grouping_registry.dart';

/// Groups [DiscoveryItem] list into semantic discovery clusters (HC-F1.5).
abstract final class DiscoveryGroupingBuilder {
  static DiscoveryGroupingModel build(List<DiscoveryItem> items) {
    final groupedItems = <DiscoveryGroupType, List<DiscoveryItem>>{
      for (final type in DiscoveryGroupOrder.types) type: [],
    };

    for (final item in items) {
      final type = DiscoveryGroupOrder.fromCategory(item.category);
      groupedItems[type]!.add(item);
    }

    for (final type in DiscoveryGroupOrder.types) {
      groupedItems[type]!.sort(_catalogOrder);
    }

    final groups = [
      for (final type in DiscoveryGroupOrder.types)
        DiscoveryGroup(
          type: type,
          id: DiscoveryGroupOrder.groupId(type),
          title: DiscoveryGroupingRegistry.groupTitle(type),
          description: DiscoveryGroupingRegistry.groupDescription(type),
          items: List.unmodifiable(groupedItems[type]!),
        ),
    ];

    return DiscoveryGroupingModel(
      version: DiscoveryGroupingModel.versionId,
      groups: List.unmodifiable(groups),
      allItems: List.unmodifiable(items),
    );
  }

  static int _catalogOrder(DiscoveryItem a, DiscoveryItem b) {
    final indexA = DiscoveryCatalogIds.catalogOrder.indexOf(a.id);
    final indexB = DiscoveryCatalogIds.catalogOrder.indexOf(b.id);
    final safeA = indexA < 0 ? DiscoveryCatalogIds.catalogOrder.length : indexA;
    final safeB = indexB < 0 ? DiscoveryCatalogIds.catalogOrder.length : indexB;
    return safeA.compareTo(safeB);
  }
}
