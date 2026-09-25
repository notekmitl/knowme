import 'package:knowme/data/models/astrology_chart_model.dart';

/// Meaning fragments keyed by calculated natal planet signs. This V2 registry
/// mirrors the Western reader's sign meanings, while remaining independent of
/// its Thai sentence layout. Missing planet/sign codes never imply a meaning.
abstract final class WesternNatalLifeSemantics {
  static String workMethod(AstrologyChartModel chart) =>
      _mercuryWork[_sign(chart, 'mercury')] ?? '';

  static String moneyValue(AstrologyChartModel chart) =>
      _venusMoney[_sign(chart, 'venus')] ?? '';

  static String relationshipStyle(AstrologyChartModel chart) =>
      _venusLove[_sign(chart, 'venus')] ?? '';

  static String _sign(AstrologyChartModel chart, String planet) {
    final raw = chart.planets[planet];
    if (raw is! Map || raw['sign'] is! String) return '';
    return (raw['sign'] as String).trim();
  }

  static const _mercuryWork = <String, String>{
    'Aries': 'จับประเด็นแล้วตอบสนองเร็ว',
    'Taurus': 'คิดเป็นขั้นและต้องเห็นว่าวิธีนั้นใช้ได้จริง',
    'Gemini': 'เรียนรู้ไว เชื่อมข้อมูลหลายชุด และอธิบายเรื่องยากให้คนตามทัน',
    'Cancer': 'จดจำบริบทของคนและอ่านน้ำหนักทางอารมณ์ในการสื่อสาร',
    'Leo': 'สื่อสารด้วยภาพใหญ่และทำให้คนเห็นความสำคัญของเรื่องนั้น',
    'Virgo': 'แยกปัญหาเป็นส่วนย่อย ตรวจรายละเอียด และปรับกระบวนการ',
    'Libra': 'เปรียบเทียบหลายมุมและหาถ้อยคำที่ทุกฝ่ายร่วมงานกันได้',
    'Scorpio': 'ค้นข้อมูลลึก จับประเด็นที่ซ่อนอยู่ และรักษาความลับได้',
    'Sagittarius': 'คิดจากภาพใหญ่ เรียนรู้ผ่านประสบการณ์ และชวนคนมองไกลขึ้น',
    'Capricorn': 'จัดลำดับเหตุผล วางกรอบ และสื่อสารตามเป้าหมายระยะยาว',
    'Aquarius': 'มองระบบ เห็นความเชื่อมโยง และเสนอวิธีที่ต่างจากของเดิม',
    'Pisces': 'คิดเชิงภาพและความรู้สึก จับบรรยากาศ และเล่าเรื่องให้คนเห็นภาพ',
  };

  static const _venusMoney = <String, String>{
    'Aries': 'ความคล่องตัวและสิทธิ์เลือกทันที',
    'Taurus': 'คุณภาพ ความสบาย และสิ่งที่อยู่ได้นาน',
    'Gemini': 'ทางเลือก ข้อมูล และประสบการณ์ใหม่',
    'Cancer': 'ความมั่นคงของบ้านและคนใกล้ตัว',
    'Leo': 'คุณภาพที่ทำให้ภูมิใจและการแบ่งปันกับคนสำคัญ',
    'Virgo': 'ประโยชน์จริง รายละเอียด และความคุ้มค่า',
    'Libra': 'ความสวยงาม ความพอดี และการแบ่งกันอย่างเป็นธรรม',
    'Scorpio': 'ความไว้ใจ ความเป็นส่วนตัว และคุณค่าที่ลึกจริง',
    'Sagittarius': 'อิสระ การเรียนรู้ และประสบการณ์ที่เปิดโลก',
    'Capricorn': 'ความมั่นคง มาตรฐาน และผลระยะยาว',
    'Aquarius': 'อิสระทางเลือก เทคโนโลยี และสิ่งที่มีประโยชน์ต่อกลุ่ม',
    'Pisces': 'ความหมาย ความรู้สึก และการช่วยเหลือ',
  };

  static const _venusLove = <String, String>{
    'Aries': 'แสดงความสนใจตรงและชอบความสัมพันธ์ที่มีชีวิตชีวา',
    'Taurus': 'แสดงความรักผ่านความสม่ำเสมอ การสัมผัส และการดูแลที่จับต้องได้',
    'Gemini': 'ผูกพันผ่านบทสนทนา อารมณ์ขัน และความอยากรู้อยากเห็น',
    'Cancer': 'ดูแลผ่านความใส่ใจและการสร้างพื้นที่ที่ไว้ใจกัน',
    'Leo': 'รักอย่างเปิดเผย อบอุ่น และให้ความสำคัญกับการเห็นคุณค่ากัน',
    'Virgo': 'แสดงความรักผ่านการช่วยแก้ปัญหาและดูแลรายละเอียด',
    'Libra': 'ให้ค่ากับการรับฟัง ความสุภาพ และการตัดสินใจร่วมกัน',
    'Scorpio': 'ผูกพันลึกและให้ความสำคัญกับความซื่อตรง',
    'Sagittarius': 'รักผ่านการแบ่งปันประสบการณ์ ความคิด และการเติบโต',
    'Capricorn': 'แสดงความรักผ่านความรับผิดชอบและการวางแผนอนาคต',
    'Aquarius': 'ต้องการความเป็นเพื่อน ความเท่าเทียม และพื้นที่เป็นตัวเอง',
    'Pisces': 'รับรู้ความรู้สึกละเอียดและพร้อมอ่อนโยนกับคนรัก',
  };
}
