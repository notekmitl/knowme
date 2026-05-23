/// House tails — 2–3 deterministic variants per house (hash: planet + sign).
abstract final class AstrologyHouseModifiers {
  static String? forHouse(
    int house,
    String lang, {
    required String planet,
    required String sign,
  }) {
    if (house < 1 || house > 12) return null;
    final variants = _variants[house];
    if (variants == null || variants.isEmpty) return null;
    final idx = _hash('$planet|$sign') % variants.length;
    return lang == 'th' ? variants[idx].th : variants[idx].en;
  }

  static int _hash(String key) {
    var h = 17;
    for (final u in key.codeUnits) {
      h = (h * 31 + u) & 0x7fffffff;
    }
    return h;
  }

  static const _variants = {
    1: [
      _Line(en: ', often in first impressions', th: 'ซึ่งมักเห็นชัดตอนเจอคนใหม่'),
      _Line(en: ', often when meeting someone new', th: 'ซึ่งมักโผล่ตอนคนเพิ่งรู้จักคุณ'),
      _Line(en: ', often in how you show up at first', th: 'ซึ่งมักสะท้อนในภาพแรกที่คนเห็น'),
    ],
    2: [
      _Line(en: ', often around money and what you keep', th: 'ซึ่งมักผูกกับเงินและสิ่งที่เก็บไว้'),
      _Line(en: ', often in what you earn and hold onto', th: 'ซึ่งมักเกี่ยวกับรายได้และสิ่งที่ตั้งใจเก็บ'),
      _Line(en: ', often in material security', th: 'ซึ่งมักแตะเรื่องความมั่นคงทางวัตถุ'),
    ],
    3: [
      _Line(en: ', often in everyday talk', th: 'ซึ่งมักโผล่ในการคุยประจำวัน'),
      _Line(en: ', often in messages and short trips', th: 'ซึ่งมักเห็นในการสื่อสารและจังหวะสั้นๆ'),
      _Line(en: ', often in weekly rhythm', th: 'ซึ่งมักอยู่ในจังหวะชีวิตรายสัปดาห์'),
    ],
    4: [
      _Line(
        en: ', often in what feels familiar and safe',
        th: 'มักเกี่ยวกับสิ่งที่ทำให้รู้สึกคุ้นเคยหรือสบายใจ',
      ),
      _Line(
        en: ', often in emotional roots and what stays close',
        th: 'มักแตะรากทางใจและสิ่งใกล้ชีวิต',
      ),
      _Line(
        en: ', often in your comfort zone when life speeds up',
        th: 'มักเห็นในพื้นที่ที่คุ้นเคยและไม่อยากรีบออก',
      ),
      _Line(
        en: ', often in attachment to what feels near and steady',
        th: 'มักผูกกับสิ่งที่อยู่ใกล้ตัวและทำให้ใจนิ่ง',
      ),
      _Line(
        en: ', often when you return to what steadies you',
        th: 'มักชัดเมื่อได้กลับไปที่ที่รู้สึกมั่น',
      ),
    ],
    5: [
      _Line(en: ', often in romance and play', th: 'ซึ่งมักแสดงในเรื่องรักและความสนุก'),
      _Line(en: ', often in creative joy', th: 'ซึ่งมักโผล่ตอนสร้างสรรค์หรือมีความสุข'),
      _Line(en: ', often in what you share for fun', th: 'ซึ่งมักอยู่ในสิ่งที่อยากแบ่งให้คนอื่น'),
    ],
    6: [
      _Line(en: ', often at work and daily routines', th: 'ซึ่งมักเห็นในงานและกิจวัตรประจำ'),
      _Line(en: ', often in habits and health rhythm', th: 'ซึ่งมักแตะกิจวัตรและสุขภาพประจำวัน'),
      _Line(en: ', often in fixing daily life', th: 'ซึ่งมักโผล่ตอนจัดระเบียบชีวิตให้เดินได้'),
    ],
    7: [
      _Line(
        en: ', often in meeting someone halfway',
        th: 'มักเห็นชัดขึ้นเวลาอยู่ใกล้คนสำคัญ',
      ),
      _Line(
        en: ', often in reading each other and pacing closeness',
        th: 'มักอยู่ในการอ่านใจและจังหวะเข้าหากัน',
      ),
      _Line(
        en: ', often when adjusting to someone close',
        th: 'มักเด่นเมื่อต้องปรับตัวกับคนใกล้',
      ),
      _Line(
        en: ', often with someone important you listen to',
        th: 'มักชัดกับคนที่ต้องฟังกัน',
      ),
      _Line(
        en: ', often when a key person is in the picture',
        th: 'มักแสดงเมื่อมีใครบางคนสำคัญในชีวิต',
      ),
    ],
    8: [
      _Line(en: ', often in trust and shared stakes', th: 'ซึ่งมักเกี่ยวกับความไว้ใจและเรื่องร่วม'),
      _Line(en: ', often in what you share when safe', th: 'ซึ่งมักแตะสิ่งที่เปิดเมื่อรู้สึกปลอดภัย'),
      _Line(en: ', often in joint resources', th: 'ซึ่งมักโผล่ในเรื่องที่ต้องเชื่อใจกัน'),
    ],
    9: [
      _Line(en: ', often through beliefs and learning', th: 'ซึ่งมักเชื่อมกับความเชื่อและการเรียนรู้'),
      _Line(en: ', often in travel of the mind', th: 'ซึ่งมักเห็นในการขยายมุมมอง'),
      _Line(en: ', often in meaning and study', th: 'ซึ่งมักอยู่ในเรื่องความหมายและการศึกษา'),
    ],
    10: [
      _Line(en: ', often in career and public role', th: 'ซึ่งมักสะท้อนในทางการงานและบทบาท'),
      _Line(en: ', often in reputation and direction', th: 'ซึ่งมักเกี่ยวกับทิศทางและภาพลักษณ์'),
      _Line(en: ', often in responsibility you carry', th: 'ซึ่งมักโผล่ในหน้าที่ที่รับมา'),
    ],
    11: [
      _Line(en: ', often through friends and community', th: 'ซึ่งมักปรากฏผ่านเพื่อนและกลุ่ม'),
      _Line(en: ', often in networks and hopes', th: 'ซึ่งมักอยู่ในเครือข่ายและความหวังต่ออนาคต'),
      _Line(en: ', often in collective goals', th: 'ซึ่งมักแตะเป้าหมายร่วมกับคนรอบข้าง'),
    ],
    12: [
      _Line(
        en: ', often in time spent understanding yourself',
        th: 'มักเป็นเรื่องที่ใช้เวลาเข้าใจตัวเอง',
      ),
      _Line(
        en: ', often clearer when you are alone',
        th: 'ค่อยๆ ชัดขึ้นเมื่ออยู่ลำพัง',
      ),
      _Line(
        en: ', often in thoughts you do not need to say aloud',
        th: 'อาจเกิดขึ้นเงียบๆ ในพื้นที่ส่วนตัว',
      ),
      _Line(
        en: ', often in quiet time you keep for yourself',
        th: 'มักซ่อนในเวลาที่ได้อยู่กับตัวเอง',
      ),
      _Line(
        en: ', often slower to show than people expect',
        th: 'มักโผล่ช้ากว่าที่คนอื่นสังเกต',
      ),
    ],
  };
}

class _Line {
  const _Line({required this.en, required this.th});
  final String en;
  final String th;
}
