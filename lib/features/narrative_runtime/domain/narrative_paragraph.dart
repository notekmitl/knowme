import 'narrative_confidence.dart';
import 'narrative_evidence.dart';
import 'narrative_mode.dart';

/// Single evidence-anchored narrative paragraph from one activated pattern.
class NarrativeParagraph {
  const NarrativeParagraph({
    required this.paragraphId,
    required this.mode,
    required this.text,
    required this.patternId,
    required this.patternLabel,
    required this.activationId,
    required this.activationStrength,
    required this.evidence,
    required this.confidence,
  });

  final String paragraphId;
  final NarrativeMode mode;
  final String text;
  final String patternId;
  final String patternLabel;
  final String activationId;
  final double activationStrength;
  final List<NarrativeEvidence> evidence;
  final NarrativeConfidence confidence;

  Map<String, dynamic> toMap() {
    return {
      'paragraphId': paragraphId,
      'mode': mode.key,
      'text': text,
      'patternId': patternId,
      'patternLabel': patternLabel,
      'activationId': activationId,
      'activationStrength': activationStrength,
      'evidence': evidence.map((row) => row.toMap()).toList(),
      'confidence': confidence.toMap(),
    };
  }

  factory NarrativeParagraph.fromMap(Map<String, dynamic> map) {
    final mode = NarrativeModeLabels.parse(_requiredString(map['mode']));
    if (mode == null) {
      throw FormatException('Unknown narrative mode: ${map['mode']}');
    }

    return NarrativeParagraph(
      paragraphId: _requiredString(map['paragraphId']),
      mode: mode,
      text: _requiredString(map['text']),
      patternId: _requiredString(map['patternId']),
      patternLabel: _requiredString(map['patternLabel']),
      activationId: _requiredString(map['activationId']),
      activationStrength: _requiredDouble(map['activationStrength']),
      evidence: _evidenceList(map['evidence']),
      confidence: NarrativeConfidence.fromMap(
        Map<String, dynamic>.from(map['confidence'] as Map),
      ),
    );
  }
}

List<NarrativeEvidence> _evidenceList(dynamic raw) {
  if (raw is! List) return const [];
  return raw
      .map(
        (item) => NarrativeEvidence.fromMap(
          Map<String, dynamic>.from(item as Map),
        ),
      )
      .toList(growable: false);
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
