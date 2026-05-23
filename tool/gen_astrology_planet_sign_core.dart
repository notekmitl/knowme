// ignore_for_file: avoid_print
import 'dart:io';

const _signs = [
  'Aries',
  'Taurus',
  'Gemini',
  'Cancer',
  'Leo',
  'Virgo',
  'Libra',
  'Scorpio',
  'Sagittarius',
  'Capricorn',
  'Aquarius',
  'Pisces',
];

void main() {
  final data = <String, Map<String, List<String>>>{
    'sun': _sun(),
    'moon': _moon(),
    'mercury': _mercury(),
    'venus': _venus(),
    'mars': _mars(),
    'jupiter': _jupiter(),
    'saturn': _saturn(),
  };

  final b = StringBuffer('''
// Big 7 × 12 planet–sign core meanings (deterministic local coverage).
import 'astrology_planet_interpretation_engine.dart';

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
''');

  for (final e in data.entries) {
    b.writeln("    '${e.key}': {");
    for (var i = 0; i < _signs.length; i++) {
      final sign = _signs[i];
      final en = e.value[sign]![0];
      final th = e.value[sign]![1];
      b.writeln("      '$sign': _Pair(");
      b.writeln("        ${_dq(en)},");
      b.writeln("        ${_dq(th)},");
      b.writeln('      ),');
    }
    b.writeln('    },');
  }
  b.writeln('  };');
  b.writeln('}');

  final out = File(
    'lib/presentation/pages/astrology/astrology_planet_sign_core.dart',
  );
  out.writeAsStringSync(b.toString());
  print('Wrote ${out.path} (${data.length * 12} entries)');
}

String _dq(String s) => "r'''$s'''";

Map<String, List<String>> _rows(List<List<String>> rows) {
  assert(rows.length == 12);
  return Map.fromIterables(_signs, rows);
}

Map<String, List<String>> _sun() => _rows([
      [
        'You may express will through action — starting, competing, and learning by doing.',
        'คุณอาจแสดงเจตจักน์ผ่านการลงมือ — การเริ่ม การท้าทายตัวเอง และการเรียนรู้จากการทำ',
      ],
      [
        'You may build identity through steadiness — loyalty to pace, comfort, and what feels reliable.',
        'คุณอาจสร้างตัวตนผ่านความมั่นคง — จังหวะที่พอใจ ความสบาย และสิ่งที่เชื่อถือได้',
      ],
      [
        'You may define yourself through ideas — curiosity, conversation, and staying mentally mobile.',
        'คุณอาจนิยามตัวเองผ่านความคิด — ความอยากรู้ การพูดคุย และการไม่ยึดมุมเดียว',
      ],
      [
        'You may shine through care — belonging, memory, and protecting what feels like home.',
        'คุณอาจเปล่งประกายผ่านการดูแล — ความเป็นเจ้าของ ความทรงจำ และการปกป้องสิ่งที่รู้สึกเหมือนบ้าน',
      ],
      [
        'You may want to be seen warmly — creative pride, generosity, and sincere presence.',
        'คุณอาจอยากถูกมองเห็นอย่างอบอุ่น — ความภูมิใจสร้างสรรค์ ความเอื้อ และการแสดงตัวจริงๆ',
      ],
      [
        'You may refine identity through service — usefulness, detail, and doing things properly.',
        'คุณอาจขัดเกลาเอกลักษณ์ผ่านการช่วยเหลือ — ความมีประโยชน์ รายละเอียด และการทำให้ถูกต้อง',
      ],
      [
        'You may seek balance in who you are — fairness, charm, and how you relate in public.',
        'คุณอาจแสวงหาความสมดุลในตัวตน — ความยุติธรรม เสน่ห์ และวิธีที่คุณอยู่กับคน',
      ],
      [
        'You may hold intensity quietly — loyalty, depth, and strength without needing to perform.',
        'คุณอาจเก็บความเข้มข้นไว้เงียบๆ — ความผูกพัน ความลึก และความแข็งแรงที่ไม่ต้องโอ้อวด',
      ],
      [
        'You may grow through horizons — meaning, honesty, and room to keep exploring.',
        'คุณอาจเติบโตผ่านขอบฟ้า — ความหมาย ความจริงใจ และพื้นที่ในการสำรวจ',
      ],
      [
        'You may earn identity through effort — responsibility, standards, and long-term aims.',
        'คุณอาจสร้างตัวตนผ่านความพยายาม — ความรับผิดชอบ มาตรฐาน และเป้าหมายระยะยาว',
      ],
      [
        'You may stand apart with principles — ideas, independence, and your own rules.',
        'คุณอาจยืนด้วยหลักการ — ไอเดีย อิสระ และกติกาของตัวเอง',
      ],
      [
        'You may soften identity through empathy — imagination, feeling, and quiet sensitivity.',
        'คุณอาจนุ่มเอกลักษณ์ด้วยความเห็นอกเห็นใจ — จินตนาการ ความรู้สึก และความอ่อนไหวที่เงียบ',
      ],
    ]);

