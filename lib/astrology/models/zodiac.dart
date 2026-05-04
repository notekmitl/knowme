enum Zodiac {
  aries,
  taurus,
  gemini,
  cancer,
  leo,
  virgo,
  libra,
  scorpio,
  sagittarius,
  capricorn,
  aquarius,
  pisces,
}

extension ZodiacExtension on Zodiac {
  String get displayName {
    switch (this) {
      case Zodiac.aries:
        return "Aries";
      case Zodiac.taurus:
        return "Taurus";
      case Zodiac.gemini:
        return "Gemini";
      case Zodiac.cancer:
        return "Cancer";
      case Zodiac.leo:
        return "Leo";
      case Zodiac.virgo:
        return "Virgo";
      case Zodiac.libra:
        return "Libra";
      case Zodiac.scorpio:
        return "Scorpio";
      case Zodiac.sagittarius:
        return "Sagittarius";
      case Zodiac.capricorn:
        return "Capricorn";
      case Zodiac.aquarius:
        return "Aquarius";
      case Zodiac.pisces:
        return "Pisces";
    }
  }
}
