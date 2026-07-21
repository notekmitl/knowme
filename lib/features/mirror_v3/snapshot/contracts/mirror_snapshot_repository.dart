import 'mirror_snapshot_read_request.dart';
import 'mirror_snapshot_read_result.dart';
import 'mirror_snapshot_write_request.dart';
import 'mirror_snapshot_write_result.dart';

/// MV3.4 repository boundary — orchestrates validation gate + storage contract.
abstract class MirrorSnapshotRepository {
  Future<MirrorSnapshotReadResult> load(MirrorSnapshotReadRequest request);

  Future<MirrorSnapshotWriteResult> save(MirrorSnapshotWriteRequest request);
}
