import 'human_dimension.dart';

/// Structural human pattern — no narrative prose (HM3).
class HumanPattern {
  const HumanPattern({
    required this.id,
    required this.patternKey,
    required this.label,
    required this.primaryDimension,
    required this.secondaryDimensions,
    required this.fusionFindingIds,
    required this.fusionFindingType,
    required this.supportingMirrorKeys,
    required this.patternStrength,
  });

  final String id;
  final String patternKey;
  final String label;
  final HumanDimensionId primaryDimension;
  final List<HumanDimensionId> secondaryDimensions;
  final List<String> fusionFindingIds;
  final String fusionFindingType;
  final List<String> supportingMirrorKeys;
  final double patternStrength;

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'patternKey': patternKey,
      'label': label,
      'primaryDimension': primaryDimension.key,
      'secondaryDimensions':
          secondaryDimensions.map((item) => item.key).toList(),
      'fusionFindingIds': fusionFindingIds,
      'fusionFindingType': fusionFindingType,
      'supportingMirrorKeys': supportingMirrorKeys,
      'patternStrength': patternStrength,
    };
  }

  factory HumanPattern.fromMap(Map<String, dynamic> map) {
    final primaryRaw = _requiredString(map['primaryDimension']);
    final primary = parseHumanDimensionId(primaryRaw);
    if (primary == null) {
      throw FormatException('Unknown primary dimension: $primaryRaw');
    }

    final secondaryRaw = map['secondaryDimensions'];
    final secondary = <HumanDimensionId>[];
    if (secondaryRaw is List) {
      for (final item in secondaryRaw) {
        if (item is! String) continue;
        final dimension = parseHumanDimensionId(item);
        if (dimension != null) secondary.add(dimension);
      }
    }

    return HumanPattern(
      id: _requiredString(map['id']),
      patternKey: _requiredString(map['patternKey']),
      label: _requiredString(map['label']),
      primaryDimension: primary,
      secondaryDimensions: secondary,
      fusionFindingIds: _stringList(map['fusionFindingIds']),
      fusionFindingType: _requiredString(map['fusionFindingType']),
      supportingMirrorKeys: _stringList(map['supportingMirrorKeys']),
      patternStrength: _requiredDouble(map['patternStrength']),
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
