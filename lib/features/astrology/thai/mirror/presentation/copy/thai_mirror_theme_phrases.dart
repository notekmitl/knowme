import 'thai_mirror_theme_life_hints.dart';
class ThaiThemePhrase {
  const ThaiThemePhrase({
    required this.tag,
    required this.headlinePart,
    required this.heroDetail,
    this.strengthTitle = 'มีจุดเด่นในตัวเอง',
    this.strengthBody = 'คุณมีความสามารถที่ค่อย ๆ ปรากฏเมื่อได้ทำในสิ่งที่ถนัด',
    this.cautionTitle,
    this.cautionBody,
    this.advice,
    this.workHint,
    this.moneyHint,
    this.loveHint,
    this.healthHint,
    this.luckHint,
  });

  final String tag;
  final String headlinePart;
  final String heroDetail;
  final String strengthTitle;
  final String strengthBody;
  final String? cautionTitle;
  final String? cautionBody;
  final String? advice;
  final String? workHint;
  final String? moneyHint;
  final String? loveHint;
  final String? healthHint;
  final String? luckHint;
}

abstract final class ThaiMirrorThemePhrases {
  static const _fallback = ThaiThemePhrase(
    tag: 'มีเอกลักษณ์',
    headlinePart: 'มีสไตล์เป็นของตัวเอง',
    heroDetail: 'คุณมีวิธีคิดและวิธีใช้ชีวิตที่เป็นแบบฉบับของคุณ',
    strengthTitle: 'ทำตัวได้ดีในแบบของตัวเอง',
    strengthBody:
        'คุณมักรู้ว่าอะไรเหมาะกับตัวเอง เวลาได้ทำในแบบที่ถนัดจะเห็นผลชัดที่สุด',
    workHint: 'เลือกงานที่ให้คุณใช้จุดแข็งได้เต็มที่',
    moneyHint: 'วางแผนการใช้จ่ายตามความสามารถจริงของตัวเอง',
    loveHint: 'ความสัมพันธ์ดีขึ้นเมื่อคุณเป็นตัวเองอย่างตรงไปตรงมา',
    healthHint: 'พักผ่อนพอและฟังสัญญาณจากร่างกายบ้าง',
    luckHint: 'โอกาสมักมาเมื่อคุณเปิดใจลองสิ่งใหม่ที่เหมาะกับตัวเอง',
  );

