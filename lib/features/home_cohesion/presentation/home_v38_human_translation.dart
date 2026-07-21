import 'home_screen_v3_models.dart';

/// Human Translation Layer — V3.8 (no internal theme names on UI).
abstract final class HomeV38HumanTranslation {
  static const technicalTerms = {
    'driven',
    'passionate',
    'structure',
    'reflection',
    'adaptability',
    'expression',
    'autonomy',
    'growth',
    'relationships',
    'connection',
    'adaptation',
    'leadership',
    'creativity',
    'transformation',
    'independent',
    'disciplined',
    'flexible',
    'adaptable',
    'expressive',
    'reserved',
    'structured',
    'analytical',
    'intuitive',
  };

  /// Short normalized label for Signature layer (e.g. อิสระ).
  static String signatureLabel(String themeId) {
    return _profileFor(themeId).signatureLabel;
  }

  static HomeInsightCardData insightCard(String themeId) {
    final profile = _profileFor(themeId);
    return HomeInsightCardData(
      humanMeaning: profile.humanMeaning,
      supportingExplanation: profile.supportingExplanation,
      visualKind: profile.visualKind,
    );
  }

  static bool isTechnicalTerm(String text) {
    final normalized = text.trim().toLowerCase();
    if (technicalTerms.contains(normalized)) return true;
    return _containsLatinTechnicalWord(normalized);
  }

  static String sanitizeForUi(String text) {
    var result = text.trim();
    if (result.isEmpty) return result;
    if (isTechnicalTerm(result)) {
      return signatureLabel(result);
    }
    for (final term in technicalTerms) {
      result = result.replaceAll(RegExp(term, caseSensitive: false), '');
    }
    return result.replaceAll(RegExp(r'\s+'), ' ').trim();
  }

