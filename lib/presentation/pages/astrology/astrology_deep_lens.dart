// “อีกชั้นของตัวคุณ” — deterministic big3 lens (no sign names; complements hero).
abstract final class AstrologyDeepLens {
  static String fromBig3(Map<String, dynamic> big3, String lang) {
    final sun = _norm(big3['sun']);
    final moon = _norm(big3['moon']);
    final rising = _norm(big3['rising']);
    if (sun == null && moon == null && rising == null) return '';

    final isThai = lang == 'th';
    final key = _archetype(sun, moon, rising);
    final pool = _templates[key] ?? _templates['blend']!;
    final idx = _variant(sun ?? 'x', moon ?? 'y', rising ?? 'z', pool.length);
    return isThai ? pool[idx].th : pool[idx].en;
  }

  static String? _norm(dynamic raw) {
    if (raw is! String || raw.trim().isEmpty) return null;
    final s = raw.trim();
    final key = s[0].toUpperCase() + s.substring(1).toLowerCase();
    return _elements.containsKey(key) ? key : null;
  }

  static _El? _el(String? sign) => sign == null ? null : _elements[sign];

  static String _archetype(String? sun, String? moon, String? rising) {
    final er = _el(rising);
    final em = _el(moon);
    final es = _el(sun);

    if (er != null && em != null && er != em) {
      return 'outer_${er.name}_inner_${em.name}';
    }
    if (es != null && em != null && es != em) {
      return 'drive_${es.name}_heart_${em.name}';
    }

    final counts = <_El, int>{};
    for (final e in [es, em, er]) {
      if (e == null) continue;
      counts[e] = (counts[e] ?? 0) + 1;
    }
    if (counts.isEmpty) return 'blend';
    final top = counts.entries.reduce((a, b) => a.value >= b.value ? a : b);
    if (top.value >= 2) return '${top.key.name}_heavy';
    return 'blend';
  }

  static int _variant(String a, String b, String c, int count) {
    if (count <= 1) return 0;
    return (a.hashCode ^ b.hashCode ^ c.hashCode).abs() % count;
  }

  static const _elements = {
    'Aries': _El.fire,
    'Taurus': _El.earth,
    'Gemini': _El.air,
    'Cancer': _El.water,
    'Leo': _El.fire,
    'Virgo': _El.earth,
    'Libra': _El.air,
    'Scorpio': _El.water,
    'Sagittarius': _El.fire,
    'Capricorn': _El.earth,
    'Aquarius': _El.air,
    'Pisces': _El.water,
  };

