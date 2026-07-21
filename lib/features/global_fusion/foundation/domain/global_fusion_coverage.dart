/// Aggregated mirror coverage for global fusion output.
class GlobalFusionCoverage {
  const GlobalFusionCoverage({
    required this.mirrorCount,
    required this.mirrorRoleIds,
    required this.coveredDimensions,
    required this.totalSignalCount,
    required this.weightedCoverage,
  });

  final int mirrorCount;
  final List<String> mirrorRoleIds;
  final List<String> coveredDimensions;
  final int totalSignalCount;
  final double weightedCoverage;

  Map<String, dynamic> toMap() {
    return {
      'mirrorCount': mirrorCount,
      'mirrorRoleIds': mirrorRoleIds,
      'coveredDimensions': coveredDimensions,
      'totalSignalCount': totalSignalCount,
      'weightedCoverage': weightedCoverage,
    };
  }

  factory GlobalFusionCoverage.fromMap(Map<String, dynamic> map) {
    final weighted = map['weightedCoverage'];
    if (weighted is! num) {
      throw FormatException('Invalid weightedCoverage: $weighted');
    }

    return GlobalFusionCoverage(
      mirrorCount: _requiredInt(map['mirrorCount']),
      mirrorRoleIds: _stringList(map['mirrorRoleIds']),
      coveredDimensions: _stringList(map['coveredDimensions']),
      totalSignalCount: _requiredInt(map['totalSignalCount']),
      weightedCoverage: weighted.toDouble(),
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

String _requiredString(dynamic raw) {
  if (raw is! String || raw.trim().isEmpty) {
    throw FormatException('Invalid string field: $raw');
  }
  return raw.trim();
}
