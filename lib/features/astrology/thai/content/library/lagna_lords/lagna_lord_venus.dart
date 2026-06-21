import '../../models/content_status.dart';
import '../../models/thai_content_key.dart';
import '../../models/thai_content_section.dart';
import '../../models/thai_content_type.dart';
import '../../models/thai_fusion_theme_category.dart';
import '../../models/thai_theme_mapping.dart';

const ThaiContentSection lagnaLordVenusSection = ThaiContentSection(
  key: ThaiContentKeys.lagnaLordVenus,
  contentType: ThaiContentType.lagnaLord,
  contentStatus: ContentStatus.approved,
  version: 'v1',
  title: 'เจ้าเรือนลัคนา — ศุกร์',
  summary:
      'เมื่อศุกร์เป็นเจ้าเรือนลัคนา แก่นตัวตนจากลัคนาอาจถูกปรับด้วยความสัมพันธ์และความกลมกลืน '
      'หลายครั้งคุณอาจเข้าใจตนเองผ่านการเชื่อมต่อกับผู้อื่นและบรรยากาศรอบตัว',
  coreNature:
      'ศุกร์ในบทบาทเจ้าเรือนลัคนามักทำหน้าที่เพิ่มมิติของความสวยงามและความสมดุล '
      'คุณอาจให้ความสำคัญกับความสัมพันธ์ที่กลมกลืนและความรู้สึกดีในชีวิตประจำวัน',
  strengths: [
    'อาจสร้างความสัมพันธ์ที่อบอุ่นและกลมกลืนได้ดี',
    'อาจมองหาจุดกลางเมื่อมีความขัดแย้ง',
    'อาจสร้างบรรยากาศที่ทำให้ผู้อื่นรู้สึกสบายใจ',
  ],
  challenges: [
    'อาจลังเลในการตัดสินใจเมื่อต้องเลือกข้างใดข้างหนึ่ง',
    'อาจหลีกเลี่ยงความขัดแย้งแม้จำเป็นต้องเผชิญ',
    'อาจลืมความต้องการของตนเองเมื่อพยายามทำให้ทุกคนพอใจ',
  ],
  growthPath:
      'การฝึกฟังเสียงภายในและยอมรับว่าความสมดุลบางครั้งต้องเริ่มจากตนเอง '
      'อาจช่วยให้ศุกร์สร้างความกลมกลืนได้อย่างแท้จริง',
  themeMappings: [
    ThaiThemeMapping(
      category: ThaiFusionThemeCategory.relationships,
      theme: 'relationship_oriented',
      weight: 0.9,
    ),
    ThaiThemeMapping(
      category: ThaiFusionThemeCategory.relationships,
      theme: 'diplomatic',
      weight: 0.8,
    ),
    ThaiThemeMapping(
      category: ThaiFusionThemeCategory.emotionalWorld,
      theme: 'expressive',
      weight: 0.7,
    ),
  ],
);
