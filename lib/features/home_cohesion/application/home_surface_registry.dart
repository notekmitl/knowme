import '../domain/home_experience_blueprint.dart';
import '../domain/home_screen_contract.dart';

/// Section purpose and data requirements for Home MVP (HX-F1).
abstract final class HomeSurfaceRegistry {
  static const surfaceVersion = 'home_surface.v1';

  static String sectionPurpose(HomeExperienceSectionType type) {
    return switch (type) {
      HomeExperienceSectionType.journey =>
        'ช่วยผู้ใช้เห็นภาพรวมว่าสำรวจตัวเองไปถึงไหนแล้ว',
      HomeExperienceSectionType.reflections =>
        'แสดงมิเรอร์และมุมมองรวมที่สะท้อนสิ่งที่มีอยู่แล้ว',
      HomeExperienceSectionType.explore =>
        'เปิดเส้นทางสำรวจที่ยังทำต่อได้อย่างอิสระ',
    };
  }

  static String requiredData(HomeExperienceSectionType type) {
    return switch (type) {
      HomeExperienceSectionType.journey =>
        'ExplorationOverview และ profile readiness',
      HomeExperienceSectionType.reflections =>
        'Astrology Mirror, Personality Mirror, Global Fusion summaries',
      HomeExperienceSectionType.explore =>
        'Discovery items ที่ไม่ถูกล็อก',
    };
  }

  static HomeScreenRegion regionFor(HomeExperienceSectionType type) {
    return switch (type) {
      HomeExperienceSectionType.journey => HomeScreenRegion.aboveFold,
      HomeExperienceSectionType.reflections => HomeScreenRegion.aboveFold,
      HomeExperienceSectionType.explore => HomeScreenRegion.belowFold,
    };
  }

  static int expectedChildCount(HomeExperienceSectionType type) {
    return switch (type) {
      HomeExperienceSectionType.journey => 1,
      HomeExperienceSectionType.reflections => 3,
      HomeExperienceSectionType.explore => 6,
    };
  }
}