Map<String, List<String>> _moon() => _rows([
      [
        'Emotionally you may need momentum — quick honesty and space to react without stalemate.',
        'ทางใจคุณอาจต้องการแรงขับ — ความจริงเร็ว และพื้นที่ตอบสนองโดยไม่ค้าง',
      ],
      [
        'You may need calm rhythm — routine, touch, and knowing what will not shift overnight.',
        'คุณอาจต้องการจังหวะที่สงบ — กิจวัตร สัมผัส และรู้ว่าอะไรไม่เปลี่ยนทันที',
      ],
      [
        'You may process mood through talk — naming feelings, lightening tone, then thinking again.',
        'คุณอาจจัดการอารมณ์ผ่านการพูด — ตั้งชื่อความรู้สึก ผ่อนบรรยากาศ แล้วคิดใหม่',
      ],
      [
        'You may need closeness — family tone, nostalgia, and feeling held when vulnerable.',
        'คุณอาจต้องการความใกล้ชิด — โทนครอบครัว ความทรงจำ และรู้สึกถูกกอดเมื่อเปราะบาง',
      ],
      [
        'You may need recognition — warmth, play, and feeling proud of who you love.',
        'คุณอาจต้องการการยอมรับ — ความอบอุ่น การเล่น และภูมิใจในคนที่รัก',
      ],
      [
        'You may soothe anxiety by fixing — lists, helpful acts, and making chaos smaller.',
        'คุณอาจลดความวิตกด้วยการแก้ — รายการ ช่วยเหลือ และทำให้วุ่นวายเล็กลง',
      ],
      [
        'You may need harmony — polite tone, fewer sharp edges, and peace in the room.',
        'คุณอาจต้องการความสงบ — น้ำเสียงนุ่ม ขอบที่ไม่แข็ง และบรรยากาศสงบ',
      ],
      [
        'You may feel deeply before you speak — trust tests, privacy, and emotional truth.',
        'คุณอาจรู้สึกลึกก่อนพูด — การทดสอบความไว้ใจ ความเป็นส่วนตัว และความจริงทางใจ',
      ],
      [
        'You may need freedom in feeling — hope, mental travel, and future-oriented relief.',
        'คุณอาจต้องการอิสระในการรู้สึก — ความหวัง จิตใจที่เดินทาง และการมองอนาคต',
      ],
      [
        'You may hold worry responsibly — duty, control, and proving you can carry weight.',
        'คุณอาจแบกความกังวลอย่างมีสติ — หน้าที่ การควบคุม และพิสูจน์ว่าแบกได้',
      ],
      [
        'You may need distance to feel — friendship, ideals, and not being crowded emotionally.',
        'คุณอาจต้องการระยะห่างเพื่อรู้สึก — มิตรภาพ อุดมคติ และไม่ถูกเบียดทางอารมณ์',
      ],
      [
        'You may absorb atmosphere — dreams, music, and boundaries that blur easily.',
        'คุณอาจรับบรรยากาศเข้ามา — ความฝัน เสียงเพลง และขอบเขตที่ละลายง่าย',
      ],
    ]);