  static const _templates = {
    'outer_air_inner_water': [
      _Pair(
        en:
            'You may seem easy to talk to, yet when something truly matters you often need time to feel it through before you show more of yourself.',
        th:
            'คุณอาอาจดูเปิดกว้างและคุยง่าย แต่เมื่อเรื่องสำคัญกับใจจริงๆ มักใช้เวลาคิดก่อนค่อยๆ เปิดมากขึ้น',
      ),
      _Pair(
        en:
            'People may read you as light and curious first, while privately you often move slower and care more about emotional safety than you let on.',
        th:
            'หลายครั้งคนอาจเห็นคุณสบายและอยากรู้ แต่ลึกๆ มักใส่ใจความปลอดภัยทางใจมากกว่าที่แสดงออก',
      ),
    ],
    'outer_air_inner_fire': [
      _Pair(
        en:
            'You may come across as flexible and quick-minded, while inside you often want momentum and honesty once you are invested.',
        th:
            'ภายนอกอาจดูยืดหยุ่นและคิดไว แต่ข้างในมักอยากให้เรื่องที่สนใจจริงๆ เดินหน้าและตรงไปตรงมา',
      ),
    ],
    'outer_air_inner_earth': [
      _Pair(
        en:
            'You may seem open and conversational, yet you often prefer practical follow-through and steady ground once a decision is real.',
        th:
            'อาจดูเปิดและชอบคุย แต่พอตัดสินใจจริงมักอยากให้มีขั้นตอนชัดและพื้นที่ที่มั่นใจ',
      ),
    ],
    'outer_fire_inner_water': [
      _Pair(
        en:
            'You may show energy and warmth early, while deeper feelings often need trust and time before they fully surface.',
        th:
            'ตอนแรกอาจดูมีพลังและอบอุ่น แต่ความรู้สึกลึกๆ มักต้องมีความไว้ใจก่อนจึงค่อยๆ ออกมา',
      ),
    ],
    'outer_fire_inner_earth': [
      _Pair(
        en:
            'You may look ready to move and speak up, while privately you often weigh durability, duty, and what will still matter later.',
        th:
            'ภายนอกอาจดูพร้อมลุย แต่ข้างในมักชั่งว่าอะไรยั่งยืนและยังสำคัญในระยะยาว',
      ),
    ],
    'outer_water_inner_fire': [
      _Pair(
        en:
            'You may seem gentle or reserved at first, yet when you care you often act with surprising directness and conviction.',
        th:
            'ตอนแรกอาจดูนุ่มหรือเก็บตัว แต่พอใส่ใจจริงมักลงมือตรงและมั่นใจกว่าที่คนคาด',
      ),
    ],
    'outer_earth_inner_water': [
      _Pair(
        en:
            'You may read as calm and capable on the surface, while much of what moves you stays private until it feels safe.',
        th:
            'ภายนอกอาจดูนิ่งและจัดการได้ดี แต่สิ่งที่ขับใจมักอยู่ในใจจนกว่าจะรู้สึกปลอดภัย',
      ),
    ],
    'outer_earth_inner_fire': [
      _Pair(
        en:
            'You may appear steady and careful first, while inside you often carry strong drive once you commit to a direction.',
        th:
            'อาจดูรอบคอบและมั่นคง แต่ข้างในมักมีแรงขับชัดเมื่อตั้งใจกับทิศทางหนึ่ง',
      ),
    ],
    'drive_fire_heart_water': [
      _Pair(
        en:
            'You may push forward and test limits, yet emotionally you often need closeness and room to feel before you fully open up.',
        th:
            'มักอยากลองและเดินหน้า แต่ทางใจมักต้องการความใกล้ชิดและเวลารู้สึกก่อนเปิดใจเต็มที่',
      ),
    ],
    'drive_air_heart_water': [
      _Pair(
        en:
            'You may like to understand many sides, while what you need inside is often simpler: honesty, rest, and emotional truth.',
        th:
            'มักอยากเข้าใจหลายมุม แต่สิ่งที่ใจต้องการมักตรงกว่า — ความจริงใจ พักใจ และความรู้สึกที่แท้',
      ),
    ],
    'drive_earth_heart_fire': [
      _Pair(
        en:
            'You may build step by step and value reliability, while your feelings can run hotter and more urgent than people assume.',
        th:
            'มักสร้างทีละขั้นและให้ค่าความมั่นคง แต่อารมณ์ข้างในอาจร้อนและเร่งกว่าที่คนเห็น',
      ),
    ],
    'air_heavy': [
      _Pair(
        en:
            'You may live a lot through ideas, talk, and changing angles — and often feel best when life stays mentally alive.',
        th:
            'มักใช้ความคิด การคุย และการมองหลายมุมเป็นส่วนสำคัญของชีวิต และรู้สึกดีเมื่อมีอะไรให้เรียนรู้',
      ),
    ],
    'water_heavy': [
      _Pair(
        en:
            'You may notice mood, tone, and what is unsaid — and often need emotional honesty more than quick fixes.',
        th:
            'มักไวต่อบรรยากาศและสิ่งที่ไม่ได้พูด และมักต้องการความจริงทางใจมากกว่าคำตอบเร็ว',
      ),
    ],
    'fire_heavy': [
      _Pair(
        en:
            'You may move when something inspires you, and often feel drained when momentum stalls or meaning fades.',
        th:
            'มักขยับเมื่อมีแรงบันดาลใจ และมักเหนื่อยเมื่อชีวิตค้างหรือความหมายจางลง',
      ),
    ],
    'earth_heavy': [
      _Pair(
        en:
            'You may trust what you can see, repeat, and improve — and often feel unsettled when plans lack ground.',
        th:
            'มักเชื่อในสิ่งที่ทำซ้ำได้และเห็นผล และมักไม่สบายใจเมื่อแผนไม่มีพื้นที่ยืน',
      ),
    ],
    'blend': [
      _Pair(
        en:
            'Another lens: you may show one tone in public, need something quieter inside, and still carry a core drive that only fully makes sense to you.',
        th:
            'อีกมุมหนึ่งที่อาจสังเกตได้: ภายนอกอาจดูแบบหนึ่ง ข้างในมีความต้องการที่เงียบกว่า และยังมีแรงขับที่คุณเองเข้าใจชัดที่สุด',
      ),
      _Pair(
        en:
            'You may get along easily on the surface, yet when something touches real feeling you often listen inward before you fully explain.',
        th:
            'หลายครั้งคุณอาจเข้ากับคนง่าย แต่เมื่อเรื่องกระทบใจจริงๆ มักฟังตัวเองก่อนจะอธิบายให้คนอื่นเข้าใจ',
      ),
    ],
  };
}

enum _El { fire, earth, air, water }

class _Pair {
  const _Pair({required this.en, required this.th});
  final String en;
  final String th;
}
