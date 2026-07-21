import '../domain/entities/fusion_tension.dart';
import '../presentation/fusion_presentation_copy.dart';

/// Human-language tension narratives — V3 insight quality.
abstract final class TensionNarrativeBuilder {
  static List<String> build(List<FusionTension> tensions) {
    if (tensions.isEmpty) return const [];

    return tensions
        .map(_narrativeForTension)
        .where((text) => text.isNotEmpty)
        .toList();
  }

  static String _narrativeForTension(FusionTension tension) {
    if (tension.perspectives.length < 2) return '';

    final themeIds = tension.perspectives
        .map((perspective) => perspective.themeId)
        .toSet()
        .toList();

    if (themeIds.isEmpty) return '';

    final tailored = _tailoredNarrative(themeIds);
    if (tailored != null) return tailored;

    final phrases = themeIds
        .map(FusionPresentationCopy.themePhrase)
        .toSet()
        .toList();

    if (phrases.length == 1) {
      return 'บางศาสตร์สะท้อน${phrases.first}ในมุมที่ต่างกันเล็กน้อย\n\n'
          'สิ่งนี้ไม่ได้หมายความว่าคุณสับสน\n'
          'แต่อาจเป็นสัญญาณว่าคุณมีหลายมิติที่เลือกใช้ได้';
    }

    final first = phrases.first;
    final second = phrases.length > 1 ? phrases[1] : phrases.first;

    return 'บางศาสตร์สะท้อนเรื่อง$first\n'
        'ขณะที่บางศาสตร์ให้ความสำคัญกับ$second\n\n'
        'สิ่งนี้อาจทำให้คุณลังเล\n'
        'ระหว่างการเลือกทิศทางที่รู้สึกใกล้เคียงกับตัวเอง\n'
        'กับการรักษาสมดุลกับสิ่งรอบตัว\n\n'
        'ไม่มีด้านไหนผิด\n\n'
        'แต่การรู้ว่ากำลังเลือกอะไร\n'
        'จะช่วยให้คุณสบายใจกับผลลัพธ์มากขึ้น';
  }

  static String? _tailoredNarrative(List<String> themeIds) {
    final set = themeIds.toSet();

    if (set.contains('adaptable') &&
        (set.contains('expressive') || set.contains('openness'))) {
      return 'บางศาสตร์สะท้อนเรื่องการปรับตัว\n'
          'ขณะที่บางศาสตร์ให้ความสำคัญกับการแสดงออก\n\n'
          'สิ่งนี้อาจทำให้คุณลังเล\n'
          'ระหว่างการรักษาความสัมพันธ์\n'
          'กับการพูดในสิ่งที่ตัวเองเชื่อ\n\n'
          'ไม่มีด้านไหนผิด\n\n'
          'แต่การรู้ว่ากำลังเลือกอะไร\n'
          'จะช่วยให้คุณสบายใจกับผลลัพธ์มากขึ้น';
    }

    if (set.contains('independent') && set.contains('supportive')) {
      return 'บางศาสตร์สะท้อนเรื่องความเป็นอิสระ\n'
          'ขณะที่บางศาสตร์ให้ความสำคัญกับการดูแลและสนับสนุนผู้อื่น\n\n'
          'สิ่งนี้อาจทำให้คุณลังเล\n'
          'ระหว่างพื้นที่ของตัวเอง\n'
          'กับความผูกพันกับคนรอบตัว\n\n'
          'ไม่มีด้านไหนผิด\n\n'
          'แต่การรู้ว่ากำลังเลือกอะไร\n'
          'จะช่วยให้คุณสบายใจกับผลลัพธ์มากขึ้น';
    }

    if (set.contains('structured') && set.contains('expressive')) {
      return 'บางศาสตร์สะท้อนเรื่องความเป็นระเบียบ\n'
          'ขณะที่บางศาสตร์ให้ความสำคัญกับการแสดงออก\n\n'
          'สิ่งนี้อาจทำให้คุณลังเล\n'
          'ระหว่างการรักษาโครงสร้างที่มั่นคง\n'
          'กับการแสดงตัวตนอย่างอิสระ\n\n'
          'ไม่มีด้านไหนผิด\n\n'
          'แต่การรู้ว่ากำลังเลือกอะไร\n'
          'จะช่วยให้คุณสบายใจกับผลลัพธ์มากขึ้น';
    }

    return null;
  }
}