Map<String, List<String>> _mercury() => _rows([
      [
        'You may think in quick decisions — saying what you mean and learning from friction.',
        'คุณอาจคิดแบบตัดสินใจเร็ว — พูดตรง และเรียนรู้จากแรงเสียดทาน',
      ],
      [
        'You may think slowly and practically — preferring proof, repetition, and clear examples.',
        'คุณอาจคิดช้าและเป็นรูปธรรม — ชอบหลักฐาน การทำซ้ำ และตัวอย่างที่ชัด',
      ],
      [
        'You may think in links and options — often talking things through before you land on a view.',
        'คุณอาจคิดเป็นลิงก์และทางเลือก — มักพูดคุยเรื่องต่างๆ ก่อนจะสรุปมุมของตัวเอง',
      ],
      [
        'You may think with feeling first — memory, tone, and what the room needs to hear.',
        'คุณอาจคิดด้วยความรู้สึกก่อน — ความทรงจำ น้ำเสียง และสิ่งที่ห้องนั้นต้องการได้ยิน',
      ],
      [
        'You may think out loud with confidence — storytelling, humor, and making ideas visible.',
        'คุณอาจคิดออกเสียงอย่างมั่นใจ — เล่าเรื่อง อารมณ์ขัน และทำให้ไอเดียมองเห็นได้',
      ],
      [
        'You may think in edits — sorting details, spotting errors, and improving the plan.',
        'คุณอาจคิดแบบแก้ไข — จัดรายละเอียด จับความผิดพลาด และปรับแผนให้ดีขึ้น',
      ],
      [
        'You may think in both sides — weighing words so fairness stays in the conversation.',
        'คุณอาจคิดสองด้าน — ชั่งคำพูดเพื่อให้ความยุติธรรมอยู่ในการสนทนา',
      ],
      [
        'You may think beneath the surface — reading subtext, silence, and what is not said.',
        'คุณอาจคิดใต้ผิว — อ่านนัยแฝง ความเงียบ และสิ่งที่ไม่ได้พูด',
      ],
      [
        'You may think in big pictures — principles, possibilities, and where a topic could lead.',
        'คุณอาจคิดภาพใหญ่ — หลักการ ความเป็นไปได้ และทิศที่หัวข้ออาจไป',
      ],
      [
        'You may think in structure — steps, deadlines, and what will still matter later.',
        'คุณอาจคิดเป็นโครงสร้าง — ขั้นตอน เดดไลน์ และสิ่งที่ยังสำคัญในอนาคต',
      ],
      [
        'You may think in systems and patterns — ideas that apply beyond one situation.',
        'คุณอาจคิดเป็นระบบและรูปแบบ — ไอเดียที่ใช้ได้มากกว่าสถานการณ์เดียว',
      ],
      [
        'You may think in images and intuition — gentle logic that follows feeling and metaphor.',
        'คุณอาจคิดเป็นภาพและสัญชาตญาณ — ตรรกะนุ่มที่ตามความรู้สึกและอุปมา',
      ],
    ]);

