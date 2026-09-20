import 'package:knowme/data/models/astrology_chart_model.dart';

class WesternReaderSection {
  const WesternReaderSection({
    required this.id,
    required this.title,
    required this.body,
  });

  final String id;
  final String title;
  final String body;
}

abstract final class WesternReaderV2Copy {
  static bool isV2(AstrologyChartModel chart) =>
      chart.version == 'western_natal_v2' &&
      chart.reader['version'] == 'western_reader_th_v2';

  static String overview(AstrologyChartModel chart) {
    final raw = chart.reader['overview'];
    if (raw is Map && raw['th'] is String) {
      return (raw['th'] as String).trim();
    }
    return '';
  }

  static List<WesternReaderSection> sections(AstrologyChartModel chart) {
    final raw = chart.reader['sections'];
    if (raw is! List) return const [];
    return [
      for (final value in raw)
        if (value is Map &&
            value['id'] is String &&
            value['title'] is String &&
            value['body'] is String)
          WesternReaderSection(
            id: (value['id'] as String).trim(),
            title: (value['title'] as String).trim(),
            body: (value['body'] as String).trim(),
          ),
    ];
  }

  static String method(AstrologyChartModel chart) =>
      chart.reader['method'] is String
      ? (chart.reader['method'] as String).trim()
      : '';

  static String disclaimer(AstrologyChartModel chart) =>
      chart.reader['disclaimer'] is String
      ? (chart.reader['disclaimer'] as String).trim()
      : '';

  static Map<String, int> balance(AstrologyChartModel chart, String category) {
    final raw = chart.analysis[category];
    if (raw is! Map || raw['percentages'] is! Map) return const {};
    final percentages = raw['percentages'] as Map;
    return {
      for (final entry in percentages.entries)
        if (entry.key is String && entry.value is num)
          entry.key as String: (entry.value as num).round(),
    };
  }

  static String dominant(AstrologyChartModel chart, String category) {
    final raw = chart.analysis[category];
    if (raw is! Map || raw['dominant'] is! String) return 'balanced';
    return raw['dominant'] as String;
  }

  static List<Map<String, dynamic>> analysisList(
    AstrologyChartModel chart,
    String key,
  ) {
    final raw = chart.analysis[key];
    if (raw is! List) return const [];
    return [
      for (final value in raw)
        if (value is Map) Map<String, dynamic>.from(value),
    ];
  }

  static String signLabel(dynamic raw) => switch ('$raw') {
    'Aries' => 'เมษ',
    'Taurus' => 'พฤษภ',
    'Gemini' => 'เมถุน',
    'Cancer' => 'กรกฎ',
    'Leo' => 'สิงห์',
    'Virgo' => 'กันย์',
    'Libra' => 'ตุลย์',
    'Scorpio' => 'พิจิก',
    'Sagittarius' => 'ธนู',
    'Capricorn' => 'มกร',
    'Aquarius' => 'กุมภ์',
    'Pisces' => 'มีน',
    _ => '—',
  };

  static String planetLabel(dynamic raw) => switch ('$raw') {
    'sun' => 'ดวงอาทิตย์',
    'moon' => 'ดวงจันทร์',
    'mercury' => 'ดาวพุธ',
    'venus' => 'ดาวศุกร์',
    'mars' => 'ดาวอังคาร',
    'jupiter' => 'ดาวพฤหัสบดี',
    'saturn' => 'ดาวเสาร์',
    _ => '$raw',
  };

  static String aspectLabel(dynamic raw) => switch ('$raw') {
    'conjunction' => 'กุมกัน',
    'sextile' => 'ส่งเสริมกัน',
    'square' => 'ทำมุมท้าทาย',
    'trine' => 'ไหลลื่น',
    'opposition' => 'ดึงคนละทิศ',
    _ => '$raw',
  };

  static String elementLabel(String key) => switch (key) {
    'fire' => 'ไฟ',
    'earth' => 'ดิน',
    'air' => 'ลม',
    'water' => 'น้ำ',
    'balanced' => 'สมดุล',
    _ => key,
  };

  static String modalityLabel(String key) => switch (key) {
    'cardinal' => 'เริ่มต้น',
    'fixed' => 'ยืนระยะ',
    'mutable' => 'ปรับตัว',
    'balanced' => 'สมดุล',
    _ => key,
  };

  static String polarityLabel(String key) => switch (key) {
    'positive' => 'แสดงออก',
    'negative' => 'รับเข้า',
    'balanced' => 'สมดุล',
    _ => key,
  };

  static String houseLabel(int house) => switch (house) {
    1 => 'ตัวตนและการเริ่มต้น',
    2 => 'รายได้และคุณค่า',
    3 => 'การสื่อสารและการเรียนรู้',
    4 => 'บ้านและฐานใจ',
    5 => 'ความสร้างสรรค์และความรัก',
    6 => 'งานประจำและระบบชีวิต',
    7 => 'คู่สัมพันธ์และการร่วมมือ',
    8 => 'ทรัพย์สินร่วมและการเปลี่ยนผ่าน',
    9 => 'การศึกษาและโลกที่กว้างขึ้น',
    10 => 'อาชีพและชื่อเสียง',
    11 => 'เครือข่ายและเป้าหมายร่วม',
    12 => 'โลกภายในและการพัก',
    _ => 'เรือน $house',
  };
}
