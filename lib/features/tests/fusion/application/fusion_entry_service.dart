import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:knowme/services/astrology_firestore_service.dart';

import 'fusion_lens_loader.dart';
import 'fusion_loader.dart';

/// Read-only Home entry availability for Fusion Result V1 (no fusion logic).
class FusionEntryState {
  const FusionEntryState({required this.canOpen});

  final bool canOpen;
}

class FusionEntryService {
  FusionEntryService({
    FusionLoader? fusionLoader,
    FusionLensLoader? lensLoader,
    AstrologyFirestoreService? astrologyService,
    FirebaseFirestore? firestore,
  })  : _fusionLoader = fusionLoader ?? FusionLoader(),
        _lensLoader = lensLoader ?? FusionLensLoader(),
        _astrologyService = astrologyService ?? AstrologyFirestoreService(),
        _firestore = firestore ?? FirebaseFirestore.instance;

  final FusionLoader _fusionLoader;
  final FusionLensLoader _lensLoader;
  final AstrologyFirestoreService _astrologyService;
  final FirebaseFirestore _firestore;

  Future<FusionEntryState> evaluate(String uid) async {
    if (uid.isEmpty) {
      return const FusionEntryState(canOpen: false);
    }

    final fusionInput = await _fusionLoader.load(uid: uid);

    var hasAstrology = fusionInput.astrologyResult != null;
    if (!hasAstrology) {
      hasAstrology =
          await _astrologyService.getWesternNatalChart(uid) != null;
    }
    if (!hasAstrology) {
      hasAstrology = await _isAstrologyReadyFromProfile(uid);
    }

    final lensInput = await _lensLoader.load(uid: uid);
    final canOpen = hasAstrology ||
        fusionInput.hasAny ||
        lensInput.lenses.isNotEmpty;

    return FusionEntryState(canOpen: canOpen);
  }

  Future<bool> _isAstrologyReadyFromProfile(String uid) async {
    try {
      final doc = await _firestore
          .collection('users')
          .doc(uid)
          .collection('profile')
          .doc('main')
          .get();
      final data = doc.data();
      if (data == null) return false;

      final hasBirthDate =
          (data['birthDate'] as String?)?.trim().isNotEmpty == true;
      final hasBirthTime =
          (data['birthTime'] as String?)?.trim().isNotEmpty == true;
      final latitude = data['latitude'];
      final longitude = data['longitude'];
      final hasLocation = latitude is num && longitude is num;
      return hasBirthDate && hasBirthTime && hasLocation;
    } catch (_) {
      return false;
    }
  }
}
