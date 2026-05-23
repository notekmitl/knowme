class ChartPlanetInterpretation {
  const ChartPlanetInterpretation({
    required this.planet,
    required this.en,
    required this.th,
  });

  final String planet;
  final String en;
  final String th;
}

class AstrologyChartModel {
  final Map<String, dynamic> big3;

  final Map<String, dynamic> planets;

  final Map<String, dynamic> insight;

  final Map<String, dynamic> overallSummary;

  final List<ChartPlanetInterpretation> interpretations;

  AstrologyChartModel({
    required this.big3,
    required this.planets,
    required this.insight,
    required this.overallSummary,
    this.interpretations = const [],
  });

  factory AstrologyChartModel.fromMap(Map<String, dynamic> map) {
    return AstrologyChartModel(
      big3: Map<String, dynamic>.from(map['big3'] ?? {}),
      planets: Map<String, dynamic>.from(map['planets'] ?? {}),
      insight: Map<String, dynamic>.from(map['insight'] ?? {}),
      overallSummary: Map<String, dynamic>.from(map['overall_summary'] ?? {}),
      interpretations: _parseInterpretations(map['interpretations']),
    );
  }

  static List<ChartPlanetInterpretation> _parseInterpretations(dynamic raw) {
    if (raw is! List) return const [];

    final out = <ChartPlanetInterpretation>[];
    for (final item in raw) {
      if (item is! Map) continue;

      final planet = item['planet'];
      if (planet is! String || planet.trim().isEmpty) continue;

      out.add(
        ChartPlanetInterpretation(
          planet: planet.trim(),
          en: item['en'] is String ? (item['en'] as String).trim() : '',
          th: item['th'] is String ? (item['th'] as String).trim() : '',
        ),
      );
    }
    return out;
  }

  /// Backend interpretation for [planetKey], locale-aware. Empty if not found.
  String interpretationForPlanet(
    String planetKey, {
    required bool isThai,
    bool allowAlternateLocale = true,
  }) {
    final key = planetKey.toLowerCase();
    for (final item in interpretations) {
      if (item.planet.toLowerCase() != key) continue;

      final primary = isThai ? item.th : item.en;
      if (primary.isNotEmpty) return primary;

      if (allowAlternateLocale) {
        final alternate = isThai ? item.en : item.th;
        if (alternate.isNotEmpty) return alternate;
      }
    }
    return '';
  }
}
