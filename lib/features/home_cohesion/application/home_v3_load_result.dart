import 'package:knowme/features/home_cohesion/application/home_v2_assembler.dart';
import 'package:knowme/features/home_cohesion/presentation/home_screen_v3_models.dart';
import 'package:knowme/features/narrative_runtime/domain/narrative_result.dart';

/// Result of progressive Home load — preserves bundle for generation merges.
class HomeV3LoadResult {
  const HomeV3LoadResult({
    required this.data,
    required this.bundle,
    this.narrative,
  });

  final HomeScreenV3Data data;
  final HomeV2SourceBundle bundle;
  final NarrativeResult? narrative;
}
