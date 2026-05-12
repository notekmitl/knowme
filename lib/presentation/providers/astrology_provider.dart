import 'package:flutter/material.dart';

import '../../data/models/astrology_chart_model.dart';

import '../../services/astrology_firestore_service.dart';

import '../../services/astrology_api_service.dart';

class AstrologyProvider extends ChangeNotifier {
  final AstrologyFirestoreService _firestoreService =
      AstrologyFirestoreService();

  final AstrologyApiService _apiService = AstrologyApiService();

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

      _chart = await _firestoreService.getWesternNatalChart(uid);
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;

      notifyListeners();
    }
  }

  Future<void> generateChart({
    required String uid,
    required String birthDate,
    required String birthTime,
    required double latitude,
    required double longitude,
  }) async {
    try {
      _isLoading = true;

      _error = null;

      notifyListeners();

      await AstrologyApiService.generateChart(
        uid: uid,
        birthDate: birthDate,
        birthTime: birthTime,
        latitude: latitude,
        longitude: longitude,
      );

      _chart = await _firestoreService.getWesternNatalChart(uid);
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;

      notifyListeners();
    }
  }
}
