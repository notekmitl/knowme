import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

/// Funnel events for Production Funnel Recovery V2.
enum FunnelTelemetryEvent {
  homeView('home_view'),
  mbtiStart('mbti_start'),
  mbtiComplete('mbti_complete'),
  narrativePreviewSeen('narrative_preview_seen'),
  bigFiveStart('big_five_start'),
  bigFiveComplete('big_five_complete'),
  eqStart('eq_start'),
  eqComplete('eq_complete');

  const FunnelTelemetryEvent(this.storageKey);
  final String storageKey;
}

abstract final class FunnelTelemetry {
  static Future<void> track(FunnelTelemetryEvent event) async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null || uid.isEmpty) return;

    final db = FirebaseFirestore.instance;
    final now = DateTime.now().toUtc();

    await db
        .collection('users')
        .doc(uid)
        .collection('funnel_telemetry')
        .doc(event.storageKey)
        .set({
      'event': event.storageKey,
      'count': FieldValue.increment(1),
      'lastSeenAt': now.toIso8601String(),
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));

    await db
        .collection('users')
        .doc(uid)
        .collection('funnel_telemetry')
        .doc('_events')
        .collection('log')
        .add({
      'event': event.storageKey,
      'at': now.toIso8601String(),
      'createdAt': FieldValue.serverTimestamp(),
    });
  }
}
