import 'package:knowme/data/models/astrology_chart_model.dart';

/// Deterministic integrated hero mirror from Western natal big3 (no AI / no API).
/// v1.3 — tension-first, situational wording; hero copy is feature-complete.
abstract final class AstrologyHeroSynthesis {
  static String build(AstrologyChartModel chart, {required String lang}) {
    final isThai = lang == 'th';
    final sun = _normalizeSign(chart.big3['sun']);
    final moon = _normalizeSign(chart.big3['moon']);
    final rising = _normalizeSign(chart.big3['rising']);

    if (sun == null && moon == null && rising == null) {
      return _genericFallback(isThai);
    }

    final hook = _integratedHook(rising, moon, isThai);
    final weave = _sunWeave(sun, rising, moon, isThai);

    final parts = <String>[
      if (hook.isNotEmpty) hook,
      if (weave != null && weave.isNotEmpty) weave,
    ];

    if (parts.isEmpty) return _genericFallback(isThai);
    return parts.take(2).join('\n\n');
  }

  static String? _normalizeSign(dynamic raw) {
    if (raw is! String || raw.trim().isEmpty) return null;
    final s = raw.trim();
    final key = s[0].toUpperCase() + s.substring(1).toLowerCase();
    return _signMeta.containsKey(key) ? key : null;
  }

  static int _variant(String a, String b, int count) {
    if (count <= 1) return 0;
    return (a.hashCode ^ b.hashCode).abs() % count;
  }

  static String _integratedHook(String? rising, String? moon, bool isThai) {
    if (rising != null && moon != null) {
      final pairLine = _highSignalPairTension(rising, moon, isThai);
      if (pairLine != null) return pairLine;

      if (rising == moon) {
        return _pick(isThai, _alignedTension, rising, moon);
      }

      final er = _element(rising);
      final em = _element(moon);
      if (er != em) {
        return _outerInnerTension(er, em, rising, moon, isThai);
      }
      return _sameElementTension(rising, moon, er, isThai);
    }
    if (rising != null) {
      return _pick(isThai, _surfaceTension, rising, rising);
    }
    if (moon != null) {
      return _pick(isThai, _innerTension, moon, moon);
    }
    return '';
  }

  /// A few well-known rising×moon pairs — high relatability without a full matrix.
  static String? _highSignalPairTension(
    String rising,
    String moon,
    bool isThai,
  ) {
    final key = '$rising|$moon';
    final templates = _pairTension[key];
    if (templates == null) return null;
    return _pick(isThai, templates, rising, moon);
  }

  static String _outerInnerTension(
    _Element outer,
    _Element inner,
    String rising,
    String moon,
    bool isThai,
  ) {
    final pair = _orderPair(outer, inner);
    final templates = _tensionByElementPair[pair] ?? _genericOuterInner;
    return _pick(isThai, templates, rising, moon);
  }

  static String _sameElementTension(
    String rising,
    String moon,
    _Element element,
    bool isThai,
  ) {
    final mr = _signMeta[rising]!.$2;
    final mm = _signMeta[moon]!.$2;
    if (mr != mm) {
      final key = _modalityKey(mr, mm);
      final modality = _modalityTension[key];
      if (modality != null) {
        return _pick(isThai, modality, rising, moon);
      }
    }
    final templates = _sameElementHarmony[element] ?? _genericHarmony;
    return _pick(isThai, templates, rising, moon);
  }

  static String? _sunWeave(
    String? sun,
    String? rising,
    String? moon,
    bool isThai,
  ) {
    if (sun == null) return null;
    if (sun == rising && sun == moon) return null;

    final key = _sunWeaveKey(sun, rising, moon);
    final templates = _sunWeaveLines[key] ?? _sunWeaveDefault;
    return _pick(isThai, templates, sun, key);
  }

