/// Stable lookup keys for Thai Astrology content entries.
abstract final class ThaiContentKeys {
  // --- Lagna (12 rashi) ---

  static const lagnaAries = 'lagna_aries';
  static const lagnaTaurus = 'lagna_taurus';
  static const lagnaGemini = 'lagna_gemini';
  static const lagnaCancer = 'lagna_cancer';
  static const lagnaLeo = 'lagna_leo';
  static const lagnaVirgo = 'lagna_virgo';
  static const lagnaLibra = 'lagna_libra';
  static const lagnaScorpio = 'lagna_scorpio';
  static const lagnaSagittarius = 'lagna_sagittarius';
  static const lagnaCapricorn = 'lagna_capricorn';
  static const lagnaAquarius = 'lagna_aquarius';
  static const lagnaPisces = 'lagna_pisces';

  static const allLagna = <String>[
    lagnaAries,
    lagnaTaurus,
    lagnaGemini,
    lagnaCancer,
    lagnaLeo,
    lagnaVirgo,
    lagnaLibra,
    lagnaScorpio,
    lagnaSagittarius,
    lagnaCapricorn,
    lagnaAquarius,
    lagnaPisces,
  ];

  // --- Lagna Lords (7 grahas) ---

  static const lagnaLordSun = 'lagna_lord_sun';
  static const lagnaLordMoon = 'lagna_lord_moon';
  static const lagnaLordMars = 'lagna_lord_mars';
  static const lagnaLordMercury = 'lagna_lord_mercury';
  static const lagnaLordJupiter = 'lagna_lord_jupiter';
  static const lagnaLordVenus = 'lagna_lord_venus';
  static const lagnaLordSaturn = 'lagna_lord_saturn';

  static const allLagnaLord = <String>[
    lagnaLordSun,
    lagnaLordMoon,
    lagnaLordMars,
    lagnaLordMercury,
    lagnaLordJupiter,
    lagnaLordVenus,
    lagnaLordSaturn,
  ];

  // --- Ramahabhuta (4 elements) ---

  static const ramahabhutaEarth = 'ramahabhuta_earth';
  static const ramahabhutaWater = 'ramahabhuta_water';
  static const ramahabhutaWind = 'ramahabhuta_wind';
  static const ramahabhutaFire = 'ramahabhuta_fire';

  static const allRamahabhuta = <String>[
    ramahabhutaEarth,
    ramahabhutaWater,
    ramahabhutaWind,
    ramahabhutaFire,
  ];

  // --- Mahabhuta Positions (7 positions) ---

  static const mahabhutaPyadhi = 'mahabhuta_pyadhi';
  static const mahabhutaMarana = 'mahabhuta_marana';
  static const mahabhutaThaya = 'mahabhuta_thaya';
  static const mahabhutaPuti = 'mahabhuta_puti';
  static const mahabhutaRachiya = 'mahabhuta_rachiya';
  static const mahabhutaThongchai = 'mahabhuta_thongchai';
  static const mahabhutaAdhibodi = 'mahabhuta_adhibodi';

  static const allMahabhutaPosition = <String>[
    mahabhutaPyadhi,
    mahabhutaMarana,
    mahabhutaThaya,
    mahabhutaPuti,
    mahabhutaRachiya,
    mahabhutaThongchai,
    mahabhutaAdhibodi,
  ];

  // --- Myanmar Seven Numbers (structure only for V1) ---

  static const myanmarSeven1 = 'myanmar_seven_1';
  static const myanmarSeven2 = 'myanmar_seven_2';
  static const myanmarSeven3 = 'myanmar_seven_3';
  static const myanmarSeven4 = 'myanmar_seven_4';
  static const myanmarSeven5 = 'myanmar_seven_5';
  static const myanmarSeven6 = 'myanmar_seven_6';
  static const myanmarSeven7 = 'myanmar_seven_7';

  static const allMyanmarSeven = <String>[
    myanmarSeven1,
    myanmarSeven2,
    myanmarSeven3,
    myanmarSeven4,
    myanmarSeven5,
    myanmarSeven6,
    myanmarSeven7,
  ];

  static const all = <String>[
    ...allLagna,
    ...allLagnaLord,
    ...allRamahabhuta,
    ...allMahabhutaPosition,
    ...allMyanmarSeven,
  ];
}
