import 'package:knowme/core/themes/theme_registry.dart';

import 'thai_mirror_theme_life_hints.dart';
import 'thai_mirror_theme_phrases.dart';

class ThemeCopyVariant {
  const ThemeCopyVariant({required this.title, required this.body});

  final String title;
  final String body;
}

/// Multi-variant theme copy — strength, advice, and life-area hints.
abstract final class ThaiMirrorThemeVariants {
  static const _explicitStrengths = <String, List<ThemeCopyVariant>>{
    'expressive': [
      ThemeCopyVariant(
        title: 'สื่อสารความคิดได้ชัด',
        body: 'คุณสื่อสารความคิดได้ชัดเจน',
      ),
      ThemeCopyVariant(
        title: 'ทำให้คนเข้าใจเรื่องยาก',
        body: 'คุณมักช่วยให้คนอื่นเข้าใจเรื่องยากได้ง่ายขึ้น',
      ),
      ThemeCopyVariant(
        title: 'กล้าพูดตรงจากใจ',
        body: 'คุณกล้าพูดในสิ่งที่คิดอย่างตรงไปตรงมา',
      ),
    ],
    'analytical': [
      ThemeCopyVariant(
        title: 'หาสาเหตุก่อนตัดสินใจ',
        body: 'คุณชอบหาสาเหตุก่อนตัดสินใจ',
      ),
      ThemeCopyVariant(
        title: 'มองเห็นรายละเอียด',
        body: 'คุณมองเห็นรายละเอียดที่คนอื่นมองข้าม',
      ),
      ThemeCopyVariant(
        title: 'ไม่เชื่อข้อสรุปลอย ๆ',
        body: 'คุณไม่ค่อยเชื่อข้อสรุปที่ยังไม่มีเหตุผลรองรับ',
      ),
    ],
    'communication': [
      ThemeCopyVariant(
        title: 'พูดแล้วคนเข้าใจ',
        body: 'คุณถ่ายทอดความคิดให้คนอื่นเข้าใจได้ชัด',
      ),
      ThemeCopyVariant(
        title: 'เชื่อมความเข้าใจในทีม',
        body: 'คุณมักเป็นคนกลางที่ทำให้ทุกฝ่ายพูดภาษาเดียวกัน',
      ),
      ThemeCopyVariant(
        title: 'อธิบายเรื่องซับซ้อนได้',
        body: 'เวลาต้องอธิบายเรื่องยาก คุณมักหาคำที่ทำให้ทุกคนตรงกัน',
      ),
    ],
    'leadership': [
      ThemeCopyVariant(
        title: 'นำทีมไปข้างหน้า',
        body: 'คุณมักเป็นคนที่ทีมหันมามองเวลาต้องตัดสินใจ',
      ),
      ThemeCopyVariant(
        title: 'สร้างทิศทางให้คนอื่น',
        body: 'คุณช่วยให้คนรอบตัวเห็นภาพและรู้ว่าต้องทำอะไรต่อ',
      ),
      ThemeCopyVariant(
        title: 'รับผิดชอบเมื่อสำคัญ',
        body: 'เมื่องานหนัก คุณมักยืนหน้าและจัดการได้',
      ),
    ],
    'disciplined': [
      ThemeCopyVariant(
        title: 'ทำจริงจังเมื่อให้คำมั่น',
        body: 'เวลามอบหมายงานคุณจัดลำดับและทำจนสำเร็จ',
      ),
      ThemeCopyVariant(
        title: 'รักษาวินัยในตัวเอง',
        body: 'คุณมักทำตามแผนแม้ไม่มีใครคอยดู',
      ),
      ThemeCopyVariant(
        title: 'ไว้ใจได้เรื่องสำคัญ',
        body: 'คนรอบข้างมักมอบหมายเรื่องสำคัญให้คุณเพราะรู้ว่าคุณไม่ทิ้งงาน',
      ),
    ],
    'creative': [
      ThemeCopyVariant(
        title: 'คิดไอเดียใหม่',
        body: 'คุณมักเสนอแนวทางที่คนอื่นยังไม่คิด',
      ),
      ThemeCopyVariant(
        title: 'ออกแบบวิธีของตัวเอง',
        body: 'คุณชอบปรับแต่งหรือสร้างสิ่งใหม่ให้เหมาะกับสถานการณ์',
      ),
      ThemeCopyVariant(
        title: 'มองเห็นความเป็นไปได้',
        body: 'แม้ทางเดิมตัน คุณมักหาทางออกที่แตกต่างได้',
      ),
    ],
    'empathetic': [
      ThemeCopyVariant(
        title: 'เข้าใจความรู้สึกคนอื่น',
        body: 'คุณมักรับรู้ว่าคนรอบตัวรู้สึกอย่างไรแม้ไม่ได้พูดออกมา',
      ),
      ThemeCopyVariant(
        title: 'ฟังอย่างตั้งใจ',
        body: 'คนใกล้ชิดมักรู้สึกว่าคุณฟังจริง ไม่ใช่แค่รอตอบ',
      ),
      ThemeCopyVariant(
        title: 'สร้างบรรยากาศปลอดภัย',
        body: 'เมื่อคุณอยู่ คนอื่นมักกล้าแบ่งปันความรู้สึกมากขึ้น',
      ),
    ],
    'reliability': [
      ThemeCopyVariant(
        title: 'ทำตามที่สัญญา',
        body: 'คุณมักทำตามที่บอกไว้ แม้ไม่มีใครคอยเตือน',
      ),
      ThemeCopyVariant(
        title: 'คนไว้ใจได้',
        body: 'เมื่อคุณรับปาก คนรอบตัวมักไม่ต้องกังวลว่าจะหลุด',
      ),
      ThemeCopyVariant(
        title: 'สม่ำเสมอในงานสำคัญ',
        body: 'คุณทำงานสำคัญได้คุณภาพใกล้เคียงกันทุกครั้ง',
      ),
    ],
    'persistence': [
      ThemeCopyVariant(
        title: 'ไม่ยอมแพ้กลางทาง',
        body: 'คุณมักทำต่อแม้ไม่มีใครเห็นผลทันที จนกว่าจะสำเร็จ',
      ),
      ThemeCopyVariant(
        title: 'อดทนกับเป้าหมายยาว',
        body: 'แม้ช้า คุณก็ไม่เลิกกลางคันง่าย ๆ',
      ),
      ThemeCopyVariant(
        title: 'ลุยต่อแม้ติดขัด',
        body: 'เมื่อเจออุปสรรค คุณมักหาทางใหม่แทนการหยุด',
      ),
    ],
    'builder': [
      ThemeCopyVariant(
        title: 'สร้างของที่มั่นคง',
        body: 'คุณชอบสร้างระบบหรือผลงานที่อยู่ได้ยาว',
      ),
      ThemeCopyVariant(
        title: 'วางรากฐานก่อนขยาย',
        body: 'คุณมักทำพื้นฐานให้แน่นก่อนเร่งความเร็ว',
      ),
      ThemeCopyVariant(
        title: 'ทำให้สิ่งเล็กโตขึ้น',
        body: 'คุณเห็นผลสะสมจากความสม่ำเสมอมากกว่าการกระโดดครั้งเดียว',
      ),
    ],
    'systematic': [
      ThemeCopyVariant(
        title: 'จัดระบบได้ดี',
        body: 'เมื่อคุณดูแลเรื่องสำคัญ ทุกอย่างมักเป็นระเบียบและไม่หลุด',
      ),
      ThemeCopyVariant(
        title: 'ทำซ้ำได้คุณภาพคงที่',
        body: 'คุณสร้างขั้นตอนที่ทำซ้ำได้โดยไม่พลาดบ่อย',
      ),
      ThemeCopyVariant(
        title: 'มองภาพรวมและรายละเอียด',
        body: 'คุณเชื่อมแผนใหญ่กับงานย่อยได้ลงตัว',
      ),
    ],
    'detail_oriented': [
      ThemeCopyVariant(
        title: 'ใส่ใจรายละเอียด',
        body: 'คุณมักจับความผิดพลาดเล็ก ๆ ที่คนอื่นมองข้าม',
      ),
      ThemeCopyVariant(
        title: 'ทำงานละเอียดแม่นยำ',
        body: 'งานที่ต้องการความถูกต้องคุณทำได้ดี',
      ),
      ThemeCopyVariant(
        title: 'ไม่ปล่อยผ่านง่าย ๆ',
        body: 'คุณตรวจสอบก่อนส่งมอบ ทำให้ผลงานน่าเชื่อถือ',
      ),
    ],
    'relationship_oriented': [
      ThemeCopyVariant(
        title: 'ใส่ใจความสัมพันธ์',
        body: 'คุณมักเห็นความสำคัญของคนรอบตัวก่อนตัดสินใจ',
      ),
      ThemeCopyVariant(
        title: 'เชื่อมมิตรกับคนรอบข้าง',
        body: 'คุณช่วยให้ความสัมพันธ์ในชีวิตและงานราบรื่นขึ้น',
      ),
      ThemeCopyVariant(
        title: 'ฟังและเข้าใจผู้อื่น',
        body: 'คนใกล้ชิดมักรู้สึกว่าคุณใส่ใจพวกเขาจริง',
      ),
    ],
    'diplomatic': [
      ThemeCopyVariant(
        title: 'หาทางกลางได้ดี',
        body: 'คุณมักช่วยให้ทุกฝ่ายพูดกันได้โดยไม่ระเบิด',
      ),
      ThemeCopyVariant(
        title: 'พูดนุ่มแต่ตรงประเด็น',
        body: 'คุณสื่อสารยาก ๆ โดยไม่ทำให้ใครเสียหน้า',
      ),
      ThemeCopyVariant(
        title: 'ลดความตึงในทีม',
        body: 'เมื่อบรรยากาศร้อน คุณมักเป็นคนคลายสถานการณ์',
      ),
    ],
    'independent': [
      ThemeCopyVariant(
        title: 'ทำได้ด้วยตัวเอง',
        body: 'คุณมักลงมือและจัดการได้โดยไม่ต้องรอใคร',
      ),
      ThemeCopyVariant(
        title: 'ไม่พึ่งพาเกินจำเป็น',
        body: 'คุณชอบพึ่งพาความสามารถของตัวเองเมื่อสถานการณ์ต้องการ',
      ),
      ThemeCopyVariant(
        title: 'ตัดสินใจเองได้',
        body: 'เมื่อต้องเลือก คุณมักรู้ว่าตัวเองต้องการอะไร',
      ),
    ],
    'adaptable': [
      ThemeCopyVariant(
        title: 'ปรับตัวได้เร็ว',
        body: 'เมื่อแผนเปลี่ยน คุณมักหาทางใหม่ได้ไม่ตื่นตัว',
      ),
      ThemeCopyVariant(
        title: 'ยืดหยุ่นกับสถานการณ์',
        body: 'คุณไม่ยึดติดกับวิธีเดิมถ้ามันไม่ work แล้ว',
      ),
      ThemeCopyVariant(
        title: 'รับมือกับความไม่แน่นอน',
        body: 'แม้สิ่งรอบตัวเปลี่ยน คุณมักหาจังหวะของตัวเองได้',
      ),
    ],
  };

