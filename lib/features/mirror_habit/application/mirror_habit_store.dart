import '../domain/mirror_day_record.dart';

/// Phase D — where day records live.
///
/// The habit loop depends only on this interface. The default production
/// implementation persists per user in Firestore; tests/preview use the
/// in-memory store. Persisting nothing (no auth) is a valid, graceful state.
abstract class MirrorHabitStore {
  /// Recent records (most useful window for streaks/trends), any order.
  Future<List<MirrorDayRecord>> recent({int days = 35});

  /// Idempotent upsert of a single day's record (keyed by its date).
  Future<void> upsert(MirrorDayRecord record);
}

/// In-memory store — deterministic, for tests, preview and no-auth surfaces.
class InMemoryMirrorHabitStore implements MirrorHabitStore {
  InMemoryMirrorHabitStore([List<MirrorDayRecord> seed = const []]) {
    for (final r in seed) {
      _byKey[r.dateKey] = r;
    }
  }

  final Map<String, MirrorDayRecord> _byKey = {};

  @override
  Future<List<MirrorDayRecord>> recent({int days = 35}) async =>
      _byKey.values.toList();

  @override
  Future<void> upsert(MirrorDayRecord record) async {
    _byKey[record.dateKey] = record;
  }
}
