import '../../models/content_status.dart';
import '../../models/thai_content_key.dart';
import '../../models/thai_content_section.dart';
import '../../models/thai_content_type.dart';
import '../../models/thai_fusion_theme_category.dart';
import '../../models/thai_theme_mapping.dart';

const ThaiContentSection ramahabhutaWindSection = ThaiContentSection(
  key: ThaiContentKeys.ramahabhutaWind,
  contentType: ThaiContentType.ramahabhuta,
  contentStatus: ContentStatus.approved,
  version: 'v1',
  title: 'รามหาภูติ — ธาตุลม',
  summary:
      'รามหาภูติลมสะท้อนรูปแบบพลังที่เคลื่อนไหวและแลกเปลี่ยน '
      'หลายครั้งคุณอาจรู้สึกมีชีวิตชีวาเมื่อได้เรียนรู้และสื่อสารความคิด',
  coreNature:
      'ธาตุลมในมุมมองรามหาภูติมักสะท้อนแนวโน้มทางจิตใจที่ยืดหยุ่น อยากรู้ '
      'และเปิดรับข้อมูลใหม่ — เป็นรูปแบบพลังที่เน้นการเชื่อมโยงและการปรับตัว',
  strengths: [
    'อาจเรียนรู้และปรับมุมมองได้เร็วเมื่อได้รับข้อมูลใหม่',
    'อาจสื่อสารความคิดและเชื่อมโยงแนวคิดจากหลายแหล่งได้ดี',
    'อาจปรับตัวในสถานการณ์ที่เปลี่ยนแปลงได้คล่อง',
  ],
  challenges: [
    'อาจกระจัดกระจายความสนใจเมื่อมีสิ่งเร้าหลายอย่างพร้อมกัน',
    'อาจลึกซึ้งน้อยลงเมื่อเปลี่ยนโฟกัสบ่อยเกินไป',
    'อาจวิเคราะห์มากจนลืมฟังความรู้สึกของตนเอง',
  ],
  growthPath:
      'การฝึกเลือกโฟกัสสำคัญและลงลึกทีละเรื่อง '
      'อาจช่วยให้ความคล่องตัวของธาตุลมกลายเป็นความเชี่ยวชาญที่แท้จริง',
  themeMappings: [
    ThaiThemeMapping(
      category: ThaiFusionThemeCategory.coreSelf,
      theme: 'curious',
      weight: 0.85,
    ),
    ThaiThemeMapping(
      category: ThaiFusionThemeCategory.coreSelf,
      theme: 'adaptable',
      weight: 0.8,
    ),
    ThaiThemeMapping(
      category: ThaiFusionThemeCategory.strengths,
      theme: 'communication',
      weight: 0.8,
    ),
    ThaiThemeMapping(
      category: ThaiFusionThemeCategory.thinkingStyle,
      theme: 'analytical',
      weight: 0.75,
    ),
  ],
);
