import 'package:knowme/features/human_model/domain/human_dimension.dart';

import 'pattern_confidence.dart';

/// Activated registry pattern — structural output, not narrative (HP4).
class PatternActivation {
  const PatternActivation({
    required this.activationId,
    required this.patternId,
    required this.label,
    required this.patternFamilyId,
    required this.dimension,
    required this.activationStrength,
    required this.sourceHumanPatternId,
    required this.sourceHumanPatternKey,
    required this.confidence,
  });

  final String activationId;
  final String patternId;
  final String label;
  final String patternFamilyId;
  final HumanDimensionId dimension;
  final double activationStrength;
  final String sourceHumanPatternId;
  final String sourceHumanPatternKey;
  final PatternConfidence confidence;

  Map<String, dynamic> toMap() {
    return {
      'activationId': activationId,
      'patternId': patternId,
      'label': label,
      'patternFamilyId': patternFamilyId,
      'dimension': dimension.key,
      'activationStrength': activationStrength,
      'sourceHumanPatternId': sourceHumanPatternId,
      'sourceHumanPatternKey': sourceHumanPatternKey,
      'confidence': confidence.toMap(),
    };
  }

  factory PatternActivation.fromMap(Map<String, dynamic> map) {
    final dimensionRaw = _requiredString(map['dimension']);
    final dimension = parseHumanDimensionId(dimensionRaw);
    if (dimension == null) {
      throw FormatException('Unknown dimension: $dimensionRaw');
    }

    return PatternActivation(
      activationId: _requiredString(map['activationId']),
      patternId: _requiredString(map['patternId']),
      label: _requiredString(map['label']),
      patternFamilyId: _requiredString(map['patternFamilyId']),
      dimension: dimension,
      activationStrength: _requiredDouble(map['activationStrength']),
      sourceHumanPatternId: _requiredString(map['sourceHumanPatternId']),
      sourceHumanPatternKey: _requiredString(map['sourceHumanPatternKey']),
      confidence: PatternConfidence.fromMap(
        Map<String, dynamic>.from(map['confidence'] as Map),
      ),
    );
  }
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