  static String _sunWeaveKey(String? sun, String? rising, String? moon) {
    if (sun == null) return 'default';
    if (rising != null && sun == rising) return 'sun_equals_rising';
    if (moon != null && sun == moon) return 'sun_equals_moon';
    final es = _element(sun);
    if (rising != null && moon != null) {
      if (es == _element(moon) && es != _element(rising)) {
        return 'sun_hidden_behind_surface';
      }
      if (es == _element(rising) && es != _element(moon)) {
        return 'sun_differs_from_moon';
      }
    }
    if (rising != null && es != _element(rising)) {
      return 'sun_vs_rising';
    }
    return 'sun_motivation';
  }

  static String _pick(bool isThai, List<_Line> templates, String a, String b) {
    if (templates.isEmpty) return _genericFallback(isThai);
    final v = _variant(a, b, templates.length);
    return isThai ? templates[v].th : templates[v].en;
  }

  static String _genericFallback(bool isThai) => isThai
      ? 'บางครั้งคุณอาจรู้สึกว่ามีหลายด้านในตัวเองที่ไม่ได้แสดงออกพร้อมกัน — และนั่นทำให้คุณรู้สึกเป็นคุณจริงๆ'
      : 'Sometimes you may feel like different sides of you show up in different moments — and that mix can feel very personal.';

  static _Element _element(String sign) => _signMeta[sign]!.$1;

  static (_Element, _Element) _orderPair(_Element a, _Element b) {
    return a.index <= b.index ? (a, b) : (b, a);
  }

  static String _modalityKey(_Modality a, _Modality b) {
    return a.index <= b.index ? '${a.name}-${b.name}' : '${b.name}-${a.name}';
  }

  static const _signMeta = {
    'Aries': (_Element.fire, _Modality.cardinal),
    'Taurus': (_Element.earth, _Modality.fixed),
    'Gemini': (_Element.air, _Modality.mutable),
    'Cancer': (_Element.water, _Modality.cardinal),
    'Leo': (_Element.fire, _Modality.fixed),
    'Virgo': (_Element.earth, _Modality.mutable),
    'Libra': (_Element.air, _Modality.cardinal),
    'Scorpio': (_Element.water, _Modality.fixed),
    'Sagittarius': (_Element.fire, _Modality.mutable),
    'Capricorn': (_Element.earth, _Modality.cardinal),
    'Aquarius': (_Element.air, _Modality.fixed),
    'Pisces': (_Element.water, _Modality.mutable),
  };

  // --- High-signal sign pairs (outer × inner) ---

  static const _pairTension = {
    'Libra|Scorpio': [
      _Line(
        en:
            'You may seem calm or agreeable at first, while privately you often think more deeply about motives and emotional honesty than people expect.',
        th:
            'ตอนแรกคุณอาจดูสงบหรือเห็นด้วยง่าย แต่ข้างในมักคิดเรื่องเจตนาและความจริงใจทางใจลึกกว่าที่คนอื่นคาด',
      ),
    ],
    'Gemini|Sagittarius': [
      _Line(
        en:
            'You may come across as open and easy to talk to, but when something feels emotionally important you often take more time before fully opening up.',
        th:
            'คุณอาจดูเปิดและคุยง่าย แต่พอเรื่องทางใจรู้สึกสำคัญ มักใช้เวลามากกว่าที่คิดก่อนจะเปิดใจเต็มที่',
      ),
    ],
    'Gemini|Cancer': [
      _Line(
        en:
            'You may seem light or sociable in groups, yet when trust matters you often need a slower, safer pace than your first impression suggests.',
        th:
            'ในวงสังคมคุณอาจดูเบาและเข้ากับคนง่าย แต่พอเรื่องความไว้ใจสำคัญ มักต้องการจังหวะที่ช้าและปลอดภัยกว่าที่ภาพแรกบอก',
      ),
    ],
    'Capricorn|Sagittarius': [
      _Line(
        en:
            'You may want room to explore and grow, yet still feel a strong pull toward responsibility once something actually matters.',
        th:
            'คุณอาจอยากมีพื้นที่เติบโตและลองสิ่งใหม่ แต่พอเรื่องนั้นสำคัญจริงๆ มักรู้สึกถูกดึงกลับไปที่ความรับผิดชอบ',
      ),
    ],
    'Sagittarius|Capricorn': [
      _Line(
        en:
            'You may come across as upbeat or forward-looking, while in decisions that matter you often weigh duty and long-term impact more than people realize.',
        th:
            'คุณอาจดูมองโลกในแง่ดีหรือก้าวไปข้างหน้า แต่พอต้องตัดสินใจเรื่องสำคัญ มักชั่งความรับผิดชอบและผลระยะยาวมากกว่าที่คนเห็น',
      ),
    ],
  };

