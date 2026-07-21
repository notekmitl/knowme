import '../../models/content_status.dart';
import '../../models/thai_content_key.dart';
import '../../models/thai_content_section.dart';
import '../../models/thai_content_type.dart';
import '../../models/thai_fusion_theme_category.dart';
import '../../models/thai_theme_mapping.dart';

const ThaiContentSection lagnaLordSunSection = ThaiContentSection(
  key: ThaiContentKeys.lagnaLordSun,
  contentType: ThaiContentType.lagnaLord,
  contentStatus: ContentStatus.approved,
  version: 'v1',
  title: 'เจ้าเรือนลัคนา — อาทิตย์',
  summary:
      'เมื่ออาทิตย์เป็นเจ้าเรือนลัคนา แก่นตัวตนจากลัคนาอาจถูกขับเคลื่อนด้วยความมุ่งมั่นและการแสดงออก '
      'หลายครั้งคุณอาจรู้สึกว่าต้องการทิศทางที่ชัดและพื้นที่ในการเป็นตัวของตนเอง',
  coreNature:
      'อาทิตย์ในบทบาทเจ้าเรือนลัคนามักทำหน้าที่เป็นแรงขับเคลื่อนความมั่นใจและความชัดเจน '
      'คุณอาจมองตัวเองผ่านเลนส์ของผู้ที่ต้องการเติบโตและถูกมองเห็นในสิ่งที่ทำ',
  strengths: [
    'อาจมีแรงจูงใจในการกำหนดทิศทางและยืนหยัดในสิ่งที่ให้ความสำคัญ',
    'อาจสร้างแรงบันดาลใจให้ตนเองและผู้อื่นผ่านการเป็นตัวอย่าง',
    'อาจตัดสินใจได้ชัดเมื่อเห็นภาพรวมของเป้าหมาย',
  ],
  challenges: [
    'อาจต้องการการยอมรับหรือการมองเห็นจากภายนอกมากเกินไป',
    'อาจรู้สึกเสียกำลังใจเมื่อความคืบหน้าไม่ชัดเจน',
    'อาจลืมฟังมุมมองอื่นเมื่อมุ่งเน้นเป้าหมายของตนเอง',
  ],
  growthPath:
      'การฝึกหาความมั่นใจจากภายในโดยไม่พึ่งพาการยอมรับอย่างเดียว '
      'อาจช่วยให้พลังของอาทิตย์ส่องสว่างอย่างสมดุลมากขึ้น',
  themeMappings: [
    ThaiThemeMapping(
      category: ThaiFusionThemeCategory.coreSelf,
      theme: 'ambitious',
      weight: 0.85,
    ),
    ThaiThemeMapping(
      category: ThaiFusionThemeCategory.strengths,
      theme: 'leadership',
      weight: 0.8,
    ),
    ThaiThemeMapping(
      category: ThaiFusionThemeCategory.workAndAmbition,
      theme: 'leader',
      weight: 0.75,
    ),
  ],
);
