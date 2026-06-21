import '../../models/content_status.dart';
import '../../models/thai_content_key.dart';
import '../../models/thai_content_section.dart';
import '../../models/thai_content_type.dart';
import '../../models/thai_fusion_theme_category.dart';
import '../../models/thai_theme_mapping.dart';

const ThaiContentSection ramahabhutaEarthSection = ThaiContentSection(
  key: ThaiContentKeys.ramahabhutaEarth,
  contentType: ThaiContentType.ramahabhuta,
  contentStatus: ContentStatus.approved,
  version: 'v1',
  title: 'รามหาภูติ — ธาตุดิน',
  summary:
      'รามหาภูติดินสะท้อนรูปแบบพลังที่มุ่งสู่ความมั่นคงและพื้นฐาน '
      'หลายครั้งคุณอาจรู้สึกสบายใจเมื่อชีวิตมีโครงสร้างที่คาดเดาได้',
  coreNature:
      'ธาตุดินในมุมมองรามหาภูติมักสะท้อนแนวโน้มทางจิตใจที่ให้ความสำคัญกับความสม่ำเสมอ '
      'ความอดทน และการสร้างรากฐานก่อนขยายตัว — ไม่ใช่ธาตุทางกายภาพ แต่เป็นรูปแบบพลังภายใน',
  strengths: [
    'อาจมีความอดทนและความสม่ำเสมอในการดำเนินชีวิต',
    'อาจสร้างความมั่นคงให้ตนเองและสิ่งรอบข้างได้ดี',
    'อาจตัดสินใจอย่างรอบคอบเมื่อเกี่ยวข้องกับสิ่งที่มีคุณค่า',
  ],
  challenges: [
    'อาจต้านการเปลี่ยนแปลงที่เกิดขึ้นเร็วเกินไป',
    'อาจยึดติดกับความสบายหรือรูปแบบเดิมนานเกินความจำเป็น',
    'อาจใช้เวลานานกว่าที่คาดในการปรับตัวกับสิ่งใหม่',
  ],
  growthPath:
      'การเปิดรับการปรับตัวเล็กน้อยทีละก้าว '
      'อาจช่วยให้ความมั่นคงของธาตุดินยืดหยุ่นและเติบโตได้พร้อมกับโลกที่เปลี่ยนแปลง',
  themeMappings: [
    ThaiThemeMapping(
      category: ThaiFusionThemeCategory.coreSelf,
      theme: 'grounded',
      weight: 0.9,
    ),
    ThaiThemeMapping(
      category: ThaiFusionThemeCategory.coreSelf,
      theme: 'practical',
      weight: 0.85,
    ),
    ThaiThemeMapping(
      category: ThaiFusionThemeCategory.emotionalWorld,
      theme: 'stable',
      weight: 0.8,
    ),
    ThaiThemeMapping(
      category: ThaiFusionThemeCategory.workAndAmbition,
      theme: 'builder',
      weight: 0.75,
    ),
    ThaiThemeMapping(
      category: ThaiFusionThemeCategory.strengths,
      theme: 'persistence',
      weight: 0.7,
    ),
  ],
);
