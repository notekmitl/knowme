import '../../models/content_status.dart';
import '../../models/thai_content_key.dart';
import '../../models/thai_content_section.dart';
import '../../models/thai_content_type.dart';
import '../../models/thai_fusion_theme_category.dart';
import '../../models/thai_theme_mapping.dart';

const ThaiContentSection lagnaAquariusSection = ThaiContentSection(
  key: ThaiContentKeys.lagnaAquarius,
  contentType: ThaiContentType.lagna,
  contentStatus: ContentStatus.approved,
  version: 'v1',
  title: 'ลัคนาราศีกุมภ',
  summary:
      'ลัคนากุมภมักสะท้อนภาพของผู้ที่เข้าหาโลกด้วยมุมมองที่แตกต่าง '
      'หลายครั้งคุณอาจให้ความสำคัญกับอุดมการณ์และการคิดนอกกรอบ',
  coreNature:
      'แก่นธาตุของลัคนานี้อาจโน้มไปทางความเป็นอิสระทางความคิด นวัตกรรม '
      'และการมองมนุษย์ในมุมที่กว้างและเท่าเทียม',
  strengths: [
    'ความคิดสร้างสรรค์และมุมมองที่แตกต่างจากคนส่วนใหญ่',
    'ความเป็นกลางและการมองคนโดยไม่ตัดสินจากภายนอก',
    'พลังในการเชื่อมโยงกลุ่มคนหรือแนวคิดที่มีเป้าหมายร่วม',
  ],
  challenges: [
    'อาจรู้สึกห่างเหินทางอารมณ์เมื่อมุ่งเน้นเหตุผลหรืออุดมการณ์',
    'อาจต้านกรอบหรืออำนาจที่รู้สึกว่าจำกัดอิสระ',
    'อาจยากต่อการเข้าใจเมื่อคนอื่นไม่เห็นภาพเดียวกัน',
  ],
  growthPath:
      'การฝึกเชื่อมโยงอุดมการณ์กับความรู้สึกของตนเองและผู้อื่น '
      'อาจช่วยให้นวัตกรรมของคุณสร้างผลกระทบที่ลึกและยั่งยืนมากขึ้น',
  themeMappings: [
    ThaiThemeMapping(
      category: ThaiFusionThemeCategory.coreSelf,
      theme: 'independent',
      weight: 0.9,
    ),
    ThaiThemeMapping(
      category: ThaiFusionThemeCategory.thinkingStyle,
      theme: 'analytical',
      weight: 0.85,
    ),
    ThaiThemeMapping(
      category: ThaiFusionThemeCategory.relationships,
      theme: 'diplomatic',
      weight: 0.65,
    ),
  ],
);
