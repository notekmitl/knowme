import '../../models/content_status.dart';
import '../../models/thai_content_key.dart';
import '../../models/thai_content_section.dart';
import '../../models/thai_content_type.dart';
import '../../models/thai_fusion_theme_category.dart';
import '../../models/thai_theme_mapping.dart';

const ThaiContentSection myanmarSeven1Section = ThaiContentSection(
  key: ThaiContentKeys.myanmarSeven1,
  contentType: ThaiContentType.myanmarSeven,
  contentStatus: ContentStatus.approved,
  version: 'v1',
  title: 'เลข 1 — อาทิตย์',
  summary:
      'เลข 1 สะท้อนรูปแบบพลังอาทิตย์ในดวงชะตาแบบพม่า '
      'หลายครั้งอาจปรากฏเป็นแรงขับเคลื่อนด้านความมั่นใจและการเป็นตัวของตนเองในช่วงชีวิต',
  coreNature:
      'รูปแบบเลข 1 มักสะท้อนสัญญาณชีวิตที่เน้นตัวตน ความชัดเจน และการมองเห็น '
      'เป็น Life-Pattern Signal ไม่ใช่ตัวตนหลัก — แต่เป็นแนวโน้มที่อาจโผล่เด่นในบางช่วงของดวง',
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
      'อาจช่วยให้พลังของเลข 1 ส่องสว่างอย่างสมดุลมากขึ้น',
  themeMappings: [
    ThaiThemeMapping(
      category: ThaiFusionThemeCategory.coreSelf,
      theme: 'ambitious',
      weight: 0.9,
    ),
    ThaiThemeMapping(
      category: ThaiFusionThemeCategory.strengths,
      theme: 'leadership',
      weight: 0.85,
    ),
    ThaiThemeMapping(
      category: ThaiFusionThemeCategory.emotionalWorld,
      theme: 'expressive',
      weight: 0.7,
    ),
  ],
);
