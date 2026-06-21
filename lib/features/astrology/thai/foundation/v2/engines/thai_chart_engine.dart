import 'dart:convert';

import 'package:crypto/crypto.dart';

import '../../models/profile_warning.dart';
import '../../models/thai_birth_data.dart';
import '../contracts/thai_v2_engine_contract.dart';
import '../models/thai_chart.dart';
import '../models/thai_chart_metadata.dart';
import 'house_engine.dart';
import 'sidereal_engine.dart';

/// Orchestrates V2 chart generation: Birth Data → [ThaiChart].
abstract final class ThaiChartEngine {
  static ThaiChart generate(ThaiBirthData birthData) {
    final metadata = ThaiChartMetadata(
      engineVersion: ThaiV2EngineContract.engineVersion,
      schemaVersion: ThaiV2EngineContract.schemaVersion,
      zodiac: ThaiV2EngineContract.zodiac,
      ayanamsa: ThaiV2EngineContract.ayanamsa,
      houseSystem: ThaiV2EngineContract.houseSystem,
      birthFingerprint: _birthFingerprint(birthData),
      computedAt: DateTime.now().toUtc(),
      hasBirthTime: birthData.hasBirthTime,
    );

    final sidereal = SiderealEngine.calculate(birthData);
    final warnings = List<ProfileWarning>.unmodifiable(sidereal.warnings);

    if (sidereal.lagna == null) {
      return ThaiChart(
        metadata: metadata,
        warnings: warnings,
        placements: const [],
        relationships: const [],
      );
    }

    final houses = HouseEngine.calculate(lagna: sidereal.lagna!);

    return ThaiChart(
      metadata: metadata,
      warnings: warnings,
      lagna: sidereal.lagna,
      houses: houses,
      placements: const [],
      relationships: const [],
    );
  }

  static String _birthFingerprint(ThaiBirthData birthData) {
    final canonical = _birthFingerprintCanonical(birthData);
    return sha256.convert(utf8.encode(canonical)).toString();
  }

  static String _birthFingerprintCanonical(ThaiBirthData birthData) {
    final local = birthData.localDateTime;
    final year = local.year;
    final month = local.month.toString().padLeft(2, '0');
    final day = local.day.toString().padLeft(2, '0');
    final hour = local.hour.toString().padLeft(2, '0');
    final minute = local.minute.toString().padLeft(2, '0');
    final tzOffsetMinutes = birthData.timeZoneOffset.inMinutes;
    final latitude = birthData.latitude;
    final longitude = birthData.longitude;
    final hasBirthTime = birthData.hasBirthTime;

    return '$year-$month-$day|$hour:$minute|'
        '$tzOffsetMinutes|$latitude|$longitude|$hasBirthTime';
  }
}
