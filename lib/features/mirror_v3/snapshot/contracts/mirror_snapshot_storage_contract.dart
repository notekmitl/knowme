import 'mirror_snapshot_read_request.dart';
import 'mirror_snapshot_read_result.dart';
import 'mirror_snapshot_write_request.dart';
import 'mirror_snapshot_write_result.dart';

/// MV3.4 storage boundary contract — implement in future persistence layer.
abstract class MirrorSnapshotStorageContract {
  Future<MirrorSnapshotReadResult> read(MirrorSnapshotReadRequest request);

  Future<MirrorSnapshotWriteResult> write(MirrorSnapshotWriteRequest request);

  Future<bool> exists(String snapshotId);
}
