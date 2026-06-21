import '../enums/thai_fusion_category_id.dart';
import '../enums/thai_fusion_confidence_level.dart';

/// Category activation summary for [ThaiFusionSnapshot].
class ThaiFusionCategoryActivation {
  ThaiFusionCategoryActivation({
    required this.categoryId,
    required this.prominence,
    required this.themeCount,
    required this.factCount,
    required this.confidence,
    this.dimensionRefId,
  }) : assert(
          themeCount >= 0,
          'themeCount must be non-negative',
        ),
        assert(
          factCount >= 0,
          'factCount must be non-negative',
        );

  final ThaiFusionCategoryId categoryId;
  final double prominence;
  final int themeCount;
  final int factCount;
  final String? dimensionRefId;
  final ThaiFusionConfidenceLevel confidence;

  factory ThaiFusionCategoryActivation.fromMap(Map<String, dynamic> map) {
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

    final prominence = map['prominence'];
    if (prominence is! num) {
      throw FormatException('Invalid prominence: $prominence');
    }

    final dimensionRefIdRaw = map['dimensionRefId'] ?? map['dimension_ref_id'];
    String? dimensionRefId;
    if (dimensionRefIdRaw is String && dimensionRefIdRaw.trim().isNotEmpty) {
      dimensionRefId = dimensionRefIdRaw.trim();
    }

    return ThaiFusionCategoryActivation(
      categoryId: categoryId,
      prominence: prominence.toDouble(),
      themeCount: _parseInt(map['themeCount'] ?? map['theme_count'], 'themeCount'),
      factCount: _parseInt(map['factCount'] ?? map['fact_count'], 'factCount'),
      dimensionRefId: dimensionRefId,
      confidence: confidence,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'categoryId': categoryId.id,
      'prominence': prominence,
      'themeCount': themeCount,
      'factCount': factCount,
      if (dimensionRefId != null) 'dimensionRefId': dimensionRefId,
      'confidence': confidence.id,
    };
  }

  @override
  bool operator ==(Object other) {
    return other is ThaiFusionCategoryActivation &&
        other.categoryId == categoryId &&
        other.prominence == prominence &&
        other.themeCount == themeCount &&
        other.factCount == factCount &&
        other.dimensionRefId == dimensionRefId &&
        other.confidence == confidence;
  }

  @override
  int get hashCode => Object.hash(
        categoryId,
        prominence,
        themeCount,
        factCount,
        dimensionRefId,
        confidence,
      );

  static int _parseInt(dynamic raw, String field) {
    if (raw is int) return raw;
    if (raw is num) return raw.toInt();
    throw FormatException('Invalid $field: $raw');
  }
}
