import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'package:knowme/data/models/astrology_chart_model.dart';

import '../domain/fusion_constants.dart';
import '../domain/fusion_models.dart';
import 'fusion_astrology_backfill.dart';

/// Read-only loader for deterministic results used by Fusion (no writes).
class FusionLoader {
  FusionLoader({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;

  /// Guest-safe: missing auth → empty [FusionInput]. Never throws.
  Future<FusionInput> load({String? uid}) async {
    try {
      final effectiveUid = uid ?? FirebaseAuth.instance.currentUser?.uid;
      if (effectiveUid == null || effectiveUid.isEmpty) {
        return const FusionInput();
      }

      await FusionAstrologyBackfill.ensureMirrored(
        uid: effectiveUid,
        firestore: _firestore,
      );

      final results = _firestore
          .collection('users')
          .doc(effectiveUid)
          .collection('results');

      final astrology = await _loadAstrology(results.doc(FusionResultDocIds.astrology));
      final mbtiMini = await _loadMbti(results.doc(FusionResultDocIds.mbtiMini));
      final cognitive =
          await _loadMbti(results.doc(FusionResultDocIds.mbtiCognitive));

      return FusionInput(
        astrologyResult: astrology,
        mbtiMiniResult: mbtiMini,
        cognitiveResult: cognitive,
      );
    } catch (_) {
      return const FusionInput();
    }
  }

  Future<AstrologyChartModel?> _loadAstrology(
    DocumentReference<Map<String, dynamic>> ref,
  ) async {
    try {
      final snap = await ref.get();
      if (!snap.exists) return null;
      final data = snap.data();
      if (data == null || data.isEmpty) return null;
      return AstrologyChartModel.fromMap(data);
    } catch (_) {
      return null;
    }
  }

  Future<MbtiTraitsResult?> _loadMbti(
    DocumentReference<Map<String, dynamic>> ref,
  ) async {
    try {
      final snap = await ref.get();
      if (!snap.exists) return null;
      final data = snap.data();
      if (data == null || data.isEmpty) return null;
      final parsed = MbtiTraitsResult.fromFirestore(data);
      return parsed.traits.isEmpty ? null : parsed;
    } catch (_) {
      return null;
    }
  }
}
