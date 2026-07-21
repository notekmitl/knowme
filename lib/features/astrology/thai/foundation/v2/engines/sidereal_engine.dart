import '../../models/profile_warning.dart';
import '../../models/thai_birth_data.dart';
import '../../engines/lagna_engine.dart';
import '../../engines/lagna_lord_engine.dart';
import '../models/thai_lagna.dart';

/// Sidereal lagna wrapper — delegates to V1 [LagnaEngine] and [LagnaLordEngine].
abstract final class SiderealEngine {
  static SiderealEngineResult calculate(ThaiBirthData birthData) {
    if (!birthData.hasBirthTime) {
      return const SiderealEngineResult(
        warnings: [
          ProfileWarning(
            code: 'MISSING_BIRTH_TIME',
            severity: ProfileWarningSeverity.high,
            message:
                'ไม่มีเวลาเกิด — ไม่สามารถคำนวณลัคนาและเจ้าเรือนลัคนาได้',
            affectedFields: ['lagnaKey', 'lagnaLordKey'],
          ),
        ],
      );
    }

    final lagnaResult = LagnaEngine.calculate(birthData);
    if (lagnaResult == null) {
      return const SiderealEngineResult();
    }

    final lordKey = LagnaLordEngine.resolve(lagnaResult.lagnaKey)!;

    return SiderealEngineResult(
      lagna: ThaiLagna(
        signKey: lagnaResult.lagnaKey,
        lordKey: lordKey,
        siderealDeg: lagnaResult.siderealAscendantDeg,
        signIndex: lagnaResult.signIndex,
      ),
    );
  }
}

class SiderealEngineResult {
  const SiderealEngineResult({
    this.lagna,
    this.warnings = const [],
  });

  final ThaiLagna? lagna;
  final List<ProfileWarning> warnings;
}
