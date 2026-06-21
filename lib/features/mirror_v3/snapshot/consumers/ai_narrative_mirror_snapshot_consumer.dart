import '../models/knowme_mirror_snapshot.dart';
import 'mirror_snapshot_consumer.dart';

/// AI Narrative consumer contract — explainability payload only, no generation.
abstract class AiNarrativeMirrorSnapshotConsumer implements MirrorSnapshotConsumer {
  @override
  String get consumerId => 'ai_narrative';

  /// Evidence rows traceable to findings for future narrative grounding.
  Map<String, List<String>> explainabilityIndex(KnowMeMirrorSnapshot snapshot);
}
