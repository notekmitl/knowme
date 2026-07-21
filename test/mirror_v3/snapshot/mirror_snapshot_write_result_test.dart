import 'package:flutter_test/flutter_test.dart';
import 'package:knowme/features/mirror_v3/snapshot/contracts/mirror_snapshot_write_result.dart';

void main() {
  group('MirrorSnapshotWriteResult', () {
    test('acceptedFor preserves accepted=true semantics', () {
      final result = MirrorSnapshotWriteResult.acceptedFor('snap-1');
      expect(result.accepted, isTrue);
      expect(result.snapshotId, 'snap-1');
      expect(result.rejectedReason, isNull);
    });

    test('rejected preserves accepted=false semantics', () {
      final result = MirrorSnapshotWriteResult.rejected(
        snapshotId: 'snap-2',
        reason: 'contract-denied',
      );
      expect(result.accepted, isFalse);
      expect(result.snapshotId, 'snap-2');
      expect(result.rejectedReason, 'contract-denied');
    });

    test('instance field accepted remains distinct from factory', () {
      final accepted = MirrorSnapshotWriteResult.acceptedFor('a');
      final rejected = MirrorSnapshotWriteResult.rejected(
        snapshotId: 'b',
        reason: 'x',
      );
      expect(accepted.accepted, isNot(rejected.accepted));
    });
  });
}
