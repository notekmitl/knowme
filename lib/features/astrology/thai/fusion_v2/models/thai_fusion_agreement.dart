import '../enums/thai_fusion_category_id.dart';
import '../enums/thai_fusion_confidence_level.dart';

/// Cross-layer agreement for [ThaiFusionSnapshot].
class ThaiFusionAgreement {
  ThaiFusionAgreement({
    required this.agreementId,
    required this.categoryId,
    required this.themeIds,
    required this.factIds,
    required this.dimensionIds,
    required this.strength,
    required this.confidence,
  });

  final String agreementId;
  final ThaiFusionCategoryId categoryId;
  final List<String> themeIds;
  final List<String> factIds;
  final List<String> dimensionIds;
  final double strength;
  final ThaiFusionConfidenceLevel confidence;

  factory ThaiFusionAgreement.fromMap(Map<String, dynamic> map) {
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

    final strength = map['strength'];
    if (strength is! num) {
      throw FormatException('Invalid strength: $strength');
    }

    return ThaiFusionAgreement(
      agreementId: _requiredString(map['agreementId'] ?? map['agreement_id']),
      categoryId: categoryId,
      themeIds: _stringList(map['themeIds'] ?? map['theme_ids']),
      factIds: _stringList(map['factIds'] ?? map['fact_ids']),
      dimensionIds: _stringList(map['dimensionIds'] ?? map['dimension_ids']),
      strength: strength.toDouble(),
      confidence: confidence,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'agreementId': agreementId,
      'categoryId': categoryId.id,
      'themeIds': themeIds,
      'factIds': factIds,
      'dimensionIds': dimensionIds,
      'strength': strength,
      'confidence': confidence.id,
    };
  }

  @override
  bool operator ==(Object other) {
    return other is ThaiFusionAgreement &&
        other.agreementId == agreementId &&
        other.categoryId == categoryId &&
        other.strength == strength &&
        other.confidence == confidence &&
        _listEquals(other.themeIds, themeIds) &&
        _listEquals(other.factIds, factIds) &&
        _listEquals(other.dimensionIds, dimensionIds);
  }

  @override
  int get hashCode => Object.hash(
        agreementId,
        categoryId,
        strength,
        confidence,
        Object.hashAll(themeIds),
        Object.hashAll(factIds),
        Object.hashAll(dimensionIds),
      );

  static String _requiredString(dynamic raw) {
    if (raw is! String || raw.trim().isEmpty) {
      throw FormatException('Invalid string field: $raw');
    }
    return raw.trim();
  }

  static List<String> _stringList(dynamic raw) {
    if (raw is! List) return const [];
    return raw.whereType<String>().map((item) => item.trim()).toList();
  }

  static bool _listEquals(List<String> a, List<String> b) {
    if (a.length != b.length) return false;
    for (var i = 0; i < a.length; i++) {
      if (a[i] != b[i]) return false;
    }
    return true;
  }
}
