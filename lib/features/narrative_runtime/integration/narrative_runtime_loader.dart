import 'package:knowme/features/narrative_runtime/domain/narrative_result.dart';

import 'user_runtime_pipeline_service.dart';

/// Loads narrative for Home from the signed-in user's real pipeline data.
class NarrativeRuntimeLoader {
  Future<NarrativeResult?> loadForUser(
    String uid, {
    DateTime? generatedAt,
  }) async {
    if (uid.isEmpty) return null;
    return UserRuntimePipelineService.loadNarrativeForUser(
      uid,
      generatedAt: generatedAt,
    );
  }
}
