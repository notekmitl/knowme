import 'constants/thai_calculation_standards.dart';
import 'engines/lagna_engine.dart';
import 'engines/lagna_lord_engine.dart';
import 'engines/mahabhuta_engine.dart';
import 'engines/myanmar_seven_engine.dart';
import 'models/profile_warning.dart';
import 'models/thai_astrology_profile.dart';
import 'models/thai_birth_data.dart';

/// Central orchestrator: Birth Data → ThaiAstrologyProfile.
abstract final class ThaiFoundationEngine {
  static ThaiAstrologyProfile generate(ThaiBirthData birthData) {
    final warnings = <ProfileWarning>[];

    String? lagnaKey;
    String? lagnaLordKey;
    double? siderealAscendantDeg;

    if (!birthData.hasBirthTime) {
      warnings.add(
        const ProfileWarning(
          code: 'MISSING_BIRTH_TIME',
          severity: ProfileWarningSeverity.high,
          message:
              'ไม่มีเวลาเกิด — ไม่สามารถคำนวณลัคนาและเจ้าเรือนลัคนาได้',
          affectedFields: ['lagnaKey', 'lagnaLordKey'],
        ),
      );
    } else {
      final lagna = LagnaEngine.calculate(birthData);
      if (lagna != null) {
        lagnaKey = lagna.lagnaKey;
        siderealAscendantDeg = lagna.siderealAscendantDeg;
        lagnaLordKey = LagnaLordEngine.resolve(lagnaKey);
      }
    }

    final myanmar = MyanmarSevenEngine.calculate(birthData);
    final mahabhuta = MahabhutaEngine.calculate(birthData);
    warnings.addAll(myanmar.warnings);
    warnings.addAll(mahabhuta.warnings);

    return ThaiAstrologyProfile(
      lagnaKey: lagnaKey,
      lagnaLordKey: lagnaLordKey,
      mahabhutaPositionKeys: mahabhuta.mahabhutaPositionKeys,
      myanmarKeys: myanmar.myanmarKeys,
      dominantMyanmarKey: myanmar.dominantMyanmarKey,
      hasBirthTime: birthData.hasBirthTime,
      calculationStandardVersion: ThaiCalculationStandards.version,
      zodiac: ThaiCalculationStandards.zodiac,
      ayanamsa: ThaiCalculationStandards.ayanamsa,
      houseSystem: ThaiCalculationStandards.houseSystem,
      warnings: List<ProfileWarning>.unmodifiable(warnings),
      computedAt: DateTime.now().toUtc(),
      siderealAscendantDeg: siderealAscendantDeg,
      myanmarChartNumbers:
          myanmar.chartNumbers.isEmpty ? null : myanmar.chartNumbers,
      mahabhutaChartNumbers:
          mahabhuta.chartNumbers.isEmpty ? null : mahabhuta.chartNumbers,
      row4Sum: myanmar.row4Sum.isEmpty ? null : myanmar.row4Sum,
    );
  }
}
