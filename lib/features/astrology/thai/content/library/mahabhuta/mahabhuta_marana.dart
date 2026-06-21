import '../../models/content_status.dart';
import '../../models/thai_content_key.dart';
import '../../models/thai_content_section.dart';
import '../../models/thai_content_type.dart';
import '../../models/thai_fusion_theme_category.dart';
import '../../models/thai_theme_mapping.dart';

const ThaiContentSection mahabhutaMaranaSection = ThaiContentSection(
  key: ThaiContentKeys.mahabhutaMarana,
  contentType: ThaiContentType.mahabhutaPosition,
  contentStatus: ContentStatus.approved,
  version: 'v1',
  title: 'มหาภูติ — มรณะ',
  summary:
      'ตำแหน่งมรณะสะท้อนรูปแบบภายในที่เกี่ยวกับการเปลี่ยนแปลงและการปล่อยวาง '
      'หลายครั้งอาจปรากฏเป็นแนวโน้มที่ทำให้คุณรับรู้จังหวะสิ้นสุดของวงจรเดิมได้ชัด',
  coreNature:
      'มรณะในมุมมองมหาภูติพม่าประยุกต์มักสะท้อนสัญญาณชีวิตที่เกี่ยวกับการเปลี่ยนผ่าน '
      'และการปล่อยสิ่งที่หมดอายุ — เป็น Life-Position Signal ไม่ใช่คำทำนาย',
  strengths: [
    'อาจปรับตัวต่อการเปลี่ยนแปลงได้ดีเมื่อยอมรับความจริง',
    'อาจปล่อยวางสิ่งที่ไม่ส่งเสริมการเติบโตได้เมื่อพร้อม',
    'อาจเรียนรู้จากช่วงเปลี่ยนผ่านและเริ่มต้นใหม่ได้',
  ],
  challenges: [
    'อาจต้านการเปลี่ยนแปลงแม้สิ่งเดิมไม่เหมาะสมแล้ว',
    'อาจเศร้าหรือลังเลเมื่อต้องปิดบทหนึ่งของชีวิต',
    'อาจยึดติดกับรูปแบบเดิมเพราะความคุ้นเคย',
  ],
  growthPath:
      'การฝึกมองการสิ้นสุดเป็นการเปิดช่องใหม่ '
      'อาจช่วยให้มรณะกลายเป็นกลไกการเติบโตที่สมดุลมากขึ้น',
  themeMappings: [
    ThaiThemeMapping(
      category: ThaiFusionThemeCategory.growthPath,
      theme: 'develop_patience',
      weight: 0.9,
    ),
    ThaiThemeMapping(
      category: ThaiFusionThemeCategory.coreSelf,
      theme: 'adaptable',
      weight: 0.85,
    ),
    ThaiThemeMapping(
      category: ThaiFusionThemeCategory.growthPath,
      theme: 'embrace_change',
      weight: 0.8,
    ),
    ThaiThemeMapping(
      category: ThaiFusionThemeCategory.strengths,
      theme: 'resilient',
      weight: 0.7,
    ),
  ],
);
