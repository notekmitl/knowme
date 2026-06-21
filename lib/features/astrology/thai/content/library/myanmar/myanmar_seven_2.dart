import '../../models/content_status.dart';
import '../../models/thai_content_key.dart';
import '../../models/thai_content_section.dart';
import '../../models/thai_content_type.dart';
import '../../models/thai_fusion_theme_category.dart';
import '../../models/thai_theme_mapping.dart';

const ThaiContentSection myanmarSeven2Section = ThaiContentSection(
  key: ThaiContentKeys.myanmarSeven2,
  contentType: ThaiContentType.myanmarSeven,
  contentStatus: ContentStatus.approved,
  version: 'v1',
  title: 'เลข 2 — จันทร์',
  summary:
      'เลข 2 สะท้อนรูปแบบพลังจันทร์ในดวงชะตาแบบพม่า '
      'หลายครั้งอาจปรากฏเป็นแรงเชื่อมโยงทางอารมณ์และความผูกพันในช่วงชีวิต',
  coreNature:
      'รูปแบบเลข 2 มักสะท้อนสัญญาณชีวิตที่เน้นการรับรู้อารมณ์ ความอ่อนไหว และการปรับตัว '
      'เป็น Life-Pattern Signal ที่บ่งบอกแนวโน้มทางใจมากกว่าตัวตนหลัก',
  strengths: [
    'อาจรับรู้ความต้องการทางอารมณ์ของตนเองและผู้อื่นได้ดี',
    'อาจสร้างความใกล้ชิดผ่านการดูแลและความเข้าใจ',
    'อาจปรับตัวตามบรรยากาศและจังหวะของสถานการณ์',
  ],
  challenges: [
    'อาจอ่อนไหวต่อคำพูดหรือบรรยากาศที่ไม่สบายใจ',
    'อาจยึดติดกับความรู้สึกหรือความผูกพันในอดีต',
    'อาจสับสนระหว่างความรู้สึกของตนเองกับของผู้อื่น',
  ],
  growthPath:
      'การฝึกแยกความรู้สึกปัจจุบันออกจากประสบการณ์เก่า '
      'อาจช่วยให้ความอ่อนไหวของเลข 2 กลายเป็นพลังเข้าใจตนเองอย่างลึกซึ้ง',
  themeMappings: [
    ThaiThemeMapping(
      category: ThaiFusionThemeCategory.emotionalWorld,
      theme: 'empathetic',
      weight: 0.9,
    ),
    ThaiThemeMapping(
      category: ThaiFusionThemeCategory.emotionalWorld,
      theme: 'sensitive',
      weight: 0.85,
    ),
    ThaiThemeMapping(
      category: ThaiFusionThemeCategory.relationships,
      theme: 'supportive',
      weight: 0.75,
    ),
  ],
);
