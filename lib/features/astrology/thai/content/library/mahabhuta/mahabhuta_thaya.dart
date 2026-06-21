import '../../models/content_status.dart';
import '../../models/thai_content_key.dart';
import '../../models/thai_content_section.dart';
import '../../models/thai_content_type.dart';
import '../../models/thai_fusion_theme_category.dart';
import '../../models/thai_theme_mapping.dart';

const ThaiContentSection mahabhutaThayaSection = ThaiContentSection(
  key: ThaiContentKeys.mahabhutaThaya,
  contentType: ThaiContentType.mahabhutaPosition,
  contentStatus: ContentStatus.approved,
  version: 'v1',
  title: 'มหาภูติ — ทายะ',
  summary:
      'ตำแหน่งทายะสะท้อนรูปแบบภายในที่เกี่ยวกับรากฐานชีวิตและความมั่นคง '
      'หลายครั้งอาจปรากฏเป็นแนวโน้มที่ทำให้คุณให้ความสำคัญกับสิ่งที่มีคุณค่าระยะยาว',
  coreNature:
      'ทายะในมุมมองมหาภูติพม่าประยุกต์มักสะท้อนสัญญาณชีวิตที่เกี่ยวกับฐานราก '
      'และสิ่งที่ให้ความหมายกับชีวิต — เป็น Life-Position Signal ไม่ใช่ตัวตนหลัก',
  strengths: [
    'อาจสร้างความมั่นคงและรากฐานให้ตนเองได้ดี',
    'อาจมองหาสิ่งที่มีคุณค่าและยืนยาวได้อย่างรอบคอบ',
    'อาจอดทนต่อเป้าหมายที่สำคัญแม้ใช้เวลานาน',
  ],
  challenges: [
    'อาจยึดติดกับรากฐานเดิมจนต้านการปรับตัว',
    'อาจลังเลเมื่อต้องเปลี่ยนสิ่งที่เคยให้ความมั่นคง',
    'อาจให้ความสำคัญกับความปลอดภัยมากจนลดความยืดหยุ่น',
  ],
  growthPath:
      'การฝึกแยกแยะระหว่างรากฐานที่ยั่งยืนกับรูปแบบที่ต้องปรับ '
      'อาจช่วยให้ทายะสนับสนุนการเติบโตโดยไม่ยึดติด',
  themeMappings: [
    ThaiThemeMapping(
      category: ThaiFusionThemeCategory.coreSelf,
      theme: 'grounded',
      weight: 0.9,
    ),
    ThaiThemeMapping(
      category: ThaiFusionThemeCategory.emotionalWorld,
      theme: 'stable',
      weight: 0.85,
    ),
    ThaiThemeMapping(
      category: ThaiFusionThemeCategory.coreSelf,
      theme: 'practical',
      weight: 0.8,
    ),
    ThaiThemeMapping(
      category: ThaiFusionThemeCategory.workAndAmbition,
      theme: 'builder',
      weight: 0.75,
    ),
  ],
);
