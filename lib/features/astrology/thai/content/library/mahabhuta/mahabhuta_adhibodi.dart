import '../../models/content_status.dart';
import '../../models/thai_content_key.dart';
import '../../models/thai_content_section.dart';
import '../../models/thai_content_type.dart';
import '../../models/thai_fusion_theme_category.dart';
import '../../models/thai_theme_mapping.dart';

const ThaiContentSection mahabhutaAdhibodiSection = ThaiContentSection(
  key: ThaiContentKeys.mahabhutaAdhibodi,
  contentType: ThaiContentType.mahabhutaPosition,
  contentStatus: ContentStatus.approved,
  version: 'v1',
  title: 'มหาภูติ — อธิบดี',
  summary:
      'ตำแหน่งอธิบดีสะท้อนรูปแบบภายในที่เกี่ยวกับภาวะผู้นำ การกำหนดทิศทาง และการตัดสินใจ '
      'หลายครั้งอาจปรากฏเป็นแนวโน้มที่ทำให้คุณรับผิดชอบต่อทิศทางชีวิตของตนเอง',
  coreNature:
      'อธิบดีในมุมมองมหาภูติพม่าประยุกต์มักสะท้อนสัญญาณชีวิตที่เกี่ยวกับการกำหนดทิศทาง '
      'และการตัดสินใจอย่างมีเหตุผล — เป็น Life-Position Signal ไม่ใช่ตำแหน่งผู้นำถาวร',
  strengths: [
    'อาจตัดสินใจได้ชัดเมื่อเห็นภาพรวมของสิ่งที่สำคัญ',
    'อาจรับผิดชอบต่อทิศทางชีวิตของตนเองได้ดี',
    'อาจวางแผนและนำตนเองไปสู่เป้าหมายได้อย่างมีวินัย',
  ],
  challenges: [
    'อาจกดดันตนเองเมื่อรู้สึกว่าต้องควบคุมทุกอย่าง',
    'อาจลืมฟังมุมมองอื่นเมื่อมุ่งเน้นการตัดสินใจ',
    'อาจรับภาระมากเกินไปเพราะความรู้สึกว่าต้องเป็นผู้นำ',
  ],
  growthPath:
      'การฝึกแบ่งปันการตัดสินใจและยอมรับความไม่แน่นอน '
      'อาจช่วยให้อธิบดีนำทางชีวิตได้อย่างยืดหยุ่นมากขึ้น',
  themeMappings: [
    ThaiThemeMapping(
      category: ThaiFusionThemeCategory.strengths,
      theme: 'leadership',
      weight: 0.95,
    ),
    ThaiThemeMapping(
      category: ThaiFusionThemeCategory.coreSelf,
      theme: 'disciplined',
      weight: 0.9,
    ),
    ThaiThemeMapping(
      category: ThaiFusionThemeCategory.coreSelf,
      theme: 'independent',
      weight: 0.85,
    ),
    ThaiThemeMapping(
      category: ThaiFusionThemeCategory.thinkingStyle,
      theme: 'strategic',
      weight: 0.75,
    ),
  ],
);
