import 'package:cloud_firestore/cloud_firestore.dart';

import '../data/models/astrology_chart_model.dart';

class AstrologyFirestoreService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<AstrologyChartModel?> getWesternNatalChart(String uid) async {
    try {
      final doc = await _firestore
          .collection('users')
          .doc(uid)
          .collection('astrology')
          .doc('western_natal')
          .get();

      if (!doc.exists) {
        return null;
      }

      final data = doc.data();

      if (data == null) {
        return null;
      }

      return AstrologyChartModel.fromMap(data);
    } catch (e) {
      throw Exception('Failed to load astrology chart: $e');
    }
  }
}
