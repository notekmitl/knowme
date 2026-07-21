import '../../models/content_status.dart';
import '../../models/thai_content_key.dart';
import '../../models/thai_content_section.dart';
import '../../models/thai_content_type.dart';
import '../../models/thai_fusion_theme_category.dart';
import '../../models/thai_theme_mapping.dart';

const ThaiContentSection lagnaLibraSection = ThaiContentSection(
  key: ThaiContentKeys.lagnaLibra,
  contentType: ThaiContentType.lagna,
  contentStatus: ContentStatus.approved,
  version: 'v1',
  title: 'ลัคนาราศีตุลย์',
  summary:
      'ลัคนาตุลย์มักสะท้อนภาพของผู้ที่เข้าหาโลกผ่านความสมดุลและความสัมพันธ์ '
      'หลายครั้งคุณอาจให้ความสำคัญกับความยุติธรรมและบรรยากาศที่กลมกลืน',
  coreNature:
      'แก่นธาตุของลัคนานี้อาจโน้มไปทางการมองหาจุดกลาง การประนีประนอม '
      'และการสร้างความกลมกลืนในสิ่งแวดล้อม',
  strengths: [
    'ความสามารถในการมองหลายมุมมองและหาจุดกลาง',
    'ทักษะในการสร้างความสัมพันธ์และบรรยากาศที่กลมกลืน',
    'ความยุติธรรมและการให้ความสำคัญกับทุกฝ่าย',
  ],
  challenges: [
    'อาจลังเลในการตัดสินใจเมื่อต้องเลือกข้างใดข้างหนึ่ง',
    'อาจหลีกเลี่ยงความขัดแย้งแม้จำเป็นต้องเผชิญ',
    'อาจลืมความต้องการของตนเองเมื่อพยายามทำให้ทุกคนพอใจ',
  ],
  growthPath:
      'การฝึกฟังเสียงภายในและยอมรับว่าความสมดุลบางครั้งต้องเริ่มจากตนเอง '
      'อาจช่วยให้คุณสร้างความกลมกลืนได้อย่างแท้จริง',
  themeMappings: [
    ThaiThemeMapping(
      category: ThaiFusionThemeCategory.coreSelf,
      theme: 'adaptable',
      weight: 0.9,
    ),
    ThaiThemeMapping(
      category: ThaiFusionThemeCategory.relationships,
      theme: 'diplomatic',
      weight: 0.9,
    ),
    ThaiThemeMapping(
      category: ThaiFusionThemeCategory.growthAreas,
      theme: 'overthinking',
      weight: 0.6,
    ),
  ],
);
