import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../domain/thai_life_map_beta_feedback.dart';

class ThaiLifeMapBetaFeedbackSaveResult {
  const ThaiLifeMapBetaFeedbackSaveResult._({
    required this.success,
    this.error,
  });

  const ThaiLifeMapBetaFeedbackSaveResult.ok() : this._(success: true);

  const ThaiLifeMapBetaFeedbackSaveResult.failure(String error)
    : this._(success: false, error: error);

  final bool success;
  final String? error;
}

/// Persist invited-beta Life Map validation feedback.
///
/// Enforced by `firestore.rules` (invited + own uid). Client checks are UX only.
class ThaiLifeMapBetaFeedbackStore {
  ThaiLifeMapBetaFeedbackStore({
    FirebaseFirestore? firestore,
    FirebaseAuth? auth,
  }) : _firestoreOverride = firestore,
       _authOverride = auth;

  final FirebaseFirestore? _firestoreOverride;
  final FirebaseAuth? _authOverride;

  static const String collectionName = 'thai_life_map_beta_feedback';
  static const String periodSubcollection = 'period_feedback';

  FirebaseFirestore? _db() {
    try {
      return _firestoreOverride ?? FirebaseFirestore.instance;
    } catch (_) {
      return null;
    }
  }

  FirebaseAuth? _auth() {
    try {
      return _authOverride ?? FirebaseAuth.instance;
    } catch (_) {
      return null;
    }
  }

  String? get currentUid => _auth()?.currentUser?.uid;

  DocumentReference<Map<String, dynamic>>? _userDoc(String uid) {
    final db = _db();
    if (db == null) return null;
    return db.collection(collectionName).doc(uid);
  }

  Future<ThaiLifeMapBetaFeedback?> loadOwn() async {
    final uid = currentUid;
    if (uid == null) return null;
    final ref = _userDoc(uid);
    if (ref == null) return null;
    try {
      final snap = await ref.get();
      if (!snap.exists) return null;
      final data = snap.data() ?? const {};
      return ThaiLifeMapBetaFeedback.fromMap(
        _normalizeTimestamps(data),
        userId: uid,
      );
    } catch (_) {
      return null;
    }
  }

  /// Upsert overall scores for the signed-in user (doc id = uid).
  Future<ThaiLifeMapBetaFeedbackSaveResult> upsertOverall(
    ThaiLifeMapBetaFeedback feedback,
  ) async {
    final uid = currentUid;
    if (uid == null || uid != feedback.userId) {
      return const ThaiLifeMapBetaFeedbackSaveResult.failure(
        'ต้องเข้าสู่ระบบด้วยบัญชี invited beta',
      );
    }
    final validationError = ThaiLifeMapBetaFeedback.validate(
      scores: feedback.scores,
      lifeMapRef: feedback.lifeMapRef,
      viewportClass: feedback.viewportClass,
      buildVersion: feedback.buildVersion,
      optionalComment: feedback.optionalComment,
      uxIssues: feedback.uxIssues,
    );
    if (validationError != null) {
      return ThaiLifeMapBetaFeedbackSaveResult.failure(validationError);
    }

    final ref = _userDoc(uid);
    if (ref == null) {
      return const ThaiLifeMapBetaFeedbackSaveResult.failure(
        'ระบบบันทึกข้อมูลยังไม่พร้อมใช้งาน',
      );
    }

    try {
      final existing = await ref.get();
      final now = DateTime.now().toUtc();
      final payload = feedback.toFirestoreMap(
        isCreate: !existing.exists,
        now: now,
      );
      // Convert DateTime → Timestamp for Firestore.
      payload['createdAt'] = existing.exists
          ? (existing.data()?['createdAt'] ?? Timestamp.fromDate(now))
          : Timestamp.fromDate(now);
      payload['updatedAt'] = FieldValue.serverTimestamp();

      await ref.set(payload, SetOptions(merge: true));
      return const ThaiLifeMapBetaFeedbackSaveResult.ok();
    } catch (_) {
      return const ThaiLifeMapBetaFeedbackSaveResult.failure(
        'ไม่สามารถบันทึกได้ กรุณาลองใหม่อีกครั้ง',
      );
    }
  }

