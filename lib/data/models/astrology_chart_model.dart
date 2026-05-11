class AstrologyChartModel {
  final Map<String, dynamic> big3;

  final Map<String, dynamic> planets;

  final List<dynamic> aspects;

  final Map<String, dynamic> houses;

  final Map<String, dynamic> insight;

  AstrologyChartModel({
    required this.big3,

    required this.planets,

    required this.aspects,

    required this.houses,

    required this.insight,
  });

  factory AstrologyChartModel.fromMap(Map<String, dynamic> map) {
    return AstrologyChartModel(
      big3: Map<String, dynamic>.from(map['big3'] ?? {}),

      planets: Map<String, dynamic>.from(map['planets'] ?? {}),

      aspects: List<dynamic>.from(map['aspects'] ?? []),

      houses: Map<String, dynamic>.from(map['houses'] ?? {}),

      insight: Map<String, dynamic>.from(map['insight'] ?? {}),
    );
  }
}
