/// Coverage summary for [ThaiFusionSnapshot].
class ThaiFusionCoverage {
  const ThaiFusionCoverage({
    required this.mappedCategoryCount,
    required this.totalCategoryCount,
    required this.mirrorDimensionCount,
    required this.interpretationFactCount,
    required this.hasSparseDimensions,
  }) : assert(
          mappedCategoryCount >= 0,
          'mappedCategoryCount must be non-negative',
        ),
        assert(
          totalCategoryCount >= 0,
          'totalCategoryCount must be non-negative',
        ),
        assert(
          mirrorDimensionCount >= 0,
          'mirrorDimensionCount must be non-negative',
        ),
        assert(
          interpretationFactCount >= 0,
          'interpretationFactCount must be non-negative',
        );

  final int mappedCategoryCount;
  final int totalCategoryCount;
  final int mirrorDimensionCount;
  final int interpretationFactCount;
  final bool hasSparseDimensions;

  factory ThaiFusionCoverage.fromMap(Map<String, dynamic> map) {
    return ThaiFusionCoverage(
      mappedCategoryCount: _parseInt(
        map['mappedCategoryCount'] ?? map['mapped_category_count'],
        'mappedCategoryCount',
      ),
      totalCategoryCount: _parseInt(
        map['totalCategoryCount'] ?? map['total_category_count'],
        'totalCategoryCount',
      ),
      mirrorDimensionCount: _parseInt(
        map['mirrorDimensionCount'] ?? map['mirror_dimension_count'],
        'mirrorDimensionCount',
      ),
      interpretationFactCount: _parseInt(
        map['interpretationFactCount'] ?? map['interpretation_fact_count'],
        'interpretationFactCount',
      ),
      hasSparseDimensions:
          map['hasSparseDimensions'] == true || map['has_sparse_dimensions'] == true,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'mappedCategoryCount': mappedCategoryCount,
      'totalCategoryCount': totalCategoryCount,
      'mirrorDimensionCount': mirrorDimensionCount,
      'interpretationFactCount': interpretationFactCount,
      'hasSparseDimensions': hasSparseDimensions,
    };
  }

  @override
  bool operator ==(Object other) {
    return other is ThaiFusionCoverage &&
        other.mappedCategoryCount == mappedCategoryCount &&
        other.totalCategoryCount == totalCategoryCount &&
        other.mirrorDimensionCount == mirrorDimensionCount &&
        other.interpretationFactCount == interpretationFactCount &&
        other.hasSparseDimensions == hasSparseDimensions;
  }

  @override
  int get hashCode => Object.hash(
        mappedCategoryCount,
        totalCategoryCount,
        mirrorDimensionCount,
        interpretationFactCount,
        hasSparseDimensions,
      );

  static int _parseInt(dynamic raw, String field) {
    if (raw is int) return raw;
    if (raw is num) return raw.toInt();
    throw FormatException('Invalid $field: $raw');
  }
}