  static const Map<String, ThaiThemePhrase> all = {
    'independent': ThaiThemePhrase(
      tag: 'ชอบทำเอง',
      headlinePart: 'ชอบพึ่งตัวเอง',
      heroDetail: 'คุณชอบตัดสินใจเองและไม่อยากรอให้ใครมาบอกทุกขั้นตอน',
      strengthTitle: 'เดินด้วยตัวเองได้ดี',
      strengthBody:
          'เวลาต้องลุยคนเดียวคุณไม่ติดขัดง่าย ๆ และมักหาทางออกได้ด้วยความมั่นใจในตัวเอง',
      workHint: 'งานที่ให้อิสระในการตัดสินใจเหมาะกับคุณ',
      loveHint: 'คุณให้ความสำคัญกับพื้นที่ส่วนตัวในความสัมพันธ์',
    ),
    'disciplined': ThaiThemePhrase(
      tag: 'รับผิดชอบ',
      headlinePart: 'รับผิดชอบสูง',
      heroDetail: 'คุณมักทำตามสัญญาและไม่ทิ้งงานค้างกลางทาง',
      strengthTitle: 'ทำจริงจังเมื่อให้คำมั่น',
      strengthBody:
          'เวลามอบหมายงานคุณจัดลำดับและทำจนสำเร็จ คนรอบข้างเลยไว้ใจให้ดูแลเรื่องสำคัญ',
      workHint: 'งานที่ต้องทำต่อเนื่องและมีระเบียบคือจุดแข็งของคุณ',
      moneyHint: 'คุณมักวางแผนการใช้จ่ายอย่างรอบคอบ ไม่ใช้เงินมั่ว ๆ',
    ),
    'curious': ThaiThemePhrase(
      tag: 'อยากรู้',
      headlinePart: 'ชอบเรียนรู้',
      heroDetail: 'คุณชอบถาม ชอบลอง และเปิดรับสิ่งใหม่ได้เร็ว',
      strengthTitle: 'เรียนรู้เร็วและลุยต่อได้',
      strengthBody:
          'เวลาเจอเรื่องใหม่คุณมักงอกงันไปกับมัน แล้วเอาความรู้ไปใช้ได้จริงในชีวิต',
      luckHint: 'โอกาสใหม่มักเข้ามาเมื่อคุณกล้าลองสิ่งที่ยังไม่เคยทำ',
    ),
    'practical': ThaiThemePhrase(
      tag: 'ลงมือทำ',
      headlinePart: 'ลงมือทำเป็นจริง',
      heroDetail: 'คุณเลือกทางที่ทำได้จริงมากกว่าคุยสวย ๆ แต่ลงมือยาก',
      strengthTitle: 'เลือกทางที่ใช้ได้จริง',
      strengthBody:
          'เวลาต้องตัดสินใจคุณมักถามว่า “ทำได้ไหม” ก่อน “ฟังดูดีไหม” ทำให้งานออกมาใช้ได้จริง',
      moneyHint: 'คุณใช้เงินกับสิ่งที่จำเป็นและคุ้มค่า ไม่ฟุ่มเฟือยโดยไม่จำเป็น',
    ),
    'grounded': ThaiThemePhrase(
      tag: 'มั่นคง',
      headlinePart: 'มั่นคงและนิ่ง',
      heroDetail: 'คุณชอบความมั่นคงและไม่ชอบเปลี่ยนแปลงบ่อยเกินไป',
      strengthTitle: 'ยืนหยัดได้ดีในวันที่วุ่นวาย',
      strengthBody:
          'เวลารอบข้างตื่นตระหนก คุณมักเป็นคนที่ยังคิดเป็นระเบียบและช่วยให้ทุกอย่างนิ่งลง',
      healthHint: 'รักษาสมดุลชีวิตด้วยกิจวัตรที่มั่นคงจะช่วยให้คุณแข็งแรง',
    ),
    'visionary': ThaiThemePhrase(
      tag: 'มองไกล',
      headlinePart: 'มองอนาคตไกล',
      heroDetail: 'คุณชอบคิดถึงภาพใหญ่และสิ่งที่อยากสร้างในระยะยาว',
      strengthTitle: 'เห็นภาพใหญ่ชัด',
      strengthBody:
          'คุณมักบอกได้ว่าอยากไปถึงไหน แล้วค่อย ๆ วางทีละก้าวให้ใกล้เป้าหมายนั้น',
      workHint: 'งานที่มีเป้าหมายชัดเจนจะดึงพลังของคุณออกมาได้เต็มที่',
      luckHint: 'โอกาสดีมักมาจากการที่คุณเห็นทางที่คนอื่นยังมองไม่เห็น',
    ),
    'protective': ThaiThemePhrase(
      tag: 'เอาใจใส่',
      headlinePart: 'เอาใจใส่คนใกล้ชิด',
      heroDetail: 'คุณใส่ใจคนที่รักและอยากให้คนรอบข้างปลอดภัย',
      strengthTitle: 'ดูแลคนรอบข้างได้ดี',
      strengthBody:
          'เวลาใครมีปัญหา คุณมักเป็นคนแรกที่เข้าไปช่วยหรือให้กำลังใจ',
      loveHint: 'คุณแสดงความรักผ่านการดูแลและอยู่เคียงข้างเมื่อต้องการ',
    ),
    'adaptable': ThaiThemePhrase(
      tag: 'ปรับตัวเก่ง',
      headlinePart: 'ปรับตัวเก่ง',
      heroDetail: 'เมื่อสถานการณ์เปลี่ยน คุณมักหาทางใหม่ได้ไม่นาน',
      strengthTitle: 'ยืดหยุ่นเมื่อสถานการณ์เปลี่ยน',
      strengthBody:
          'แผนอาจพัง แต่คุณมักไม่ติดขัดนาน แล้วหาวิธีอื่นที่ยังไปต่อได้',
      workHint: 'งานที่ต้องรับมือกับความเปลี่ยนแปลงบ่อย ๆ คุณทำได้ดี',
    ),
    'creative': ThaiThemePhrase(
      tag: 'คิดสร้างสรรค์',
      headlinePart: 'คิดสร้างสรรค์',
      heroDetail: 'คุณชอบทำสิ่งที่แตกต่างและแสดงตัวตนในแบบของตัวเอง',
      strengthTitle: 'หาไอเดียใหม่ได้',
      strengthBody:
          'เวลาติดขัด คุณมักคิดทางออกที่คนอื่นไม่นึกถึง ทำให้งานมีสีสันและน่าสนใจ',
      workHint: 'งานที่ให้คุณออกแบบหรือคิดเองจะทำให้คุณมีพลัง',
    ),
    'ambitious': ThaiThemePhrase(
      tag: 'มุ่งมั่น',
      headlinePart: 'มุ่งมั่นและไม่หยุด',
      heroDetail: 'เมื่อตั้งใจแล้ว คุณมักผลักดันตัวเองไปข้างหน้าอย่างต่อเนื่อง',
      strengthTitle: 'มีแรงขับเคลื่อนสูง',
      strengthBody:
          'คุณไม่พอใจกับการยืนอยู่กับที่ ชอบเติบโตและทำให้ตัวเองเก่งขึ้นเรื่อย ๆ',
      workHint: 'เป้าหมายที่ท้าทายจะทำให้คุณตื่นเต้นและทุ่มเท',
    ),
    'analytical': ThaiThemePhrase(
      tag: 'คิดละเอียด',
      headlinePart: 'ชอบคิดก่อนทำ',
      heroDetail: 'คุณชอบแยกปัญหาเป็นส่วน ๆ ก่อนตัดสินใจครั้งใหญ่',
      strengthTitle: 'คิดรอบคอบก่อลงมือ',
      strengthBody:
          'เวลาเลือกทาง คุณมักดูข้อดีข้อเสียก่อน ทำให้ตัดสินใจแล้วเสียใจน้อยลง',
      cautionTitle: 'อย่าคิดนานจนเสียจังหวะ',
      cautionBody:
          'บางครั้งข้อมูลพอแล้วแต่คุณยังคิดต่อ ลองตั้งเวลาตัดสินใจเพื่อไม่พลาดโอกาส',
    ),
    'strategic': ThaiThemePhrase(
      tag: 'วางแผนเก่ง',
      headlinePart: 'วางแผนเก่ง',
      heroDetail: 'คุณชอบคิดล่วงหน้าและเชื่อมทุกอย่างเข้ากับเป้าหมายใหญ่',
      strengthTitle: 'มองถึงขั้นตอนถัดไป',
      strengthBody:
          'คุณไม่ได้แค่ทำวันนี้ให้เสร็จ แต่คิดด้วยว่าขั้นต่อไปควรเป็นอย่างไร',
      workHint: 'งานที่ต้องวางแผนระยะยาวเหมาะกับคุณมาก',
    ),
    'reflective': ThaiThemePhrase(
      tag: 'ใคร่ครวญ',
      headlinePart: 'ใคร่ครวญก่อนตอบ',
      heroDetail: 'คุณไม่รีบตอบทุกอย่าง ชอบคิดให้ดีก่อนพูดหรือทำ',
      strengthTitle: 'คิดก่อนลงมือ',
      strengthBody:
          'คุณมักเห็นมุมที่คนอื่นมองข้าม เพราะใช้เวลาทบทวนสิ่งที่เกิดขึ้น',
      healthHint: 'การมีเวลาอยู่กับตัวเองช่วยให้คุณฟื้นพลังได้ดี',
    ),
    'big_picture': ThaiThemePhrase(
      tag: 'มองภาพรวม',
      headlinePart: 'มองภาพรวม',
      heroDetail: 'คุณเห็นภาพใหญ่ก่อนรายละเอียดเล็ก ๆ',
      strengthTitle: 'เห็นทั้งป่าทั้งต้นไม้',
      strengthBody:
          'เวลาทีมติดรายละเอียด คุณมักช่วยดึงกลับมาที่เป้าหมายหลักได้',
      workHint: 'บทบาทที่ต้องประสานงานหลายส่วนเข้าด้วยกันเหมาะกับคุณ',
    ),
    'detail_oriented': ThaiThemePhrase(
      tag: 'ใส่ใจรายละเอียด',
      headlinePart: 'ใส่ใจรายละเอียด',
      heroDetail: 'คุณสังเกตสิ่งเล็ก ๆ ที่คนอื่นมองข้ามได้ดี',
      strengthTitle: 'งานละเอียดออกมาดี',
      strengthBody:
          'งานที่ต้องแม่นยำคุณทำได้ดี เพราะไม่ปล่อยให้ข้อผิดพลาดเล็ก ๆ หลุดไปง่าย ๆ',
      cautionTitle: 'อย่าติดรายละเอียดจนลืมภาพใหญ่',
      cautionBody:
          'บางครั้งงานเสร็จพอใช้ได้แล้ว ไม่จำเป็นต้องเก็บทุกจุดให้สมบูรณ์แบบ',
    ),
    'fast_moving': ThaiThemePhrase(
      tag: 'ลงมือเร็ว',
      headlinePart: 'ลงมือเร็ว',
      heroDetail: 'เมื่อรู้ว่าต้องทำอะไร คุณมักเริ่มได้ทันทีไม่รอนาน',
      strengthTitle: 'เริ่มได้เร็ว',
      strengthBody:
          'คุณไม่ค่อยรอจังหวะสมบูรณ์แบบ ทำให้งานเดินหน้าได้เร็วกว่าที่คาด',
      cautionTitle: 'อย่ารีบจนลืมตรวจสอบ',
      cautionBody:
          'ลองหยุดสักครู่ก่อนส่งงานสำคัญ เพื่อให้แน่ใจว่าไม่พลาดรายละเอียดสำคัญ',
    ),
    'systematic': ThaiThemePhrase(
      tag: 'เป็นระบบ',
      headlinePart: 'จัดระเบียบเก่ง',
      heroDetail: 'คุณชอบจัดลำดับงานเป็นขั้นตอน ทำให้สิ่งซับซ้อนดูง่ายขึ้น',
      strengthTitle: 'ทำงานเป็นระบบ',
      strengthBody:
          'เวลางานยุ่ง คุณมักแยกเป็นขั้นตอนแล้วไล่ทำทีละอย่างจนจบ',
      workHint: 'งานที่ต้องมีกระบวนการชัดเจนคุณทำได้ดีมาก',
    ),
    'empathetic': ThaiThemePhrase(
      tag: 'เข้าใจคนอื่น',
      headlinePart: 'เข้าใจความรู้สึกคนอื่น',
      heroDetail: 'คุณรับรู้ได้ว่าคนรอบข้างรู้สึกอย่างไร และมักตอบสนองอย่างเหมาะสม',
      strengthTitle: 'ฟังและเข้าใจคนอื่น',
      strengthBody:
          'เวลาใครเล่าเรื่อง คุณมักทำให้เขารู้สึกว่าถูกเข้าใจ ไม่ใช่แค่ถูกฟัง',
      loveHint: 'ความสัมพันธ์ลึกขึ้นเมื่อคุณใส่ใจความรู้สึกของอีกฝ่าย',
    ),
    'sensitive': ThaiThemePhrase(
      tag: 'รู้สึกลึก',
      headlinePart: 'รู้สึกลึกซึ้ง',
      heroDetail: 'คุณรับรู้ความรู้สึกได้ละเอียด ทั้งของตัวเองและคนรอบข้าง',
      strengthTitle: 'สัมผัสอารมณ์ได้ละเอียด',
      strengthBody:
          'คุณมักรู้ว่าตอนนี้บรรยากาศเป็นอย่างไร และปรับตัวให้เหมาะกับสถานการณ์',
      healthHint: 'พักผ่อนเมื่อรู้สึกอ่อนล้าทางใจ จะช่วยให้คุณฟื้นตัวได้เร็ว',
      cautionTitle: 'อย่าเก็บความรู้สึกไว้คนเดียวนานเกินไป',
      cautionBody:
          'ลองเล่าให้คนที่ไว้ใจฟังบ้าง จะช่วยลดภาระในใจได้มาก',
    ),
    'stable': ThaiThemePhrase(
      tag: 'อารมณ์นิ่ง',
      headlinePart: 'อารมณ์มั่นคง',
      heroDetail: 'แม้มีเรื่องกดดัน คุณมักยังคงใจเย็นและคิดได้',
      strengthTitle: 'ใจนิ่งในวันที่วุ่นวาย',
      strengthBody:
          'เวลาเกิดปัญหา คนรอบข้างมักพึ่งคุณเพราะคุณไม่ตื่นตระหนกง่าย ๆ',
      healthHint: 'รักษาจังหวะชีวิตสม่ำเสมอจะช่วยให้คุณแข็งแรงต่อเนื่อง',
    ),
    'expressive': ThaiThemePhrase(
      tag: 'แสดงออกชัด',
      headlinePart: 'แสดงออกชัดเจน',
      heroDetail: 'เมื่อรู้สึกอะไร คุณมักบอกได้และทำให้คนอื่นเข้าใจตัวคุณ',
      strengthTitle: 'สื่อสารความรู้สึกได้ชัด',
      strengthBody:
          'คุณไม่ปล่อยให้คนเดาเอาเอง ทำให้ความสัมพันธ์โปร่งใสและลดความเข้าใจผิด',
      loveHint: 'พูดความรู้สึกตรง ๆ ในที่ที่ปลอดภัยจะทำให้ความรักแน่นแฟ้นขึ้น',
    ),
    'reserved': ThaiThemePhrase(
      tag: 'เก็บตัว',
      headlinePart: 'เก็บตัวแต่ลึก',
      heroDetail: 'คุณไม่เปิดเผยทุกอย่างกับทุกคน แต่เมื่อไว้ใจแล้วจะจริงจังมาก',
      strengthTitle: 'ไว้ใจอย่างมีขอบเขต',
      strengthBody:
          'คุณเลือกคนที่จะเปิดใจอย่างรอบคอบ ทำให้ความสัมพันธ์ที่มีอยู่ลึกและจริงใจ',
      loveHint: 'ให้เวลาค่อย ๆ เปิดใจ ความสัมพันธ์จะแน่นแฟ้นเมื่อไว้ใจกันแล้ว',
    ),
    'resilient': ThaiThemePhrase(
      tag: 'ฟื้นตัวเก่ง',
      headlinePart: 'ฟื้นตัวจากความยากลำบาก',
      heroDetail: 'แม้ล้ม คุณมักลุกขึ้นมาและเดินต่อได้ไม่นาน',
      strengthTitle: 'ไม่ยอมแพ้ง่าย ๆ',
      strengthBody:
          'ความยากลำบากไม่ได้ทำให้คุณหยุดถาวร คุณมักหาทางกลับมาแข็งแกร่งกว่าเดิม',
      healthHint: 'พักผ่อนหลังผ่านช่วงหนัก จะช่วยให้คุณฟื้นกลับมาได้เต็มที่',
    ),
    'calm_under_pressure': ThaiThemePhrase(
      tag: 'ใจเย็น',
      headlinePart: 'ใจเย็นเมื่อกดดัน',
      heroDetail: 'ยิ่งเร่งยิ่งมีสติ คุณมักยังคิดได้แม้ในสถานการณ์เร่งด่วน',
      strengthTitle: 'สงบในวิกฤต',
      strengthBody:
          'เวลาเกิดเหตุฉุกเฉิน คุณมักเป็นคนที่ช่วยให้ทุกคนตั้งสติและหาทางออก',
      workHint: 'งานที่มีแรงกดดันสูงคุณรับมือได้ดีกว่าที่คิด',
    ),
    'loyal': ThaiThemePhrase(
      tag: 'ซื่อสัตย์',
      headlinePart: 'ซื่อสัตย์ต่อคนใกล้ชิด',
      heroDetail: 'เมื่อไว้ใจใครแล้ว คุณมักยืนข้างเขาอย่างจริงจัง',
      strengthTitle: 'ซื่อสัตย์ในความสัมพันธ์',
      strengthBody:
          'คุณไม่ทิ้งคนที่รักง่าย ๆ ทำให้คนรอบข้างรู้สึกมั่นใจเมื่ออยู่กับคุณ',
      loveHint: 'ความไว้วางใจคือหัวใจของความสัมพันธ์ที่คุณสร้าง',
    ),
    'supportive': ThaiThemePhrase(
      tag: 'คอยสนับสนุน',
      headlinePart: 'คอยสนับสนุนคนรอบข้าง',
      heroDetail: 'คุณชอบช่วยให้คนอื่นก้าวไปข้างหน้าและไม่ทิ้งใครไว้คนเดียว',
      strengthTitle: 'เป็นกำลังใจให้คนอื่น',
      strengthBody:
          'เวลาใครท้อ คุณมักอยู่ข้าง ๆ และช่วยหาทางออกไปด้วยกัน',
      loveHint: 'คุณแสดงความรักผ่านการอยู่เคียงข้างและช่วยเหลือจริง ๆ',
    ),
    'relationship_oriented': ThaiThemePhrase(
      tag: 'ให้ความสำคัญกับความสัมพันธ์',
      headlinePart: 'ให้ความสำคัญกับความสัมพันธ์',
      heroDetail: 'คุณใส่ใจคนรอบข้างมาก และความสัมพันธ์คือสิ่งสำคัญในชีวิต',
      strengthTitle: 'สร้างความสัมพันธ์ได้ดี',
      strengthBody:
          'คุณมักจำรายละเอียดเล็ก ๆ ของคนสำคัญ และทำให้เขารู้สึกมีค่า',
      loveHint: 'ลงเวลากับคนรักอย่างตั้งใจ ความสัมพันธ์จะเติบโตอย่างมั่นคง',
    ),
    'independent_in_relationships': ThaiThemePhrase(
      tag: 'มีพื้นที่ส่วนตัว',
      headlinePart: 'มีพื้นที่ส่วนตัวในความรัก',
      heroDetail: 'คุณรักคนใกล้ชิด แต่ยังต้องการเวลาและพื้นที่ของตัวเอง',
      strengthTitle: 'รักอย่างมีขอบเขต',
      strengthBody:
          'คุณไม่ต้องอยู่ติดกันตลอดเวลาเพื่อรู้สึกมั่นใจ ทำให้ความสัมพันธ์สบายและยั่งยืน',
      loveHint: 'บอกคู่ของคุณว่าต้องการเวลาส่วนตัวบ้าง จะช่วยลดความเข้าใจผิด',
    ),
    'protective_of_others': ThaiThemePhrase(
      tag: 'ปกป้องคนรัก',
      headlinePart: 'ปกป้องคนรัก',
      heroDetail: 'คุณไม่ยอมให้คนที่รักถูกทำร้ายหรือถูกเอาเปรียบง่าย ๆ',
      strengthTitle: 'ดูแลคนสำคัญ',
      strengthBody:
          'เวลาใครที่คุณรักมีปัญหา คุณมักเข้าไปช่วยหรือปกป้องทันที',
      loveHint: 'แสดงความห่วงใยโดยไม่ต้องควบคุมทุกอย่างในชีวิตของเขา',
    ),
    'diplomatic': ThaiThemePhrase(
      tag: 'หาจุดร่วม',
      headlinePart: 'หาจุดร่วมเก่ง',
      heroDetail: 'เวลามีความขัดแย้ง คุณมักหาทางที่ทุกฝ่ายยอมรับได้',
      strengthTitle: 'คุยกันแล้วจบ',
      strengthBody:
          'คุณไม่ชอบทะเลาะยืดเยื้อ มักหาทางกลางที่ทุกคนยังเดินหน้าต่อได้',
      loveHint: 'พูดจากความรู้สึกจริง แต่เลือกคำที่ไม่ทำร้ายอีกฝ่าย',
    ),
    'builder': ThaiThemePhrase(
      tag: 'สร้างผลงาน',
      headlinePart: 'สร้างผลงานได้จริง',
      heroDetail: 'คุณไม่ได้แค่เริ่มต้น แต่ทำจนเห็นผลลัพธ์ที่จับต้องได้',
      strengthTitle: 'ทำจนเห็นผล',
      strengthBody:
          'งานที่คุณลงมือมักมีความต่อเนื่องและสร้างมูลค่าระยะยาว ไม่ใช่แค่ชั่วคราว',
      workHint: 'งานที่ต้องสร้างผลลัพธ์ยั่งยืนเหมาะกับคุณที่สุด',
    ),
    'leader': ThaiThemePhrase(
      tag: 'เป็นผู้นำ',
      headlinePart: 'เป็นผู้นำโดยธรรมชาติ',
      heroDetail: 'คนรอบข้างมักหันมาถามคุณเวลาต้องการทิศทาง',
      strengthTitle: 'ชี้ทางและสร้างแรงบันดาลใจ',
      strengthBody:
          'คุณมักเห็นภาพรวมก่อน แล้วช่วยให้ทีมรู้ว่าต้องไปทางไหน',
      workHint: 'บทบาทที่ต้องประสานทีมหรือตัดสินใจนำหน้าเหมาะกับคุณ',
    ),
    'explorer': ThaiThemePhrase(
      tag: 'ชอบสำรวจ',
      headlinePart: 'ชอบลองสิ่งใหม่',
      heroDetail: 'คุณเบื่อกับของเดิม ๆ และชอบเปิดประสบการณ์ใหม่',
      strengthTitle: 'กล้าลองสิ่งใหม่',
      strengthBody:
          'คุณมักเป็นคนแรกที่ลองทางที่ยังไม่มีใครกล้า แล้วเปิดทางให้คนอื่นตาม',
      luckHint: 'โอกาสดีมักมาจากการที่คุณกล้าออกจากโซนสบาย',
    ),
    'specialist': ThaiThemePhrase(
      tag: 'เชี่ยวชาญเฉพาะทาง',
      headlinePart: 'เชี่ยวชาญในสิ่งที่ถนัด',
      heroDetail: 'คุณชอบเจาะลึกในสิ่งที่สนใจจนเก่งกว่าคนทั่วไป',
      strengthTitle: 'เก่งในจุดที่โฟกัส',
      strengthBody:
          'เมื่อคุณสนใจเรื่องใดจริงจัง คุณมักเก่งขึ้นเร็วและเป็นที่ปรึกษาของคนอื่น',
      workHint: 'งานเฉพาะทางที่ให้คุณเจาะลึกจะทำให้คุณโดดเด่น',
    ),
    'teacher': ThaiThemePhrase(
      tag: 'ชอบสอน',
      headlinePart: 'ชอบถ่ายทอดความรู้',
      heroDetail: 'คุณมีความสุขเมื่อช่วยให้คนอื่นเข้าใจสิ่งที่คุณรู้',
      strengthTitle: 'อธิบายให้คนอื่นเข้าใจ',
      strengthBody:
          'คุณมักหาคำพูดที่ทำให้เรื่องยากกลายเป็นเรื่องง่าย',
      workHint: 'งานที่ต้องสอนหรือแนะนำคนอื่นเหมาะกับคุณ',
    ),
    'entrepreneurial': ThaiThemePhrase(
      tag: 'กล้าลอง',
      headlinePart: 'กล้าลองและลงมือทำ',
      heroDetail: 'คุณไม่รอโอกาสมาหา มักสร้างโอกาสด้วยตัวเอง',
      strengthTitle: 'กล้าเริ่มต้น',
      strengthBody:
          'แม้ไม่แน่ใจหมด คุณก็มักลองก่อนแล้วปรับไปทีละน้อย',
      workHint: 'งานที่ให้คุณริเริ่มเองจะทำให้คุณมีพลังสูงสุด',
      luckHint: 'โอกาสมักมาจากการที่คุณกล้าลงมือทำก่อนคนอื่น',
    ),
    'innovator': ThaiThemePhrase(
      tag: 'คิดนอกกรอบ',
      headlinePart: 'คิดนอกกรอบ',
      heroDetail: 'คุณชอบปรับปรุงวิธีเดิม ๆ ให้ดีขึ้นหรือแตกต่าง',
      strengthTitle: 'หาทางใหม่ได้',
      strengthBody:
          'เวลาเจอระบบที่ตัน คุณมักเสนอวิธีที่คนอื่นไม่เคยคิด',
      workHint: 'งานที่ต้องคิดวิธีใหม่ ๆ จะดึงความสามารถของคุณออกมา',
    ),
    'persistence': ThaiThemePhrase(
      tag: 'อดทน',
      headlinePart: 'อดทนต่อเนื่อง',
      heroDetail: 'แม้ช้า คุณก็ไม่เลิกกลางคันง่าย ๆ',
      strengthTitle: 'ไม่ยอมแพ้กลางทาง',
      strengthBody:
          'คุณมักทำต่อแม้ไม่มีใครเห็นผลทันที จนกว่าจะสำเร็จ',
      workHint: 'งานระยะยาวที่ต้องอดทนคุณทำได้ดี',
    ),
    'communication': ThaiThemePhrase(
      tag: 'สื่อสารเก่ง',
      headlinePart: 'สื่อสารเก่ง',
      heroDetail: 'คุณถ่ายทอดความคิดให้คนอื่นเข้าใจได้ชัด',
      strengthTitle: 'พูดแล้วคนเข้าใจ',
      strengthBody:
          'เวลาต้องอธิบายเรื่องซับซ้อน คุณมักหาคำที่ทำให้ทุกคนตรงกัน',
      workHint: 'งานที่ต้องประสานงานหลายฝ่ายคุณทำได้ดี',
    ),
    'adaptability': ThaiThemePhrase(
      tag: 'ยืดหยุ่น',
      headlinePart: 'ยืดหยุ่นสูง',
      heroDetail: 'เมื่อแผนเปลี่ยน คุณมักปรับตัวได้เร็วไม่ติดขัดนาน',
      strengthTitle: 'ปรับตัวได้เร็ว',
      strengthBody:
          'คุณไม่ยึดติดกับวิธีเดิม ทำให้ผ่านช่วงเปลี่ยนแปลงได้ง่ายกว่าคนอื่น',
    ),
    'leadership': ThaiThemePhrase(
      tag: 'นำทีมได้',
      headlinePart: 'นำทีมได้ดี',
      heroDetail: 'คนรอบข้างมักฟังและเชื่อใจการตัดสินใจของคุณ',
      strengthTitle: 'เป็นที่พึ่งของทีม',
      strengthBody:
          'เวลาทีมสับสน คุณมักช่วยจัดลำดับและทำให้ทุกคนรู้ว่าต้องทำอะไร',
      workHint: 'ตำแหน่งที่ต้องดูแลทีมเหมาะกับคุณ',
    ),
    'creativity': ThaiThemePhrase(
      tag: 'สร้างสรรค์',
      headlinePart: 'สร้างสรรค์',
      heroDetail: 'คุณชอบทำสิ่งที่แตกต่างและมีเอกลักษณ์',
      strengthTitle: 'มีไอเดียสดใหม่',
      strengthBody:
          'เวลางานตัน คุณมักหาทางออกที่สร้างสรรค์และน่าสนใจ',
    ),
    'empathy': ThaiThemePhrase(
      tag: 'เห็นใจผู้อื่น',
      headlinePart: 'เห็นใจผู้อื่น',
      heroDetail: 'คุณเข้าใจว่าคนอื่นรู้สึกอย่างไรและมักตอบสนองอย่างเหมาะสม',
      strengthTitle: 'เข้าใจมุมมองคนอื่น',
      strengthBody:
          'คุณมักเห็นว่าทำไมคนถึงทำแบบนั้น ทำให้แก้ปัญหาร่วมกันได้ง่ายขึ้น',
      loveHint: 'ฟังก่อนตอบ จะทำให้ความสัมพันธ์ลึกขึ้น',
    ),
    'reliability': ThaiThemePhrase(
      tag: 'ไว้ใจได้',
      headlinePart: 'ไว้ใจได้',
      heroDetail: 'สัญญาแล้วทำ คุณมักทำให้คนอื่นมั่นใจได้',
      strengthTitle: 'ทำตามที่สัญญา',
      strengthBody:
          'คนรอบข้างรู้ว่ามอบหมายให้คุณแล้วไม่ต้องกังวล งานจะออกมาตรงเวลา',
      workHint: 'คนรอบข้างมักมอบหมายงานสำคัญให้คุณเพราะไว้ใจได้',
      moneyHint: 'คุณมักเก็บออมและใช้จ่ายอย่างมีแผน',
    ),
    'perfectionism': ThaiThemePhrase(
      tag: 'มาตรฐานสูง',
      headlinePart: 'มาตรฐานสูง',
      heroDetail: 'คุณอยากให้ทุกอย่างดีที่สุด บางครั้งจนลืมพัก',
      strengthTitle: 'ใส่ใจคุณภาพ',
      strengthBody:
          'งานที่คุณทำมักมีรายละเอียดดี เพราะคุณไม่ยอมส่งของที่ยังไม่พอใจ',
      cautionTitle: 'อย่าตั้งมาตรฐานสูงเกินไป',
      cautionBody:
          'บางครั้ง “ดีพอแล้ว” ก็ควรปล่อยไป ไม่งั้นคุณจะเหนื่อยโดยไม่จำเป็น',
    ),
    'impulsiveness': ThaiThemePhrase(
      tag: 'ตัดสินใจเร็ว',
      headlinePart: 'ตัดสินใจเร็ว',
      heroDetail: 'คุณมักลงมือทันทีเมื่อรู้สึกว่าถูกทาง',
      cautionTitle: 'อย่าตัดสินใจเร็วเกินไป',
      cautionBody:
          'ลองหยุดถามตัวเองสักครั้งว่า “พรุ่งนี้จะยังคิดแบบนี้ไหม” ก่อนลงมือเรื่องใหญ่',
      strengthTitle: 'ลงมือได้ทันที',
      strengthBody:
          'เมื่อเห็นโอกาสคุณไม่รอนาน ทำให้ไม่พลาดจังหวะที่ดี',
    ),
    'overthinking': ThaiThemePhrase(
      tag: 'คิดมาก',
      headlinePart: 'คิดมาก',
      heroDetail: 'คุณมักคิดวนซ้ำก่อนตัดสินใจครั้งสำคัญ',
      cautionTitle: 'อย่าคิดวนมากเกินไป',
      cautionBody:
          'ตั้งเวลาให้ตัวเอง แล้วลงมือเมื่อข้อมูลพอแล้ว ไม่ต้องรอความแน่นอน 100%',
      strengthTitle: 'คิดลึกก่อนตัดสินใจ',
      strengthBody:
          'คุณมักเห็นผลกระทบที่คนอื่นมองข้าม ทำให้ตัดสินใจแล้วเสียใจน้อยลง',
    ),
    'avoidance': ThaiThemePhrase(
      tag: 'หลีกเลี่ยงความขัดแย้ง',
      headlinePart: 'ไม่ชอบความขัดแย้ง',
      heroDetail: 'คุณมักเลี่ยงเรื่องที่ทำให้ไม่สบายใจ',
      cautionTitle: 'อย่าเลี่ยงปัญหาจนลากยาว',
      cautionBody:
          'พูดคุยตรง ๆ ในที่ที่ปลอดภัย จะช่วยแก้ปัญหาได้เร็วกว่าทำเป็นไม่เห็น',
      strengthTitle: 'รักษาบรรยากาศให้สงบ',
      strengthBody:
          'คุณมักหลีกเลี่ยงการทะเลาะที่ไม่จำเป็น ทำให้บ้านหรือที่ทำงานสงบขึ้น',
    ),
    'self_criticism': ThaiThemePhrase(
      tag: 'วิจารณ์ตัวเอง',
      headlinePart: 'เข้มงวดกับตัวเอง',
      heroDetail: 'คุณมักมองตัวเองเข้มกว่าที่มองคนอื่น',
      cautionTitle: 'อย่าวิจารณ์ตัวเองหนักเกินไป',
      cautionBody:
          'ลองถามตัวเองว่า “ถ้าเป็นเพื่อน ฉันจะพูดกับเขาแบบนี้ไหม” แล้วให้โอกาสตัวเองบ้าง',
      strengthTitle: 'มุ่งมั่นพัฒนาตัวเอง',
      strengthBody:
          'คุณไม่หยุดอยู่กับที่ มักหาทางทำให้ตัวเองดีขึ้นเรื่อย ๆ',
    ),
    'control': ThaiThemePhrase(
      tag: 'อยากควบคุม',
      headlinePart: 'อยากควบคุมทุกอย่าง',
      heroDetail: 'เมื่อไม่แน่ใจ คุณมักพยายามจัดการทุกอย่างเอง',
      cautionTitle: 'อย่าควบคุมมากเกินไป',
      cautionBody:
          'ลองมอบหมายบางส่วนให้คนอื่น จะช่วยลดความเหนื่อยและเปิดพื้นที่ให้คนรอบข้างช่วย',
      strengthTitle: 'จัดการได้เป็นระบบ',
      strengthBody:
          'เมื่อคุณดูแลเรื่องสำคัญ ทุกอย่างมักเป็นระเบียบและไม่หลุด',
    ),
    'people_pleasing': ThaiThemePhrase(
      tag: 'ใส่ใจคนอื่นมาก',
      headlinePart: 'ใส่ใจความคิดคนอื่น',
      heroDetail: 'คุณมักกังวลว่าคนอื่นจะพอใจหรือไม่',
      cautionTitle: 'อย่าลืมความต้องการของตัวเอง',
      cautionBody:
          'การบอก “ไม่” บางครั้งไม่ได้ทำร้ายใคร แต่ช่วยให้คุณมีพลังดูแลคนสำคัญได้ยาวนาน',
      strengthTitle: 'ทำให้คนรอบข้างสบายใจ',
      strengthBody:
          'คุณมักสังเกตว่าคนอื่นต้องการอะไร และช่วยให้บรรยากาศดีขึ้น',
    ),
    'trust_yourself_more': ThaiThemePhrase(
      tag: 'เชื่อมั่นตัวเอง',
      headlinePart: 'กำลังเรียนรู้เชื่อตัวเอง',
      heroDetail: 'คุณมีข้อมูลพอแล้ว แต่ยังรอการยืนยันจากคนอื่นบ่อยเกินไป',
      advice:
          'ช่วงนี้ลองตัดสินใจเล็ก ๆ ด้วยตัวเองก่อน แล้วดูว่าผลเป็นอย่างไร คุณจะเชื่อมั่นมากขึ้นทีละน้อย',
      strengthTitle: 'เปิดรับการเติบโต',
      strengthBody:
          'คุณพร้อมเรียนรู้และปรับปรุงตัวเองอยู่เสมอ',
    ),
    'open_to_collaboration': ThaiThemePhrase(
      tag: 'เปิดรับความร่วมมือ',
      headlinePart: 'เปิดรับการทำงานร่วมกัน',
      heroDetail: 'คุณเริ่มเห็นว่าการทำคนเดียวไม่ได้ดีที่สุดเสมอไป',
      advice:
          'ลองแบ่งงานหรือขอความเห็นจากคนที่ไว้ใจ คุณอาจได้ผลลัพธ์ดีกว่าที่ทำคนเดียว',
      strengthTitle: 'พร้อมรับฟังคนอื่น',
      strengthBody:
          'คุณเปิดใจรับมุมมองใหม่ ทำให้ทีมทำงานร่วมกันได้ดีขึ้น',
    ),
    'develop_patience': ThaiThemePhrase(
      tag: 'ใจเย็นขึ้น',
      headlinePart: 'กำลังเรียนรู้ใจเย็น',
      heroDetail: 'คุณรู้ว่าบางสิ่งต้องใช้เวลา แม้ยังอยากให้เร็วบ้าง',
      advice:
          'ช่วงนี้ให้เวลากับกระบวนการบ้าง ไม่ต้องรีบให้ทุกอย่างสำเร็จในวันเดียว',
      strengthTitle: 'อดทนรอผลลัพธ์',
      strengthBody:
          'คุณเข้าใจว่าสิ่งดี ๆ มักต้องใช้เวลา',
    ),
    'embrace_change': ThaiThemePhrase(
      tag: 'เปิดรับการเปลี่ยนแปลง',
      headlinePart: 'เปิดรับการเปลี่ยนแปลง',
      heroDetail: 'คุณเริ่มเห็นว่าการเปลี่ยนไม่ได้น่ากลัวเสมอไป',
      strengthTitle: 'ปรับตัวเมื่อชีวิตเปลี่ยน',
      strengthBody: 'คุณมักหาทางใหม่ได้เมื่อสถานการณ์ไม่เป็นไปตามแผน',
      advice:
          'เมื่อชีวิตเปลี่ยนทิศทาง ลองมองว่ามีอะไรใหม่ที่คุณได้เรียนรู้บ้าง',
      luckHint: 'โอกาสใหม่มักซ่อนอยู่ในสิ่งที่คุณยังไม่เคยลอง',
    ),
    'express_emotions_more_freely': ThaiThemePhrase(
      tag: 'แบ่งปันอารมณ์',
      headlinePart: 'กำลังเรียนรู้พูดความรู้สึก',
      heroDetail: 'คุณรู้สึกลึก แต่ยังไม่ค่อยบอกออกมาทุกครั้ง',
      strengthTitle: 'รับรู้อารมณ์ตัวเองได้ดี',
      strengthBody: 'คุณรู้ว่าตัวเองรู้สึกอย่างไร แม้ยังไม่ได้พูดออกมาทุกครั้ง',
      advice:
          'ลองบอกคนที่ไว้ใจว่าวันนี้รู้สึกอย่างไร แม้แค่ประโยคเดียว จะช่วยให้ใจเบาลง',
      loveHint: 'การพูดความรู้สึกตรง ๆ ช่วยให้คนรักเข้าใจคุณมากขึ้น',
    ),
    'balance_structure_with_flexibility': ThaiThemePhrase(
      tag: 'สมดุลระหว่างแผนกับความยืดหยุ่น',
      headlinePart: 'ผสมแผนกับความยืดหยุ่น',
      heroDetail: 'คุณชอบมีแผน แต่ก็รู้ว่าบางครั้งต้องปรับตามสถานการณ์',
      strengthTitle: 'มีทั้งแผนและความยืดหยุ่น',
      strengthBody: 'คุณวางแผนได้ดี แต่ก็ปรับตัวได้เมื่อสิ่งรอบตัวเปลี่ยน',
      advice:
          'วางแผนไว้ แต่เว้นช่องว่างให้ปรับได้เมื่อสิ่งรอบตัวเปลี่ยน จะเดินหน้าได้ทั้งมั่นคงและคล่องตัว',
      workHint: 'ผสมระเบียบกับความยืดหยุ่น งานจะไม่ตันเมื่อมีอุปสรรค',
    ),
  };

  static ThaiThemePhrase phrase(String themeId) {
    final base = all[themeId] ?? _fallback;
    final life = ThaiMirrorThemeLifeHints.forTheme(themeId);
    return ThaiThemePhrase(
      tag: base.tag,
      headlinePart: base.headlinePart,
      heroDetail: base.heroDetail,
      strengthTitle: base.strengthTitle,
      strengthBody: base.strengthBody,
      cautionTitle: base.cautionTitle,
      cautionBody: base.cautionBody,
      advice: base.advice,
      workHint: base.workHint ?? life.work,
      moneyHint: base.moneyHint ?? life.money,
      loveHint: base.loveHint ?? life.love,
      healthHint: base.healthHint ?? life.health,
      luckHint: base.luckHint ?? life.luck,
    );
  }

  static String aspectHint(String themeId, String aspect) {
    final phrase = ThaiMirrorThemePhrases.phrase(themeId);
    return switch (aspect) {
      'work' => phrase.workHint!,
      'money' => phrase.moneyHint!,
      'love' => phrase.loveHint!,
      'health' => phrase.healthHint!,
      'luck' => phrase.luckHint!,
      _ => phrase.workHint!,
    };
  }
}
