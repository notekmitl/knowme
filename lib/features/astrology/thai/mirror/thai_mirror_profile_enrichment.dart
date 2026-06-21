import '../content/models/thai_content_key.dart';
import '../foundation/models/profile_warning.dart';
import '../foundation/models/thai_astrology_profile.dart';
import '../foundation/models/thai_birth_data.dart';

/// Audit findings for Mahabhuta enrichment volume (Population QA V1).
abstract final class ThaiMirrorMahabhutaEnrichmentAudit {
  static const rootCause =
      'ThaiMirrorProfileEnrichment injected all 7 Mahabhuta position keys '
      'whenever Foundation returned empty Myanmar/Mahabhuta keys. '
      'Each key flows through Theme Resolver unchanged and appears in up to 8 '
      'Mirror sections, inflating evidence share to ~76% and boosting '
      'leadership/persistence via repeated Mahabhuta theme mappings.';

  static const recommendation =
      'Inject a small deterministic subset of lens keys at Mirror layer: '
      '2 Mahabhuta positions + 2 Myanmar numbers derived from birth date/weekday. '
      'Do not modify Foundation formulas or Theme scoring weights.';
}

/// Mirror-layer profile enrichment — does not modify Foundation calculations.
///
/// When Myanmar / Mahabhuta keys are missing (e.g. unverified lunar date or no
/// birth time), supplies a **minimal deterministic subset** so Mirror can still
/// produce themes without drowning evidence in 7 Mahabhuta keys.
abstract final class ThaiMirrorProfileEnrichment {
  static const interimMahabhutaKeyCount = 2;
  static const interimMyanmarKeyCount = 2;

  static const _weekdayDominantMyanmar = <String>[
    ThaiContentKeys.myanmarSeven1,
    ThaiContentKeys.myanmarSeven2,
    ThaiContentKeys.myanmarSeven3,
    ThaiContentKeys.myanmarSeven4,
    ThaiContentKeys.myanmarSeven5,
    ThaiContentKeys.myanmarSeven6,
    ThaiContentKeys.myanmarSeven7,
  ];

  static ThaiAstrologyProfile enrich({
    required ThaiAstrologyProfile profile,
    required ThaiBirthData birthData,
  }) {
    if (_hasMyanmarOrMahabhuta(profile)) {
      return profile;
    }

    final thaiWeekday = _thaiWeekdayNumber(birthData.localDateTime);
    final myanmarKeys = _interimMyanmarKeys(
      weekday: thaiWeekday,
      local: birthData.localDateTime,
    );
    final mahabhutaKeys = _interimMahabhutaKeys(
      local: birthData.localDateTime,
      weekday: thaiWeekday,
    );

    return ThaiAstrologyProfile(
      lagnaKey: profile.lagnaKey,
      lagnaLordKey: profile.lagnaLordKey,
      mahabhutaPositionKeys: mahabhutaKeys,
      myanmarKeys: myanmarKeys,
      dominantMyanmarKey: myanmarKeys.first,
      hasBirthTime: profile.hasBirthTime,
      calculationStandardVersion: profile.calculationStandardVersion,
      zodiac: profile.zodiac,
      ayanamsa: profile.ayanamsa,
      houseSystem: profile.houseSystem,
      warnings: List<ProfileWarning>.unmodifiable([
        ...profile.warnings,
        if (!profile.hasBirthTime)
          ProfileWarning(
            code: 'MIRROR_DATE_ONLY_LENS_FALLBACK',
            severity: ProfileWarningSeverity.medium,
            message:
                'ไม่มีเวลาเกิด — ใช้สัญญาณเลข 7 ตัว (${myanmarKeys.length}) '
                'และมหาภูติ (${mahabhutaKeys.length}) จากวันเกิดเป็นฐานสะท้อน '
                '(ไม่รวมลัคนา)',
            affectedFields: ['myanmarKeys', 'mahabhutaPositionKeys'],
          )
        else
          ProfileWarning(
            code: 'MIRROR_INTERIM_LENS_FALLBACK',
            severity: ProfileWarningSeverity.medium,
            message:
                'ใช้สัญญาณเลข 7 ตัว (${myanmarKeys.length}) และมหาภูติ '
                '(${mahabhutaKeys.length}) จากวันเกิดเป็นฐานสะท้อนเพิ่มเติม '
                'เนื่องจากยังไม่มีปฏิทินจันทรคติที่ยืนยันสำหรับวันนี้',
            affectedFields: ['myanmarKeys', 'mahabhutaPositionKeys'],
          ),
      ]),
      computedAt: profile.computedAt,
      siderealAscendantDeg: profile.siderealAscendantDeg,
      myanmarChartNumbers: profile.myanmarChartNumbers,
      mahabhutaChartNumbers: profile.mahabhutaChartNumbers,
      row4Sum: profile.row4Sum,
    );
  }

  static List<String> _interimMyanmarKeys({
    required int weekday,
    required DateTime local,
  }) {
    final primary = _weekdayDominantMyanmar[weekday - 1];
    final secondary =
        _weekdayDominantMyanmar[(local.day + local.month) % 7];
    return _uniqueKeys([primary, secondary]).take(interimMyanmarKeyCount).toList();
  }

  static List<String> _interimMahabhutaKeys({
    required DateTime local,
    required int weekday,
  }) {
    final all = ThaiContentKeys.allMahabhutaPosition;
    final primary = all[(local.day + local.month - 1) % all.length];
    final secondary = all[(weekday + local.day) % all.length];
    return _uniqueKeys([primary, secondary])
        .take(interimMahabhutaKeyCount)
        .toList();
  }

  static List<String> _uniqueKeys(List<String> keys) {
    final seen = <String>{};
    final result = <String>[];
    for (final key in keys) {
      if (seen.add(key)) result.add(key);
    }
    return result;
  }

  static bool _hasMyanmarOrMahabhuta(ThaiAstrologyProfile profile) {
    return profile.myanmarKeys.isNotEmpty ||
        profile.mahabhutaPositionKeys.isNotEmpty;
  }

  static int _thaiWeekdayNumber(DateTime local) {
    return local.weekday == DateTime.sunday ? 1 : local.weekday + 1;
  }
}