  // --- Element outer (rising) × inner (moon) tension ---

  static const _tensionByElementPair = {
    (_Element.air, _Element.water): [
      _Line(
        en:
            'You may come across as open and easy to talk to, but when something feels emotionally important you often take more time before fully opening up.',
        th:
            'คุณอาจดูเปิดและคุยง่าย แต่พอเรื่องทางใจรู้สึกสำคัญ มักใช้เวลามากกว่าที่คิดก่อนจะเปิดใจเต็มที่',
      ),
    ],
    (_Element.air, _Element.fire): [
      _Line(
        en:
            'You may seem easygoing in conversation, yet when a decision actually counts you often care more about honesty and follow-through than people assume.',
        th:
            'คุณอาจดูสบายๆ ตอนคุย แต่พอต้องตัดสินใจเรื่องสำคัญ มักใส่ใจความจริงใจและการลงมือจริงมากกว่าที่คนอื่นคิด',
      ),
    ],
    (_Element.air, _Element.earth): [
      _Line(
        en:
            'You may look flexible on the surface, but once something matters you often want clear boundaries and something you can rely on.',
        th:
            'ภายนอกคุณอาจดูยืดหยุ่น แต่พอเรื่องนั้นสำคัญ มักอยากมีขอบเขตชัดและสิ่งที่พึ่งพาได้',
      ),
    ],
    (_Element.fire, _Element.water): [
      _Line(
        en:
            'You may seem confident or quick to act in the moment, but when trust is on the line you often need more time before you show the full depth of what you feel.',
        th:
            'คุณอาจดูมั่นใจหรือลงมือเร็วในบางจังหวะ แต่พอเรื่องความไว้ใจเข้ามา มักใช้เวลาก่อนจะแสดงความรู้สึกที่ลึกกว่าที่เห็น',
      ),
    ],
    (_Element.fire, _Element.earth): [
      _Line(
        en:
            'You may move fast when something excites you, yet when stakes are real you often slow down to ask what will actually last.',
        th:
            'คุณอาจเดินเร็วเมื่อตื่นเต้นกับเรื่องหนึ่ง แต่พอเดิมพันสูง มักชะลอลงเพื่อถามว่าอะไรยืนระยะจริง',
      ),
    ],
    (_Element.earth, _Element.air): [
      _Line(
        en:
            'You may appear steady and practical in public, while in your own head you often keep turning things over long after the moment has passed.',
        th:
            'ต่อหน้าคนอื่นคุณอาจดูนิ่งและเป็นจริง แต่ในหัวมักยังหมุนเรื่องเดิมต่ออีกนานหลังจังหวะนั้นผ่านไป',
      ),
    ],
    (_Element.earth, _Element.water): [
      _Line(
        en:
            'You may look composed when life is calm, but conflict or emotional pressure can hit you harder than your calm surface suggests.',
        th:
            'ตอนชีวิตสงบคุณอาจดูนิ่ง แต่พอมีความขัดแย้งหรือแรงกดดันทางใจ บางครั้งกระทบคุณแรงกว่าที่ภาพภายนอกบอก',
      ),
    ],
    (_Element.water, _Element.fire): [
      _Line(
        en:
            'You may read as gentle or accommodating at first, but when something you care about is challenged you can become surprisingly firm.',
        th:
            'ตอนแรกคุณอาจดูอ่อนโยนหรือยอมประนีประนอม แต่พอเรื่องที่ใส่ใจถูกท้าทาย บางครั้งคุณหนุนหนักกว่าที่คนคาด',
      ),
    ],
    (_Element.water, _Element.air): [
      _Line(
        en:
            'You may pick up on moods quickly, yet when emotions run high you sometimes need distance to think before you know what you actually want to say.',
        th:
            'คุณอาจรับอารมณ์คนอื่นได้ไว แต่พอความรู้สึกพุ่งแรง บางครั้งต้องถอยมาคิดก่อนจะรู้ว่าอยากพูดอะไรจริงๆ',
      ),
    ],
    (_Element.fire, _Element.air): [
      _Line(
        en:
            'You may come off as direct or spirited, while privately you often keep weighing options longer than people think.',
        th:
            'คุณอาจดูตรงหรือมีพลัง แต่ข้างในมักชั่งทางเลือกนานกว่าที่คนอื่นคิด',
      ),
    ],
  };

