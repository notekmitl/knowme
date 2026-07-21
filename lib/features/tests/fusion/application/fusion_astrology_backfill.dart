import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:knowme/services/astrology_firestore_service.dart';

import '../domain/fusion_constants.dart';
import 'fusion_astrology_mirror.dart';

/// One-time compatibility: mirror legacy `astrology/western_natal` → `results/astrology`.
abstract final class FusionAstrologyBackfill {
  static Future<void> ensureMirrored({
    required String uid,
    FirebaseFirestore? firestore,
    AstrologyFirestoreService? chartReader,
  }) async {
    if (uid.isEmpty) return;

    try {
      final db = firestore ?? FirebaseFirestore.instance;
      final resultsRef = db
          .collection('users')
          .doc(uid)
          .collection('results')
          .doc(FusionResultDocIds.astrology);

      final existing = await resultsRef.get();
      if (_hasUsableSnapshot(existing.data())) {
        return;
      }

      final chart =
          await (chartReader ?? AstrologyFirestoreService()).getWesternNatalChart(
        uid,
      );
      if (chart == null) return;

      await FusionAstrologyMirror.mirrorFromChart(
        uid: uid,
        chart: chart,
        firestore: db,
      );
    } catch (_) {
      // Non-fatal compatibility path.
    }
  }

  static bool _hasUsableSnapshot(Map<String, dynamic>? data) {
    if (data == null || data.isEmpty) return false;
    final big3 = data['big3'];
    if (big3 is! Map || big3.isEmpty) return false;
    return true;
  }
}
