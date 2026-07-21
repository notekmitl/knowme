import 'package:knowme/features/astrology/thai/content/models/thai_content_key.dart';

/// Consumer-facing lagna tone — no internal labels in output.
class LagnaConsumerTone {
  const LagnaConsumerTone({
    required this.headlineTail,
    required this.heroAccent,
    required this.strengthTail,
    required this.adviceTail,
    required this.workDash,
    required this.moneyDash,
    required this.loveDash,
    required this.healthDash,
    required this.luckDash,
    required this.growthDash,
  });

  final String headlineTail;
  final String heroAccent;
  final String strengthTail;
  final String adviceTail;
  final String workDash;
  final String moneyDash;
  final String loveDash;
  final String healthDash;
  final String luckDash;
  final String growthDash;

  String dashboardFor(String aspect) => switch (aspect) {
        'work' => workDash,
        'money' => moneyDash,
        'love' => loveDash,
        'health' => healthDash,
        'luck' => luckDash,
        _ => workDash,
      };
}

abstract final class ThaiMirrorLagnaInfluence {
  static const _tones = <String, LagnaConsumerTone>{
    ThaiContentKeys.lagnaAries: LagnaConsumerTone(
      headlineTail: 'คุณมักลุกขึ้นทำก่อนเมื่อเห็นโอกาส',
      heroAccent: 'พลังเริ่มต้นและความกล้าลงมือเป็นจุดที่คนรอบตัวสังเกตในตัวคุณ',
      strengthTail: 'จุดนี้เด่นเมื่อต้องเปิดทางหรือเริ่มสิ่งใหม่',
      adviceTail: 'ใช้ความกล้าเริ่มต้น แต่เว้นจังหวะสั้น ๆ ให้คิดก่อนลงมือเต็มที่',
      workDash: 'งานที่ให้คุณเป็นคนริเริ่มจะเห็นผลเร็ว',
      moneyDash: 'ลงทุนกับสิ่งที่เปิดโอกาสใหม่ได้ตรงกับจังหวะของคุณ',
      loveDash: 'ความสัมพันธ์ดีขึ้นเมื่อคุณพูดตรงและลงมือดูแลจริง',
      healthDash: 'ออกกำลังหรือขยับร่างกายช่วยระบายพลังส่วนเกิน',
      luckDash: 'โอกาสมักมาพร้อมช่วงที่คุณกล้าลองก่อนคนอื่น',
      growthDash: 'ฝึกหยุดสักครู่ก่อนรีบตัดสินใจ จะทำให้พลังคุณยั่งยืนขึ้น',
    ),
    ThaiContentKeys.lagnaTaurus: LagnaConsumerTone(
      headlineTail: 'คุณให้ความสำคัญกับความมั่นคงและผลลัพธ์ที่จับต้องได้',
      heroAccent: 'ความอดทนและการสร้างฐานที่แน่นเป็นสไตล์ของคุณ',
      strengthTail: 'จุดนี้แข็งแรงเมื่อต้องทำต่อเนื่องและไม่ล้มเลิกกลางทาง',
      adviceTail: 'รักษาจังหวะที่มั่นคง แต่เปิดรับการปรับเล็กน้อยเมื่อจำเป็น',
      workDash: 'งานที่ให้ผลลัพธ์ชัดและทำซ้ำได้ดีเหมาะกับคุณ',
      moneyDash: 'สะสมและวางแผนระยะยาวจะให้ความสบายใจ',
      loveDash: 'ความรักมั่นคงเมื่อมีความไว้ใจและเวลาร่วมกัน',
      healthDash: 'พักผ่อนเพียงพอและกินอย่างสม่ำเสมอช่วยรักษาพลัง',
      luckDash: 'โอกาสดีมักมาจากความสม่ำเสมอมากกว่าการเสี่ยง',
      growthDash: 'ลองยืดหยุ่นบ้างเมื่อแผนเดิมตัน โดยไม่ทิ้งฐานที่มั่นคง',
    ),
    ThaiContentKeys.lagnaGemini: LagnaConsumerTone(
      headlineTail: 'คุณมักเรียนรู้เร็วและสลับมุมมองได้คล่อง',
      heroAccent: 'ความอยากรู้และการสื่อสารเป็นทางผ่านพลังของคุณ',
      strengthTail: 'จุดนี้เด่นเมื่อต้องเชื่อมข้อมูลหรือคนหลายฝ่าย',
      adviceTail: 'โฟกัสเรื่องเดียวให้จบก่อนกระโดดไปเรื่องถัดไป',
      workDash: 'งานที่ต้องสื่อสารและประสานหลายส่วนเหมาะกับคุณ',
      moneyDash: 'กระจายความเสี่ยงดีกว่าลงทุนก้อนเดียว',
      loveDash: 'ความสัมพันธ์ดีเมื่อมีบทสนทนาที่เปิดใจ',
      healthDash: 'พักสมองสั้น ๆ ช่วยลดความเหนื่อยล้าจากการคิดมาก',
      luckDash: 'โอกาสมักมาผ่านคนรู้จักหรือข้อมูลใหม่',
      growthDash: 'ฝึกฟังให้จบก่อนตอบ จะทำให้การสื่อสารลึกขึ้น',
    ),
    ThaiContentKeys.lagnaCancer: LagnaConsumerTone(
      headlineTail: 'คุณใส่ใจความรู้สึกและความปลอดภัยของคนใกล้ชิด',
      heroAccent: 'ความอ่อนไหวและการดูแลเป็นภาษาที่คุณถนัด',
      strengthTail: 'จุดนี้เด่นเมื่อต้องปกป้องหรือสร้างบรรยากาศที่อบอุ่น',
      adviceTail: 'ดูแลใจตัวเองด้วย ไม่ใช่แค่ดูแลคนอื่น',
      workDash: 'งานที่มีความหมายกับคนหรือทีมจะทำให้คุณทุ่มเท',
      moneyDash: 'เก็บออมเพื่อความมั่นคงของครอบครัวหรือคนรัก',
      loveDash: 'ความรักลึกเมื่อรู้สึกปลอดภัยและเป็นตัวเองได้',
      healthDash: 'เวลาพักใจและอยู่กับคนที่ไว้ใจช่วยฟื้นพลัง',
      luckDash: 'โอกาสมักมาผ่านคนที่ไว้ใจหรือชุมชนใกล้ตัว',
      growthDash: 'ลองแบ่งความรู้สึกออกมาบ้าง จะลดภาระในใจ',
    ),
    ThaiContentKeys.lagnaLeo: LagnaConsumerTone(
      headlineTail: 'คุณมักต้องการทำสิ่งที่ภูมิใจและเห็นผลชัด',
      heroAccent: 'ความมั่นใจและการแสดงออกเป็นพลังหลักของคุณ',
      strengthTail: 'จุดนี้เด่นเมื่อได้เป็นตัวแทนหรือนำทีม',
      adviceTail: 'ใช้ความมั่นใจ แต่ฟังความเห็นคนอื่นบ้างก่อนตัดสินใจ',
      workDash: 'งานที่ให้คุณโดดเด่นหรือสร้างผลงานชัดเหมาะกับคุณ',
      moneyDash: 'ลงทุนกับสิ่งที่สะท้อนคุณค่าของตัวเอง',
      loveDash: 'ความรักอบอุ่นเมื่อได้รับการยอมรับและชื่นชมจริงใจ',
      healthDash: 'พักเมื่อรู้สึกหมดไฟ อย่าดึงพลังต่อเนื่องจนเกินไป',
      luckDash: 'โอกาสมักมาเมื่อคุณกล้าแสดงความสามารถ',
      growthDash: 'แบ่งเวทีให้คนอื่นบ้าง จะทำให้ทีมแข็งแกร่งขึ้น',
    ),
    ThaiContentKeys.lagnaVirgo: LagnaConsumerTone(
      headlineTail: 'คุณใส่ใจรายละเอียดและอยากให้ทุกอย่างเรียบร้อย',
      heroAccent: 'ความละเอียดและการปรับปรุงเป็นจุดที่คนไว้วางใจคุณ',
      strengthTail: 'จุดนี้เด่นเมื่องานต้องการความแม่นยำ',
      adviceTail: 'พอใจกับความดีพอ ไม่ต้องไล่ความสมบูรณ์แบบทุกครั้ง',
      workDash: 'งานที่ต้องจัดระบบหรือตรวจทานจะเห็นฝีมือคุณ',
      moneyDash: 'บันทึกรายจ่ายและวางแผนช่วยให้ใจสบาย',
      loveDash: 'ความรักดีขึ้นเมื่อพูดความต้องการตรง ๆ ไม่เก็บไว้',
      healthDash: 'นอนพอและลดการจู้จี้ตัวเองจะช่วยให้ร่างกายเบา',
      luckDash: 'โอกาสมักมาจากงานที่ทำดีจนมีคนแนะนำต่อ',
      growthDash: 'ยอมรับความไม่สมบูรณ์บางส่วน จะทำให้คุณเดินหน้าเร็วขึ้น',
    ),
    ThaiContentKeys.lagnaLibra: LagnaConsumerTone(
      headlineTail: 'คุณมักมองหาสมดุลและความยุติธรรมในการตัดสินใจ',
      heroAccent: 'ความสามารถในการประนีประนอมเป็นจุดแข็งที่คนมักพึ่ง',
      strengthTail: 'จุดนี้เด่นเมื่อต้องหาทางกลางที่ทุกฝ่ายพอใจ',
      adviceTail: 'ตัดสินใจบางเรื่องด้วยตัวเอง ไม่ต้องรอให้ทุกคนเห็นพ้อง',
      workDash: 'งานที่ต้องเจรจาหรือออกแบบความสัมพันธ์เหมาะกับคุณ',
      moneyDash: 'ใช้เงินกับสิ่งที่สร้างความสมดุลในชีวิต',
      loveDash: 'ความรักดีเมื่อมีความเท่าเทียมและเวลาคุณภาพ',
      healthDash: 'ลดความเครียดจากการพยายามทำให้ทุกคนพอใจ',
      luckDash: 'โอกาสมักมาผ่านพันธมิตรหรือเครือข่าย',
      growthDash: 'กล้าบอกความต้องการของตัวเอง แม้จะไม่สมดุลในทุกครั้ง',
    ),
    ThaiContentKeys.lagnaScorpio: LagnaConsumerTone(
      headlineTail: 'คุณมองลึกและไม่ชอบความผิวเผิน',
      heroAccent: 'ความเข้มข้นและความซื่อสัตย์ต่อความรู้สึกเป็นธาตุของคุณ',
      strengthTail: 'จุดนี้เด่นเมื่อต้องเจาะลึกหรือผ่านวิกฤต',
      adviceTail: 'ปล่อยบางเรื่องที่ควบคุมไม่ได้ จะมีพลังไปกับสิ่งสำคัญกว่า',
      workDash: 'งานที่ต้องวิเคราะห์ลึกหรือรักษาความลับเหมาะกับคุณ',
      moneyDash: 'วางแผนรองรับความเสี่ยงที่คำนวณแล้ว',
      loveDash: 'ความรักลึกเมื่อไว้ใจกันจริง ไม่ใช่แค่ผิวเผิน',
      healthDash: 'ปลดปล่อยความตึงในใจจะช่วยให้ร่างกายผ่อนคลาย',
      luckDash: 'โอกาสมักมาหลังผ่านช่วงเปลี่ยนแปลงสำคัญ',
      growthDash: 'ลองเปิดเผยความรู้สึกบางส่วนกับคนที่ปลอดภัย',
    ),
    ThaiContentKeys.lagnaSagittarius: LagnaConsumerTone(
      headlineTail: 'คุณมองไกลและชอบขยายขอบเขตความรู้',
      heroAccent: 'ความกว้างมุมมองและความหวังเป็นพลังขับเคลื่อนของคุณ',
      strengthTail: 'จุดนี้เด่นเมื่อต้องมองภาพใหญ่และสร้างแรงบันดาลใจ',
      adviceTail: 'ลงมือทำทีละขั้น ไม่ต้องรอให้เห็นทั้งหมดก่อนเริ่ม',
      workDash: 'งานที่เกี่ยวกับการเรียนรู้หรือขยายตลาดเหมาะกับคุณ',
      moneyDash: 'ลงทุนกับทักษะและประสบการณ์ระยะยาว',
      loveDash: 'ความรักเติบโตเมื่อทั้งคู่มีเป้าหมายหรือการผจญภัยร่วม',
      healthDash: 'ออกไปขยับร่างกายกลางแจ้งช่วยเติมพลัง',
      luckDash: 'โอกาสมักมาจากการเดินทางหรือคนนอกวงเดิม',
      growthDash: 'ฟังรายละเอียดเล็ก ๆ บ้าง จะช่วยให้แผนใหญ่สำเร็จ',
    ),
    ThaiContentKeys.lagnaCapricorn: LagnaConsumerTone(
      headlineTail: 'คุณให้ความสำคัญกับเป้าหมายระยะยาวและความรับผิดชอบ',
      heroAccent: 'ความอดทนและวินัยทำให้คุณไปถึงไกลกว่าที่คิด',
      strengthTail: 'จุดนี้เด่นเมื่องานต้องใช้เวลาและความมุ่งมั่น',
      adviceTail: 'พักผ่อนบ้าง ความสำเร็จยาวต้องมีพลังสำรอง',
      workDash: 'งานที่มีโครงสร้างและเส้นทางเติบโตชัดเหมาะกับคุณ',
      moneyDash: 'สะสมและลงทุนอย่างมีแผนคือจุดแข็งของคุณ',
      loveDash: 'ความรักมั่นคงเมื่อทั้งสองฝ่ายรับผิดชอบต่อกัน',
      healthDash: 'อย่าละเลยการพักเพราะอยากไปให้ถึงเป้า',
      luckDash: 'โอกาสมักมาจากความสม่ำเสมอและชื่อเสียงที่สะสม',
      growthDash: 'ลองยอมรับความช่วยเหลือ ไม่ต้องแบกทุกอย่างคนเดียว',
    ),
    ThaiContentKeys.lagnaAquarius: LagnaConsumerTone(
      headlineTail: 'คุณคิดต่างและมักมองโลกในมุมใหม่',
      heroAccent: 'ความเป็นอิสระทางความคิดเป็นสิ่งที่คุณถนัด',
      strengthTail: 'จุดนี้เด่นเมื่อต้องคิดนอกกรอบหรือปฏิวัติวิธีเดิม',
      adviceTail: 'เชื่อมโยงกับคนรอบตัวบ้าง ไอเดียดีต้องมีคนช่วยลงมือ',
      workDash: 'งานที่ให้อิสระและท้าทายแบบเดิมเหมาะกับคุณ',
      moneyDash: 'ลงทุนกับนวัตกรรมหรือทักษะที่หายาก',
      loveDash: 'ความรักดีเมื่อเคารพอิสระและความคิดของกันและกัน',
      healthDash: 'พักจากหน้าจอและข้อมูลมากเกินไป',
      luckDash: 'โอกาสมักมาจากเครือข่ายหรือไอเดียที่แปลกใหม่',
      growthDash: 'ลองทำงานร่วมกับทีมบางครั้ง จะได้ผลลัพธ์ใหญ่ขึ้น',
    ),
    ThaiContentKeys.lagnaPisces: LagnaConsumerTone(
      headlineTail: 'คุณรับรู้อารมณ์และบรรยากาศรอบตัวได้ลึก',
      heroAccent: 'ความเห็นอกเห็นใจและจินตนาการเป็นพลังของคุณ',
      strengthTail: 'จุดนี้เด่นเมื่อต้องเข้าใจคนหรือสร้างงานที่มีความหมาย',
      adviceTail: 'ตั้งขอบเขตที่ชัด จะช่วยไม่ให้พลังรั่วไหลไปกับคนอื่น',
      workDash: 'งานที่ใช้ความคิดสร้างสรรค์หรือช่วยเหลือคนเหมาะกับคุณ',
      moneyDash: 'แยกเงินใช้จ่ายกับเงินออมให้ชัดจะสบายใจ',
      loveDash: 'ความรักลึกเมื่อรู้สึกถูกเข้าใจโดยไม่ต้องอธิบายมาก',
      healthDash: 'เวลาอยู่กับธรรมชาติหรือศิลปะช่วยเติมพลัง',
      luckDash: 'โอกาสมักมาผ่านความรู้สึกหรือสัญชาตญาณที่นำทาง',
      growthDash: 'พูด “ไม่” บางครั้งเพื่อปกป้องพลังของตัวเอง',
    ),
  };