  static const _genericOuterInner = [
    _Line(
      en:
          'You may show one side of yourself in public and another when you are off stage — not fake, just not all visible at once.',
      th:
          'คุณอาจมีด้านหนึ่งที่โชว์ต่อโลก และอีกด้านเมื่ออยู่กับตัวเอง — ไม่ใช่เสแสร้ แค่ไม่ได้โชว์พร้อมกัน',
    ),
  ];

  static const _modalityTension = {
    'mutable-fixed': [
      _Line(
        en:
            'You may want room to explore and grow, yet still feel a strong pull toward responsibility once something matters.',
        th:
            'คุณอาจอยากมีพื้นที่เติบโตและลองสิ่งใหม่ แต่พอเรื่องนั้นสำคัญจริงๆ มักรู้สึกถูกดึงกลับไปที่ความรับผิดชอบ',
      ),
    ],
    'cardinal-fixed': [
      _Line(
        en:
            'You may start things easily in the open, but emotionally you often need to feel sure before you fully commit.',
        th:
            'คุณอาจเริ่มอะไรได้ง่ายต่อหน้าคนอื่น แต่ทางใจมักต้องแน่ใจก่อนจะผูกมัดเต็มที่',
      ),
    ],
    'mutable-cardinal': [
      _Line(
        en:
            'You may adapt quickly in the moment, while underneath you often want a clear direction before you settle.',
        th:
            'คุณอาจปรับตัวเร็วในจังหวะนั้น แต่ลึกๆ มักอยากมีทิศทางชัดก่อนจะหยุดลง',
      ),
    ],
  };

  static const _sameElementHarmony = {
    _Element.fire: [
      _Line(
        en:
            'What people see and what moves you often line up — you may not explain everything, but your reactions usually make sense in hindsight.',
        th:
            'สิ่งที่คนเห็นกับสิ่งที่ขับเคลื่อนคุณมักไปในทางเดียวกัน — คุณอาจไม่ได้อธิบายทุกอย่าง แต่ปฏิกิริยามักสมเหตุสมผลเมื่อมองย้อนกลับ',
      ),
    ],
    _Element.earth: [
      _Line(
        en:
            'You may come across as reliable, and that same steadiness often shows up when money, time, or promises are on the line.',
        th:
            'คุณอาจดูพึ่งพาได้ และความนิ่งแบบนั้นมักโผล่เมื่อเรื่องเงิน เวลา หรือสัญญาสำคัญ',
      ),
    ],
    _Element.air: [
      _Line(
        en:
            'You may connect easily with people, and you often need mental space afterward to decide what you actually think.',
        th:
            'คุณอาจเข้ากับคนได้ง่าย และหลังนั้นมักต้องการพื้นที่ในหัวเพื่อตัดสินใจว่าคิดจริงอย่างไร',
      ),
    ],
    _Element.water: [
      _Line(
        en:
            'You may feel things strongly in the moment, and you often need quiet time before you know what you want to do with those feelings.',
        th:
            'คุณอาจรู้สึกแรงในจังหวะนั้น และมักต้องมีเวลาเงียบๆ ก่อนรู้ว่าจะทำอะไรกับความรู้สึกนั้น',
      ),
    ],
  };

