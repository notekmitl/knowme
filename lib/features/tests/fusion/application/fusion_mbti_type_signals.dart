import '../domain/fusion_constants.dart';
import '../domain/fusion_models.dart';

/// Preset MBTI type → signal strengths (deterministic, maintainable table).
typedef MbtiTypeSignalSpec = (String id, FusionSignalStrength strength);

abstract final class FusionMbtiTypeSignals {
  static const Map<String, List<MbtiTypeSignalSpec>> byTypeCode = {
    'INTJ': [
      (FusionSignalIds.reflection, FusionSignalStrength.high),
      (FusionSignalIds.logicOrientation, FusionSignalStrength.medium),
      (FusionSignalIds.structure, FusionSignalStrength.medium),
      (FusionSignalIds.exploration, FusionSignalStrength.low),
    ],
    'INTP': [
      (FusionSignalIds.curiosity, FusionSignalStrength.high),
      (FusionSignalIds.logicOrientation, FusionSignalStrength.medium),
      (FusionSignalIds.reflection, FusionSignalStrength.medium),
      (FusionSignalIds.structure, FusionSignalStrength.low),
    ],
    'ENTJ': [
      (FusionSignalIds.logicOrientation, FusionSignalStrength.high),
      (FusionSignalIds.structure, FusionSignalStrength.high),
      (FusionSignalIds.exploration, FusionSignalStrength.medium),
      (FusionSignalIds.socialExpression, FusionSignalStrength.medium),
    ],
    'ENTP': [
      (FusionSignalIds.exploration, FusionSignalStrength.high),
      (FusionSignalIds.curiosity, FusionSignalStrength.high),
      (FusionSignalIds.openness, FusionSignalStrength.medium),
      (FusionSignalIds.structure, FusionSignalStrength.low),
    ],
    'INFJ': [
      (FusionSignalIds.reflection, FusionSignalStrength.high),
      (FusionSignalIds.intuition, FusionSignalStrength.medium),
      (FusionSignalIds.emotionalProcessing, FusionSignalStrength.medium),
      (FusionSignalIds.structure, FusionSignalStrength.low),
    ],
    'INFP': [
      (FusionSignalIds.emotionalProcessing, FusionSignalStrength.high),
      (FusionSignalIds.reflection, FusionSignalStrength.medium),
      (FusionSignalIds.openness, FusionSignalStrength.medium),
      (FusionSignalIds.structure, FusionSignalStrength.low),
    ],
    'ENFJ': [
      (FusionSignalIds.socialExpression, FusionSignalStrength.high),
      (FusionSignalIds.emotionalProcessing, FusionSignalStrength.medium),
      (FusionSignalIds.structure, FusionSignalStrength.medium),
      (FusionSignalIds.exploration, FusionSignalStrength.low),
    ],
    'ENFP': [
      (FusionSignalIds.exploration, FusionSignalStrength.high),
      (FusionSignalIds.curiosity, FusionSignalStrength.high),
      (FusionSignalIds.socialExpression, FusionSignalStrength.medium),
      (FusionSignalIds.structure, FusionSignalStrength.low),
    ],
    'ISTJ': [
      (FusionSignalIds.structure, FusionSignalStrength.high),
      (FusionSignalIds.logicOrientation, FusionSignalStrength.medium),
      (FusionSignalIds.reflection, FusionSignalStrength.medium),
      (FusionSignalIds.exploration, FusionSignalStrength.low),
    ],
    'ISFJ': [
      (FusionSignalIds.structure, FusionSignalStrength.high),
      (FusionSignalIds.emotionalSensitivity, FusionSignalStrength.medium),
      (FusionSignalIds.reflection, FusionSignalStrength.medium),
      (FusionSignalIds.exploration, FusionSignalStrength.low),
    ],
    'ESTJ': [
      (FusionSignalIds.structure, FusionSignalStrength.high),
      (FusionSignalIds.logicOrientation, FusionSignalStrength.medium),
      (FusionSignalIds.socialExpression, FusionSignalStrength.medium),
      (FusionSignalIds.openness, FusionSignalStrength.low),
    ],
    'ESFJ': [
      (FusionSignalIds.socialExpression, FusionSignalStrength.high),
      (FusionSignalIds.emotionalProcessing, FusionSignalStrength.medium),
      (FusionSignalIds.structure, FusionSignalStrength.medium),
      (FusionSignalIds.exploration, FusionSignalStrength.low),
    ],
    'ISTP': [
      (FusionSignalIds.logicOrientation, FusionSignalStrength.medium),
      (FusionSignalIds.structure, FusionSignalStrength.medium),
      (FusionSignalIds.exploration, FusionSignalStrength.low),
      (FusionSignalIds.socialExpression, FusionSignalStrength.low),
    ],
    'ISFP': [
      (FusionSignalIds.emotionalProcessing, FusionSignalStrength.medium),
      (FusionSignalIds.reflection, FusionSignalStrength.medium),
      (FusionSignalIds.openness, FusionSignalStrength.medium),
      (FusionSignalIds.structure, FusionSignalStrength.low),
    ],
    'ESTP': [
      (FusionSignalIds.exploration, FusionSignalStrength.high),
      (FusionSignalIds.socialExpression, FusionSignalStrength.medium),
      (FusionSignalIds.structure, FusionSignalStrength.low),
      (FusionSignalIds.reflection, FusionSignalStrength.low),
    ],
    'ESFP': [
      (FusionSignalIds.socialExpression, FusionSignalStrength.high),
      (FusionSignalIds.exploration, FusionSignalStrength.medium),
      (FusionSignalIds.emotionalProcessing, FusionSignalStrength.medium),
      (FusionSignalIds.structure, FusionSignalStrength.low),
    ],
  };
}
