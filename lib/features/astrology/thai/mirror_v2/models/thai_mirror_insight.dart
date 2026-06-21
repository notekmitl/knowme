import '../enums/thai_mirror_dimension_id.dart';
import '../enums/thai_mirror_pattern_type.dart';
import '../enums/thai_mirror_structural_confidence.dart';

/// Structural pattern insight for [ThaiMirrorSnapshot].
///
/// No narrative or presentation fields.
class ThaiMirrorInsight {
  ThaiMirrorInsight({
    required this.insightId,
    required this.dimensionId,
    required this.patternType,
    required this.themeIds,
    required this.structuralWeight,
    required this.confidence,
  }) : assert(
          themeIds.isNotEmpty,
          'themeIds must not be empty',
        );

  final String insightId;
  final ThaiMirrorDimensionId dimensionId;
  final ThaiMirrorPatternType patternType;
  final List<String> themeIds;
  final double structuralWeight;
  final ThaiMirrorStructuralConfidence confidence;

  factory ThaiMirrorInsight.fromMap(Map<String, dynamic> map) {
    final dimensionRaw = map['dimensionId'] ?? map['dimension_id'];
    ThaiMirrorDimensionId? dimensionId;
    if (dimensionRaw is ThaiMirrorDimensionId) {
      dimensionId = dimensionRaw;
    } else if (dimensionRaw is String) {
      dimensionId = parseThaiMirrorDimensionId(dimensionRaw);
    }
    if (dimensionId == null) {
      throw FormatException('Invalid dimensionId: $dimensionRaw');
    }

    final patternRaw = map['patternType'] ?? map['pattern_type'];
    ThaiMirrorPatternType? patternType;
    if (patternRaw is ThaiMirrorPatternType) {
      patternType = patternRaw;
    } else if (patternRaw is String) {
      patternType = parseThaiMirrorPatternType(patternRaw);
    }
    if (patternType == null) {
      throw FormatException('Invalid patternType: $patternRaw');
    }

    final confidenceRaw = map['confidence'];
    ThaiMirrorStructuralConfidence? confidence;
    if (confidenceRaw is ThaiMirrorStructuralConfidence) {
      confidence = confidenceRaw;
    } else if (confidenceRaw is String) {
      confidence = parseThaiMirrorStructuralConfidence(confidenceRaw);
    }
    if (confidence == null) {
      throw FormatException('Invalid confidence: $confidenceRaw');
    }

    final structuralWeight = map['structuralWeight'] ?? map['structural_weight'];
    if (structuralWeight is! num) {
      throw FormatException('Invalid structuralWeight: $structuralWeight');
    }

    final themeIdsRaw = map['themeIds'] ?? map['theme_ids'];
    if (themeIdsRaw is! List) {
      throw FormatException('Invalid themeIds: $themeIdsRaw');
    }

    return ThaiMirrorInsight(
      insightId: _requiredString(map['insightId'] ?? map['insight_id']),
      dimensionId: dimensionId,
      patternType: patternType,
      themeIds: List<String>.unmodifiable(
        themeIdsRaw.whereType<String>().map((item) => item.trim()).toList(),
      ),
      structuralWeight: structuralWeight.toDouble(),
      confidence: confidence,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'insightId': insightId,
      'dimensionId': dimensionId.id,
      'patternType': patternType.id,
      'themeIds': themeIds,
      'structuralWeight': structuralWeight,
      'confidence': confidence.id,
    };
  }

  @override
  bool operator ==(Object other) {
    return other is ThaiMirrorInsight &&
        other.insightId == insightId &&
        other.dimensionId == dimensionId &&
        other.patternType == patternType &&
        other.structuralWeight == structuralWeight &&
        other.confidence == confidence &&
        _stringListEquals(other.themeIds, themeIds);
  }

  @override
  int get hashCode => Object.hash(
        insightId,
        dimensionId,
        patternType,
        structuralWeight,
        confidence,
        Object.hashAll(themeIds),
      );

  static String _requiredString(dynamic raw) {
    if (raw is! String || raw.trim().isEmpty) {
      throw FormatException('Invalid string field: $raw');
    }
    return raw.trim();
  }

  static bool _stringListEquals(List<String> a, List<String> b) {
    if (a.length != b.length) return false;
    for (var i = 0; i < a.length; i++) {
      if (a[i] != b[i]) return false;
    }
    return true;
  }
}
