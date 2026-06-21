import '../../models/content_status.dart';
import '../../models/thai_content_key.dart';
import '../../models/thai_content_section.dart';
import '../../models/thai_content_type.dart';
import '../../models/thai_fusion_theme_category.dart';
import '../../models/thai_theme_mapping.dart';

const ThaiContentSection lagnaTaurusSection = ThaiContentSection(
  key: ThaiContentKeys.lagnaTaurus,
  contentType: ThaiContentType.lagna,
  contentStatus: ContentStatus.approved,
  version: 'v1',
  title: 'ลัคนาราศีพฤษภ',
  summary:
      'ลัคนาพฤษภมักสะท้อนภาพของผู้ที่ให้ความสำคัญกับความมั่นคงและความสม่ำเสมอ '
      'หลายครั้งคุณอาจรู้สึกสบายใจเมื่อชีวิตมีจังหวะที่คาดเดาได้',
  coreNature:
      'แก่นธาตุของลัคนานี้อาจโน้มไปทางความอดทน การสัมผัสโลกผ่านประสาทสัมผัส '
      'และการสร้างพื้นฐานที่มั่นคงก่อนขยายตัว',
  strengths: [
    'ความอดทนและความสม่ำเสมอในการดำเนินชีวิต',
    'ความสามารถในการสร้างความมั่นคงให้ตนเองและคนรอบข้าง',
    'การตัดสินใจอย่างรอบคอบเมื่อเกี่ยวข้องกับสิ่งที่มีคุณค่า',
  ],
  challenges: [
    'อาจต้านการเปลี่ยนแปลงที่เกิดขึ้นเร็วเกินไป',
    'อาจยึดติดกับความสบายหรือรูปแบบเดิมนานเกินความจำเป็น',
    'อาจใช้เวลานานกว่าที่คาดในการปรับตัวกับสิ่งใหม่',
  ],
  growthPath:
      'การเปิดรับการปรับตัวเล็กน้อยทีละก้าว '
      'อาจช่วยให้ความมั่นคงของคุณยืดหยุ่นและเติบโตได้พร้อมกับโลกที่เปลี่ยนแปลง',
  themeMappings: [
    ThaiThemeMapping(
      category: ThaiFusionThemeCategory.coreSelf,
      theme: 'grounded',
      weight: 0.95,
    ),
    ThaiThemeMapping(
      category: ThaiFusionThemeCategory.emotionalWorld,
      theme: 'stable',
      weight: 0.85,
    ),
    ThaiThemeMapping(
      category: ThaiFusionThemeCategory.workAndAmbition,
      theme: 'builder',
      weight: 0.7,
    ),
  ],
);
