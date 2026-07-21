// Post-compose dedupe: surface cleanup + cross-card semantic bucket alternates.
abstract final class AstrologySemanticDedupe {
  static const _big7Order = [
    'sun',
    'moon',
    'mercury',
    'venus',
    'mars',
    'jupiter',
    'saturn',
  ];

  /// Ordered big7 cards — surface pass + bucket collision swap.
  static Map<String, String> dedupePlanetCards(
    Map<String, String> cards,
    String lang,
  ) {
    final usedBuckets = <String>{};
    final out = <String, String>{};

    for (final planet in _big7Order) {
      final raw = cards[planet];
      if (raw == null || raw.trim().isEmpty) continue;

      var text = surfaceCleanup(raw, lang);
      text = _resolveBucketCollisions(
        text,
        planet: planet,
        lang: lang,
        usedBuckets: usedBuckets,
      );
      out[planet] = _ensurePeriod(text);
    }

    for (final e in cards.entries) {
      if (out.containsKey(e.key)) continue;
      out[e.key] = surfaceCleanup(e.value, lang);
    }
    return out;
  }

  // --- Task 2: within-card surface cleanup ---

  static String surfaceCleanup(String text, String lang) {
    var t = text.trim();
    if (t.isEmpty) return t;

    final map = lang == 'th' ? _thSurface : _enSurface;
    for (final e in map.entries) {
      t = t.replaceAll(e.key, e.value);
    }

    if (lang == 'th') {
      t = _dedupeWord(t, 'มัก', 'หลายที');
      t = _dedupeWord(t, 'ค่อยๆ', 'ทีละน้อย');
      t = t.replaceAll('  ', ' ');
    } else {
      t = _dedupeWord(t, 'often ', 'at times ');
      t = t.replaceAll('  ', ' ');
    }
    return t;
  }

  static String _dedupeWord(String text, String word, String replacement) {
    final first = text.indexOf(word);
    if (first < 0) return text;
    final second = text.indexOf(word, first + word.length);
    if (second < 0) return text;
    return text.replaceRange(second, second + word.length, replacement);
  }

  static const _thSurface = {
    'เรื่องบ้านและความรู้สึกมั่นใจ': 'สิ่งที่ทำให้รู้สึกปลอดภัย',
    'เรื่องบ้านและความรู้สึกกับใจ': 'สิ่งที่ทำให้รู้สึกปลอดภัย',
    'ความรู้สึกกับใจ': 'เรื่องที่เก็บไว้ข้างใน',
    'ความรู้สึกมั่นใจ': 'ความรู้สึกปลอดภัย',
    'มุมส่วนตัว': 'มุมที่เก็บไว้ข้างใน',
    'ในมุมส่วนตัว': 'ในพื้นที่ส่วนตัว',
    'เงียบๆ ในมุมส่วนตัว': 'เงียบๆ ในพื้นที่ส่วนตัว',
    'คู่ความสัมพันธ์ใกล้ชิด': 'คนใกล้ตัวที่สำคัญ',
    'ความสัมพันธ์ใกล้ชิด': 'คนใกล้ตัวที่สำคัญ',
    'ค่อยๆ เปิด': 'ทีละน้อยเปิด',
    'ค่อยๆ มอง': 'ทีละน้อยมอง',
  };

  static const _enSurface = {
    'around home and feeling settled': 'where you feel safe and grounded',
    'close partnerships': 'one-to-one bonds',
    'feeling settled': 'feeling grounded',
    'more inward than people see': 'more private than people see',
    'inward than people see': 'private than people see',
  };

  // --- Task 1: cross-card semantic buckets ---

  static String _resolveBucketCollisions(
    String text,
    {required String planet,
    required String lang,
    required Set<String> usedBuckets}) {
    var t = text;
    for (final bucket in _buckets) {
      if (!bucket.matches(t, lang)) continue;

      if (usedBuckets.contains(bucket.id)) {
        t = bucket.applyAlternate(t, planet, lang, usedBuckets.length);
      }
      usedBuckets.add(bucket.id);
    }
    return t;
  }

