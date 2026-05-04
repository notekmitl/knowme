class AstrologyResult {
  final String sunSign;
  final String element;
  final String chineseZodiac;
  final String? ascendant;

  final Map<String, dynamic> planets;

  AstrologyResult({
    required this.sunSign,
    required this.element,
    required this.chineseZodiac,
    this.ascendant,
    required this.planets,
  });

  /// =============================
  /// FROM FIRESTORE
  /// =============================
  factory AstrologyResult.fromMap(Map<String, dynamic> map) {

    Map<String, dynamic> parsedPlanets = {};

    if (map["planets"] != null) {
      parsedPlanets = Map<String, dynamic>.from(map["planets"]);
    }

    return AstrologyResult(
      sunSign: map["sunSign"] ?? "",
      element: map["element"] ?? "",
      chineseZodiac: map["chineseZodiac"] ?? "",
      ascendant: map["ascendant"],
      planets: parsedPlanets,
    );
  }

  /// =============================
  /// TO FIRESTORE
  /// =============================
  Map<String, dynamic> toMap() {
    return {
      "sunSign": sunSign,
      "element": element,
      "chineseZodiac": chineseZodiac,
      "ascendant": ascendant,
      "planets": planets,
    };
  }

  /// =============================
  /// Helper functions
  /// =============================

  String getPlanetSign(String planet) {
    if (!planets.containsKey(planet)) return "";

    final value = planets[planet];

    if (value is Map && value["sign"] != null) {
      return value["sign"];
    }

    if (value is String) {
      return value;
    }

    return "";
  }

  /// ใช้ง่ายใน UI

  String get sun => getPlanetSign("sun");
  String get moon => getPlanetSign("moon");
  String get mercury => getPlanetSign("mercury");
  String get venus => getPlanetSign("venus");
  String get mars => getPlanetSign("mars");
  String get jupiter => getPlanetSign("jupiter");
  String get saturn => getPlanetSign("saturn");
}