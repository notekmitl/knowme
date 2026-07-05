import '../thai_canon_evidence_attachment.dart';
import '../thai_canon_evidence_signal_scope.dart';
import '../thai_canon_evidence_type.dart';
import '../thai_canon_ontology_runtime_mapping.dart';
import '../thai_canon_period_status_runtime_mapping.dart';
import '../thai_mirror_canon_evidence_bundle.dart';
import 'thai_canon_evidence_alignment_classification.dart';

/// One classified evidence row (attachment or trace-derived skip).
class ThaiCanonEvidenceAlignmentRecord {
  const ThaiCanonEvidenceAlignmentRecord({
    required this.fixtureId,
    required this.signalId,
    this.sectionId,
    required this.classification,
    required this.reason,
    this.evidenceType,
    this.attachmentIndex,
  });

  final String fixtureId;
  final String signalId;
  final String? sectionId;
  final ThaiCanonEvidenceType? evidenceType;
  final ThaiCanonEvidenceAlignmentClassification classification;
  final String reason;
  final int? attachmentIndex;
}

/// Deterministic alignment rules — read-only, no Canon mutation.
abstract final class ThaiCanonEvidenceAlignmentClassifier {
  static List<ThaiCanonEvidenceAlignmentRecord> classifyFixture({
    required String fixtureId,
    required ThaiMirrorCanonEvidenceBundle bundle,
  }) {
    final records = <ThaiCanonEvidenceAlignmentRecord>[];

    for (var i = 0; i < bundle.attachments.length; i++) {
      final attachment = bundle.attachments[i];
      final result = _classifyAttachment(attachment);
      records.add(
        ThaiCanonEvidenceAlignmentRecord(
          fixtureId: fixtureId,
          signalId: attachment.signalId,
          sectionId: attachment.sectionId,
          evidenceType: attachment.evidenceType,
          classification: result.$1,
          reason: result.$2,
          attachmentIndex: i,
        ),
      );
    }

    final trace = bundle.trace;
    if (trace.skippedRemedyEvidenceCount > 0) {
      records.add(
        ThaiCanonEvidenceAlignmentRecord(
          fixtureId: fixtureId,
          signalId: 'trace:skipped_remedy',
          classification:
              ThaiCanonEvidenceAlignmentClassification.skippedRemedy,
          reason:
              '${trace.skippedRemedyEvidenceCount} remedy units in Canon; '
              'intentionally not attached to report',
        ),
      );
    }
    if (trace.skippedTaksaEvidenceCount > 0) {
      records.add(
        ThaiCanonEvidenceAlignmentRecord(
          fixtureId: fixtureId,
          signalId: 'trace:skipped_taksa',
          classification: ThaiCanonEvidenceAlignmentClassification.skippedTaksa,
          reason:
              '${trace.skippedTaksaEvidenceCount} Taksa units in Canon; '
              'runtime lacks deterministic Taksa keys',
        ),
      );
    }
    if (trace.skippedLookupTableEvidenceCount > 0) {
      records.add(
        ThaiCanonEvidenceAlignmentRecord(
          fixtureId: fixtureId,
          signalId: 'trace:skipped_lookup_tables',
          classification: ThaiCanonEvidenceAlignmentClassification.internalOnly,
          reason:
              '${trace.skippedLookupTableEvidenceCount} lookup-table units; '
              'reference-only — not attached to broad report copy',
        ),
      );
    }
    for (final note in trace.skippedPeriodStatusNotes) {
      records.add(
        ThaiCanonEvidenceAlignmentRecord(
          fixtureId: fixtureId,
          signalId: 'trace:period_status:$note',
          classification:
              ThaiCanonEvidenceAlignmentClassification.skippedPeriodStatus,
          reason: note,
        ),
      );
    }
    for (final signal in trace.lifePeriodsWithoutRuntimeStatus) {
      records.add(
        ThaiCanonEvidenceAlignmentRecord(
          fixtureId: fixtureId,
          signalId: 'trace:noStatusInRuntime:$signal',
          classification: ThaiCanonEvidenceAlignmentClassification.internalOnly,
          reason:
              'Life-period anchor has no exact ดวงขึ้น/ดวงตก label in '
              'runtime/report output (not a mapping failure)',
        ),
      );
    }
    if (trace.lifePeriodStatusMetadataBlocker != null) {
      records.add(
        ThaiCanonEvidenceAlignmentRecord(
          fixtureId: fixtureId,
          signalId:
              'trace:lifePeriodStatusMetadataBlocker:'
              '${trace.lifePeriodStatusMetadataBlocker}',
          classification: ThaiCanonEvidenceAlignmentClassification.internalOnly,
          reason:
              'Period-status metadata layer blocked — no deterministic engine '
              'status to expose',
        ),
      );
    }
    if (trace.lifePeriodPositionFeasibilityResult != null) {
      records.add(
        ThaiCanonEvidenceAlignmentRecord(
          fixtureId: fixtureId,
          signalId:
              'trace:lifePeriodPositionFeasibility:'
              '${trace.lifePeriodPositionFeasibilityResult}',
          classification: ThaiCanonEvidenceAlignmentClassification.internalOnly,
          reason:
              'Life-period Mahabhut position metadata feasibility audit '
              '(internal only)',
        ),
      );
    }
    if (trace.lifePeriodPositionMetadataBlocker != null) {
      records.add(
        ThaiCanonEvidenceAlignmentRecord(
          fixtureId: fixtureId,
          signalId:
              'trace:lifePeriodPositionMetadataBlocker:'
              '${trace.lifePeriodPositionMetadataBlocker}',
          classification: ThaiCanonEvidenceAlignmentClassification.internalOnly,
          reason:
              'Per-period Mahabhut position metadata blocked — no deterministic '
              'archetype/period context to map Canon placements',
        ),
      );
    }
    if (trace.lifePeriodRiseFallFeasibilityResult != null) {
      records.add(
        ThaiCanonEvidenceAlignmentRecord(
          fixtureId: fixtureId,
          signalId:
              'trace:lifePeriodRiseFallFeasibility:'
              '${trace.lifePeriodRiseFallFeasibilityResult}',
          classification: ThaiCanonEvidenceAlignmentClassification.internalOnly,
          reason:
              'Engine rise/fall metadata feasibility audit (internal only)',
        ),
      );
    }
    for (final signal in trace.lifePeriodsWithRuntimeStatus) {
      records.add(
        ThaiCanonEvidenceAlignmentRecord(
          fixtureId: fixtureId,
          signalId: 'trace:runtimeStatus:$signal',
          classification: ThaiCanonEvidenceAlignmentClassification.internalOnly,
          reason:
              'Period status from engine/runtime rise/fall metadata (internal only)',
        ),
      );
    }
    for (final signal in trace.lifePeriodsWithCanonDerivedStatus) {
      records.add(
        ThaiCanonEvidenceAlignmentRecord(
          fixtureId: fixtureId,
          signalId: 'trace:canonDerivedStatus:$signal',
          classification: ThaiCanonEvidenceAlignmentClassification.internalOnly,
          reason:
              'Period status derived from exact Canon life_period context marker',
        ),
      );
    }
    for (final signal in trace.lifePeriodsWithoutCanonStatusMarker) {
      records.add(
        ThaiCanonEvidenceAlignmentRecord(
          fixtureId: fixtureId,
          signalId: 'trace:noCanonStatusMarker:$signal',
          classification: ThaiCanonEvidenceAlignmentClassification.internalOnly,
          reason:
              'Life-period structural evidence present but no unambiguous '
              'Canon [ดวงขึ้น]/[ดวงตก] marker',
        ),
      );
    }
    for (final signal in trace.outOfCanonScopeSignals) {
      final contentKey = _contentKeyFromSignal(signal);
      records.add(
        ThaiCanonEvidenceAlignmentRecord(
          fixtureId: fixtureId,
          signalId: signal,
          sectionId: _sectionFromSignal(signal),
          classification:
              ThaiCanonEvidenceAlignmentClassification.outOfCanonScope,
          reason: contentKey == null
              ? 'Signal outside frozen Mahabhut Canon scope'
              : ThaiCanonEvidenceSignalScope.outOfCanonScopeReason(contentKey),
        ),
      );
    }
    for (final signal in trace.inCanonScopeUnmappedSignals) {
      records.add(
        ThaiCanonEvidenceAlignmentRecord(
          fixtureId: fixtureId,
          signalId: signal,
          sectionId: _sectionFromSignal(signal),
          classification:
              ThaiCanonEvidenceAlignmentClassification.unmappedSignal,
          reason: 'In-scope signal with no deterministic Canon attachment',
        ),
      );
    }
    for (final candidate in trace.traceOnlyEvidenceCandidates) {
      records.add(
        ThaiCanonEvidenceAlignmentRecord(
          fixtureId: fixtureId,
          signalId: candidate,
          classification: candidate.startsWith('prediction:')
              ? ThaiCanonEvidenceAlignmentClassification.relatedButWeak
              : ThaiCanonEvidenceAlignmentClassification.relatedButWeak,
          reason: candidate.startsWith('prediction:')
              ? 'Bulk periodStatus rules trace-only; '
                  'do not prove full prediction prose'
              : 'Planet attribute evidence trace-only; '
                  'does not directly support section prose',
        ),
      );
    }

    records.sort((a, b) => a.signalId.compareTo(b.signalId));
    return records;
  }

