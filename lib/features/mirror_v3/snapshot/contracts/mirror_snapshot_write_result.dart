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

  /// Accepted write factory — named [acceptedFor] so it does not clash with
  /// the [accepted] instance field.
  static MirrorSnapshotWriteResult acceptedFor(String snapshotId) {
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
