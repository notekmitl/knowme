/// Human model coverage across canonical dimensions.
class HumanCoverage {
  const HumanCoverage({
    required this.dimensionCount,
    required this.activatedDimensionCount,
    required this.patternCount,
    required this.weightedCoverage,
    required this.activatedDimensionKeys,
  });

  final int dimensionCount;
  final int activatedDimensionCount;
  final int patternCount;
  final double weightedCoverage;
  final List<String> activatedDimensionKeys;

  Map<String, dynamic> toMap() {
    return {
      'dimensionCount': dimensionCount,
      'activatedDimensionCount': activatedDimensionCount,
      'patternCount': patternCount,
      'weightedCoverage': weightedCoverage,
      'activatedDimensionKeys': activatedDimensionKeys,
    };
  }

  factory HumanCoverage.fromMap(Map<String, dynamic> map) {
    return HumanCoverage(
      dimensionCount: _requiredInt(map['dimensionCount']),
      activatedDimensionCount: _requiredInt(map['activatedDimensionCount']),
      patternCount: _requiredInt(map['patternCount']),
      weightedCoverage: _requiredDouble(map['weightedCoverage']),
      activatedDimensionKeys: _stringList(map['activatedDimensionKeys']),
    );
  }
}

List<String> _stringList(dynamic raw) {
  if (raw is! List) return const [];
  return raw.whereType<String>().toList(growable: false);
}

int _requiredInt(dynamic raw) {
  if (raw is int) return raw;
  if (raw is num) return raw.toInt();
  throw FormatException('Invalid int: $raw');
}

double _requiredDouble(dynamic raw) {
  if (raw is! num) throw FormatException('Invalid double: $raw');
  return raw.toDouble();
}
