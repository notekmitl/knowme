import '../models/knowme_mirror_snapshot.dart';

/// MV3.4 read request boundary — no storage implementation.
class MirrorSnapshotReadRequest {
  const MirrorSnapshotReadRequest({
    required this.snapshotId,
    this.mirrorScopeId,
    this.ownerKey,
  });

  final String snapshotId;
  final String? mirrorScopeId;
  final String? ownerKey;
}
