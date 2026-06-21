import '../domain/entities/astrology_fusion_result.dart';
import '../domain/entities/fusion_signal.dart';
import '../domain/entities/fusion_support_level.dart';
import '../domain/entities/fusion_tension.dart';
import '../presentation/fusion_presentation_copy.dart';

/// Life-pattern contradictions from fusion data — V4.
class FusionContradiction {
  const FusionContradiction({
    required this.poleA,
    required this.poleB,
    required this.explanation,
    required this.reflection,
  });

  final String poleA;
  final String poleB;
  final String explanation;
  final String reflection;

  String get formattedBody =>
      'หลายศาสตร์เห็นตรงกันว่า\n\n'
      '$poleA\n\n'
      'แต่ในเวลาเดียวกัน\n\n'
      '$poleB\n\n'
      '$explanation\n\n'
      '$reflection';

  String formattedWithWisdom(String? wisdom) {
    final base = formattedBody;
    if (wisdom == null || wisdom.trim().isEmpty) return base;
    return '$base\n\n$wisdom';
  }
}

abstract final class FusionContradictionBuilder {
  static FusionContradiction? build(AstrologyFusionResult result) {
    final fromTension = _fromTension(result.tensions);
    if (fromTension != null) return fromTension;

    final fromSignals = _fromSignals(result);
    if (fromSignals != null) return fromSignals;

    return _fromThemes(result.topThemes);
  }

  static FusionContradiction? _fromTension(List<FusionTension> tensions) {
    for (final tension in tensions) {
      if (tension.perspectives.length < 2) continue;

      final themeIds = tension.perspectives
          .map((p) => p.themeId)
          .toSet()
          .toList();
      if (themeIds.length < 2) continue;

      final tailored = _tailoredTension(themeIds);
      if (tailored != null) return tailored;
    }
    return null;
  }

  static FusionContradiction? _tailoredTension(List<String> themeIds) {
    final set = themeIds.toSet();

    if (set.contains('independent') &&
        (set.contains('supportive') || set.contains('loyal'))) {
      return const FusionContradiction(
        poleA: 'คุณต้องการอิสระในการกำหนดชีวิต',
        poleB: 'คุณก็ใส่ใจความรู้สึกของคนรอบตัวมาก',
        explanation:
            'อยากเป็นตัวเอง\n'
            'แต่ก็ไม่ต้องการทำให้ใครเสียใจ',
        reflection:
            'ความขัดแย้งนี้ไม่ได้หมายความว่าคุณสับสน\n'
            'แต่อาจหมายความว่าคุณกำลังหาทางเลือกที่ทั้งจริงกับตัวเองและรักษาความสัมพันธ์',
      );
    }

    if (set.contains('independent') && set.contains('adaptable')) {
      return const FusionContradiction(
        poleA: 'คุณต้องการอิสระในการกำหนดชีวิต',
        poleB: 'คุณก็ไม่ได้มีความสุขกับความไม่แน่นอน',
        explanation:
            'สิ่งที่คุณตามหา\n'
            'อาจไม่ใช่อิสระแบบไร้ขอบเขต\n'
            'แต่คืออิสระภายในทิศทางที่คุณเลือกเอง',
        reflection:
            'หลายศาสตร์เห็นว่าคุณมีพลังเมื่อได้เลือกทิศทางเอง\n'
            'แม้เส้นทางนั้นจะยังไม่ชัดทุกช่วงเวลา',
      );
    }

    if (set.contains('expressive') && set.contains('adaptable')) {
      return const FusionContradiction(
        poleA: 'คุณต้องการแสดงความคิดอย่างตรงไปตรงมา',
        poleB: 'คุณก็มีแนวโน้มปรับตัวเพื่อรักษาความสัมพันธ์',
        explanation:
            'บางครั้งคุณอาจลังเล\n'
            'ระหว่างการพูดในสิ่งที่เชื่อกับการรักษาบรรยากาศ',
        reflection:
            'ความตึงนี้ไม่ได้หมายความว่าคุณไม่จริงใจ\n'
            'แต่อาจสะท้อนว่าคุณใส่ใจทั้งตัวตนและผู้อื่นในเวลาเดียวกัน',
      );
    }

    if (set.contains('structured') && set.contains('expressive')) {
      return const FusionContradiction(
        poleA: 'คุณต้องการความชัดเจนและโครงสร้าง',
        poleB: 'คุณก็ต้องการพื้นที่แสดงตัวตนอย่างอิสระ',
        explanation:
            'คุณอาจรู้สึกว่าต้องเลือก\n'
            'ระหว่างความมั่นคงกับความยืดหยุ่น',
        reflection:
            'หลายศาสตร์เห็นว่าคุณเติบโตได้ดี\n'
            'เมื่อมีกรอบที่ชัด แต่ยังเหลือพื้นที่ให้ตัวเองหายใจ',
      );
    }

    final first = FusionPresentationCopy.themePhrase(themeIds.first);
    final second = FusionPresentationCopy.themePhrase(themeIds[1]);
    return FusionContradiction(
      poleA: 'หลายศาสตร์สะท้อน$first',
      poleB: 'ขณะที่บางศาสตร์ให้ความสำคัญกับ$second',
      explanation:
          'สองด้านนี้อาจดูต่างกัน\n'
          'แต่มักอยู่ในชีวิตคุณพร้อมกัน',
      reflection:
          'การเห็นทั้งสองด้านชัดขึ้น\n'
          'อาจช่วยให้คุณเลือกได้อย่างสบายใจมากขึ้น',
    );
  }

