import '../models/knowme_mirror_snapshot.dart';
import 'mirror_snapshot_consumer.dart';

/// Global Fusion consumer contract — cross-mirror theme alignment input.
abstract class GlobalFusionMirrorSnapshotConsumer implements MirrorSnapshotConsumer {
  @override
  String get consumerId => 'global_fusion';

  /// Theme ids eligible for fusion activation from mirror agreements.
  List<String> fusionThemeCandidates(KnowMeMirrorSnapshot snapshot);

  /// Tension pairs for divergence architecture.
  List<(String, String)> tensionThemePairs(KnowMeMirrorSnapshot snapshot);
}