  static List<ThemeCopyVariant> strengthVariants(String themeId) {
    final explicit = _explicitStrengths[themeId];
    if (explicit != null) return explicit;

    final phrase = ThaiMirrorThemePhrases.phrase(themeId);
    return [
      ThemeCopyVariant(title: phrase.strengthTitle, body: phrase.strengthBody),
      ThemeCopyVariant(
        title: '${phrase.tag}เด่นในตัวคุณ',
        body: 'คุณมัก${phrase.headlinePart} — ${phrase.heroDetail}',
      ),
      ThemeCopyVariant(
        title: 'จุดแข็งจาก${phrase.tag}',
        body: 'เมื่อต้องใช้${phrase.headlinePart} คุณมักทำได้ดีกว่าที่คาด',
      ),
    ];
  }

  static Set<String> allStrengthTitlesForTheme(String themeId) =>
      strengthVariants(themeId).map((v) => v.title).toSet();

  static List<String> adviceVariants(String themeId) {
    final explicit = _explicitAdvice[themeId];
    if (explicit != null) return explicit;

    final phrase = ThaiMirrorThemePhrases.phrase(themeId);
    final base = phrase.advice;
    if (base == null || base.isEmpty) return const [];

    return [
      base,
      '${phrase.heroDetail} — ลองนำไปใช้ในสัปดาห์นี้',
      'ช่วงนี้${phrase.headlinePart} — $base',
      'จากมุม${phrase.tag}: $base',
    ];
  }

