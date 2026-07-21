/// Trace metadata for Thai Beta narrative composition (test/debug only).
library;

import 'thai_beta_narrative_domain.dart';

class ThaiBetaNarrativeTraceEntry {
  const ThaiBetaNarrativeTraceEntry({
    required this.sectionId,
    required this.field,
    required this.primaryTrait,
    this.secondaryTrait,
    this.domain,
    this.relationship,
    this.lifePeriod,
    this.blockId,
    this.minimumConfidence,
    this.requiresBirthTime,
    this.sourceSignalIds = const [],
  });

  final String sectionId;
  final String field;
  final String primaryTrait;
  final String? secondaryTrait;
  final ThaiBetaLifeDomain? domain;
  final String? relationship;
  final String? lifePeriod;
  final String? blockId;
  final double? minimumConfidence;
  final bool? requiresBirthTime;
  final List<String> sourceSignalIds;
}

class ThaiBetaNarrativeTrace {
  const ThaiBetaNarrativeTrace({this.entries = const []});

  final List<ThaiBetaNarrativeTraceEntry> entries;

  ThaiBetaNarrativeTrace add(ThaiBetaNarrativeTraceEntry entry) {
    return ThaiBetaNarrativeTrace(entries: [...entries, entry]);
  }
}
