import '../domain/entities/astrology_fusion_result.dart';
import '../domain/entities/fusion_signal.dart';
import '../domain/entities/fusion_tension.dart';
import '../presentation/fusion_presentation_copy.dart';
import 'fusion_meaning_signal_helpers.dart';

/// Recurring life challenges (not warnings) — V6.
class FusionLifeTest {
  const FusionLifeTest({required this.body});

  final String body;
}

abstract final class FusionLifeTestBuilder {
  static FusionLifeTest? build(AstrologyFusionResult result) {
    if (result.tensions.isNotEmpty) {
      final fromTension = _fromTension(result.tensions.first);
      if (fromTension != null) return FusionLifeTest(body: fromTension);
    }

    final fromProfile = _fromProfile(result);
    if (fromProfile != null) return FusionLifeTest(body: fromProfile);

    if (result.signals.isEmpty) return null;

    return const FusionLifeTest(
      body:
          'ชีวิตอาจทดสอบคุณผ่านสถานการณ์\n'
          'ที่ต้องเลือกระหว่างสิ่งที่รู้สึกใกล้เคียงกับตัวเอง\n'
          'กับสิ่งที่สถานการณ์ดึงคุณไป\n\n'
          'หลายศาสตร์สะท้อนว่า\n'
          'โจทย์ลักษณะนี้อาจกลับมาในหลายรูปแบบ',
    );
  }

  static String? _fromTension(FusionTension tension) {
    if (tension.perspectives.length < 2) return null;

    final themeIds =
        tension.perspectives.map((p) => p.themeId).toSet().toList();
    if (themeIds.length < 2) return null;

    final set = themeIds.toSet();

    if (set.contains('independent') &&
        (set.contains('supportive') || set.contains('loyal'))) {
      return _testNarrative(
        poleA: 'ความจริงที่อยู่ในใจ',
        poleB: 'ความคาดหวังจากคนรอบตัว',
      );
    }

    if (set.contains('expressive') && set.contains('adaptable')) {
      return _testNarrative(
        poleA: 'สิ่งที่คุณเชื่อและต้องการพูด',
        poleB: 'ความกลมกลืนกับคนรอบตัว',
      );
    }

    if (set.contains('structured') && set.contains('expressive')) {
      return _testNarrative(
        poleA: 'ความมั่นคงและโครงสร้าง',
        poleB: 'พื้นที่แสดงตัวตนอย่างอิสระ',
      );
    }

    final first = FusionPresentationCopy.themePhrase(themeIds.first);
    final second = FusionPresentationCopy.themePhrase(themeIds[1]);
    return _testNarrative(poleA: first, poleB: second);
  }

  static String _testNarrative({
    required String poleA,
    required String poleB,
  }) {
    return 'ชีวิตอาจทดสอบคุณผ่านสถานการณ์ที่ต้องเลือกระหว่าง\n\n'
        '$poleA\n\n'
        'กับ\n\n'
        '$poleB\n\n'
        'หลายศาสตร์สะท้อนว่า\n'
        'โจทย์ลักษณะนี้อาจกลับมาในหลายรูปแบบ';
  }

  static String? _fromProfile(AstrologyFusionResult result) {
    if (FusionMeaningSignalHelpers.hasSignal(result, FusionSignalType.autonomy) &&
        FusionMeaningSignalHelpers.hasSignal(result, FusionSignalType.connection)) {
      return _testNarrative(
        poleA: 'ความจริงที่อยู่ในใจ',
        poleB: 'ความคาดหวังจากคนรอบตัว',
      );
    }

    if (FusionMeaningSignalHelpers.hasSignal(result, FusionSignalType.expression) &&
        FusionMeaningSignalHelpers.hasSignal(result, FusionSignalType.adaptation)) {
      return _testNarrative(
        poleA: 'สิ่งที่คุณเชื่อและต้องการพูด',
        poleB: 'ความกลมกลืนกับคนรอบตัว',
      );
    }

    if (FusionMeaningSignalHelpers.hasSignal(result, FusionSignalType.autonomy)) {
      return _testNarrative(
        poleA: 'เสียงตัวเอง',
        poleB: 'เสียงจากภายนอกที่บอกว่าควรเป็นอย่างไร',
      );
    }

    if (FusionMeaningSignalHelpers.hasSignal(result, FusionSignalType.reflection)) {
      return _testNarrative(
        poleA: 'การตัดสินใจอย่างรวดเร็ว',
        poleB: 'เวลาในการทบทวนและมองภายใน',
      );
    }

    return null;
  }
}
