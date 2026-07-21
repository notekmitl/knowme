import '../../models/content_status.dart';
import '../../models/thai_content_key.dart';
import '../../models/thai_content_section.dart';
import '../../models/thai_content_type.dart';
import '../../models/thai_fusion_theme_category.dart';
import '../../models/thai_theme_mapping.dart';

const ThaiContentSection lagnaLordMercurySection = ThaiContentSection(
  key: ThaiContentKeys.lagnaLordMercury,
  contentType: ThaiContentType.lagnaLord,
  contentStatus: ContentStatus.approved,
  version: 'v1',
  title: 'เจ้าเรือนลัคนา — พุธ',
  summary:
      'เมื่อพุธเป็นเจ้าเรือนลัคนา แก่นตัวตนจากลัคนาอาจถูกปรับด้วยการคิดและการสื่อสาร '
      'หลายครั้งคุณอาจเข้าใจตนเองผ่านการแลกเปลี่ยนความคิดและข้อมูล',
  coreNature:
      'พุธในบทบาทเจ้าเรือนลัคนามักทำหน้าที่เชื่อมตัวตนเข้ากับการวิเคราะห์และการเรียนรู้ '
      'คุณอาจมองโลกผ่านเลนส์ของความอยากรู้และความยืดหยุ่นทางความคิด',
  strengths: [
    'อาจประมวลผลข้อมูลและสื่อสารความคิดได้คล่อง',
    'อาจปรับมุมมองได้เร็วเมื่อได้รับข้อมูลใหม่',
    'อาจเชื่อมโยงความคิดจากหลายแหล่งเข้าด้วยกัน',
  ],
  challenges: [
    'อาจกระจัดกระจายความสนใจเมื่อมีสิ่งเร้าหลายอย่างพร้อมกัน',
    'อาจลึกซึ้งน้อยลงเมื่อเปลี่ยนโฟกัสบ่อยเกินไป',
    'อาจวิเคราะห์มากจนลืมฟังความรู้สึกของตนเอง',
  ],
  growthPath:
      'การฝึกเลือกโฟกัสสำคัญและลงลึกทีละเรื่อง '
      'อาจช่วยให้ความคล่องตัวของพุธกลายเป็นความเชี่ยวชาญที่แท้จริง',
  themeMappings: [
    ThaiThemeMapping(
      category: ThaiFusionThemeCategory.thinkingStyle,
      theme: 'analytical',
      weight: 0.9,
    ),
    ThaiThemeMapping(
      category: ThaiFusionThemeCategory.strengths,
      theme: 'communication',
      weight: 0.85,
    ),
    ThaiThemeMapping(
      category: ThaiFusionThemeCategory.coreSelf,
      theme: 'curious',
      weight: 0.7,
    ),
  ],
);
