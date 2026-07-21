import 'application/mirror_habit_store.dart';
import 'data/firestore_mirror_habit_store.dart';

/// Phase D — app-wide access to the habit store.
///
/// Defaults to the Firestore-backed, per-user store (which no-ops without auth).
/// Swap [store] in tests or preview for an [InMemoryMirrorHabitStore].
abstract final class MirrorHabit {
  static MirrorHabitStore store = FirestoreMirrorHabitStore();
}
