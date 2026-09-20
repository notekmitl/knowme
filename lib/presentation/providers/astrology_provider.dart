import 'package:flutter/material.dart';

import '../../data/models/astrology_chart_model.dart';

import '../../services/astrology_firestore_service.dart';

import '../../services/astrology_api_service.dart';

typedef WesternChartLoader = Future<AstrologyChartModel?> Function(String uid);
typedef WesternProviderGenerateFn =
    Future<AstrologyChartModel> Function({
      required String uid,
      required String birthDate,
      required String birthTime,
      required double latitude,
      required double longitude,
    });

class AstrologyProvider extends ChangeNotifier {
  AstrologyProvider({
    AstrologyFirestoreService? firestoreService,
    WesternChartLoader? loadChartFn,
    WesternProviderGenerateFn? generateChartFn,
  }) : _loadChartFn =
           loadChartFn ??
           ((uid) => (firestoreService ?? AstrologyFirestoreService())
               .getWesternNatalChart(uid)),
       _generateChartFn = generateChartFn ?? _defaultGenerateChart;

  final WesternChartLoader _loadChartFn;
  final WesternProviderGenerateFn _generateChartFn;

  AstrologyChartModel? _chart;

  bool _isLoading = false;

  String? _error;

  AstrologyChartModel? get chart => _chart;

  bool get isLoading => _isLoading;

  String? get error => _error;

  void usePreparedChart(AstrologyChartModel chart) {
    _chart = chart;
    _isLoading = false;
    _error = null;
    notifyListeners();
  }

  Future<void> loadChart(String uid) async {
    try {
      _isLoading = true;

      _error = null;

      notifyListeners();

      _chart = await _loadChartFn(uid);
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

      _chart = await _generateChartFn(
        uid: uid,
        birthDate: birthDate,
        birthTime: birthTime,
        latitude: latitude,
        longitude: longitude,
      );
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;

      notifyListeners();
    }
  }

  static Future<AstrologyChartModel> _defaultGenerateChart({
    required String uid,
    required String birthDate,
    required String birthTime,
    required double latitude,
    required double longitude,
  }) {
    return AstrologyApiService.generateChart(
      uid: uid,
      birthDate: birthDate,
      birthTime: birthTime,
      latitude: latitude,
      longitude: longitude,
    );
  }
}
