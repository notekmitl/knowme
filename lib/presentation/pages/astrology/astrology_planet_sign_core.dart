// Big 7 × 12 planet–sign core meanings (deterministic local coverage).

class _Pair {
  const _Pair(this.en, this.th);
  final String en;
  final String th;
}

abstract final class AstrologyPlanetSignCore {
  static String? core(String planet, String sign, String lang) {
    final p = planet.toLowerCase();
    final pair = _table[p]?[sign];
    if (pair == null) return null;
    return lang == 'th' ? pair.th : pair.en;
  }

  static const _table = <String, Map<String, _Pair>>{
    'sun': {
      'Aries': _Pair(
        r'''You may express will through action — starting, competing, and learning by doing.''',
        r'''คุณอาจแสดงเจตจักน์ผ่านการลงมือ — การเริ่ม การท้าทายตัวเอง และการเรียนรู้จากการทำ''',
      ),
      'Taurus': _Pair(
        r'''You may build identity through steadiness — loyalty to pace, comfort, and what feels reliable.''',
        r'''คุณอาจสร้างตัวตนผ่านความมั่นคง — จังหวะที่พอใจ ความสบาย และสิ่งที่เชื่อถือได้''',
      ),
      'Gemini': _Pair(
        r'''You may define yourself through ideas — curiosity, conversation, and staying mentally mobile.''',
        r'''คุณอาจนิยามตัวเองผ่านความคิด — ความอยากรู้ การพูดคุย และการไม่ยึดมุมเดียว''',
      ),
      'Cancer': _Pair(
        r'''You may shine through care — belonging, memory, and protecting what feels like home.''',
        r'''คุณอาจเปล่งประกายผ่านการดูแล — ความเป็นเจ้าของ ความทรงจำ และการปกป้องสิ่งที่รู้สึกเหมือนบ้าน''',
      ),
      'Leo': _Pair(
        r'''You may want to be seen warmly — creative pride, generosity, and sincere presence.''',
        r'''คุณอาจอยากถูกมองเห็นอย่างอบอุ่น — ความภูมิใจสร้างสรรค์ ความเอื้อ และการแสดงตัวจริงๆ''',
      ),
      'Virgo': _Pair(
        r'''You may refine identity through service — usefulness, detail, and doing things properly.''',
        r'''คุณอาจขัดเกลาเอกลักษณ์ผ่านการช่วยเหลือ — ความมีประโยชน์ รายละเอียด และการทำให้ถูกต้อง''',
      ),
      'Libra': _Pair(
        r'''You may seek balance in who you are — fairness, charm, and how you relate in public.''',
        r'''คุณอาจแสวงหาความสมดุลในตัวตน — ความยุติธรรม เสน่ห์ และวิธีที่คุณอยู่กับคน''',
      ),
      'Scorpio': _Pair(
        r'''You may hold intensity quietly — loyalty, depth, and strength without needing to perform.''',
        r'''คุณอาจเก็บความเข้มข้นไว้เงียบๆ — ความผูกพัน ความลึก และความแข็งแรงที่ไม่ต้องโอ้อวด''',
      ),
      'Sagittarius': _Pair(
        r'''You may grow through horizons — meaning, honesty, and room to keep exploring.''',
        r'''คุณอาจเติบโตผ่านขอบฟ้า — ความหมาย ความจริงใจ และพื้นที่ในการสำรวจ''',
      ),
      'Capricorn': _Pair(
        r'''You may earn identity through effort — responsibility, standards, and long-term aims.''',
        r'''คุณอาจสร้างตัวตนผ่านความพยายาม — ความรับผิดชอบ มาตรฐาน และเป้าหมายระยะยาว''',
      ),
      'Aquarius': _Pair(
        r'''You may stand apart with principles — ideas, independence, and your own rules.''',
        r'''คุณอาจยืนด้วยหลักการ — ไอเดีย อิสระ และกติกาของตัวเอง''',
      ),
      'Pisces': _Pair(
        r'''You may soften identity through empathy — imagination, feeling, and quiet sensitivity.''',
        r'''คุณอาจนุ่มเอกลักษณ์ด้วยความเห็นอกเห็นใจ — จินตนาการ ความรู้สึก และความอ่อนไหวที่เงียบ''',
      ),
    },
    'moon': {
      'Aries': _Pair(
        r'''Emotionally you may need momentum — quick honesty and space to react without stalemate.''',
        r'''ทางใจคุณอาจต้องการแรงขับ — ความจริงเร็ว และพื้นที่ตอบสนองโดยไม่ค้าง''',
      ),
      'Taurus': _Pair(
        r'''You may need calm rhythm — routine, touch, and knowing what will not shift overnight.''',
        r'''คุณอาจต้องการจังหวะที่สงบ — กิจวัตร สัมผัส และรู้ว่าอะไรไม่เปลี่ยนทันที''',
      ),
      'Gemini': _Pair(
        r'''You may process mood through talk — naming feelings, lightening tone, then thinking again.''',
        r'''คุณอาจจัดการอารมณ์ผ่านการพูด — ตั้งชื่อความรู้สึก ผ่อนบรรยากาศ แล้วคิดใหม่''',
      ),
      'Cancer': _Pair(
        r'''You may need closeness — family tone, nostalgia, and feeling held when vulnerable.''',
        r'''คุณอาจต้องการความใกล้ชิด — โทนครอบครัว ความทรงจำ และรู้สึกถูกกอดเมื่อเปราะบาง''',
      ),
      'Leo': _Pair(
        r'''You may need recognition — warmth, play, and feeling proud of who you love.''',
        r'''คุณอาจต้องการการยอมรับ — ความอบอุ่น การเล่น และภูมิใจในคนที่รัก''',
      ),
      'Virgo': _Pair(
        r'''You may soothe anxiety by fixing — lists, helpful acts, and making chaos smaller.''',
        r'''คุณอาจลดความวิตกด้วยการแก้ — รายการ ช่วยเหลือ และทำให้วุ่นวายเล็กลง''',
      ),
      'Libra': _Pair(
        r'''You may need harmony — polite tone, fewer sharp edges, and peace in the room.''',
        r'''คุณอาจต้องการความสงบ — น้ำเสียงนุ่ม ขอบที่ไม่แข็ง และบรรยากาศสงบ''',
      ),
      'Scorpio': _Pair(
        r'''You may feel deeply before you speak — trust tests, privacy, and emotional truth.''',
        r'''คุณอาจรู้สึกลึกก่อนพูด — การทดสอบความไว้ใจ ความเป็นส่วนตัว และความจริงทางใจ''',
      ),
      'Sagittarius': _Pair(
        r'''You may need freedom in feeling — hope, mental travel, and future-oriented relief.''',
        r'''คุณอาจต้องการอิสระในการรู้สึก — ความหวัง จิตใจที่เดินทาง และการมองอนาคต''',
      ),
      'Capricorn': _Pair(
        r'''You may hold worry responsibly — duty, control, and proving you can carry weight.''',
        r'''คุณอาจแบกความกังวลอย่างมีสติ — หน้าที่ การควบคุม และพิสูจน์ว่าแบกได้''',
      ),
      'Aquarius': _Pair(
        r'''You may need distance to feel — friendship, ideals, and not being crowded emotionally.''',
        r'''คุณอาจต้องการระยะห่างเพื่อรู้สึก — มิตรภาพ อุดมคติ และไม่ถูกเบียดทางอารมณ์''',
      ),
      'Pisces': _Pair(
        r'''You may absorb atmosphere — dreams, music, and boundaries that blur easily.''',
        r'''คุณอาจรับบรรยากาศเข้ามา — ความฝัน เสียงเพลง และขอบเขตที่ละลายง่าย''',
      ),
    },
    'mercury': {
      'Aries': _Pair(
        r'''You may think in quick decisions — saying what you mean and learning from friction.''',
        r'''คุณอาจคิดแบบตัดสินใจเร็ว — พูดตรง และเรียนรู้จากแรงเสียดทาน''',
      ),
      'Taurus': _Pair(
        r'''You may think slowly and practically — preferring proof, repetition, and clear examples.''',
        r'''คุณอาจคิดช้าและเป็นรูปธรรม — ชอบหลักฐาน การทำซ้ำ และตัวอย่างที่ชัด''',
      ),
      'Gemini': _Pair(
        r'''You may think in links and options — often talking things through before you land on a view.''',
        r'''คุณอาจคิดเป็นลิงก์และทางเลือก — มักพูดคุยเรื่องต่างๆ ก่อนจะสรุปมุมของตัวเอง''',
      ),
      'Cancer': _Pair(
        r'''You may think with feeling first — memory, tone, and what the room needs to hear.''',
        r'''คุณอาจคิดด้วยความรู้สึกก่อน — ความทรงจำ น้ำเสียง และสิ่งที่ห้องนั้นต้องการได้ยิน''',
      ),
      'Leo': _Pair(
        r'''You may think out loud with confidence — storytelling, humor, and making ideas visible.''',
        r'''คุณอาจคิดออกเสียงอย่างมั่นใจ — เล่าเรื่อง อารมณ์ขัน และทำให้ไอเดียมองเห็นได้''',
      ),
      'Virgo': _Pair(
        r'''You may think in edits — sorting details, spotting errors, and improving the plan.''',
        r'''คุณอาจคิดแบบแก้ไข — จัดรายละเอียด จับความผิดพลาด และปรับแผนให้ดีขึ้น''',
      ),
      'Libra': _Pair(
        r'''You may think in both sides — weighing words so fairness stays in the conversation.''',
        r'''คุณอาจคิดสองด้าน — ชั่งคำพูดเพื่อให้ความยุติธรรมอยู่ในการสนทนา''',
      ),
      'Scorpio': _Pair(
        r'''You may think beneath the surface — reading subtext, silence, and what is not said.''',
        r'''คุณอาจคิดใต้ผิว — อ่านนัยแฝง ความเงียบ และสิ่งที่ไม่ได้พูด''',
      ),
      'Sagittarius': _Pair(
        r'''You may think in big pictures — principles, possibilities, and where a topic could lead.''',
        r'''คุณอาจคิดภาพใหญ่ — หลักการ ความเป็นไปได้ และทิศที่หัวข้ออาจไป''',
      ),
      'Capricorn': _Pair(
        r'''You may think in structure — steps, deadlines, and what will still matter later.''',
        r'''คุณอาจคิดเป็นโครงสร้าง — ขั้นตอน เดดไลน์ และสิ่งที่ยังสำคัญในอนาคต''',
      ),
      'Aquarius': _Pair(
        r'''You may think in systems and patterns — ideas that apply beyond one situation.''',
        r'''คุณอาจคิดเป็นระบบและรูปแบบ — ไอเดียที่ใช้ได้มากกว่าสถานการณ์เดียว''',
      ),
      'Pisces': _Pair(
        r'''You may think in images and intuition — gentle logic that follows feeling and metaphor.''',
        r'''คุณอาจคิดเป็นภาพและสัญชาตญาณ — ตรรกะนุ่มที่ตามความรู้สึกและอุปมา''',
      ),
    },
    'venus': {
      'Aries': _Pair(
        r'''In love and taste you may want spark — direct pursuit, honest desire, and little patience for mixed signals.''',
        r'''ในเรื่องรักและรสนิยมคุณอาจอยากได้ประกายไฟ — ชัดเจน ตรงไปตรงมา และไม่ค่อยทนการส่งสัญญาณคลุมเครือ''',
      ),
      'Taurus': _Pair(
        r'''You may value steadiness — touch, loyalty, and pleasures that repeat without drama.''',
        r'''คุณอาจให้ค่ากับความมั่นคง — สัมผัส ความผูกพัน และความสุขที่เกิดซ้ำโดยไม่วุ่น''',
      ),
      'Gemini': _Pair(
        r'''You may value variety in connection — wit, mental chemistry, and room to stay curious.''',
        r'''คุณอาจให้ค่าความหลากหลายในความสัมพันธ์ — ไหวพริบ ความเข้ากันทางความคิด และพื้นที่อยากรู้''',
      ),
      'Cancer': _Pair(
        r'''You may value emotional safety — nurturing, shared history, and being chosen again and again.''',
        r'''คุณอาจให้ค่าความปลอดภัยทางใจ — การดูแล ประวัติร่วม และการถูกเลือกซ้ำๆ''',
      ),
      'Leo': _Pair(
        r'''You may value warmth and admiration — romance, generosity, and feeling special together.''',
        r'''คุณอาจให้ค่าความอบอุ่นและการชื่นชม — ความโรแมนติก ความเอื้อ และความรู้สึกพิเศษเมื่ออยู่ด้วยกัน''',
      ),
      'Virgo': _Pair(
        r'''You may value care shown through acts — reliability, small fixes, and thoughtful routines.''',
        r'''คุณอาจให้ค่าการดูแลผ่านการกระทำ — ความไว้ใจได้ การช่วยเล็กๆ และกิจวัตรที่ใส่ใจ''',
      ),
      'Libra': _Pair(
        r'''You may value balance and courtesy — partnership tone, aesthetics, and avoiding needless harshness.''',
        r'''คุณอาจให้ค่าความสมดุลและมารยาท — โทนคู่ความสัมพันธ์ ความงาม และการหลีกเลี่ยงความแรงที่ไม่จำเป็น''',
      ),
      'Scorpio': _Pair(
        r'''You may value depth and loyalty — intensity, honesty about jealousy, and bonds that transform.''',
        r'''คุณอาจให้ค่าความลึกและความผูกพัน — ความเข้มข้น ความจริงใจเรื่องความหึง และสายใยที่เปลี่ยนคุณ''',
      ),
      'Sagittarius': _Pair(
        r'''You may value freedom with affection — adventure, shared beliefs, and space to grow.''',
        r'''คุณอาจให้ค่าอิสระคู่ความใกล้ชิด — การผจญภัย ความเชื่อร่วม และพื้นที่เติบโต''',
      ),
      'Capricorn': _Pair(
        r'''You may value commitment shown over time — respect, boundaries, and love that proves itself.''',
        r'''คุณอาจให้ค่าความมุ่งมั่นที่แสดงด้วยเวลา — ความเคารพ ขอบเขต และความรักที่พิสูจน์ตัวเอง''',
      ),
      'Aquarius': _Pair(
        r'''You may value friendship in love — ideals, odd chemistry, and partners who feel like allies.''',
        r'''คุณอาจให้ค่ามิตรภาพในความรัก — อุดมคติ เคมีแปลกๆ และคู่ที่รู้สึกเหมือนพันธมิตร''',
      ),
      'Pisces': _Pair(
        r'''You may value tenderness and imagination — compassion, art, and love that feels soulful.''',
        r'''คุณอาจให้ค่าความอ่อนโยนและจินตนาการ — เมตตา ศิลปะ และความรักที่รู้สึกลึก''',
      ),
    },
    'mars': {
      'Aries': _Pair(
        r'''You may act fast and directly — initiating, competing, and preferring clear conflict to drift.''',
        r'''คุณอาจลงมือเร็วและตรง — เริ่มต้น แข่งขัน และชอบความขัดแย้งที่ชัดมากกว่าความคลุมเครือ''',
      ),
      'Taurus': _Pair(
        r'''You may act with stubborn stamina — holding ground, building slowly, and resisting rushed change.''',
        r'''คุณอาจลงมือด้วยความอดทน — ยืนพื้น สร้างช้าๆ และต้านการเปลี่ยนแบบเร่งรีบ''',
      ),
      'Gemini': _Pair(
        r'''You may act through words and movement — debating, multitasking, and switching tactics quickly.''',
        r'''คุณอาจลงมือผ่านคำพูดและการเคลื่อนไหว — โต้วาที ทำหลายอย่าง และสลับกลยุทธ์เร็ว''',
      ),
      'Cancer': _Pair(
        r'''You may act to protect — defending people, home, and what feels emotionally important.''',
        r'''คุณอาจลงมือเพื่อปกป้อง — ป้องคน บ้าน และสิ่งที่สำคัญทางใจ''',
      ),
      'Leo': _Pair(
        r'''You may act for pride and visibility — courage, performance, and refusing to be overlooked.''',
        r'''คุณอาจลงมือเพื่อศักดิ์ศรีและการถูกเห็น — ความกล้า การแสดงออก และไม่ยอมถูกมองข้าม''',
      ),
      'Virgo': _Pair(
        r'''You may act through precision — fixing problems, improving systems, and working until it is right.''',
        r'''คุณอาจลงมือด้วยความแม่นยำ — แก้ปัญหา ปรับระบบ และทำจนถูกต้อง''',
      ),
      'Libra': _Pair(
        r'''You may act through negotiation — pushing gently, using charm, and avoiding open warfare.''',
        r'''คุณอาจลงมือผ่านการเจรจา — ผลักเบาๆ ใช้เสน่ห์ และหลีกเลี่ยงสงครามเปิด''',
      ),
      'Scorpio': _Pair(
        r'''You may act with controlled force — strategic patience, intensity, and finishing what you start.''',
        r'''คุณอาจลงมือด้วยแรงที่ควบคุมได้ — อดทนเชิงกลยุทธ์ ความเข้มข้น และทำจนจบ''',
      ),
      'Sagittarius': _Pair(
        r'''You may act on conviction — taking risks for beliefs, travel, or a bigger meaning.''',
        r'''คุณอาจลงมือจากความเชื่อ — เสี่ยงเพื่อความเชื่อ การเดินทาง หรือความหมายที่ใหญ่กว่า''',
      ),
      'Capricorn': _Pair(
        r'''You may act with discipline — climbing step by step, enduring pressure, and playing the long game.''',
        r'''คุณอาจลงมือด้วยวินัย — ไต่ทีละขั้น ทนแรงกดดัน และเล่นเกมระยะยาว''',
      ),
      'Aquarius': _Pair(
        r'''You may act for causes and groups — rebellion, innovation, and fighting for the future you want.''',
        r'''คุณอาจลงมือเพื่อประเด็นและกลุ่ม — ท้าทาย นวัตกรรม และต่อสู้เพื่ออนาคตที่อยากได้''',
      ),
      'Pisces': _Pair(
        r'''You may act indirectly — persistence in dreams, creative escape, or anger that goes inward first.''',
        r'''คุณอาจลงมือทางอ้อม — ความพากเพียรในความฝัน ทางหนีสร้างสรรค์ หรือโกรธที่หมุนเข้าข้างในก่อน''',
      ),
    },
    'jupiter': {
      'Aries': _Pair(
        r'''You may grow through courage — trying, failing forward, and trusting your own initiative.''',
        r'''คุณอาจเติบโตผ่านความกล้า — ลอง ล้มแล้วเดินต่อ และเชื่อในการริเริ่มของตัวเอง''',
      ),
      'Taurus': _Pair(
        r'''You may grow through patience — building assets, savoring life, and faith in steady progress.''',
        r'''คุณอาจเติบโตผ่านความอดทน — สะสมคุณค่า รสชาติชีวิต และความเชื่อในก้าวที่มั่นคง''',
      ),
      'Gemini': _Pair(
        r'''You may grow through learning — books, people, and ideas that keep multiplying.''',
        r'''คุณอาจเติบโตผ่านการเรียนรู้ — หนังสือ คน และไอเดียที่ขยายตัวเรื่อยๆ''',
      ),
      'Cancer': _Pair(
        r'''You may grow through belonging — family wisdom, emotional generosity, and feeling rooted.''',
        r'''คุณอาจเติบโตผ่านความเป็นเจ้าของ — ปัญญาครอบครัว ความเอื้อทางใจ และรากที่มั่น''',
      ),
      'Leo': _Pair(
        r'''You may grow through expression — confidence, play, and believing your story matters.''',
        r'''คุณอาจเติบโตผ่านการแสดงออก — ความมั่นใจ การเล่น และความเชื่อว่าเรื่องของคุณมีความหมาย''',
      ),
      'Virgo': _Pair(
        r'''You may grow through usefulness — skills, service, and meaning found in getting better.''',
        r'''คุณอาจเติบโตผ่านความมีประโยชน์ — ทักษะ การช่วยเหลือ และความหมายจากการพัฒนาตัวเอง''',
      ),
      'Libra': _Pair(
        r'''You may grow through relationship — fairness, diplomacy, and seeing yourself in others.''',
        r'''คุณอาจเติบโตผ่านความสัมพันธ์ — ความยุติธรรม การไกล่เกลี่ย และมองตัวเองในคนอื่น''',
      ),
      'Scorpio': _Pair(
        r'''You may grow through depth — shared resources, psychology, and trust earned slowly.''',
        r'''คุณอาจเติบโตผ่านความลึก — ทรัพยากรร่วม จิตใจ และความไว้ใจที่ได้มาช้าๆ''',
      ),
      'Sagittarius': _Pair(
        r'''You may grow through exploration — travel, philosophy, and optimism about what is next.''',
        r'''คุณอาจเติบโตผ่านการสำรวจ — การเดินทาง ปรัชญา และมองข้างหน้าด้วยความหวัง''',
      ),
      'Capricorn': _Pair(
        r'''You may grow through responsibility — mentors, structure, and rewards that take time.''',
        r'''คุณอาจเติบโตผ่านความรับผิดชอบ — ที่ปรึกษา โครงสร้าง และผลตอบแทนที่ใช้เวลา''',
      ),
      'Aquarius': _Pair(
        r'''You may grow through community — networks, reform, and hope for collective progress.''',
        r'''คุณอาจเติบโตผ่านชุมชน — เครือข่าย การปรับปรุง และความหวังต่อความก้าวหน้าร่วม''',
      ),
      'Pisces': _Pair(
        r'''You may grow through compassion — spirituality, art, and faith in what cannot be measured.''',
        r'''คุณอาจเติบโตผ่านความเมตตา — จิตวิญญาณ ศิลปะ และความเชื่อในสิ่งที่วัดยาก''',
      ),
    },
    'saturn': {
      'Aries': _Pair(
        r'''You may learn limits through initiative — owning mistakes quickly and building self-trust by trying.''',
        r'''คุณอาจเรียนรู้ขอบเขตผ่านการริเริ่ม — รับผิดเร็ว และสร้างความเชื่อตัวเองจากการลอง''',
      ),
      'Taurus': _Pair(
        r'''You may learn limits around security — patience with money, body, and what cannot be rushed.''',
        r'''คุณอาจเรียนรู้ขอบเขตเรื่องความมั่นคง — อดทนกับเงิน ร่างกาย และสิ่งที่เร่งไม่ได้''',
      ),
      'Gemini': _Pair(
        r'''You may learn limits in communication — focusing scattered thought and finishing what you start saying.''',
        r'''คุณอาจเรียนรู้ขอบเขตในการสื่อสาร — โฟกัสความคิดที่กระจาย และพูดจนจบประเด็น''',
      ),
      'Cancer': _Pair(
        r'''You may learn limits around care — boundaries with family, mood, and old emotional habits.''',
        r'''คุณอาจเรียนรู้ขอบเขตเรื่องการดูแล — ขอบกับครอบครัว อารมณ์ และนิสัยทางใจเก่าๆ''',
      ),
      'Leo': _Pair(
        r'''You may learn limits around pride — earning respect, not performing for empty applause.''',
        r'''คุณอาจเรียนรู้ขอบเขตเรื่องศักดิ์ศรี — ได้รับความเคารพจากผลงาน ไม่ใช่แสดงเพื่อเสียงปรบมือว่าง''',
      ),
      'Virgo': _Pair(
        r'''You may learn limits in work — standards, health stress, and accepting imperfect progress.''',
        r'''คุณอาจเรียนรู้ขอบเขตในงาน — มาตรฐาน ความเครียดสุขภาพ และยอมรับความก้าวหน้าที่ไม่สมบูรณ์''',
      ),
      'Libra': _Pair(
        r'''You may learn limits in partnership — contracts, fairness, and choosing people you can rely on.''',
        r'''คุณอาจเรียนรู้ขอบเขตในคู่ความสัมพันธ์ — ข้อตกลง ความยุติธรรม และเลือกคนที่พึ่งได้''',
      ),
      'Scorpio': _Pair(
        r'''You may learn limits around trust — debt, intimacy, and power dynamics you cannot ignore.''',
        r'''คุณอาจเรียนรู้ขอบเขตเรื่องความไว้ใจ — หนี้สิน ความใกล้ชิด และพลังอำนาจที่มองข้ามไม่ได้''',
      ),
      'Sagittarius': _Pair(
        r'''You may learn limits in belief — testing teachers, laws, and stories before you build on them.''',
        r'''คุณอาจเรียนรู้ขอบเขตในความเชื่อ — ทดสอบครู กฎ และเรื่องเล่าก่อนสร้างต่อ''',
      ),
      'Capricorn': _Pair(
        r'''You may learn limits in ambition — duty, reputation, and success that costs something real.''',
        r'''คุณอาจเรียนรู้ขอบเขตใน ambition — หน้าที่ ชื่อเสียง และความสำเร็จที่แลกด้วยราคาจริง''',
      ),
      'Aquarius': _Pair(
        r'''You may learn limits in groups — belonging versus conformity, and friends who hold you accountable.''',
        r'''คุณอาจเรียนรู้ขอบเขตในกลุ่ม — การอยู่ร่วมกับการยึดตาม และเพื่อนที่ท้าทายคุณอย่างตรงไปตรงมา''',
      ),
      'Pisces': _Pair(
        r'''You may learn limits around escape — solitude, sleep, and facing what you have been avoiding.''',
        r'''คุณอาจเรียนรู้ขอบเขตเรื่องการหนี — ความสงบ การพัก และเผชิญสิ่งที่เคยหลีกเลี่ยง''',
      ),
    },
  };
}
