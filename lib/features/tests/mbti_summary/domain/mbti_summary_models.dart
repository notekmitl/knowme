import 'package:knowme/features/tests/mbti/domain/mbti_models.dart';
import 'package:knowme/features/tests/mbti_cognitive/domain/mbti_cognitive_models.dart';

/// Catalog / module id — not a scored test.
const String mbtiSummaryModuleId = 'mbti_summary';

enum MbtiSummaryAlignment {
  aligned,
  partial,
  mixed,
}

/// Readiness to open the fusion page (derived from stored results).
class MbtiSummaryAvailability {
  const MbtiSummaryAvailability({
    required this.hasMbtiResult,
    required this.hasCognitiveResult,
    this.mbtiScoredQuestionCount = 0,
    this.cognitiveScoredQuestionCount = 0,
  });

  final bool hasMbtiResult;
  final bool hasCognitiveResult;
  final int mbtiScoredQuestionCount;
  final int cognitiveScoredQuestionCount;

  bool get canOpenFusion => hasMbtiResult && hasCognitiveResult;

  bool get missingMbti => !hasMbtiResult;
  bool get missingCognitive => !hasCognitiveResult;
}

/// Inputs for rule-based fusion (no new Firestore schema).
class MbtiSummaryFusionInput {
  const MbtiSummaryFusionInput({
    required this.mbti,
    required this.cognitive,
  });

  final MbtiResultSummary mbti;
  final MbtiCognitiveResultSummary cognitive;
}

/// Presentation-ready fusion output (deterministic).
class MbtiSummaryFusionView {
  const MbtiSummaryFusionView({
    required this.typeCode,
    required this.topFunctionsLabel,
    required this.heroParagraphs,
    required this.alignment,
    required this.alignmentBodyKey,
    required this.thinkingBulletKeys,
    required this.confidenceKey,
    required this.growthCautionKey,
    required this.mbtiScoredQuestionCount,
    required this.cognitiveScoredQuestionCount,
  });

  final String typeCode;
  final String topFunctionsLabel;
  final List<String> heroParagraphs;
  final MbtiSummaryAlignment alignment;
  final String alignmentBodyKey;
  final List<String> thinkingBulletKeys;
  final String confidenceKey;
  final String growthCautionKey;
  final int mbtiScoredQuestionCount;
  final int cognitiveScoredQuestionCount;
}
