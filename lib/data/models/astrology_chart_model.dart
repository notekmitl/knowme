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
  final String version;

  final String contractId;

  final String engineVersion;

  final String inputHash;

  final Map<String, dynamic> big3;

  final Map<String, dynamic> planets;

  final Map<String, dynamic> insight;

  final Map<String, dynamic> overallSummary;

  final Map<String, dynamic> houses;

  final List<Map<String, dynamic>> aspects;

  final Map<String, dynamic> analysis;

  final Map<String, dynamic> reader;

  final List<ChartPlanetInterpretation> interpretations;

  AstrologyChartModel({
    this.version = '',
    this.contractId = '',
    this.engineVersion = '',
    this.inputHash = '',
    required this.big3,
    required this.planets,
    required this.insight,
    required this.overallSummary,
    this.houses = const {},
    this.aspects = const [],
    this.analysis = const {},
    this.reader = const {},
    this.interpretations = const [],
  });

  factory AstrologyChartModel.fromMap(Map<String, dynamic> map) {
    return AstrologyChartModel(
      version: map['version'] is String ? map['version'] as String : '',
      contractId: map['contract_id'] is String
          ? map['contract_id'] as String
          : '',
      engineVersion: map['engine_version'] is String
          ? map['engine_version'] as String
          : '',
      inputHash: map['input_hash'] is String ? map['input_hash'] as String : '',
      big3: Map<String, dynamic>.from(map['big3'] ?? {}),
      planets: Map<String, dynamic>.from(map['planets'] ?? {}),
      insight: Map<String, dynamic>.from(map['insight'] ?? {}),
      overallSummary: Map<String, dynamic>.from(map['overall_summary'] ?? {}),
      houses: Map<String, dynamic>.from(map['houses'] ?? {}),
      aspects: _parseMaps(map['aspects']),
      analysis: Map<String, dynamic>.from(map['analysis'] ?? {}),
      reader: Map<String, dynamic>.from(map['reader'] ?? {}),
      interpretations: _parseInterpretations(map['interpretations']),
    );
  }

  static List<Map<String, dynamic>> _parseMaps(dynamic raw) {
    if (raw is! List) return const [];
    return [
      for (final value in raw)
        if (value is Map) Map<String, dynamic>.from(value),
    ];
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
