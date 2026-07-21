import 'human_dimension_activation.dart';
import 'human_pattern.dart';

/// Aggregated human profile across canonical dimensions (HM1).
class HumanProfile {
  const HumanProfile({
    required this.dimensions,
    required this.patterns,
    required this.activePatternKeys,
  });

  final List<HumanDimension> dimensions;
  final List<HumanPattern> patterns;
  final List<String> activePatternKeys;

  int get patternCount => patterns.length;

  Map<String, dynamic> toMap() {
    return {
      'dimensions': dimensions.map((item) => item.toMap()).toList(),
      'patterns': patterns.map((item) => item.toMap()).toList(),
      'activePatternKeys': activePatternKeys,
    };
  }

  factory HumanProfile.fromMap(Map<String, dynamic> map) {
    return HumanProfile(
      dimensions: _dimensions(map['dimensions']),
      patterns: _patterns(map['patterns']),
      activePatternKeys: _stringList(map['activePatternKeys']),
    );
  }
}

List<HumanDimension> _dimensions(dynamic raw) {
  if (raw is! List) return const [];
  return raw
      .map(
        (item) => HumanDimension.fromMap(
          Map<String, dynamic>.from(item as Map),
        ),
      )
      .toList(growable: false);
}

List<HumanPattern> _patterns(dynamic raw) {
  if (raw is! List) return const [];
  return raw
      .map(
        (item) => HumanPattern.fromMap(
          Map<String, dynamic>.from(item as Map),
        ),
      )
      .toList(growable: false);
}

List<String> _stringList(dynamic raw) {
  if (raw is! List) return const [];
  return raw.whereType<String>().toList(growable: false);
}
