/// Presentation-only life-stage context for Thai Life Map narrative.
///
/// Does **not** change engine period boundaries. The presenter supplies the
/// reader-relevant age for each period so a long astrology window cannot turn
/// a child into an adult in user-facing copy.
library;

enum ThaiLifeStageBand {
  earlyChildhood,
  schoolAge,
  teen,
  youngAdult,
  workingAdult,
  midlife,
  elder,
}

abstract final class ThaiLifeStageContext {
  /// Inclusive age bands for narrative tone only.
  static ThaiLifeStageBand fromAge(int age) {
    if (age < 1) return ThaiLifeStageBand.earlyChildhood;
    if (age <= 6) return ThaiLifeStageBand.earlyChildhood;
    if (age <= 12) return ThaiLifeStageBand.schoolAge;
    if (age <= 17) return ThaiLifeStageBand.teen;
    if (age <= 29) return ThaiLifeStageBand.youngAdult;
    if (age <= 49) return ThaiLifeStageBand.workingAdult;
    if (age <= 64) return ThaiLifeStageBand.midlife;
    return ThaiLifeStageBand.elder;
  }

  static String bandLabelTh(ThaiLifeStageBand band) => switch (band) {
    ThaiLifeStageBand.earlyChildhood => 'วัยเด็กเล็ก',
    ThaiLifeStageBand.schoolAge => 'วัยเรียน',
    ThaiLifeStageBand.teen => 'วัยรุ่น',
    ThaiLifeStageBand.youngAdult => 'วัยเริ่มต้นผู้ใหญ่',
    ThaiLifeStageBand.workingAdult => 'วัยทำงาน',
    ThaiLifeStageBand.midlife => 'วัยกลางคน',
    ThaiLifeStageBand.elder => 'วัยสูงอายุ',
  };

  static bool isChildOriented(ThaiLifeStageBand band) =>
      band == ThaiLifeStageBand.earlyChildhood ||
      band == ThaiLifeStageBand.schoolAge;

  static bool allowsAdultCareerMoneyRomance(ThaiLifeStageBand band) =>
      band == ThaiLifeStageBand.youngAdult ||
      band == ThaiLifeStageBand.workingAdult ||
      band == ThaiLifeStageBand.midlife ||
      band == ThaiLifeStageBand.elder;

  /// Remap engine domain keys into narrative-safe domains for the stage.
  static String narrativeDomain(String engineDomain, ThaiLifeStageBand band) {
    if (allowsAdultCareerMoneyRomance(band)) return engineDomain;
    // Children / teens: never lead with adult career, money, or romance.
    switch (engineDomain) {
      case 'career':
        return band == ThaiLifeStageBand.teen ? 'growth' : 'growth';
      case 'money':
        return 'health'; // security / care framing lives under health/care bank
      case 'love':
        return band == ThaiLifeStageBand.teen ? 'love' : 'growth';
      default:
        return engineDomain;
    }
  }
}
