import '../../models/content_status.dart';
import '../../models/thai_content_key.dart';
import '../../models/thai_content_section.dart';
import '../../models/thai_content_type.dart';
import '../../models/thai_fusion_theme_category.dart';
import '../../models/thai_theme_mapping.dart';

const ThaiContentSection mahabhutaRachiyaSection = ThaiContentSection(
  key: ThaiContentKeys.mahabhutaRachiya,
  contentType: ThaiContentType.mahabhutaPosition,
  contentStatus: ContentStatus.approved,
  version: 'v1',
  title: 'มหาภูติ — ราชิยะ',
  summary:
      'ตำแหน่งราชิยะสะท้อนรูปแบบภายในที่เกี่ยวกับการยอมรับ สถานะ และอิทธิพลต่อสังคม '
      'หลายครั้งอาจปรากฏเป็นแนวโน้มที่ทำให้คุณให้ความสำคัญกับบทบาทในสังคม',
  coreNature:
      'ราชิยะในมุมมองมหาภูติพม่าประยุกต์มักสะท้อนสัญญาณชีวิตที่เกี่ยวกับการถูกมองเห็น '
      'และอิทธิพลต่อผู้อื่น — เป็น Life-Position Signal ไม่ใช่การันตีความสำเร็จ',
  strengths: [
    'อาจสร้างความน่าเชื่อถือและการยอมรับในวงสังคมได้',
    'อาจนำทางผู้อื่นด้วยบทบาทที่ชัดเจน',
    'อาจปรับตัวต่อบทบาททางสังคมได้ดี',
  ],
  challenges: [
    'อาจพึ่งพาการยอมรับจากภายนอกมากเกินไป',
    'อาจกดดันตนเองให้รักษาสถานะ',
    'อาจลืมความต้องการภายในเมื่อมุ่งรักษาภาพลักษณ์',
  ],
  growthPath:
      'การฝึกแยกคุณค่าภายในจากการยอมรับภายนอก '
      'อาจช่วยให้ราชิยะสนับสนุนความมั่นใจอย่างสมดุล',
  themeMappings: [
    ThaiThemeMapping(
      category: ThaiFusionThemeCategory.strengths,
      theme: 'leadership',
      weight: 0.9,
    ),
    ThaiThemeMapping(
      category: ThaiFusionThemeCategory.relationships,
      theme: 'diplomatic',
      weight: 0.85,
    ),
    ThaiThemeMapping(
      category: ThaiFusionThemeCategory.relationships,
      theme: 'relationship_oriented',
      weight: 0.8,
    ),
    ThaiThemeMapping(
      category: ThaiFusionThemeCategory.coreSelf,
      theme: 'ambitious',
      weight: 0.75,
    ),
  ],
);