Map<String, List<String>> _venus() => _rows([
      [
        'In love and taste you may want spark — direct pursuit, honest desire, and little patience for mixed signals.',
        'ในเรื่องรักและรสนิยมคุณอาจอยากได้ประกายไฟ — ชัดเจน ตรงไปตรงมา และไม่ค่อยทนการส่งสัญญาณคลุมเครือ',
      ],
      [
        'You may value steadiness — touch, loyalty, and pleasures that repeat without drama.',
        'คุณอาจให้ค่ากับความมั่นคง — สัมผัส ความผูกพัน และความสุขที่เกิดซ้ำโดยไม่วุ่น',
      ],
      [
        'You may value variety in connection — wit, mental chemistry, and room to stay curious.',
        'คุณอาจให้ค่าความหลากหลายในความสัมพันธ์ — ไหวพริบ ความเข้ากันทางความคิด และพื้นที่อยากรู้',
      ],
      [
        'You may value emotional safety — nurturing, shared history, and being chosen again and again.',
        'คุณอาจให้ค่าความปลอดภัยทางใจ — การดูแล ประวัติร่วม และการถูกเลือกซ้ำๆ',
      ],
      [
        'You may value warmth and admiration — romance, generosity, and feeling special together.',
        'คุณอาจให้ค่าความอบอุ่นและการชื่นชม — ความโรแมนติก ความเอื้อ และความรู้สึกพิเศษเมื่ออยู่ด้วยกัน',
      ],
      [
        'You may value care shown through acts — reliability, small fixes, and thoughtful routines.',
        'คุณอาจให้ค่าการดูแลผ่านการกระทำ — ความไว้ใจได้ การช่วยเล็กๆ และกิจวัตรที่ใส่ใจ',
      ],
      [
        'You may value balance and courtesy — partnership tone, aesthetics, and avoiding needless harshness.',
        'คุณอาจให้ค่าความสมดุลและมารยาท — โทนคู่ความสัมพันธ์ ความงาม และการหลีกเลี่ยงความแรงที่ไม่จำเป็น',
      ],
      [
        'You may value depth and loyalty — intensity, honesty about jealousy, and bonds that transform.',
        'คุณอาจให้ค่าความลึกและความผูกพัน — ความเข้มข้น ความจริงใจเรื่องความหึง และสายใยที่เปลี่ยนคุณ',
      ],
      [
        'You may value freedom with affection — adventure, shared beliefs, and space to grow.',
        'คุณอาจให้ค่าอิสระคู่ความใกล้ชิด — การผจญภัย ความเชื่อร่วม และพื้นที่เติบโต',
      ],
      [
        'You may value commitment shown over time — respect, boundaries, and love that proves itself.',
        'คุณอาจให้ค่าความมุ่งมั่นที่แสดงด้วยเวลา — ความเคารพ ขอบเขต และความรักที่พิสูจน์ตัวเอง',
      ],
      [
        'You may value friendship in love — ideals, odd chemistry, and partners who feel like allies.',
        'คุณอาจให้ค่ามิตรภาพในความรัก — อุดมคติ เคมีแปลกๆ และคู่ที่รู้สึกเหมือนพันธมิตร',
      ],
      [
        'You may value tenderness and imagination — compassion, art, and love that feels soulful.',
        'คุณอาจให้ค่าความอ่อนโยนและจินตนาการ — เมตตา ศิลปะ และความรักที่รู้สึกลึก',
      ],
    ]);

Map<String, List<String>> _mars() => _rows([
      [
        'You may act fast and directly — initiating, competing, and preferring clear conflict to drift.',
        'คุณอาจลงมือเร็วและตรง — เริ่มต้น แข่งขัน และชอบความขัดแย้งที่ชัดมากกว่าความคลุมเครือ',
      ],
      [
        'You may act with stubborn stamina — holding ground, building slowly, and resisting rushed change.',
        'คุณอาจลงมือด้วยความอดทน — ยืนพื้น สร้างช้าๆ และต้านการเปลี่ยนแบบเร่งรีบ',
      ],
      [
        'You may act through words and movement — debating, multitasking, and switching tactics quickly.',
        'คุณอาจลงมือผ่านคำพูดและการเคลื่อนไหว — โต้วาที ทำหลายอย่าง และสลับกลยุทธ์เร็ว',
      ],
      [
        'You may act to protect — defending people, home, and what feels emotionally important.',
        'คุณอาจลงมือเพื่อปกป้อง — ป้องคน บ้าน และสิ่งที่สำคัญทางใจ',
      ],
      [
        'You may act for pride and visibility — courage, performance, and refusing to be overlooked.',
        'คุณอาจลงมือเพื่อศักดิ์ศรีและการถูกเห็น — ความกล้า การแสดงออก และไม่ยอมถูกมองข้าม',
      ],
      [
        'You may act through precision — fixing problems, improving systems, and working until it is right.',
        'คุณอาจลงมือด้วยความแม่นยำ — แก้ปัญหา ปรับระบบ และทำจนถูกต้อง',
      ],
      [
        'You may act through negotiation — pushing gently, using charm, and avoiding open warfare.',
        'คุณอาจลงมือผ่านการเจรจา — ผลักเบาๆ ใช้เสน่ห์ และหลีกเลี่ยงสงครามเปิด',
      ],
      [
        'You may act with controlled force — strategic patience, intensity, and finishing what you start.',
        'คุณอาจลงมือด้วยแรงที่ควบคุมได้ — อดทนเชิงกลยุทธ์ ความเข้มข้น และทำจนจบ',
      ],
      [
        'You may act on conviction — taking risks for beliefs, travel, or a bigger meaning.',
        'คุณอาจลงมือจากความเชื่อ — เสี่ยงเพื่อความเชื่อ การเดินทาง หรือความหมายที่ใหญ่กว่า',
      ],
      [
        'You may act with discipline — climbing step by step, enduring pressure, and playing the long game.',
        'คุณอาจลงมือด้วยวินัย — ไต่ทีละขั้น ทนแรงกดดัน และเล่นเกมระยะยาว',
      ],
      [
        'You may act for causes and groups — rebellion, innovation, and fighting for the future you want.',
        'คุณอาจลงมือเพื่อประเด็นและกลุ่ม — ท้าทาย นวัตกรรม และต่อสู้เพื่ออนาคตที่อยากได้',
      ],
      [
        'You may act indirectly — persistence in dreams, creative escape, or anger that goes inward first.',
        'คุณอาจลงมือทางอ้อม — ความพากเพียรในความฝัน ทางหนีสร้างสรรค์ หรือโกรธที่หมุนเข้าข้างในก่อน',
      ],
    ]);

