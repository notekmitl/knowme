import 'package:flutter/material.dart';

import '../models/astrology_result.dart';
import '../services/astrology_service.dart';

class AstrologyProvider extends ChangeNotifier {

  final AstrologyService _service = AstrologyService();

  AstrologyResult? result;

  Future<void> calculate({
    required DateTime birthDateTime,
    double? lat,
    double? lng,
  }) async {

    final res = await _service.calculate(
      birthDateTime: birthDateTime,
      lat: lat,
      lng: lng,
    );

    print("PROVIDER RESULT: ${res.toMap()}");

    result = res;

    notifyListeners();
  }

  void setResult(AstrologyResult newResult) {

    print("SET RESULT: ${newResult.toMap()}");

    result = newResult;

    notifyListeners();
  }
}