import '../../models/content_status.dart';
import '../../models/thai_content_key.dart';
import '../../models/thai_content_section.dart';
import '../../models/thai_content_type.dart';
import '../../models/thai_fusion_theme_category.dart';
import '../../models/thai_theme_mapping.dart';

const ThaiContentSection lagnaLordSaturnSection = ThaiContentSection(
  key: ThaiContentKeys.lagnaLordSaturn,
  contentType: ThaiContentType.lagnaLord,
  contentStatus: ContentStatus.approved,
  version: 'v1',
  title: 'เจ้าเรือนลัคนา — เสาร์',
  summary:
      'เมื่อเสาร์เป็นเจ้าเรือนลัคนา แก่นตัวตนจากลัคนาอาจถูกปรับด้วยวินัยและความรับผิดชอบ '
      'หลายครั้งคุณอาจรู้สึกสบายใจเมื่อมีโครงสร้างและเป้าหมายระยะยาวที่ชัดเจน',
  coreNature:
      'เสาร์ในบทบาทเจ้าเรือนลัคนามักทำหน้าที่เพิ่มมิติของความอดทนและการวางรากฐาน '
      'คุณอาจมองตัวเองผ่านเลนส์ของผู้ที่ให้ความสำคัญกับความมั่นคงและผลลัพธ์ระยะยาว',
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
      'อาจช่วยให้ความมุ่งมั่นของเสาร์ยั่งยืนโดยไม่สูญเสียสุขภาพจิต',
  themeMappings: [
    ThaiThemeMapping(
      category: ThaiFusionThemeCategory.coreSelf,
      theme: 'disciplined',
      weight: 0.9,
    ),
    ThaiThemeMapping(
      category: ThaiFusionThemeCategory.strengths,
      theme: 'persistence',
      weight: 0.85,
    ),
    ThaiThemeMapping(
      category: ThaiFusionThemeCategory.workAndAmbition,
      theme: 'builder',
      weight: 0.8,
    ),
    ThaiThemeMapping(
      category: ThaiFusionThemeCategory.growthPath,
      theme: 'develop_patience',
      weight: 0.65,
    ),
  ],
);