  static FusionContradiction? _fromSignals(AstrologyFusionResult result) {
    final types = _visibleSignals(result).map((s) => s.type).toSet();

    if (types.contains(FusionSignalType.autonomy) &&
        types.contains(FusionSignalType.reflection)) {
      return const FusionContradiction(
        poleA: 'คุณกล้าตัดสินใจและรับผิดชอบทางเลือกของตัวเอง',
        poleB: 'คุณก็ชอบทบทวนก่อนลงมือเสมอ',
        explanation:
            'กล้าตัดสินใจ\n'
            'แต่ชอบทบทวนก่อนเสมอ',
        reflection:
            'ความขัดแย้งนี้ไม่ใช่ความลังเล\n'
            'แต่อาจเป็นวิธีที่คุณใช้เพื่อตัดสินใจอย่างมีน้ำหนัก',
      );
    }

    if (types.contains(FusionSignalType.autonomy) &&
        types.contains(FusionSignalType.connection)) {
      return const FusionContradiction(
        poleA: 'คุณต้องการอิสระในการกำหนดชีวิต',
        poleB: 'คุณก็ใส่ใจความสัมพันธ์กับคนรอบตัวมาก',
        explanation:
            'อยากเป็นตัวเอง\n'
            'แต่ก็ใส่ใจความรู้สึกคนอื่นมาก',
        reflection:
            'คุณไม่จำเป็นต้องเลือกด้านใดด้านหนึ่งถาวร\n'
            'แต่การรู้ว่ากำลังถ่วงน้ำหนักอะไร อาจช่วยให้คุณสบายใจขึ้น',
      );
    }

    if (types.contains(FusionSignalType.expression) &&
        types.contains(FusionSignalType.adaptation)) {
      return const FusionContradiction(
        poleA: 'คุณต้องการแสดงความคิดอย่างตรงไปตรงมา',
        poleB: 'คุณก็มีแนวโน้มปรับตัวตามสถานการณ์',
        explanation:
            'บางครั้งการพูดตรงไปตรงมา\n'
            'กับการรักษาความกลมกลืนอาจดึงคุณไปคนละทิศ',
        reflection:
            'หลายศาสตร์เห็นว่าคุณมีพลังเมื่อรู้ว่ากำลังเลือกอะไร\n'
            'ไม่ใช่เมื่อถูกสถานการณ์ดึงไปโดยไม่รู้ตัว',
      );
    }

    return null;
  }

  static FusionContradiction? _fromThemes(List<String> themes) {
    if (themes.contains('independent')) {
      return const FusionContradiction(
        poleA: 'คุณต้องการอิสระในการกำหนดชีวิต',
        poleB: 'คุณก็ไม่ได้มีความสุขกับความไม่แน่นอน',
        explanation:
            'ต้องการอิสระ\n'
            'แต่ไม่ชอบความไร้ทิศทาง',
        reflection:
            'สิ่งที่คุณตามหา\n'
            'อาจไม่ใช่อิสระแบบไร้ขอบเขต\n'
            'แต่คืออิสระภายในทิศทางที่คุณเลือกเอง',
      );
    }
    return null;
  }

  static List<FusionSignal> _visibleSignals(AstrologyFusionResult result) {
    return result.signals
        .where(
          (s) =>
              s.supportLevel != FusionSupportLevel.low &&
              s.type != FusionSignalType.transformation,
        )
        .toList();
  }
}
