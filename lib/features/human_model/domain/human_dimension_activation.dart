import 'human_dimension.dart';

/// Activated canonical dimension within a human profile (HM1/HM2).
class HumanDimension {
  const HumanDimension({
    required this.dimensionId,
    required this.dimensionKey,
    required this.activation,
    required this.patternIds,
  });

  final HumanDimensionId dimensionId;
  final String dimensionKey;
  final double activation;
  final List<String> patternIds;

  Map<String, dynamic> toMap() {
    return {
      'dimensionId': dimensionId.key,
      'dimensionKey': dimensionKey,
      'activation': activation,
      'patternIds': patternIds,
    };
  }

  factory HumanDimension.fromMap(Map<String, dynamic> map) {
    final dimensionRaw = _requiredString(map['dimensionId']);
    final dimensionId = parseHumanDimensionId(dimensionRaw);
    if (dimensionId == null) {
      throw FormatException('Unknown human dimension: $dimensionRaw');
    }

    return HumanDimension(
      dimensionId: dimensionId,
      dimensionKey: _requiredString(map['dimensionKey']),
      activation: _requiredDouble(map['activation']),
      patternIds: _stringList(map['patternIds']),
    );
  }
}

List<String> _stringList(dynamic raw) {
  if (raw is! List) return const [];
  return raw.whereType<String>().toList(growable: false);
}

String _requiredString(dynamic raw) {
  if (raw is! String || raw.trim().isEmpty) {
    throw FormatException('Invalid string field: $raw');
  }
  return raw.trim();
}

double _requiredDouble(dynamic raw) {
  if (raw is! num) throw FormatException('Invalid double: $raw');
  return raw.toDouble();
}
