import 'package:flutter/foundation.dart';
import 'package:knowme/features/tests/mbti/domain/mbti_models.dart';
import 'package:knowme/features/tests/mbti_cognitive/domain/mbti_cognitive_models.dart';

/// Temporary fusion confidence diagnostics — remove after root cause confirmed.
abstract final class MbtiSummaryDebug {
  static const _tag = '[MbtiSummaryDebug]';

  static void logFirestorePaths({required String uid}) {
    if (!kDebugMode) return;
    debugPrint('$_tag Firestore read paths (NOT tests/* progress):');
    debugPrint('$_tag   users/$uid/results/$mbtiMiniTestId');
    debugPrint('$_tag   users/$uid/results/$mbtiCognitiveTestId');
    debugPrint('$_tag Catalog progress (separate): users/$uid/tests/$mbtiMiniTestId');
    debugPrint('$_tag Catalog progress (separate): users/$uid/tests/$mbtiCognitiveTestId');
  }

  static void logRawMbtiResultDoc({
    required String uid,
    required Map<String, dynamic>? raw,
    required bool exists,
  }) {
    if (!kDebugMode) return;
    debugPrint('$_tag --- users/$uid/results/$mbtiMiniTestId (raw) ---');
    debugPrint('$_tag exists=$exists');
    if (raw == null) {
      debugPrint('$_tag (no document data)');
      return;
    }
    debugPrint(
      '$_tag raw scoredQuestionCount field=${raw['scoredQuestionCount']} '
      '(type=${raw['scoredQuestionCount']?.runtimeType})',
    );
    debugPrint('$_tag raw type=${raw['type']}');
    debugPrint('$_tag raw testId=${raw['testId']}');
    debugPrint(
      '$_tag raw dimensions keys E/I/S/N/T/F/J/P present: '
      'E=${raw['E']} I=${raw['I']} S=${raw['S']} N=${raw['N']} '
      'T=${raw['T']} F=${raw['F']} J=${raw['J']} P=${raw['P']}',
    );
  }

  static void logRawCognitiveResultDoc({
    required String uid,
    required Map<String, dynamic>? raw,
    required bool exists,
  }) {
    if (!kDebugMode) return;
    debugPrint('$_tag --- users/$uid/results/$mbtiCognitiveTestId (raw) ---');
    debugPrint('$_tag exists=$exists');
    if (raw == null) return;
    debugPrint(
      '$_tag raw scoredQuestionCount field=${raw['scoredQuestionCount']} '
      '(type=${raw['scoredQuestionCount']?.runtimeType})',
    );
    debugPrint('$_tag raw topFunctions=${raw['topFunctions']}');
  }

  static void logLoadedMbtiResult(MbtiResultSummary? result) {
    if (!kDebugMode) return;
    debugPrint('$_tag MBTI result (parsed from results/mbti_mini):');
    if (result == null) {
      debugPrint('$_tag   null');
      return;
    }
    debugPrint('$_tag   type=${result.type}');
    debugPrint('$_tag   scoredQuestionCount=${result.scoredQuestionCount}');
    debugPrint('$_tag   testId=${result.testId}');
    debugPrint('$_tag   dimensions=${result.dimensions}');
    debugPrint('$_tag   scoringVersion=${result.scoringVersion}');
  }

  static void logLoadedCognitiveResult(MbtiCognitiveResultSummary? result) {
    if (!kDebugMode) return;
    debugPrint('$_tag Cognitive result (parsed from results/mbti_cognitive):');
    if (result == null) {
      debugPrint('$_tag   null');
      return;
    }
    debugPrint('$_tag   scoredQuestionCount=${result.scoredQuestionCount}');
    debugPrint('$_tag   topFunctions=${result.topFunctions}');
    debugPrint('$_tag   stackTypeHints=${result.stackTypeHints}');
  }

  static void logFusionConfidence({
    required int mbtiCount,
    required int cognitiveCount,
  }) {
    if (!kDebugMode) return;
    final weakest = mbtiCount < cognitiveCount ? mbtiCount : cognitiveCount;
    String tier;
    String tierKey;
    if (weakest >= mbtiAccurateCheckpoint) {
      tier = 'accurate (80+)';
      tierKey = 'mbti_cog_confidence_accurate';
    } else if (weakest >= mbtiStandardCheckpoint) {
      tier = 'standard (40-79)';
      tierKey = 'mbti_cog_confidence_standard';
    } else {
      tier = 'mini (0-39)';
      tierKey = 'mbti_cog_confidence_mini';
    }

    debugPrint('$_tag Fusion confidence (from result.scoredQuestionCount only):');
    debugPrint('$_tag   mbtiCount=$mbtiCount');
    debugPrint('$_tag   cognitiveCount=$cognitiveCount');
    debugPrint('$_tag   weakest=min($mbtiCount,$cognitiveCount)=$weakest');
    debugPrint('$_tag   tier=$tier');
    debugPrint('$_tag   confidenceKey=$tierKey');
    if (mbtiCount == mbtiMiniCheckpoint && mbtiCount < mbtiAccurateCheckpoint) {
      debugPrint(
        '$_tag   NOTE: mbtiCount==16 may be model default when Firestore field '
        'is missing (see raw doc log above)',
      );
    }
  }

  static void logMbtiSavePath({
    required int questionsLength,
    required int answersLength,
    required int scoredQuestionCount,
    required String type,
  }) {
    if (!kDebugMode) return;
    debugPrint('$_tag MBTI saveResult (finish → results/mbti_mini):');
    debugPrint('$_tag   questions.length=$questionsLength');
    debugPrint('$_tag   answers.length=$answersLength');
    debugPrint('$_tag   summary.scoredQuestionCount=$scoredQuestionCount');
    debugPrint('$_tag   summary.type=$type');
  }
}
