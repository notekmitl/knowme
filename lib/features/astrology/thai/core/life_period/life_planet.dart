/// Core Thai astrology — the eight planets of the traditional Thai 8-day
/// planetary-strength cycle.
///
/// Each planet owns a fixed *strength* (the number of years its life period
/// lasts) and a human *phase name* so consumers can speak in life language
/// ("ช่วงวางรากฐาน") with the planet kept as supporting information only.
///
/// This lives in the reusable core module (no presentation dependency) so it
/// can be shared by the Life Timeline, Annual Prediction, Future Prediction,
/// AI Chat, Compatibility and Fusion features.
library;

enum LifePlanet { sun, moon, mars, mercury, jupiter, venus, saturn, rahu }

/// Static, reusable metadata for each planet. Strengths follow the traditional
/// Thai cycle (Moon 15, Mars 8, Mercury(day) 17, Saturn 10, Jupiter 19,
/// Rahu 12, Venus 21, Sun 6).
class LifePlanetData {
  const LifePlanetData({
    required this.planet,
    required this.strength,
    required this.thaiName,
    required this.phaseName,
    required this.phaseEssence,
    required this.keyword,
    required this.affinity,
  });

  final LifePlanet planet;

  /// Years this planet's life period lasts.
  final int strength;

  /// Thai planet name ("ดาวเสาร์").
  final String thaiName;

  /// Human life-phase name shown as the period title ("ช่วงวางรากฐาน").
  final String phaseName;

  /// One-line essence of the phase.
  final String phaseEssence;

  /// A single supporting keyword ("ความมั่นคง").
  final String keyword;

  /// Intrinsic domain affinity 0–100 for the seven composite life scores.
  final PlanetAffinity affinity;
}

/// The seven life domains scored across the timeline. `pressure` is friction;
/// the other six are supportive domains.
enum LifeDomain { career, money, love, health, growth, opportunity, pressure }

extension LifeDomainInfo on LifeDomain {
  /// Short Thai label ("การงาน"). A label, never narrative copy.
  String get labelTh => switch (this) {
    LifeDomain.career => 'การงาน',
    LifeDomain.money => 'การเงิน',
    LifeDomain.love => 'ความรัก',
    LifeDomain.health => 'สุขภาพ',
    LifeDomain.growth => 'การเติบโต',
    LifeDomain.opportunity => 'โอกาส',
    LifeDomain.pressure => 'แรงกดดัน',
  };

  /// The six supportive domains (pressure excluded).
  static const List<LifeDomain> supportive = [
    LifeDomain.career,
    LifeDomain.money,
    LifeDomain.love,
    LifeDomain.health,
    LifeDomain.growth,
    LifeDomain.opportunity,
  ];
}

/// Intrinsic 0–100 base levels per life domain, before strength / relationship
/// / evidence modulation.
class PlanetAffinity {
  const PlanetAffinity({
    required this.career,
    required this.money,
    required this.love,
    required this.health,
    required this.growth,
    required this.opportunity,
    required this.pressure,
  });

  final int career;
  final int money;
  final int love;
  final int health;
  final int growth;
  final int opportunity;
  final int pressure;

  /// Intrinsic base level for [domain].
  int valueOf(LifeDomain domain) => switch (domain) {
    LifeDomain.career => career,
    LifeDomain.money => money,
    LifeDomain.love => love,
    LifeDomain.health => health,
    LifeDomain.growth => growth,
    LifeDomain.opportunity => opportunity,
    LifeDomain.pressure => pressure,
  };

  /// The six supportive domains ranked strongest → weakest (pressure excluded).
  List<LifeDomain> get supportRanked {
    final list = [...LifeDomainInfo.supportive]
      ..sort((a, b) => valueOf(b).compareTo(valueOf(a)));
    return list;
  }
}

