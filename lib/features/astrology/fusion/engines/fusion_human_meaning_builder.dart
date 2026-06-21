import '../domain/entities/astrology_fusion_result.dart';
import '../domain/entities/fusion_signal.dart';
import '../domain/entities/fusion_support_level.dart';
import 'fusion_human_meaning_copy.dart';

/// Synthesizes human-facing meaning from fusion themes and patterns — V3.
abstract final class FusionHumanMeaningBuilder {
  static String buildHeroSupporting(AstrologyFusionResult result) {
    if (_hasAutonomyPattern(result)) {
      return FusionHumanMeaningCopy.heroAutonomySupporting;
    }

    if (_hasExpressionPattern(result)) {
      return 'หลายศาสตร์เห็นตรงกันว่า\n\n'
          'ช่วงเวลาที่คุณมีพลังที่สุด\n'
          'มักเกิดขึ้นเมื่อไม่ต้องซ่อนสิ่งที่คิดและรู้สึก\n\n'
          'ความเข้าใจมักตามมา\n'
          'เมื่อคุณกล้าสื่อสารอย่างตรงไปตรงมา';
    }

    if (_hasReflectionPattern(result)) {
      return 'หลายศาสตร์เห็นตรงกันว่า\n\n'
          'ช่วงเวลาที่คุณเห็นทางออกชัดที่สุด\n'
          'มักไม่ใช่ตอนที่รีบตัดสินใจ\n\n'
          'แต่เป็นตอนที่คุณหยุดทบทวน\n'
          'แล้วเลือกเดินต่ออย่างมีสติ';
    }

    return '${_patternLead(result)}\n\n'
        'หลายศาสตร์เห็นรูปแบบชีวิตแบบเดียวกันในด้านนี้\n'
        'และมักสะท้อนจุดที่คุณมีพลังเมื่อได้ใช้ชีวิตอย่างสอดคล้องกับตัวเอง';
  }

  static String buildKnowMeMoment(AstrologyFusionResult result) {
    if (_hasAutonomyPattern(result)) {
      return FusionHumanMeaningCopy.knowMeMomentAutonomyBody;
    }
    if (_hasExpressionPattern(result)) {
      return FusionHumanMeaningCopy.knowMeMomentExpressionBody;
    }
    if (_hasReflectionPattern(result)) {
      return FusionHumanMeaningCopy.knowMeMomentReflectionBody;
    }
    return FusionHumanMeaningCopy.knowMeMomentDefaultBody;
  }

  static bool _hasAutonomyPattern(AstrologyFusionResult result) {
    if (result.topThemes.any(_isAutonomyTheme)) return true;
    return _visibleSignals(result).any(
      (signal) => signal.type == FusionSignalType.autonomy,
    );
  }

  static bool _hasExpressionPattern(AstrologyFusionResult result) {
    if (result.topThemes.any(_isExpressionTheme)) return true;
    return _visibleSignals(result).any(
      (signal) => signal.type == FusionSignalType.expression,
    );
  }

  static bool _hasReflectionPattern(AstrologyFusionResult result) {
    if (result.topThemes.any(_isReflectionTheme)) return true;
    return _visibleSignals(result).any(
      (signal) => signal.type == FusionSignalType.reflection,
    );
  }

  static bool _isAutonomyTheme(String themeId) {
    return themeId == 'independent' ||
        themeId == 'autonomy' ||
        themeId == 'driven' ||
        themeId == 'responsible';
  }

  static bool _isExpressionTheme(String themeId) {
    return themeId == 'expressive' ||
        themeId == 'expression' ||
        themeId == 'passionate' ||
        themeId == 'openness';
  }

  static bool _isReflectionTheme(String themeId) {
    return themeId == 'analytical' ||
        themeId == 'intuitive' ||
        themeId == 'reflection' ||
        themeId == 'calm';
  }

  static String _patternLead(AstrologyFusionResult result) {
    if (result.topThemes.isEmpty) {
      return 'หลายศาสตร์เห็นตรงกันว่า';
    }
    return 'หลายศาสตร์เห็นรูปแบบชีวิตแบบเดียวกัน\n'
        'ในด้านที่สำคัญกับคุณ';
  }

  static List<FusionSignal> _visibleSignals(AstrologyFusionResult result) {
    return result.signals
        .where(
          (signal) =>
              signal.supportLevel != FusionSupportLevel.low &&
              signal.type != FusionSignalType.transformation,
        )
        .toList();
  }
}