Map<String, List<String>> _jupiter() => _rows([
      [
        'You may grow through courage — trying, failing forward, and trusting your own initiative.',
        'คุณอาจเติบโตผ่านความกล้า — ลอง ล้มแล้วเดินต่อ และเชื่อในการริเริ่มของตัวเอง',
      ],
      [
        'You may grow through patience — building assets, savoring life, and faith in steady progress.',
        'คุณอาจเติบโตผ่านความอดทน — สะสมคุณค่า รสชาติชีวิต และความเชื่อในก้าวที่มั่นคง',
      ],
      [
        'You may grow through learning — books, people, and ideas that keep multiplying.',
        'คุณอาจเติบโตผ่านการเรียนรู้ — หนังสือ คน และไอเดียที่ขยายตัวเรื่อยๆ',
      ],
      [
        'You may grow through belonging — family wisdom, emotional generosity, and feeling rooted.',
        'คุณอาจเติบโตผ่านความเป็นเจ้าของ — ปัญญาครอบครัว ความเอื้อทางใจ และรากที่มั่น',
      ],
      [
        'You may grow through expression — confidence, play, and believing your story matters.',
        'คุณอาจเติบโตผ่านการแสดงออก — ความมั่นใจ การเล่น และความเชื่อว่าเรื่องของคุณมีความหมาย',
      ],
      [
        'You may grow through usefulness — skills, service, and meaning found in getting better.',
        'คุณอาจเติบโตผ่านความมีประโยชน์ — ทักษะ การช่วยเหลือ และความหมายจากการพัฒนาตัวเอง',
      ],
      [
        'You may grow through relationship — fairness, diplomacy, and seeing yourself in others.',
        'คุณอาจเติบโตผ่านความสัมพันธ์ — ความยุติธรรม การไกล่เกลี่ย และมองตัวเองในคนอื่น',
      ],
      [
        'You may grow through depth — shared resources, psychology, and trust earned slowly.',
        'คุณอาจเติบโตผ่านความลึก — ทรัพยากรร่วม จิตใจ และความไว้ใจที่ได้มาช้าๆ',
      ],
      [
        'You may grow through exploration — travel, philosophy, and optimism about what is next.',
        'คุณอาจเติบโตผ่านการสำรวจ — การเดินทาง ปรัชญา และมองข้างหน้าด้วยความหวัง',
      ],
      [
        'You may grow through responsibility — mentors, structure, and rewards that take time.',
        'คุณอาจเติบโตผ่านความรับผิดชอบ — ที่ปรึกษา โครงสร้าง และผลตอบแทนที่ใช้เวลา',
      ],
      [
        'You may grow through community — networks, reform, and hope for collective progress.',
        'คุณอาจเติบโตผ่านชุมชน — เครือข่าย การปรับปรุง และความหวังต่อความก้าวหน้าร่วม',
      ],
      [
        'You may grow through compassion — spirituality, art, and faith in what cannot be measured.',
        'คุณอาจเติบโตผ่านความเมตตา — จิตวิญญาณ ศิลปะ และความเชื่อในสิ่งที่วัดยาก',
      ],
    ]);

