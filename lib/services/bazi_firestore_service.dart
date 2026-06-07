import 'package:cloud_firestore/cloud_firestore.dart';

import '../data/models/bazi_chart_model.dart';

class BaziFirestoreService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<BaziChartModel?> getChineseBaziChart(String uid) async {
    try {
      final doc = await _firestore
          .collection('users')
          .doc(uid)
          .collection('astrology')
          .doc('chinese_bazi')
          .get();

      if (!doc.exists) {
        return null;
      }

      final data = doc.data();
      if (data == null) {
        return null;
      }

      return BaziChartModel.fromMap(data);
    } catch (e) {
      throw Exception('Failed to load BaZi chart: $e');
    }
  }
}
