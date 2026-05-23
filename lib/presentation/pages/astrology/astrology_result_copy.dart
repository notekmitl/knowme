/// Sign and planet display names for astrology result (TH / EN only).
abstract final class AstrologyResultCopy {
  static String signLabel(String? sign, String lang) {
    if (sign == null || sign.trim().isEmpty) return '—';
    final normalized = sign.trim();
    final title = normalized[0].toUpperCase() +
        normalized.substring(1).toLowerCase();
    if (lang == 'th') {
      return _signsTh[title] ?? title;
    }
    return title;
  }

  static String planetLabel(String planetKey, String lang) {
    final key = planetKey.toLowerCase();
    if (lang == 'th') {
      return _planetsTh[key] ?? key;
    }
    return _planetsEn[key] ??
        (key.isEmpty ? key : key[0].toUpperCase() + key.substring(1));
  }

  static const _signsTh = {
    'Aries': 'ราศีเมษ',
    'Taurus': 'ราศีพฤษภ',
    'Gemini': 'ราศีเมถุน',
    'Cancer': 'ราศีกรกฎ',
    'Leo': 'ราศีสิงห์',
    'Virgo': 'ราศีกันย์',
    'Libra': 'ราศีตุลย์',
    'Scorpio': 'ราศีพิจิก',
    'Sagittarius': 'ราศีธนู',
    'Capricorn': 'ราศีมังกร',
    'Aquarius': 'ราศีกุมภ์',
    'Pisces': 'ราศีมีน',
  };

  static const _planetsTh = {
    'sun': 'ดวงอาทิตย์',
    'moon': 'ดวงจันทร์',
    'mercury': 'ดวงพุธ',
    'venus': 'ดวงศุกร์',
    'mars': 'ดวงอังคาร',
    'jupiter': 'ดวงพฤหัสบดี',
    'saturn': 'ดวงเสาร์',
    'uranus': 'ดวงยูเรนัส',
    'neptune': 'ดวงเนปจูน',
    'pluto': 'ดวงพลูโต',
  };

  static const _planetsEn = {
    'sun': 'Sun',
    'moon': 'Moon',
    'mercury': 'Mercury',
    'venus': 'Venus',
    'mars': 'Mars',
    'jupiter': 'Jupiter',
    'saturn': 'Saturn',
    'uranus': 'Uranus',
    'neptune': 'Neptune',
    'pluto': 'Pluto',
  };
}