  static const _default = LagnaConsumerTone(
    headlineTail: '',
    heroAccent: '',
    strengthTail: '',
    adviceTail: '',
    workDash: '',
    moneyDash: '',
    loveDash: '',
    healthDash: '',
    luckDash: '',
    growthDash: '',
  );

  static LagnaConsumerTone tone(String? lagnaKey) {
    if (lagnaKey == null || lagnaKey.isEmpty) return _default;
    return _tones[lagnaKey] ?? _default;
  }

  static String headlineVariant(String? lagnaKey, int seed) {
    final t = tone(lagnaKey);
    if (t.headlineTail.isEmpty) return '';
    final alts = [t.headlineTail, t.heroAccent, t.growthDash]
        .where((s) => s.isNotEmpty)
        .toSet()
        .toList();
    return alts[seed.abs() % alts.length];
  }

  static String heroAccentVariant(String? lagnaKey, int seed) {
    final t = tone(lagnaKey);
    if (t.heroAccent.isEmpty) return '';
    final alts = [t.heroAccent, t.headlineTail, t.strengthTail]
        .where((s) => s.isNotEmpty)
        .toSet()
        .toList();
    return alts[seed.abs() % alts.length];
  }

  static String strengthVariant(String? lagnaKey, int seed) {
    final t = tone(lagnaKey);
    if (t.strengthTail.isEmpty) return '';
    final alts = [t.strengthTail, t.growthDash, t.heroAccent]
        .where((s) => s.isNotEmpty)
        .toSet()
        .toList();
    return alts[seed.abs() % alts.length];
  }

  static String adviceVariant(String? lagnaKey, int seed) {
    final t = tone(lagnaKey);
    if (t.adviceTail.isEmpty) return '';
    final alts = [t.adviceTail, t.growthDash, t.headlineTail]
        .where((s) => s.isNotEmpty)
        .toSet()
        .toList();
    return alts[seed.abs() % alts.length];
  }

  static String dashboardVariant(String? lagnaKey, String aspect, int seed) {
    final t = tone(lagnaKey);
    final aspectDash = t.dashboardFor(aspect);
    final alts = [aspectDash, t.growthDash, t.adviceTail, t.strengthTail]
        .where((s) => s.isNotEmpty)
        .toSet()
        .toList();
    if (alts.isEmpty) return '';
    return alts[seed.abs() % alts.length];
  }

  static List<String> lagnaKeysForValidation() => _tones.keys.toList();
}
