import '../../domain/global_agreement_strength.dart';
import '../../domain/global_core_themes.dart';
import '../../domain/global_confidence_band.dart';

/// Deterministic reflection copy — mapping tables only (GF-F3, no AI).
abstract final class GlobalNarrativeRegistry {
  static const narrativeVersion = 'global_narrative.v1';

  static String themeReflection(String themeId) {
    return _themeReflections[themeId] ??
        'หลายมุมสะท้อนแนวโน้มที่อาจสำคัญกับคุณในช่วงนี้';
  }

  static String agreementReflection(String themeId) {
    return _agreementReflections[themeId] ?? themeReflection(themeId);
  }

  static String tensionReflection(String primaryThemeId, String secondaryThemeId) {
    final key = _tensionKey(primaryThemeId, secondaryThemeId);
    return _tensionReflections[key] ??
        'บางมุมสะท้อนแนวโน้มที่แตกต่างกัน '
            'และอาจชวนให้คุณพิจารณาทั้งสองด้านอย่างนุ่มนวล';
  }

  static GlobalConfidenceBand agreementStrengthBand(
    GlobalAgreementStrength strength,
  ) {
    return switch (strength) {
      GlobalAgreementStrength.weak => GlobalConfidenceBand.low,
      GlobalAgreementStrength.medium => GlobalConfidenceBand.medium,
      GlobalAgreementStrength.strong => GlobalConfidenceBand.high,
    };
  }

  static String _tensionKey(String a, String b) {
    final sorted = [a, b]..sort();
    return '${sorted[0]}:${sorted[1]}';
  }

  static const Map<String, String> _themeReflections = {
    GlobalThemeIds.reflection:
        'คุณอาจให้ความสำคัญกับการใคร่ครวญ การมองเข้าไปข้างใน '
            'และการใช้เวลาทำความเข้าใจสิ่งต่าง ๆ ก่อนตัดสินใจ',
    GlobalThemeIds.structure:
        'คุณอาจให้ความสำคัญกับความชัดเจน การวางแผน '
            'และความมั่นคงที่ช่วยให้สิ่งต่าง ๆ ดำเนินไปได้อย่างเป็นระเบียบ',
    GlobalThemeIds.adaptability:
        'คุณอาจให้ความสำคัญกับความยืดหยุ่น '
            'และการปรับตัวเมื่อสถานการณ์เปลี่ยนไป',
    GlobalThemeIds.relationships:
        'คุณอาจให้ความสำคัญกับการเชื่อมโยง การดูแลซึ่งกันและกัน '
            'และความเข้าใจในมิติความสัมพันธ์',
    GlobalThemeIds.expression:
        'คุณอาจให้ความสำคัญกับการแสดงออก การสื่อสารความรู้สึก '
            'และการให้โลกภายนอกเห็นสิ่งที่อยู่ข้างใน',
    GlobalThemeIds.autonomy:
        'คุณอาจให้ความสำคัญกับการตัดสินใจด้วยตัวเอง '
            'และการกำหนดทิศทางบางอย่างของชีวิตด้วยตนเอง',
    GlobalThemeIds.growth:
        'คุณอาจให้ความสำคัญกับการเติบโต การเรียนรู้ '
            'และการก้าวไปข้างหน้าในแบบของคุณเอง',
  };

  static const Map<String, String> _agreementReflections = {
    GlobalThemeIds.reflection:
        'หลายมุมสะท้อนแนวโน้มที่คุณอาจให้เวลากับการคิด การไตร่ตรอง '
            'และการทำความเข้าใจสิ่งต่าง ๆ อย่างลึกซึ้ง',
    GlobalThemeIds.structure:
        'หลายมุมสะท้อนแนวโน้มที่คุณอาจรู้สึกสบายใจกว่า '
            'เมื่อสิ่งต่าง ๆ มีความชัดเจนและวางแผนได้',
    GlobalThemeIds.adaptability:
        'หลายมุมสะท้อนแนวโน้มที่คุณอาจปรับตัวได้ดี '
            'เมื่อสถานการณ์หรือบริบทเปลี่ยนไป',
    GlobalThemeIds.relationships:
        'หลายมุมสะท้อนแนวโน้มที่คุณอาจให้ความสำคัญกับการเชื่อมโยง '
            'และการดูแลความสัมพันธ์รอบตัว',
    GlobalThemeIds.expression:
        'หลายมุมสะท้อนแนวโน้มที่คุณอาจแสดงออก '
            'และสื่อสารสิ่งที่อยู่ข้างในได้อย่างเป็นธรรมชาติ',
    GlobalThemeIds.autonomy:
        'หลายมุมสะท้อนแนวโน้มที่คุณอาจให้ความสำคัญกับอิสระ '
            'และการตัดสินใจในแบบของตนเอง',
    GlobalThemeIds.growth:
        'หลายมุมสะท้อนแนวโน้มที่คุณอาจมองหาโอกาสในการเติบโต '
            'และพัฒนาตนเองอย่างต่อเนื่อง',
  };

  static const Map<String, String> _tensionReflections = {
    'adaptability:structure':
        'บางมุมสะท้อนความต้องการความชัดเจน '
            'ขณะที่อีกมุมสะท้อนความยืดหยุ่นต่อสถานการณ์',
    'reflection:relationships':
        'บางมุมสะท้อนการใคร่ครวญและมองเข้าไปข้างใน '
            'ขณะที่อีกมุมสะท้อนการเชื่อมโยงและความสัมพันธ์',
    'growth:structure':
        'บางมุมสะท้อนการเติบโตและการก้าวไปข้างหน้า '
            'ขณะที่อีกมุมสะท้อนความมั่นคงและความเป็นระเบียบ',
  };
}
