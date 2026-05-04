import '../models/astrology_result.dart';
import '../models/zodiac.dart';
import '../models/element.dart';

import 'zodiac_calculator.dart';
import 'chinese_zodiac_calculator.dart';

class AstrologyService {

  Future<AstrologyResult> calculate({
    required DateTime birthDateTime,
    double? lat,
    double? lng,
  }) async {

    final zodiacEnum = ZodiacCalculator.getZodiac(birthDateTime);
    final elementEnum = ZodiacCalculator.getElement(zodiacEnum);

    final zodiac = zodiacEnum.name[0].toUpperCase() + zodiacEnum.name.substring(1);
    final element = elementEnum.name;

    final chinese = ChineseZodiacCalculator.getChineseZodiac(birthDateTime);

    String? ascendant = "Cancer";

    final planets = {
      "sun": {"sign": zodiac},
      "moon": {"sign": "Libra"},
      "mercury": {"sign": "Gemini"},
      "venus": {"sign": "Taurus"},
      "mars": {"sign": "Libra"},
      "jupiter": {"sign": "Scorpio"},
      "saturn": {"sign": "Capricorn"},
    };

    print("PLANETS DEBUG: $planets");

    return AstrologyResult(
      sunSign: zodiac,
      element: element,
      chineseZodiac: chinese,
      ascendant: ascendant,
      planets: planets,
    );
  }
}