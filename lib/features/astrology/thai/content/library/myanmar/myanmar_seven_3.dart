import '../../models/content_status.dart';
import '../../models/thai_content_key.dart';
import '../../models/thai_content_section.dart';
import '../../models/thai_content_type.dart';
import '../../models/thai_fusion_theme_category.dart';
import '../../models/thai_theme_mapping.dart';

const ThaiContentSection myanmarSeven3Section = ThaiContentSection(
  key: ThaiContentKeys.myanmarSeven3,
  contentType: ThaiContentType.myanmarSeven,
  contentStatus: ContentStatus.approved,
  version: 'v1',
  title: 'เลข 3 — อังคาร',
  summary:
      'เลข 3 สะท้อนรูปแบบพลังอังคารในดวงชะตาแบบพม่า '
      'หลายครั้งอาจปรากฏเป็นแรงขับเคลื่อนด้านการลงมือและความกล้าในช่วงชีวิต',
  coreNature:
      'รูปแบบเลข 3 มักสะท้อนสัญญาณชีวิตที่เน้นพลัง ความตรงไปตรงมา และการเผชิญหน้า '
      'เป็น Life-Pattern Signal ที่บ่งบอกแนวโน้มการกระทำมากกว่าตัวตนหลัก',
  strengths: [
    'อาจมีความกล้าในการเริ่มต้นและต่อสู้เพื่อสิ่งที่ให้ความสำคัญ',
    'อาจขับเคลื่อนตนเองและผู้อื่นให้เดินหน้าอย่างตรงไปตรงมา',
    'อาจตอบสนองอย่างรวดเร็วเมื่อเห็นโอกาสหรืออุปสรรคชัดเจน',
  ],
  challenges: [
    'อาจรีบลงมือทำก่อนประเมินผลกระทบอย่างรอบคอบ',
    'อาจหงุดหงิดเมื่อความคืบหน้าช้ากว่าที่คาดไว้',
    'อาจแสดงออกตรงเกินไปจนทำให้ผู้อื่นรู้สึกกดดัน',
  ],
  growthPath:
      'การฝึกหยุดสักครู่เพื่อสังเกตแรงจูงใจก่อนลงมือ '
      'อาจช่วยให้พลังของเลข 3 ถูกใช้อย่างมีคุณภาพมากขึ้น',
  themeMappings: [
    ThaiThemeMapping(
      category: ThaiFusionThemeCategory.coreSelf,
      theme: 'independent',
      weight: 0.85,
    ),
    ThaiThemeMapping(
      category: ThaiFusionThemeCategory.thinkingStyle,
      theme: 'fast_moving',
      weight: 0.8,
    ),
    ThaiThemeMapping(
      category: ThaiFusionThemeCategory.strengths,
      theme: 'persistence',
      weight: 0.75,
    ),
  ],
);
