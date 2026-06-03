import 'package:knowme/features/tests/mbti/data/mbti_firestore_repository.dart';
import 'package:knowme/features/tests/mbti_cognitive/data/mbti_cognitive_firestore_repository.dart';

import '../domain/mbti_summary_insight_models.dart';
import '../domain/mbti_summary_models.dart';
import 'mbti_summary_fusion_engine.dart';
import 'mbti_summary_insight_engine.dart';

/// Fusion view + Phase 1 insights for the summary page.
class MbtiSummaryFusionContent {
  const MbtiSummaryFusionContent({
    required this.view,
    required this.insights,
  });

  final MbtiSummaryFusionView view;
  final MbtiSummaryInsightBundle insights;
}

/// Loads existing MBTI + Cognitive results for fusion (read-only).
class MbtiSummaryLoader {
  MbtiSummaryLoader({
    MbtiFirestoreRepository? mbtiRepository,
    MbtiCognitiveFirestoreRepository? cognitiveRepository,
  })  : _mbtiRepository = mbtiRepository ?? MbtiFirestoreRepositoryImpl(),
        _cognitiveRepository =
            cognitiveRepository ?? MbtiCognitiveFirestoreRepositoryImpl();

  final MbtiFirestoreRepository _mbtiRepository;
  final MbtiCognitiveFirestoreRepository _cognitiveRepository;

  Future<MbtiSummaryAvailability> loadAvailability(String uid) async {
    final mbti = await _mbtiRepository.loadLatestResult(uid);
    final cognitive = await _cognitiveRepository.loadLatestResult(uid);

    return MbtiSummaryAvailability(
      hasMbtiResult: mbti != null,
      hasCognitiveResult: cognitive != null,
      mbtiScoredQuestionCount: mbti?.scoredQuestionCount ?? 0,
      cognitiveScoredQuestionCount: cognitive?.scoredQuestionCount ?? 0,
    );
  }

  Future<MbtiSummaryFusionView?> loadFusionView(String uid) async {
    final content = await loadFusionContent(uid);
    return content?.view;
  }

  Future<MbtiSummaryFusionContent?> loadFusionContent(String uid) async {
    final mbti = await _mbtiRepository.loadLatestResult(uid);
    final cognitive = await _cognitiveRepository.loadLatestResult(uid);
    if (mbti == null || cognitive == null) return null;

    final input = MbtiSummaryFusionInput(mbti: mbti, cognitive: cognitive);
    return MbtiSummaryFusionContent(
      view: MbtiSummaryFusionEngine.build(input),
      insights: MbtiSummaryInsightEngine.build(
        mbti: mbti,
        cognitive: cognitive,
      ),
    );
  }
}
