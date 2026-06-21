/// Snapshot coverage for activated registry patterns.
class PatternSnapshotCoverage {
  const PatternSnapshotCoverage({
    required this.registryPatternCount,
    required this.activatedPatternCount,
    required this.activatedDimensionCount,
    required this.weightedCoverage,
    required this.activatedDimensionKeys,
  });

  final int registryPatternCount;
  final int activatedPatternCount;
  final int activatedDimensionCount;
  final double weightedCoverage;
  final List<String> activatedDimensionKeys;

  Map<String, dynamic> toMap() {
    return {
      'registryPatternCount': registryPatternCount,
      'activatedPatternCount': activatedPatternCount,
      'activatedDimensionCount': activatedDimensionCount,
      'weightedCoverage': weightedCoverage,
      'activatedDimensionKeys': activatedDimensionKeys,
    };
  }

  factory PatternSnapshotCoverage.fromMap(Map<String, dynamic> map) {
    return PatternSnapshotCoverage(
      registryPatternCount: _requiredInt(map['registryPatternCount']),
      activatedPatternCount: _requiredInt(map['activatedPatternCount']),
      activatedDimensionCount: _requiredInt(map['activatedDimensionCount']),
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
