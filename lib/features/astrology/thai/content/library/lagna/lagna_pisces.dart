import '../../models/content_status.dart';
import '../../models/thai_content_key.dart';
import '../../models/thai_content_section.dart';
import '../../models/thai_content_type.dart';
import '../../models/thai_fusion_theme_category.dart';
import '../../models/thai_theme_mapping.dart';

const ThaiContentSection lagnaPiscesSection = ThaiContentSection(
  key: ThaiContentKeys.lagnaPisces,
  contentType: ThaiContentType.lagna,
  contentStatus: ContentStatus.approved,
  version: 'v1',
  title: 'ลัคนาราศีมีน',
  summary:
      'ลัคนามีนมักสะท้อนภาพของผู้ที่เข้าหาโลกด้วยความอ่อนไหวและจินตนาการ '
      'หลายครั้งคุณอาจรับรู้สิ่งที่อยู่นอกเหตุผลอย่างลึกซึ้ง',
  coreNature:
      'แก่นธาตุของลัคนานี้อาจโน้มไปทางความเห็นอกเห็นใจ จินตนาการ '
      'และการเชื่อมโยงกับโลกทางอารมณ์และจิตวิญญาณ',
  strengths: [
    'ความเห็นอกเห็นใจและความสามารถในการเข้าใจความรู้สึกของผู้อื่น',
    'จินตนาการและความคิดสร้างสรรค์ที่ลึกซึ้ง',
    'ความยืดหยุ่นในการปรับตัวกับสถานการณ์ที่เปลี่ยนแปลง',
  ],
  challenges: [
    'อาจสับสนระหว่างความรู้สึกของตนเองกับของผู้อื่น',
    'อาจหลบหนีความจริงเมื่อรู้สึกหนักเกินไป',
    'อาจตั้งขอบเขตกับผู้อื่นได้ยาก',
  ],
  growthPath:
      'การฝึกแยกความรู้สึกของตนเองออกจากของผู้อื่น '
      'อาจช่วยให้ความอ่อนไหวของคุณกลายเป็นพลังเข้าใจโลกอย่างลึกซึ้ง',
  themeMappings: [
    ThaiThemeMapping(
      category: ThaiFusionThemeCategory.coreSelf,
      theme: 'creative',
      weight: 0.95,
    ),
    ThaiThemeMapping(
      category: ThaiFusionThemeCategory.emotionalWorld,
      theme: 'empathetic',
      weight: 0.9,
    ),
    ThaiThemeMapping(
      category: ThaiFusionThemeCategory.growthAreas,
      theme: 'people_pleasing',
      weight: 0.7,
    ),
  ],
);
