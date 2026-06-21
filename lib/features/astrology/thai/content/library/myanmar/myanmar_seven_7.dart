import '../../models/content_status.dart';
import '../../models/thai_content_key.dart';
import '../../models/thai_content_section.dart';
import '../../models/thai_content_type.dart';
import '../../models/thai_fusion_theme_category.dart';
import '../../models/thai_theme_mapping.dart';

const ThaiContentSection myanmarSeven7Section = ThaiContentSection(
  key: ThaiContentKeys.myanmarSeven7,
  contentType: ThaiContentType.myanmarSeven,
  contentStatus: ContentStatus.approved,
  version: 'v1',
  title: 'เลข 7 — เสาร์',
  summary:
      'เลข 7 สะท้อนรูปแบบพลังเสาร์ในดวงชะตาแบบพม่า '
      'หลายครั้งอาจปรากฏเป็นแรงสร้างรากฐานด้านวินัยและความอดทนในช่วงชีวิต',
  coreNature:
      'รูปแบบเลข 7 มักสะท้อนสัญญาณชีวิตที่เน้นโครงสร้าง ความรับผิดชอบ และระยะยาว '
      'เป็น Life-Pattern Signal ที่บ่งบอกแนวโน้มการสร้างรากฐานมากกว่าตัวตนหลัก',
  strengths: [
    'อาจมีวินัยและความอดทนในการทำงานเพื่อเป้าหมาย',
    'อาจวางแผนและสร้างผลลัพธ์ที่ยั่งยืนได้ดี',
    'อาจรับผิดชอบต่อสิ่งที่มอบหมายอย่างจริงจัง',
  ],
  challenges: [
    'อาจกดดันตนเองมากเกินไปด้วยมาตรฐานที่สูง',
    'อาจลืมพักผ่อนหรือความสุขระหว่างทาง',
    'อาจต้านการเปลี่ยนแปลงที่เกิดขึ้นเร็วเกินไป',
  ],
  growthPath:
      'การฝึกยอมรับความสำเร็จเล็กน้อยระหว่างทาง '
      'อาจช่วยให้ความมุ่งมั่นของเลข 7 ยั่งยืนโดยไม่สูญเสียสุขภาพจิต',
  themeMappings: [
    ThaiThemeMapping(
      category: ThaiFusionThemeCategory.coreSelf,
      theme: 'disciplined',
      weight: 0.95,
    ),
    ThaiThemeMapping(
      category: ThaiFusionThemeCategory.strengths,
      theme: 'persistence',
      weight: 0.9,
    ),
    ThaiThemeMapping(
      category: ThaiFusionThemeCategory.workAndAmbition,
      theme: 'builder',
      weight: 0.85,
    ),
    ThaiThemeMapping(
      category: ThaiFusionThemeCategory.growthPath,
      theme: 'develop_patience',
      weight: 0.7,
    ),
  ],
);
