/// Final V1 polish: opener variation, phrase cleanup, length clamp (compose-time only).
abstract final class AstrologyPlanetInterpretationPolish {
  static String polishCore(
    String core,
    String lang, {
    required String planet,
    required String sign,
    int? house,
    bool applyOpenerVariation = true,
  }) {
    var text = core;
    text = normalizePhrases(text, lang);
    if (applyOpenerVariation) {
      text = applyOpener(text, planet, sign, house, lang);
    }
    return text;
  }

  /// Strips default subject lead before rhythm patterns reshape the sentence.
  static String stripLead(String body, String lang) =>
      _stripDefaultLead(body.trim(), lang);

  static String clampLength(String text, String lang) {
    final maxWords = lang == 'th' ? 24 : 22;
    var t = text.trim();
    if (t.isEmpty) return t;

    var words = _words(t);
    if (words.length <= maxWords) return _ensurePeriod(t);

    final trimmed = _trimTailFirst(t, lang);
    words = _words(trimmed);
    if (words.length <= maxWords) return _ensurePeriod(trimmed);

    final hard = words.take(maxWords).join(' ');
    return _ensurePeriod(hard);
  }

  // --- Phrase cleanup (~25 pairs per locale) ---

  static String normalizePhrases(String text, String lang) {
    final map = lang == 'th' ? _thPhrases : _enPhrases;
    var out = text;
    for (final e in map.entries) {
      out = out.replaceAll(e.key, e.value);
    }
    return out;
  }

  static const _thPhrases = {
    'คิดเป็นลิงก์และทางเลือก': 'ชอบคิดหลายทางก่อนสรุป',
    'นิยามตัวเองผ่านความคิด': 'มักนิยามตัวตนผ่านไอเดียและบทสนทนา',
    'เติบโตผ่านความลึก': 'เติบโตผ่านความสัมพันธ์ที่ลึกและจริงใจ',
    'เติบโตผ่านขอบฟ้า': 'เติบโตเมื่อได้มองไกลและหาความหมาย',
    'คิดเป็นโครงสร้าง': 'คิดเป็นลำดับขั้นและจังหวะเวลา',
    'คิดเป็นระบบและรูปแบบ': 'มักมองเป็นระบบมากกว่าเรื่องเดียว',
    'แสดงเจตจักน์ผ่านการลงมือ': 'มักลงมือทันทีเมื่ออยากเริ่ม',
    'สร้างตัวตนผ่านความมั่นคง': 'มักสร้างตัวตนจากความมั่นคงที่ค่อยๆ สะสม',
    'เปล่งประกายผ่านการดูแล': 'มักมีพลังเมื่อได้ดูแลคนที่รัก',
    'ขัดเกลาเอกลักษณ์ผ่านการช่วยเหลือ': 'มักรู้สึกดีเมื่อช่วยให้เรื่องราบรื่น',
    'แสวงหาความสมดุลในตัวตน': 'มักอยากให้ตัวเองและคนรอบข้างสมดุล',
    'เก็บความเข้มข้นไว้เงียบๆ': 'มักเก็บอารมณ์เข้มไว้ในใจ',
    'เรียนรู้ขอบเขตในคู่ความสัมพันธ์': 'มักเรียนรู้ขอบเขตในความสัมพันธ์ใกล้ชิด',
    'เรียนรู้ขอบเขตในการสื่อสาร': 'มักเรียนรู้จังหวะการพูดและการฟัง',
    'เรียนรู้ขอบเขตเรื่องความมั่นคง': 'มักเรียนรู้ว่าอะไรสร้างความมั่นคงให้ชีวิต',
    'เรียนรู้ขอบเขตเรื่องการดูแล': 'มักเรียนรู้ขอบเขตกับครอบครัวและอารมณ์เก่าๆ',
    'เรียนรู้ขอบเขตใน ambition': 'มักเรียนรู้ราคาของความทะเยอทะยาน',
    'ลงมือด้วยแรงที่ควบคุมได้': 'มักลงมืออย่างมีแผนและจบสิ่งที่เริ่ม',
    'ลงมือผ่านการเจรจา': 'มักผลักเบาๆ ผ่านการคุยมากกว่าปะทะตรงๆ',
    'ให้ค่าความหลากหลายในความสัมพันธ์': 'มักชอบความสัมพันธ์ที่มีบทสนทนาและพลังทางความคิด',
    'จัดการอารมณ์ผ่านการพูด': 'มักคลายอารมณ์เมื่อได้พูดออกมา',
    'ทางใจคุณอาจต้องการแรงขับ': 'ต้องการแรงขับทางใจ',
    'ในเรื่องรักและรสนิยมคุณอาจอยากได้ประกายไฟ': 'ในเรื่องรักมักชอบความชัดและไม่ค่อยทนความคลุมเครือ',
    'มักเติบโตผ่านความเมตตา': 'มักเติบโตเมื่อได้เห็นใจและสร้างสรรค์',
    'มักเติบโตผ่านการสำรวจ': 'มักเติบโตเมื่อได้เรียนรู้และขยายมุมมอง',
  };

