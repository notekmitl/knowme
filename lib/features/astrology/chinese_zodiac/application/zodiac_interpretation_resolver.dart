import 'package:knowme/data/models/bazi_chart_model.dart';

import '../data/zodiac_personality_library.dart';
import '../domain/zodiac_personality_profile.dart';

/// Resolves Year Animal personality content from existing BaZi chart data.
abstract final class ZodiacInterpretationResolver {
  static ZodiacPersonalityProfile? resolve(BaziYearAnimal animal, String lang) {
    return ZodiacPersonalityLibrary.lookup(animal.en, lang);
  }

  static ZodiacPersonalityProfile? resolveFromChart(
    BaziChartModel chart,
    String lang,
  ) {
    return resolve(chart.yearAnimal, lang);
  }

  static String displayAnimalName(BaziYearAnimal animal, String lang) {
    if (lang == 'th') {
      return _animalThai(animal.en) ?? animal.en;
    }
    return animal.en;
  }

  static String? _animalThai(String en) {
    return switch (en.toLowerCase()) {
      'rat' => 'หนู',
      'ox' => 'วัว',
      'tiger' => 'เสือ',
      'rabbit' => 'กระต่าย',
      'dragon' => 'มังกร',
      'snake' => 'งู',
      'horse' => 'ม้า',
      'goat' => 'แพะ',
      'monkey' => 'ลิง',
      'rooster' => 'ไก่',
      'dog' => 'สุนัข',
      'pig' => 'หมู',
      _ => null,
    };
  }
}
