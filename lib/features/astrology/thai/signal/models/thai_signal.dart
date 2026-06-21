import 'thai_signal_evidence.dart';
import 'thai_signal_fact_type.dart';
import 'thai_signal_provenance.dart';
import 'thai_signal_source.dart';

/// Atomic structural fact derived from Thai Chart V2 foundation output.
///
/// Structural truth only — no category hints, themes, or interpretation.
class ThaiSignal {
  const ThaiSignal({
    required this.signalId,
    required this.source,
    required this.factType,
    required this.evidence,
    required this.confidenceWeight,
    required this.contentKeyRefs,
    required this.provenance,
    this.facts = const {},
  });

  final String signalId;
  final ThaiSignalSource source;
  final ThaiSignalFactType factType;
  final ThaiSignalEvidence evidence;
  final double confidenceWeight;
  final List<String> contentKeyRefs;
  final ThaiSignalProvenance provenance;
  final Map<String, String> facts;
}
