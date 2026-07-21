import '../domain/entities/fusion_signal.dart';
import '../domain/entities/fusion_support_level.dart';
import '../registry/theme_registry.dart';

/// Human-facing copy for Astrology Fusion presentation (no internal ids).
abstract final class FusionPresentationCopy {
  static const Map<FusionSignalType, String> signalTitles = {
    FusionSignalType.autonomy: 'อิสระและการพึ่งพาตัวเอง',
    FusionSignalType.structure: 'โครงสร้างและความรับผิดชอบ',
    FusionSignalType.growth: 'การเติบโต',
    FusionSignalType.connection: 'ความสัมพันธ์',
    FusionSignalType.adaptation: 'การปรับตัว',
    FusionSignalType.expression: 'การแสดงออก',
    FusionSignalType.reflection: 'การทบทวน',
    FusionSignalType.leadership: 'ภาวะผู้นำ',
    FusionSignalType.creativity: 'ความคิดสร้างสรรค์',
    FusionSignalType.transformation: 'มุมมองที่เปลี่ยนแปลง',
  };

  static const Map<String, String> lensTitles = {
    'western_natal': 'Western Natal',
    'chinese_bazi': 'Chinese BaZi',
    'thai_astrology': 'Thai Astrology',
  };

  static String signalTitle(FusionSignalType type) {
    return signalTitles[type] ?? type.name;
  }

  static String lensTitle(String lensId) {
    return lensTitles[lensId] ?? lensId;
  }

  static String supportLevelLabel(FusionSupportLevel level) {
    return switch (level) {
      FusionSupportLevel.high => 'สนับสนุนอย่างชัดเจน',
      FusionSupportLevel.medium => 'มีแนวร่วม',
      FusionSupportLevel.low => 'สังเกตได้',
    };
  }

  static String themePhrase(String themeId) {
    final theme = FusionThemeRegistry.getById(themeId);
    if (theme == null) return themeId;

    return switch (theme.id) {
      'independent' => 'ความเป็นอิสระ',
      'adaptable' => 'การปรับตัว',
      'supportive' => 'การดูแลและสนับสนุนผู้อื่น',
      'diplomatic' => 'การหาจุดร่วมกับผู้อื่น',
      'loyal' => 'ความผูกพันและความจงรักภักดี',
      'independent_connection' => 'พื้นที่ส่วนตัวในความสัมพันธ์',
      'leadership' => 'บทบาทผู้นำ',
      'driven' => 'แรงขับเคลื่อนไปข้างหน้า',
      'responsible' => 'ความรับผิดชอบ',
      'growth_focused' => 'การเติบโตและการเรียนรู้',
      'structured' => 'ความเป็นระเบียบ',
      'analytical' => 'การคิดวิเคราะห์',
      'expressive' => 'การแสดงออก',
      'responsive' => 'การตอบสนองต่อสิ่งรอบตัว',
      'passionate' => 'ความหลงใหลและพลังใจ',
      'persistent' => 'ความมุ่งมั่นต่อเนื่อง',
      'reliable' => 'ความน่าเชื่อถือ',
      'calm' => 'ความสงบภายใน',
      'intuitive' => 'สัญชาตญาณและการรับรู้',
      'openness' => 'ความเปิดรับประสบการณ์ใหม่',
      _ => theme.name,
    };
  }
}
