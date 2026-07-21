import '../models/knowme_mirror_snapshot.dart';
import 'mirror_snapshot_consumer.dart';

/// Home-facing consumer contract — structural summary only.
abstract class HomeMirrorSnapshotConsumer implements MirrorSnapshotConsumer {
  @override
  String get consumerId => 'home';

  /// Top mirror keys ranked by structural prominence metadata.
  List<String> topMirrorKeys(KnowMeMirrorSnapshot snapshot);

  /// Coverage tier for home reflection cards.
  String coverageTier(KnowMeMirrorSnapshot snapshot);
}
