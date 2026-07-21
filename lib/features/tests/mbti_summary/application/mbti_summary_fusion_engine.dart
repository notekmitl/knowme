import 'package:knowme/core/i18n/app_text.dart';
import 'package:knowme/data/mbti/mbti_types.dart';
import 'package:knowme/features/tests/mbti_cognitive/presentation/mbti_cognitive_result_content.dart';

import '../domain/mbti_summary_constants.dart';
import 'package:knowme/services/mbti/mbti_function_stack.dart';

import '../domain/mbti_summary_models.dart';

/// Rule-based MBTI + Cognitive fusion (no AI).
abstract final class MbtiSummaryFusionEngine {
  static MbtiSummaryFusionView build(MbtiSummaryFusionInput input) {
    final mbti = input.mbti;
    final cognitive = input.cognitive;
    final type = mbti.type.toUpperCase();
    final topFour = cognitive.topFour;
    final topLabel = topFour.take(3).join('/');

    final alignment = _detectAlignment(type, topFour);
    final alignmentBodyKey = switch (alignment) {
      MbtiSummaryAlignment.aligned => 'mbti_sum_align_aligned',
      MbtiSummaryAlignment.partial => 'mbti_sum_align_partial',
      MbtiSummaryAlignment.mixed => 'mbti_sum_align_mixed',
    };

    final heroParagraphs = _heroParagraphs(type, topFour);
    final thinkingBulletKeys = _thinkingBulletKeys(topFour);
    final confidenceKey = _fusionConfidenceKey(
      mbti.scoredQuestionCount,
      cognitive.scoredQuestionCount,
    );
    final growthCautionKey = _growthCautionKey(type, topFour);

    return MbtiSummaryFusionView(
      typeCode: type,
      topFunctionsLabel: topLabel,
      heroParagraphs: heroParagraphs,
      alignment: alignment,
      alignmentBodyKey: alignmentBodyKey,
      thinkingBulletKeys: thinkingBulletKeys,
      confidenceKey: confidenceKey,
      growthCautionKey: growthCautionKey,
      mbtiScoredQuestionCount: mbti.scoredQuestionCount,
      cognitiveScoredQuestionCount: cognitive.scoredQuestionCount,
    );
  }

  static String typeRoleLabel(String type) {
    final lang = AppText.lang;
    final mbti = mbtiTypes[type];
    return mbti?.title[lang] ?? mbti?.title['en'] ?? type;
  }

  static String typeDescriptionLine(String type) {
    final lang = AppText.lang;
    final mbti = mbtiTypes[type];
    return mbti?.description[lang] ??
        mbti?.description['en'] ??
        AppText.t('mbti_sum_type_unknown');
  }

  static List<String> _heroParagraphs(String type, List<String> topFour) {
    final lines = <String>[
      typeDescriptionLine(type),
      ...MbtiCognitiveResultContent.thinkingStyleLines(topFour).take(2),
    ];
    return lines.where((l) => l.isNotEmpty).toList();
  }

  static List<String> _thinkingBulletKeys(List<String> topFour) {
    final keys = <String>[];
    for (final fn in topFour.take(4)) {
      keys.add('mbti_cog_think_${fn.toLowerCase()}');
    }
    if (keys.isEmpty) {
      keys.add('mbti_cog_think_fallback');
    }
    return keys;
  }

  static MbtiSummaryAlignment _detectAlignment(
    String type,
    List<String> topCognitive,
  ) {
    final stack = mbtiFunctionStacks[type];
    if (stack == null || topCognitive.isEmpty) {
      return MbtiSummaryAlignment.partial;
    }

    final cogTop2 = topCognitive.take(2).toList();
    final stackTop2 = stack.take(2).toSet();
    final stackTop4 = stack.take(4).toSet();

    final overlapTop2 =
        cogTop2.where((fn) => stackTop2.contains(fn)).length;

    if (overlapTop2 >= mbtiSummaryAlignedTopTwoOverlapMin) {
      return MbtiSummaryAlignment.aligned;
    }

    final overlapTop4 =
        topCognitive.take(2).where((fn) => stackTop4.contains(fn)).length;

    if (overlapTop4 >= mbtiSummaryPartialTopFourOverlapMin) {
      return MbtiSummaryAlignment.partial;
    }

    return MbtiSummaryAlignment.mixed;
  }

  /// Confidence from stored result [scoredQuestionCount] only (weaker of MBTI + Cognitive).
  static String _fusionConfidenceKey(int mbtiScored, int cognitiveScored) {
    final weakest = mbtiScored < cognitiveScored ? mbtiScored : cognitiveScored;

    if (weakest >= mbtiSummaryAccurateCheckpoint) {
      return 'mbti_cog_confidence_accurate';
    }
    if (weakest >= mbtiSummaryStandardCheckpoint) {
      return 'mbti_cog_confidence_standard';
    }
    return 'mbti_cog_confidence_mini';
  }

  static String _growthCautionKey(String type, List<String> topFour) {
    final top2 = topFour.take(2).toSet();
    final hasLogic = top2.contains('Te') || top2.contains('Ti');
    final hasFeeling = top2.contains('Fi') || top2.contains('Fe');
    final typeUpper = type.toUpperCase();

    if (hasLogic && !hasFeeling && typeUpper.contains('F')) {
      return 'mbti_sum_caution_logic_over_feeling';
    }
    if (hasLogic && typeUpper.contains('T') && !hasFeeling) {
      return 'mbti_sum_caution_logic_blindspot';
    }
    if ((top2.contains('Ne') || top2.contains('Ni')) &&
        (typeUpper.contains('S'))) {
      return 'mbti_sum_caution_intuition_vs_type';
    }
    if ((top2.contains('Si') || top2.contains('Se')) &&
        (typeUpper.contains('N'))) {
      return 'mbti_sum_caution_sensing_vs_type';
    }
    return 'mbti_sum_caution_balanced';
  }
}
