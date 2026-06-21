import '../../models/content_status.dart';
import '../../models/thai_content_key.dart';
import '../../models/thai_content_section.dart';
import '../../models/thai_content_type.dart';
import '../../models/thai_fusion_theme_category.dart';
import '../../models/thai_theme_mapping.dart';

const ThaiContentSection lagnaLordJupiterSection = ThaiContentSection(
  key: ThaiContentKeys.lagnaLordJupiter,
  contentType: ThaiContentType.lagnaLord,
  contentStatus: ContentStatus.approved,
  version: 'v1',
  title: 'เจ้าเรือนลัคนา — พฤหัสบดี',
  summary:
      'เมื่อพฤหัสบดีเป็นเจ้าเรือนลัคนา แก่นตัวตนจากลัคนาอาจถูกขยายด้วยมุมมองที่กว้างและความหมาย '
      'หลายครั้งคุณอาจมองตนเองผ่านการเติบโตและการแบ่งปันสิ่งที่เรียนรู้',
  coreNature:
      'พฤหัสบดีในบทบาทเจ้าเรือนลัคนามักทำหน้าที่เพิ่มมิติของความหวังและการขยายตัว '
      'คุณอาจให้ความสำคัญกับการมองภาพใหญ่และการเชื่อมโยงประสบการณ์เข้ากับความหมาย',
  strengths: [
    'อาจมองเห็นโอกาสและบทเรียนในสิ่งที่เกิดขึ้นรอบตัว',
    'อาจสร้างแรงบันดาลใจให้ตนเองและผู้อื่นผ่านมุมมองที่กว้างขึ้น',
    'อาจแบ่งปันความรู้และช่วยผู้อื่นเติบโตได้อย่างเป็นธรรมชาติ',
  ],
  challenges: [
    'อาจมองข้ามรายละเอียดสำคัญเมื่อมุ่งสู่ภาพใหญ่',
    'อาจให้คำแนะนำมากเกินไปโดยไม่ตั้งใจ',
    'อาจคาดหวังสูงเกินกว่าที่สถานการณ์จริงรองรับ',
  ],
  growthPath:
      'การฝึกลงลึกในรายละเอียดบางอย่างที่สำคัญ '
      'อาจช่วยให้วิสัยทัศน์ของพฤหัสบดีกลายเป็นผลลัพธ์ที่เป็นรูปธรรมมากขึ้น',
  themeMappings: [
    ThaiThemeMapping(
      category: ThaiFusionThemeCategory.coreSelf,
      theme: 'visionary',
      weight: 0.85,
    ),
    ThaiThemeMapping(
      category: ThaiFusionThemeCategory.workAndAmbition,
      theme: 'teacher',
      weight: 0.85,
    ),
    ThaiThemeMapping(
      category: ThaiFusionThemeCategory.growthPath,
      theme: 'open_to_collaboration',
      weight: 0.7,
    ),
  ],
);
