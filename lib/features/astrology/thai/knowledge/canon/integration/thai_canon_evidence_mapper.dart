import 'package:knowme/features/astrology/thai/knowledge/canon/atomic/atomic_knowledge_unit.dart';

import 'thai_canon_evidence_index.dart';
import 'thai_canon_evidence_ref.dart';
import 'thai_canon_evidence_safety.dart';
import 'thai_canon_ontology_runtime_mapping.dart';

/// Maps runtime identifiers and Canon ontology ids to [ThaiCanonEvidenceRef]
/// records. Read-only and deterministic.
class ThaiCanonEvidenceMapper {
  const ThaiCanonEvidenceMapper(this.index);

  final ThaiCanonEvidenceIndex index;

  List<ThaiCanonEvidenceRef> refsForUnits(Iterable<AtomicKnowledgeUnit> units) {
    final refs = units
        .map(
          (u) => ThaiCanonEvidenceRef.fromUnit(
            u,
            safety: ThaiCanonEvidenceRef.safetyForDomain(u.domain),
          ),
        )
        .toList(growable: false);
    refs.sort((a, b) => a.unitId.compareTo(b.unitId));
    return refs;
  }

  List<ThaiCanonEvidenceRef> evidenceForSubject(String subject) =>
      refsForUnits(index.bySubject(subject));

  List<ThaiCanonEvidenceRef> evidenceForObject(String object) =>
      refsForUnits(index.byObject(object));

  List<ThaiCanonEvidenceRef> evidenceForSubjectAndObject({
    required String subject,
    required String object,
  }) {
    final objectMatches = index.byObject(object).where((u) => u.subject == subject);
    return refsForUnits(objectMatches);
  }

  List<ThaiCanonEvidenceRef> evidenceForPlanet(String canonPlanetId) =>
      refsForUnits(index.byPlanet(canonPlanetId));

  List<ThaiCanonEvidenceRef> evidenceForMahabhutPosition(
    String canonPositionId,
  ) =>
      refsForUnits(index.byMahabhutPosition(canonPositionId));

  List<ThaiCanonEvidenceRef> evidenceForRuntimeContentKey(String contentKey) {
    final canonId =
        ThaiCanonOntologyRuntimeMapping.canonMahabhutForContentKey(contentKey);
    if (canonId == null) return const [];
    return evidenceForMahabhutPosition(canonId);
  }

  List<ThaiCanonEvidenceRef> evidenceForTaksaRole(String canonRoleId) =>
      refsForUnits(index.byTaksaRole(canonRoleId));

  List<ThaiCanonEvidenceRef> evidenceForLifePeriodContext(String value) =>
      refsForUnits(index.byLifePeriodContext(value));

  /// All Canon units whose subject or object is [canonPeriodStatusId].
  List<ThaiCanonEvidenceRef> evidenceForPeriodStatusCanonId(
    String canonPeriodStatusId,
  ) =>
      refsForUnits(
        index.units.where(
          (u) =>
              u.subject == canonPeriodStatusId || u.object == canonPeriodStatusId,
        ),
      );

  /// Remedy Canon — always classified [ThaiCanonEvidenceSafety.remedyInternalOnly].
  List<ThaiCanonEvidenceRef> evidenceForRemedyDomain() {
    return refsForUnits(index.byRemedyDomain()).map((ref) {
      if (ref.safety == ThaiCanonEvidenceSafety.remedyInternalOnly) return ref;
      return ThaiCanonEvidenceRef(
        unitId: ref.unitId,
        relation: ref.relation,
        subject: ref.subject,
        object: ref.object,
        sourceBookId: ref.sourceBookId,
        sourcePage: ref.sourcePage,
        sourceRef: ref.sourceRef,
        contextType: ref.contextType,
        contextValue: ref.contextValue,
        condition: ref.condition,
        confidence: ref.confidence,
        domain: ref.domain,
        safety: ThaiCanonEvidenceSafety.remedyInternalOnly,
      );
    }).toList(growable: false);
  }

  List<ThaiCanonEvidenceRef> evidenceForRemedyId(String remedyId) =>
      refsForUnits(index.bySubject(remedyId));
}
