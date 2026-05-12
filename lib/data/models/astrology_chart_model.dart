class AstrologyChartModel {
  final Map<String, dynamic> big3;

  final Map<String, dynamic> planets;

  final Map<String, dynamic> insight;

  final Map<String, dynamic> overallSummary;

  AstrologyChartModel({
    required this.big3,
    required this.planets,
    required this.insight,
    required this.overallSummary,
  });

  factory AstrologyChartModel.fromMap(Map<String, dynamic> map) {
    return AstrologyChartModel(
      big3: Map<String, dynamic>.from(map['big3'] ?? {}),

      planets: Map<String, dynamic>.from(map['planets'] ?? {}),

      insight: Map<String, dynamic>.from(map['insight'] ?? {}),

      overallSummary: Map<String, dynamic>.from(map['overall_summary'] ?? {}),
    );
  }
}
