class ChineseZodiacCalculator {
  static const animals = [
    'Monkey',
    'Rooster',
    'Dog',
    'Pig',
    'Rat',
    'Ox',
    'Tiger',
    'Rabbit',
    'Dragon',
    'Snake',
    'Horse',
    'Goat',
  ];

  static String getChineseZodiac(DateTime date) {
    int year = date.year;
    return animals[year % 12];
  }
}
