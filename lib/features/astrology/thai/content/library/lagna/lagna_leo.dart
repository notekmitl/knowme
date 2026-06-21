import '../../models/content_status.dart';
import '../../models/thai_content_key.dart';
import '../../models/thai_content_section.dart';
import '../../models/thai_content_type.dart';
import '../../models/thai_fusion_theme_category.dart';
import '../../models/thai_theme_mapping.dart';

const ThaiContentSection lagnaLeoSection = ThaiContentSection(
  key: ThaiContentKeys.lagnaLeo,
  contentType: ThaiContentType.lagna,
  contentStatus: ContentStatus.approved,
  version: 'v1',
  title: 'ลัคนาราศีสิงห์',
  summary:
      'ลัคนาสิงห์มักสะท้อนภาพของผู้ที่เข้าหาโลกด้วยความมั่นใจและการแสดงออก '
      'หลายครั้งคุณอาจรู้สึกมีพลังเมื่อได้เป็นตัวของตนเองอย่างชัดเจน',
  coreNature:
      'แก่นธาตุของลัคนานี้อาจโน้มไปทางความภาคภูมิใจในตนเอง ความอบอุ่น '
      'และการสร้างแรงบันดาลใจให้ตนเองและผู้อื่น',
  strengths: [
    'ความมั่นใจและความสามารถในการเป็นตัวของตนเอง',
    'พลังในการสร้างแรงบันดาลใจและความอบอุ่นให้คนรอบข้าง',
    'ความกล้าที่จะยืนหยัดในสิ่งที่เชื่อและให้ความสำคัญ',
  ],
  challenges: [
    'อาจต้องการการยอมรับหรือการมองเห็นจากผู้อื่นมากเกินไป',
    'อาจรู้สึกเสียกำลังใจเมื่อไม่ได้รับความสนใจตามที่หวัง',
    'อาจยึดติดกับภาพลักษณ์หรือความภาคภูมิใจจนลืมฟังมุมมองอื่น',
  ],
  growthPath:
      'การฝึกหาความมั่นใจจากภายในโดยไม่พึ่งพาการยอมรับภายนอกอย่างเดียว '
      'อาจช่วยให้แสงของคุณส่องสว่างอย่างสมดุลและยั่งยืน',
  themeMappings: [
    ThaiThemeMapping(
      category: ThaiFusionThemeCategory.coreSelf,
      theme: 'ambitious',
      weight: 0.95,
    ),
    ThaiThemeMapping(
      category: ThaiFusionThemeCategory.strengths,
      theme: 'leadership',
      weight: 0.85,
    ),
    ThaiThemeMapping(
      category: ThaiFusionThemeCategory.growthAreas,
      theme: 'people_pleasing',
      weight: 0.65,
    ),
  ],
);
