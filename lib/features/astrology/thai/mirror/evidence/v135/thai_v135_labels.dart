import 'package:knowme/features/astrology/thai/content/models/thai_content_key.dart';
import 'package:knowme/features/astrology/thai/core/life_period/life_planet.dart';

/// Human Thai labels for V1.3.5 evidence facts (presentation helpers only).
abstract final class ThaiV135Labels {
  static const lagnaTh = <String, String>{
    ThaiContentKeys.lagnaAries: 'เมษ',
    ThaiContentKeys.lagnaTaurus: 'พฤษภ',
    ThaiContentKeys.lagnaGemini: 'มิถุน',
    ThaiContentKeys.lagnaCancer: 'กรกฎ',
    ThaiContentKeys.lagnaLeo: 'สิงห์',
    ThaiContentKeys.lagnaVirgo: 'กันย์',
    ThaiContentKeys.lagnaLibra: 'ตุลย์',
    ThaiContentKeys.lagnaScorpio: 'พิจิก',
    ThaiContentKeys.lagnaSagittarius: 'ธนู',
    ThaiContentKeys.lagnaCapricorn: 'มังกร',
    ThaiContentKeys.lagnaAquarius: 'กุมภ์',
    ThaiContentKeys.lagnaPisces: 'มีน',
  };

  static const lordTh = <String, String>{
    ThaiContentKeys.lagnaLordSun: 'อาทิตย์',
    ThaiContentKeys.lagnaLordMoon: 'จันทร์',
    ThaiContentKeys.lagnaLordMars: 'อังคาร',
    ThaiContentKeys.lagnaLordMercury: 'พุธ',
    ThaiContentKeys.lagnaLordJupiter: 'พฤหัสบดี',
    ThaiContentKeys.lagnaLordVenus: 'ศุกร์',
    ThaiContentKeys.lagnaLordSaturn: 'เสาร์',
  };

  static String lagna(String? key) =>
      key == null ? 'ยังยืนยันลัคนาไม่ได้' : (lagnaTh[key] ?? key);

  static String lord(String? key) =>
      key == null ? 'ยังยืนยันเจ้าเรือนลัคนาไม่ได้' : (lordTh[key] ?? key);

  static String planet(LifePlanet p) => LifePlanets.of(p).thaiName;

  static String weekdayTh(int weekday) => switch (weekday) {
        DateTime.monday => 'วันจันทร์',
        DateTime.tuesday => 'วันอังคาร',
        DateTime.wednesday => 'วันพุธ',
        DateTime.thursday => 'วันพฤหัสบดี',
        DateTime.friday => 'วันศุกร์',
        DateTime.saturday => 'วันเสาร์',
        DateTime.sunday => 'วันอาทิตย์',
        _ => 'วันไม่ทราบ',
      };
}