  static const _enPhrases = {
    'think in links and options': 'like to weigh a few angles before you decide',
    'define yourself through ideas': 'often shape who you are through ideas and talk',
    'grow through depth': 'grow through trust and emotional honesty',
    'grow through horizons': 'grow when you can look further ahead',
    'think in structure': 'think in steps, timing, and what still matters later',
    'think in systems and patterns': 'notice patterns that repeat beyond one moment',
    'express will through action': 'show your drive by starting and learning as you go',
    'build identity through steadiness': 'build who you are through steady, reliable pace',
    'shine through care': 'come alive when you care for people who feel like yours',
    'refine identity through service': 'feel most yourself when you make things work better',
    'seek balance in who you are': 'want your inner life and your relationships to feel even',
    'hold intensity quietly': 'keep strong feeling close rather than on display',
    'learn limits in partnership': 'learn boundaries in close relationships',
    'learn limits in communication': 'learn rhythm in how you speak and listen',
    'learn limits around security': 'learn what actually makes life feel stable',
    'learn limits around care': 'learn boundaries with family and old emotional habits',
    'act with controlled force': 'act with patience, focus, and finishing what you start',
    'act through negotiation': 'push gently through talk more than open conflict',
    'value variety in connection': 'value wit and mental chemistry in connection',
    'process mood through talk': 'often settle mood by putting it into words',
    'Emotionally you may need momentum': 'You may need emotional momentum',
    'In love and taste you may want spark': 'In love you may want clarity, not mixed signals',
    'grow through compassion': 'grow through empathy, art, and quiet meaning',
    'grow through exploration': 'grow through learning and widening your view',
    'earn identity through effort': 'build identity through effort and long-term aims',
  };

  // --- Opener variation ---

  static const _thOpeners = [
    'หลายครั้งคุณ',
    'เวลาบางเรื่องสำคัญ คุณมัก',
    'คุณดูจะ',
    'ในบางจังหวะ คุณอาจ',
    'เรื่องนี้มักทำให้คุณ',
    'คุณมักให้ความสำคัญกับ',
    'บางครั้งคุณเลือกที่จะ',
  ];

  static const _enOpeners = [
    'You may often ',
    'At times, you ',
    'You tend to ',
    'When something matters, you often ',
    'You may find yourself ',
    'In some situations, you ',
    'You often ',
  ];

  static String applyOpener(
    String body,
    String planet,
    String sign,
    int? house,
    String lang,
  ) {
    final rest = _stripDefaultLead(body, lang);
    if (rest.isEmpty) return body;

    // ~40% of cards keep a visible opener; rest start on the verb phrase.
    if (!_useVisibleOpener(planet, sign, house)) {
      return _naturalStart(rest, lang);
    }

    final pool = lang == 'th' ? _thOpeners : _enOpeners;
    final idx = _hash(planet, sign, house ?? 0) % pool.length;
    var opener = pool[idx];
    if (!_openerFits(lang, opener, rest)) {
      opener = pool[0];
    }
    return _joinOpener(opener, rest, lang);
  }

  /// Deterministic ~40% opener rate (2/5).
  static bool _useVisibleOpener(String planet, String sign, int? house) {
    return _hash(planet, sign, house ?? 0) % 5 < 2;
  }