  static String _ensurePeriod(String text) {
    final t = text.trim();
    if (t.isEmpty) return t;
    return t.endsWith('.') || t.endsWith('。') ? t : '$t.';
  }

  static const _buckets = [
    _Bucket(
      id: 'home_emotion',
      thTriggers: [
        'เรื่องบ้าน',
        'ที่พักใจ',
        'รู้สึกปลอดภัย',
        'รู้สึกมั่นคง',
        'สิ่งใกล้ตัว',
        'เป็นตัวเองมากขึ้น',
      ],
      enTriggers: [
        'around home',
        'feel safe',
        'feeling settled',
        'private base',
        'close and steady',
      ],
      thAlts: [
        'สิ่งที่ทำให้รู้สึกมั่นใจ',
        'พื้นที่ที่รู้สึกเป็นตัวเอง',
        'เรื่องใกล้ตัวที่ทำให้สบายใจ',
      ],
      enAlts: [
        'where you feel grounded',
        'what feels like your base',
        'what helps you feel at home inside',
      ],
    ),
    _Bucket(
      id: 'privacy',
      thTriggers: [
        'มุมที่เก็บไว้ข้างใน',
        'พื้นที่ส่วนตัว',
        'อยู่กับตัวเอง',
        'หมุนเข้าข้างใน',
        'ไม่ค่อยพูดออกมา',
        'ข้างในมากกว่า',
      ],
      enTriggers: [
        'stays private',
        'quiet inner',
        'more private',
        'more inward',
        'not say out loud',
      ],
      thAlts: [
        'เวลาที่ได้อยู่กับตัวเอง',
        'สิ่งที่เก็บไว้ข้างใน',
        'พื้นที่เงียบๆ ของตัวเอง',
      ],
      enAlts: [
        'time you keep to yourself',
        'what you hold inward',
        'your quieter side',
      ],
    ),
    _Bucket(
      id: 'relationship_close',
      thTriggers: [
        'คนใกล้ตัว',
        'ความสัมพันธ์ใกล้ชิด',
        'คู่ความสัมพันธ์',
        'เข้าใจกัน',
        'พบกันครึ่งทาง',
        'คนสำคัญ',
      ],
      enTriggers: [
        'close partnership',
        'one-to-one',
        'meeting halfway',
        'understand each other',
      ],
      thAlts: [
        'เรื่องของคนใกล้ชิด',
        'การปรับตัวกับคนสำคัญ',
        'ความสัมพันธ์ที่ต้องฟังกัน',
      ],
      enAlts: [
        'someone you meet halfway',
        'a bond that needs mutual tuning',
        'people you let close',
      ],
    ),
    _Bucket(
      id: 'trust',
      thTriggers: ['ความไว้ใจ', 'เชื่อใจกัน'],
      enTriggers: ['trust', 'when safe'],
      thAlts: ['การยอมเปิดเมื่อปลอดภัย', 'เรื่องที่ต้องไว้ใจก่อน'],
      enAlts: ['what you share when it feels safe', 'stakes you hold together'],
    ),
  ];
}

class _Bucket {
  const _Bucket({
    required this.id,
    required this.thTriggers,
    required this.enTriggers,
    required this.thAlts,
    required this.enAlts,
  });

  final String id;
  final List<String> thTriggers;
  final List<String> enTriggers;
  final List<String> thAlts;
  final List<String> enAlts;

  bool matches(String text, String lang) {
    final triggers = lang == 'th' ? thTriggers : enTriggers;
    return triggers.any(text.contains);
  }

  String applyAlternate(String text, String planet, String lang, int usedCount) {
    final triggers = lang == 'th' ? thTriggers : enTriggers;
    final alts = lang == 'th' ? thAlts : enAlts;
    if (alts.isEmpty) return text;

    for (final trigger in triggers) {
      if (!text.contains(trigger)) continue;
      final idx = (_dedupeHash('$planet|$id|$usedCount') + triggers.indexOf(trigger)) %
          alts.length;
      return text.replaceFirst(trigger, alts[idx]);
    }
    return text;
  }
}

int _dedupeHash(String key) {
  var h = 17;
  for (final u in key.codeUnits) {
    h = (h * 31 + u) & 0x7fffffff;
  }
  return h;
}
