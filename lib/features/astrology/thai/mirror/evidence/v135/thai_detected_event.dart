import 'thai_evidence_item.dart';

/// V1.3.5 — a life-event signal emitted by a deterministic rule.
///
/// Every event must cite ≥1 real [evidenceIds]. No filler quota.
class ThaiDetectedEvent {
  const ThaiDetectedEvent({
    required this.eventKey,
    required this.evidenceIds,
    required this.topic,
    required this.summaryFact,
    required this.tense,
    this.conflictGroupId,
    this.weight = 0,
  });

  /// Stable dedupe key (normalized).
  final String eventKey;

  final List<String> evidenceIds;
  final ThaiEvidenceTopic topic;

  /// Structured fact line for composers (not final Thai prose).
  final String summaryFact;

  final ThaiEventTense tense;
  final String? conflictGroupId;
  final int weight;
}

enum ThaiEventTense { pastLikely, present, futureLikely }
