import '../domain/entities/astrology_fusion_result.dart';
import '../domain/entities/fusion_signal.dart';
import '../presentation/fusion_presentation_copy.dart';
import 'fusion_meaning_signal_helpers.dart';

/// Future direction paths — reflection only — V6.
class FusionDirection {
  const FusionDirection({
    required this.directionA,
    required this.directionB,
    required this.reflectionQuestion,
  });

  final String directionA;
  final String directionB;
  final String reflectionQuestion;
}

abstract final class FusionDirectionBuilder {
  static FusionDirection? build(AstrologyFusionResult result) {
    if (result.signals.isEmpty &&
        result.tensions.isEmpty &&
        result.topThemes.isEmpty) {
      return null;
    }

    final profile = _resolveProfile(result);
    final paths = _paths[profile];
    if (paths != null) return paths;

    final themeId = FusionMeaningSignalHelpers.primaryThemeId(result);
    final phrase =
        themeId != null ? FusionPresentationCopy.themePhrase(themeId) : 'ตัวตน';

    return FusionDirection(
      directionA:
          'หากคุณค่อย ๆ เดินตาม$phraseต่อ\n'
          'ชีวิตอาจมีแนวโน้มเปิดออก\n'
          'ในทิศทางที่สอดคล้องกับตัวคุณมากขึ้น',
      directionB:
          'หากคุณหลีกเลี่ยงบทเรียนนี้ต่อ\n'
          'โจทย์เดิมอาจกลับมาในรูปแบบใหม่\n'
          'จนกว่าคุณจะพร้อมมองมันอีกครั้ง',
      reflectionQuestion:
          'หากเดินต่อในทิศทางนี้\n'
          'คุณอยากให้ชีวิตรู้สึกต่างไปอย่างไร',
    );
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
        FusionMeaningSignalHelpers.hasTheme(result, 'analytical')) {
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
    return 'default';
  }

  static const Map<String, FusionDirection> _paths = {
    'autonomy': FusionDirection(
      directionA:
          'หากคุณค่อย ๆ เชื่อการตัดสินใจของตัวเองมากขึ้น\n'
          'เส้นทางใหม่อาจมีแนวโน้มเปิดออก\n'
          'มักปรากฏเมื่อคุณกล้ารับผิดชอบทางเลือกของตัวเอง',
      directionB:
          'หากคุณหลีกเลี่ยงบทเรียนเรื่องการเป็นตัวของตัวเองต่อ\n'
          'โจทย์เดิมอาจกลับมาในรูปแบบใหม่\n'
          'จนกว่าคุณจะพร้อมเลือกด้วยหัวใจของตัวเอง',
      reflectionQuestion:
          'หากวันหนึ่งคุณไม่ต้องกังวลว่าจะทำให้ใครผิดหวัง\n'
          'เส้นทางเดิมยังเป็นทางที่คุณเลือกอยู่หรือไม่',
    ),
    'expression': FusionDirection(
      directionA:
          'หากคุณค่อย ๆ พูดความจริงอย่างตรงไปตรงมามากขึ้น\n'
          'ความเข้าใจที่ลึกขึ้นอาจมีแนวโน้มเปิดออก\n'
          'มักปรากฏเมื่อคุณไม่ต้องซ่อนสิ่งที่คิดและรู้สึก',
      directionB:
          'หากคุณหลีกเลี่ยงบทเรียนเรื่องการแสดงตัวตนต่อ\n'
          'ความเหนื่อยจากการเป็นคนที่ไม่ใช่ตัวเอง\n'
          'อาจกลับมาในหลายรูปแบบ',
      reflectionQuestion:
          'หากคุณพูดในสิ่งที่เชื่ออย่างตรงไปตรงมา\n'
          'ความสัมพันธ์รอบตัวอาจเปิดออกในมุมใดที่ยังมองไม่เห็น',
    ),
    'reflection': FusionDirection(
      directionA:
          'หากคุณค่อย ๆ ให้เวลาทบทวนมากขึ้น\n'
          'ความชัดเจนอาจมีแนวโน้มเปิดออก\n'
          'มักปรากฏเมื่อคุณหยุดก่อนตัดสินใจครั้งสำคัญ',
      directionB:
          'หากคุณหลีกเลี่ยงบทเรียนเรื่องการมองภายในต่อ\n'
          'ความลังเลเดิมอาจกลับมา\n'
          'ในรูปแบบที่ต้องการเวลามากขึ้น',
      reflectionQuestion:
          'หากคุณฟังสิ่งที่รู้มาตลอดอยู่แล้ว\n'
          'ทางเลือกอะไรอาจค่อย ๆ ชัดขึ้น',
    ),
    'connection': FusionDirection(
      directionA:
          'หากคุณค่อย ๆ หาจุดสมดุลระหว่างตัวเองกับคนรอบตัว\n'
          'ความสัมพันธ์ที่ลึกขึ้นอาจมีแนวโน้มเปิดออก\n'
          'มักปรากฏเมื่อคุณไม่ต้องทิ้งตัวเองเพื่อรักษาความผูกพัน',
      directionB:
          'หากคุณหลีกเลี่ยงบทเรียนเรื่องความสมดุลต่อ\n'
          'โจทย์เดิมอาจกลับมาในสถานการณ์ใหม่\n'
          'จนกว่าคุณจะพร้อมถ่วงน้ำหนักอีกครั้ง',
      reflectionQuestion:
          'หากคุณรักษาทั้งตัวตนและความสัมพันธ์ไว้พร้อมกัน\n'
          'ชีวิตอาจเปิดออกในแบบใดที่ยังไม่กล้าเลือก',
    ),
    'growth': FusionDirection(
      directionA:
          'หากคุณค่อย ๆ ลงมือทำสิ่งที่สำคัญกับตัวเองมากขึ้น\n'
          'โอกาสเติบโตอาจมีแนวโน้มเปิดออก\n'
          'มักปรากฏเมื่อคุณยอมเรียนรู้จากประสบการณ์จริง',
      directionB:
          'หากคุณหลีกเลี่ยงบทเรียนเรื่องการเติบโตต่อ\n'
          'ความรู้สึกติดอยู่กับที่เดิมอาจกลับมา\n'
          'ในรูปแบบที่ต้องการความกล้ามากขึ้น',
      reflectionQuestion:
          'หากคุณเลือกเติบโตแทนการรอความพร้อม\n'
          'ชีวิตอาจค่อย ๆ เปิดออกอย่างไร',
    ),
  };
}
