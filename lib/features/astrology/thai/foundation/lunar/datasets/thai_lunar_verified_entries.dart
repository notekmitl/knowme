import '../models/thai_lunar_lookup_key.dart';
import '../models/thai_lunar_record.dart';

/// Verified golden-case entries only — no synthetic or guessed data.
///
/// Sources: THAI_ASTROLOGY_DOMAIN_VALIDATION_V1.md GC-04, GC-05.
abstract final class ThaiLunarVerifiedEntries {
  static const gc04Horawej1949 = ThaiLunarRecord(
    lookupKey: ThaiLunarLookupKey(
      year: 1949,
      month: 9,
      day: 11,
      hour: 0,
      minute: 15,
    ),
    weekdayNumber: 7,
    lunarMonthNumber: 10,
    zodiacYearIndex: 2,
    provenance: ThaiLunarRecordProvenance.verifiedGoldenCase,
    sourceId: 'GC-04',
    sourceReference:
        'horawej.com Id=538981149 — 11 ก.ย. 2492 00:15, เสาร์ แรม 3 ค่ำ เดือน 10 ปีฉลู',
  );

  static const gc05Sinsaehwang1972 = ThaiLunarRecord(
    lookupKey: ThaiLunarLookupKey(
      year: 1972,
      month: 4,
      day: 4,
      hour: 2,
      minute: 0,
    ),
    weekdayNumber: 2,
    lunarMonthNumber: 5,
    zodiacYearIndex: 1,
    provenance: ThaiLunarRecordProvenance.verifiedGoldenCase,
    sourceId: 'GC-05',
    sourceReference:
        'sinsaehwang.com — 4 เม.ย. 2515 02:00, จันทร์ แรม 5 ค่ำ เดือน 5 ปีชวด',
  );

  static const all = <ThaiLunarRecord>[
    gc04Horawej1949,
    gc05Sinsaehwang1972,
  ];

  static Map<String, ThaiLunarRecord> asCanonicalMap() {
    return {
      for (final entry in all) entry.lookupKey.canonical: entry,
    };
  }
}