  static String _naturalStart(String rest, String lang) {
    if (rest.isEmpty) return rest;
    if (lang == 'th') {
      if (rest.startsWith('มัก') ||
          rest.startsWith('ชอบ') ||
          rest.startsWith('ในเรื่อง')) {
        return rest;
      }
      if (rest.startsWith('ต้องการ') || rest.startsWith('ให้ค่า')) {
        return 'มัก$rest';
      }
      return rest;
    }
    final lower = rest[0].toLowerCase() + rest.substring(1);
    if (lower.startsWith('often ') ||
        lower.startsWith('like ') ||
        lower.startsWith('in love')) {
      return lower;
    }
    return lower;
  }

  static String _stripDefaultLead(String s, String lang) {
    if (lang == 'th') {
      const prefixes = [
        'ในเรื่องรักและรสนิยมคุณอาอาจ',
        'ในเรื่องรักมักชอบความชัดและไม่ค่อยทนความคลุมเครือ',
        'ทางใจคุณอาอาจ',
        'คุณอาอาจ',
      ];
      for (final p in prefixes) {
        if (s.startsWith(p)) return s.substring(p.length).trimLeft();
      }
      return s;
    }

    const prefixes = [
      'In love and taste you may want spark',
      'In love you may want clarity, not mixed signals',
      'Emotionally you may need momentum',
      'Emotionally you may',
      'In love and taste you may',
      'You may often ',
      'You may ',
    ];
    for (final p in prefixes) {
      if (s.startsWith(p)) {
        return s.substring(p.length).trimLeft();
      }
    }
    return s;
  }

  static bool _openerFits(String lang, String opener, String rest) {
    if (lang == 'th') {
      if (opener.contains('ให้ความสำคัญกับ')) {
        return rest.startsWith('ให้ค่า') ||
            rest.startsWith('ต้องการ') ||
            rest.startsWith('แสวง') ||
            rest.startsWith('ชอบ');
      }
      if (opener.contains('ทำให้คุณ')) {
        return !rest.startsWith('เรียนรู้') && !rest.startsWith('มัก');
      }
      if (opener.contains('เลือกที่จะ')) {
        return rest.startsWith('ลงมือ') ||
            rest.startsWith('เก็บ') ||
            rest.startsWith('ยืน');
      }
      return true;
    }

    if (opener.contains('find yourself')) {
      return rest.startsWith('needing') ||
          rest.startsWith('wanting') ||
          rest.startsWith('holding') ||
          rest.startsWith('feeling') ||
          rest.startsWith('learning');
    }
    if (opener.contains('When something matters')) {
      return rest.startsWith('need') ||
          rest.startsWith('want') ||
          rest.startsWith('value') ||
          rest.startsWith('hold');
    }
    return true;
  }

  static String _joinOpener(String opener, String rest, String lang) {
    if (lang == 'en') {
      final r = rest.isEmpty
          ? rest
          : '${rest[0].toLowerCase()}${rest.substring(1)}';
      return '$opener$r'.trim();
    }
    return '$opener$rest'.trim();
  }

  static int _hash(String planet, String sign, int house) {
    var h = 17;
    for (final unit in '$planet|$sign|$house'.codeUnits) {
      h = (h * 31 + unit) & 0x7fffffff;
    }
    return h;
  }

  static List<String> _words(String text) {
    final clean = text.replaceAll(RegExp(r'[.。]$'), '').trim();
    if (clean.isEmpty) return const [];
    return clean.split(RegExp(r'\s+')).where((w) => w.isNotEmpty).toList();
  }

  static String _trimTailFirst(String text, String lang) {
    if (lang == 'th') {
      for (final marker in [
        ' โดยเฉพาะเมื่อคุณ',
        ' ในขณะที่คุณ',
        ' ในจังหวะที่คุณ',
        ' โดยหลายครั้ง',
        ' ซึ่งมัก',
        ' ซึ่งหลายครั้ง',
      ]) {
        final i = text.indexOf(marker);
        if (i > 0) return text.substring(0, i).trim();
      }
    } else {
      for (final marker in [', often quietly', ', often']) {
        final i = text.indexOf(marker);
        if (i > 0) return text.substring(0, i).trim();
      }
    }
    return text;
  }

  static String _ensurePeriod(String text) {
    final t = text.trim();
    if (t.isEmpty) return t;
    return t.endsWith('.') || t.endsWith('。') ? t : '$t.';
  }
}