  static (ThaiCanonEvidenceAlignmentClassification, String)
      _classifyAttachment(
    ThaiCanonEvidenceAttachment attachment,
  ) {
    return switch (attachment.evidenceType) {
      ThaiCanonEvidenceType.mahabhutPosition =>
        _classifyMahabhut(attachment),
      ThaiCanonEvidenceType.planetSignification =>
        _classifyPlanetSignification(attachment),
      ThaiCanonEvidenceType.lifePeriodStructural =>
        _classifyLifePeriod(attachment),
      ThaiCanonEvidenceType.periodStatusStructural =>
        _classifyPeriodStatus(attachment),
      ThaiCanonEvidenceType.predictionRule => (
          ThaiCanonEvidenceAlignmentClassification.relatedButWeak,
          'Prediction rule attachment should be trace-only',
        ),
      ThaiCanonEvidenceType.taksa => (
          ThaiCanonEvidenceAlignmentClassification.skippedTaksa,
          'Taksa evidence not wired to report signals',
        ),
      ThaiCanonEvidenceType.remedyInternal => (
          ThaiCanonEvidenceAlignmentClassification.skippedRemedy,
          'Remedy evidence must remain trace-only',
        ),
    };
  }

  static (ThaiCanonEvidenceAlignmentClassification, String) _classifyMahabhut(
    ThaiCanonEvidenceAttachment attachment,
  ) {
    final runtimeKey = _runtimeKeyFromSignal(attachment.signalId);
    final expectedCanon = runtimeKey == null
        ? null
        : ThaiCanonOntologyRuntimeMapping.canonMahabhutForContentKey(
            runtimeKey,
          );

    if (expectedCanon == null || attachment.evidenceRefs.isEmpty) {
      return (
        ThaiCanonEvidenceAlignmentClassification.relatedButWeak,
        'Mahabhut refs present but runtime key mapping incomplete',
      );
    }

    final allMatchObject = attachment.evidenceRefs.every(
      (r) => r.object == expectedCanon || r.subject == expectedCanon,
    );
    if (allMatchObject) {
      final sectionNote = attachment.sectionId == null
          ? 'profile anchor'
          : 'section ${attachment.sectionId} still uses legacy hardcoded copy';
      return (
        ThaiCanonEvidenceAlignmentClassification.strongMatch,
        'Canon object $expectedCanon directly matches runtime key '
            '$runtimeKey ($sectionNote)',
      );
    }

    return (
      ThaiCanonEvidenceAlignmentClassification.relatedButWeak,
      'Mahabhut evidence related by domain but object mismatch vs $expectedCanon',
    );
  }

