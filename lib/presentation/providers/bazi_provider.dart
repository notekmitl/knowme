import 'package:flutter/material.dart';

import '../../data/models/bazi_chart_model.dart';
import '../../services/bazi_api_service.dart';
import '../../services/bazi_firestore_service.dart';

typedef BaziChartLoader = Future<BaziChartModel?> Function(String uid);

typedef BaziGenerateFn = Future<void> Function({
  required String uid,
  required String birthDate,
  required String birthTime,
  required String timezone,
  double? latitude,
  double? longitude,
});

class BaziProvider extends ChangeNotifier {
  BaziProvider({
    BaziFirestoreService? firestoreService,
    BaziChartLoader? loadChartFn,
    BaziGenerateFn? generateBaziFn,
  })  : _loadChartFn = loadChartFn ??
            ((uid) =>
                (firestoreService ?? BaziFirestoreService())
                    .getChineseBaziChart(uid)),
        _generateBaziFn = generateBaziFn ?? BaziApiService.generateBazi;

  final BaziChartLoader _loadChartFn;
  final BaziGenerateFn _generateBaziFn;

  BaziChartModel? _chart;
  bool _isLoading = false;
  String? _error;

  BaziChartModel? get chart => _chart;
  bool get isLoading => _isLoading;
  String? get error => _error;

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

  Future<void> generateBazi({
    required String uid,
    required String birthDate,
    required String birthTime,
    required String timezone,
    double? latitude,
    double? longitude,
  }) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      await _generateBaziFn(
        uid: uid,
        birthDate: birthDate,
        birthTime: birthTime,
        timezone: timezone,
        latitude: latitude,
        longitude: longitude,
      );

      _chart = await _loadChartFn(uid);
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
