import 'home_screen_v2_models.dart';

/// User-facing copy — Home V3.8.
abstract final class HomeV3Copy {
  static const heroTitle = '🔮 ดวงของคุณ';
  static const heroEmptyHint =
      'เมื่อมีข้อมูลเกิดครบ ภาพรวมดวงจะปรากฏที่นี่ — ให้คุณรู้สึกว่า KnowMe เข้าใจคุณแล้ว';
  static const viewFullAstrology = 'ดูผลโหราศาสตร์ทั้งหมด';

  static const signatureTitle = '✨ หลายมุมมองสะท้อนตรงกันว่า...';
  static const signatureEmptyHint =
      'เมื่อมีมุมต่าง ๆ พร้อม ภาพรวมที่สะท้อนซ้ำกันจะปรากฏที่นี่';

  static const insightSectionTitle = 'สิ่งที่ KnowMe เข้าใจเกี่ยวกับคุณ';
  static const insightEmptyHint =
      'เมื่อมีมุมต่าง ๆ พร้อม บทสะท้อนสั้น ๆ จะปรากฏที่นี่';
  static const viewFullInsight = 'ดูภาพรวมทั้งหมด';

  static const profileTitle = 'โปรไฟล์';
  static const profileEmptyName = 'ยังไม่ได้ตั้งชื่อ';
  static const profileEmptyField = '—';
  static const profileCompletenessEmpty = 'เพิ่มข้อมูลเกิดเพื่อให้ดวงสะท้อนชัดขึ้น';
  static const profileCompletenessPartial = 'ข้อมูลเกิดบางส่วนพร้อมแล้ว';
  static const profileCompletenessComplete = 'ข้อมูลเกิดครบแล้ว';
  static const editProfile = 'แก้ไขข้อมูล';

  static const psychologyTitle = 'แบบทดสอบบุคลิกภาพ';
  static const psychologySubtitle =
      'หากอยากรู้จักตัวเองในอีกมุมหนึ่ง คุณสามารถลองสำรวจแบบทดสอบเพิ่มเติมได้';

  static const unlockHeroTitle = 'Astrology is complete.';
  static const unlockHeroBody =
      'Your profile is only 35% discovered.\n\nComplete one short test to unlock deeper insights.';
  static const unlockHeroProgress = 'Your profile is only 35% discovered.';
  static const unlockCtaTitle = 'Unlock Your Deep Profile';
  static const unlockCtaSubtitle = '16 Questions · ~4 Minutes';

  static const recoveryBannerTitle = 'Your astrology profile is ready.';
  static const recoveryBannerBody =
      'Unlock the missing half of your profile with a 4-minute personality test.';
  static const recoveryBannerCta = 'Start 4-minute test';

  static const narrativePreviewTitle = 'New insight unlocked';
  static const narrativePreviewCta = 'Continue discovering yourself';
  static const narrativePreviewLockedHint = 'Complete more tests to reveal';
  static const takeTest = 'ทำแบบทดสอบ';
  static const viewResult = 'ดูผลลัพธ์';
  static const continueTest = 'ทำต่อ';

  static const moreTitle = 'เพิ่มเติม';

  static String psychologyStatusLabel(HomePsychologyTestStatus status) {
    return switch (status) {
      HomePsychologyTestStatus.completed => 'มีผลแล้ว',
      HomePsychologyTestStatus.inProgress => 'ทำไปบางส่วน',
      HomePsychologyTestStatus.notStarted => 'พร้อมสำรวจ',
    };
  }
}
