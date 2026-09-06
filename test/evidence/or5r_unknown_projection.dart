// Independent civil-only oracle shared by VM tests and browser evidence harness.
// No flutter_test or IO dependency; never imported by application runtime.
import 'package:knowme/features/thai_beta/domain/thai_beta_input.dart';

const or5rOmission =
    'ไม่มีเวลาเกิด — รายงานจึงเว้นหัวข้อที่ต้องใช้เวลาเกิด แทนการเดาข้อมูลที่ไม่มี';
const or5rTitles = [
  'ส่วนที่ 1 · พื้นดวงของคุณ',
  'ส่วนที่ 2 · จังหวะชีวิตที่ผ่านมาและปัจจุบัน',
  'ส่วนที่ 3 · แนวโน้มข้างหน้า',
  'ส่วนที่ 4 · ที่มาและข้อจำกัด',
];
const or5rIds = ['civil', 'past-current', 'future', 'limits'];

List<List<String>> expectedUnknownParagraphs(ThaiBetaInput input) {
  const days = [
    'วันจันทร์',
    'วันอังคาร',
    'วันพุธ',
    'วันพฤหัสบดี',
    'วันศุกร์',
    'วันเสาร์',
    'วันอาทิตย์',
  ];
  final d = input.birthDate;
  final date =
      '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';
  return [
    [
      'วันเกิด $date ตรงกับ${days[d.weekday - 1]}ตามปฏิทิน',
      if ((input.province ?? '').isNotEmpty)
        'จังหวัดที่เกิด: ${input.province}',
      or5rOmission,
    ],
    [
      'รายงานเว้นการแบ่งช่วงชีวิตและคำทำนายอดีตหรือปัจจุบัน เพราะยังยืนยันวันทางโหราศาสตร์ไม่ได้เมื่อไม่มีเวลาเกิด',
    ],
    [
      'รายงานเว้นแนวโน้ม 12 เดือนข้างหน้าและช่วงชีวิตถัดไป รวมถึงภาพสรุปคำทำนาย เพราะข้อมูลไม่เพียงพอสำหรับคำนวณส่วนนี้',
    ],
    [
      'ใช้เฉพาะวันเกิดตามปฏิทิน ไม่ใช้เวลาโดยประมาณเพื่อคำนวณวันทางโหราศาสตร์ ลัคนา หรือเรือน',
      'ข้อมูลยังไม่เพียงพอสำหรับสรุปบุคลิก ช่วงชีวิต หรือคำทำนายที่ต้องใช้เวลาเกิด',
      'หัวข้อที่เว้นไว้: ลัคนา เรือน องศา บุคลิกจากพื้นดวง และคำทำนายการงาน การเงิน ความสัมพันธ์ สุขภาพ',
      'คำอ่านโหราศาสตร์เป็นมุมมองตามความเชื่อ ไม่ใช่ข้อยืนยันเหตุการณ์ในชีวิต',
    ],
  ];
}

String expectedUnknownText(ThaiBetaInput input) {
  final paragraphs = expectedUnknownParagraphs(input);
  return [
    'KnowMe — รายงานโหราไทย',
    'ไม่ทราบเวลาเกิด — แสดงข้อมูลที่ยืนยันได้และหัวข้อที่เว้นไว้',
    for (var i = 0; i < or5rTitles.length; i++) ...[
      or5rTitles[i],
      ...paragraphs[i],
    ],
    '',
  ].join('\n');
}
