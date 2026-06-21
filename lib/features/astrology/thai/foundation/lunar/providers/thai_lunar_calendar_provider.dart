import '../../calendar/thai_lunar_date.dart';
import '../../models/profile_warning.dart';
import '../../models/thai_birth_data.dart';
import '../models/thai_lunar_lookup_key.dart';
import '../repository/thai_lunar_repository.dart';

/// Result of Gregorian → Thai lunar resolution (infrastructure layer).
class ThaiLunarProviderResolution {
  const ThaiLunarProviderResolution({
    this.lunarDate,
    this.warnings = const [],
    this.sourceId,
  });

  final ThaiLunarDate? lunarDate;
  final List<ProfileWarning> warnings;
  final String? sourceId;

  bool get isResolved => lunarDate != null;
}

/// Facade: repository lookup + warning policy for unverified dates.
class ThaiLunarCalendarProvider {
  ThaiLunarCalendarProvider({ThaiLunarRepository? repository})
      : _repository = repository ?? InMemoryThaiLunarRepository();

  final ThaiLunarRepository _repository;

  ThaiLunarRepository get repository => _repository;

  ThaiLunarProviderResolution resolve(ThaiBirthData birthData) {
    final key = ThaiLunarLookupKey.fromDateTime(birthData.localDateTime);
    final record = _repository.lookup(key);

    if (record != null) {
      return ThaiLunarProviderResolution(
        lunarDate: record.toChartDate(),
        sourceId: record.sourceId,
      );
    }

    return ThaiLunarProviderResolution(
      warnings: [
        ProfileWarning(
          code: 'LUNAR_DATE_UNVERIFIED',
          severity: ProfileWarningSeverity.high,
          message:
              'ไม่มีข้อมูลปฏิทินจันทรคติที่ยืนยันแล้วสำหรับวันเกิดนี้ — '
              'ต้องใช้ปฏิทิน 100/150 ปี (TODO) ก่อนคำนวณเลข 7 ตัว',
          affectedFields: [
            'myanmarKeys',
            'mahabhutaPositionKeys',
            'myanmarChartNumbers',
            'mahabhutaChartNumbers',
          ],
        ),
      ],
    );
  }
}
