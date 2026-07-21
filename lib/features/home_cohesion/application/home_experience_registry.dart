import '../domain/home_experience_blueprint.dart';
import '../domain/home_section.dart';

/// Experience labels and visibility rule copy (HX-F0 — no UI).
abstract final class HomeExperienceRegistry {
  static const experienceVersion = 'home_experience.v1';

  static String sectionTitle(HomeExperienceSectionType type) {
    return switch (type) {
      HomeExperienceSectionType.journey => 'Your Journey',
      HomeExperienceSectionType.reflections => 'Your Reflections',
      HomeExperienceSectionType.explore => 'Explore More',
    };
  }

  static String sectionDescription(HomeExperienceSectionType type) {
    return switch (type) {
      HomeExperienceSectionType.journey =>
        'จุดเริ่มต้นที่ช่วยเห็นภาพรวมการสำรวจตัวเอง',
      HomeExperienceSectionType.reflections =>
        'มิเรอร์และมุมมองรวมที่สะท้อนสิ่งที่คุณมีอยู่แล้ว',
      HomeExperienceSectionType.explore =>
        'เส้นทางที่เปิดให้สำรวจต่อได้อย่างอิสระ',
    };
  }

  static String visibilityRuleId(HomeExperienceSectionType type) {
    return switch (type) {
      HomeExperienceSectionType.journey => 'journey_requires_overview_surface',
      HomeExperienceSectionType.reflections =>
        'reflections_require_visible_mirror_or_fusion',
      HomeExperienceSectionType.explore =>
        'explore_requires_visible_discovery_items',
    };
  }

  static String visibilityRuleDescription(
    HomeExperienceSectionType type, {
    required bool visible,
  }) {
    return switch (type) {
      HomeExperienceSectionType.journey => visible
          ? 'แสดง Journey เมื่อมี overview surface ที่เปิดอยู่'
          : 'ซ่อน Journey เมื่อไม่มี overview surface ที่เปิดอยู่',
      HomeExperienceSectionType.reflections => visible
          ? 'แสดง Reflections เมื่อมี mirror หรือ fusion ที่พร้อมสะท้อน'
          : 'ซ่อน Reflections เมื่อไม่มี mirror หรือ fusion ที่พร้อมสะท้อน',
      HomeExperienceSectionType.explore => visible
          ? 'แสดง Explore เมื่อมี discovery items ที่ไม่ถูกล็อก'
          : 'ซ่อน Explore เมื่อไม่มี discovery items ที่เปิดสำรวจได้',
    };
  }
}