abstract final class LifePlanets {
  static const Map<LifePlanet, LifePlanetData> data = {
    LifePlanet.saturn: LifePlanetData(
      planet: LifePlanet.saturn,
      strength: 10,
      thaiName: 'ดาวเสาร์',
      phaseName: 'ช่วงวางรากฐาน',
      phaseEssence: 'ช่วงของการตั้งหลัก อดทน และสร้างความมั่นคงให้ตัวเอง',
      keyword: 'ความมั่นคง',
      affinity: PlanetAffinity(
        career: 78,
        money: 60,
        love: 45,
        health: 50,
        growth: 64,
        opportunity: 48,
        pressure: 80,
      ),
    ),
    LifePlanet.jupiter: LifePlanetData(
      planet: LifePlanet.jupiter,
      strength: 19,
      thaiName: 'ดาวพฤหัสบดี',
      phaseName: 'ช่วงเติบโตและขยาย',
      phaseEssence: 'ช่วงที่ประตูเปิดกว้าง โอกาสและการเรียนรู้เข้ามามากขึ้น',
      keyword: 'การเติบโต',
      affinity: PlanetAffinity(
        career: 74,
        money: 70,
        love: 62,
        health: 66,
        growth: 88,
        opportunity: 86,
        pressure: 38,
      ),
    ),
    LifePlanet.rahu: LifePlanetData(
      planet: LifePlanet.rahu,
      strength: 12,
      thaiName: 'ดาวราหู',
      phaseName: 'ช่วงพลิกผันและเปลี่ยนผ่าน',
      phaseEssence: 'ช่วงที่หลายอย่างเปลี่ยนเร็ว ท้าทาย แต่ก็เปิดทางใหม่',
      keyword: 'การเปลี่ยนแปลง',
      affinity: PlanetAffinity(
        career: 60,
        money: 58,
        love: 44,
        health: 46,
        growth: 72,
        opportunity: 78,
        pressure: 74,
      ),
    ),
    LifePlanet.venus: LifePlanetData(
      planet: LifePlanet.venus,
      strength: 21,
      thaiName: 'ดาวศุกร์',
      phaseName: 'ช่วงเก็บเกี่ยวความสุข',
      phaseEssence: 'ช่วงที่ความสัมพันธ์ ความสุข และผลของสิ่งที่ทำมาเริ่มชัด',
      keyword: 'ความสุขและความสัมพันธ์',
      affinity: PlanetAffinity(
        career: 58,
        money: 76,
        love: 90,
        health: 64,
        growth: 60,
        opportunity: 68,
        pressure: 34,
      ),
    ),
    LifePlanet.sun: LifePlanetData(
      planet: LifePlanet.sun,
      strength: 6,
      thaiName: 'ดาวอาทิตย์',
      phaseName: 'ช่วงเปล่งประกาย',
      phaseEssence: 'ช่วงสั้น ๆ ที่ตัวตนและผลงานของคุณถูกมองเห็นชัดเจน',
      keyword: 'การยอมรับ',
      affinity: PlanetAffinity(
        career: 84,
        money: 62,
        love: 52,
        health: 58,
        growth: 66,
        opportunity: 70,
        pressure: 52,
      ),
    ),
    LifePlanet.moon: LifePlanetData(
      planet: LifePlanet.moon,
      strength: 15,
      thaiName: 'ดาวจันทร์',
      phaseName: 'ช่วงดูแลใจ',
      phaseEssence: 'ช่วงที่ชีวิตเรียกหาความนุ่มนวล ครอบครัว และความสงบข้างใน',
      keyword: 'ความรู้สึก',
      affinity: PlanetAffinity(
        career: 52,
        money: 56,
        love: 78,
        health: 80,
        growth: 58,
        opportunity: 54,
        pressure: 40,
      ),
    ),
    LifePlanet.mars: LifePlanetData(
      planet: LifePlanet.mars,
      strength: 8,
      thaiName: 'ดาวอังคาร',
      phaseName: 'ช่วงลงมือและบุกเบิก',
      phaseEssence:
          'ช่วงพลังสูง เหมาะกับการลงมือ ตัดสินใจ และผลักดันสิ่งที่ค้างไว้',
      keyword: 'การลงมือ',
      affinity: PlanetAffinity(
        career: 80,
        money: 60,
        love: 50,
        health: 62,
        growth: 70,
        opportunity: 72,
        pressure: 68,
      ),
    ),
    LifePlanet.mercury: LifePlanetData(
      planet: LifePlanet.mercury,
      strength: 17,
      thaiName: 'ดาวพุธ',
      phaseName: 'ช่วงเรียนรู้และเชื่อมโยง',
      phaseEssence:
          'ช่วงของการคิด สื่อสาร เรียนรู้ และต่อยอดความรู้ให้กลายเป็นโอกาส',
      keyword: 'การเรียนรู้',
      affinity: PlanetAffinity(
        career: 76,
        money: 72,
        love: 56,
        health: 58,
        growth: 80,
        opportunity: 76,
        pressure: 46,
      ),
    ),
  };

  /// Fixed planetary ring. The starting planet depends on weekday of birth, but
  /// the order after the start is always this ring (Saturn → Jupiter → Rahu →
  /// Venus → Sun → Moon → Mars → Mercury → repeat).
  static const List<LifePlanet> ring = [
    LifePlanet.saturn,
    LifePlanet.jupiter,
    LifePlanet.rahu,
    LifePlanet.venus,
    LifePlanet.sun,
    LifePlanet.moon,
    LifePlanet.mars,
    LifePlanet.mercury,
  ];

  static LifePlanetData of(LifePlanet planet) => data[planet]!;

  /// Maps a Dart [DateTime.weekday] (Mon=1 … Sun=7) to its ruling planet, which
  /// is where the life-period ring begins for that person.
  ///
  /// When [wednesdayNightRahu] is true and [weekday] is Wednesday, the start
  /// planet is Rahu (พุธกลางคืน / วันราหู) — the traditional 8-day life-period
  /// branch, separate from Taksa rotation tables.
  static LifePlanet rulerForWeekday(
    int weekday, {
    bool wednesdayNightRahu = false,
  }) {
    if (weekday == DateTime.wednesday && wednesdayNightRahu) {
      return LifePlanet.rahu;
    }
    switch (weekday) {
      case DateTime.monday:
        return LifePlanet.moon;
      case DateTime.tuesday:
        return LifePlanet.mars;
      case DateTime.wednesday:
        return LifePlanet.mercury;
      case DateTime.thursday:
        return LifePlanet.jupiter;
      case DateTime.friday:
        return LifePlanet.venus;
      case DateTime.saturday:
        return LifePlanet.saturn;
      case DateTime.sunday:
      default:
        return LifePlanet.sun;
    }
  }

  /// Maps a lagna-lord content key ("lagna_lord_saturn") to a [LifePlanet].
  static LifePlanet? fromLagnaLordKey(String? key) {
    if (key == null) return null;
    if (key.endsWith('sun')) return LifePlanet.sun;
    if (key.endsWith('moon')) return LifePlanet.moon;
    if (key.endsWith('mars')) return LifePlanet.mars;
    if (key.endsWith('mercury')) return LifePlanet.mercury;
    if (key.endsWith('jupiter')) return LifePlanet.jupiter;
    if (key.endsWith('venus')) return LifePlanet.venus;
    if (key.endsWith('saturn')) return LifePlanet.saturn;
    if (key.endsWith('rahu')) return LifePlanet.rahu;
    return null;
  }
}
