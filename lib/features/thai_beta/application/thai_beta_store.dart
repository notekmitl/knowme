import 'package:cloud_firestore/cloud_firestore.dart';

import '../domain/thai_beta_record.dart';

/// Outcome of a research submission. Never swallows failures: callers must show
/// success (with [researchId]) or an error and let the user retry.
class ThaiBetaSaveResult {
  const ThaiBetaSaveResult._({
    required this.success,
    this.researchId,
    this.docId,
    this.error,
  });

  const ThaiBetaSaveResult.success({required String researchId, String? docId})
      : this._(success: true, researchId: researchId, docId: docId);

  const ThaiBetaSaveResult.failure(String error)
      : this._(success: false, error: error);

  final bool success;
  final String? researchId;
  final String? docId;
  final String? error;
}

/// Read/write access to the `thai_beta_feedback` Firestore collection.
///
/// Public, anonymous submissions are top-level documents. A sequential,
/// human-facing `researchId` (e.g. `TH-00000001`) is allocated atomically with
/// the write via a Firestore transaction on a shared counter. Reads are used by
/// the admin tool only (and gated by `firestore.rules`).
class ThaiBetaStore {
  ThaiBetaStore({FirebaseFirestore? firestore}) : _firestoreOverride = firestore;

  final FirebaseFirestore? _firestoreOverride;

  static const String collectionName = 'thai_beta_feedback';
  static const String counterCollection = 'counters';
  static const String counterDocId = 'thai_research';

  FirebaseFirestore? _db() {
    try {
      return _firestoreOverride ?? FirebaseFirestore.instance;
    } catch (_) {
      return null;
    }
  }

  static String formatResearchId(int seq) => 'TH-${seq.toString().padLeft(8, '0')}';

  /// Whole-seconds session duration, clamped at 0 (never negative).
  static int durationSecondsBetween(DateTime start, DateTime end) {
    final seconds = end.difference(start).inSeconds;
    return seconds < 0 ? 0 : seconds;
  }

  /// Persists a submission, allocating a sequential [ThaiBetaSaveResult.researchId].
  /// Returns a failure result (never throws) when persistence is unavailable or
  /// the write fails — callers surface this to the user.
  Future<ThaiBetaSaveResult> save(ThaiBetaRecord record) async {
    final db = _db();
    if (db == null) {
      return const ThaiBetaSaveResult.failure('ระบบบันทึกข้อมูลยังไม่พร้อมใช้งาน');
    }
    try {
      final col = db.collection(collectionName);
      final counterRef = db.collection(counterCollection).doc(counterDocId);
      final docRef = col.doc();

      final researchId = await db.runTransaction<String>((tx) async {
        final counterSnap = await tx.get(counterRef);
        final current = counterSnap.exists
            ? ((counterSnap.data()?['seq'] as num?)?.toInt() ?? 0)
            : 0;
        final next = current + 1;
        if (counterSnap.exists) {
          tx.update(counterRef, {'seq': next});
        } else {
          tx.set(counterRef, {'seq': next});
        }

        final id = formatResearchId(next);
        final now = DateTime.now();
        final started = record.startedAt ?? now;
        final duration = durationSecondsBetween(started, now);

        tx.set(docRef, {
          ...record.toMap(),
          'researchId': id,
          'startedAt': Timestamp.fromDate(started),
          'submittedAt': FieldValue.serverTimestamp(),
          'durationSeconds': duration,
          'createdAt': FieldValue.serverTimestamp(),
        });
        return id;
      });

      return ThaiBetaSaveResult.success(
        researchId: researchId,
        docId: docRef.id,
      );
    } catch (_) {
      return const ThaiBetaSaveResult.failure(
        'ไม่สามารถบันทึกข้อมูลได้ กรุณาลองใหม่อีกครั้ง',
      );
    }
  }

  /// Number of completed submissions so far (the shared counter's `seq`).
  /// Best-effort: returns null when persistence is unavailable or empty, so the
  /// landing screen can simply omit the figure rather than show 0.
  Future<int?> participantCount() async {
    final db = _db();
    if (db == null) return null;
    try {
      final snap =
          await db.collection(counterCollection).doc(counterDocId).get();
      if (!snap.exists) return null;
      final seq = (snap.data()?['seq'] as num?)?.toInt();
      return (seq == null || seq <= 0) ? null : seq;
    } catch (_) {
      return null;
    }
  }

  /// Most recent submissions, newest first.
  Future<List<ThaiBetaRecord>> recent({int limit = 300}) async {
    final db = _db();
    if (db == null) return const [];
    try {
      final snap = await db
          .collection(collectionName)
          .orderBy('createdAt', descending: true)
          .limit(limit)
          .get();
      return snap.docs.map(_fromDoc).toList();
    } catch (_) {
      return const [];
    }
  }

  Future<ThaiBetaRecord?> getById(String id) async {
    final db = _db();
    if (db == null) return null;
    try {
      final doc = await db.collection(collectionName).doc(id).get();
      if (!doc.exists) return null;
      return _fromDoc(doc);
    } catch (_) {
      return null;
    }
  }

  static DateTime? _asDate(dynamic value) =>
      value is Timestamp ? value.toDate() : null;

  static ThaiBetaRecord _fromDoc(
    DocumentSnapshot<Map<String, dynamic>> doc,
  ) {
    final data = doc.data() ?? const {};
    return ThaiBetaRecord.fromMap(
      data,
      id: doc.id,
      startedAt: _asDate(data['startedAt']),
      submittedAt: _asDate(data['submittedAt']),
      createdAt: _asDate(data['createdAt']),
    );
  }
}
