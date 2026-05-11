import 'package:flutter/material.dart';

import '../../data/models/astrology_chart_model.dart';

import '../../services/astrology_firestore_service.dart';

class AstrologyProvider extends ChangeNotifier {
  final AstrologyFirestoreService _service = AstrologyFirestoreService();

  AstrologyChartModel? _chart;

  bool _isLoading = false;

  String? _error;

  AstrologyChartModel? get chart => _chart;

  bool get isLoading => _isLoading;

  String? get error => _error;

  Future<void> loadChart(String uid) async {
    try {
      _isLoading = true;

      _error = null;

      notifyListeners();

      _chart = await _service.getWesternNatalChart(uid);
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;

      notifyListeners();
    }
  }
}
