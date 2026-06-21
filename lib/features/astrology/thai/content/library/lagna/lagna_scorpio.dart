import '../../models/content_status.dart';
import '../../models/thai_content_key.dart';
import '../../models/thai_content_section.dart';
import '../../models/thai_content_type.dart';
import '../../models/thai_fusion_theme_category.dart';
import '../../models/thai_theme_mapping.dart';

const ThaiContentSection lagnaScorpioSection = ThaiContentSection(
  key: ThaiContentKeys.lagnaScorpio,
  contentType: ThaiContentType.lagna,
  contentStatus: ContentStatus.approved,
  version: 'v1',
  title: 'ลัคนาราศีพิจิก',
  summary:
      'ลัคนพิจิกมักสะท้อนภาพของผู้ที่เข้าหาโลกด้วยความลึกและความเข้มข้น '
      'หลายครั้งคุณอาจให้ความสำคัญกับสิ่งที่แท้จริงมากกว่าผิวเผิน',
  coreNature:
      'แก่นธาตุของลัคนานี้อาจโน้มไปทางการมองลึก การแปลงเปลี่ยน '
      'และการเข้าใจแรงจูงใจที่ซ่อนอยู่เบื้องหลัง',
  strengths: [
    'ความสามารถในการมองลึกและเข้าใจสิ่งที่ผู้อื่นมองข้าม',
    'ความเข้มข้นและความมุ่งมั่นเมื่อให้ความสำคัญกับสิ่งใดสิ่งหนึ่ง',
    'พลังในการผ่านพ้นวิกฤตและแปลงเปลี่ยนตนเอง',
  ],
  challenges: [
    'อาจไม่ไว้ใจผู้อื่นง่าย ๆ จนกว่าจะพิสูจน์ตนเอง',
    'อาจเก็บความรู้สึกไว้ภายในมากเกินไป',
    'อาจยึดติดกับสิ่งที่สูญเสียหรือความผิดหวัง',
  ],
  growthPath:
      'การฝึกเปิดเผยความรู้สึกอย่างปลอดภัยทีละน้อย '
      'อาจช่วยให้ความลึกของคุณกลายเป็นพลังเชื่อมโยงแทนการป้องกันตนเอง',
  themeMappings: [
    ThaiThemeMapping(
      category: ThaiFusionThemeCategory.coreSelf,
      theme: 'curious',
      weight: 0.95,
    ),
    ThaiThemeMapping(
      category: ThaiFusionThemeCategory.emotionalWorld,
      theme: 'sensitive',
      weight: 0.85,
    ),
    ThaiThemeMapping(
      category: ThaiFusionThemeCategory.growthPath,
      theme: 'embrace_change',
      weight: 0.7,
    ),
  ],
);
