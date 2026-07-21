import '../../models/content_status.dart';
import '../../models/thai_content_key.dart';
import '../../models/thai_content_section.dart';
import '../../models/thai_content_type.dart';
import '../../models/thai_fusion_theme_category.dart';
import '../../models/thai_theme_mapping.dart';

const ThaiContentSection lagnaCancerSection = ThaiContentSection(
  key: ThaiContentKeys.lagnaCancer,
  contentType: ThaiContentType.lagna,
  contentStatus: ContentStatus.approved,
  version: 'v1',
  title: 'ลัคนาราศีกรกฎ',
  summary:
      'ลัคนากรกฎมักสะท้อนภาพของผู้ที่เข้าหาโลกผ่านความรู้สึกและความผูกพัน '
      'หลายครั้งคุณอาจให้ความสำคัญกับบรรยากาศและความรู้สึกปลอดภัย',
  coreNature:
      'แก่นธาตุของลัคนานี้อาจโน้มไปทางความอ่อนไหวทางอารมณ์ การดูแล '
      'และการสร้างพื้นที่ที่รู้สึกเป็นของตนเอง',
  strengths: [
    'ความสามารถในการรับรู้และเข้าใจอารมณ์ของตนเองและผู้อื่น',
    'ความเอาใจใส่และการดูแลคนใกล้ชิดอย่างจริงใจ',
    'สัญชาตญาณที่ช่วยสังเกตบรรยากาศและความต้องการที่ไม่ได้พูดออกมา',
  ],
  challenges: [
    'อาจอ่อนไหวต่อคำพูดหรือบรรยากาศที่ไม่สบายใจ',
    'อาจยึดติดกับอดีตหรือความผูกพันเก่า',
    'อาจปกป้องตนเองมากเกินไปเมื่อรู้สึกไม่ปลอดภัย',
  ],
  growthPath:
      'การฝึกแยกความรู้สึกปัจจุบันออกจากประสบการณ์เก่า '
      'อาจช่วยให้ความอ่อนไหวของคุณกลายเป็นพลังในการเข้าใจตนเองอย่างลึกซึ้ง',
  themeMappings: [
    ThaiThemeMapping(
      category: ThaiFusionThemeCategory.coreSelf,
      theme: 'protective',
      weight: 0.95,
    ),
    ThaiThemeMapping(
      category: ThaiFusionThemeCategory.emotionalWorld,
      theme: 'sensitive',
      weight: 0.9,
    ),
    ThaiThemeMapping(
      category: ThaiFusionThemeCategory.relationships,
      theme: 'supportive',
      weight: 0.8,
    ),
  ],
);
