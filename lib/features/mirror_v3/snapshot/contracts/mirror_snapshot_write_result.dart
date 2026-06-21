/// MV3.4 write boundary result — no storage implementation.
class MirrorSnapshotWriteResult {
  const MirrorSnapshotWriteResult({
    required this.accepted,
    required this.snapshotId,
    this.rejectedReason,
  });

  final bool accepted;
  final String snapshotId;
  final String? rejectedReason;

  static MirrorSnapshotWriteResult accepted(String snapshotId) {
    return MirrorSnapshotWriteResult(
      accepted: true,
      snapshotId: snapshotId,
    );
  }

  static MirrorSnapshotWriteResult rejected({
    required String snapshotId,
    required String reason,
  }) {
    return MirrorSnapshotWriteResult(
      accepted: false,
      snapshotId: snapshotId,
      rejectedReason: reason,
    );
  }
}
