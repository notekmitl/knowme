import '../../models/content_status.dart';
import '../../models/thai_content_key.dart';
import '../../models/thai_content_section.dart';
import '../../models/thai_content_type.dart';
import '../../models/thai_fusion_theme_category.dart';
import '../../models/thai_theme_mapping.dart';

const ThaiContentSection lagnaGeminiSection = ThaiContentSection(
  key: ThaiContentKeys.lagnaGemini,
  contentType: ThaiContentType.lagna,
  contentStatus: ContentStatus.approved,
  version: 'v1',
  title: 'ลัคนาราศีเมถุน',
  summary:
      'ลัคนาเมถุนมักสะท้อนภาพของผู้ที่เข้าหาโลกด้วยความอยากรู้และการสื่อสาร '
      'หลายครั้งคุณอาจรู้สึกมีชีวิตชีวาเมื่อได้แลกเปลี่ยนความคิดกับผู้อื่น',
  coreNature:
      'แก่นธาตุของลัคนานี้อาจโน้มไปทางความยืดหยุ่นทางความคิด การเรียนรู้ '
      'และการเชื่อมโยงข้อมูลจากหลายมุมมองเข้าด้วยกัน',
  strengths: [
    'ความอยากรู้และความสามารถในการเรียนรู้สิ่งใหม่ได้เร็ว',
    'ทักษะการสื่อสารและการปรับตัวในสถานการณ์ที่หลากหลาย',
    'ความคิดที่ยืดหยุ่นและเปิดรับมุมมองใหม่',
  ],
  challenges: [
    'อาจกระจัดกระจายความสนใจเมื่อมีสิ่งเร้าหลายอย่างพร้อมกัน',
    'อาจลึกซึ้งน้อยลงเมื่อเปลี่ยนโฟกัสบ่อยเกินไป',
    'อาจรู้สึกไม่สบายใจเมื่อต้องอยู่กับเรื่องเดียวนานเกินไป',
  ],
  growthPath:
      'การฝึกเลือกโฟกัสสำคัญและลงลึกทีละเรื่อง '
      'อาจช่วยให้ความยืดหยุ่นของคุณกลายเป็นความเชี่ยวชาญที่แท้จริง',
  themeMappings: [
    ThaiThemeMapping(
      category: ThaiFusionThemeCategory.coreSelf,
      theme: 'curious',
      weight: 0.9,
    ),
    ThaiThemeMapping(
      category: ThaiFusionThemeCategory.thinkingStyle,
      theme: 'fast_moving',
      weight: 0.9,
    ),
    ThaiThemeMapping(
      category: ThaiFusionThemeCategory.relationships,
      theme: 'relationship_oriented',
      weight: 0.7,
    ),
  ],
);