  static const _explicitAdvice = <String, List<String>>{
    'develop_patience': [
      'ช่วงนี้ให้เวลากับกระบวนการบ้าง ไม่ต้องรีบให้ทุกอย่างสำเร็จในวันเดียว',
      'ลองนับถอยหลังสั้น ๆ ก่อนตอบ — จังหวะนี้ช่วยให้ใจเย็นและตัดสินใจดีขึ้น',
      'แยกเรื่องที่รีบได้กับเรื่องที่ต้องค่อย ๆ สร้าง แล้วให้เวลากับกลุ่มหลัง',
      'ตั้งเป้าเล็ก ๆ รายสัปดาห์แทนเป้าใหญ่ในวันเดียว จะเห็นความคืบหน้าชัดขึ้น',
    ],
    'embrace_change': [
      'เมื่อชีวิตเปลี่ยนทิศทาง ลองมองว่ามีอะไรใหม่ที่คุณได้เรียนรู้บ้าง',
      'เปลี่ยนแปลงไม่จำเป็นต้องกลัว — เริ่มจากปรับทีละส่วนที่ทำได้จริงในสัปดาห์นี้',
      'ลองทำสิ่งเดิมในอีกวิธีหนึ่งสัปดาห์นี้ อาจเจอทางที่เหมาะกว่าเดิม',
      'เมื่อแผนเปลี่ยน ถามตัวเองว่าอะไรยังควบคุมได้ — แล้วโฟกัสตรงนั้นก่อน',
    ],
    'express_emotions_more_freely': [
      'ลองบอกคนที่ไว้ใจว่าวันนี้รู้สึกอย่างไร แม้แค่ประโยคเดียว จะช่วยให้ใจเบาลง',
      'เขียนความรู้สึกลงกระดาษก่อนพูด จะช่วยให้สื่อสารตรงขึ้นโดยไม่เกร็ง',
      'เลือกเวลาที่สบายใจแล้วบอกความรู้สึกจริง ๆ แม้เรื่องเล็ก ๆ ก็มีผล',
      'ลองเริ่มประโยคด้วย “วันนี้ฉันรู้สึกว่า...” กับคนที่ปลอดภัยสำหรับคุณ',
    ],
    'trust_yourself_more': [
      'ช่วงนี้ลองตัดสินใจเล็ก ๆ ด้วยตัวเองก่อน แล้วดูว่าผลเป็นอย่างไร คุณจะเชื่อมั่นมากขึ้นทีละน้อย',
      'ก่อนถามความเห็นคนอื่น ลองสรุปว่าตัวเองคิดอย่างไรแล้วบันทึกไว้',
      'เลือกเรื่องที่ผลกระทบไม่รุนแรงแล้วตัดสินใจเอง จะฝึกความมั่นใจได้จริง',
      'ย้อนดูการตัดสินใจที่เคยออกมาดี แล้วใช้เป็นแรงยืนยันครั้งต่อไป',
    ],
    'open_to_collaboration': [
      'ลองแบ่งงานหรือขอความเห็นจากคนที่ไว้ใจ คุณอาจได้ผลลัพธ์ดีกว่าที่ทำคนเดียว',
      'ชวนคนที่มองต่างจากคุณมาช่วยคิด มุมใหม่อาจแก้ปัญหาที่คุณติดมานาน',
      'ลองมอบหมายงานย่อยที่ไม่ต้องทำเองทั้งหมด แล้วดูว่าเวลาที่ได้คุ้มแค่ไหน',
      'ตั้งคำถามกับทีมก่อนลงมือเอง — บางครั้งคนอื่นมีคำตอบที่คุณมองไม่เห็น',
    ],
    'balance_structure_with_flexibility': [
      'วางแผนไว้ แต่เว้นช่องว่างให้ปรับได้เมื่อสิ่งรอบตัวเปลี่ยน จะเดินหน้าได้ทั้งมั่นคงและคล่องตัว',
      'กำหนดกรอบหลัก แล้วทดลองปรับรายละเอียดตามสถานการณ์จริง',
      'มีแผนสำรองสั้น ๆ ไว้หนึ่งแบบ จะไม่ตื่นตัวเมื่อสิ่งรอบตัวเปลี่ยน',
      'แยกสิ่งที่ต้องยึดกับสิ่งที่ปรับได้ — แล้วยืดหยุ่นเฉพาะส่วนหลัง',
    ],
  };