  static _ThemeProfile _profileFor(String themeId) {
    final id = themeId.trim().toLowerCase();

    return switch (id) {
      'autonomy' || 'independent' => const _ThemeProfile(
          signatureLabel: 'อิสระ',
          humanMeaning: 'คุณรู้สึกดีที่สุดเมื่อได้เลือกเส้นทางของตัวเอง',
          supportingExplanation:
              'คุณมักต้องการพื้นที่ในการตัดสินใจด้วยตัวเอง',
          visualKind: HomeThemeVisualKind.autonomy,
        ),
      'growth' || 'visionary' || 'curious' => const _ThemeProfile(
          signatureLabel: 'การเติบโต',
          humanMeaning: 'คุณมักมองหาโอกาสในการพัฒนาตัวเองอยู่เสมอ',
          supportingExplanation: 'คุณเติบโตได้ดีเมื่อได้เรียนรู้และก้าวต่อไป',
          visualKind: HomeThemeVisualKind.growth,
        ),
      'adaptability' ||
      'adaptable' ||
      'flexible' ||
      'responsive' ||
      'adaptation' =>
        const _ThemeProfile(
          signatureLabel: 'ความยืดหยุ่น',
          humanMeaning: 'คุณสามารถปรับตัวกับการเปลี่ยนแปลงได้ดี',
          supportingExplanation: 'คุณมักหาทางให้ตัวเองเดินต่อได้ในสถานการณ์ใหม่',
          visualKind: HomeThemeVisualKind.adaptability,
        ),
      'structure' || 'structured' || 'disciplined' => const _ThemeProfile(
          signatureLabel: 'ความชัดเจน',
          humanMeaning: 'คุณทำงานได้ดีเมื่อมีแผนและทิศทางที่ชัดเจน',
          supportingExplanation: 'ความเป็นระเบียบช่วยให้คุณมั่นใจในการลงมือทำ',
          visualKind: HomeThemeVisualKind.structure,
        ),
      'reflection' || 'reserved' || 'analytical' || 'intuitive' =>
        const _ThemeProfile(
          signatureLabel: 'การทบทวนตัวเอง',
          humanMeaning: 'คุณใช้เวลาทำความเข้าใจตัวเองก่อนตัดสินใจสำคัญ',
          supportingExplanation: 'การหยุดและสะท้อนช่วยให้คุณเห็นภาพชัดขึ้น',
          visualKind: HomeThemeVisualKind.reflection,
        ),
      'expression' || 'expressive' || 'creative' => const _ThemeProfile(
          signatureLabel: 'การแสดงออก',
          humanMeaning: 'คุณสื่อความรู้สึกและตัวตนได้อย่างเป็นธรรมชาติ',
          supportingExplanation: 'เมื่อได้แสดงออก คุณมักรู้สึกใกล้ชิดกับตัวเองมากขึ้น',
          visualKind: HomeThemeVisualKind.expression,
        ),
      'relationships' || 'connection' || 'supportive' || 'diplomatic' =>
        const _ThemeProfile(
          signatureLabel: 'ความสัมพันธ์',
          humanMeaning: 'คุณให้ความสำคัญกับการเชื่อมต่อกับคนรอบข้าง',
          supportingExplanation: 'ความสัมพันธ์ที่ดีช่วยให้คุณรู้สึกมีที่ยืน',
          visualKind: HomeThemeVisualKind.relationships,
        ),
      'driven' || 'leadership' => const _ThemeProfile(
          signatureLabel: 'ความมุ่งมั่น',
          humanMeaning: 'คุณมีพลังในการลงมือทำเมื่อเห็นเป้าหมายชัดเจน',
          supportingExplanation: 'เมื่อมีทิศทาง คุณมักเดินต่อได้อย่างมั่นใจ',
          visualKind: HomeThemeVisualKind.growth,
        ),
      'passionate' => const _ThemeProfile(
          signatureLabel: 'ความหลงใหล',
          humanMeaning: 'คุณทุ่มเทเมื่อสิ่งนั้นมีความหมายกับคุณจริง ๆ',
          supportingExplanation: 'พลังใจช่วยให้คุณเดินหน้าในสิ่งที่ใส่ใจ',
          visualKind: HomeThemeVisualKind.expression,
        ),
      'grounded' => const _ThemeProfile(
          signatureLabel: 'ความมั่นคง',
          humanMeaning: 'คุณมองหาพื้นที่ที่ทำให้รู้สึกมั่นใจและมั่นคง',
          supportingExplanation: 'เมื่อมีรากฐาน คุณมักตัดสินใจได้ดีขึ้น',
          visualKind: HomeThemeVisualKind.generic,
        ),
      'responsible' || 'reliable' => const _ThemeProfile(
          signatureLabel: 'ความรับผิดชอบ',
          humanMeaning: 'คุณใส่ใจกับสิ่งที่รับปากไว้และทำให้สำเร็จ',
          supportingExplanation: 'ความน่าเชื่อถือเป็นส่วนหนึ่งของตัวตนคุณ',
          visualKind: HomeThemeVisualKind.structure,
        ),
      'calm' => const _ThemeProfile(
          signatureLabel: 'ความสงบ',
          humanMeaning: 'คุณรักษาความสงบภายในได้ดีในวันที่วุ่นวาย',
          supportingExplanation: 'ความสงบช่วยให้คุณมองเห็นสิ่งสำคัญได้ชัดขึ้น',
          visualKind: HomeThemeVisualKind.reflection,
        ),
      _ => const _ThemeProfile(
          signatureLabel: 'จุดเด่นของคุณ',
          humanMeaning: 'มีบางอย่างในตัวคุณที่สะท้อนซ้ำในหลายมุม',
          supportingExplanation: 'KnowMe กำลังเรียนรู้ภาพรวมของคุณให้ชัดขึ้น',
          visualKind: HomeThemeVisualKind.generic,
        ),
    };
  }

  static bool _containsLatinTechnicalWord(String text) {
    return technicalTerms.any((term) => text.contains(term));
  }
}

class _ThemeProfile {
  const _ThemeProfile({
    required this.signatureLabel,
    required this.humanMeaning,
    required this.supportingExplanation,
    required this.visualKind,
  });

  final String signatureLabel;
  final String humanMeaning;
  final String supportingExplanation;
  final HomeThemeVisualKind visualKind;
}
