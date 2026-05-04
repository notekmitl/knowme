import '../models/zodiac.dart';
import '../models/element.dart';

class ZodiacCalculator {
  static Zodiac getZodiac(DateTime date) {
    int d = date.day;
    int m = date.month;

    if ((m == 3 && d >= 21) || (m == 4 && d <= 19)) return Zodiac.aries;
    if ((m == 4 && d >= 20) || (m == 5 && d <= 20)) return Zodiac.taurus;
    if ((m == 5 && d >= 21) || (m == 6 && d <= 20)) return Zodiac.gemini;
    if ((m == 6 && d >= 21) || (m == 7 && d <= 22)) return Zodiac.cancer;
    if ((m == 7 && d >= 23) || (m == 8 && d <= 22)) return Zodiac.leo;
    if ((m == 8 && d >= 23) || (m == 9 && d <= 22)) return Zodiac.virgo;
    if ((m == 9 && d >= 23) || (m == 10 && d <= 22)) return Zodiac.libra;
    if ((m == 10 && d >= 23) || (m == 11 && d <= 21)) return Zodiac.scorpio;
    if ((m == 11 && d >= 22) || (m == 12 && d <= 21)) return Zodiac.sagittarius;
    if ((m == 12 && d >= 22) || (m == 1 && d <= 19)) return Zodiac.capricorn;
    if ((m == 1 && d >= 20) || (m == 2 && d <= 18)) return Zodiac.aquarius;

    return Zodiac.pisces;
  }

  static Element getElement(Zodiac zodiac) {
    switch (zodiac) {
      case Zodiac.aries:
      case Zodiac.leo:
      case Zodiac.sagittarius:
        return Element.fire;

      case Zodiac.taurus:
      case Zodiac.virgo:
      case Zodiac.capricorn:
        return Element.earth;

      case Zodiac.gemini:
      case Zodiac.libra:
      case Zodiac.aquarius:
        return Element.air;

      default:
        return Element.water;
    }
  }
}
