import 'narrative_lineage.dart';

/// Evidence row anchoring a narrative paragraph to pattern snapshot data.
class NarrativeEvidence {
  const NarrativeEvidence({
    required this.evidenceId,
    required this.lineage,
    required this.mirrorKey,
    required this.systemId,
    required this.weight,
    required this.signalIds,
  });

  final String evidenceId;
  final NarrativeLineage lineage;
  final String mirrorKey;
  final String systemId;
  final double weight;
  final List<String> signalIds;

  Map<String, dynamic> toMap() {
    return {
      'evidenceId': evidenceId,
      'lineage': lineage.toMap(),
      'mirrorKey': mirrorKey,
      'systemId': systemId,
      'weight': weight,
      'signalIds': signalIds,
    };
  }

  factory NarrativeEvidence.fromMap(Map<String, dynamic> map) {
    return NarrativeEvidence(
      evidenceId: _requiredString(map['evidenceId']),
      lineage: NarrativeLineage.fromMap(
        Map<String, dynamic>.from(map['lineage'] as Map),
      ),
      mirrorKey: _requiredString(map['mirrorKey']),
      systemId: _requiredString(map['systemId']),
      weight: _requiredDouble(map['weight']),
      signalIds: _stringList(map['signalIds']),
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
