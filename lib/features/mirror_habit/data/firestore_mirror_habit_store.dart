import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../application/mirror_habit_store.dart';
import '../domain/mirror_day_record.dart';

/// Phase D — per-user daily records at `users/{uid}/mirror_daily/{dateKey}`.
///
/// Follows the app's established Firestore conventions (`users/{uid}/…`,
/// `SetOptions(merge: true)`, `serverTimestamp`) and a `FunnelTelemetry`-style
/// null-uid guard: with no signed-in user it simply no-ops. Firebase is resolved
/// **lazily and defensively** so this store is safe to construct and call even
/// when Firebase is not initialized (tests, preview) — it just persists nothing.
class FirestoreMirrorHabitStore implements MirrorHabitStore {
  FirestoreMirrorHabitStore({FirebaseFirestore? firestore, FirebaseAuth? auth})
      : _firestoreOverride = firestore,
        _authOverride = auth;

  final FirebaseFirestore? _firestoreOverride;
  final FirebaseAuth? _authOverride;

  CollectionReference<Map<String, dynamic>>? _collection() {
    try {
      final auth = _authOverride ?? FirebaseAuth.instance;
      final uid = auth.currentUser?.uid;
      if (uid == null || uid.isEmpty) return null;
      final firestore = _firestoreOverride ?? FirebaseFirestore.instance;
      return firestore.collection('users').doc(uid).collection('mirror_daily');
    } catch (_) {
      // Firebase not available (preview/tests) — persist nothing, safely.
      return null;
    }
  }

  @override
  Future<List<MirrorDayRecord>> recent({int days = 35}) async {
    final col = _collection();
    if (col == null) return const [];
    try {
      final snap =
          await col.orderBy('date', descending: true).limit(days).get();
      return snap.docs.map((d) => MirrorDayRecord.fromMap(d.data())).toList();
    } catch (_) {
      // Habit history is non-critical; never break the Daily Mirror on read.
      return const [];
    }
  }

  @override
  Future<void> upsert(MirrorDayRecord record) async {
    final col = _collection();
    if (col == null) return;
    try {
      await col.doc(record.dateKey).set(
        {
          ...record.toMap(),
          'updatedAt': FieldValue.serverTimestamp(),
        },
        SetOptions(merge: true),
      );
    } catch (_) {
      // Persistence is best-effort; a failed write must not surface to the user.
    }
  }
}
