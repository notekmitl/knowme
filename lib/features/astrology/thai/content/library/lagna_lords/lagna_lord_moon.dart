import '../../models/content_status.dart';
import '../../models/thai_content_key.dart';
import '../../models/thai_content_section.dart';
import '../../models/thai_content_type.dart';
import '../../models/thai_fusion_theme_category.dart';
import '../../models/thai_theme_mapping.dart';

const ThaiContentSection lagnaLordMoonSection = ThaiContentSection(
  key: ThaiContentKeys.lagnaLordMoon,
  contentType: ThaiContentType.lagnaLord,
  contentStatus: ContentStatus.approved,
  version: 'v1',
  title: 'เจ้าเรือนลัคนา — จันทร์',
  summary:
      'เมื่อจันทร์เป็นเจ้าเรือนลัคนา แก่นตัวตนจากลัคนาอาจถูกปรับด้วยความอ่อนไหวและความผูกพัน '
      'หลายครั้งคุณอาจให้ความสำคัญกับบรรยากาศและความรู้สึกปลอดภัย',
  coreNature:
      'จันทร์ในบทบาทเจ้าเรือนลัคนามักทำหน้าที่เชื่อมตัวตนเข้ากับโลกอารมณ์ '
      'คุณอาจเข้าใจตนเองผ่านสิ่งที่รู้สึกและความสัมพันธ์ที่ใกล้ชิด',
  strengths: [
    'อาจรับรู้ความต้องการทางอารมณ์ของตนเองและผู้อื่นได้ดี',
    'อาจสร้างความใกล้ชิดผ่านการดูแลและความเข้าใจ',
    'อาจปรับตัวตามบรรยากาศและจังหวะของสถานการณ์',
  ],
  challenges: [
    'อาจอ่อนไหวต่อคำพูดหรือบรรยากาศที่ไม่สบายใจ',
    'อาจยึดติดกับความรู้สึกหรือความผูกพันในอดีต',
    'อาจปกป้องตนเองมากเกินไปเมื่อรู้สึกไม่ปลอดภัย',
  ],
  growthPath:
      'การฝึกแยกความรู้สึกปัจจุบันออกจากประสบการณ์เก่า '
      'อาจช่วยให้ความอ่อนไหวของจันทร์กลายเป็นพลังเข้าใจตนเองอย่างลึกซึ้ง',
  themeMappings: [
    ThaiThemeMapping(
      category: ThaiFusionThemeCategory.emotionalWorld,
      theme: 'empathetic',
      weight: 0.9,
    ),
    ThaiThemeMapping(
      category: ThaiFusionThemeCategory.relationships,
      theme: 'supportive',
      weight: 0.85,
    ),
    ThaiThemeMapping(
      category: ThaiFusionThemeCategory.strengths,
      theme: 'empathy',
      weight: 0.7,
    ),
  ],
);
