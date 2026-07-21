import '../../models/content_status.dart';
import '../../models/thai_content_key.dart';
import '../../models/thai_content_section.dart';
import '../../models/thai_content_type.dart';
import '../../models/thai_fusion_theme_category.dart';
import '../../models/thai_theme_mapping.dart';

const ThaiContentSection lagnaVirgoSection = ThaiContentSection(
  key: ThaiContentKeys.lagnaVirgo,
  contentType: ThaiContentType.lagna,
  contentStatus: ContentStatus.approved,
  version: 'v1',
  title: 'ลัคนาราศีกันย์',
  summary:
      'ลัคนากันย์มักสะท้อนภาพของผู้ที่เข้าหาโลกด้วยการสังเกตและการปรับปรุง '
      'หลายครั้งคุณอาจรู้สึกสบายใจเมื่อสิ่งต่าง ๆ อยู่ในระเบียบและมีคุณภาพ',
  coreNature:
      'แก่นธาตุของลัคนานี้อาจโน้มไปทางความละเอียดรอบคอบ การวิเคราะห์ '
      'และการมุ่งสู่การพัฒนาที่เป็นรูปธรรม',
  strengths: [
    'ความละเอียดรอบคอบและความสามารถในการสังเกตรายละเอียด',
    'การมุ่งมั่นปรับปรุงสิ่งต่าง ๆ ให้ดีขึ้นอย่างต่อเนื่อง',
    'ความน่าเชื่อถือในการทำงานที่ต้องการความแม่นยำ',
  ],
  challenges: [
    'อาจวิจารณ์ตนเองหรือสิ่งรอบตัวมากเกินไป',
    'อาจรู้สึกไม่สบายใจเมื่อสิ่งต่าง ๆ ไม่สมบูรณ์แบบ',
    'อาจลืมมองภาพรวมเมื่อจมอยู่กับรายละเอียด',
  ],
  growthPath:
      'การฝึกยอมรับความไม่สมบูรณ์แบบบางส่วน '
      'อาจช่วยให้ความละเอียดของคุณกลายเป็นพลังสร้างสรรค์แทนแรงกดดัน',
  themeMappings: [
    ThaiThemeMapping(
      category: ThaiFusionThemeCategory.coreSelf,
      theme: 'practical',
      weight: 0.9,
    ),
    ThaiThemeMapping(
      category: ThaiFusionThemeCategory.thinkingStyle,
      theme: 'analytical',
      weight: 0.9,
    ),
    ThaiThemeMapping(
      category: ThaiFusionThemeCategory.workAndAmbition,
      theme: 'specialist',
      weight: 0.75,
    ),
  ],
);
