import '../../models/content_status.dart';
import '../../models/thai_content_key.dart';
import '../../models/thai_content_section.dart';
import '../../models/thai_content_type.dart';
import '../../models/thai_fusion_theme_category.dart';
import '../../models/thai_theme_mapping.dart';

const ThaiContentSection myanmarSeven4Section = ThaiContentSection(
  key: ThaiContentKeys.myanmarSeven4,
  contentType: ThaiContentType.myanmarSeven,
  contentStatus: ContentStatus.approved,
  version: 'v1',
  title: 'เลข 4 — พุธ',
  summary:
      'เลข 4 สะท้อนรูปแบบพลังพุธในดวงชะตาแบบพม่า '
      'หลายครั้งอาจปรากฏเป็นแรงเชื่อมโยงด้านความคิดและการสื่อสารในช่วงชีวิต',
  coreNature:
      'รูปแบบเลข 4 มักสะท้อนสัญญาณชีวิตที่เน้นการเรียนรู้ การแลกเปลี่ยน และการวิเคราะห์ '
      'เป็น Life-Pattern Signal ที่บ่งบอกแนวโน้มทางปัญญามากกว่าตัวตนหลัก',
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
      'อาจช่วยให้ความคล่องตัวของเลข 4 กลายเป็นความเชี่ยวชาญที่แท้จริง',
  themeMappings: [
    ThaiThemeMapping(
      category: ThaiFusionThemeCategory.coreSelf,
      theme: 'curious',
      weight: 0.85,
    ),
    ThaiThemeMapping(
      category: ThaiFusionThemeCategory.thinkingStyle,
      theme: 'analytical',
      weight: 0.85,
    ),
    ThaiThemeMapping(
      category: ThaiFusionThemeCategory.strengths,
      theme: 'communication',
      weight: 0.8,
    ),
  ],
);
