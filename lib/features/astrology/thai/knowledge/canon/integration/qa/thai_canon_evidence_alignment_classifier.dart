import '../thai_canon_evidence_attachment.dart';
import '../thai_canon_evidence_type.dart';
import '../thai_canon_ontology_runtime_mapping.dart';
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
    for (final signal in trace.signalsWithoutCanonEvidence) {
      records.add(
        ThaiCanonEvidenceAlignmentRecord(
          fixtureId: fixtureId,
          signalId: signal,
          sectionId: _sectionFromSignal(signal),
          classification:
              ThaiCanonEvidenceAlignmentClassification.unmappedSignal,
          reason: 'Report signal has no deterministic Canon mapping',
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
    if (!attachment.userFacingAllowed || attachment.internalOnly) {
      // Still evaluate structural alignment; user-facing gate is separate.
    }

    return switch (attachment.evidenceType) {
      ThaiCanonEvidenceType.mahabhutPosition =>
        _classifyMahabhut(attachment),
      ThaiCanonEvidenceType.planetSignification =>
        _classifyPlanetSignification(attachment),
      ThaiCanonEvidenceType.lifePeriodStructural =>
        _classifyLifePeriod(attachment),
      ThaiCanonEvidenceType.predictionRule => (
          ThaiCanonEvidenceAlignmentClassification.relatedButWeak,
          'Bulk periodStatus rules attached internally; '
              'do not prove full prediction prose',
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

    final attributeOnly = attachment.evidenceRefs.every(
      (r) => r.object.startsWith('attribute.'),
    );
    if (attributeOnly) {
      return (
        ThaiCanonEvidenceAlignmentClassification.relatedButWeak,
        'Planet attribute evidence only — weak support for broad personality copy',
      );
    }

    return (
      ThaiCanonEvidenceAlignmentClassification.relatedButWeak,
      'Planet/domain evidence related but does not directly prove section prose',
    );
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
