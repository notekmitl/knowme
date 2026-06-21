import '../models/knowme_mirror_snapshot.dart';

/// MV3.4 write request boundary — no storage implementation.
class MirrorSnapshotWriteRequest {
  const MirrorSnapshotWriteRequest({
    required this.snapshot,
    required this.validationPassed,
    this.ownerKey,
  });

  final KnowMeMirrorSnapshot snapshot;
  final bool validationPassed;
  final String? ownerKey;
}
