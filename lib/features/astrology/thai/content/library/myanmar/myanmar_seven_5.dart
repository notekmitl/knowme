import '../../models/content_status.dart';
import '../../models/thai_content_key.dart';
import '../../models/thai_content_section.dart';
import '../../models/thai_content_type.dart';
import '../../models/thai_fusion_theme_category.dart';
import '../../models/thai_theme_mapping.dart';

const ThaiContentSection myanmarSeven5Section = ThaiContentSection(
  key: ThaiContentKeys.myanmarSeven5,
  contentType: ThaiContentType.myanmarSeven,
  contentStatus: ContentStatus.approved,
  version: 'v1',
  title: 'เลข 5 — พฤหัสบดี',
  summary:
      'เลข 5 สะท้อนรูปแบบพลังพฤหัสบดีในดวงชะตาแบบพม่า '
      'หลายครั้งอาจปรากฏเป็นแรงขยายตัวด้านความหมายและการเติบโตในช่วงชีวิต',
  coreNature:
      'รูปแบบเลข 5 มักสะท้อนสัญญาณชีวิตที่เน้นมุมมองกว้าง การเรียนรู้ และการแบ่งปัน '
      'เป็น Life-Pattern Signal ที่บ่งบอกแนวโน้มการขยายตัวมากกว่าตัวตนหลัก',
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
      'อาจช่วยให้วิสัยทัศน์ของเลข 5 กลายเป็นผลลัพธ์ที่เป็นรูปธรรมมากขึ้น',
  themeMappings: [
    ThaiThemeMapping(
      category: ThaiFusionThemeCategory.coreSelf,
      theme: 'visionary',
      weight: 0.9,
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
