import '../models/knowme_mirror_snapshot.dart';

/// Base consumer contract for MV3 snapshot assets.
abstract class MirrorSnapshotConsumer {
  bool canConsume(KnowMeMirrorSnapshot snapshot);

  String get consumerId;
}