  static const _genericHarmony = [
    _Line(
      en:
          'Your outer tone and inner rhythm may match more than people notice — familiar to you, even when others only catch one side.',
      th:
          'โทนภายนอกกับจังหวะข้างในอาจสอดคล้องกันมากกว่าที่คนสังเกต — คุณคุ้นกับมัน แม้คนอื่นเห็นแค่ด้านเดียว',
    ),
  ];

  static const _alignedTension = [
    _Line(
      en:
          'You may not perform two different versions of yourself — when something matters, what shows and what you feel often move together.',
      th:
          'คุณอาจไม่ได้เล่นสองบทบาท — พอเรื่องสำคัญ สิ่งที่แสดงกับสิ่งที่รู้สึกมักไปพร้อมกัน',
    ),
  ];

  static const _surfaceTension = [
    _Line(
      en:
          'People may warm to you quickly, and you often notice more about the room than you let on at first.',
      th:
          'คนอาจเข้าหาคุณได้เร็ว และคุณมักสังเกตบรรยากาศรอบตัวมากกว่าที่แสดงออกตอนแรก',
    ),
  ];

  static const _innerTension = [
    _Line(
      en:
          'When you are alone with your thoughts, you may need honesty from yourself before you know what you want to do next.',
      th:
          'ตอนอยู่กับความคิดเอง คุณอาจต้องการความจริงจากตัวเองก่อนรู้ว่าอยากทำอะไรต่อ',
    ),
  ];

  // --- Sun weave (one short beat max) ---

  static const _sunWeaveLines = {
    'sun_hidden_behind_surface': [
      _Line(
        en:
            'Under that first impression, you may care more about whether something feels fair and real than you let show.',
        th:
            'ใต้ภาพแรกนั้น คุณอาจใส่ใจว่าเรื่องนั้นยุติธรรมและจริงแค่ไหนมากกว่าที่แสดงออก',
      ),
    ],
    'sun_vs_rising': [
      _Line(
        en:
            'In choices that matter, you may follow a quieter standard of your own — not louder, just less visible from the outside.',
        th:
            'ในทางเลือกที่สำคัญ คุณอาจยึดมาตรฐานของตัวเองที่เงียบกว่า — ไม่ได้ดังกว่า แค่คนนอกมองไม่เห็น',
      ),
    ],
    'sun_differs_from_moon': [
      _Line(
        en:
            'What you say you want and what you need to feel safe do not always show up at the same time — that gap can feel very personal.',
        th:
            'สิ่งที่พูดว่าอยากได้กับสิ่งที่ต้องการให้รู้สึกปลอดภัยไม่ได้มาพร้อมกันเสมอ — ช่องว่างนั้นมักรู้สึกเป็นส่วนตัว',
      ),
    ],
    'sun_motivation': [
      _Line(
        en:
            'When you commit, it is often because the situation feels meaningful — not because it is easy.',
        th:
            'พอคุณผูกมัด มักเพราะเรื่องนั้นรู้สึกมีความหมาย — ไม่ใช่เพราะมันง่าย',
      ),
    ],
  };

  static const _sunWeaveDefault = [
    _Line(
      en:
          'There is usually another layer to how you decide — one you feel more than you explain.',
      th:
          'มักมีอีกชั้นในวิธีที่คุณตัดสินใจ — ชั้นที่คุณรู้สึกมากกว่าที่จะอธิบาย',
    ),
  ];
}

enum _Element { fire, earth, air, water }

enum _Modality { cardinal, fixed, mutable }

class _Line {
  const _Line({required this.en, required this.th});
  final String en;
  final String th;
}
