import '../enums/thai_fusion_confidence_level.dart';

/// Composite confidence summary for [ThaiFusionSnapshot].
class ThaiFusionConfidence {
  const ThaiFusionConfidence({
    required this.overallLevel,
    required this.mirrorLevel,
    required this.themeLevel,
    required this.interpretationLevel,
    required this.distinctSourceFactCount,
  }) : assert(
          distinctSourceFactCount >= 0,
          'distinctSourceFactCount must be non-negative',
        );

  final ThaiFusionConfidenceLevel overallLevel;
  final ThaiFusionConfidenceLevel mirrorLevel;
  final ThaiFusionConfidenceLevel themeLevel;
  final ThaiFusionConfidenceLevel interpretationLevel;
  final int distinctSourceFactCount;

  factory ThaiFusionConfidence.fromMap(Map<String, dynamic> map) {
    return ThaiFusionConfidence(
      overallLevel: _parseLevel(map['overallLevel'] ?? map['overall_level'], 'overallLevel'),
      mirrorLevel: _parseLevel(map['mirrorLevel'] ?? map['mirror_level'], 'mirrorLevel'),
      themeLevel: _parseLevel(map['themeLevel'] ?? map['theme_level'], 'themeLevel'),
      interpretationLevel: _parseLevel(
        map['interpretationLevel'] ?? map['interpretation_level'],
        'interpretationLevel',
      ),
      distinctSourceFactCount: _parseInt(
        map['distinctSourceFactCount'] ?? map['distinct_source_fact_count'],
        'distinctSourceFactCount',
      ),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'overallLevel': overallLevel.id,
      'mirrorLevel': mirrorLevel.id,
      'themeLevel': themeLevel.id,
      'interpretationLevel': interpretationLevel.id,
      'distinctSourceFactCount': distinctSourceFactCount,
    };
  }

  @override
  bool operator ==(Object other) {
    return other is ThaiFusionConfidence &&
        other.overallLevel == overallLevel &&
        other.mirrorLevel == mirrorLevel &&
        other.themeLevel == themeLevel &&
        other.interpretationLevel == interpretationLevel &&
        other.distinctSourceFactCount == distinctSourceFactCount;
  }

  @override
  int get hashCode => Object.hash(
        overallLevel,
        mirrorLevel,
        themeLevel,
        interpretationLevel,
        distinctSourceFactCount,
      );

  static ThaiFusionConfidenceLevel _parseLevel(dynamic raw, String field) {
    if (raw is ThaiFusionConfidenceLevel) return raw;
    if (raw is String) {
      final parsed = parseThaiFusionConfidenceLevel(raw);
      if (parsed != null) return parsed;
    }
    throw FormatException('Invalid $field: $raw');
  }

  static int _parseInt(dynamic raw, String field) {
    if (raw is int) return raw;
    if (raw is num) return raw.toInt();
    throw FormatException('Invalid $field: $raw');
  }
}
