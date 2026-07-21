import '../domain/discovery_item.dart';
import '../domain/exploration_lens_id.dart';
import '../domain/exploration_mirror_id.dart';

/// Deterministic discovery copy — mapping tables only (EO-F1, no recommendations).
abstract final class DiscoveryRegistry {
  static const discoveryVersion = 'discovery.v1';

  static String lensTitle(ExplorationLensId lensId) {
    return _lensTitles[lensId] ?? lensId.id;
  }

  static String lensDescription(ExplorationLensId lensId) {
    return _lensDescriptions[lensId] ??
        'มุมมองหนึ่งที่คุณสามารถสำรวจได้ใน KnowMe';
  }

  static DiscoveryCategory lensCategory(ExplorationLensId lensId) {
    return ExplorationLensId.astrologyLenses.contains(lensId)
        ? DiscoveryCategory.astrology
        : DiscoveryCategory.personality;
  }

  static String mirrorTitle(ExplorationMirrorId mirrorId) {
    return _mirrorTitles[mirrorId] ?? mirrorId.id;
  }

  static String mirrorDescription(ExplorationMirrorId mirrorId) {
    return _mirrorDescriptions[mirrorId] ??
        'มิเรอร์ที่รวบรวมมุมมองจากหลายเลนส์';
  }

  static DiscoveryCategory mirrorCategory(ExplorationMirrorId mirrorId) {
    return switch (mirrorId) {
      ExplorationMirrorId.astrologyMirror => DiscoveryCategory.astrology,
      ExplorationMirrorId.personalityMirror => DiscoveryCategory.personality,
    };
  }

  static const globalFusionTitle = 'Global Fusion';
  static const globalFusionDescription =
      'มุมมองรวมข้ามมิเรอร์ที่สะท้อนแนวโน้มจากดวงดาวและบุคลิกภาพ';

  static const explorationOverviewTitle = 'Exploration Overview';
  static const explorationOverviewDescription =
      'ภาพรวมว่าคุณสำรวจตัวเองไปถึงไหนแล้ว และยังมีมุมใดที่เปิดอยู่';

  static const Map<ExplorationLensId, String> _lensTitles = {
    ExplorationLensId.westernNatal: 'Western Natal',
    ExplorationLensId.chineseBazi: 'Chinese BaZi',
    ExplorationLensId.thaiAstrology: 'Thai Astrology',
    ExplorationLensId.mbti: 'MBTI',
    ExplorationLensId.eq: 'EQ',
    ExplorationLensId.bigFive: 'Big Five',
  };

  static const Map<ExplorationLensId, String> _lensDescriptions = {
    ExplorationLensId.westernNatal:
        'มุมมองดวงชะตาแบบตะวันตกจากข้อมูลวันเวลาและสถานที่เกิด',
    ExplorationLensId.chineseBazi:
        'มุมมอง BaZi ที่สะท้อนแนวโน้มพลังงานจากวันเวลาเกิด',
    ExplorationLensId.thaiAstrology:
        'มุมมองโหราศาสตร์ไทยสำหรับการมองตัวเองในแบบไทย',
    ExplorationLensId.mbti:
        'มุมมองบุคลิกแบบ MBTI จากแบบทดสอบของคุณ',
    ExplorationLensId.eq:
        'มุมมองความฉลาดทางอารมณ์จากโมดูล EQ',
    ExplorationLensId.bigFive:
        'มุมมองบุคลิกห้ามิติจาก Big Five',
  };

  static const Map<ExplorationMirrorId, String> _mirrorTitles = {
    ExplorationMirrorId.astrologyMirror: 'Astrology Mirror',
    ExplorationMirrorId.personalityMirror: 'Personality Mirror',
  };

  static const Map<ExplorationMirrorId, String> _mirrorDescriptions = {
    ExplorationMirrorId.astrologyMirror:
        'มิเรอร์ที่รวมเลนส์ดวงดาวหลายระบบเข้าด้วยกัน',
    ExplorationMirrorId.personalityMirror:
        'มิเรอร์ที่รวมผลจากแบบทดสอบบุคลิกหลายชุด',
  };
}