  /// Upsert period feedback; [periodId] = `p{index}` to prevent duplicates.
  Future<ThaiLifeMapBetaFeedbackSaveResult> upsertPeriodFeedback({
    required ThaiLifeMapPeriodFeedback feedback,
  }) async {
    final uid = currentUid;
    if (uid == null) {
      return const ThaiLifeMapBetaFeedbackSaveResult.failure(
        'ต้องเข้าสู่ระบบด้วยบัญชี invited beta',
      );
    }
    final validationError = ThaiLifeMapPeriodFeedback.validate(
      periodIndex: feedback.periodIndex,
      category: feedback.category,
      optionalComment: feedback.optionalComment,
    );
    if (validationError != null) {
      return ThaiLifeMapBetaFeedbackSaveResult.failure(validationError);
    }

    final parent = _userDoc(uid);
    if (parent == null) {
      return const ThaiLifeMapBetaFeedbackSaveResult.failure(
        'ระบบบันทึกข้อมูลยังไม่พร้อมใช้งาน',
      );
    }

    try {
      final periodId = 'p${feedback.periodIndex}';
      final payload = feedback.toFirestoreMap(now: DateTime.now().toUtc());
      payload['updatedAt'] = FieldValue.serverTimestamp();
      await parent
          .collection(periodSubcollection)
          .doc(periodId)
          .set(payload, SetOptions(merge: true));
      return const ThaiLifeMapBetaFeedbackSaveResult.ok();
    } catch (_) {
      return const ThaiLifeMapBetaFeedbackSaveResult.failure(
        'ไม่สามารถบันทึกได้ กรุณาลองใหม่อีกครั้ง',
      );
    }
  }

  Future<List<ThaiLifeMapPeriodFeedback>> loadOwnPeriodFeedback() async {
    final uid = currentUid;
    if (uid == null) return const [];
    final parent = _userDoc(uid);
    if (parent == null) return const [];
    try {
      final snap = await parent.collection(periodSubcollection).get();
      return snap.docs
          .map(
            (d) => ThaiLifeMapPeriodFeedback.fromMap(
              _normalizeTimestamps(d.data()),
            ),
          )
          .toList();
    } catch (_) {
      return const [];
    }
  }

  /// Admin-only list (rules: isAdmin). Never used on client for non-admins.
  Future<List<ThaiLifeMapBetaFeedback>> listAllForAdmin({
    int limit = 300,
  }) async {
    final db = _db();
    if (db == null) return const [];
    try {
      final snap = await db.collection(collectionName).limit(limit).get();
      return snap.docs
          .map(
            (d) => ThaiLifeMapBetaFeedback.fromMap(
              _normalizeTimestamps(d.data()),
              userId: d.id,
            ),
          )
          .toList();
    } catch (_) {
      return const [];
    }
  }

  Future<List<ThaiLifeMapPeriodFeedback>> listPeriodFeedbackForAdmin(
    String uid,
  ) async {
    final parent = _userDoc(uid);
    if (parent == null) return const [];
    try {
      final snap = await parent.collection(periodSubcollection).get();
      return snap.docs
          .map(
            (d) => ThaiLifeMapPeriodFeedback.fromMap(
              _normalizeTimestamps(d.data()),
            ),
          )
          .toList();
    } catch (_) {
      return const [];
    }
  }

  static Map<String, dynamic> _normalizeTimestamps(Map<String, dynamic> data) {
    final out = Map<String, dynamic>.from(data);
    for (final key in ['createdAt', 'updatedAt']) {
      final v = out[key];
      if (v is Timestamp) {
        out[key] = v.toDate();
      }
    }
    return out;
  }
}
