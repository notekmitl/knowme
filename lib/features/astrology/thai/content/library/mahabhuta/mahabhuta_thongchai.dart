import '../../models/content_status.dart';
import '../../models/thai_content_key.dart';
import '../../models/thai_content_section.dart';
import '../../models/thai_content_type.dart';
import '../../models/thai_fusion_theme_category.dart';
import '../../models/thai_theme_mapping.dart';

const ThaiContentSection mahabhutaThongchaiSection = ThaiContentSection(
  key: ThaiContentKeys.mahabhutaThongchai,
  contentType: ThaiContentType.mahabhutaPosition,
  contentStatus: ContentStatus.approved,
  version: 'v1',
  title: 'มหาภูติ — ธงชัย',
  summary:
      'ตำแหน่งธงชัยสะท้อนรูปแบบภายในที่เกี่ยวกับความสำเร็จ ความหวัง และแรงผลักเชิงบวก '
      'หลายครั้งอาจปรากฏเป็นแนวโน้มที่ทำให้คุณมองไปข้างหน้าด้วยพลังสร้างสรรค์',
  coreNature:
      'ธงชัยในมุมมองมหาภูติพม่าประยุกต์มักสะท้อนสัญญาณชีวิตที่เกี่ยวกับแรงขับเคลื่อนเชิงบวก '
      'และเป้าหมายที่มองเห็นได้ — เป็น Life-Position Signal ไม่ใช่การันตีผลลัพธ์',
  strengths: [
    'อาจมีแรงจูงใจในการมุ่งสู่เป้าหมายที่ให้ความหมาย',
    'อาจสร้างแรงบันดาลใจให้ตนเองและผู้อื่นได้',
    'อาจมองเห็นโอกาสแม้ในสถานการณ์ท้าทาย',
  ],
  challenges: [
    'อาจคาดหวังสูงเกินกว่าที่สถานการณ์รองรับ',
    'อาจผิดหวังเมื่อความคืบหน้าไม่ตรงกับที่หวัง',
    'อาจลืมพักผ่อนเมื่อมุ่งเน้นความสำเร็จ',
  ],
  growthPath:
      'การฝึกเฉลิมฉลองความคืบหน้าเล็กน้อยระหว่างทาง '
      'อาจช่วยให้ธงชัยยั่งยืนโดยไม่พึ่งพาความหวังอย่างเดียว',
  themeMappings: [
    ThaiThemeMapping(
      category: ThaiFusionThemeCategory.coreSelf,
      theme: 'visionary',
      weight: 0.9,
    ),
    ThaiThemeMapping(
      category: ThaiFusionThemeCategory.coreSelf,
      theme: 'ambitious',
      weight: 0.85,
    ),
    ThaiThemeMapping(
      category: ThaiFusionThemeCategory.strengths,
      theme: 'persistence',
      weight: 0.8,
    ),
    ThaiThemeMapping(
      category: ThaiFusionThemeCategory.workAndAmbition,
      theme: 'builder',
      weight: 0.75,
    ),
  ],
);