  static (ThaiCanonEvidenceAlignmentClassification, String)
      _classifyPlanetSignification(
    ThaiCanonEvidenceAttachment attachment,
  ) {
    final runtimeKey = _runtimeKeyFromSignal(attachment.signalId);
    final planetId = runtimeKey == null
        ? null
        : _planetIdFromLagnaLordKey(runtimeKey);

    if (planetId == null || attachment.evidenceRefs.isEmpty) {
      return (
        ThaiCanonEvidenceAlignmentClassification.unmappedSignal,
        'Lagna lord signal lacks planet id for Canon lookup',
      );
    }

    final subjectMatches = attachment.evidenceRefs.every(
      (r) => r.subject == planetId,
    );
    if (!subjectMatches) {
      return (
        ThaiCanonEvidenceAlignmentClassification.relatedButWeak,
        'Planet refs subject mismatch vs $planetId',
      );
    }

    final hasOwns = attachment.evidenceRefs.any((r) => r.relation == 'owns');
    if (hasOwns) {
      return (
        ThaiCanonEvidenceAlignmentClassification.strongMatch,
        '$planetId owns-domain evidence matches lagna lord signal',
      );
    }

    return (
      ThaiCanonEvidenceAlignmentClassification.relatedButWeak,
      'Planet/domain evidence related but does not directly prove section prose',
    );
  }

