import '../../models/content_status.dart';
import '../../models/thai_content_key.dart';
import '../../models/thai_content_section.dart';
import '../../models/thai_content_type.dart';
import '../../models/thai_fusion_theme_category.dart';
import '../../models/thai_theme_mapping.dart';

const ThaiContentSection lagnaSagittariusSection = ThaiContentSection(
  key: ThaiContentKeys.lagnaSagittarius,
  contentType: ThaiContentType.lagna,
  contentStatus: ContentStatus.approved,
  version: 'v1',
  title: 'ลัคนาราศีธนู',
  summary:
      'ลัคนธนูมักสะท้อนภาพของผู้ที่เข้าหาโลกด้วยความอยากรู้และการมองไกล '
      'หลายครั้งคุณอาจรู้สึกมีชีวิตชีวาเมื่อได้ขยายขอบเขตความรู้หรือประสบการณ์',
  coreNature:
      'แก่นธาตุของลัคนานี้อาจโน้มไปทางการแสวงหา การมองภาพใหญ่ '
      'และความเชื่อในความเป็นไปได้ที่กว้างกว่าปัจจุบัน',
  strengths: [
    'มุมมองที่กว้างและความสามารถในการมองภาพใหญ่',
    'ความกระตือรือร้นในการเรียนรู้และสำรวจสิ่งใหม่',
    'ความมองโลกในแง่ดีที่ช่วยสร้างแรงบันดาลใจให้ตนเองและผู้อื่น',
  ],
  challenges: [
    'อาจมองข้ามรายละเอียดสำคัญเมื่อมุ่งสู่เป้าหมายใหญ่',
    'อาจรู้สึกอึดอัดเมื่อถูกจำกัดอยู่ในกรอบแคบ',
    'อาจพูดตรงเกินไปโดยไม่ตั้งใจทำร้ายความรู้สึกผู้อื่น',
  ],
  growthPath:
      'การฝึกลงลึกในรายละเอียดบางอย่างที่สำคัญ '
      'อาจช่วยให้วิสัยทัศน์ของคุณกลายเป็นผลลัพธ์ที่เป็นรูปธรรมมากขึ้น',
  themeMappings: [
    ThaiThemeMapping(
      category: ThaiFusionThemeCategory.coreSelf,
      theme: 'visionary',
      weight: 0.9,
    ),
    ThaiThemeMapping(
      category: ThaiFusionThemeCategory.thinkingStyle,
      theme: 'big_picture',
      weight: 0.85,
    ),
    ThaiThemeMapping(
      category: ThaiFusionThemeCategory.growthPath,
      theme: 'embrace_change',
      weight: 0.8,
    ),
  ],
);
