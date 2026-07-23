import 'life_planet.dart';

/// Annual ทักษาจร role labels (Canon `taksaRole.*` surface forms).
abstract final class AnnualTaksaRoles {
  static const boriwan = 'บริวาร';
  static const ayu = 'อายุ';
  static const det = 'เดช';
  static const sri = 'ศรี';
  static const mula = 'มูละ';
  static const utsaha = 'อุตสาหะ';
  static const montri = 'มนตรี';
  static const kalakini = 'กาฬกิณี';

  /// Role order after the year's บริวารจร planet.
  static const ordered = [
    boriwan,
    ayu,
    det,
    sri,
    mula,
    utsaha,
    montri,
    kalakini,
  ];
}

/// One Thai astrological age year (อายุโหร 1–108) with ทักษาจร placement.
class AnnualTaksaYear {
  const AnnualTaksaYear({
    required this.age,
    required this.house,
    required this.boriwanPlanet,
    required this.isTagklang,
    required this.roleByPlanet,
  });

  /// Inclusive Thai age year 1–108.
  final int age;

  /// House number on the annual path (๙ for ตากลาง).
  final int house;

  /// Planet that falls on this age as บริวารจร (null when [isTagklang]).
  final LifePlanet? boriwanPlanet;

  /// True when this year is the intercalary ตากลาง ๙ after อาทิตย์ ๑.
  final bool isTagklang;

  /// Full role map for the eight ring planets this year.
  final Map<LifePlanet, String> roleByPlanet;

  String get boriwanLabel {
    if (isTagklang) return 'ตากลาง';
    final p = boriwanPlanet;
    if (p == null) return 'ไม่ทราบ';
    return LifePlanets.of(p).thaiName;
  }
}

/// Deterministic annual ทักษาจร engine for ages 1–108.
///
/// - Age 1 starts from the birth-day ruler (including พุธกลางคืน → ราหู when
///   resolved upstream).
/// - House walk for planet years: ๑ → ๒ → ๓ → ๔ → ๗ → ๕ → ๘ → ๖
/// - When the walk reaches อาทิตย์ as บริวาร (อาทิตย์ ๑), emit that year at the
///   current path house, then emit one ตากลาง year at house ๙, then continue
///   with จันทร์ at the next path house.
/// - The age planet is บริวารจร; remaining planets take อายุ…กาฬกิณี in ring order.
abstract final class AnnualTaksaEngine {
  /// House path (Arabic numerals matching Thai ๑…๖ in the brief).
  static const housePath = [1, 2, 3, 4, 7, 5, 8, 6];

  static const tagklangHouse = 9;

  static List<AnnualTaksaYear> build({
    required LifePlanet startPlanet,
    int maxAge = 108,
  }) {
    final ring = LifePlanets.ring;
    final startIndex = ring.indexOf(startPlanet);
    final out = <AnnualTaksaYear>[];

    var age = 1;
    var planetStep = 0;
    var houseStep = 0;

    while (age <= maxAge) {
      final planet = ring[(startIndex + planetStep) % ring.length];
      final house = housePath[houseStep % housePath.length];

      out.add(
        _year(
          age: age,
          house: house,
          boriwan: planet,
          isTagklang: false,
          startIndex: startIndex,
          planetStep: planetStep,
        ),
      );
      age++;

      // อาทิตย์ ๑ → intercalary ตากลาง ๙ before จันทร์ ๒.
      if (planet == LifePlanet.sun && age <= maxAge) {
        out.add(
          _year(
            age: age,
            house: tagklangHouse,
            boriwan: null,
            isTagklang: true,
            startIndex: startIndex,
            planetStep: planetStep,
          ),
        );
        age++;
      }

      planetStep++;
      houseStep++;
    }

    return out;
  }

  /// Years whose Thai age falls inside an inclusive major period window.
  static List<AnnualTaksaYear> forAgeRange({
    required LifePlanet startPlanet,
    required int startAge,
    required int endAge,
  }) {
    return build(startPlanet: startPlanet)
        .where((y) => y.age >= startAge && y.age <= endAge)
        .toList(growable: false);
  }

  static AnnualTaksaYear _year({
    required int age,
    required int house,
    required LifePlanet? boriwan,
    required bool isTagklang,
    required int startIndex,
    required int planetStep,
  }) {
    final roles = <LifePlanet, String>{};
    final ring = LifePlanets.ring;
    for (var i = 0; i < ring.length; i++) {
      final p = ring[(startIndex + planetStep + i) % ring.length];
      roles[p] = AnnualTaksaRoles.ordered[i];
    }

    return AnnualTaksaYear(
      age: age,
      house: house,
      boriwanPlanet: boriwan,
      isTagklang: isTagklang,
      roleByPlanet: Map.unmodifiable(roles),
    );
  }
}
