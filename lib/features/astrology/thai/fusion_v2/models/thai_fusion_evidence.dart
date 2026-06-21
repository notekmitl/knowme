import '../enums/thai_fusion_category_id.dart';
import '../enums/thai_fusion_confidence_level.dart';
import '../enums/thai_fusion_source_layer.dart';

/// Lean trace line for Thai Fusion V2 synthesis.
class ThaiFusionEvidence {
  ThaiFusionEvidence({
    required this.sourceLayer,
    required this.sourceRefId,
    required this.categoryId,
    required this.structuralWeight,
    required this.confidence,
  });

  final ThaiFusionSourceLayer sourceLayer;
  final String sourceRefId;
  final ThaiFusionCategoryId categoryId;
  final double structuralWeight;
  final ThaiFusionConfidenceLevel confidence;

  factory ThaiFusionEvidence.fromMap(Map<String, dynamic> map) {
    final layerRaw = map['sourceLayer'] ?? map['source_layer'];
    ThaiFusionSourceLayer? sourceLayer;
    if (layerRaw is ThaiFusionSourceLayer) {
      sourceLayer = layerRaw;
    } else if (layerRaw is String) {
      sourceLayer = parseThaiFusionSourceLayer(layerRaw);
    }
    if (sourceLayer == null) {
      throw FormatException('Invalid sourceLayer: $layerRaw');
    }

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

    return ThaiFusionEvidence(
      sourceLayer: sourceLayer,
      sourceRefId: _requiredString(map['sourceRefId'] ?? map['source_ref_id']),
      categoryId: categoryId,
      structuralWeight: structuralWeight.toDouble(),
      confidence: confidence,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'sourceLayer': sourceLayer.id,
      'sourceRefId': sourceRefId,
      'categoryId': categoryId.id,
      'structuralWeight': structuralWeight,
      'confidence': confidence.id,
    };
  }

  @override
  bool operator ==(Object other) {
    return other is ThaiFusionEvidence &&
        other.sourceLayer == sourceLayer &&
        other.sourceRefId == sourceRefId &&
        other.categoryId == categoryId &&
        other.structuralWeight == structuralWeight &&
        other.confidence == confidence;
  }

  @override
  int get hashCode => Object.hash(
        sourceLayer,
        sourceRefId,
        categoryId,
        structuralWeight,
        confidence,
      );

  static String _requiredString(dynamic raw) {
    if (raw is! String || raw.trim().isEmpty) {
      throw FormatException('Invalid string field: $raw');
    }
    return raw.trim();
  }
}