  static (ThaiCanonEvidenceAlignmentClassification, String) _classifyPeriodStatus(
    ThaiCanonEvidenceAttachment attachment,
  ) {
    if (attachment.signalId.contains(':periodStatus:canonDerived:')) {
      final canonId = _canonDerivedPeriodStatusIdFromSignal(attachment.signalId);
      if (canonId == null) {
        return (
          ThaiCanonEvidenceAlignmentClassification.relatedButWeak,
          'Canon-derived period status signal id not parseable',
        );
      }
      final matches = attachment.evidenceRefs.where(
        (r) => r.subject == canonId || r.object == canonId,
      );
      if (matches.isNotEmpty) {
        return (
          ThaiCanonEvidenceAlignmentClassification.internalOnly,
          'Canon-derived period status from exact life_period context marker '
          '($canonId) — internal annotation only',
        );
      }
      return (
        ThaiCanonEvidenceAlignmentClassification.relatedButWeak,
        'Canon-derived period status evidence partial vs $canonId',
      );
    }

    final label = _periodStatusLabelFromSignal(attachment.signalId);
    if (label == null) {
      return (
        ThaiCanonEvidenceAlignmentClassification.relatedButWeak,
        'Period status signal id not parseable',
      );
    }

    final canonId =
        ThaiCanonPeriodStatusRuntimeMapping.canonIdForRuntimeLabel(label);
    if (canonId == null) {
      return (
        ThaiCanonEvidenceAlignmentClassification.unmappedSignal,
        'Period status label not in Canon mapping table',
      );
    }

    final matches = attachment.evidenceRefs.where(
      (r) => r.subject == canonId || r.object == canonId,
    );
    if (matches.isNotEmpty &&
        matches.length == attachment.evidenceRefs.length) {
      return (
        ThaiCanonEvidenceAlignmentClassification.strongMatch,
        '$canonId evidence matches runtime label $label on life-period signal',
      );
    }

    return (
      ThaiCanonEvidenceAlignmentClassification.relatedButWeak,
      'Period status evidence partial vs $canonId',
    );
  }

  static String? _periodStatusLabelFromSignal(String signalId) {
    if (!signalId.contains(':periodStatus:')) return null;
    if (signalId.contains(':periodStatus:canonDerived:')) return null;
    return signalId.split(':periodStatus:').last;
  }

  static String? _canonDerivedPeriodStatusIdFromSignal(String signalId) {
    const prefix = ':periodStatus:canonDerived:';
    final index = signalId.indexOf(prefix);
    if (index < 0) return null;
    return signalId.substring(index + prefix.length);
  }

  static (ThaiCanonEvidenceAlignmentClassification, String) _classifyLifePeriod(
    ThaiCanonEvidenceAttachment attachment,
  ) {
    final planetId = _planetIdFromLifePeriodSignal(attachment.signalId);
    if (planetId == null) {
      return (
        ThaiCanonEvidenceAlignmentClassification.relatedButWeak,
        'Life-period signal id not parseable',
      );
    }

    final structural = attachment.evidenceRefs.where(
      (r) =>
          r.subject == planetId &&
          r.contextType == 'life_period' &&
          r.object.startsWith('mahabhutPosition.'),
    );
    if (structural.isNotEmpty &&
        structural.length == attachment.evidenceRefs.length) {
      return (
        ThaiCanonEvidenceAlignmentClassification.strongMatch,
        '$planetId located_in life_period with Mahabhut placement refs',
      );
    }

    return (
      ThaiCanonEvidenceAlignmentClassification.relatedButWeak,
      'Life-period placement evidence partial or mixed with non-structural refs',
    );
  }

  static String? _runtimeKeyFromSignal(String signalId) {
    if (signalId.startsWith('profile:mahabhuta_position:')) {
      return signalId.substring('profile:mahabhuta_position:'.length);
    }
    final colon = signalId.indexOf(':');
    if (colon < 0 || colon >= signalId.length - 1) return null;
    return signalId.substring(colon + 1);
  }

  static String? _contentKeyFromSignal(String signalId) {
    if (signalId.startsWith('profile:mahabhuta_position:')) {
      return signalId.substring('profile:mahabhuta_position:'.length);
    }
    final colon = signalId.indexOf(':');
    if (colon < 0 || colon >= signalId.length - 1) return null;
    return signalId.substring(colon + 1);
  }

  static String? _planetIdFromLagnaLordKey(String contentKey) {
    const prefix = 'lagna_lord_';
    if (!contentKey.startsWith(prefix)) return null;
    final planet = contentKey.substring(prefix.length).trim();
    if (planet.isEmpty) return null;
    return 'planet.$planet';
  }

  static String? _planetIdFromLifePeriodSignal(String signalId) {
    if (!signalId.startsWith('life_period:')) return null;
    final parts = signalId.split(':');
    if (parts.length < 3) return null;
    return parts[2];
  }

  static String? _sectionFromSignal(String signalId) {
    final colon = signalId.indexOf(':');
    if (colon <= 0) return null;
    return signalId.substring(0, colon);
  }
}
