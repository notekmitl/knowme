import '../models/knowme_mirror_snapshot.dart';
import 'mirror_snapshot_consumer.dart';

/// Analytics consumer contract — structural metrics only.
abstract class AnalyticsMirrorSnapshotConsumer implements MirrorSnapshotConsumer {
  @override
  String get consumerId => 'analytics';

  Map<String, num> metricPayload(KnowMeMirrorSnapshot snapshot);
}
