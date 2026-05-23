/// Deterministic one-line micro-insights for Big 3 cards (role × sign).
abstract final class AstrologyBig3Microcopy {
  static String forRole(AstroBig3Role role, dynamic signRaw, String lang) {
    final sign = _normalizeSign(signRaw);
    if (sign == null) return _generic(role, lang == 'th');

    final lines = _table[role]?[sign];
    if (lines == null) return _generic(role, lang == 'th');
    return lang == 'th' ? lines.th : lines.en;
  }

  static String? _normalizeSign(dynamic raw) {
    if (raw is! String || raw.trim().isEmpty) return null;
    final s = raw.trim();
    final key = s[0].toUpperCase() + s.substring(1).toLowerCase();
    return _table[AstroBig3Role.sun]!.containsKey(key) ? key : null;
  }

  static String _generic(AstroBig3Role role, bool isThai) {
    return switch (role) {
      AstroBig3Role.sun => isThai
          ? 'มักรู้สึกชัดขึ้นเมื่อสังเกตว่าตัวเองลงมือแบบไหนซ้ำๆ'
          : 'You often see your drive more clearly when you notice what you keep doing.',
      AstroBig3Role.moon => isThai
          ? 'มักรู้ว่าตัวเองสบายใจเมื่อใจได้สิ่งที่ต้องการในวันจริงๆ'
          : 'You often know you are okay when daily life meets an emotional need.',
      AstroBig3Role.rising => isThai
          ? 'คนมักอ่านคุณจากภาพแรกก่อนจะรู้จักลึก'
          : 'People often read you from a first impression before they know you well.',
    };
  }

