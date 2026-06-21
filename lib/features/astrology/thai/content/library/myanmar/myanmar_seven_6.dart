import '../../models/content_status.dart';
import '../../models/thai_content_key.dart';
import '../../models/thai_content_section.dart';
import '../../models/thai_content_type.dart';
import '../../models/thai_fusion_theme_category.dart';
import '../../models/thai_theme_mapping.dart';

const ThaiContentSection myanmarSeven6Section = ThaiContentSection(
  key: ThaiContentKeys.myanmarSeven6,
  contentType: ThaiContentType.myanmarSeven,
  contentStatus: ContentStatus.approved,
  version: 'v1',
  title: 'เลข 6 — ศุกร์',
  summary:
      'เลข 6 สะท้อนรูปแบบพลังศุกร์ในดวงชะตาแบบพม่า '
      'หลายครั้งอาจปรากฏเป็นแรงเชื่อมโยงด้านความสัมพันธ์และความกลมกลืนในช่วงชีวิต',
  coreNature:
      'รูปแบบเลข 6 มักสะท้อนสัญญาณชีวิตที่เน้นความสัมพันธ์ ความสมดุล และความอบอุ่น '
      'เป็น Life-Pattern Signal ที่บ่งบอกแนวโน้มทางใจและความสัมพันธ์มากกว่าตัวตนหลัก',
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
      'อาจช่วยให้ศุกร์ของเลข 6 สร้างความกลมกลืนได้อย่างแท้จริง',
  themeMappings: [
    ThaiThemeMapping(
      category: ThaiFusionThemeCategory.relationships,
      theme: 'relationship_oriented',
      weight: 0.9,
    ),
    ThaiThemeMapping(
      category: ThaiFusionThemeCategory.relationships,
      theme: 'diplomatic',
      weight: 0.85,
    ),
    ThaiThemeMapping(
      category: ThaiFusionThemeCategory.emotionalWorld,
      theme: 'expressive',
      weight: 0.7,
    ),
  ],
);
