import 'package:cloud_firestore/cloud_firestore.dart';

import '../domain/models/astrology_fusion_snapshot.dart';
import '../domain/models/fusion_snapshot_codec.dart';

abstract class AstrologyFusionRepository {
  static const String resultDocId = 'astrology_fusion';

  Future<AstrologyFusionSnapshot?> loadFusion(String uid);

  Future<void> saveFusion(String uid, AstrologyFusionSnapshot snapshot);

  Future<void> deleteFusion(String uid);
}

class AstrologyFusionRepositoryImpl implements AstrologyFusionRepository {
  AstrologyFusionRepositoryImpl({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;

  DocumentReference<Map<String, dynamic>> _resultRef(String uid) {
    return _firestore
        .collection('users')
        .doc(uid)
        .collection('results')
        .doc(AstrologyFusionRepository.resultDocId);
  }

  @override
  Future<AstrologyFusionSnapshot?> loadFusion(String uid) async {
    final doc = await _resultRef(uid).get();
    if (!doc.exists) return null;

    final data = doc.data();
    if (data == null) return null;

    return FusionSnapshotCodec.fromMap(data);
  }

  @override
  Future<void> saveFusion(String uid, AstrologyFusionSnapshot snapshot) async {
    await _resultRef(uid).set(FusionSnapshotCodec.toMap(snapshot));
  }

  @override
  Future<void> deleteFusion(String uid) async {
    await _resultRef(uid).delete();
  }
}

/// In-memory repository for unit tests.
class InMemoryAstrologyFusionRepository implements AstrologyFusionRepository {
  final Map<String, AstrologyFusionSnapshot> _store = {};

  @override
  Future<void> deleteFusion(String uid) async {
    _store.remove(uid);
  }

  @override
  Future<AstrologyFusionSnapshot?> loadFusion(String uid) async {
    return _store[uid];
  }

  @override
  Future<void> saveFusion(String uid, AstrologyFusionSnapshot snapshot) async {
    _store[uid] = snapshot;
  }
}
