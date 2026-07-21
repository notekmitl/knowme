import 'discovery_item.dart';

/// Semantic discovery group types (HC-F1.5).
enum DiscoveryGroupType {
  personality,
  astrology,
  fusion,
  exploration,
}

/// Stable group ordering — deterministic, not ranked (HC-F1.5).
abstract final class DiscoveryGroupOrder {
  static const types = <DiscoveryGroupType>[
    DiscoveryGroupType.personality,
    DiscoveryGroupType.astrology,
    DiscoveryGroupType.fusion,
    DiscoveryGroupType.exploration,
  ];

  static DiscoveryGroupType fromCategory(DiscoveryCategory category) {
    return switch (category) {
      DiscoveryCategory.personality => DiscoveryGroupType.personality,
      DiscoveryCategory.astrology => DiscoveryGroupType.astrology,
      DiscoveryCategory.fusion => DiscoveryGroupType.fusion,
      DiscoveryCategory.exploration => DiscoveryGroupType.exploration,
    };
  }

  static String groupId(DiscoveryGroupType type) {
    return switch (type) {
      DiscoveryGroupType.personality => 'discovery_group_personality',
      DiscoveryGroupType.astrology => 'discovery_group_astrology',
      DiscoveryGroupType.fusion => 'discovery_group_fusion',
      DiscoveryGroupType.exploration => 'discovery_group_exploration',
    };
  }
}

/// A semantic cluster of related discovery surfaces (HC-F1.5).
class DiscoveryGroup {
  const DiscoveryGroup({
    required this.type,
    required this.id,
    required this.title,
    required this.description,
    required this.items,
  });

  final DiscoveryGroupType type;
  final String id;
  final String title;
  final String description;
  final List<DiscoveryItem> items;

  int get itemCount => items.length;

  int get visibleItemCount =>
      items.where((item) => item.availability != DiscoveryAvailability.locked).length;
}
