import '../enums/thai_fusion_category_id.dart';
import '../enums/thai_fusion_confidence_level.dart';
import '../enums/thai_fusion_pattern_type.dart';
import 'thai_fusion_evidence.dart';
import 'thai_fusion_source_refs.dart';

/// Structural synthesis insight for [ThaiFusionSnapshot].
class ThaiFusionInsight {
  ThaiFusionInsight({
    required this.insightId,
    required this.categoryId,
    required this.patternType,
    required this.structuralWeight,
    required this.confidence,
    required this.evidence,
    required this.sourceRefs,
  }) : assert(
          evidence.isNotEmpty,
          'evidence must not be empty',
        );

  final String insightId;
  final ThaiFusionCategoryId categoryId;
  final ThaiFusionPatternType patternType;
  final double structuralWeight;
  final ThaiFusionConfidenceLevel confidence;
  final List<ThaiFusionEvidence> evidence;
  final ThaiFusionSourceRefs sourceRefs;

  factory ThaiFusionInsight.fromMap(Map<String, dynamic> map) {
    final categoryRaw = map['categoryId'] ?? map['category_id'];
    ThaiFusionCategoryId? categoryId;
    if (categoryRaw is ThaiFusionCategoryId) {
      categoryId = categoryRaw;
    } else if (categoryRaw is String) {
      categoryId = parseThaiFusionCategoryId(categoryRaw);
    }
    if (categoryId == null) {
      throw FormatException('Invalid categoryId: $categoryRaw');
    }

    final patternRaw = map['patternType'] ?? map['pattern_type'];
    ThaiFusionPatternType? patternType;
    if (patternRaw is ThaiFusionPatternType) {
      patternType = patternRaw;
    } else if (patternRaw is String) {
      patternType = parseThaiFusionPatternType(patternRaw);
    }
    if (patternType == null) {
      throw FormatException('Invalid patternType: $patternRaw');
    }

    final confidenceRaw = map['confidence'];
    ThaiFusionConfidenceLevel? confidence;
    if (confidenceRaw is ThaiFusionConfidenceLevel) {
      confidence = confidenceRaw;
    } else if (confidenceRaw is String) {
      confidence = parseThaiFusionConfidenceLevel(confidenceRaw);
    }
    if (confidence == null) {
      throw FormatException('Invalid confidence: $confidenceRaw');
    }

    final structuralWeight = map['structuralWeight'] ?? map['structural_weight'];
    if (structuralWeight is! num) {
      throw FormatException('Invalid structuralWeight: $structuralWeight');
    }

    final evidenceRaw = map['evidence'];
    if (evidenceRaw is! List) {
      throw FormatException('Invalid evidence: $evidenceRaw');
    }

    final sourceRefsRaw = map['sourceRefs'] ?? map['source_refs'];
    if (sourceRefsRaw is! Map) {
      throw FormatException('Invalid sourceRefs: $sourceRefsRaw');
    }

    return ThaiFusionInsight(
      insightId: _requiredString(map['insightId'] ?? map['insight_id']),
      categoryId: categoryId,
      patternType: patternType,
      structuralWeight: structuralWeight.toDouble(),
      confidence: confidence,
      evidence: List<ThaiFusionEvidence>.unmodifiable(
        evidenceRaw
            .whereType<Map>()
            .map(
              (item) => ThaiFusionEvidence.fromMap(
                Map<String, dynamic>.from(item),
              ),
            )
            .toList(growable: false),
      ),
      sourceRefs: ThaiFusionSourceRefs.fromMap(
        Map<String, dynamic>.from(sourceRefsRaw),
      ),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'insightId': insightId,
      'categoryId': categoryId.id,
      'patternType': patternType.id,
      'structuralWeight': structuralWeight,
      'confidence': confidence.id,
      'evidence': evidence.map((item) => item.toMap()).toList(growable: false),
      'sourceRefs': sourceRefs.toMap(),
    };
  }

  @override
  bool operator ==(Object other) {
    return other is ThaiFusionInsight &&
        other.insightId == insightId &&
        other.categoryId == categoryId &&
        other.patternType == patternType &&
        other.structuralWeight == structuralWeight &&
        other.confidence == confidence &&
        other.sourceRefs == sourceRefs &&
        _evidenceListEquals(other.evidence, evidence);
  }

  @override
  int get hashCode => Object.hash(
        insightId,
        categoryId,
        patternType,
        structuralWeight,
        confidence,
        sourceRefs,
        Object.hashAll(evidence),
      );

  static String _requiredString(dynamic raw) {
    if (raw is! String || raw.trim().isEmpty) {
      throw FormatException('Invalid string field: $raw');
    }
    return raw.trim();
  }

  static bool _evidenceListEquals(
    List<ThaiFusionEvidence> a,
    List<ThaiFusionEvidence> b,
  ) {
    if (a.length != b.length) return false;
    for (var i = 0; i < a.length; i++) {
      if (a[i] != b[i]) return false;
    }
    return true;
  }
}
