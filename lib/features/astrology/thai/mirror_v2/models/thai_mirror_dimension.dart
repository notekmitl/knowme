import '../enums/thai_mirror_dimension_id.dart';
import '../enums/thai_mirror_structural_confidence.dart';
import 'thai_mirror_evidence.dart';

/// Self-understanding dimension in [ThaiMirrorSnapshot].
class ThaiMirrorDimension {
  ThaiMirrorDimension({
    required this.dimensionId,
    required this.prominence,
    required this.confidence,
    required this.leadingThemeIds,
    required this.evidence,
  }) : assert(
          leadingThemeIds.isNotEmpty,
          'leadingThemeIds must not be empty',
        ),
        assert(
          evidence.isNotEmpty,
          'evidence must not be empty',
        );

  final ThaiMirrorDimensionId dimensionId;
  final double prominence;
  final ThaiMirrorStructuralConfidence confidence;
  final List<String> leadingThemeIds;
  final List<ThaiMirrorEvidence> evidence;

  factory ThaiMirrorDimension.fromMap(Map<String, dynamic> map) {
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

    final prominence = map['prominence'];
    if (prominence is! num) {
      throw FormatException('Invalid prominence: $prominence');
    }

    final leadingThemeIdsRaw = map['leadingThemeIds'] ?? map['leading_theme_ids'];
    if (leadingThemeIdsRaw is! List) {
      throw FormatException('Invalid leadingThemeIds: $leadingThemeIdsRaw');
    }

    final evidenceRaw = map['evidence'];
    if (evidenceRaw is! List) {
      throw FormatException('Invalid evidence: $evidenceRaw');
    }

    return ThaiMirrorDimension(
      dimensionId: dimensionId,
      prominence: prominence.toDouble(),
      confidence: confidence,
      leadingThemeIds: List<String>.unmodifiable(
        leadingThemeIdsRaw
            .whereType<String>()
            .map((item) => item.trim())
            .toList(),
      ),
      evidence: List<ThaiMirrorEvidence>.unmodifiable(
        evidenceRaw
            .whereType<Map>()
            .map(
              (item) => ThaiMirrorEvidence.fromMap(
                Map<String, dynamic>.from(item),
              ),
            )
            .toList(growable: false),
      ),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'dimensionId': dimensionId.id,
      'prominence': prominence,
      'confidence': confidence.id,
      'leadingThemeIds': leadingThemeIds,
      'evidence': evidence.map((item) => item.toMap()).toList(growable: false),
    };
  }

  @override
  bool operator ==(Object other) {
    return other is ThaiMirrorDimension &&
        other.dimensionId == dimensionId &&
        other.prominence == prominence &&
        other.confidence == confidence &&
        _stringListEquals(other.leadingThemeIds, leadingThemeIds) &&
        _evidenceListEquals(other.evidence, evidence);
  }

  @override
  int get hashCode => Object.hash(
        dimensionId,
        prominence,
        confidence,
        Object.hashAll(leadingThemeIds),
        Object.hashAll(evidence),
      );

  static bool _stringListEquals(List<String> a, List<String> b) {
    if (a.length != b.length) return false;
    for (var i = 0; i < a.length; i++) {
      if (a[i] != b[i]) return false;
    }
    return true;
  }

  static bool _evidenceListEquals(
    List<ThaiMirrorEvidence> a,
    List<ThaiMirrorEvidence> b,
  ) {
    if (a.length != b.length) return false;
    for (var i = 0; i < a.length; i++) {
      if (a[i] != b[i]) return false;
    }
    return true;
  }
}
