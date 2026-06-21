import '../../models/content_status.dart';
import '../../models/thai_content_key.dart';
import '../../models/thai_content_section.dart';
import '../../models/thai_content_type.dart';
import '../../models/thai_fusion_theme_category.dart';
import '../../models/thai_theme_mapping.dart';

const ThaiContentSection mahabhutaPutiSection = ThaiContentSection(
  key: ThaiContentKeys.mahabhutaPuti,
  contentType: ThaiContentType.mahabhutaPosition,
  contentStatus: ContentStatus.approved,
  version: 'v1',
  title: 'มหาภูติ — ปูติ',
  summary:
      'ตำแหน่งปูติสะท้อนรูปแบบภายในที่เกี่ยวกับข้อบกพร่องและบทเรียนที่อาจเกิดซ้ำ '
      'หลายครั้งอาจปรากฏเป็นแนวโน้มที่ทำให้คุณเห็นจุดที่ต้องซ่อมแซมในตนเองได้ชัด',
  coreNature:
      'ปูติในมุมมองมหาภูติพม่าประยุกต์มักสะท้อนสัญญาณชีวิตที่เกี่ยวกับการเรียนรู้จากข้อบกพร่อง '
      'และรูปแบบที่อาจวนซ้ำ — เป็น Life-Position Signal ไม่ใช่คำตำหนิ',
  strengths: [
    'อาจสังเกตรูปแบบซ้ำในตนเองและเริ่มปรับได้',
    'อาจมีความจริงใจต่อจุดอ่อนของตนเอง',
    'อาจพัฒนาตนเองผ่านบทเรียนที่เกิดขึ้นซ้ำได้',
  ],
  challenges: [
    'อาจวิพากษ์วิจารณ์ตนเองมากเกินไปเมื่อเห็นข้อบกพร่อง',
    'อาจรู้สึกท้อเมื่อบทเรียนเดิมเกิดขึ้นซ้ำ',
    'อาจมุ่งแก้ไขจุดอ่อนมากจนลืมจุดแข็ง',
  ],
  growthPath:
      'การฝึกมองปูติเป็นพื้นที่เรียนรู้ ไม่ใช่ข้อบกพร่องถาวร '
      'อาจช่วยให้การซ่อมแซมภายในเกิดขึ้นอย่างสมดุล',
  themeMappings: [
    ThaiThemeMapping(
      category: ThaiFusionThemeCategory.thinkingStyle,
      theme: 'reflective',
      weight: 0.9,
    ),
    ThaiThemeMapping(
      category: ThaiFusionThemeCategory.strengths,
      theme: 'persistence',
      weight: 0.85,
    ),
    ThaiThemeMapping(
      category: ThaiFusionThemeCategory.growthPath,
      theme: 'develop_patience',
      weight: 0.8,
    ),
    ThaiThemeMapping(
      category: ThaiFusionThemeCategory.thinkingStyle,
      theme: 'detail_oriented',
      weight: 0.7,
    ),
  ],
);
