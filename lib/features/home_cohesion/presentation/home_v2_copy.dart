import 'home_screen_v2_models.dart';

/// User-facing Home V2 copy — personal space tone, no funnel wording.
abstract final class HomeV2Copy {
  static const profileTitle = 'โปรไฟล์ของคุณ';
  static const profileEmptyName = 'ยังไม่ได้ตั้งชื่อ';
  static const profileEmptyField = '—';
  static const profileCompletenessEmpty = 'เพิ่มข้อมูลเกิดเพื่อให้ดวงสะท้อนชัดขึ้น';
  static const profileCompletenessPartial = 'ข้อมูลเกิดบางส่วนพร้อมแล้ว';
  static const profileCompletenessComplete = 'ข้อมูลเกิดครบแล้ว';
  static const editProfile = 'แก้ไขโปรไฟล์';

  static const astrologyTitle = 'ดวงของคุณ';
  static const astrologyEmptyHint =
      'เมื่อมีข้อมูลเกิดครบ ภาพรวมดวงจะปรากฏที่นี่ให้คุณอ่านได้ทันที';
  static const viewAstrologyResult = 'ดูผลดวงเต็ม';

  static const combinedReflectionTitle = 'ภาพรวมที่ KnowMe เข้าใจเกี่ยวกับคุณ';
  static const combinedReflectionEmptyHint =
      'เมื่อมีมุมต่าง ๆ พร้อม บทสะท้อนสั้น ๆ จะปรากฏที่นี่';
  static const viewCombinedReflection = 'ดูภาพรวมเต็ม';

  static const labelAstrologyAngle = 'จากดวงของคุณ';
  static const labelPersonalityAngle = 'จากบุคลิกภาพของคุณ';
  static const labelCrossAngle = 'ภาพรวมจากหลายมุม';

  static const psychologyTitle = 'แบบทดสอบบุคลิกภาพ';
  static const psychologySubtitle =
      'หากอยากรู้จักตัวเองในอีกมุมหนึ่ง คุณสามารถลองสำรวจแบบทดสอบเพิ่มเติมได้';
  static const takeTest = 'ทำแบบทดสอบ';
  static const viewResult = 'ดูผลลัพธ์';
  static const continueTest = 'ทำต่อ';

  static const moreTitle = 'เพิ่มเติม';

  static String psychologyStatusLabel(HomePsychologyTestStatus status) {
    return switch (status) {
      HomePsychologyTestStatus.notStarted => 'ยังไม่เริ่ม',
      HomePsychologyTestStatus.inProgress => 'ทำไปบางส่วน',
      HomePsychologyTestStatus.completed => 'มีผลแล้ว',
    };
  }
}