Map<String, List<String>> _saturn() => _rows([
      [
        'You may learn limits through initiative — owning mistakes quickly and building self-trust by trying.',
        'คุณอาจเรียนรู้ขอบเขตผ่านการริเริ่ม — รับผิดเร็ว และสร้างความเชื่อตัวเองจากการลอง',
      ],
      [
        'You may learn limits around security — patience with money, body, and what cannot be rushed.',
        'คุณอาจเรียนรู้ขอบเขตเรื่องความมั่นคง — อดทนกับเงิน ร่างกาย และสิ่งที่เร่งไม่ได้',
      ],
      [
        'You may learn limits in communication — focusing scattered thought and finishing what you start saying.',
        'คุณอาจเรียนรู้ขอบเขตในการสื่อสาร — โฟกัสความคิดที่กระจาย และพูดจนจบประเด็น',
      ],
      [
        'You may learn limits around care — boundaries with family, mood, and old emotional habits.',
        'คุณอาจเรียนรู้ขอบเขตเรื่องการดูแล — ขอบกับครอบครัว อารมณ์ และนิสัยทางใจเก่าๆ',
      ],
      [
        'You may learn limits around pride — earning respect, not performing for empty applause.',
        'คุณอาจเรียนรู้ขอบเขตเรื่องศักดิ์ศรี — ได้รับความเคารพจากผลงาน ไม่ใช่แสดงเพื่อเสียงปรบมือว่าง',
      ],
      [
        'You may learn limits in work — standards, health stress, and accepting imperfect progress.',
        'คุณอาจเรียนรู้ขอบเขตในงาน — มาตรฐาน ความเครียดสุขภาพ และยอมรับความก้าวหน้าที่ไม่สมบูรณ์',
      ],
      [
        'You may learn limits in partnership — contracts, fairness, and choosing people you can rely on.',
        'คุณอาจเรียนรู้ขอบเขตในคู่ความสัมพันธ์ — ข้อตกลง ความยุติธรรม และเลือกคนที่พึ่งได้',
      ],
      [
        'You may learn limits around trust — debt, intimacy, and power dynamics you cannot ignore.',
        'คุณอาจเรียนรู้ขอบเขตเรื่องความไว้ใจ — หนี้สิน ความใกล้ชิด และพลังอำนาจที่มองข้ามไม่ได้',
      ],
      [
        'You may learn limits in belief — testing teachers, laws, and stories before you build on them.',
        'คุณอาจเรียนรู้ขอบเขตในความเชื่อ — ทดสอบครู กฎ และเรื่องเล่าก่อนสร้างต่อ',
      ],
      [
        'You may learn limits in ambition — duty, reputation, and success that costs something real.',
        'คุณอาจเรียนรู้ขอบเขตใน ambition — หน้าที่ ชื่อเสียง และความสำเร็จที่แลกด้วยราคาจริง',
      ],
      [
        'You may learn limits in groups — belonging versus conformity, and friends who hold you accountable.',
        'คุณอาจเรียนรู้ขอบเขตในกลุ่ม — การอยู่ร่วมกับการยึดตาม และเพื่อนที่ท้าทายคุณอย่างตรงไปตรงมา',
      ],
      [
        'You may learn limits around escape — solitude, sleep, and facing what you have been avoiding.',
        'คุณอาจเรียนรู้ขอบเขตเรื่องการหนี — ความสงบ การพัก และเผชิญสิ่งที่เคยหลีกเลี่ยง',
      ],
    ]);
