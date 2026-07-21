import '../enums/thai_fusion_category_id.dart';
import '../enums/thai_fusion_confidence_level.dart';

/// Cross-layer tension for [ThaiFusionSnapshot].
class ThaiFusionTension {
  ThaiFusionTension({
    required this.tensionId,
    required this.categoryId,
    required this.leftRefId,
    required this.rightRefId,
    required this.tensionStrength,
    required this.confidence,
  });

  final String tensionId;
  final ThaiFusionCategoryId categoryId;
  final String leftRefId;
  final String rightRefId;
  final double tensionStrength;
  final ThaiFusionConfidenceLevel confidence;

  factory ThaiFusionTension.fromMap(Map<String, dynamic> map) {
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

    final tensionStrength = map['tensionStrength'] ?? map['tension_strength'];
    if (tensionStrength is! num) {
      throw FormatException('Invalid tensionStrength: $tensionStrength');
    }

    return ThaiFusionTension(
      tensionId: _requiredString(map['tensionId'] ?? map['tension_id']),
      categoryId: categoryId,
      leftRefId: _requiredString(map['leftRefId'] ?? map['left_ref_id']),
      rightRefId: _requiredString(map['rightRefId'] ?? map['right_ref_id']),
      tensionStrength: tensionStrength.toDouble(),
      confidence: confidence,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'tensionId': tensionId,
      'categoryId': categoryId.id,
      'leftRefId': leftRefId,
      'rightRefId': rightRefId,
      'tensionStrength': tensionStrength,
      'confidence': confidence.id,
    };
  }

  @override
  bool operator ==(Object other) {
    return other is ThaiFusionTension &&
        other.tensionId == tensionId &&
        other.categoryId == categoryId &&
        other.leftRefId == leftRefId &&
        other.rightRefId == rightRefId &&
        other.tensionStrength == tensionStrength &&
        other.confidence == confidence;
  }

  @override
  int get hashCode => Object.hash(
        tensionId,
        categoryId,
        leftRefId,
        rightRefId,
        tensionStrength,
        confidence,
      );

  static String _requiredString(dynamic raw) {
    if (raw is! String || raw.trim().isEmpty) {
      throw FormatException('Invalid string field: $raw');
    }
    return raw.trim();
  }
}