  static List<String> aspectHintVariants(String themeId, String aspect) {
    final hint = ThaiMirrorThemePhrases.aspectHint(themeId, aspect);
    if (hint.isEmpty) return const [];

    final phrase = ThaiMirrorThemePhrases.phrase(themeId);
    final life = ThaiMirrorThemeLifeHints.forTheme(themeId);
    final alt = switch (aspect) {
      'work' => life.money,
      'money' => life.work,
      'love' => life.health,
      'health' => life.love,
      'luck' => life.work,
      _ => life.luck,
    };

    const aspectLabels = {
      'work': 'การงาน',
      'money': 'การเงิน',
      'love': 'ความรัก',
      'health': 'สุขภาพ',
      'luck': 'โชคและโอกาส',
    };
    final aspectLabel = aspectLabels[aspect] ?? aspect;

    return [
      hint,
      'ด้าน$aspectLabel — ${phrase.heroDetail}',
      '${phrase.tag}: ${switch (aspect) {
        'work' => life.work,
        'money' => life.money,
        'love' => life.love,
        'health' => life.health,
        'luck' => life.luck,
        _ => hint,
      }}',
      if (alt.isNotEmpty && alt != hint) '$alt (ผ่าน${phrase.tag})',
    ].where((s) => s.isNotEmpty).toSet().toList();
  }

  static bool hasStrengthCoverageForAllThemes() {
    for (final theme in ThemeRegistry.getAll()) {
      if (strengthVariants(theme.id).length < 3) return false;
    }
    return true;
  }
}
