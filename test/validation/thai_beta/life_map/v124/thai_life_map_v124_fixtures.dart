import 'package:knowme/features/thai_beta/domain/thai_beta_input.dart';

/// Synthetic, deterministic Life Map V1.2.4 accuracy-audit fixtures.
///
/// Names are fictional QA labels only — not real user PII.
/// Coverage is diversity-driven, not “make known look good”.
class ThaiLifeMapV124Fixture {
  const ThaiLifeMapV124Fixture({
    required this.id,
    required this.tag,
    required this.input,
    this.expectWednesdayNightRahu,
    this.notes = '',
  });

  final String id;
  final String tag;
  final ThaiBetaInput input;

  /// When non-null, audit asserts [LifePeriodEngine.isWednesdayNightRahu].
  final bool? expectWednesdayNightRahu;
  final String notes;
}

/// At least 20 charts spanning weekdays, times, provinces, ages, genders.
abstract final class ThaiLifeMapV124Fixtures {
  static final all = <ThaiLifeMapV124Fixture>[
    ThaiLifeMapV124Fixture(
      id: 'F01',
      tag: 'mon_morning_bangkok_male',
      input: ThaiBetaInput(
        firstName: 'Audit',
        lastName: 'F01',
        birthDate: DateTime(1975, 3, 3), // Monday
        birthHour: 7,
        birthMinute: 15,
        province: 'กรุงเทพมหานคร',
        provinceKey: 'bangkok',
        gender: 'ชาย',
      ),
    ),
    ThaiLifeMapV124Fixture(
      id: 'F02',
      tag: 'tue_afternoon_chiangmai_female',
      input: ThaiBetaInput(
        firstName: 'Audit',
        lastName: 'F02',
        birthDate: DateTime(1982, 8, 10), // Tuesday
        birthHour: 14,
        birthMinute: 30,
        province: 'เชียงใหม่',
        provinceKey: 'chiang mai',
        gender: 'หญิง',
      ),
    ),
    ThaiLifeMapV124Fixture(
      id: 'F03',
      tag: 'wed_day_bangkok_mercury',
      input: ThaiBetaInput(
        firstName: 'Audit',
        lastName: 'F03',
        birthDate: DateTime(1972, 4, 5), // Wednesday
        birthHour: 9,
        birthMinute: 15,
        province: 'กรุงเทพมหานคร',
        provinceKey: 'bangkok',
        gender: 'ชาย',
      ),
      expectWednesdayNightRahu: false,
      notes: 'พุธกลางวัน → ไม่ใช่ราหู',
    ),
    ThaiLifeMapV124Fixture(
      id: 'F04',
      tag: 'wed_night_bangkok_rahu',
      input: ThaiBetaInput(
        firstName: 'Audit',
        lastName: 'F04',
        birthDate: DateTime(1972, 4, 5), // Wednesday
        birthHour: 22,
        birthMinute: 30,
        province: 'กรุงเทพมหานคร',
        provinceKey: 'bangkok',
        gender: 'หญิง',
      ),
      expectWednesdayNightRahu: true,
      notes: 'พุธหลังพระอาทิตย์ตก → ราหู',
    ),
    ThaiLifeMapV124Fixture(
      id: 'F05',
      tag: 'thu_evening_khonkaen_other',
      input: ThaiBetaInput(
        firstName: 'Audit',
        lastName: 'F05',
        birthDate: DateTime(1990, 11, 15), // Thursday
        birthHour: 18,
        birthMinute: 45,
        province: 'ขอนแก่น',
        provinceKey: 'khon kaen',
        gender: 'อื่น ๆ',
      ),
    ),
    ThaiLifeMapV124Fixture(
      id: 'F06',
      tag: 'fri_night_phuket_unspecified',
      input: ThaiBetaInput(
        firstName: 'Audit',
        lastName: 'F06',
        birthDate: DateTime(1988, 5, 20), // Friday
        birthHour: 23,
        birthMinute: 10,
        province: 'ภูเก็ต',
        provinceKey: 'phuket',
        gender: 'ไม่ระบุ',
      ),
    ),
    ThaiLifeMapV124Fixture(
      id: 'F07',
      tag: 'sat_dawn_songkhla',
      input: ThaiBetaInput(
        firstName: 'Audit',
        lastName: 'F07',
        birthDate: DateTime(1968, 9, 7), // Saturday
        birthHour: 5,
        birthMinute: 20,
        province: 'สงขลา',
        provinceKey: 'songkhla',
        gender: 'ชาย',
      ),
    ),
    ThaiLifeMapV124Fixture(
      id: 'F08',
      tag: 'sun_noon_udon',
      input: ThaiBetaInput(
        firstName: 'Audit',
        lastName: 'F08',
        birthDate: DateTime(1999, 12, 12), // Sunday
        birthHour: 12,
        birthMinute: 0,
        province: 'อุดรธานี',
        provinceKey: 'udon thani',
        gender: 'หญิง',
      ),
    ),
    ThaiLifeMapV124Fixture(
      id: 'F09',
      tag: 'mon_unknown_time_chiangrai',
      input: ThaiBetaInput(
        firstName: 'Audit',
        lastName: 'F09',
        birthDate: DateTime(1985, 1, 7), // Monday
        birthTimeUnknown: true,
        province: 'เชียงราย',
        provinceKey: 'chiang rai',
        gender: 'ชาย',
      ),
      notes: 'ไม่ทราบเวลา — ห้าม invent ราหู',
    ),
    ThaiLifeMapV124Fixture(
      id: 'F10',
      tag: 'tue_near_midnight_chonburi',
      input: ThaiBetaInput(
        firstName: 'Audit',
        lastName: 'F10',
        birthDate: DateTime(1993, 2, 16), // Tuesday
        birthHour: 23,
        birthMinute: 45,
        province: 'ชลบุรี',
        provinceKey: 'chonburi',
        gender: 'หญิง',
      ),
      notes: 'ใกล้เปลี่ยนวัน',
    ),
    ThaiLifeMapV124Fixture(
      id: 'F11',
      tag: 'wed_pre_sunset_surat',
      input: ThaiBetaInput(
        firstName: 'Audit',
        lastName: 'F11',
        birthDate: DateTime(2001, 1, 3), // Wednesday
        birthHour: 16,
        birthMinute: 0,
        province: 'สุราษฎร์ธานี',
        provinceKey: 'surat thani',
        gender: 'ชาย',
      ),
      expectWednesdayNightRahu: false,
      notes: 'พุธก่อน sunset → ไม่ใช่ราหู',
    ),
    ThaiLifeMapV124Fixture(
      id: 'F12',
      tag: 'wed_post_sunset_korat',
      input: ThaiBetaInput(
        firstName: 'Audit',
        lastName: 'F12',
        birthDate: DateTime(2001, 1, 3), // Wednesday
        birthHour: 19,
        birthMinute: 30,
        province: 'นครราชสีมา',
        provinceKey: 'nakhon ratchasima',
        gender: 'หญิง',
      ),
      expectWednesdayNightRahu: true,
      notes: 'พุธหลัง sunset ต่างจังหวัด',
    ),
    ThaiLifeMapV124Fixture(
      id: 'F13',
      tag: 'elder_1945_kanchanaburi',
      input: ThaiBetaInput(
        firstName: 'Audit',
        lastName: 'F13',
        birthDate: DateTime(1945, 6, 18), // Monday
        birthHour: 10,
        birthMinute: 0,
        province: 'กาญจนบุรี',
        provinceKey: 'kanchanaburi',
        gender: 'ชาย',
      ),
    ),
    ThaiLifeMapV124Fixture(
      id: 'F14',
      tag: 'young_2005_ubon',
      input: ThaiBetaInput(
        firstName: 'Audit',
        lastName: 'F14',
        birthDate: DateTime(2005, 7, 4), // Monday
        birthHour: 15,
        birthMinute: 40,
        province: 'อุบลราชธานี',
        provinceKey: 'ubon ratchathani',
        gender: 'หญิง',
      ),
    ),
    ThaiLifeMapV124Fixture(
      id: 'F15',
      tag: 'mid_1988_bangkok_boundary_am',
      input: ThaiBetaInput(
        firstName: 'Audit',
        lastName: 'F15',
        birthDate: DateTime(1988, 11, 15), // Tuesday
        birthHour: 0,
        birthMinute: 30,
        province: 'กรุงเทพมหานคร',
        provinceKey: 'bangkok',
        gender: 'อื่น ๆ',
      ),
      notes: 'หลังเที่ยงคืนเล็กน้อย',
    ),
    ThaiLifeMapV124Fixture(
      id: 'F16',
      tag: 'thu_early_morning_phuket',
      input: ThaiBetaInput(
        firstName: 'Audit',
        lastName: 'F16',
        birthDate: DateTime(1978, 4, 13), // Thursday
        birthHour: 4,
        birthMinute: 5,
        province: 'ภูเก็ต',
        provinceKey: 'phuket',
        gender: 'ชาย',
      ),
    ),
    ThaiLifeMapV124Fixture(
      id: 'F17',
      tag: 'fri_midday_chiangmai',
      input: ThaiBetaInput(
        firstName: 'Audit',
        lastName: 'F17',
        birthDate: DateTime(1960, 10, 14), // Friday
        birthHour: 11,
        birthMinute: 55,
        province: 'เชียงใหม่',
        provinceKey: 'chiang mai',
        gender: 'หญิง',
      ),
    ),
    ThaiLifeMapV124Fixture(
      id: 'F18',
      tag: 'sat_unknown_time_no_province',
      input: ThaiBetaInput(
        firstName: 'Audit',
        lastName: 'F18',
        birthDate: DateTime(1996, 3, 9), // Saturday
        birthTimeUnknown: true,
        gender: 'ไม่ระบุ',
      ),
      notes: 'ไม่ทราบเวลา + ไม่ระบุจังหวัด',
    ),
    ThaiLifeMapV124Fixture(
      id: 'F19',
      tag: 'sun_evening_songkhla',
      input: ThaiBetaInput(
        firstName: 'Audit',
        lastName: 'F19',
        birthDate: DateTime(2012, 8, 5), // Sunday
        birthHour: 17,
        birthMinute: 20,
        province: 'สงขลา',
        provinceKey: 'songkhla',
        gender: 'ชาย',
      ),
    ),
    ThaiLifeMapV124Fixture(
      id: 'F20',
      tag: 'wed_unknown_time_never_rahu',
      input: ThaiBetaInput(
        firstName: 'Audit',
        lastName: 'F20',
        birthDate: DateTime(1995, 6, 7), // Wednesday
        birthTimeUnknown: true,
        province: 'กรุงเทพมหานคร',
        provinceKey: 'bangkok',
        gender: 'หญิง',
      ),
      expectWednesdayNightRahu: false,
      notes: 'พุธไม่ทราบเวลา → ห้าม invent ราหู',
    ),
    ThaiLifeMapV124Fixture(
      id: 'F21',
      tag: 'tue_late_afternoon_udon',
      input: ThaiBetaInput(
        firstName: 'Audit',
        lastName: 'F21',
        birthDate: DateTime(1970, 5, 12), // Tuesday
        birthHour: 16,
        birthMinute: 50,
        province: 'อุดรธานี',
        provinceKey: 'udon thani',
        gender: 'ชาย',
      ),
    ),
    ThaiLifeMapV124Fixture(
      id: 'F22',
      tag: 'thu_night_kanchanaburi',
      input: ThaiBetaInput(
        firstName: 'Audit',
        lastName: 'F22',
        birthDate: DateTime(2008, 2, 21), // Thursday
        birthHour: 21,
        birthMinute: 5,
        province: 'กาญจนบุรี',
        provinceKey: 'kanchanaburi',
        gender: 'หญิง',
      ),
    ),
  ];

  static ThaiLifeMapV124Fixture byId(String id) =>
      all.firstWhere((f) => f.id == id);
}
