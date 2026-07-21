import '../domain/discovery_group.dart';
import '../domain/discovery_item.dart';

/// Deterministic group labels — meaning only (HC-F1.5).
abstract final class DiscoveryGroupingRegistry {
  static const groupingVersion = 'discovery_grouping.v1';

  static String groupTitle(DiscoveryGroupType type) {
    return switch (type) {
      DiscoveryGroupType.personality => 'Personality',
      DiscoveryGroupType.astrology => 'Astrology',
      DiscoveryGroupType.fusion => 'Fusion',
      DiscoveryGroupType.exploration => 'Exploration',
    };
  }

  static String groupDescription(DiscoveryGroupType type) {
    return switch (type) {
      DiscoveryGroupType.personality =>
        'มุมมองจากแบบทดสอบและมิเรอร์บุคลิกภาพ',
      DiscoveryGroupType.astrology =>
        'มุมมองจากเลนส์ดวงดาวและมิเรอร์ดวงดาว',
      DiscoveryGroupType.fusion =>
        'มุมมองรวมข้ามมิเรอร์',
      DiscoveryGroupType.exploration =>
        'ภาพรวมการสำรวจตัวเอง',
    };
  }
}
