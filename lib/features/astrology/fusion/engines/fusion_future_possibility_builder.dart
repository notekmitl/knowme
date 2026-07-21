import '../domain/entities/astrology_fusion_result.dart';
import '../domain/entities/fusion_signal.dart';
import '../domain/entities/fusion_support_level.dart';

/// Future possibility layer — reflection only, no fortune-telling — V4.
class FusionFuturePossibility {
  const FusionFuturePossibility({
    required this.opportunity,
    required this.challenge,
    required this.futureReflection,
  });

  final String opportunity;
  final String challenge;
  final String futureReflection;
}

abstract final class FusionFuturePossibilityBuilder {
  static FusionFuturePossibility? build(AstrologyFusionResult result) {
    if (result.signals.isEmpty &&
        result.tensions.isEmpty &&
        result.growthOpportunities.isEmpty &&
        result.futureTendencies.isEmpty) {
      return null;
    }

    return FusionFuturePossibility(
      opportunity: _opportunity(result),
      challenge: _challenge(result),
      futureReflection: _futureReflection(result),
    );
  }

  static String _opportunity(AstrologyFusionResult result) {
    if (_hasSignal(result, FusionSignalType.autonomy) ||
        result.topThemes.contains('independent')) {
      return 'เมื่อคุณเริ่มเชื่อการตัดสินใจของตัวเองมากขึ้น\n\n'
          'หลายศาสตร์สะท้อนว่า\n'
          'เส้นทางใหม่อาจมีแนวโน้มเปิดออก\n'
          'มักปรากฏเมื่อคุณกล้าเลือกทิศทางของตัวเอง';
    }

    if (_hasSignal(result, FusionSignalType.expression)) {
      return 'เมื่อคุณกล้าแสดงตัวตนอย่างตรงไปตรงมามากขึ้น\n\n'
          'หลายศาสตร์สะท้อนว่า\n'
          'ความเข้าใจที่ลึกขึ้นอาจมีแนวโน้มเปิดออก\n'
          'มักปรากฏเมื่อคุณไม่ต้องซ่อนสิ่งที่คิดและรู้สึก';
    }

    if (_hasSignal(result, FusionSignalType.growth)) {
      return 'เมื่อคุณลงมือทำสิ่งที่สำคัญกับตัวเองมากขึ้น\n\n'
          'หลายศาสตร์สะท้อนว่า\n'
          'โอกาสเติบโตอาจมีแนวโน้มเปิดออก\n'
          'มักปรากฏเมื่อคุณยอมเรียนรู้จากประสบการณ์จริง';
    }

    final tendency = result.futureTendencies.isNotEmpty
        ? result.futureTendencies.first.description
        : null;
    if (tendency != null && tendency.trim().isNotEmpty) {
      return 'หลายศาสตร์สะท้อนว่า\n'
          '${tendency.trim()}\n\n'
          'นี่อาจกลายเป็นเส้นทางที่มีแนวโน้มเปิดออก';
    }

    return 'เมื่อคุณใช้ชีวิตสอดคล้องกับตัวเองมากขึ้น\n\n'
        'หลายศาสตร์สะท้อนว่า\n'
        'เส้นทางในด้านที่คุณให้ความสำคัญอยู่แล้ว\n'
        'อาจมีแนวโน้มเปิดออก';
  }

  static String _challenge(AstrologyFusionResult result) {
    if (result.tensions.isNotEmpty) {
      return 'การพยายามรักษาความสมดุล\n'
          'ระหว่างความเป็นตัวเอง\n\n'
          'กับความคาดหวังจากคนรอบตัว\n\n'
          'มักปรากฏเมื่อชีวิตเข้าสู่ช่วงเปลี่ยนแปลง\n'
          'และอาจกลายเป็นบทเรียนสำคัญ';
    }

    if (_hasSignal(result, FusionSignalType.autonomy) &&
        _hasSignal(result, FusionSignalType.connection)) {
      return 'การหาจุดสมดุล\n'
          'ระหว่างพื้นที่ของตัวเองกับความผูกพัน\n\n'
          'มักปรากฏเมื่อความสัมพันธ์และทิศทางชีวิต\n'
          'ดึงคุณไปคนละทาง';
    }

    if (_hasSignal(result, FusionSignalType.structure)) {
      return 'การรักษาความยืดหยุ่น\n'
          'ท่ามกลางโครงสร้างที่คุณสร้างไว้\n\n'
          'มักปรากฏเมื่อสถานการณ์เปลี่ยนไป\n'
          'และอาจกลายเป็นบทเรียนเรื่องการปรับตัว';
    }

    return 'การไม่ทิ้งตัวเอง\n'
        'ท่ามกลางความคาดหวังจากภายนอก\n\n'
        'มักปรากฏเมื่อคุณยืนอยู่หน้าทางเลือกสำคัญ\n'
        'และอาจมีโอกาสเติบโตเป็นความเข้าใจตัวเองลึกขึ้น';
  }

  static String _futureReflection(AstrologyFusionResult result) {
    if (_hasSignal(result, FusionSignalType.autonomy) ||
        result.topThemes.contains('independent')) {
      return 'หากวันหนึ่งคุณไม่ต้องกังวล\n'
          'ว่าจะทำให้ใครผิดหวัง\n\n'
          'เส้นทางเดิมยังเป็นทางที่คุณเลือกอยู่หรือไม่';
    }

    if (_hasSignal(result, FusionSignalType.expression)) {
      return 'หากคุณพูดในสิ่งที่เชื่ออย่างตรงไปตรงมา\n'
          'โดยไม่ต้องกังวลถึงปฏิกิริยา\n\n'
          'ความสัมพันธ์รอบตัวอาจเปิดออกในมุมใดที่ยังมองไม่เห็น';
    }

    if (_hasSignal(result, FusionSignalType.reflection)) {
      return 'หากคุณให้เวลาทบทวนมากขึ้น\n'
          'ก่อนตัดสินใจครั้งสำคัญ\n\n'
          'ทางเลือกอะไรอาจมีแนวโน้มเปิดออก\n'
          'ที่ยังมองไม่เห็นตอนนี้';
    }

    return 'หากคุณใช้ชีวิตตามแบบที่สอดคล้องกับตัวเองมากขึ้น\n'
        'เส้นทางอะไรอาจมีโอกาสเติบโตเป็น\n'
        'สิ่งที่ยังไม่กล้าเลือกในวันนี้';
  }

  static bool _hasSignal(AstrologyFusionResult result, FusionSignalType type) {
    return result.signals.any(
      (s) =>
          s.type == type &&
          s.supportLevel != FusionSupportLevel.low &&
          s.type != FusionSignalType.transformation,
    );
  }
}
