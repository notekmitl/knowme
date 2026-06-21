import 'discovery_group.dart';
import 'discovery_item.dart';

/// Grouped discovery catalog — semantic structure without UI (HC-F1.5).
class DiscoveryGroupingModel {
  const DiscoveryGroupingModel({
    required this.version,
    required this.groups,
    required this.allItems,
  });

  static const String versionId = 'discovery_grouping.v1';

  final String version;
  final List<DiscoveryGroup> groups;
  final List<DiscoveryItem> allItems;

  DiscoveryGroup group(DiscoveryGroupType type) {
    return groups.firstWhere((entry) => entry.type == type);
  }

  int get totalItemCount => allItems.length;

  int get groupedItemCount =>
      groups.fold<int>(0, (sum, group) => sum + group.itemCount);
}
