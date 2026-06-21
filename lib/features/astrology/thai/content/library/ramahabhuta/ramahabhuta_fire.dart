import '../../models/content_status.dart';
import '../../models/thai_content_key.dart';
import '../../models/thai_content_section.dart';
import '../../models/thai_content_type.dart';
import '../../models/thai_fusion_theme_category.dart';
import '../../models/thai_theme_mapping.dart';

const ThaiContentSection ramahabhutaFireSection = ThaiContentSection(
  key: ThaiContentKeys.ramahabhutaFire,
  contentType: ThaiContentType.ramahabhuta,
  contentStatus: ContentStatus.approved,
  version: 'v1',
  title: 'รามหาภูติ — ธาตุไฟ',
  summary:
      'รามหาภูติไฟสะท้อนรูปแบบพลังที่ร้อนแรงและขับเคลื่อน '
      'หลายครั้งคุณอาจรู้สึกมีพลังเมื่อเห็นทิศทางที่ชัดและได้ลงมือทำ',
  coreNature:
      'ธาตุไฟในมุมมองรามหาภูติมักสะท้อนแนวโน้มทางจิตใจที่มุ่งมั่น กล้าแสดงออก '
      'และต้องการเคลื่อนไหว — เป็นรูปแบบพลังที่เน้นการริเริ่มและแรงจูงใจภายใน',
  strengths: [
    'อาจมีความกล้าในการเริ่มต้นและขับเคลื่อนสิ่งที่ให้ความสำคัญ',
    'อาจสร้างแรงบันดาลใจให้ตนเองและผู้อื่นผ่านการลงมือทำ',
    'อาจตอบสนองอย่างรวดเร็วเมื่อเห็นโอกาสชัดเจน',
  ],
  challenges: [
    'อาจรีบลงมือทำก่อนประเมินผลกระทบอย่างรอบคอบ',
    'อาจหงุดหงิดเมื่อความคืบหน้าช้ากว่าที่คาดไว้',
    'อาจแสดงออกตรงเกินไปจนทำให้ผู้อื่นรู้สึกกดดัน',
  ],
  growthPath:
      'การฝึกหยุดสักครู่เพื่อสังเกตแรงจูงใจก่อนลงมือ '
      'อาจช่วยให้พลังของธาตุไฟถูกใช้อย่างมีคุณภาพและยั่งยืนมากขึ้น',
  themeMappings: [
    ThaiThemeMapping(
      category: ThaiFusionThemeCategory.coreSelf,
      theme: 'independent',
      weight: 0.9,
    ),
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
      category: ThaiFusionThemeCategory.thinkingStyle,
      theme: 'fast_moving',
      weight: 0.75,
    ),
  ],
);