  static const _table = {
    AstroBig3Role.sun: {
      'Aries': _Line(
        en: 'You often start before you feel fully ready and learn by doing.',
        th: 'มักเริ่มก่อนที่จะพร้อมเต็มที่และเรียนรู้จากการลงมือ',
      ),
      'Taurus': _Line(
        en: 'You often stick with a pace that feels steady rather than rushing change.',
        th: 'มักยึดจังหวะที่มั่นคงมากกว่าการเปลี่ยนแบบเร่งรีบ',
      ),
      'Gemini': _Line(
        en: 'You often want to understand more than one side before you decide.',
        th: 'มักอยากเข้าใจหลายมุมก่อนตัดสินใจอะไร',
      ),
      'Cancer': _Line(
        en: 'You often move toward what feels like home, care, or belonging.',
        th: 'มักขยับเข้าหาสิ่งที่รู้สึกเหมือนบ้าน การดูแล หรือความเป็นเจ้าของ',
      ),
      'Leo': _Line(
        en: 'You often put energy into being seen and sharing what you create.',
        th: 'มักใส่แรงเมื่อได้แสดงตัวและแบ่งสิ่งที่สร้างให้คนอื่น',
      ),
      'Virgo': _Line(
        en: 'You often feel better when something messy becomes workable.',
        th: 'มักรู้สึกดีเมื่อเรื่องยุ่งๆ กลายเป็นทำได้จริง',
      ),
      'Libra': _Line(
        en: 'You often pause to keep things fair before you commit.',
        th: 'มักหยุดชั่งก่อนตัดสินใจเพื่อให้เรื่องยุติธรรม',
      ),
      'Scorpio': _Line(
        en: 'You often go all in once trust is there, not before.',
        th: 'มักใส่เต็มที่เมื่อไว้ใจแล้ว ไม่ใช่ตั้งแต่แรก',
      ),
      'Sagittarius': _Line(
        en: 'You often feel alive when life is moving and there is room to learn.',
        th: 'มักรู้สึกดีเมื่อชีวิตเดินหน้าและมีที่ให้เรียนรู้',
      ),
      'Capricorn': _Line(
        en: 'You often measure yourself by what you build over time.',
        th: 'มักวัดตัวเองจากสิ่งที่สร้างสะสมไปทีละน้อย',
      ),
      'Aquarius': _Line(
        en: 'You often choose your own rules even when others want conformity.',
        th: 'มักเลือกกติกาของตัวเองแม้คนรอบข้างอยากให้เหมือนกัน',
      ),
      'Pisces': _Line(
        en: 'You often follow feeling and imagination more than a fixed plan.',
        th: 'มักตามความรู้สึกและจินตนาการมากกว่าแผนที่ตายตัว',
      ),
    },
    AstroBig3Role.moon: {
      'Aries': _Line(
        en: 'When upset, you may need to move or speak before feelings stall.',
        th: 'เวลาไม่สบายใจ มักต้องขยับหรือพูดก่อนที่ใจจะค้าง',
      ),
      'Taurus': _Line(
        en: 'You often settle when routine, touch, or calm returns.',
        th: 'มักสงบลงเมื่อมีกิจวัตร สัมผัส หรือความเงียบกลับมา',
      ),
      'Gemini': _Line(
        en: 'You often clear mood by talking it out or reframing it in your head.',
        th: 'มักคลายอารมณ์เมื่อได้พูดออกหรือเปลี่ยนมุมในหัว',
      ),
      'Cancer': _Line(
        en: 'You often need to feel held, remembered, or emotionally at home.',
        th: 'มักต้องการรู้สึกถูกกอด ถูกจำ หรือมีบ้านทางใจ',
      ),
      'Leo': _Line(
        en: 'You often need to feel valued, not just liked, by people you care about.',
        th: 'มักต้องการรู้สึกมีค่า ไม่ใช่แค่ถูกชอบ จากคนสำคัญ',
      ),
      'Virgo': _Line(
        en: 'When anxious, you may fix, list, or do something useful to feel steady.',
        th: 'เวลาวิตก มักแก้ จดรายการ หรือทำอะไรที่มีประโยชน์เพื่อให้ใจนิ่ง',
      ),
      'Libra': _Line(
        en: 'You often need the room to feel peaceful, not charged, with others.',
        th: 'มักต้องการบรรยากาศสงบกับคน ไม่ใช่บรรยากาศชาร์จ',
      ),
      'Scorpio': _Line(
        en: 'You often need trust first; feelings deepen after that, not before.',
        th: 'มักต้องการความไว้ใจก่อน พอมีแล้วความรู้สึกมักลึกขึ้น',
      ),
      'Sagittarius': _Line(
        en: 'You often feel better when you can learn or see life moving forward.',
        th: 'มักรู้สึกดีเมื่อได้เรียนรู้หรือเห็นชีวิตเดินไปข้างหน้า',
      ),
      'Capricorn': _Line(
        en: 'You often carry worry quietly and feel safer when you are in control.',
        th: 'มักแบกความกังวลเงียบๆ และสบายใจขึ้นเมื่อจัดการได้',
      ),
      'Aquarius': _Line(
        en: 'You often need space to think before you know what you truly feel.',
        th: 'มักต้องการพื้นที่คิดก่อนจะรู้ว่ารู้สึกจริงแบบไหน',
      ),
      'Pisces': _Line(
        en: 'You often soak up the mood around you and need quiet to reset.',
        th: 'มักรับอารมณ์รอบตัวเข้ามาและต้องการความเงียบเพื่อฟื้น',
      ),
    },
    AstroBig3Role.rising: {
      'Aries': _Line(
        en: 'People may see you as direct, fast to respond, or ready to go.',
        th: 'คนมักเห็นคุณตรงไปตรงมา ตอบเร็ว หรือพร้อมลุย',
      ),
      'Taurus': _Line(
        en: 'People may read you as calm, unhurried, or hard to rush.',
        th: 'คนมักเห็นคุณสงบ ไม่รีบ หรือยากที่จะเร่ง',
      ),
      'Gemini': _Line(
        en: 'People may find you easy to talk to before they know you deeply.',
        th: 'คนมักรู้สึกว่าคุณคุยง่ายก่อนจะรู้จักลึก',
      ),
      'Cancer': _Line(
        en: 'People may sense you are approachable but take time to fully open.',
        th: 'คนมักรู้สึกว่าคุณเข้าหาง่าย แต่คุณอาจใช้เวลาก่อนเปิดใจจริง',
      ),
      'Leo': _Line(
        en: 'People may notice warmth or confidence in your first hello.',
        th: 'คนมักเห็นความอบอุ่นหรือความมั่นใจตั้งแต่ทักทายครั้งแรก',
      ),
      'Virgo': _Line(
        en: 'People may see you as thoughtful, careful, or quietly put together.',
        th: 'คนมักเห็นคุณใส่ใจ รอบคอบ หรือดูเรียบร้อย',
      ),
      'Libra': _Line(
        en: 'People may read you as polite and tuned to the social tone.',
        th: 'คนมักเห็นคุณสุภาพและไวต่อบรรยากาศในวงสนทนา',
      ),
      'Scorpio': _Line(
        en: 'People may sense reserve first and depth only after trust.',
        th: 'คนมักเห็นคุณเก็บตัวก่อน และเห็นความลึกหลังไว้ใจ',
      ),
      'Sagittarius': _Line(
        en: 'People may see openness or a forward-looking tone right away.',
        th: 'คนมักเห็นความเปิดหรือท่าทีมองไปข้างหน้าตั้งแต่แรก',
      ),
      'Capricorn': _Line(
        en: 'People may read you as serious, capable, or quietly responsible.',
        th: 'คนมักเห็นคุณจริงจัง มีความสามารถ หรือรับผิดชอบ',
      ),
      'Aquarius': _Line(
        en: 'People may notice you are a bit different or mentally elsewhere.',
        th: 'คนมักสังเกตว่าคุณแตกต่างหรือมีมุมคิดเป็นของตัวเอง',
      ),
      'Pisces': _Line(
        en: 'People may sense softness and that you are not in a hurry.',
        th: 'คนมักรู้สึกว่าคุณอ่อนโยนและไม่รีบในภาพแรก',
      ),
    },
  };
}

enum AstroBig3Role { sun, moon, rising }

class _Line {
  const _Line({required this.en, required this.th});
  final String en;
  final String th;
}
