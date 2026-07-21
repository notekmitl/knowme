import '../../models/content_status.dart';
import '../../models/thai_content_key.dart';
import '../../models/thai_content_section.dart';
import '../../models/thai_content_type.dart';
import '../../models/thai_fusion_theme_category.dart';
import '../../models/thai_theme_mapping.dart';

const ThaiContentSection mahabhutaPyadhiSection = ThaiContentSection(
  key: ThaiContentKeys.mahabhutaPyadhi,
  contentType: ThaiContentType.mahabhutaPosition,
  contentStatus: ContentStatus.approved,
  version: 'v1',
  title: 'มหาภูติ — พยาธิ',
  summary:
      'ตำแหน่งพยาธิสะท้อนรูปแบบภายในที่เกี่ยวกับจุดเปราะบางและความไม่มั่นคงของตัวตน '
      'หลายครั้งอาจปรากฏเป็นแนวโน้มที่ทำให้คุณรับรู้บาดแผลภายในได้ลึกกว่าผู้อื่น',
  coreNature:
      'พยาธิในมุมมองมหาภูติพม่าประยุกต์มักสะท้อนสัญญาณชีวิตที่เกี่ยวกับความอ่อนไหวต่อจุดเปราะ '
      'และการรับรู้ความไม่มั่นคงภายใน — เป็น Life-Position Signal ไม่ใช่ตัวตนหลัก',
  strengths: [
    'อาจมีความตระหนักรู้ในตนเองและความรู้สึกที่ลึกซึ้ง',
    'อาจเรียนรู้จากประสบการณ์ยากและพัฒนาความยืดหยุ่นทางใจได้',
    'อาจเข้าใจความเปราะบางของตนเองและผู้อื่นได้ดี',
  ],
  challenges: [
    'อาจรู้สึกไม่มั่นคงเมื่อเผชิญสถานการณ์ที่กระตุ้นจุดเปราะ',
    'อาจยึดติดกับบาดแผลในอดีตนานเกินความจำเป็น',
    'อาจลังเลในการเปิดใจเมื่อกลัวถูกทำร้ายซ้ำ',
  ],
  growthPath:
      'การฝึกรับรู้จุดเปราะโดยไม่ตัดสินตนเอง '
      'อาจช่วยให้พยาธิกลายเป็นพลังเข้าใจตนเองอย่างลึกซึ้งมากขึ้น',
  themeMappings: [
    ThaiThemeMapping(
      category: ThaiFusionThemeCategory.emotionalWorld,
      theme: 'sensitive',
      weight: 0.9,
    ),
    ThaiThemeMapping(
      category: ThaiFusionThemeCategory.strengths,
      theme: 'resilient',
      weight: 0.85,
    ),
    ThaiThemeMapping(
      category: ThaiFusionThemeCategory.thinkingStyle,
      theme: 'reflective',
      weight: 0.8,
    ),
    ThaiThemeMapping(
      category: ThaiFusionThemeCategory.emotionalWorld,
      theme: 'expressive',
      weight: 0.7,
    ),
  ],
);
