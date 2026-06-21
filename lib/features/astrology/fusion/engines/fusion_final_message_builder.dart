import '../domain/entities/astrology_fusion_result.dart';
import '../domain/entities/fusion_signal.dart';
import 'fusion_meaning_signal_helpers.dart';

/// Memorable closing message — V6 (max ~3 lines).
class FusionFinalMessage {
  const FusionFinalMessage({required this.message});

  final String message;
}

abstract final class FusionFinalMessageBuilder {
  static FusionFinalMessage? build(AstrologyFusionResult result) {
    if (result.signals.isEmpty && result.topThemes.isEmpty) return null;

    final profile = _resolveProfile(result);
    final message = _messages[profile];
    if (message != null) return FusionFinalMessage(message: message);

    return const FusionFinalMessage(
      message:
          'หลายศาสตร์ไม่ได้มาบอกว่าคุณควรเป็นใคร\n'
          'แต่มาช่วยให้คุณเห็นว่าตัวเองกำลังเดินอยู่บทไหน',
    );
  }

  static String _resolveProfile(AstrologyFusionResult result) {
    if (FusionMeaningSignalHelpers.hasSignal(result, FusionSignalType.autonomy) ||
        FusionMeaningSignalHelpers.hasTheme(result, 'independent')) {
      return 'autonomy';
    }
    if (FusionMeaningSignalHelpers.hasSignal(result, FusionSignalType.reflection) ||
        FusionMeaningSignalHelpers.hasTheme(result, 'analytical') ||
        FusionMeaningSignalHelpers.hasTheme(result, 'intuitive')) {
      return 'reflection';
    }
    if (FusionMeaningSignalHelpers.hasSignal(result, FusionSignalType.expression) ||
        FusionMeaningSignalHelpers.hasTheme(result, 'expressive')) {
      return 'expression';
    }
    if (FusionMeaningSignalHelpers.hasSignal(result, FusionSignalType.connection) ||
        FusionMeaningSignalHelpers.hasTheme(result, 'supportive')) {
      return 'connection';
    }
    return 'default';
  }

  static const Map<String, String> _messages = {
    'autonomy':
        'คุณไม่ได้เกิดมาเพื่อเป็นทุกอย่างสำหรับทุกคน\n\n'
        'คุณเกิดมาเพื่อเป็นตัวเองอย่างเต็มที่',
    'reflection':
        'บางครั้งคำตอบ\n'
        'ไม่ได้อยู่ที่การมองไปข้างหน้า\n\n'
        'แต่อยู่ที่การฟังสิ่งที่คุณรู้มาตลอดอยู่แล้ว',
    'expression':
        'คุณไม่จำเป็นต้องเลือกระหว่างความจริงกับความรัก\n\n'
        'บางครั้งทั้งสองอย่างอาจอยู่ร่วมกันได้',
    'connection':
        'คุณไม่จำเป็นต้องเลือกระหว่างตัวเองกับคนรอบตัว\n\n'
        'บางครั้งการเป็นตัวเองคือของขวัญที่ดีที่สุดที่ให้ได้',
    'default':
        'หลายศาสตร์ไม่ได้มาบอกว่าคุณควรเป็นใคร\n'
        'แต่มาช่วยให้คุณเห็นว่าตัวเองกำลังเดินอยู่บทไหน',
  };
}
