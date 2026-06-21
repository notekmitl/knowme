import '../../models/content_status.dart';
import '../../models/thai_content_key.dart';
import '../../models/thai_content_section.dart';
import '../../models/thai_content_type.dart';
import '../../models/thai_fusion_theme_category.dart';
import '../../models/thai_theme_mapping.dart';

const ThaiContentSection lagnaLordMarsSection = ThaiContentSection(
  key: ThaiContentKeys.lagnaLordMars,
  contentType: ThaiContentType.lagnaLord,
  contentStatus: ContentStatus.approved,
  version: 'v1',
  title: 'เจ้าเรือนลัคนา — อังคาร',
  summary:
      'เมื่ออังคารเป็นเจ้าเรือนลัคนา แก่นตัวตนจากลัคนาอาจถูกขับเคลื่อนด้วยพลังและความตั้งใจ '
      'หลายครั้งคุณอาจรู้สึกมีชีวิตชีวาเมื่อได้ลงมือทำสิ่งที่เชื่อ',
  coreNature:
      'อังคารในบทบาทเจ้าเรือนลัคนามักทำหน้าที่เพิ่มความกล้าและความมุ่งมั่นให้ตัวตน '
      'คุณอาจมองตัวเองเป็นคนที่ต้องการเคลื่อนไหวและไม่ชอบค้างอยู่กับความลังเลนาน',
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
      'อาจช่วยให้พลังของอังคารถูกใช้อย่างมีคุณภาพมากขึ้น',
  themeMappings: [
    ThaiThemeMapping(
      category: ThaiFusionThemeCategory.coreSelf,
      theme: 'independent',
      weight: 0.85,
    ),
    ThaiThemeMapping(
      category: ThaiFusionThemeCategory.strengths,
      theme: 'leadership',
      weight: 0.8,
    ),
    ThaiThemeMapping(
      category: ThaiFusionThemeCategory.thinkingStyle,
      theme: 'fast_moving',
      weight: 0.7,
    ),
  ],
);
