import '../models/knowme_mirror_snapshot.dart';

/// MV3.4 read boundary result — no storage implementation.
class MirrorSnapshotReadResult {
  const MirrorSnapshotReadResult({
    required this.found,
    this.snapshot,
    this.failureCode,
  });

  final bool found;
  final KnowMeMirrorSnapshot? snapshot;
  final String? failureCode;

  static MirrorSnapshotReadResult notFound({String? failureCode}) {
    return MirrorSnapshotReadResult(
      found: false,
      failureCode: failureCode ?? 'not_found',
    );
  }

  static MirrorSnapshotReadResult success(KnowMeMirrorSnapshot snapshot) {
    return MirrorSnapshotReadResult(found: true, snapshot: snapshot);
  }
}
