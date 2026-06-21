import '../../models/content_status.dart';
import '../../models/thai_content_key.dart';
import '../../models/thai_content_section.dart';
import '../../models/thai_content_type.dart';
import '../../models/thai_fusion_theme_category.dart';
import '../../models/thai_theme_mapping.dart';

const ThaiContentSection ramahabhutaWaterSection = ThaiContentSection(
  key: ThaiContentKeys.ramahabhutaWater,
  contentType: ThaiContentType.ramahabhuta,
  contentStatus: ContentStatus.approved,
  version: 'v1',
  title: 'รามหาภูติ — ธาตุน้ำ',
  summary:
      'รามหาภูติน้ำสะท้อนรูปแบบพลังที่ไหลและเชื่อมโยงทางอารมณ์ '
      'หลายครั้งคุณอาจรับรู้ความรู้สึกของตนเองและผู้อื่นอย่างลึกซึ้ง',
  coreNature:
      'ธาตุน้ำในมุมมองรามหาภูติมักสะท้อนแนวโน้มทางจิตใจที่อ่อนไหวและเห็นอกเห็นใจ '
      'เป็นรูปแบบพลังที่เน้นการรับรู้ การปรับตัว และความผูกพันทางอารมณ์',
  strengths: [
    'อาจรับรู้ความต้องการทางอารมณ์ของตนเองและผู้อื่นได้ดี',
    'อาจสร้างความใกล้ชิดผ่านการดูแลและความเข้าใจ',
    'อาจปรับตัวตามบรรยากาศและจังหวะของสถานการณ์',
  ],
  challenges: [
    'อาจอ่อนไหวต่อคำพูดหรือบรรยากาศที่ไม่สบายใจ',
    'อาจสับสนระหว่างความรู้สึกของตนเองกับของผู้อื่น',
    'อาจหลบหนีความรู้สึกหนักเมื่อรู้สึกท่วมท้น',
  ],
  growthPath:
      'การฝึกแยกความรู้สึกของตนเองออกจากของผู้อื่น '
      'อาจช่วยให้ความอ่อนไหวของธาตุน้ำกลายเป็นพลังเข้าใจโลกอย่างลึกซึ้ง',
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
      weight: 0.8,
    ),
    ThaiThemeMapping(
      category: ThaiFusionThemeCategory.relationships,
      theme: 'relationship_oriented',
      weight: 0.75,
    ),
  ],
);
