import '../domain/entities/astrology_fusion_result.dart';
import '../domain/entities/fusion_signal.dart';
import '../presentation/fusion_presentation_copy.dart';
import 'fusion_meaning_signal_helpers.dart';

/// Symbolic life lessons from fusion themes — V5.
class FusionLifeLesson {
  const FusionLifeLesson({required this.body});

  final String body;
}

abstract final class FusionLifeLessonBuilder {
  static FusionLifeLesson? build(AstrologyFusionResult result) {
    if (result.signals.isEmpty && result.topThemes.isEmpty) return null;

    final profile = _resolveProfile(result);
    final lesson = _lessons[profile];
    if (lesson != null) return FusionLifeLesson(body: lesson);

    final themeId = FusionMeaningSignalHelpers.primaryThemeId(result);
    if (themeId != null) {
      final phrase = FusionPresentationCopy.themePhrase(themeId);
      return FusionLifeLesson(
        body:
            'ชีวิตดูเหมือนกำลังชวนให้คุณเรียนรู้ว่า\n\n'
            '$phrase\n'
            'ไม่ได้เป็นคำตอบสุดท้าย\n'
            'แต่เป็นทิศทางที่คุณกำลังเดินอยู่',
      );
    }

    return null;
  }

  static String _resolveProfile(AstrologyFusionResult result) {
    if (FusionMeaningSignalHelpers.hasSignal(result, FusionSignalType.autonomy) ||
        FusionMeaningSignalHelpers.hasTheme(result, 'independent')) {
      return 'autonomy';
    }
    if (FusionMeaningSignalHelpers.hasSignal(result, FusionSignalType.expression) ||
        FusionMeaningSignalHelpers.hasTheme(result, 'expressive')) {
      return 'expression';
    }
    if (FusionMeaningSignalHelpers.hasSignal(result, FusionSignalType.reflection) ||
        FusionMeaningSignalHelpers.hasTheme(result, 'analytical') ||
        FusionMeaningSignalHelpers.hasTheme(result, 'intuitive')) {
      return 'reflection';
    }
    if (FusionMeaningSignalHelpers.hasSignal(result, FusionSignalType.connection) ||
        FusionMeaningSignalHelpers.hasTheme(result, 'supportive')) {
      return 'connection';
    }
    if (FusionMeaningSignalHelpers.hasSignal(result, FusionSignalType.growth) ||
        FusionMeaningSignalHelpers.hasTheme(result, 'growth_focused')) {
      return 'growth';
    }
    if (FusionMeaningSignalHelpers.hasSignal(result, FusionSignalType.structure) ||
        FusionMeaningSignalHelpers.hasTheme(result, 'structured')) {
      return 'structure';
    }
    if (FusionMeaningSignalHelpers.hasSignal(result, FusionSignalType.adaptation) ||
        FusionMeaningSignalHelpers.hasTheme(result, 'adaptable')) {
      return 'adaptation';
    }
    return 'default';
  }

  static const Map<String, String> _lessons = {
    'autonomy':
        'ชีวิตดูเหมือนกำลังชวนให้คุณเรียนรู้ว่า\n\n'
        'การตัดสินใจด้วยตัวเอง\n'
        'ไม่ได้หมายความว่าต้องทำทุกอย่างคนเดียว',
    'expression':
        'ชีวิตดูเหมือนกำลังชวนให้คุณเรียนรู้ว่า\n\n'
        'การพูดความจริง\n'
        'สามารถอยู่ร่วมกับความอ่อนโยนได้',
    'reflection':
        'ชีวิตดูเหมือนกำลังชวนให้คุณเรียนรู้ว่า\n\n'
        'ความชัดเจน\n'
        'มักเกิดขึ้นหลังจากการหยุดทบทวน\n'
        'ไม่ใช่การรีบตัดสินใจ',
    'connection':
        'ชีวิตดูเหมือนกำลังชวนให้คุณเรียนรู้ว่า\n\n'
        'การรักษาความสัมพันธ์\n'
        'ไม่จำเป็นต้องแลกกับการทิ้งตัวเอง',
    'growth':
        'ชีวิตดูเหมือนกำลังชวนให้คุณเรียนรู้ว่า\n\n'
        'การเติบโต\n'
        'มักเริ่มจากความไม่สมบูรณ์แบบ\n'
        'มากกว่าความพร้อมที่รอมานาน',
    'structure':
        'ชีวิตดูเหมือนกำลังชวนให้คุณเรียนรู้ว่า\n\n'
        'ความมั่นคง\n'
        'ไม่ได้หมายความว่าต้องแข็งทื่อตลอดเวลา',
    'adaptation':
        'ชีวิตดูเหมือนกำลังชวนให้คุณเรียนรู้ว่า\n\n'
        'การปรับตัว\n'
        'ไม่ได้หมายความว่าต้องเปลี่ยนตัวเองทั้งหมด',
  };
}
