import 'narrative_confidence.dart';
import 'narrative_mode.dart';
import 'narrative_paragraph.dart';

/// Narrative section for one mode — ordered paragraphs from activated patterns.
class NarrativeSection {
  const NarrativeSection({
    required this.mode,
    required this.title,
    required this.paragraphs,
    required this.confidence,
  });

  final NarrativeMode mode;
  final String title;
  final List<NarrativeParagraph> paragraphs;
  final NarrativeConfidence confidence;

  bool get isEmpty => paragraphs.isEmpty;

  Map<String, dynamic> toMap() {
    return {
      'mode': mode.key,
      'title': title,
      'paragraphs': paragraphs.map((item) => item.toMap()).toList(),
      'confidence': confidence.toMap(),
    };
  }

  factory NarrativeSection.fromMap(Map<String, dynamic> map) {
    final mode = NarrativeModeLabels.parse(_requiredString(map['mode']));
    if (mode == null) {
      throw FormatException('Unknown narrative mode: ${map['mode']}');
    }

    return NarrativeSection(
      mode: mode,
      title: _requiredString(map['title']),
      paragraphs: _paragraphList(map['paragraphs']),
      confidence: NarrativeConfidence.fromMap(
        Map<String, dynamic>.from(map['confidence'] as Map),
      ),
    );
  }
}

List<NarrativeParagraph> _paragraphList(dynamic raw) {
  if (raw is! List) return const [];
  return raw
      .map(
        (item) => NarrativeParagraph.fromMap(
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
