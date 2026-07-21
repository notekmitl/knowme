import '../../models/content_status.dart';
import '../../models/thai_content_key.dart';
import '../../models/thai_content_section.dart';
import '../../models/thai_content_type.dart';
import '../../models/thai_fusion_theme_category.dart';
import '../../models/thai_theme_mapping.dart';

const ThaiContentSection lagnaCapricornSection = ThaiContentSection(
  key: ThaiContentKeys.lagnaCapricorn,
  contentType: ThaiContentType.lagna,
  contentStatus: ContentStatus.approved,
  version: 'v1',
  title: 'ลัคนาราศีมกร',
  summary:
      'ลัคนามกรมักสะท้อนภาพของผู้ที่เข้าหาโลกด้วยความรับผิดชอบและโครงสร้าง '
      'หลายครั้งคุณอาจรู้สึกสบายใจเมื่อมีเป้าหมายระยะยาวที่ชัดเจน',
  coreNature:
      'แก่นธาตุของลัคนานี้อาจโน้มไปทางวินัย การวางแผน '
      'และการสร้างผลลัพธ์ที่ยั่งยืนผ่านความอดทน',
  strengths: [
    'ความรับผิดชอบและความสามารถในการวางแผนระยะยาว',
    'วินัยและความอดทนในการทำงานเพื่อเป้าหมาย',
    'ความน่าเชื่อถือในสิ่งที่มอบหมาย',
  ],
  challenges: [
    'อาจกดดันตนเองมากเกินไปด้วยมาตรฐานที่สูง',
    'อาจลืมพักผ่อนหรือความสุขระหว่างทาง',
    'อาจแสดงออกทางอารมณ์น้อยกว่าที่รู้สึกภายใน',
  ],
  growthPath:
      'การฝึกยอมรับความสำเร็จเล็กน้อยระหว่างทาง '
      'อาจช่วยให้ความมุ่งมั่นของคุณยั่งยืนโดยไม่สูญเสียสุขภาพจิต',
  themeMappings: [
    ThaiThemeMapping(
      category: ThaiFusionThemeCategory.coreSelf,
      theme: 'disciplined',
      weight: 0.95,
    ),
    ThaiThemeMapping(
      category: ThaiFusionThemeCategory.workAndAmbition,
      theme: 'builder',
      weight: 0.9,
    ),
    ThaiThemeMapping(
      category: ThaiFusionThemeCategory.strengths,
      theme: 'persistence',
      weight: 0.8,
    ),
  ],
);
