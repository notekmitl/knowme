import 'home_screen_v2_models.dart';

/// User-facing copy — Home V3 UX Conversion Sprint V1 (Thai-first).
abstract final class HomeV3Copy {
  // --- Vocabulary (canonical terms) ---
  static const profileCompletionTitle = 'ความสมบูรณ์ของโปรไฟล์';
  static const deepProfileLabel = 'ภาพรวมตัวตน';
  static const stepAstrology = 'ดวงชะตา';
  static const stepMbti = 'บุคลิก MBTI';
  static const stepBigFive = 'บุคลิก 5 มิติ';
  static const stepEq = 'ความฉลาดทางอารมณ์';
  static const nextStepBadge = 'ขั้นถัดไป';

  // --- Hero ---
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

  // --- Psychology section ---
  static const psychologyTitle = 'แบบทดสอบบุคลิกภาพ';
  static const psychologySubtitle =
      'ทำครบ 3 ขั้น (MBTI · บุคลิก 5 มิติ · EQ) เพื่อเปิดภาพรวมตัวตนฉบับเต็ม';

  static const mbtiCardTitle = 'บุคลิก MBTI';
  static const mbtiCardDescription =
      'บอกว่าคุณมักคิดและตัดสินใจอย่างไร — ใช้เวลา ~4 นาที';
  static const bigFiveCardTitle = 'บุคลิก 5 มิติ';
  static const bigFiveCardDescription =
      'บอกว่าคุณมักทำตัวและตอบสนองอย่างไรในชีวิตจริง — ใช้เวลา ~5 นาที';
  static const eqCardTitle = 'ความฉลาดทางอารมณ์ (EQ)';
  static const eqCardDescription =
      'บอกว่าคุณจัดการอารมณ์และความสัมพันธ์อย่างไร — สิ่งที่ MBTI และบุคลิก 5 มิติ ยังมองไม่เห็น';

  // --- Unlock hero (astrology complete, no MBTI) ---
  static const unlockHeroEyebrow = 'ขั้นที่ 2 จาก 5';
  static const unlockHeroTitle = 'ดวงชะตาพร้อมแล้ว';
  static const unlockHeroBody =
      'โหราศาสตร์บอกมุมมองหนึ่งของคุณ — แบบทดสอบ MBTI จะบอกว่าคุณคิดและตัดสินใจอย่างไร\n'
      'รวมกันแล้ว KnowMe จะสร้างโปรไฟล์เชิงลึกที่สมบูรณ์ขึ้น';
  static const unlockHeroReward =
      '🎁 รางวัล: อ่านตัวอย่างภาพรวมตัวตนส่วนแรกทันทีหลังทำ MBTI (~4 นาที)';
  static const unlockCtaTitle = 'เริ่มแบบทดสอบ MBTI';
  static const unlockCtaSubtitle = '16 คำถาม · ~4 นาที · ปลดล็อกโปรไฟล์เชิงลึก';

  // --- Recovery banner (fallback when unlock hero hidden) ---
  static const recoveryBannerTitle = 'ดวงชะตาครบแล้ว — ต่อด้วยบุคลิก MBTI';
  static const recoveryBannerBody =
      'ใช้เวลา ~4 นาที เพื่อให้ KnowMe เข้าใจคุณลึกขึ้นและเปิดตัวอย่างภาพรวมตัวตน';
  static const recoveryBannerCta = 'เริ่มแบบทดสอบ MBTI';

  // --- Narrative preview ---
  static const narrativePreviewBadge = 'ตัวอย่างภาพรวมตัวตน';
  static const narrativePreviewCta = 'ดูภาพรวมหลายมุมมอง';
  static const narrativePreviewLockedHint = 'ทำขั้นถัดไปเพื่อเปิดอ่าน';
  static const narrativePreviewFallback =
      'บุคลิก MBTI เชื่อมแล้ว — ทำบุคลิก 5 มิติ ต่อเพื่อเปิดภาพรวมตัวตนฉบับเต็ม';

  static String narrativePreviewTitle(int readSections, int totalSections) =>
      'คุณได้อ่าน $readSections จาก $totalSections ส่วน';

  static String narrativePreviewRewardLine(int lockedSections) =>
      lockedSections > 0
          ? 'ทำขั้นที่เหลืออีก ~10 นาที เพื่อเปิดภาพรวมตัวตนฉบับเต็ม'
          : 'ภาพรวมตัวตนฉบับเต็มพร้อมอ่านแล้ว';

  static const narrativeLockedSectionLabels = [
    'ส่วนที่ 2: จุดแข็งและจุดที่ควรระวัง',
    'ส่วนที่ 3: ความสัมพันธ์และอารมณ์',
    'ส่วนที่ 4: แนวโน้มและการเติบโต',
    'ส่วนที่ 5: ภาพรวมตัวตน',
  ];

  // --- MBTI post-test preview ---
  static const mbtiPreviewNextStep =
      'ขั้นถัดไป: บุคลิก 5 มิติ (~5 นาที) — บอกว่าคุณมักทำตัวอย่างไรในชีวิตจริง';
  static const mbtiPreviewBackHome = 'กลับหน้าหลัก — ทำขั้นถัดไป';
  static const mbtiPreviewViewResult = 'ดูผล MBTI';

  // --- Progress subtitles ---
  static const progressSubtitleEmpty =
      'เริ่มจากกรอกข้อมูลเกิดเพื่อเปิดดวงชะตา';
  static const progressSubtitleAstrologyOnly =
      'เริ่มแล้ว — เหลืออีก 4 ขั้น · ขั้นถัดไป: บุคลิก MBTI (~4 นาที)';
  static const progressSubtitleAfterMbti =
      'ขั้นถัดไป: บุคลิก 5 มิติ (~5 นาที) — วัดว่าคุณมักทำตัวอย่างไร';
  static const progressSubtitleAfterBigFive =
      'ขั้นถัดไป: ความฉลาดทางอารมณ์ (~5 นาที) — ด้านที่บุคลิกยังมองไม่เห็น';
  static const progressSubtitleAfterEq =
      'ใกล้ครบแล้ว — ทำขั้นที่ยังขาดเพื่อเปิดภาพรวมตัวตน';
  static const progressSubtitleAlmostDone =
      'ขั้นสุดท้าย: เปิดภาพรวมตัวตน';
  static const progressSubtitleComplete =
      'ครบแล้ว — ภาพรวมตัวตนพร้อมอ่าน';

  static const takeTest = 'ทำแบบทดสอบ';
  static const viewResult = 'ดูผลลัพธ์';
  static const continueTest = 'ทำต่อ';
  static const moreTitle = 'เพิ่มเติม';

  static String psychologyStatusLabel(
    HomePsychologyTestStatus status, {
    bool isNextStep = false,
  }) {
    if (isNextStep && status != HomePsychologyTestStatus.completed) {
      return nextStepBadge;
    }
    return switch (status) {
      HomePsychologyTestStatus.completed => 'มีผลแล้ว',
      HomePsychologyTestStatus.inProgress => 'ทำไปบางส่วน',
      HomePsychologyTestStatus.notStarted => 'พร้อมเริ่ม',
    };
  }
}
