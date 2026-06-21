import '../../models/content_status.dart';
import '../../models/thai_content_key.dart';
import '../../models/thai_content_section.dart';
import '../../models/thai_content_type.dart';
import '../../models/thai_fusion_theme_category.dart';
import '../../models/thai_theme_mapping.dart';

const ThaiContentSection lagnaAriesSection = ThaiContentSection(
  key: ThaiContentKeys.lagnaAries,
  contentType: ThaiContentType.lagna,
  contentStatus: ContentStatus.approved,
  version: 'v1',
  title: 'ลัคนาราศีเมษ',
  summary:
      'ลัคนาเมษมักสะท้อนภาพของผู้ที่เข้าหาโลกด้วยความตั้งใจและพลังเริ่มต้น '
      'หลายครั้งคุณอาจรู้สึกว่าการลงมือทำช่วยให้เข้าใจตัวเองได้ชัดขึ้น',
  coreNature:
      'แก่นธาตุของลัคนานี้อาจโน้มไปทางการริเริ่ม ความกล้า และการแสดงออกอย่างตรงไปตรงมา '
      'คุณอาจมองตัวเองเป็นคนที่ต้องการเคลื่อนไหวและไม่ชอบค้างอยู่กับที่นานเกินไป',
  strengths: [
    'ความกล้าในการเริ่มต้นสิ่งใหม่เมื่อเห็นทิศทางที่ชัด',
    'พลังในการขับเคลื่อนตนเองและผู้อื่นให้เดินหน้า',
    'ความตรงไปตรงมาในการแสดงออกและตัดสินใจ',
  ],
  challenges: [
    'อาจรีบลงมือทำก่อนประเมินผลกระทบอย่างรอบคอบ',
    'อาจหงุดหงิดเมื่อความคืบหน้าช้ากว่าที่คาดไว้',
    'อาจต้องการพื้นที่ปรับจังหวะเมื่อแรงกระตุ้นสูงเกินไป',
  ],
  growthPath:
      'การฝึกหยุดสักครู่เพื่อสังเกตแรงจูงใจก่อนลงมือ '
      'อาจช่วยให้พลังของคุณถูกใช้อย่างมีคุณภาพและยั่งยืนมากขึ้น',
  themeMappings: [
    ThaiThemeMapping(
      category: ThaiFusionThemeCategory.coreSelf,
      theme: 'independent',
      weight: 0.95,
    ),
    ThaiThemeMapping(
      category: ThaiFusionThemeCategory.thinkingStyle,
      theme: 'fast_moving',
      weight: 0.8,
    ),
    ThaiThemeMapping(
      category: ThaiFusionThemeCategory.strengths,
      theme: 'leadership',
      weight: 0.75,
    ),
  ],
);
