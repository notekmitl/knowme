import '../models/thai_lunar_lookup_key.dart';
import 'thai_golden_case.dart';

/// Published golden cases — see `test/fixtures/lunar_references.yaml`.
abstract final class ThaiGoldenCases {
  static final all = <ThaiGoldenCase>[
    // --- พรหมชาติ (dooasia.com) — row4 published ---
    ThaiGoldenCase(
      id: 'GC-01',
      source:
          'http://horoscope.dooasia.com/phommachat/phommachath014c001.shtml — ตัวอย่างที่ 1',
      weekdayNumber: 1,
      lunarMonthNumber: 2,
      zodiacYearIndex: 3,
      expectedRow4: [6, 9, 12, 15, 18, 14, 10],
      row4Source: ThaiGoldenRow4Source.published,
      boundaryTags: ['january', 'ordinary'],
      notes: ['อาทิตย์ เดือนยี่(มกราคม) ปีขาด(3)'],
    ),
    ThaiGoldenCase(
      id: 'GC-02',
      source:
          'http://horoscope.dooasia.com/phommachat/phommachath014c001.shtml — ตัวอย่างที่ 2',
      weekdayNumber: 2,
      lunarMonthNumber: 5,
      zodiacYearIndex: 1,
      expectedRow4: [8, 11, 14, 10, 13, 16, 12],
      row4Source: ThaiGoldenRow4Source.published,
      boundaryTags: ['april', 'zodiac_year_boundary', 'ordinary'],
      notes: ['จันทร์ เดือน 5 ปีชวด — col5 มาตา = 13 per arithmetic'],
    ),
    ThaiGoldenCase(
      id: 'GC-03',
      source:
          'http://horoscope.dooasia.com/phommachat/phommachath014c001.shtml — ตัวอย่างที่ 3',
      weekdayNumber: 5,
      lunarMonthNumber: 9,
      zodiacYearIndex: 12,
      expectedRow4: [12, 15, 18, 7, 10, 13, 9],
      row4Source: ThaiGoldenRow4Source.published,
      boundaryTags: ['september', 'intercalary_month_base', 'ordinary'],
      notes: ['พฤหัส เดือน 9 ปีกุน'],
    ),

    // --- horawej หมอชิต — GC-04 row4 published ---
    ThaiGoldenCase(
      id: 'GC-04',
      source: 'https://www.horawej.com/_m/article/content/content.php?aid=538981149',
      lookupKey: ThaiLunarLookupKey(
        year: 1949,
        month: 9,
        day: 11,
        hour: 0,
        minute: 15,
      ),
      birthDate: DateTime(1949, 9, 11, 0, 15),
      weekdayNumber: 7,
      lunarMonthNumber: 10,
      zodiacYearIndex: 2,
      expectedRow4: [12, 8, 11, 14, 17, 13, 9],
      row4Source: ThaiGoldenRow4Source.published,
      boundaryTags: ['september', 'before_0600', 'ordinary'],
      notes: ['เสาร์ แรม 3 ค่ำ เดือน 10 ปีฉลู — 06:00 boundary example'],
    ),

    // --- sinsaehwang — GC-05 ---
    ThaiGoldenCase(
      id: 'GC-05',
      source:
          'https://sinsaehwang.com/เลข-7-ตัว-4-ฐาน-พื้นฐาน-1/ — 4 เม.ย. 2515 02:00',
      lookupKey: ThaiLunarLookupKey(
        year: 1972,
        month: 4,
        day: 4,
        hour: 2,
        minute: 0,
      ),
      birthDate: DateTime(1972, 4, 4, 2, 0),
      weekdayNumber: 2,
      lunarMonthNumber: 5,
      zodiacYearIndex: 1,
      expectedRow4: [8, 11, 14, 10, 13, 16, 12],
      row4Source: ThaiGoldenRow4Source.arithmeticFromPublishedInputs,
      boundaryTags: ['april', 'songkran_season', 'before_0600', 'zodiac_year_boundary'],
      notes: ['จันทร์ แรม 5 ค่ำ เดือน 5 ปีชวด — matches GC-02 structure'],
    ),

    // --- horawej — uniform rows pedagogical example ---
    ThaiGoldenCase(
      id: 'GC-06',
      source:
          'https://www.horawej.com/_m/article/content/content.php?aid=538977480 — ตัวอย่างดวงครู',
      weekdayNumber: 1,
      lunarMonthNumber: 1,
      zodiacYearIndex: 1,
      expectedRow4: [3, 6, 9, 12, 15, 18, 21],
      row4Source: ThaiGoldenRow4Source.published,
      boundaryTags: ['december', 'lunar_month_boundary', 'ordinary'],
      notes: ['อาทิตย์ เดือนอ้าย/8 ปีชวด/มะแม — all bases start at 1'],
    ),

    // --- พรหมชาติ phommachath016c004 — body chart examples ---
    ThaiGoldenCase(
      id: 'GC-07',
      source:
          'http://horoscope.dooasia.com/phommachat/phommachath016c004.shtml — อังคาร เดือน 1 ปีชวด',
      weekdayNumber: 3,
      lunarMonthNumber: 1,
      zodiacYearIndex: 1,
      expectedRow4: [5, 8, 11, 14, 17, 13, 16],
      row4Source: ThaiGoldenRow4Source.arithmeticFromPublishedInputs,
      boundaryTags: ['december', 'lunar_month_boundary', 'ordinary'],
      notes: ['อังคาร เดือน 1 (ธันวา) ปีชวด'],
    ),
    ThaiGoldenCase(
      id: 'GC-08',
      source:
          'http://horoscope.dooasia.com/phommachat/phommachath016c004.shtml — อังคาร เดือน 6 ปีชวด',
      weekdayNumber: 3,
      lunarMonthNumber: 6,
      zodiacYearIndex: 1,
      expectedRow4: [10, 13, 9, 12, 15, 11, 14],
      row4Source: ThaiGoldenRow4Source.arithmeticFromPublishedInputs,
      boundaryTags: ['june', 'ordinary'],
      notes: ['อังคาร เดือน 6 (พฤษภาคม) ปีชวด'],
    ),

    // --- sinsaehwang — second published gregorian example ---
    ThaiGoldenCase(
      id: 'GC-09',
      source:
          'https://sinsaehwang.com/เลข-7-ตัว-4-ฐาน-พื้นฐาน-1/ — 22 ก.ย. 2510',
      birthDate: DateTime(1967, 9, 22, 12, 0),
      weekdayNumber: 6,
      lunarMonthNumber: 10,
      zodiacYearIndex: 8,
      expectedRow4: [10, 13, 9, 12, 15, 11, 14],
      row4Source: ThaiGoldenRow4Source.arithmeticFromPublishedInputs,
      boundaryTags: ['september', 'ordinary'],
      notes: [
        'ศุกร์ แรม 4 ค่ำ เดือน 10 ปีมะแม — time not published; noon placeholder for chart-only test',
      ],
    ),

    // --- horawej ระวี ก้องวงศ์ — Myanmar-adapted 4-base inputs ---
    ThaiGoldenCase(
      id: 'GC-10',
      source:
          'https://www.horawej.com/index.php?Id=420241&ac=article&lay=show — ตัวอย่างที่ 1',
      weekdayNumber: 5,
      lunarMonthNumber: 2,
      zodiacYearIndex: 1,
      expectedRow4: [8, 11, 14, 10, 13, 16, 12],
      row4Source: ThaiGoldenRow4Source.arithmeticFromPublishedInputs,
      boundaryTags: ['ordinary'],
      notes: ['หญิง วันพฤหัส เดือน 2 ปีชวด — 4-base rows only'],
    ),
    ThaiGoldenCase(
      id: 'GC-11',
      source:
          'https://www.horawej.com/index.php?Id=420241&ac=article&lay=show — ตัวอย่างที่ 2',
      birthDate: DateTime(1964, 4, 25, 9, 0),
      weekdayNumber: 7,
      lunarMonthNumber: 6,
      zodiacYearIndex: 5,
      expectedRow4: [18, 14, 10, 6, 9, 12, 15],
      row4Source: ThaiGoldenRow4Source.arithmeticFromPublishedInputs,
      boundaryTags: ['april', 'songkran_season', 'ordinary'],
      notes: ['เสาร์ เดือน 6 ปีมะโรง — 25 เม.ย. 2507 09:00'],
    ),

    // --- พรหมชาติ ตย.2 inputs × weekday rotation table (same page) ---
    ThaiGoldenCase(
      id: 'GC-12',
      source:
          'phommachath014c001 — weekday table + ตย.2 month/year (เดือน 5 ปีชวด)',
      weekdayNumber: 1,
      lunarMonthNumber: 5,
      zodiacYearIndex: 1,
      expectedRow4: [7, 10, 13, 9, 12, 15, 18],
      row4Source: ThaiGoldenRow4Source.arithmeticFromPublishedInputs,
      boundaryTags: ['ordinary'],
      notes: ['อาทิตย์ + เดือน 5 + ชวด — pedagogy combo from same source'],
    ),
    ThaiGoldenCase(
      id: 'GC-13',
      source:
          'phommachath014c001 — weekday table + ตย.2 month/year (เดือน 5 ปีชวด)',
      weekdayNumber: 3,
      lunarMonthNumber: 5,
      zodiacYearIndex: 1,
      expectedRow4: [9, 12, 15, 11, 14, 10, 13],
      row4Source: ThaiGoldenRow4Source.arithmeticFromPublishedInputs,
      boundaryTags: ['ordinary'],
      notes: ['อังคาร + เดือน 5 + ชวด'],
    ),
    ThaiGoldenCase(
      id: 'GC-14',
      source:
          'phommachath014c001 — weekday table + ตย.2 month/year (เดือน 5 ปีชวด)',
      weekdayNumber: 4,
      lunarMonthNumber: 5,
      zodiacYearIndex: 1,
      expectedRow4: [10, 13, 16, 12, 8, 11, 14],
      row4Source: ThaiGoldenRow4Source.arithmeticFromPublishedInputs,
      boundaryTags: ['ordinary'],
      notes: ['พุธ + เดือน 5 + ชวด'],
    ),
    ThaiGoldenCase(
      id: 'GC-15',
      source:
          'phommachath014c001 — weekday table + ตย.2 month/year (เดือน 5 ปีชวด)',
      weekdayNumber: 6,
      lunarMonthNumber: 5,
      zodiacYearIndex: 1,
      expectedRow4: [12, 15, 11, 7, 10, 13, 16],
      row4Source: ThaiGoldenRow4Source.arithmeticFromPublishedInputs,
      boundaryTags: ['ordinary'],
      notes: ['ศุกร์ + เดือน 5 + ชวด'],
    ),
    ThaiGoldenCase(
      id: 'GC-16',
      source:
          'phommachath014c001 — weekday table + ตย.2 month/year (เดือน 5 ปีชวด)',
      weekdayNumber: 7,
      lunarMonthNumber: 5,
      zodiacYearIndex: 1,
      expectedRow4: [13, 9, 12, 8, 11, 14, 17],
      row4Source: ThaiGoldenRow4Source.arithmeticFromPublishedInputs,
      boundaryTags: ['ordinary'],
      notes: ['เสาร์ + เดือน 5 + ชวด'],
    ),

    // --- Month / year boundary coverage from published month-year tables ---
    ThaiGoldenCase(
      id: 'GC-17',
      source: 'phommachath014c001 — เดือน 12 (พฤศจิกายน) + ปีกุน(12)',
      weekdayNumber: 4,
      lunarMonthNumber: 12,
      zodiacYearIndex: 12,
      expectedRow4: [14, 17, 20, 9, 5, 8, 11],
      row4Source: ThaiGoldenRow4Source.arithmeticFromPublishedInputs,
      boundaryTags: ['december', 'zodiac_year_boundary'],
      notes: ['พุธ เดือน 12 ปีกุน — lunar month 12 / year 12 bases'],
    ),
    ThaiGoldenCase(
      id: 'GC-18',
      source: 'phommachath016c004 — อังคาร เดือน 7 ปีมะเส็ง(6)',
      weekdayNumber: 3,
      lunarMonthNumber: 7,
      zodiacYearIndex: 6,
      expectedRow4: [16, 12, 8, 11, 14, 10, 13],
      row4Source: ThaiGoldenRow4Source.arithmeticFromPublishedInputs,
      boundaryTags: ['june', 'ordinary'],
      notes: ['อังคาร เดือน 7 (มิถุนายน) ปีมะเส็ง'],
    ),
    ThaiGoldenCase(
      id: 'GC-19',
      source: 'phommachath014c001 — เดือน 3 (กุมภาพันธ์) + ปีขาล(3)',
      weekdayNumber: 2,
      lunarMonthNumber: 3,
      zodiacYearIndex: 3,
      expectedRow4: [8, 11, 14, 17, 20, 9, 5],
      row4Source: ThaiGoldenRow4Source.arithmeticFromPublishedInputs,
      boundaryTags: ['january', 'ordinary'],
      notes: ['จันทร์ เดือน 3 ปีขาล — February lunar pair'],
    ),
    ThaiGoldenCase(
      id: 'GC-20',
      source: 'phommachath014c001 — เดือน 11 (ตุลาคม) + ปีจอ(11)',
      weekdayNumber: 5,
      lunarMonthNumber: 11,
      zodiacYearIndex: 11,
      expectedRow4: [13, 16, 19, 15, 4, 7, 10],
      row4Source: ThaiGoldenRow4Source.arithmeticFromPublishedInputs,
      boundaryTags: ['ordinary'],
      notes: ['พฤหัส เดือน 11 ปีจอ'],
    ),
  ];

  static List<ThaiGoldenCase> withTag(String tag) {
    return all.where((c) => c.boundaryTags.contains(tag)).toList();
  }

  static ThaiGoldenCase? byId(String id) {
    for (final c in all) {
      if (c.id == id) return c;
    }
    return null;
  }
}
